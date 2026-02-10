import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../inventory/providers/product_provider.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../finance/providers/expense_provider.dart';
import '../../../inventory/presentation/pages/product_form_page.dart';
import '../../../checkout/presentation/pages/admin_checkout_standalone_page.dart';
import '../../../finance/presentation/pages/finance_page.dart';
import '../../../employees/presentation/pages/employee_management_page.dart';

/// Dashboard Monitoring - Real-time Business Overview
class DashboardHomeContent extends ConsumerWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    // Watch all data providers
    final productsAsync = ref.watch(productsProvider);
    final customersAsync = ref.watch(customersProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(productsProvider);
        ref.invalidate(customersProvider);
        ref.invalidate(ordersProvider);
        ref.invalidate(expensesProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDark),
            const SizedBox(height: 24),

            // Main Stats Cards - Total Data
            _buildMainStats(productsAsync, customersAsync, ordersAsync, isDark),
            const SizedBox(height: 20),

            // Financial Overview
            _buildFinancialOverview(ordersAsync, expensesAsync, isDark),
            const SizedBox(height: 20),

            // Layout for different screens
            if (isWide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildOrderStatusOverview(ordersAsync, isDark),
                        const SizedBox(height: 16),
                        _buildRecentActivity(ordersAsync, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildLowStockAlert(productsAsync, isDark),
                        const SizedBox(height: 16),
                        _buildCustomerDebtAlert(customersAsync, isDark),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildOrderStatusOverview(ordersAsync, isDark),
              const SizedBox(height: 16),
              _buildLowStockAlert(productsAsync, isDark),
              const SizedBox(height: 16),
              _buildCustomerDebtAlert(customersAsync, isDark),
              const SizedBox(height: 16),
              _buildRecentActivity(ordersAsync, isDark),
              const SizedBox(height: 16),
              _buildQuickActions(context, isDark),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 17
            ? 'Selamat Siang'
            : 'Selamat Malam';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dashboard Monitoring',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id').format(now),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge('Online', Colors.green, isDark),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(
    AsyncValue<List<ProductModel>> productsAsync,
    AsyncValue<List<CustomerModel>> customersAsync,
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMainStatCard(
            'Total Produk',
            productsAsync.when(
              data: (p) => '${p.length}',
              loading: () => '-',
              error: (_, __) => '!',
            ),
            Icons.inventory_2_rounded,
            AppColors.info,
            isDark,
            subtitle: productsAsync.maybeWhen(
              data: (p) => '${p.where((x) => x.isLowStock).length} stok rendah',
              orElse: () => '',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMainStatCard(
            'Total Pelanggan',
            customersAsync.when(
              data: (c) => '${c.length}',
              loading: () => '-',
              error: (_, __) => '!',
            ),
            Icons.people_rounded,
            AppColors.success,
            isDark,
            subtitle: customersAsync.maybeWhen(
              data: (c) =>
                  '${c.where((x) => x.totalDebt > 0).length} punya hutang',
              orElse: () => '',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMainStatCard(
            'Total Pesanan',
            ordersAsync.when(
              data: (o) => '${o.length}',
              loading: () => '-',
              error: (_, __) => '!',
            ),
            Icons.receipt_long_rounded,
            AppColors.warning,
            isDark,
            subtitle: ordersAsync.maybeWhen(
              data: (o) => '${o.where((x) => x.isPaid).length} lunas',
              orElse: () => '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.2 : 0.1),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(
    AsyncValue<List<OrderModel>> ordersAsync,
    AsyncValue expensesAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (orders) {
        // Calculate totals from ALL orders
        double totalRevenue = 0;
        double totalPaid = 0;
        double totalPending = 0;

        for (final order in orders) {
          totalRevenue += order.finalAmount;
          totalPaid += order.paidAmount;
          totalPending += order.remainingAmount;
        }

        // Get expense total
        double totalExpense = 0;
        expensesAsync.whenData((expenses) {
          for (final e in expenses) {
            totalExpense += e.amount;
          }
        });

        final profit = totalPaid - totalExpense;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ringkasan Keuangan',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Semua Waktu',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildFinanceItem(
                      'Total Penjualan',
                      PriceFormatter.format(totalRevenue),
                      Icons.trending_up_rounded,
                      AppColors.primary,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinanceItem(
                      'Sudah Dibayar',
                      PriceFormatter.format(totalPaid),
                      Icons.check_circle_rounded,
                      AppColors.success,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFinanceItem(
                      'Belum Dibayar',
                      PriceFormatter.format(totalPending),
                      Icons.schedule_rounded,
                      AppColors.warning,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinanceItem(
                      'Total Pengeluaran',
                      PriceFormatter.format(totalExpense),
                      Icons.money_off_rounded,
                      AppColors.error,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (profit >= 0 ? AppColors.success : AppColors.error)
                          .withOpacity(0.15),
                      (profit >= 0 ? AppColors.success : AppColors.error)
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (profit >= 0 ? AppColors.success : AppColors.error)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      profit >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laba/Rugi Bersih',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          PriceFormatter.format(profit.abs()),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: profit >= 0
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat data keuangan', isDark),
    );
  }

  Widget _buildFinanceItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusOverview(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (orders) {
        final paid = orders.where((o) => o.isPaid).length;
        final partial = orders.where((o) => o.isPartial).length;
        final unpaid = orders.where((o) => o.isUnpaid).length;
        final total = orders.length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_rounded,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Status Pembayaran',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$total pesanan',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Progress bars
              _buildStatusBar('Lunas', paid, total, AppColors.success, isDark),
              const SizedBox(height: 12),
              _buildStatusBar(
                  'Sebagian', partial, total, AppColors.warning, isDark),
              const SizedBox(height: 12),
              _buildStatusBar(
                  'Belum Bayar', unpaid, total, AppColors.error, isDark),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat status', isDark),
    );
  }

  Widget _buildStatusBar(
    String label,
    int count,
    int total,
    Color color,
    bool isDark,
  ) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockAlert(
    AsyncValue<List<ProductModel>> productsAsync,
    bool isDark,
  ) {
    return productsAsync.when(
      data: (products) {
        final lowStock = products.where((p) => p.isLowStock).toList();
        final outOfStock = products.where((p) => p.isOutOfStock).toList();
        final alertProducts = [...outOfStock, ...lowStock].take(5).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alertProducts.isNotEmpty
                  ? AppColors.error.withOpacity(0.3)
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: alertProducts.isNotEmpty
                        ? AppColors.error
                        : AppColors.success,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Peringatan Stok',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (alertProducts.isNotEmpty
                              ? AppColors.error
                              : AppColors.success)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${alertProducts.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: alertProducts.isNotEmpty
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (alertProducts.isEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.success, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Semua stok aman!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                ...alertProducts.map((p) => _buildStockItem(p, isDark)),
              ],
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat stok', isDark),
    );
  }

  Widget _buildStockItem(ProductModel product, bool isDark) {
    final isOut = product.isOutOfStock;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isOut ? AppColors.error : AppColors.warning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOut ? Icons.cancel_rounded : Icons.warning_amber_rounded,
            color: isOut ? AppColors.error : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${product.stock} ${product.unit}',
            style: AppTextStyles.labelMedium.copyWith(
              color: isOut ? AppColors.error : AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDebtAlert(
    AsyncValue<List<CustomerModel>> customersAsync,
    bool isDark,
  ) {
    return customersAsync.when(
      data: (customers) {
        final withDebt = customers.where((c) => c.totalDebt > 0).toList()
          ..sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
        final topDebtors = withDebt.take(5).toList();

        double totalDebt = 0;
        for (final c in withDebt) {
          totalDebt += c.totalDebt;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: totalDebt > 0
                  ? AppColors.warning.withOpacity(0.3)
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Piutang Pelanggan',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                PriceFormatter.format(totalDebt),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${withDebt.length} pelanggan',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (topDebtors.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...topDebtors.map((c) => _buildDebtorItem(c, isDark)),
              ],
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat piutang', isDark),
    );
  }

  Widget _buildDebtorItem(CustomerModel customer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.warning.withOpacity(0.2),
            child: Text(
              customer.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              customer.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            PriceFormatter.formatCompact(customer.totalDebt),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (orders) {
        final recent = orders.take(8).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Aktivitas Terbaru',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                Center(
                  child: Text(
                    'Belum ada aktivitas',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                )
              else
                ...recent.map((o) => _buildActivityItem(o, isDark)),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat aktivitas', isDark),
    );
  }

  Widget _buildActivityItem(OrderModel order, bool isDark) {
    final statusColor = order.isPaid
        ? AppColors.success
        : order.isPartial
            ? AppColors.warning
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.orderNumber,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.formatCompact(order.finalAmount),
                style: AppTextStyles.labelMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                DateFormat('dd/MM').format(order.orderDate),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Aksi Cepat',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Kasir',
                  Icons.point_of_sale_rounded,
                  AppColors.success,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminCheckoutStandalonePage()),
                  ),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  'Produk',
                  Icons.add_box_rounded,
                  AppColors.info,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductFormPage()),
                  ),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Keuangan',
                  Icons.account_balance_wallet_rounded,
                  AppColors.warning,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinancePage()),
                  ),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  'Karyawan',
                  Icons.badge_rounded,
                  AppColors.accent,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EmployeeManagementPage()),
                  ),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Material(
      color: color.withOpacity(isDark ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
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

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
