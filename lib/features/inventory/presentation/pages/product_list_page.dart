import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../providers/product_provider.dart';
import '../../data/models/product_model.dart';
import 'product_form_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Premium Product List Page
class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final globalSearchQuery = ref.watch(globalSearchQueryProvider);

    return Column(
      children: [
        // Category Filter Section
        _buildCategoryFilter(categoriesAsync, selectedCategory, isDark),

        // Products List
        Expanded(
          child: productsAsync.when(
            data: (products) => _buildProductList(
              products,
              selectedCategory,
              globalSearchQuery,
              isDark,
            ),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(
    AsyncValue<List<String>> categoriesAsync,
    String? selectedCategory,
    bool isDark,
  ) {
    final viewMode = ref.watch(productViewModeProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Categories
                Expanded(
                  child: categoriesAsync.when(
                    data: (categories) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(
                              'All', null, selectedCategory, isDark),
                          ...categories.map((category) => _buildCategoryChip(
                                category,
                                category,
                                selectedCategory,
                                isDark,
                              )),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 32,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                // View Mode Toggle
                ViewModeToggle(
                  currentMode: viewMode,
                  onModeChanged: (mode) {
                    ref.read(productViewModeProvider.notifier).state = mode;
                  },
                  availableModes: const [ViewMode.grid, ViewMode.list],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryChip(
    String label,
    String? value,
    String? selectedValue,
    bool isDark,
  ) {
    final isSelected = value == selectedValue;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(selectedCategoryProvider.notifier).state =
                isSelected ? null : value;
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05)),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(
    List<ProductModel> products,
    String? selectedCategory,
    String globalSearchQuery,
    bool isDark,
  ) {
    final viewMode = ref.watch(productViewModeProvider);

    // Filter by search query
    final filteredProducts = globalSearchQuery.isEmpty
        ? products
        : products.where((p) {
            final query = globalSearchQuery.toLowerCase();
            return p.name.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false);
          }).toList();

    // Filter by category
    final displayProducts = selectedCategory == null
        ? filteredProducts
        : filteredProducts
            .where((p) => p.category == selectedCategory)
            .toList();

    if (displayProducts.isEmpty) {
      return _buildEmptyState(globalSearchQuery, isDark);
    }

    // Show grid view
    if (viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return _buildProductGridCard(product, index, isDark);
        },
      );
    }

    // Show list view (default)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return _buildProductCard(product, index, isDark);
      },
    );
  }

  Widget _buildProductGridCard(ProductModel product, int index, bool isDark) {
    final stockColor = product.isOutOfStock
        ? AppColors.error
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      animationDelay: Duration(milliseconds: index * 30),
      onTap: () => _navigateToProductForm(context, product: product),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image/Icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.accent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                product.name,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Price & Stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      PriceFormatter.formatCompact(product.price),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.stock}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Menu button at top right
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text('Edit', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _navigateToProductForm(context, product: product),
                  ),
                ),
                PopupMenuItem(
                  height: 40,
                  child: Row(
                    children: [
                      const Icon(Icons.delete_rounded,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _deleteProduct(product),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, int index, bool isDark) {
    final stockColor = product.isOutOfStock
        ? AppColors.error
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      animationDelay: Duration(milliseconds: index * 50),
      onTap: () => _navigateToProductForm(context, product: product),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      product.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inventory_2_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),

          const SizedBox(width: 16),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: stockColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.isOutOfStock
                                ? Icons.warning_rounded
                                : Icons.inventory_rounded,
                            size: 12,
                            color: stockColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: stockColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.format(product.price),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              PopupMenuButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      Duration.zero,
                      () => _navigateToProductForm(context, product: product),
                    ),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.delete_rounded,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      Duration.zero,
                      () => _deleteProduct(product),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isEmpty
                  ? Icons.inventory_2_outlined
                  : Icons.search_off_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty ? 'No products yet' : 'No results found',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Tambahkan produk pertama Anda untuk memulai'
                : 'Try a different search term',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            GradientButton(
              text: 'Tambah Produk',
              icon: Icons.add_rounded,
              onPressed: () => _navigateToProductForm(context),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Terjadi kesalahan',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Coba Lagi',
            icon: Icons.refresh_rounded,
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToProductForm(BuildContext context,
      {ProductModel? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Delete Product'),
          ],
        ),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(productsProvider.notifier).deleteProduct(product.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}
