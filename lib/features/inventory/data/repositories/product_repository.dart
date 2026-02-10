import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/product_model.dart';

/// Product Repository - Handle all product database operations
class ProductRepository {
  final DatabaseHelper _dbHelper;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  ProductRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Get all products
  Future<List<ProductModel>> getAllProducts({
    bool activeOnly = false,
    String? category,
  }) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (activeOnly) {
        whereClause = 'is_active = ?';
        whereArgs.add(1);
      }

      if (category != null && category.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'category = ?';
        whereArgs.add(category);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.products,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'name ASC',
      );

      return maps.map((map) => ProductModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting all products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.products,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ProductModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting product by id: $e');
      rethrow;
    }
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.products,
        where: 'name LIKE ? OR category LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return maps.map((map) => ProductModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error searching products: $e');
      rethrow;
    }
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM ${DatabaseTables.products}
        WHERE stock <= min_stock AND is_active = 1
        ORDER BY stock ASC
      ''');

      return maps.map((map) => ProductModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting low stock products: $e');
      rethrow;
    }
  }

  /// Get all categories
  Future<List<String>> getAllCategories() async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT category FROM ${DatabaseTables.products}
        WHERE is_active = 1
        ORDER BY category ASC
      ''');

      return maps.map((map) => map['category'] as String).toList();
    } catch (e) {
      _logger.e('Error getting categories: $e');
      rethrow;
    }
  }

  /// Create new product
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final db = await _dbHelper.database;

      final newProduct = product.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insert(
        DatabaseTables.products,
        newProduct.toDatabase(),
      );

      _logger.i('Product created: ${newProduct.name}');
      return newProduct;
    } catch (e) {
      _logger.e('Error creating product: $e');
      rethrow;
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final db = await _dbHelper.database;

      final updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
      );

      await db.update(
        DatabaseTables.products,
        updatedProduct.toDatabase(),
        where: 'id = ?',
        whereArgs: [updatedProduct.id],
      );

      _logger.i('Product updated: ${updatedProduct.name}');
      return updatedProduct;
    } catch (e) {
      _logger.e('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product (soft delete)
  Future<void> deleteProduct(String id) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        DatabaseTables.products,
        {
          'is_active': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Product soft deleted: $id');
    } catch (e) {
      _logger.e('Error deleting product: $e');
      rethrow;
    }
  }

  /// Hard delete product (permanent)
  Future<void> hardDeleteProduct(String id) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        DatabaseTables.products,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Product hard deleted: $id');
    } catch (e) {
      _logger.e('Error hard deleting product: $e');
      rethrow;
    }
  }

  /// Update stock
  Future<void> updateStock(String id, int newStock) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        DatabaseTables.products,
        {
          'stock': newStock,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Stock updated for product: $id, new stock: $newStock');
    } catch (e) {
      _logger.e('Error updating stock: $e');
      rethrow;
    }
  }

  /// Adjust stock (add or subtract)
  Future<void> adjustStock(String id, int adjustment) async {
    try {
      final db = await _dbHelper.database;

      await db.rawUpdate('''
        UPDATE ${DatabaseTables.products}
        SET stock = stock + ?,
            updated_at = ?
        WHERE id = ?
      ''', [adjustment, DateTime.now().toIso8601String(), id]);

      _logger.i('Stock adjusted for product: $id, adjustment: $adjustment');
    } catch (e) {
      _logger.e('Error adjusting stock: $e');
      rethrow;
    }
  }

  /// Get product count
  Future<int> getProductCount({bool activeOnly = true}) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseTables.products}
        ${activeOnly ? 'WHERE is_active = 1' : ''}
      ''');

      return result.first['count'] as int;
    } catch (e) {
      _logger.e('Error getting product count: $e');
      rethrow;
    }
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery('''
        SELECT SUM(stock * price) as total FROM ${DatabaseTables.products}
        WHERE is_active = 1
      ''');

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      _logger.e('Error getting total stock value: $e');
      rethrow;
    }
  }
}
