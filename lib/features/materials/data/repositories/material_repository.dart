import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/material.dart';

final materialRepositoryProvider = Provider((ref) => MaterialRepository());

class MaterialRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const _tableName = 'materials';

  /// Initialize materials table
  Future<void> ensureTableExists() async {
    final db = await _db.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
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
  }

  /// Get all materials
  Future<List<ProductMaterial>> getAll({bool activeOnly = true}) async {
    await ensureTableExists();
    final db = await _db.database;

    String whereClause = activeOnly ? 'WHERE is_active = 1' : '';
    final result = await db.rawQuery('''
      SELECT * FROM $_tableName $whereClause ORDER BY name ASC
    ''');

    return result.map((map) => ProductMaterial.fromMap(map)).toList();
  }

  /// Get material by ID
  Future<ProductMaterial?> getById(String id) async {
    await ensureTableExists();
    final db = await _db.database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return ProductMaterial.fromMap(result.first);
  }

  /// Create new material
  Future<ProductMaterial> create(ProductMaterial material) async {
    await ensureTableExists();
    final db = await _db.database;

    final newMaterial = material.copyWith(
      id: material.id.isEmpty ? const Uuid().v4() : material.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert(_tableName, newMaterial.toMap());
    return newMaterial;
  }

  /// Update material
  Future<void> update(ProductMaterial material) async {
    await ensureTableExists();
    final db = await _db.database;

    final updatedMaterial = material.copyWith(updatedAt: DateTime.now());
    await db.update(
      _tableName,
      updatedMaterial.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  /// Delete material (soft delete)
  Future<void> delete(String id) async {
    await ensureTableExists();
    final db = await _db.database;
    await db.update(
      _tableName,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete material
  Future<void> hardDelete(String id) async {
    await ensureTableExists();
    final db = await _db.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Adjust material stock
  Future<void> adjustStock(String id, double adjustment) async {
    await ensureTableExists();
    final db = await _db.database;
    await db.rawUpdate('''
      UPDATE $_tableName 
      SET stock = stock + ?, updated_at = ?
      WHERE id = ?
    ''', [adjustment, DateTime.now().toIso8601String(), id]);
  }

  /// Get low stock materials
  Future<List<ProductMaterial>> getLowStock() async {
    await ensureTableExists();
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT * FROM $_tableName 
      WHERE is_active = 1 AND stock <= min_stock
      ORDER BY stock ASC
    ''');

    return result.map((map) => ProductMaterial.fromMap(map)).toList();
  }

  /// Get material count
  Future<int> getCount() async {
    await ensureTableExists();
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_tableName WHERE is_active = 1
    ''');
    return result.first['count'] as int;
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    await ensureTableExists();
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(stock * price_per_unit), 0) as total 
      FROM $_tableName WHERE is_active = 1
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
