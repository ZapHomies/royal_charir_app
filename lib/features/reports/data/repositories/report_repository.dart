import 'package:intl/intl.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/sales_report_model.dart';

/// Reports Repository
class ReportRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get Sales Report
  Future<SalesReportModel> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;

    // Format dates
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd 23:59:59').format(endDate);

    // Total sales statistics
    final salesStats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(final_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(remaining_amount), 0) as total_remaining,
        COALESCE(SUM(CASE WHEN payment_status = 'Lunas' THEN 1 ELSE 0 END), 0) as paid_orders,
        COALESCE(SUM(CASE WHEN payment_status = 'Sebagian' THEN 1 ELSE 0 END), 0) as partial_orders,
        COALESCE(SUM(CASE WHEN payment_status = 'Belum Bayar' OR payment_status = 'unpaid' THEN 1 ELSE 0 END), 0) as unpaid_orders
      FROM ${DatabaseTables.orders}
      WHERE order_date >= ? AND order_date <= ?
    ''', [start, end]);

    final stats = salesStats.first;

    // Top products
    final topProductsData = await db.rawQuery('''
      SELECT 
        oi.product_name,
        COALESCE(SUM(oi.subtotal), 0) as amount,
        SUM(oi.quantity) as count
      FROM ${DatabaseTables.orderItems} oi
      INNER JOIN ${DatabaseTables.orders} o ON oi.order_id = o.id
      WHERE o.order_date >= ? AND order_date <= ?
      GROUP BY oi.product_name
      ORDER BY amount DESC
      LIMIT 10
    ''', [start, end]);

    final topProducts = topProductsData
        .map((p) => SalesReportItem(
              name: p['product_name'] as String,
              amount: (p['amount'] as num).toDouble(),
              count: p['count'] as int,
            ))
        .toList();

    // Top customers - JOIN with customers table
    final topCustomersData = await db.rawQuery('''
      SELECT 
        c.name as customer_name,
        COALESCE(SUM(o.final_amount), 0) as amount,
        COUNT(*) as count
      FROM ${DatabaseTables.orders} o
      INNER JOIN ${DatabaseTables.customers} c ON o.customer_id = c.id
      WHERE o.order_date >= ? AND o.order_date <= ?
      GROUP BY c.id, c.name
      ORDER BY amount DESC
      LIMIT 10
    ''', [start, end]);

    final topCustomers = topCustomersData
        .map((c) => SalesReportItem(
              name: c['customer_name'] as String,
              amount: (c['amount'] as num).toDouble(),
              count: c['count'] as int,
            ))
        .toList();

    return SalesReportModel(
      startDate: startDate,
      endDate: endDate,
      totalSales: (stats['total_sales'] as num).toDouble(),
      totalPaid: (stats['total_paid'] as num).toDouble(),
      totalRemaining: (stats['total_remaining'] as num).toDouble(),
      totalOrders: stats['total_orders'] as int,
      paidOrders: stats['paid_orders'] as int,
      partialOrders: stats['partial_orders'] as int,
      unpaidOrders: stats['unpaid_orders'] as int,
      topProducts: topProducts,
      topCustomers: topCustomers,
    );
  }

  /// Get Stock Report
  Future<StockReportModel> getStockReport() async {
    final db = await _dbHelper.database;

    // Get all products with stock info
    final products = await db.query(
      DatabaseTables.products,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    final items = products.map((p) {
      final stock = p['stock'] as int;
      final price = (p['price'] as num).toDouble();
      final minStock = p['min_stock'] as int? ?? 10;
      final unit = p['unit'] as String? ?? 'pcs';

      String status;
      // Low stock if less than minStock
      if (stock <= 0) {
        status = 'out';
      } else if (stock < minStock) {
        status = 'low';
      } else {
        status = 'OK';
      }

      return ProductStockInfo(
        productId: p['id'] as String,
        productName: p['name'] as String,
        category: p['category'] as String,
        stock: stock,
        minStock: minStock,
        unit: unit,
        price: price,
        stockValue: stock * price,
        status: status,
      );
    }).toList();

    // Calculate totals
    final totalProducts = items.length;
    final lowStockProducts = items.where((i) => i.status == 'low').length;
    final outOfStockProducts = items.where((i) => i.status == 'out').length;
    final totalStockValue = items.fold<double>(
      0,
      (sum, item) => sum + item.stockValue,
    );

    return StockReportModel(
      totalProducts: totalProducts,
      lowStockProducts: lowStockProducts,
      outOfStockProducts: outOfStockProducts,
      totalStockValue: totalStockValue,
      items: items,
    );
  }

  /// Get Daily Sales (for charts)
  Future<Map<String, double>> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;

    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd 23:59:59').format(endDate);

    final results = await db.rawQuery('''
      SELECT 
        DATE(order_date) as date,
        COALESCE(SUM(final_amount), 0) as total
      FROM ${DatabaseTables.orders}
      WHERE order_date >= ? AND order_date <= ?
      GROUP BY DATE(order_date)
      ORDER BY DATE(order_date)
    ''', [start, end]);

    return Map.fromEntries(
      results.map((r) => MapEntry(
            r['date'] as String,
            (r['total'] as num).toDouble(),
          )),
    );
  }
}
