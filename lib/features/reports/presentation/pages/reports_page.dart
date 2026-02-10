import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../inventory/providers/product_provider.dart';
import '../../../finance/providers/expense_provider.dart';
import '../../../finance/data/models/expense_model.dart';
import 'sales_report_page.dart';
import 'stock_report_page.dart';

/// Reports Page - Laporan Bisnis Lengkap
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _selectedPeriod = 'bulan';

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'hari':
        return DateTime(now.year, now.month, now.day);
      case 'minggu':
        return now.subtract(const Duration(days: 6));
      case 'bulan':
        return DateTime(now.year, now.month, 1);
      case 'tahun':
        return DateTime(now.year, 1, 1);
      case 'semua':
        return DateTime(2020, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    // Watch data providers
    final ordersAsync = ref.watch(ordersProvider);
    final expensesAsync = ref.watch(expensesProvider);
    // productsProvider is invalidated in refresh but not directly used here

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
        ref.invalidate(productsProvider);
        ref.invalidate(expensesProvider);
      },
      child: ListView(
        padding:
            EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 100),
        children: [
          // Header
          _buildHeader(isDark),
          const SizedBox(height: 16),

          // Period Filter
          _buildPeriodFilter(isDark),
          const SizedBox(height: 20),

          // Summary Cards - Using orders data directly
          _buildSummaryCards(ordersAsync, expensesAsync, isDark),
          const SizedBox(height: 20),

          // Main Content
          if (isWide) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSalesChart(ordersAsync, isDark),
                      const SizedBox(height: 16),
                      _buildPaymentStatusChart(ordersAsync, isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopProducts(ordersAsync, isDark),
                      const SizedBox(height: 16),
                      _buildTopCustomers(ordersAsync, isDark),
                      const SizedBox(height: 16),
                      _buildQuickReports(context, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSalesChart(ordersAsync, isDark),
            const SizedBox(height: 16),
            _buildPaymentStatusChart(ordersAsync, isDark),
            const SizedBox(height: 16),
            _buildTopProducts(ordersAsync, isDark),
            const SizedBox(height: 16),
            _buildTopCustomers(ordersAsync, isDark),
            const SizedBox(height: 16),
            _buildQuickReports(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan Bisnis',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Analisis performa bisnis Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM yyyy', 'id').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(bool isDark) {
    final periods = [
      ('hari', 'Hari Ini'),
      ('minggu', '7 Hari'),
      ('bulan', 'Bulan Ini'),
      ('tahun', 'Tahun Ini'),
      ('semua', 'Semua'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final isSelected = _selectedPeriod == p.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => setState(() => _selectedPeriod = p.$1),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    p.$2,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<List<OrderModel>> ordersAsync,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (allOrders) {
        // Filter orders by selected period
        final orders = allOrders.where((o) {
          return o.orderDate
                  .isAfter(_startDate.subtract(const Duration(days: 1))) &&
              o.orderDate.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        // Calculate totals
        double totalSales = 0;
        double totalPaid = 0;
        double totalRemaining = 0;
        int paidCount = 0;
        int partialCount = 0;
        int unpaidCount = 0;

        for (final order in orders) {
          totalSales += order.finalAmount;
          totalPaid += order.paidAmount;
          totalRemaining += order.remainingAmount;

          if (order.isPaid) {
            paidCount++;
          } else if (order.isPartial) {
            partialCount++;
          } else {
            unpaidCount++;
          }
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Penjualan',
                    PriceFormatter.format(totalSales),
                    Icons.trending_up_rounded,
                    AppColors.primary,
                    isDark,
                    subtitle: '${orders.length} pesanan',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    'Sudah Dibayar',
                    PriceFormatter.format(totalPaid),
                    Icons.check_circle_rounded,
                    AppColors.success,
                    isDark,
                    subtitle: '$paidCount lunas',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Belum Dibayar',
                    PriceFormatter.format(totalRemaining),
                    Icons.schedule_rounded,
                    AppColors.warning,
                    isDark,
                    subtitle: '${partialCount + unpaidCount} pending',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: expensesAsync.when(
                    data: (allExpenses) {
                      final expenses = allExpenses.where((e) {
                        return e.expenseDate.isAfter(
                                _startDate.subtract(const Duration(days: 1))) &&
                            e.expenseDate.isBefore(
                                _endDate.add(const Duration(days: 1)));
                      }).toList();

                      double totalExpense = 0;
                      for (final e in expenses) {
                        totalExpense += e.amount;
                      }

                      return _buildSummaryCard(
                        'Pengeluaran',
                        PriceFormatter.format(totalExpense),
                        Icons.money_off_rounded,
                        AppColors.error,
                        isDark,
                        subtitle: '${expenses.length} transaksi',
                      );
                    },
                    loading: () => _buildSummaryCard(
                      'Pengeluaran',
                      '-',
                      Icons.money_off_rounded,
                      AppColors.error,
                      isDark,
                    ),
                    error: (_, __) => _buildSummaryCard(
                      'Pengeluaran',
                      'Error',
                      Icons.money_off_rounded,
                      AppColors.error,
                      isDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorCard('Gagal memuat data', isDark),
    );
  }

  Widget _buildSummaryCard(
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSalesChart(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (allOrders) {
        // Get last 7 days data
        final now = DateTime.now();
        final days = <DateTime>[];
        final salesByDay = <double>[];

        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day - i);
          days.add(day);

          double daySales = 0;
          for (final order in allOrders) {
            if (order.orderDate.year == day.year &&
                order.orderDate.month == day.month &&
                order.orderDate.day == day.day) {
              daySales += order.paidAmount;
            }
          }
          salesByDay.add(daySales);
        }

        final maxSales = salesByDay.isEmpty
            ? 1.0
            : salesByDay.reduce((a, b) => a > b ? a : b);

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
                  Icon(Icons.show_chart_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Grafik Penjualan (7 Hari)',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxSales > 0 ? maxSales * 1.2 : 100000,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            PriceFormatter.formatCompact(rod.toY),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('EEE', 'id').format(days[idx]),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              PriceFormatter.formatCompact(value),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxSales > 0 ? maxSales / 4 : 25000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: salesByDay.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat grafik', isDark),
    );
  }

  Widget _buildPaymentStatusChart(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (allOrders) {
        // Filter by period
        final orders = allOrders.where((o) {
          return o.orderDate
                  .isAfter(_startDate.subtract(const Duration(days: 1))) &&
              o.orderDate.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        final paid = orders.where((o) => o.isPaid).length;
        final partial = orders.where((o) => o.isPartial).length;
        final unpaid = orders.where((o) => o.isUnpaid).length;
        final total = orders.length;

        if (total == 0) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Center(
              child: Text(
                'Tidak ada pesanan pada periode ini',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          );
        }

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
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: paid.toDouble(),
                            color: AppColors.success,
                            title: '',
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: partial.toDouble(),
                            color: AppColors.warning,
                            title: '',
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: unpaid.toDouble(),
                            color: AppColors.error,
                            title: '',
                            radius: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendItem(
                            'Lunas', paid, total, AppColors.success, isDark),
                        const SizedBox(height: 12),
                        _buildLegendItem('Sebagian', partial, total,
                            AppColors.warning, isDark),
                        const SizedBox(height: 12),
                        _buildLegendItem('Belum Bayar', unpaid, total,
                            AppColors.error, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat status', isDark),
    );
  }

  Widget _buildLegendItem(
    String label,
    int count,
    int total,
    Color color,
    bool isDark,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        Text(
          '$count (${percentage.toStringAsFixed(0)}%)',
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProducts(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
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
              Icon(Icons.star_rounded, color: AppColors.warning, size: 22),
              const SizedBox(width: 10),
              Text(
                'Produk Terlaris',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ordersAsync.when(
            data: (orders) {
              // This would need order items data
              // For now show placeholder
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Lihat di Laporan Penjualan',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(
    AsyncValue<List<OrderModel>> ordersAsync,
    bool isDark,
  ) {
    return ordersAsync.when(
      data: (allOrders) {
        // Filter by period
        final orders = allOrders.where((o) {
          return o.orderDate
                  .isAfter(_startDate.subtract(const Duration(days: 1))) &&
              o.orderDate.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        // Group by customer
        final customerSales = <String, double>{};
        for (final order in orders) {
          customerSales[order.customerName] =
              (customerSales[order.customerName] ?? 0) + order.finalAmount;
        }

        // Sort and take top 5
        final sortedCustomers = customerSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topCustomers = sortedCustomers.take(5).toList();

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
                  Icon(Icons.people_rounded, color: AppColors.info, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Pelanggan Teratas',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (topCustomers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Tidak ada data',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ...topCustomers.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final customer = entry.value;
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
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            customer.key,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          PriceFormatter.formatCompact(customer.value),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard('Gagal memuat data', isDark),
    );
  }

  Widget _buildQuickReports(BuildContext context, bool isDark) {
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
              Icon(Icons.description_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Laporan Detail',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReportButton(
            'Laporan Penjualan',
            Icons.receipt_long_rounded,
            AppColors.success,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesReportPage()),
            ),
            isDark,
          ),
          const SizedBox(height: 8),
          _buildReportButton(
            'Laporan Stok',
            Icons.inventory_2_rounded,
            AppColors.info,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockReportPage()),
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Material(
      color: color.withOpacity(isDark ? 0.15 : 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
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
          Text(message, style: TextStyle(color: AppColors.error)),
        ],
      ),
    );
  }
}
