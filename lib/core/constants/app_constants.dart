/// Konstanta aplikasi Royal Charir
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Royal Charir';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem Informasi Manajemen Gudang';
  static const String companyName = 'Royal Charir Furniture';

  // Database
  static const String databaseName = 'royal_charir.db';
  static const int databaseVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Order Types
  static const String orderTypeWholesale = 'wholesale';
  static const String orderTypeRetail = 'retail';

  // Payment Status
  static const String paymentStatusPaid = 'Lunas';
  static const String paymentStatusUnpaid = 'Belum Bayar';
  static const String paymentStatusPartial = 'Sebagian';

  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodTransfer = 'transfer';
  static const String paymentMethodCheque = 'cheque';

  // Document Types
  static const String documentTypeInvoice = 'invoice';
  static const String documentTypeDeliveryNote = 'delivery_note';

  // Transaction Types
  static const String transactionTypeSale = 'sale';
  static const String transactionTypePurchase = 'purchase';
  static const String transactionTypeAdjustment = 'adjustment';
  static const String transactionTypeReturn = 'return';

  // Stock Movement Types
  static const String stockMovementIn = 'in';
  static const String stockMovementOut = 'out';

  // Stock Opname Status
  static const String stockOpnameStatusDraft = 'draft';
  static const String stockOpnameStatusCompleted = 'Selesai';

  // Customer Types
  static const String customerTypeWholesale = 'wholesale';
  static const String customerTypeRetail = 'retail';

  // Date Formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatDatabase = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormatReport = 'dd MMMM yyyy';
  static const String dateFormatInvoice = 'dd/MM/yyyy HH:mm';

  // File Paths
  static const String documentsFolder = 'documents';
  static const String invoicesFolder = 'invoices';
  static const String deliveryNotesFolder = 'delivery_notes';
  static const String reportsFolder = 'Laporan';
  static const String backupFolder = 'backups';
  static const String imageFolder = 'images';

  // Image Settings
  static const int maxImageSize = 2048; // 2MB
  static const int imageQuality = 85;
  static const int thumbnailSize = 200;

  // Backup Settings
  static const String backupFileExtension = '.rcbackup';
  static const String backupDateFormat = 'yyyyMMdd_HHmmss';

  // Auto Backup
  static const int autoBackupIntervalDays = 7;

  // Report Formats
  static const String reportFormatPDF = 'pdf';
  static const String reportFormatExcel = 'excel';
  static const String reportFormatCSV = 'csv';

  // Currency
  static const String currencySymbol = 'Rp';
  static const String currencyLocale = 'id_ID';

  // Units
  static const List<String> productUnits = [
    'pcs',
    'set',
    'lusin',
    'kodi',
    'gross',
    'box',
  ];

  // Product Categories (Default)
  static const List<String> defaultCategories = [
    'Bantal',
    'Guling',
    'Tikar',
    'Kasur',
    'Aksesoris',
  ];

  // Settings Keys
  static const String settingThemeMode = 'theme_mode';
  static const String settingLastBackup = 'last_backup';
  static const String settingAutoBackup = 'auto_backup';
  static const String settingCompanyName = 'company_name';
  static const String settingCompanyAddress = 'company_address';
  static const String settingCompanyPhone = 'company_phone';
  static const String settingInvoicePrefix = 'invoice_prefix';
  static const String settingDeliveryNotePrefix = 'delivery_note_prefix';

  // Default Values
  static const String defaultInvoicePrefix = 'INV';
  static const String defaultDeliveryNotePrefix = 'SJ';
  static const int defaultMinStock = 10;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Snackbar Duration
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration snackbarDurationLong = Duration(seconds: 5);

  // Debounce Duration (untuk search)
  static const Duration debounceDuration = Duration(milliseconds: 500);
}
