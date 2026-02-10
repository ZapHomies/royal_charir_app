import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';

import '../constants/database_tables.dart';

/// SQLite Database Helper untuk Royal Charir
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static final Logger _logger = Logger();

  static const String _databaseName = 'royal_charir_v3.db';
  static const int _databaseVersion = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String dbPath = join(appDocDir.path, 'RoyalCharir', _databaseName);

      // Create directory with better error handling
      final Directory dbDir = Directory(dirname(dbPath));
      try {
        if (!await dbDir.exists()) {
          await dbDir.create(recursive: true);
          _logger.i('Database directory created: ${dbDir.path}');
        }
      } catch (dirError) {
        _logger.e('Error creating database directory: $dirError');
        // Try to use the app documents directory directly
        final fallbackPath = join(appDocDir.path, _databaseName);
        _logger.w('Using fallback database path: $fallbackPath');
        return await _openDatabase(fallbackPath);
      }

      _logger.i('Database path: $dbPath');
      return await _openDatabase(dbPath);
    } catch (e) {
      _logger.e('Error initializing database: $e');
      // Ultimate fallback - use temp directory
      final tempDir = Directory.systemTemp;
      final fallbackPath = join(tempDir.path, 'RoyalCharir', _databaseName);
      final fallbackDir = Directory(dirname(fallbackPath));
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      _logger.w('Using temp fallback database path: $fallbackPath');
      return await _openDatabase(fallbackPath);
    }
  }

  Future<Database> _openDatabase(String dbPath) async {
    final database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );
    _logger.i('Database initialized successfully at: $dbPath');
    return database;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    _logger.d('Foreign keys enabled');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 3) {
      // Add wholesale_price column to products table
      try {
        await db.execute('''
          ALTER TABLE ${DatabaseTables.products} 
          ADD COLUMN wholesale_price REAL
        ''');
        // Set wholesale_price to same as price for existing products
        await db.execute('''
          UPDATE ${DatabaseTables.products} 
          SET wholesale_price = price 
          WHERE wholesale_price IS NULL
        ''');
        _logger.i('Added wholesale_price column to products table');
      } catch (e) {
        _logger.w('Column wholesale_price may already exist: $e');
      }
    }

    if (oldVersion < 4) {
      // Create materials table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseTables.materials} (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            unit TEXT DEFAULT 'pcs',
            stock REAL DEFAULT 0,
            min_stock REAL DEFAULT 10,
            price_per_unit REAL DEFAULT 0,
            supplier TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_materials_name ON ${DatabaseTables.materials}(name)');
        _logger.i('Created materials table');
      } catch (e) {
        _logger.w('Materials table may already exist: $e');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables...');

    // Products
    await db.execute('''
      CREATE TABLE ${DatabaseTables.products} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        wholesale_price REAL,
        stock INTEGER NOT NULL DEFAULT 0,
        min_stock INTEGER DEFAULT 10,
        unit TEXT DEFAULT 'pcs',
        image_path TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Customers
    await db.execute('''
      CREATE TABLE ${DatabaseTables.customers} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        customer_type TEXT NOT NULL,
        notes TEXT,
        total_debt REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Orders
    await db.execute('''
      CREATE TABLE ${DatabaseTables.orders} (
        id TEXT PRIMARY KEY,
        order_number TEXT UNIQUE NOT NULL,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        order_type TEXT NOT NULL,
        order_date TEXT NOT NULL,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0,
        final_amount REAL NOT NULL,
        payment_status TEXT NOT NULL,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseTables.customers}(id) ON DELETE RESTRICT
      )
    ''');

    // Order Items
    await db.execute('''
      CREATE TABLE ${DatabaseTables.orderItems} (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES ${DatabaseTables.orders}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id)
      )
    ''');

    // Stock Opname
    await db.execute('''
      CREATE TABLE ${DatabaseTables.stockOpnames} (
        id TEXT PRIMARY KEY,
        opname_number TEXT UNIQUE NOT NULL,
        opname_date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        approved_by TEXT,
        approved_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Stock Opname Items
    await db.execute('''
      CREATE TABLE ${DatabaseTables.stockOpnameItems} (
        id TEXT PRIMARY KEY,
        opname_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        system_stock INTEGER NOT NULL,
        physical_stock INTEGER NOT NULL,
        difference INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (opname_id) REFERENCES ${DatabaseTables.stockOpnames}(id) ON DELETE CASCADE
      )
    ''');

    // Users (Staff)
    await db.execute('''
      CREATE TABLE ${DatabaseTables.users} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        password TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Wholesale Prices
    await db.execute('''
      CREATE TABLE wholesale_prices (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseTables.customers}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute(
        'CREATE INDEX idx_products_name ON ${DatabaseTables.products}(name)');
    await db.execute(
        'CREATE INDEX idx_customers_name ON ${DatabaseTables.customers}(name)');
    await db.execute(
        'CREATE INDEX idx_orders_date ON ${DatabaseTables.orders}(order_date)');
    await db.execute(
        'CREATE INDEX idx_orders_status ON ${DatabaseTables.orders}(payment_status)');

    // Materials
    await db.execute('''
      CREATE TABLE ${DatabaseTables.materials} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        unit TEXT DEFAULT 'pcs',
        stock REAL DEFAULT 0,
        min_stock REAL DEFAULT 10,
        price_per_unit REAL DEFAULT 0,
        supplier TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_materials_name ON ${DatabaseTables.materials}(name)');

    _logger.i('Database tables created successfully');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> reset() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocDir.path, 'RoyalCharir', _databaseName);

    await close();

    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
      _logger.w('Database deleted');
    }

    _database = await _initDatabase();
  }

  Future<String> getDatabasePath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return join(appDocDir.path, 'RoyalCharir', _databaseName);
  }
}
