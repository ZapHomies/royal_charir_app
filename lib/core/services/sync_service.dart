import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:royal_charir_app/core/database/database_helper.dart';
import 'package:royal_charir_app/core/api/api_client.dart';
import 'package:royal_charir_app/features/sync/data/datasources/product_remote_datasource.dart';
import 'package:royal_charir_app/features/sync/data/datasources/customer_remote_datasource.dart';
import 'package:royal_charir_app/features/sync/data/datasources/order_remote_datasource.dart';
import 'package:royal_charir_app/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:royal_charir_app/features/sync/data/datasources/user_remote_datasource.dart';

import '../constants/database_tables.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
}

class SyncService {
  final DatabaseHelper databaseHelper;
  final ApiClient apiClient;
  final Logger logger = Logger();
  final Connectivity connectivity = Connectivity();

  late final ProductRemoteDataSource productRemoteDataSource;
  late final CustomerRemoteDataSource customerRemoteDataSource;
  late final OrderRemoteDataSource orderRemoteDataSource;
  late final SyncRemoteDataSource syncRemoteDataSource;
  late final UserRemoteDataSource userRemoteDataSource;

  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _lastError;
  int _totalSynced = 0;

  SyncService({
    required this.databaseHelper,
    required this.apiClient,
  }) {
    productRemoteDataSource = ProductRemoteDataSource(apiClient: apiClient);
    customerRemoteDataSource = CustomerRemoteDataSource(apiClient: apiClient);
    orderRemoteDataSource = OrderRemoteDataSource(apiClient: apiClient);
    syncRemoteDataSource = SyncRemoteDataSource(apiClient: apiClient);
    userRemoteDataSource = UserRemoteDataSource(apiClient: apiClient);
  }

  SyncStatus get status => _status;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastError => _lastError;
  int get productsCreated => _totalSynced;
  int get productsUpdated => 0;

  Future<bool> isOnline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.mobile);
  }

  Future<Map<String, dynamic>?> getServerStatus() async {
    try {
      if (!await isOnline()) return null;
      return await syncRemoteDataSource.getSyncStatus();
    } catch (e) {
      logger.e('Failed to get server status: $e');
      return null;
    }
  }

  Future<bool> fullSync() async {
    _status = SyncStatus.syncing;
    _totalSynced = 0;

    try {
      if (!await isOnline()) {
        throw Exception('Device is offline');
      }

      logger.i('Starting full sync...');
      final db = await databaseHelper.database;

      // 0. CLEANUP BAD DATA (Null IDs)
      await db.delete(DatabaseTables.products, where: 'id IS NULL');
      await db.delete(DatabaseTables.customers, where: 'id IS NULL');
      await db.delete(DatabaseTables.users, where: 'id IS NULL');

      // 1. PRODUCTS SYNC
      final products = await productRemoteDataSource.getProducts();
      for (final product in products) {
        final existing = await db.query(DatabaseTables.products,
            where: 'id = ?', whereArgs: [product['uuid']]);
        final data = {
          'id': product['uuid'],
          'name': product['name'],
          'category': product['category'],
          'description': product['description'],
          'price': product['price'],
          'stock': product['stock'],
          'min_stock': product['min_stock'] ?? 10,
          'unit': product['unit'] ?? 'pcs',
          'image_path': product['image'],
          'is_active':
              (product['is_active'] == true || product['is_active'] == 1)
                  ? 1
                  : 0,
          'created_at': product['created_at'],
          'updated_at': product['updated_at'],
        };
        if (existing.isEmpty) {
          await db.insert(DatabaseTables.products, data);
        } else {
          await db.update(DatabaseTables.products, data,
              where: 'id = ?', whereArgs: [product['uuid']]);
        }
        _totalSynced++;
      }

      // 2. CUSTOMERS SYNC
      final customers = await customerRemoteDataSource.getCustomers();
      for (final customer in customers) {
        final existing = await db.query(DatabaseTables.customers,
            where: 'id = ?', whereArgs: [customer['uuid']]);
        final data = {
          'id': customer['uuid'],
          'name': customer['name'],
          'phone': customer['phone'],
          'email': customer['email'],
          'address': customer['address'],
          'customer_type': customer['customer_type'],
          'notes': customer['notes'],
          'total_debt': customer['total_debt'] ?? 0.0,
          'is_active':
              (customer['is_active'] == true || customer['is_active'] == 1)
                  ? 1
                  : 0,
          'created_at': customer['created_at'],
          'updated_at': customer['updated_at'],
        };
        if (existing.isEmpty) {
          await db.insert(DatabaseTables.customers, data);
        } else {
          await db.update(DatabaseTables.customers, data,
              where: 'id = ?', whereArgs: [customer['uuid']]);
        }
        _totalSynced++;
      }

      // 3. USERS SYNC
      final users = await userRemoteDataSource.getUsers();
      for (final user in users) {
        // Skip if user exists locally (to preserve local password)
        // Or update but keep password? Let's keep password.
        final existing = await db.query(DatabaseTables.users,
            where: 'id = ?', whereArgs: [user['uuid']]);

        final data = {
          'id': user['uuid'],
          'name': user['name'],
          'email': user['email'],
          'phone': user['phone'],
          'role': user['role'],
          'is_active':
              (user['is_active'] == true || user['is_active'] == 1) ? 1 : 0,
          'created_at': user['created_at'],
          'updated_at': user['updated_at'],
          // Don't overwrite password from server (it's hashed anyway or null)
        };

        if (existing.isEmpty) {
          await db.insert(DatabaseTables.users, data);
        } else {
          await db.update(DatabaseTables.users, data,
              where: 'id = ?', whereArgs: [user['uuid']]);
        }
        _totalSynced++;
      }

      // 4. PUSH LOCAL PRODUCTS
      final localProducts = await db.query(DatabaseTables.products);
      if (localProducts.isNotEmpty) {
        final productsData = localProducts
            .map((p) => {
                  'uuid': p['id'],
                  'name': p['name'],
                  'category': p['category'],
                  'description': p['description'],
                  'price': p['price'],
                  'stock': p['stock'],
                  'min_stock': p['min_stock'],
                  'unit': p['unit'],
                  'image': p['image_path'],
                  'is_active': p['is_active'] == 1,
                  'created_at': p['created_at'],
                  'updated_at': p['updated_at'],
                })
            .toList();
        await productRemoteDataSource.syncProducts(productsData);
      }

      // 5. PUSH LOCAL CUSTOMERS
      final localCustomers = await db.query(DatabaseTables.customers);
      if (localCustomers.isNotEmpty) {
        final customersData = localCustomers
            .map((c) => {
                  'uuid': c['id'],
                  'name': c['name'],
                  'phone': c['phone'],
                  'email': c['email'],
                  'address': c['address'],
                  'customer_type': c['customer_type'],
                  'notes': c['notes'],
                  'total_debt': c['total_debt'],
                  'is_active': c['is_active'] == 1,
                  'created_at': c['created_at'],
                  'updated_at': c['updated_at'],
                })
            .toList();
        await customerRemoteDataSource.syncCustomers(customersData);
      }

      // 6. PUSH LOCAL USERS
      final localUsers = await db.query(DatabaseTables.users);
      if (localUsers.isNotEmpty) {
        final usersData = localUsers
            .map((u) => {
                  'uuid': u['id'],
                  'name': u['name'],
                  'email': u['email'],
                  'phone': u['phone'],
                  'role': u['role'],
                  'is_active': u['is_active'] == 1,
                  'created_at': u['created_at'],
                  'updated_at': u['updated_at'],
                })
            .toList();
        await userRemoteDataSource.syncUsers(usersData);
      }

      _lastSyncTime = DateTime.now();
      _status = SyncStatus.success;
      _lastError = null;
      logger.i('Sync completed: $_totalSynced records');
      return true;
    } catch (e) {
      logger.e('Sync failed: $e');
      _status = SyncStatus.failed;
      _lastError = e.toString();
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportDatabase({
    String type = 'full',
    String format = 'json',
  }) async {
    try {
      if (!await isOnline()) {
        throw Exception('Device is offline');
      }
      final result = await syncRemoteDataSource.exportDatabase(
        type: type,
        format: format,
        compress: true,
      );
      return result;
    } catch (e) {
      logger.e('Export failed: $e');
      return null;
    }
  }

  Future<bool> importDatabase({
    required String filePath,
    String mode = 'merge',
  }) async {
    try {
      if (!await isOnline()) {
        throw Exception('Device is offline');
      }
      await syncRemoteDataSource.importDatabase(
        filePath: filePath,
        mode: mode,
      );
      await fullSync();
      return true;
    } catch (e) {
      logger.e('Import failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> createBackup() async {
    try {
      if (!await isOnline()) {
        throw Exception('Device is offline');
      }
      final result = await syncRemoteDataSource.createBackup();
      return result;
    } catch (e) {
      logger.e('Backup failed: $e');
      return null;
    }
  }

  /// Backup database to Documents/RoyalCharir/Backups folder
  Future<String?> backupLocalDatabase() async {
    try {
      final dbPath = await databaseHelper.getDatabasePath();
      final file = File(dbPath);
      if (!await file.exists()) return null;

      // Get directory to save (Documents/RoyalCharir/Backups)
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir =
          Directory(join(appDocDir.path, 'RoyalCharir', 'Backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final backupName = 'royal_charir_backup_$timestamp.db';
      final backupPath = join(backupDir.path, backupName);

      await file.copy(backupPath);
      logger.i('Local backup saved to: $backupPath');
      return backupPath;
    } catch (e) {
      logger.e('Local backup failed: $e');
      return null;
    }
  }

  /// Export database to a specific path (for USB/network share)
  Future<String?> exportLocalDatabaseTo(String destinationPath) async {
    try {
      final dbPath = await databaseHelper.getDatabasePath();
      final file = File(dbPath);
      if (!await file.exists()) return null;

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final backupName = 'royal_charir_sync_$timestamp.db';
      final backupPath = join(destinationPath, backupName);

      await file.copy(backupPath);
      logger.i('Database exported to: $backupPath');
      return backupPath;
    } catch (e) {
      logger.e('Export to path failed: $e');
      return null;
    }
  }

  /// Restore database from backup file
  Future<bool> restoreLocalDatabase(String backupPath) async {
    try {
      final dbPath = await databaseHelper.getDatabasePath();
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        logger.e('Backup file not found: $backupPath');
        return false;
      }

      // Validate it's a SQLite database
      final bytes = await backupFile.readAsBytes();
      if (bytes.length < 16 ||
          String.fromCharCodes(bytes.sublist(0, 6)) != 'SQLite') {
        logger.e('Invalid database file');
        return false;
      }

      // Close current database
      await databaseHelper.close();

      // Copy backup to database path
      await backupFile.copy(dbPath);

      // Re-open database
      await databaseHelper.database;

      logger.i('Database restored from: $backupPath');
      return true;
    } catch (e) {
      logger.e('Local restore failed: $e');
      // Try to re-open database even if restore failed
      try {
        await databaseHelper.database;
      } catch (_) {}
      return false;
    }
  }

  /// Get list of available backups
  Future<List<Map<String, dynamic>>> getAvailableBackups() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir =
          Directory(join(appDocDir.path, 'RoyalCharir', 'Backups'));
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      final backups = <Map<String, dynamic>>[];

      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.db')) {
          final stat = await entity.stat();
          backups.add({
            'path': entity.path,
            'name': basename(entity.path),
            'size': stat.size,
            'modified': stat.modified,
          });
        }
      }

      // Sort by modified date descending
      backups.sort((a, b) =>
          (b['modified'] as DateTime).compareTo(a['modified'] as DateTime));

      return backups;
    } catch (e) {
      logger.e('Failed to get backups: $e');
      return [];
    }
  }

  void reset() {
    _status = SyncStatus.idle;
    _lastError = null;
    _totalSynced = 0;
  }
}
