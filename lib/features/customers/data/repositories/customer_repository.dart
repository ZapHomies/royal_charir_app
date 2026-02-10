import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/customer_model.dart';
import '../models/wholesale_price.dart';

/// Customer Repository
class CustomerRepository {
  final DatabaseHelper _dbHelper;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  CustomerRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers({
    bool activeOnly = false,
    String? customerType,
  }) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (activeOnly) {
        whereClause = 'is_active = ?';
        whereArgs.add(1);
      }

      if (customerType != null && customerType.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'customer_type = ?';
        whereArgs.add(customerType);
      }

      final maps = await db.query(
        DatabaseTables.customers,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'name ASC',
      );

      return maps.map((map) => CustomerModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting customers: $e');
      rethrow;
    }
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.query(
        DatabaseTables.customers,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return CustomerModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting customer: $e');
      rethrow;
    }
  }

  /// Search customers
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.query(
        DatabaseTables.customers,
        where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return maps.map((map) => CustomerModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error searching customers: $e');
      rethrow;
    }
  }

  /// Get customers with debt
  Future<List<CustomerModel>> getCustomersWithDebt() async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.query(
        DatabaseTables.customers,
        where: 'total_debt > 0 AND is_active = 1',
        orderBy: 'total_debt DESC',
      );

      return maps.map((map) => CustomerModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting customers with debt: $e');
      rethrow;
    }
  }

  /// Create customer
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final db = await _dbHelper.database;

      final newCustomer = customer.copyWith(
        id: customer.id.isNotEmpty ? customer.id : _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insert(
        DatabaseTables.customers,
        newCustomer.toDatabase(),
      );

      _logger.i('Customer created: ${newCustomer.name}');
      return newCustomer;
    } catch (e) {
      _logger.e('Error creating customer: $e');
      rethrow;
    }
  }

  /// Update customer
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final db = await _dbHelper.database;

      final updated = customer.copyWith(updatedAt: DateTime.now());

      await db.update(
        DatabaseTables.customers,
        updated.toDatabase(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );

      _logger.i('Customer updated: ${updated.name}');
      return updated;
    } catch (e) {
      _logger.e('Error updating customer: $e');
      rethrow;
    }
  }

  /// Delete customer (soft delete)
  Future<void> deleteCustomer(String id) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        DatabaseTables.customers,
        {
          'is_active': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Customer deleted: $id');
    } catch (e) {
      _logger.e('Error deleting customer: $e');
      rethrow;
    }
  }

  /// Update customer debt
  Future<void> updateDebt(String id, double newDebt) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        DatabaseTables.customers,
        {
          'total_debt': newDebt,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Customer debt updated: $id, debt: $newDebt');
    } catch (e) {
      _logger.e('Error updating debt: $e');
      rethrow;
    }
  }

  /// Get customer count
  Future<int> getCustomerCount({bool activeOnly = true}) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseTables.customers}
        ${activeOnly ? 'WHERE is_active = 1' : ''}
      ''');

      return result.first['count'] as int;
    } catch (e) {
      _logger.e('Error getting customer count: $e');
      rethrow;
    }
  }

  /// Get total debt
  Future<double> getTotalDebt() async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(total_debt), 0) as total FROM ${DatabaseTables.customers}
        WHERE is_active = 1
      ''');

      return (result.first['total'] as num).toDouble();
    } catch (e) {
      _logger.e('Error getting total debt: $e');
      rethrow;
    }
  }

  /// Get wholesale prices for customer
  Future<List<WholesalePrice>> getWholesalePrices(String customerId) async {
    try {
      final db = await _dbHelper.database;

      final maps = await db.query(
        'wholesale_prices',
        where: 'customer_id = ?',
        whereArgs: [customerId],
      );

      return maps.map((map) => WholesalePrice.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error getting wholesale prices: $e');
      rethrow;
    }
  }

  /// Save wholesale price
  Future<void> saveWholesalePrice(WholesalePrice price) async {
    try {
      final db = await _dbHelper.database;

      await db.insert(
        'wholesale_prices',
        price.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.i('Wholesale price saved');
    } catch (e) {
      _logger.e('Error saving wholesale price: $e');
      rethrow;
    }
  }

  /// Delete wholesale prices by customer ID
  Future<void> deleteWholesalePricesByCustomerId(String customerId) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        'wholesale_prices',
        where: 'customer_id = ?',
        whereArgs: [customerId],
      );

      _logger.i('Wholesale prices deleted for customer: $customerId');
    } catch (e) {
      _logger.e('Error deleting wholesale prices: $e');
      rethrow;
    }
  }

  /// Sync customers from server
  Future<void> syncCustomers(List<CustomerModel> customers) async {
    try {
      final db = await _dbHelper.database;

      await db.transaction((txn) async {
        for (final customer in customers) {
          await txn.insert(
            DatabaseTables.customers,
            customer.toDatabase(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      _logger.i('Customers synced: ${customers.length}');
    } catch (e) {
      _logger.e('Error syncing customers: $e');
      rethrow;
    }
  }
}


