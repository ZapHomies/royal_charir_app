import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/material.dart';
import '../../providers/material_provider.dart';

/// Premium Material Management Page - Kelola Bahan
class MaterialManagementPage extends ConsumerStatefulWidget {
  const MaterialManagementPage({super.key});

  @override
  ConsumerState<MaterialManagementPage> createState() =>
      _MaterialManagementPageState();
}

class _MaterialManagementPageState
    extends ConsumerState<MaterialManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, low_stock

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final materialsAsync = ref.watch(materialsProvider);
    final statsAsync = ref.watch(materialStatsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Kelola Bahan'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(materialsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMaterialForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Bahan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Stats Cards
          statsAsync.when(
            data: (stats) => _buildStatsSection(isDark, stats),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari bahan...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterChip('Semua', 'all', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Stok Rendah', 'low_stock', isDark),
              ],
            ),
          ),

          // Materials List
          Expanded(
            child: materialsAsync.when(
              data: (materials) {
                var filtered = materials.where((m) {
                  final matchesSearch = m.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (m.description?.toLowerCase() ?? '')
                          .contains(_searchQuery.toLowerCase());
                  final matchesFilter = _selectedFilter == 'all' ||
                      (_selectedFilter == 'low_stock' && m.stock <= m.minStock);
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final material = filtered[index];
                    return _buildMaterialCard(material, isDark, index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(materialsProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark,
              'Total Bahan',
              '${stats['totalMaterials']}',
              Icons.inventory_2_rounded,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark,
              'Stok Rendah',
              '${stats['lowStockCount']}',
              Icons.warning_rounded,
              stats['lowStockCount'] > 0 ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark,
              'Total Nilai',
              _currencyFormat.format(stats['totalValue']),
              Icons.account_balance_wallet_rounded,
              AppColors.info,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatCard(
      bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Bahan',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan bahan untuk membuat produk',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildMaterialCard(ProductMaterial material, bool isDark, int index) {
    final isLowStock = material.stock <= material.minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock
              ? AppColors.error.withOpacity(0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isLowStock ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMaterialForm(context, material: material),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isLowStock
                        ? LinearGradient(
                            colors: [
                              AppColors.error.withOpacity(0.8),
                              AppColors.error
                            ],
                          )
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.layers_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              material.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 14, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Stok Rendah',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (material.description != null &&
                          material.description!.isNotEmpty)
                        Text(
                          material.description!,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.inventory_rounded,
                            '${material.stock.toStringAsFixed(material.stock.truncateToDouble() == material.stock ? 0 : 1)} ${material.unit}',
                            isLowStock ? AppColors.error : AppColors.success,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.attach_money_rounded,
                            _currencyFormat.format(material.pricePerUnit),
                            AppColors.info,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_rounded,
                          color: AppColors.success),
                      tooltip: 'Tambah Stok',
                      onPressed: () =>
                          _showStockAdjustment(context, material, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_rounded,
                          color: AppColors.warning),
                      tooltip: 'Kurangi Stok',
                      onPressed: () =>
                          _showStockAdjustment(context, material, false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildInfoChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialForm(BuildContext context, {ProductMaterial? material}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MaterialFormSheet(material: material),
    );
  }

  void _showStockAdjustment(
      BuildContext context, ProductMaterial material, bool isAdd) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdd ? 'Tambah Stok' : 'Kurangi Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              material.name,
              style: AppTextStyles.titleSmall
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Stok saat ini: ${material.stock.toStringAsFixed(material.stock.truncateToDouble() == material.stock ? 0 : 1)} ${material.unit}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Jumlah (${material.unit})',
                hintText: '0',
                prefixIcon: Icon(
                  isAdd ? Icons.add_rounded : Icons.remove_rounded,
                  color: isAdd ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final adjustment = isAdd ? amount : -amount;
                await ref
                    .read(materialsProvider.notifier)
                    .adjustStock(material.id, adjustment);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAdd
                            ? 'Stok berhasil ditambah'
                            : 'Stok berhasil dikurangi',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isAdd ? AppColors.success : AppColors.warning,
            ),
            child: Text(isAdd ? 'Tambah' : 'Kurangi'),
          ),
        ],
      ),
    );
  }
}

/// Material Form Bottom Sheet
class _MaterialFormSheet extends ConsumerStatefulWidget {
  final ProductMaterial? material;

  const _MaterialFormSheet({this.material});

  @override
  ConsumerState<_MaterialFormSheet> createState() => _MaterialFormSheetState();
}

class _MaterialFormSheetState extends ConsumerState<_MaterialFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _priceController;
  late final TextEditingController _supplierController;

  String _selectedUnit = 'pcs';
  bool _isLoading = false;

  final List<String> _units = [
    'pcs',
    'meter',
    'cm',
    'kg',
    'gram',
    'lembar',
    'roll',
    'batang',
    'liter',
    'ml',
  ];

  bool get isEditMode => widget.material != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.material?.description ?? '');
    _stockController =
        TextEditingController(text: widget.material?.stock.toString() ?? '0');
    _minStockController = TextEditingController(
        text: widget.material?.minStock.toString() ?? '10');
    _priceController = TextEditingController(
        text: widget.material?.pricePerUnit.toString() ?? '0');
    _supplierController =
        TextEditingController(text: widget.material?.supplier ?? '');
    _selectedUnit = widget.material?.unit ?? 'pcs';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.layers_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditMode ? 'Edit Bahan' : 'Tambah Bahan Baru',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Kelola bahan untuk produksi',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditMode)
                        IconButton(
                          icon: Icon(Icons.delete_rounded,
                              color: AppColors.error),
                          tooltip: 'Hapus',
                          onPressed: () => _deleteMaterial(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bahan *',
                      hintText: 'contoh: Kain Oxford, Silikon, Spon',
                      prefixIcon: Icon(Icons.label_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama bahan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Deskripsi opsional',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Unit, Stock, Min Stock Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Satuan',
                            prefixIcon: Icon(Icons.straighten_rounded),
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedUnit = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stok',
                            hintText: '0',
                            prefixIcon: Icon(Icons.inventory_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _minStockController,
                          decoration: const InputDecoration(
                            labelText: 'Min. Stok',
                            hintText: '10',
                            prefixIcon: Icon(Icons.warning_amber_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga per Satuan',
                      hintText: '0',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supplier Field
                  TextFormField(
                    controller: _supplierController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier (Opsional)',
                      hintText: 'Nama supplier',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _saveMaterial,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded),
                    label:
                        Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Bahan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final material = ProductMaterial(
        id: widget.material?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        unit: _selectedUnit,
        stock: double.tryParse(_stockController.text) ?? 0,
        minStock: double.tryParse(_minStockController.text) ?? 10,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0,
        supplier: _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        isActive: widget.material?.isActive ?? true,
        createdAt: widget.material?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode) {
        await ref.read(materialsProvider.notifier).updateMaterial(material);
      } else {
        await ref.read(materialsProvider.notifier).addMaterial(material);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Bahan berhasil diperbarui'
                  : 'Bahan berhasil ditambahkan',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMaterial() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bahan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${widget.material?.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.material != null) {
      await ref
          .read(materialsProvider.notifier)
          .deleteMaterial(widget.material!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
