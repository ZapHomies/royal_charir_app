import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../../../core/database/database_helper.dart';
import '../models/expense_model.dart';

/// Expense Repository
class ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  static const String _tableName = 'expenses';

  ExpenseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Ensure table exists
  Future<void> _ensureTableExists() async {
    final db = await _dbHelper.database;

    // Check if table exists
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$_tableName'");

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE $_tableName (
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          expense_date TEXT NOT NULL,
          notes TEXT,
          receipt_path TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      _logger.i('Expenses table created');
    }
  }

  /// Get all expenses
  Future<List<ExpenseModel>> getAllExpenses({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (category != null && category.isNotEmpty) {
        whereClause = 'category = ?';
        whereArgs.add(category);
      }

      if (startDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'expense_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'expense_date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final maps = await db.query(
        _tableName,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'expense_date DESC',
      );

      return maps.map((map) => ExpenseModel.fromDatabase(map)).toList();
    } catch (e) {
      _logger.e('Error getting expenses: $e');
      rethrow;
    }
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      final maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ExpenseModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting expense: $e');
      rethrow;
    }
  }

  /// Create expense
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      final newExpense = expense.copyWith(
        id: expense.id.isNotEmpty ? expense.id : _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insert(_tableName, newExpense.toDatabase());

      _logger.i('Expense created: ${newExpense.description}');
      return newExpense;
    } catch (e) {
      _logger.e('Error creating expense: $e');
      rethrow;
    }
  }

  /// Update expense
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      final updated = expense.copyWith(updatedAt: DateTime.now());

      await db.update(
        _tableName,
        updated.toDatabase(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );

      _logger.i('Expense updated: ${updated.description}');
      return updated;
    } catch (e) {
      _logger.e('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String id) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.i('Expense deleted: $id');
    } catch (e) {
      _logger.e('Error deleting expense: $e');
      rethrow;
    }
  }

  /// Get total expenses
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause = 'expense_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'expense_date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(amount), 0) as total FROM $_tableName
        ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      ''', whereArgs);

      return (result.first['total'] as num).toDouble();
    } catch (e) {
      _logger.e('Error getting total expenses: $e');
      rethrow;
    }
  }

  /// Get expenses by category
  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _ensureTableExists();
      final db = await _dbHelper.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause = 'WHERE expense_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isEmpty) {
          whereClause = 'WHERE expense_date <= ?';
        } else {
          whereClause += ' AND expense_date <= ?';
        }
        whereArgs.add(endDate.toIso8601String());
      }

      final result = await db.rawQuery('''
        SELECT category, COALESCE(SUM(amount), 0) as total 
        FROM $_tableName
        $whereClause
        GROUP BY category
      ''', whereArgs);

      final Map<String, double> categoryTotals = {};
      for (final row in result) {
        final category = row['category'] as String;
        final total = (row['total'] as num).toDouble();
        categoryTotals[category] = total;
      }

      return categoryTotals;
    } catch (e) {
      _logger.e('Error getting expenses by category: $e');
      rethrow;
    }
  }

  /// Get today's expenses
  Future<double> getTodayExpenses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTotalExpenses(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get this month's expenses
  Future<double> getMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getTotalExpenses(startDate: startOfMonth, endDate: endOfMonth);
  }
}


