import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:royal_charir_app/core/database/database_helper.dart';
import 'package:royal_charir_app/features/categories/domain/entities/category.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Category>> getAll() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.name as id, c.name, 
             COUNT(p.id) as product_count,
             MIN(p.created_at) as created_at,
             MAX(p.updated_at) as updated_at
      FROM (SELECT DISTINCT category as name FROM products) c
      LEFT JOIN products p ON c.name = p.category
      GROUP BY c.name
      ORDER BY c.name
    ''');

    return result
        .map((map) => Category.fromMap({
              'id': map['id'],
              'name': map['name'],
              'description': null,
              'product_count': map['product_count'] ?? 0,
              'created_at':
                  map['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at':
                  map['updated_at'] ?? DateTime.now().toIso8601String(),
            }))
        .toList();
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final db = await _db.database;
    await db.update(
      'products',
      {'category': newName},
      where: 'category = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> deleteCategory(String name) async {
    final db = await _db.database;
    // Set to Uncategorized instead of deleting products
    await db.update(
      'products',
      {'category': 'Uncategorized'},
      where: 'category = ?',
      whereArgs: [name],
    );
  }
}


