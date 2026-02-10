import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../providers/report_provider.dart';
import 'stock_report_page.dart';
import '../../../../core/services/report_print_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sales_report_model.dart';

/// Sales Report Page dengan tema gelap yang clean
class SalesReportPage extends ConsumerStatefulWidget {
  const SalesReportPage({super.key});

  @override
  ConsumerState<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends ConsumerState<SalesReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateRange = DateRange(start: _startDate, end: _endDate);
    final reportAsync = ref.watch(salesReportProvider(dateRange));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          'Laporan Penjualan',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_rounded),
            tooltip: 'Laporan Stok',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const StockReportPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Cetak',
            onPressed: () => _printReport(context, reportAsync),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    size: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Ubah', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: reportAsync.when(
              data: (report) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary Cards
                  _buildSummaryCards(report, isDark),
                  const SizedBox(height: 20),

                  // Payment Status Chart
                  _buildPaymentStatusChart(report, isDark),
                  const SizedBox(height: 20),

                  // Top Products
                  if (report.topProducts.isNotEmpty) ...[
                    _buildSectionTitle(
                        'Produk Terlaris', Icons.star_rounded, isDark),
                    const SizedBox(height: 10),
                    _buildTopList(report.topProducts, 'terjual', isDark),
                    const SizedBox(height: 20),
                  ],

                  // Top Customers
                  if (report.topCustomers.isNotEmpty) ...[
                    _buildSectionTitle(
                        'Pelanggan Teratas', Icons.people_rounded, isDark),
                    const SizedBox(height: 10),
                    _buildTopList(report.topCustomers, 'pesanan', isDark),
                  ],
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48,
                        color: AppColors.error.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('Error: $error',
                        style: TextStyle(
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SalesReportModel report, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Penjualan',
                PriceFormatter.format(report.totalSales),
                Icons.attach_money_rounded,
                AppColors.success,
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryCard(
                'Jumlah Pesanan',
                '${report.totalOrders}',
                Icons.receipt_rounded,
                AppColors.primary,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Sudah Dibayar',
                PriceFormatter.format(report.totalPaid),
                Icons.check_circle_rounded,
                AppColors.info,
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryCard(
                'Belum Dibayar',
                PriceFormatter.format(report.totalRemaining),
                Icons.pending_rounded,
                AppColors.warning,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(SalesReportModel report, bool isDark) {
    final total =
        report.paidOrders + report.partialOrders + report.unpaidOrders;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 100,
                height: 100,
                child: total > 0
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 25,
                          sections: [
                            PieChartSectionData(
                              value: report.paidOrders.toDouble(),
                              color: AppColors.success,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: report.partialOrders.toDouble(),
                              color: AppColors.warning,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: report.unpaidOrders.toDouble(),
                              color: AppColors.error,
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          'No Data',
                          style: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('Lunas', report.paidOrders, total,
                        AppColors.success, isDark),
                    const SizedBox(height: 10),
                    _buildLegendItem('Sebagian', report.partialOrders, total,
                        AppColors.warning, isDark),
                    const SizedBox(height: 10),
                    _buildLegendItem('Belum Bayar', report.unpaidOrders, total,
                        AppColors.error, isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String label, int count, int total, Color color, bool isDark) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTopList(
      List<SalesReportItem> items, String countLabel, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              '${item.count} $countLabel',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),
            ),
            trailing: Text(
              PriceFormatter.formatCompact(item.amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _printReport(
      BuildContext context, AsyncValue<SalesReportModel> reportAsync) async {
    reportAsync.when(
      data: (report) async {
        try {
          await ReportPrintService.printSalesReport(report, preview: true);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error printing: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memuat data laporan...')),
        );
      },
      error: (err, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $err'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }
}
