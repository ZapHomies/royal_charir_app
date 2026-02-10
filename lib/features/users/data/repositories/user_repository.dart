import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final result = await db.query(DatabaseTables.users, orderBy: 'name ASC');
    return result.map((map) => UserModel.fromDatabase(map)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseTables.users,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromDatabase(result.first);
    }
    return null;
  }

  Future<void> addUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseTables.users,
      user.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseTables.users,
      user.toDatabase(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseTables.users,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncUsers(List<UserModel> users) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Optional: Clear existing users or just update/insert
      // await txn.delete(DatabaseTables.users);

      for (final user in users) {
        await txn.insert(
          DatabaseTables.users,
          user.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
