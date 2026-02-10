import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';

/// Premium Product Form Page - Add or Edit product with modern UI
class ProductFormPage extends ConsumerStatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _wholesalePriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _unitController;
  late final TextEditingController _newCategoryController;

  String? _selectedCategory;
  bool _isLoading = false;
  bool _showNewCategoryField = false;

  bool get isEditMode => widget.product != null;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _selectedCategory = widget.product?.category;
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _wholesalePriceController = TextEditingController(
      text: widget.product?.wholesalePrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '0',
    );
    _minStockController = TextEditingController(
      text: widget.product?.minStock.toString() ?? '10',
    );
    _unitController = TextEditingController(
      text: widget.product?.unit ?? 'pcs',
    );
    _newCategoryController = TextEditingController();

    if (widget.product?.imagePath != null) {
      _selectedImage = File(widget.product!.imagePath!);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _wholesalePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(productCategoriesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk Baru'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: AppColors.error),
              tooltip: 'Hapus Produk',
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              _buildImageSection(isDark).animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 24),

              // Basic Info Section
              _buildSectionCard(
                isDark,
                'Informasi Dasar',
                Icons.info_rounded,
                AppColors.primary,
                [
                  // Product Name
                  _buildPremiumTextField(
                    controller: _nameController,
                    label: 'Nama Produk',
                    hint: 'contoh: Bantal Silikon Premium',
                    icon: Icons.inventory_2_rounded,
                    isRequired: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  categoriesAsync.when(
                    data: (categories) =>
                        _buildCategoryDropdown(categories, isDark),
                    loading: () => _buildLoadingField(isDark),
                    error: (_, __) => _buildCategoryDropdown([], isDark),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildPremiumTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    hint: 'Deskripsi produk (opsional)',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    isDark: isDark,
                  ),
                ],
              ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1),
              const SizedBox(height: 16),

              // Pricing Section
              _buildSectionCard(
                isDark,
                'Harga',
                Icons.payments_rounded,
                AppColors.success,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPremiumTextField(
                          controller: _priceController,
                          label: 'Harga Jual',
                          hint: '0',
                          icon: Icons.sell_rounded,
                          prefixText: 'Rp ',
                          isRequired: true,
                          isNumeric: true,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPremiumTextField(
                          controller: _wholesalePriceController,
                          label: 'Harga Grosir',
                          hint: '0',
                          icon: Icons.local_offer_rounded,
                          prefixText: 'Rp ',
                          isNumeric: true,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 16),

              // Stock Section
              _buildSectionCard(
                isDark,
                'Stok & Satuan',
                Icons.inventory_rounded,
                AppColors.info,
                [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPremiumTextField(
                          controller: _stockController,
                          label: 'Stok',
                          hint: '0',
                          icon: Icons.storage_rounded,
                          isRequired: true,
                          isInteger: true,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildPremiumTextField(
                          controller: _minStockController,
                          label: 'Min. Stok',
                          hint: '10',
                          icon: Icons.warning_amber_rounded,
                          isInteger: true,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildUnitDropdown(isDark),
                      ),
                    ],
                  ),
                ],
              ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(isDark)
                  .animate(delay: 400.ms)
                  .fadeIn()
                  .scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 16),

              if (isEditMode)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Batal'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Preview
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
                image: _selectedImage != null && _selectedImage!.existsSync()
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null || !_selectedImage!.existsSync()
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambah Foto',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),

          // Image Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto Produk',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap untuk menambah atau mengubah foto produk',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_selectedImage != null)
                      TextButton.icon(
                        onPressed: () => setState(() => _selectedImage = null),
                        icon: Icon(Icons.delete_rounded,
                            size: 18, color: AppColors.error),
                        label: Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: Text(
                          _selectedImage != null ? 'Ganti' : 'Pilih Gambar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    bool isDark,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? prefixText,
    bool isRequired = false,
    bool isNumeric = false,
    bool isInteger = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      maxLines: maxLines,
      keyboardType:
          isNumeric || isInteger ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (isInteger) FilteringTextInputFormatter.digitsOnly,
        if (isNumeric && !isInteger)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      textCapitalization: isNumeric || isInteger
          ? TextCapitalization.none
          : TextCapitalization.words,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label wajib diisi';
              }
              if (isNumeric || isInteger) {
                final num = double.tryParse(value);
                if (num == null || num < 0) {
                  return 'Masukkan angka yang valid';
                }
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildCategoryDropdown(List<String> categories, bool isDark) {
    // Combine existing categories
    final allCategories = <String>{...categories};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: allCategories.contains(_selectedCategory)
                ? _selectedCategory
                : null,
            decoration: InputDecoration(
              labelText: 'Kategori *',
              prefixIcon: const Icon(Icons.category_rounded),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const Text('Pilih kategori'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            borderRadius: BorderRadius.circular(12),
            items: [
              ...allCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }),
              const DropdownMenuItem(
                value: '_new_',
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Tambah Kategori Baru'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value == '_new_') {
                setState(() {
                  _showNewCategoryField = true;
                  _selectedCategory = null;
                });
              } else {
                setState(() {
                  _showNewCategoryField = false;
                  _selectedCategory = value;
                });
              }
            },
            validator: (value) {
              if ((value == null || value.isEmpty) &&
                  _newCategoryController.text.isEmpty) {
                return 'Kategori wajib dipilih';
              }
              return null;
            },
          ),
        ),

        // New Category Input Field
        if (_showNewCategoryField) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newCategoryController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori Baru',
                    hintText: 'Masukkan nama kategori',
                    prefixIcon: const Icon(Icons.add_circle_rounded),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _selectedCategory = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.error),
                onPressed: () {
                  setState(() {
                    _showNewCategoryField = false;
                    _newCategoryController.clear();
                  });
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUnitDropdown(bool isDark) {
    final units = ['pcs', 'set', 'unit', 'lusin', 'box', 'pack'];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value:
            units.contains(_unitController.text) ? _unitController.text : null,
        decoration: const InputDecoration(
          labelText: 'Satuan',
          prefixIcon: Icon(Icons.straighten_rounded),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: const Text('pcs'),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down_rounded),
        borderRadius: BorderRadius.circular(12),
        items: units.map((unit) {
          return DropdownMenuItem(
            value: unit,
            child: Text(unit),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _unitController.text = value;
          }
        },
      ),
    );
  }

  Widget _buildLoadingField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Memuat kategori...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveProduct,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  isEditMode ? 'Simpan Perubahan' : 'Tambah Produk',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Check category
    final category = _showNewCategoryField
        ? _newCategoryController.text.trim()
        : _selectedCategory;

    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan pilih atau buat kategori'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save image to app directory if selected
      String? imagePath = widget.product?.imagePath;
      if (_selectedImage != null &&
          _selectedImage!.path != widget.product?.imagePath) {
        imagePath = _selectedImage!.path;
      }

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        category: category,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        wholesalePrice: _wholesalePriceController.text.isNotEmpty
            ? double.parse(_wholesalePriceController.text)
            : null,
        stock: int.parse(_stockController.text),
        minStock: int.tryParse(_minStockController.text) ?? 10,
        unit: _unitController.text.trim().isEmpty
            ? 'pcs'
            : _unitController.text.trim(),
        imagePath: imagePath,
        isActive: widget.product?.isActive ?? true,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode) {
        await ref.read(productsProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productsProvider.notifier).addProduct(product);
      }

      // Refresh categories
      ref.invalidate(productCategoriesProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Produk berhasil diperbarui'
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
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

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${widget.product?.name}"?',
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

    if (confirm == true && widget.product != null) {
      await ref
          .read(productsProvider.notifier)
          .deleteProduct(widget.product!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
