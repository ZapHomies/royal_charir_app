import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Enhanced Sync Settings Page with selective export/import
class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  bool _isLoading = false;
  String _statusMessage = '';
  List<FileSystemEntity> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir =
          Directory(p.join(appDir.path, 'RoyalCharir', 'Backups'));

      if (await backupDir.exists()) {
        final files = await backupDir.list().toList();
        final dbFiles = files
            .where((f) => f.path.endsWith('.db') || f.path.endsWith('.json'))
            .toList();
        dbFiles.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        setState(() => _backupFiles = dbFiles);
      }
    } catch (e) {
      debugPrint('Error loading backup files: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Sinkronisasi & Backup'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  _buildInfoCard(isDark).animate().fadeIn().slideY(begin: -0.1),
                  const SizedBox(height: 24),

                  // Export Section
                  _buildSectionTitle(
                      'Export Data', Icons.upload_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.tune_rounded,
                    title: 'Export Selektif',
                    subtitle: 'Pilih data spesifik untuk diexport (JSON)',
                    color: AppColors.primary,
                    onTap: () => _showSelectiveExportDialog(context, isDark),
                    isDark: isDark,
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1),
                  const SizedBox(height: 8),
                  _buildActionCard(
                    icon: Icons.storage_rounded,
                    title: 'Export Database Lengkap',
                    subtitle: 'Export seluruh database ke file (.db)',
                    color: AppColors.info,
                    onTap: _exportFullDatabase,
                    isDark: isDark,
                  ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1),
                  const SizedBox(height: 8),
                  _buildActionCard(
                    icon: Icons.save_rounded,
                    title: 'Buat Backup Lokal',
                    subtitle: 'Simpan backup di folder aplikasi',
                    color: Colors.teal,
                    onTap: _createBackup,
                    isDark: isDark,
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1),
                  const SizedBox(height: 24),

                  // Import Section
                  _buildSectionTitle(
                      'Import Data', Icons.download_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.merge_rounded,
                    title: 'Import & Gabungkan',
                    subtitle: 'Import data baru tanpa menghapus yang ada',
                    color: AppColors.success,
                    onTap: () => _importAndMerge(context, isDark),
                    isDark: isDark,
                  ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  _buildActionCard(
                    icon: Icons.restore_rounded,
                    title: 'Restore Database',
                    subtitle: 'Ganti seluruh database (data lama akan hilang)',
                    color: AppColors.warning,
                    onTap: _importAndReplace,
                    isDark: isDark,
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 24),

                  // Local Backups Section
                  if (_backupFiles.isNotEmpty) ...[
                    _buildSectionTitle(
                        'Backup Lokal', Icons.history_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildBackupList(isDark)
                        .animate(delay: 350.ms)
                        .fadeIn()
                        .slideY(begin: 0.1),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.sync_rounded, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sinkronisasi Antar Perangkat',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoStep('1', 'Export data dari komputer sumber', isDark),
          _buildInfoStep('2', 'Copy file ke USB/cloud/folder bersama', isDark),
          _buildInfoStep('3', 'Import & Gabungkan di komputer tujuan', isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Import & Gabungkan tidak akan menghapus data yang sudah ada',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackupList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: _backupFiles.take(5).map((file) {
          final name = p.basename(file.path);
          final stat = file.statSync();
          final date = DateFormat('dd/MM/yyyy HH:mm').format(stat.modified);
          final size = (stat.size / 1024).toStringAsFixed(0);
          final isJson = file.path.endsWith('.json');

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isJson ? AppColors.success : AppColors.info)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isJson ? Icons.data_object_rounded : Icons.storage_rounded,
                color: isJson ? AppColors.success : AppColors.info,
                size: 20,
              ),
            ),
            title: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '$date • $size KB',
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onSelected: (value) {
                if (value == 'restore') {
                  _restoreFromBackup(file.path);
                } else if (value == 'delete') {
                  _deleteBackup(file.path);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Restore'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== EXPORT FUNCTIONS ====================

  /// Show selective export dialog
  Future<void> _showSelectiveExportDialog(
      BuildContext context, bool isDark) async {
    final selectedTables = <String, bool>{
      'products': true,
      'customers': true,
      'orders': true,
      'order_items': true,
      'materials': true,
    };

    final tableLabels = {
      'products': 'Produk',
      'customers': 'Pelanggan',
      'orders': 'Pesanan',
      'order_items': 'Item Pesanan',
      'materials': 'Bahan',
    };

    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Export Selektif'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih data yang ingin diexport:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                ...selectedTables.keys.map((table) {
                  return CheckboxListTile(
                    value: selectedTables[table],
                    onChanged: (value) {
                      setState(() => selectedTables[table] = value ?? false);
                    },
                    title: Text(tableLabels[table] ?? table),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selectedTables),
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _performSelectiveExport(result);
    }
  }

  /// Perform selective export
  Future<void> _performSelectiveExport(Map<String, bool> selectedTables) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mempersiapkan export...';
    });

    try {
      final selectedDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Pilih folder tujuan export',
      );

      if (selectedDir == null) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Export dibatalkan';
        });
        return;
      }

      setState(() => _statusMessage = 'Mengexport data...');

      final db = await DatabaseHelper.instance.database;
      final exportData = <String, dynamic>{
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'data': {},
      };

      // Export selected tables
      for (final entry in selectedTables.entries) {
        if (entry.value) {
          setState(() => _statusMessage = 'Mengexport ${entry.key}...');
          try {
            final data = await db.query(entry.key);
            exportData['data'][entry.key] = data;
          } catch (e) {
            debugPrint('Table ${entry.key} not found: $e');
          }
        }
      }

      // Save to JSON file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportPath =
          p.join(selectedDir, 'RoyalCharir_Export_$timestamp.json');
      final file = File(exportPath);
      await file.writeAsString(jsonEncode(exportData));

      // Calculate stats
      int totalRecords = 0;
      final dataMap = exportData['data'] as Map<String, dynamic>;
      for (final table in dataMap.values) {
        totalRecords += (table as List).length;
      }

      setState(() {
        _statusMessage = 'Export berhasil!';
        _isLoading = false;
      });

      _showSnackBar(
        'Berhasil export $totalRecords data ke:\n$exportPath',
        AppColors.success,
      );
      _loadBackupFiles();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal export: $e', AppColors.error);
    }
  }

  /// Export full database
  Future<void> _exportFullDatabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Memilih folder tujuan...';
    });

    try {
      final selectedDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Pilih folder tujuan (USB/Network)',
      );

      if (selectedDir == null) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Export dibatalkan';
        });
        return;
      }

      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('Database tidak ditemukan');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportPath = p.join(selectedDir, 'RoyalCharir_Full_$timestamp.db');

      await dbFile.copy(exportPath);

      setState(() {
        _statusMessage = 'Export berhasil!';
        _isLoading = false;
      });

      _showSnackBar(
        'Database berhasil diexport ke:\n$exportPath',
        AppColors.success,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal export: $e', AppColors.error);
    }
  }

  /// Create local backup
  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Membuat backup...';
    });

    try {
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('Database tidak ditemukan');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final backupDir =
          Directory(p.join(appDir.path, 'RoyalCharir', 'Backups'));

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = p.join(backupDir.path, 'backup_$timestamp.db');

      await dbFile.copy(backupPath);

      setState(() {
        _statusMessage = 'Backup berhasil dibuat!';
        _isLoading = false;
      });

      _showSnackBar('Backup berhasil: backup_$timestamp.db', AppColors.success);
      _loadBackupFiles();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal membuat backup: $e', AppColors.error);
    }
  }

  // ==================== IMPORT FUNCTIONS ====================

  /// Import and merge data
  Future<void> _importAndMerge(BuildContext context, bool isDark) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Memilih file...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih file export (.json)',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Import dibatalkan';
        });
        return;
      }

      setState(() => _statusMessage = 'Membaca file...');

      final sourcePath = result.files.first.path!;
      final sourceFile = File(sourcePath);
      final content = await sourceFile.readAsString();
      final importData = jsonDecode(content) as Map<String, dynamic>;

      // Analyze data for preview
      final dataMap = importData['data'] as Map<String, dynamic>? ?? {};
      final preview = await _analyzeImportData(dataMap);

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show preview dialog
      final confirm = await _showImportPreviewDialog(context, isDark, preview);

      if (confirm != true) {
        _showSnackBar('Import dibatalkan', AppColors.warning);
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = 'Mengimport data...';
      });

      // Perform merge import
      final stats = await _performMergeImport(dataMap);

      setState(() {
        _statusMessage = 'Import berhasil!';
        _isLoading = false;
      });

      _showSnackBar(
        'Berhasil import:\n'
        '• ${stats['inserted']} data baru ditambahkan\n'
        '• ${stats['skipped']} data sudah ada (dilewati)',
        AppColors.success,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal import: $e', AppColors.error);
    }
  }

  /// Analyze import data to show preview
  Future<Map<String, Map<String, int>>> _analyzeImportData(
      Map<String, dynamic> dataMap) async {
    final db = await DatabaseHelper.instance.database;
    final preview = <String, Map<String, int>>{};

    for (final entry in dataMap.entries) {
      final tableName = entry.key;
      final records = entry.value as List;

      int newCount = 0;
      int existingCount = 0;

      for (final record in records) {
        final id = record['id'] as String?;
        if (id != null) {
          try {
            final existing = await db.query(
              tableName,
              where: 'id = ?',
              whereArgs: [id],
            );
            if (existing.isEmpty) {
              newCount++;
            } else {
              existingCount++;
            }
          } catch (e) {
            // Table might not exist
            newCount++;
          }
        }
      }

      preview[tableName] = {
        'total': records.length,
        'new': newCount,
        'existing': existingCount,
      };
    }

    return preview;
  }

  /// Show import preview dialog
  Future<bool?> _showImportPreviewDialog(
    BuildContext context,
    bool isDark,
    Map<String, Map<String, int>> preview,
  ) async {
    final tableLabels = {
      'products': 'Produk',
      'customers': 'Pelanggan',
      'orders': 'Pesanan',
      'order_items': 'Item Pesanan',
      'materials': 'Bahan',
    };

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.preview_rounded, color: AppColors.info),
            const SizedBox(width: 12),
            const Text('Preview Import'),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data yang sudah ada akan dilewati, hanya data baru yang ditambahkan',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rincian data yang akan diimport:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...preview.entries.map((entry) {
                final tableName = entry.key;
                final stats = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          tableLabels[tableName] ?? tableName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${stats['new']}',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Baru',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${stats['existing']}',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Sudah Ada',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Import Sekarang'),
          ),
        ],
      ),
    );
  }

  /// Perform merge import
  Future<Map<String, int>> _performMergeImport(
      Map<String, dynamic> dataMap) async {
    final db = await DatabaseHelper.instance.database;
    int inserted = 0;
    int skipped = 0;

    for (final entry in dataMap.entries) {
      final tableName = entry.key;
      final records = entry.value as List;

      // Ensure table exists
      try {
        await db.query(tableName, limit: 1);
      } catch (e) {
        // Skip if table doesn't exist
        continue;
      }

      for (final record in records) {
        final id = record['id'] as String?;
        if (id != null) {
          try {
            final existing = await db.query(
              tableName,
              where: 'id = ?',
              whereArgs: [id],
            );
            if (existing.isEmpty) {
              await db.insert(tableName, Map<String, dynamic>.from(record));
              inserted++;
            } else {
              skipped++;
            }
          } catch (e) {
            debugPrint('Error inserting into $tableName: $e');
          }
        }
      }
    }

    return {'inserted': inserted, 'skipped': skipped};
  }

  /// Import and replace (full restore)
  Future<void> _importAndReplace() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Memilih file database...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih file database (.db)',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Import dibatalkan';
        });
        return;
      }

      final sourcePath = result.files.first.path!;
      final sourceFile = File(sourcePath);

      // Validate SQLite file
      final bytes = await sourceFile.readAsBytes();
      if (bytes.length < 16 ||
          String.fromCharCodes(bytes.sublist(0, 6)) != 'SQLite') {
        throw Exception('File bukan database SQLite yang valid');
      }

      setState(() => _isLoading = false);

      // Confirm before replacing
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.warning),
              const SizedBox(width: 12),
              const Text('Konfirmasi Restore'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Database saat ini akan diganti dengan file yang dipilih.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'PERHATIAN: Semua data saat ini akan HILANG!\nPastikan sudah membuat backup.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Ya, Ganti Database'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        _showSnackBar('Import dibatalkan', AppColors.warning);
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = 'Mengimport database...';
      });

      // Close current database
      await DatabaseHelper.instance.close();

      // Replace database
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      await sourceFile.copy(dbPath);

      // Reinitialize database
      await DatabaseHelper.instance.database;

      setState(() {
        _statusMessage = 'Import berhasil!';
        _isLoading = false;
      });

      _showSnackBar(
        'Database berhasil diimport!\nRestart aplikasi untuk melihat perubahan.',
        AppColors.success,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal import: $e', AppColors.error);
    }
  }

  /// Restore from local backup
  Future<void> _restoreFromBackup(String backupPath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Restore'),
        content: Text(
          'Database saat ini akan diganti dengan backup:\n'
          '${p.basename(backupPath)}\n\n'
          'Semua data saat ini akan hilang!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Ya, Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Melakukan restore...';
    });

    try {
      final backupFile = File(backupPath);

      // Close current database
      await DatabaseHelper.instance.close();

      // Replace database
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      await backupFile.copy(dbPath);

      // Reinitialize database
      await DatabaseHelper.instance.database;

      setState(() {
        _statusMessage = 'Restore berhasil!';
        _isLoading = false;
      });

      _showSnackBar(
        'Database berhasil direstore!\nRestart aplikasi untuk melihat perubahan.',
        AppColors.success,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
      _showSnackBar('Gagal restore: $e', AppColors.error);
    }
  }

  /// Delete local backup
  Future<void> _deleteBackup(String backupPath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Backup?'),
        content: Text('Hapus backup:\n${p.basename(backupPath)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await File(backupPath).delete();
        _loadBackupFiles();
        _showSnackBar('Backup berhasil dihapus', AppColors.success);
      } catch (e) {
        _showSnackBar('Gagal menghapus backup: $e', AppColors.error);
      }
    }
  }
}
