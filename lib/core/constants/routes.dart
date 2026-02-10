/// Route names untuk navigasi
class Routes {
  Routes._();

  // Main Routes
  static const String home = '/';
  static const String dashboard = '/dashboard';

  // Inventory
  static const String inventory = '/inventory';
  static const String addProduct = '/inventory/add';
  static const String editProduct = '/inventory/edit';
  static const String productDetail = '/inventory/detail';

  // Stock Opname
  static const String stockOpname = '/stock-opname';
  static const String stockOpnameDetail = '/stock-opname/detail';
  static const String createStockOpname = '/stock-opname/create';

  // Orders
  static const String orders = '/orders';
  static const String createOrder = '/orders/create';
  static const String orderDetail = '/orders/detail';

  // Customers
  static const String customers = '/customers';
  static const String customerDetail = '/customers/detail';
  static const String unpaidInvoices = '/customers/unpaid-invoices';

  // Reports
  static const String reports = '/reports';
  static const String transactionReport = '/reports/transaction';
  static const String stockReport = '/reports/stock';
  static const String salesReport = '/reports/sales';

  // Printing
  static const String printPreview = '/print-preview';

  // Settings
  static const String settings = '/settings';
  static const String backup = '/settings/backup';
}
