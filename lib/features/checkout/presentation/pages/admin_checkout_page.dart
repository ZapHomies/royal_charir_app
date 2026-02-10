import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/services/dot_matrix_print_service.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../../../inventory/providers/product_provider.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../orders/data/models/order_model.dart';

/// Premium Admin Checkout Page with Database Integration
class AdminCheckoutPage extends ConsumerStatefulWidget {
  const AdminCheckoutPage({super.key});

  @override
  ConsumerState<AdminCheckoutPage> createState() => _AdminCheckoutPageState();
}

class _AdminCheckoutPageState extends ConsumerState<AdminCheckoutPage> {
  CustomerModel? selectedCustomer;
  final List<CartItem> cart = [];
  double discount = 0;
  String paymentStatus = 'Belum Bayar';
  double paidAmount = 0;
  bool isProcessing = false;

  // Retail mode: true = retail (form), false = wholesale (dropdown)
  bool isRetailMode = true;

  // Customer special prices: productId -> special price
  Map<String, double> _customerSpecialPrices = {};

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _retailNameController = TextEditingController();
  final TextEditingController _retailPhoneController = TextEditingController();
  String _productSearch = '';

  @override
  void initState() {
    super.initState();
    // Add listener to rebuild when retail customer name changes
    _retailNameController.addListener(() {
      if (isRetailMode) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    _paidController.dispose();
    _searchController.dispose();
    _notesController.dispose();
    _driverNameController.dispose();
    _retailNameController.dispose();
    _retailPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);
    final productsAsync = ref.watch(productsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    return Row(
      children: [
        // Left: Product Selection
        Expanded(
          flex: isWideScreen ? 2 : 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Selection (compact)
                _buildCustomerSelector(customersAsync, isDark),
                const SizedBox(height: 8),
                // Product Search
                _buildProductSearch(),
                const SizedBox(height: 8),
                // Products Grid - use list view for speed
                Expanded(
                  child: _buildProductList(productsAsync, isDark),
                ),
              ],
            ),
          ),
        ),
        // Right: Cart & Checkout (narrower)
        _buildCartSection(isDark, isWideScreen),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return const SizedBox.shrink(); // Removed header for compact layout
  }

  Widget _buildCustomerSelector(
      AsyncValue<List<CustomerModel>> customersAsync, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          // Mode Toggle - compact
          _buildModeToggle(isDark),
          const SizedBox(width: 10),
          // Customer Input
          Expanded(
            child: isRetailMode
                ? _buildRetailInput(isDark)
                : _buildWholesaleDropdown(customersAsync, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRetailInput(bool isDark) {
    return TextField(
      controller: _retailNameController,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Nama Pelanggan',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
      ),
    );
  }

  Widget _buildWholesaleDropdown(
      AsyncValue<List<CustomerModel>> customersAsync, bool isDark) {
    return customersAsync.when(
      data: (customers) => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: 'Pilih pelanggan grosir',
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
        value: selectedCustomer?.id,
        isExpanded: true,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : Colors.black87,
        ),
        items: customers.map((customer) {
          return DropdownMenuItem(
            value: customer.id,
            child: Text(customer.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) async {
          final customer = customers.firstWhere((c) => c.id == value);
          setState(() {
            selectedCustomer = customer;
            cart.clear();
          });
          await _loadCustomerPrices(customer.id);
        },
      ),
      loading: () => const SizedBox(
          height: 36,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildModeToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Retail button
          _buildToggleButton(
            label: 'Eceran',
            icon: Icons.person_rounded,
            isSelected: isRetailMode,
            color: AppColors.info,
            onTap: () {
              if (!isRetailMode) {
                setState(() {
                  isRetailMode = true;
                  selectedCustomer = null;
                  cart.clear();
                });
              }
            },
          ),
          const SizedBox(width: 4),
          // Wholesale button
          _buildToggleButton(
            label: 'Grosir',
            icon: Icons.store_rounded,
            isSelected: !isRetailMode,
            color: AppColors.accent,
            onTap: () {
              if (isRetailMode) {
                setState(() {
                  isRetailMode = false;
                  _retailNameController.clear();
                  _retailPhoneController.clear();
                  cart.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetailCustomerForm(bool isDark) {
    return Column(
      children: [
        // Customer Name (Required)
        TextField(
          controller: _retailNameController,
          decoration: InputDecoration(
            labelText: 'Nama Pelanggan *',
            hintText: 'Masukkan nama pelanggan',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        const SizedBox(height: 10),
        // Phone (Optional)
        TextField(
          controller: _retailPhoneController,
          decoration: InputDecoration(
            labelText: 'Telepon (Opsional)',
            hintText: 'Masukkan nomor telepon',
            prefixIcon: const Icon(Icons.phone_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        // Retail price indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sell_rounded, size: 14, color: AppColors.info),
              const SizedBox(width: 6),
              Text(
                'Menggunakan Harga Eceran',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWholesaleCustomerDropdown(
      AsyncValue<List<CustomerModel>> customersAsync, bool isDark) {
    return customersAsync.when(
      data: (customers) => Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Pilih pelanggan grosir',
              prefixIcon: const Icon(Icons.store_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            value: selectedCustomer?.id,
            isExpanded: true,
            items: customers.map((customer) {
              return DropdownMenuItem(
                value: customer.id,
                child: Text(
                  customer.name,
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) async {
              final customer = customers.firstWhere((c) => c.id == value);
              setState(() {
                selectedCustomer = customer;
                // Reset cart when customer changes
                cart.clear();
              });
              // Load customer's special prices
              await _loadCustomerPrices(customer.id);
            },
          ),
          if (selectedCustomer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sell_rounded, size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Menggunakan Harga Grosir',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildProductSearch() {
    final viewMode = ref.watch(checkoutViewModeProvider);

    return Row(
      children: [
        Expanded(
          child: PremiumSearchBar(
            controller: _searchController,
            hintText: 'Cari produk...',
            onChanged: (value) {
              setState(() => _productSearch = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        ViewModeToggle(
          currentMode: viewMode,
          onModeChanged: (mode) {
            ref.read(checkoutViewModeProvider.notifier).state = mode;
          },
          availableModes: const [ViewMode.grid, ViewMode.list],
        ),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }

  /// Compact product list for fast checkout
  Widget _buildProductList(
      AsyncValue<List<ProductModel>> productsAsync, bool isDark) {
    return productsAsync.when(
      data: (products) {
        final filtered = _productSearch.isEmpty
            ? products
            : products
                .where((p) =>
                    p.name
                        .toLowerCase()
                        .contains(_productSearch.toLowerCase()) ||
                    p.category
                        .toLowerCase()
                        .contains(_productSearch.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            final cartItem =
                cart.where((item) => item.productId == product.id).firstOrNull;
            final isInCart = cartItem != null;
            final cartQty = cartItem?.quantity ?? 0;
            final price = _getProductPrice(product);
            final isOutOfStock = product.stock <= 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: isInCart ? 0.8 : 0.5)
                    : Colors.white.withValues(alpha: isInCart ? 1 : 0.8),
                borderRadius: BorderRadius.circular(8),
                border: isInCart
                    ? Border.all(
                        color: AppColors.success.withValues(alpha: 0.5),
                        width: 1.5)
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                      ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isOutOfStock
                      ? null
                      : (isRetailMode || selectedCustomer != null)
                          ? () => _addToCart(product)
                          : () => _showSelectCustomerMessage(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        // Product name
                        Expanded(
                          flex: 3,
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : isDark
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Stock
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppColors.error.withValues(alpha: 0.1)
                                : product.isLowStock
                                    ? AppColors.warning.withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock
                                  ? AppColors.error
                                  : product.isLowStock
                                      ? AppColors.warning
                                      : isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Price
                        SizedBox(
                          width: 70,
                          child: Text(
                            PriceFormatter.formatCompact(price),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        // Cart indicator
                        if (isInCart) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'x$cartQty',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildProductGrid(AsyncValue<List<ProductModel>> productsAsync,
      bool isDark, bool isWideScreen) {
    final viewMode = ref.watch(checkoutViewModeProvider);

    return productsAsync.when(
      data: (products) {
        final filtered = _productSearch.isEmpty
            ? products
            : products
                .where((p) =>
                    p.name
                        .toLowerCase()
                        .contains(_productSearch.toLowerCase()) ||
                    p.category
                        .toLowerCase()
                        .contains(_productSearch.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Produk tidak ditemukan',
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

        // List view
        if (viewMode == ViewMode.list) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return _buildProductListCard(product, index, isDark);
            },
          );
        }

        // Grid view (default)
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWideScreen ? 0.9 : 0.8,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            return _buildProductCard(product, index, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildProductListCard(ProductModel product, int index, bool isDark) {
    final cartItem =
        cart.where((item) => item.productId == product.id).firstOrNull;
    final isInCart = cartItem != null;
    final cartQty = cartItem?.quantity ?? 0;

    // Get price based on mode and customer special prices
    final price = _getProductPrice(product);

    final stockColor = product.isOutOfStock
        ? AppColors.error
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInCart
              ? AppColors.success.withValues(alpha: 0.5)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05)),
          width: isInCart ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: product.stock > 0 && selectedCustomer != null
              ? () => _addToCart(product)
              : (selectedCustomer == null
                  ? () => _showSelectCustomerMessage()
                  : null),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.accent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stock
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.stock}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: stockColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Price
                Text(
                  PriceFormatter.formatCompact(price),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Cart quantity badge
                if (isInCart) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'x$cartQty',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 20))
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildProductCard(ProductModel product, int index, bool isDark) {
    final cartItem =
        cart.where((item) => item.productId == product.id).firstOrNull;
    final isInCart = cartItem != null;
    final cartQty = cartItem?.quantity ?? 0;

    // Get price based on mode and customer special prices
    final price = _getProductPrice(product);

    return GlassCard(
      padding: EdgeInsets.zero,
      animationDelay: Duration(milliseconds: index * 30),
      onTap: product.stock > 0 && _canAddToCart()
          ? () => _addToCart(product)
          : (!_canAddToCart() ? () => _showSelectCustomerMessage() : null),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(12),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          PriceFormatter.format(price),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.stock > 0 ? '${product.stock}' : 'Out',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: product.stock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Cart indicator
          if (isInCart)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_rounded,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$cartQty',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Out of stock overlay
          if (product.stock <= 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'OUT OF STOCK',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartSection(bool isDark, bool isWideScreen) {
    return Container(
      width: isWideScreen ? 320 : 280,
      margin: const EdgeInsets.fromLTRB(6, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Cart Header - Compact
          _buildCartHeader(),
          // Selected Customer - Compact
          if (selectedCustomer != null) _buildSelectedCustomer(),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  // Cart Items List
                  _buildCartItemsList(isDark),
                  // Payment Section
                  _buildPaymentSection(isDark),
                ],
              ),
            ),
          ),
          // Total & Checkout Button - Fixed Footer
          _buildCheckoutSection(isDark),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Keranjang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${cart.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCustomer!.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedCustomer!.isWholesale ? 'Grosir' : 'Eceran',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () {
              setState(() {
                selectedCustomer = null;
                cart.clear();
              });
            },
            color: AppColors.success,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(bool isDark) {
    if (cart.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              'Keranjang kosong',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedCustomer == null
                  ? 'Select a customer first'
                  : 'Click products to add',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Items count header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${cart.length} item${cart.length > 1 ? 's' : ''} in cart',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => cart.clear());
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cart items
        ...cart.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildCartItem(item, index, isDark);
        }),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      PriceFormatter.formatCompact(item.unitPrice),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      ' × ${item.quantity} = ',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                    Text(
                      PriceFormatter.formatCompact(item.subtotal),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Quantity controls - Compact
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _decreaseQty(index),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _increaseQty(index),
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Delete button
          InkWell(
            onTap: () => _removeItem(index),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Discount
          TextField(
            controller: _discountController,
            decoration: InputDecoration(
              labelText: 'Discount (Rp)',
              prefixIcon: const Icon(Icons.discount_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                discount = double.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: 12),
          // Payment Status
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Payment Status',
              prefixIcon: const Icon(Icons.payment_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            value: paymentStatus,
            items: const [
              DropdownMenuItem(value: 'Lunas', child: Text('Paid (Lunas)')),
              DropdownMenuItem(
                  value: 'Belum Bayar', child: Text('Unpaid (Belum Bayar)')),
              DropdownMenuItem(value: 'Sebagian', child: Text('Partial (DP)')),
            ],
            onChanged: (value) {
              setState(() {
                paymentStatus = value ?? 'Belum Bayar';
                if (paymentStatus == 'Lunas') {
                  paidAmount = _calculateTotal();
                  _paidController.text = paidAmount.toStringAsFixed(0);
                } else if (paymentStatus == 'Belum Bayar') {
                  paidAmount = 0;
                  _paidController.text = '';
                }
              });
            },
          ),
          // Paid Amount (for partial)
          if (paymentStatus == 'Sebagian') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _paidController,
              decoration: InputDecoration(
                labelText: 'Paid Amount (Rp)',
                prefixIcon: const Icon(Icons.money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  paidAmount = double.tryParse(value) ?? 0;
                });
              },
            ),
          ],
          const SizedBox(height: 12),
          // Notes/Remarks
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes / Keterangan (Opsional)',
              prefixIcon: const Icon(Icons.note_alt_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          // Driver Name
          TextField(
            controller: _driverNameController,
            decoration: InputDecoration(
              labelText: 'Nama Supir (Opsional)',
              hintText: 'Untuk surat jalan',
              prefixIcon: const Icon(Icons.local_shipping_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(bool isDark) {
    final subtotal = _calculateSubtotal();
    final total = _calculateTotal();
    final remaining = total - (paymentStatus == 'Lunas' ? total : paidAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal
          _buildTotalRow('Subtotal', subtotal, isDark),
          if (discount > 0)
            _buildTotalRow('Diskon', -discount, isDark, color: AppColors.error),
          const SizedBox(height: 8),
          Container(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 8),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                PriceFormatter.format(total),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (paymentStatus != 'Lunas' && remaining > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sisa', style: AppTextStyles.bodySmall),
                Text(
                  PriceFormatter.format(remaining),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: isProcessing ? 'Processing...' : 'Process Checkout',
              icon: Icons.check_circle_rounded,
              gradient: AppColors.successGradient,
              // Fixed: For retail mode, check customer name instead of selectedCustomer
              isDisabled: cart.isEmpty ||
                  isProcessing ||
                  (isRetailMode
                      ? _retailNameController.text.trim().isEmpty
                      : selectedCustomer == null),
              isLoading: isProcessing,
              onPressed: _processCheckout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          amount < 0
              ? '- ${PriceFormatter.format(-amount)}'
              : PriceFormatter.format(amount),
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ??
                (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }

  // Cart operations

  /// Check if user can add to cart based on mode
  bool _canAddToCart() {
    if (isRetailMode) {
      // In retail mode, just need a name entered (but allow adding first, validate on checkout)
      return true;
    } else {
      // In wholesale mode, need selected customer
      return selectedCustomer != null;
    }
  }

  /// Load customer special prices from database
  Future<void> _loadCustomerPrices(String customerId) async {
    try {
      final repository = CustomerRepository();
      final prices = await repository.getWholesalePrices(customerId);

      setState(() {
        _customerSpecialPrices = {for (final p in prices) p.productId: p.price};
      });
    } catch (e) {
      // If error, just use default wholesale prices
      setState(() {
        _customerSpecialPrices = {};
      });
    }
  }

  /// Get product price based on mode and customer special prices
  double _getProductPrice(ProductModel product) {
    if (isRetailMode) {
      return product.price;
    } else {
      // Wholesale mode: check for customer-specific price first
      if (_customerSpecialPrices.containsKey(product.id)) {
        return _customerSpecialPrices[product.id]!;
      }
      // Fallback to global wholesale price
      return product.wholesalePrice;
    }
  }

  void _addToCart(ProductModel product) {
    // Use smart pricing based on mode and customer
    final price = _getProductPrice(product);

    final existingIndex =
        cart.indexWhere((item) => item.productId == product.id);
    if (existingIndex >= 0) {
      setState(() {
        cart[existingIndex] = cart[existingIndex].copyWith(
          quantity: cart[existingIndex].quantity + 1,
        );
      });
    } else {
      setState(() {
        cart.add(CartItem(
          productId: product.id,
          productName: product.name,
          unitPrice: price,
          quantity: 1,
        ));
      });
    }
  }

  void _increaseQty(int index) {
    setState(() {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    });
  }

  void _decreaseQty(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index] = cart[index].copyWith(quantity: cart[index].quantity - 1);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return cart.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double _calculateTotal() {
    return (_calculateSubtotal() - discount).clamp(0, double.infinity);
  }

  void _showSelectCustomerMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Silakan pilih pelanggan terlebih dahulu'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _processCheckout() async {
    // Validate based on mode
    if (isRetailMode) {
      // Retail mode: need customer name
      if (_retailNameController.text.trim().isEmpty || cart.isEmpty) {
        if (_retailNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan masukkan nama pelanggan'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    } else {
      // Wholesale mode: need selected customer
      if (selectedCustomer == null || cart.isEmpty) return;
    }

    setState(() => isProcessing = true);

    try {
      final uuid = const Uuid();
      final orderId = uuid.v4();
      final now = DateTime.now();
      final total = _calculateTotal();
      final paid = paymentStatus == 'Lunas' ? total : paidAmount;

      // Generate order number
      final orderNumber =
          'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

      // Combine notes with driver name if provided
      String? orderNotes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      if (_driverNameController.text.trim().isNotEmpty) {
        final driverInfo = 'Supir: ${_driverNameController.text.trim()}';
        orderNotes =
            orderNotes != null ? '$orderNotes\n$driverInfo' : driverInfo;
      }

      // Customer data based on mode
      final String customerId;
      final String customerName;
      final String orderType;

      if (isRetailMode) {
        // Retail mode: create a temporary retail customer in database
        customerId = uuid.v4();
        customerName = _retailNameController.text.trim();
        orderType = 'Eceran';

        // Create retail customer in database to satisfy foreign key constraint
        final retailCustomer = CustomerModel(
          id: customerId,
          name: customerName,
          phone: _retailPhoneController.text.trim().isEmpty
              ? null
              : _retailPhoneController.text.trim(),
          customerType: 'retail',
          createdAt: now,
          updatedAt: now,
        );
        await CustomerRepository().createCustomer(retailCustomer);
      } else {
        // Wholesale mode: use selected customer
        customerId = selectedCustomer!.id;
        customerName = selectedCustomer!.name;
        orderType = 'Grosir';
      }

      // Create order
      final order = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        customerId: customerId,
        customerName: customerName,
        orderType: orderType,
        orderDate: now,
        totalAmount: _calculateSubtotal(),
        discount: discount,
        finalAmount: total,
        paymentStatus: paymentStatus,
        paidAmount: paid,
        remainingAmount: total - paid,
        notes: orderNotes,
        createdAt: now,
        updatedAt: now,
      );

      // Create order items
      final orderItems = cart
          .map((item) => OrderItemModel(
                id: uuid.v4(),
                orderId: orderId,
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                subtotal: item.subtotal,
              ))
          .toList();

      // Save to database via provider
      await ref.read(ordersProvider.notifier).createOrder(order, orderItems);

      // Update product stock (decrease)
      for (final item in cart) {
        await ref.read(productsProvider.notifier).adjustStock(
              item.productId,
              -item.quantity, // Decrease stock
            );
      }

      // Refresh data
      ref.invalidate(ordersProvider);
      ref.invalidate(productsProvider);

      if (mounted) {
        // Pass order with items for printing
        final orderWithItems = order.copyWith(items: orderItems);
        _showSuccessDialog(orderWithItems);
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
        setState(() => isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(child: Text('Order Created!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetailRow('Order No', order.orderNumber),
            _buildOrderDetailRow('Pelanggan', order.customerName),
            _buildOrderDetailRow(
                'Type', order.isWholesale ? 'Grosir' : 'Eceran'),
            _buildOrderDetailRow(
                'Total', PriceFormatter.format(order.finalAmount)),
            _buildOrderDetailRow('Status', order.paymentStatus.toUpperCase()),
            if (order.remainingAmount > 0)
              _buildOrderDetailRow(
                  'Sisa', PriceFormatter.format(order.remainingAmount)),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Print Documents',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Print options
            Row(
              children: [
                Expanded(
                  child: _PrintOptionButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Invoice',
                    color: AppColors.info,
                    onTap: () => _printInvoice(order),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PrintOptionButton(
                    icon: Icons.local_shipping_rounded,
                    label: 'Surat Jalan',
                    color: AppColors.accent,
                    onTap: () => _printDeliveryNote(order),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCheckout();
            },
            child: const Text('Skip'),
          ),
          GradientButton(
            text: 'Done',
            onPressed: () {
              Navigator.pop(context);
              _resetCheckout();
            },
          ),
        ],
      ),
    );
  }

  void _resetCheckout() {
    setState(() {
      cart.clear();
      discount = 0;
      paidAmount = 0;
      paymentStatus = 'Belum Bayar';
      _discountController.clear();
      _paidController.clear();
      _notesController.clear();
      _driverNameController.clear();
      selectedCustomer = null;
    });
  }

  Future<void> _printInvoice(OrderModel order) async {
    // Close the dialog
    Navigator.pop(context);

    try {
      // Create customer from order data for printing
      final customer = CustomerModel(
        id: order.customerId,
        name: order.customerName,
        customerType: order.orderType == 'Eceran' ? 'retail' : 'wholesale',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await DotMatrixPrintService.printInvoice(order, customer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error print nota: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    _resetCheckout();
  }

  Future<void> _printDeliveryNote(OrderModel order) async {
    // Close the dialog
    Navigator.pop(context);

    try {
      // Create customer from order data for printing
      final customer = CustomerModel(
        id: order.customerId,
        name: order.customerName,
        customerType: order.orderType == 'Eceran' ? 'retail' : 'wholesale',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await DotMatrixPrintService.printDeliveryOrder(order, customer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error print surat jalan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    _resetCheckout();
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondaryLight)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Print Option Button Widget
class _PrintOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PrintOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cart Item Model
class CartItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
