import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../constants/database_tables.dart';

/// Database Seeder untuk mengisi data sample
class DatabaseSeeder {
  static final DatabaseSeeder _instance = DatabaseSeeder._internal();
  factory DatabaseSeeder() => _instance;
  DatabaseSeeder._internal();

  final _uuid = const Uuid();

  /// Seed semua data sample
  Future<void> seedAll() async {
    final db = await DatabaseHelper.instance.database;

    // Fix any existing customer types (migration)
    await _fixCustomerTypes(db);

    // Check if data already exists
    final existingProducts = await db.query(DatabaseTables.products);
    if (existingProducts.isNotEmpty) {
      return; // Data already seeded
    }

    await _seedProducts(db);
    await _seedCustomers(db);
  }

  /// Fix existing customer types from 'grosir'/'ecer' to 'wholesale'/'retail'
  Future<void> _fixCustomerTypes(dynamic db) async {
    await db.rawUpdate('''
      UPDATE ${DatabaseTables.customers}
      SET customer_type = 'wholesale'
      WHERE customer_type = 'grosir'
    ''');
    await db.rawUpdate('''
      UPDATE ${DatabaseTables.customers}
      SET customer_type = 'retail'
      WHERE customer_type = 'ecer'
    ''');
  }

  Future<void> _seedProducts(dynamic db) async {
    final now = DateTime.now().toIso8601String();

    final products = [
      {
        'id': _uuid.v4(),
        'name': 'Bantal Dakron Standard',
        'category': 'Bantal',
        'description': 'Bantal dakron berkualitas tinggi',
        'price': 45000.0,
        'wholesale_price': 35000.0,
        'stock': 100,
        'min_stock': 20,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Bantal Dakron Premium',
        'category': 'Bantal',
        'description': 'Bantal dakron premium dengan cover satin',
        'price': 75000.0,
        'wholesale_price': 60000.0,
        'stock': 50,
        'min_stock': 10,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Guling Dakron Standard',
        'category': 'Guling',
        'description': 'Guling dakron untuk tidur nyaman',
        'price': 55000.0,
        'wholesale_price': 45000.0,
        'stock': 80,
        'min_stock': 15,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Guling Dakron Premium',
        'category': 'Guling',
        'description': 'Guling dakron premium ukuran besar',
        'price': 85000.0,
        'wholesale_price': 70000.0,
        'stock': 40,
        'min_stock': 8,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Kasur Lipat 3 Medium',
        'category': 'Kasur',
        'description': 'Kasur lipat 3 ukuran 90x180cm',
        'price': 180000.0,
        'wholesale_price': 150000.0,
        'stock': 25,
        'min_stock': 5,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Kasur Lipat 3 Large',
        'category': 'Kasur',
        'description': 'Kasur lipat 3 ukuran 120x200cm',
        'price': 250000.0,
        'wholesale_price': 210000.0,
        'stock': 20,
        'min_stock': 5,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Tikar Lipat Motif',
        'category': 'Tikar',
        'description': 'Tikar lipat dengan berbagai motif',
        'price': 65000.0,
        'wholesale_price': 50000.0,
        'stock': 60,
        'min_stock': 12,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Sarung Bantal Set',
        'category': 'Aksesoris',
        'description': 'Set sarung bantal 2pcs',
        'price': 35000.0,
        'wholesale_price': 25000.0,
        'stock': 150,
        'min_stock': 30,
        'unit': 'set',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Sarung Guling Set',
        'category': 'Aksesoris',
        'description': 'Set sarung guling 2pcs',
        'price': 40000.0,
        'wholesale_price': 30000.0,
        'stock': 120,
        'min_stock': 25,
        'unit': 'set',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Sprei Single',
        'category': 'Aksesoris',
        'description': 'Sprei ukuran single 90x200cm',
        'price': 85000.0,
        'wholesale_price': 65000.0,
        'stock': 5, // Low stock untuk testing
        'min_stock': 10,
        'unit': 'pcs',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final product in products) {
      await db.insert(DatabaseTables.products, product);
    }
  }

  Future<void> _seedCustomers(dynamic db) async {
    final now = DateTime.now().toIso8601String();

    final customers = [
      {
        'id': _uuid.v4(),
        'name': 'Toko Maju Jaya',
        'phone': '08123456789',
        'email': 'tokojaya@example.com',
        'address': 'Jl. Raya Utama No. 123, Jakarta',
        'customer_type': 'wholesale',
        'notes': 'Pelanggan grosir tetap sejak 2020',
        'total_debt': 0.0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'CV Berkah Textile',
        'phone': '08234567890',
        'email': 'berkah@example.com',
        'address': 'Jl. Industri Raya No. 45, Bandung',
        'customer_type': 'wholesale',
        'notes': 'Pembelian rutin setiap minggu',
        'total_debt': 500000.0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Budi Santoso',
        'phone': '08345678901',
        'email': null,
        'address': 'Perumahan Griya Indah Blok A5',
        'customer_type': 'retail',
        'notes': null,
        'total_debt': 0.0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Ibu Maria',
        'phone': '08456789012',
        'email': null,
        'address': 'Jl. Melati No. 78',
        'customer_type': 'retail',
        'notes': 'Sering pesan untuk reseller kecil',
        'total_debt': 150000.0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Toko Sumber Rezeki',
        'phone': '08567890123',
        'email': 'sumberrezeki@example.com',
        'address': 'Pasar Tradisional Stand B12, Surabaya',
        'customer_type': 'wholesale',
        'notes': 'Pelanggan baru 2024',
        'total_debt': 0.0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final customer in customers) {
      await db.insert(DatabaseTables.customers, customer);
    }
  }
}
