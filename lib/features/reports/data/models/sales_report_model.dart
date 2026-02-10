/// Sales Report Model
class SalesReportModel {
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final double totalPaid;
  final double totalRemaining;
  final int totalOrders;
  final int paidOrders;
  final int partialOrders;
  final int unpaidOrders;
  final List<SalesReportItem> topProducts;
  final List<SalesReportItem> topCustomers;

  const SalesReportModel({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalPaid,
    required this.totalRemaining,
    required this.totalOrders,
    required this.paidOrders,
    required this.partialOrders,
    required this.unpaidOrders,
    required this.topProducts,
    required this.topCustomers,
  });
}

/// Sales Report Item (for top products/customers)
class SalesReportItem {
  final String name;
  final double amount;
  final int count;

  const SalesReportItem({
    required this.name,
    required this.amount,
    required this.count,
  });
}

/// Stock Report Model
class StockReportModel {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalStockValue;
  final List<ProductStockInfo> items;

  const StockReportModel({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalStockValue,
    required this.items,
  });
}

/// Product Stock Info (aligned with Laravel)
class ProductStockInfo {
  final String productId;
  final String productName;
  final String category;
  final int stock;
  final int minStock;
  final String unit;
  final double price;
  final double stockValue;
  final String status; // 'OK', 'low', 'out'

  const ProductStockInfo({
    required this.productId,
    required this.productName,
    required this.category,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.price,
    required this.stockValue,
    required this.status,
  });
}

