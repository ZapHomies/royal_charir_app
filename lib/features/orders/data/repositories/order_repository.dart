import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/order_model.dart';

/// Order Repository
class OrderRepository {
  final DatabaseHelper _dbHelper;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  OrderRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Generate order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final prefix = 'ORD';
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return '$prefix-$timestamp';
  }

  /// Get all orders
  Future<List<OrderModel>> getAllOrders({
    String? paymentStatus,
    String? orderType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (paymentStatus != null) {
        whereClause = 'payment_status = ?';
        whereArgs.add(paymentStatus);
      }

      if (orderType != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'order_type = ?';
        whereArgs.add(orderType);
      }

      if (startDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'order_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'order_date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final maps = await db.rawQuery('''
        SELECT o.*, c.name as customer_name
        FROM ${DatabaseTables.orders} o
        INNER JOIN ${DatabaseTables.customers} c ON o.customer_id = c.id
        ${whereClause.isEmpty ? '' : 'WHERE $whereClause'}
        ORDER BY o.order_date DESC, o.created_at DESC
      ''', whereArgs);

      final orders = <OrderModel>[];
      for (final map in maps) {
        final items = await getOrderItems(map['id'] as String);
        orders.add(OrderModel.fromDatabase(map).copyWith(items: items));
      }

      return orders;
    } catch (e) {
      _logger.e('Error getting orders: $e');
      rethrow;
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.rawQuery('''
        SELECT o.*, c.name as customer_name
        FROM ${DatabaseTables.orders} o
        INNER JOIN ${DatabaseTables.customers} c ON o.customer_id = c.id
        WHERE o.id = ?
      ''', [id]);

      if (maps.isEmpty) return null;

      final items = await getOrderItems(id);
      return OrderModel.fromDatabase(maps.first).copyWith(items: items);
    } catch (e) {
      _logger.e('Error getting order: $e');
      rethrow;
    }
  }

  /// Get order items
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.query(
        DatabaseTables.orderItems,
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      return maps.map((map) => OrderItemModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting order items: $e');
      rethrow;
    }
  }

  /// Create order
  Future<OrderModel> createOrder(
      OrderModel order, List<OrderItemModel> items) async {
    try {
      final db = await _dbHelper.database;

      // Use provided order data, only generate if missing
      final newOrder = order.copyWith(
        id: order.id.isNotEmpty ? order.id : _uuid.v4(),
        orderNumber: order.orderNumber.isNotEmpty
            ? order.orderNumber
            : _generateOrderNumber(),
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      // Insert order
      await db.insert(DatabaseTables.orders, newOrder.toDatabase());

      // Insert items
      for (final item in items) {
        final newItem = item.copyWith(
          id: item.id.isNotEmpty ? item.id : _uuid.v4(),
          orderId: newOrder.id,
        );
        await db.insert(DatabaseTables.orderItems, newItem.toDatabase());
      }

      // NOTE: Stock update is handled by the caller (checkout page)
      // to avoid double-updating stock

      // Update customer debt if unpaid/partial
      if (newOrder.paymentStatus != 'Lunas') {
        await db.rawUpdate('''
          UPDATE ${DatabaseTables.customers}
          SET total_debt = total_debt + ?, updated_at = ?
          WHERE id = ?
        ''', [
          newOrder.remainingAmount,
          DateTime.now().toIso8601String(),
          newOrder.customerId
        ]);
      }

      _logger.i('Order created: ${newOrder.orderNumber}');
      return newOrder.copyWith(items: items);
    } catch (e) {
      _logger.e('Error creating order: $e');
      rethrow;
    }
  }

  /// Update payment
  Future<void> updatePayment(String orderId, double amount) async {
    try {
      final db = await _dbHelper.database;
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');

      final newPaidAmount = order.paidAmount + amount;
      final newRemaining = order.finalAmount - newPaidAmount;

      String newStatus;
      if (newRemaining <= 0) {
        newStatus = 'Lunas';
      } else if (newPaidAmount > 0) {
        newStatus = 'Sebagian';
      } else {
        newStatus = 'Belum Bayar';
      }

      await db.update(
        DatabaseTables.orders,
        {
          'paid_amount': newPaidAmount,
          'remaining_amount': newRemaining.clamp(0, order.finalAmount),
          'payment_status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Update customer debt
      await db.rawUpdate('''
        UPDATE ${DatabaseTables.customers}
        SET total_debt = total_debt - ?, updated_at = ?
        WHERE id = ?
      ''', [amount, DateTime.now().toIso8601String(), order.customerId]);

      _logger.i('Payment updated: $orderId, amount: $amount');
    } catch (e) {
      _logger.e('Error updating payment: $e');
      rethrow;
    }
  }

  /// Get orders by customer
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.rawQuery('''
        SELECT o.*, c.name as customer_name
        FROM ${DatabaseTables.orders} o
        INNER JOIN ${DatabaseTables.customers} c ON o.customer_id = c.id
        WHERE o.customer_id = ?
        ORDER BY o.order_date DESC
      ''', [customerId]);

      final orders = <OrderModel>[];
      for (final map in maps) {
        final items = await getOrderItems(map['id'] as String);
        orders.add(OrderModel.fromDatabase(map).copyWith(items: items));
      }

      return orders;
    } catch (e) {
      _logger.e('Error getting customer orders: $e');
      rethrow;
    }
  }

  /// Get today's orders
  Future<List<OrderModel>> getTodayOrders() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getAllOrders(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get order count
  Future<int> getOrderCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db
          .rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.orders}');
      return result.first['count'] as int;
    } catch (e) {
      _logger.e('Error getting order count: $e');
      rethrow;
    }
  }

  /// Get total revenue
  Future<double> getTotalRevenue(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause = 'order_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'order_date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final result = await db.rawQuery('''
        SELECT SUM(final_amount) as total FROM ${DatabaseTables.orders}
        ${whereClause.isEmpty ? '' : 'WHERE $whereClause'}
      ''', whereArgs);

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      _logger.e('Error getting revenue: $e');
      rethrow;
    }
  }
}
