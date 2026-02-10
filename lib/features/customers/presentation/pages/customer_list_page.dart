import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../providers/customer_provider.dart';
import 'customer_form_page.dart';
import 'customer_detail_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../orders/presentation/pages/order_form_page.dart';

/// Premium Customer List Page
class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);
    final selectedType = ref.watch(selectedCustomerTypeProvider);
    final globalSearchQuery = ref.watch(globalSearchQueryProvider);

    return Column(
      children: [
        // Filter Section
        _buildTypeFilter(selectedType, isDark),

        // Customer List
        Expanded(
          child: customersAsync.when(
            data: (customers) => _buildCustomerList(
              customers,
              selectedType,
              globalSearchQuery,
              isDark,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter(String? selectedType, bool isDark) {
    final viewMode = ref.watch(customerViewModeProvider);

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
                // Wholesale customers label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.store_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Pelanggan Grosir',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ViewModeToggle(
                  currentMode: viewMode,
                  onModeChanged: (mode) {
                    ref.read(customerViewModeProvider.notifier).state = mode;
                  },
                  availableModes: const [ViewMode.list, ViewMode.grid],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCustomerList(
    List<CustomerModel> customers,
    String? selectedType,
    String globalSearchQuery,
    bool isDark,
  ) {
    final viewMode = ref.watch(customerViewModeProvider);

    final filtered = customers.where((c) {
      final matchSearch = globalSearchQuery.isEmpty ||
          c.name.toLowerCase().contains(globalSearchQuery.toLowerCase()) ||
          (c.phone?.toLowerCase().contains(globalSearchQuery.toLowerCase()) ??
              false);
      final matchType = selectedType == null || c.customerType == selectedType;
      return matchSearch && matchType;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(globalSearchQuery, isDark);
    }

    // Grid view
    if (viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final customer = filtered[index];
          return _buildCustomerGridCard(customer, index, isDark);
        },
      );
    }

    // List view (default)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final customer = filtered[index];
        return _buildCustomerCard(customer, index, isDark);
      },
    );
  }

  Widget _buildCustomerGridCard(
      CustomerModel customer, int index, bool isDark) {
    final isWholesale = customer.isWholesale;
    final hasDebt = customer.hasDebt;
    final typeColor = isWholesale ? AppColors.accent : AppColors.info;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      animationDelay: Duration(milliseconds: index * 30),
      onTap: () => _navigateToDetail(customer),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                customer.name,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Phone
              if (customer.phone != null && customer.phone!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        customer.phone!,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              // Bottom row - Type badge and debt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWholesale
                              ? Icons.store_rounded
                              : Icons.person_rounded,
                          size: 12,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWholesale ? 'Grosir' : 'Retail',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Debt indicator
              if (hasDebt) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 12,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        PriceFormatter.formatCompact(customer.totalDebt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // Menu button
          Positioned(
            top: -4,
            right: -4,
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
                if (isWholesale)
                  PopupMenuItem(
                    height: 40,
                    child: Row(
                      children: [
                        Icon(Icons.add_shopping_cart_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Buat Pesanan', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      Duration.zero,
                      () => _navigateToOrder(customer),
                    ),
                  ),
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
                    () => _navigateToForm(customer: customer),
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
                    () => _deleteCustomer(customer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer, int index, bool isDark) {
    final isWholesale = customer.isWholesale;
    final hasDebt = customer.hasDebt;
    final typeColor = isWholesale ? AppColors.accent : AppColors.info;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      animationDelay: Duration(milliseconds: index * 50),
      onTap: () => _navigateToDetail(customer),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  typeColor.withValues(alpha: 0.2),
                  typeColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isWholesale ? Icons.business_rounded : Icons.person_rounded,
              color: typeColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          // Customer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Grosir',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      customer.phone ?? 'Tidak ada telepon',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (hasDebt) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              size: 12,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              PriceFormatter.formatCompact(customer.totalDebt),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Menu
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
              // Harga Khusus - hanya untuk wholesale
              if (isWholesale)
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.price_change_rounded,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('Harga Khusus',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.success)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _navigateToForm(customer: customer),
                  ),
                ),
              // Buat Pesanan - hanya untuk wholesale
              if (isWholesale)
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Buat Pesanan',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _navigateToOrder(customer),
                  ),
                ),
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
                  () => _navigateToForm(customer: customer),
                ),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _deleteCustomer(customer),
                ),
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
              color: AppColors.info.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isEmpty
                  ? Icons.people_outline_rounded
                  : Icons.search_off_rounded,
              size: 48,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty ? 'Belum ada pelanggan' : 'Tidak ditemukan',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Tambahkan pelanggan pertama Anda untuk memulai'
                : 'Coba kata kunci pencarian lain',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            GradientButton(
              text: 'Tambah Pelanggan',
              icon: Icons.person_add_rounded,
              onPressed: () => _navigateToForm(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
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
          Text('Gagal memuat pelanggan', style: AppTextStyles.titleMedium),
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
            onPressed: () => ref.invalidate(customersProvider),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm({CustomerModel? customer}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(customer: customer),
      ),
    );
  }

  Future<void> _navigateToDetail(CustomerModel customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );
    // Refresh customer list after returning
    ref.invalidate(customersProvider);
  }

  Future<void> _navigateToOrder(CustomerModel customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderFormPage(preselectedCustomer: customer),
      ),
    );
    ref.invalidate(customersProvider);
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
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
            const Text('Hapus Pelanggan'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus "${customer.name}"?'),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(customersProvider.notifier).deleteCustomer(customer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customer.name} berhasil dihapus'),
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
              content: Text('Kesalahan: $e'),
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
