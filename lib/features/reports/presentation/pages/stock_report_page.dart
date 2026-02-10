import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../providers/report_provider.dart';
import 'sales_report_page.dart';
import '../../../../core/services/report_print_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sales_report_model.dart';

/// Stock Report Page
class StockReportPage extends ConsumerStatefulWidget {
  const StockReportPage({super.key});

  @override
  ConsumerState<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends ConsumerState<StockReportPage> {
  String _selectedFilter = 'All'; // 'All', 'Low Stock', 'Out of Stock'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportAsync = ref.watch(stockReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
        actions: [
          // Navigate to Sales Report
          IconButton(
            icon: const Icon(Icons.trending_up),
            tooltip: 'Sales Report',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesReportPage(),
                ),
              );
            },
          ),
          // Print Report
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Report',
            onPressed: () => _printReport(context, reportAsync),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(stockReportProvider),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          // Filter items
          final filteredItems = report.items.where((item) {
            if (_selectedFilter == 'Low Stock') return item.status == 'low';
            if (_selectedFilter == 'Out of Stock') return item.status == 'out';
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 100), // Bottom padding for floating bar
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Products',
                      '${report.totalProducts}',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Stock Value',
                      PriceFormatter.format(report.totalStockValue),
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Low Stock',
                      '${report.lowStockProducts}',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Out of Stock',
                      '${report.outOfStockProducts}',
                      Icons.error,
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Products List
              Text(
                'Stock Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'All',
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = 'All');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Low Stock'),
                      selected: _selectedFilter == 'Low Stock',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = 'Low Stock');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Out of Stock'),
                      selected: _selectedFilter == 'Out of Stock',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = 'Out of Stock');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Products Table
              Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Kategori')),
                      DataColumn(label: Text('Stok'), numeric: true),
                      DataColumn(label: Text('Min'), numeric: true),
                      DataColumn(label: Text('Value'), numeric: true),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: filteredItems.map((item) {
                      Color statusColor = Colors.green;
                      IconData statusIcon = Icons.check_circle;
                      String statusText = 'OK';

                      if (item.status == 'low') {
                        statusColor = Colors.orange;
                        statusIcon = Icons.warning;
                        statusText = 'Low';
                      } else if (item.status == 'out') {
                        statusColor = Colors.red;
                        statusIcon = Icons.error;
                        statusText = 'Out';
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                item.productName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(item.category)),
                          DataCell(Text('${item.stock} ${item.unit}')),
                          DataCell(Text('${item.minStock}')),
                          DataCell(Text(
                              PriceFormatter.formatCompact(item.stockValue))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 16, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(color: statusColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReport(
      BuildContext context, AsyncValue<StockReportModel> reportAsync) async {
    reportAsync.when(
      data: (report) async {
        try {
          // Show print preview
          await ReportPrintService.printStockReport(report, preview: true);
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
          const SnackBar(content: Text('Loading report data...')),
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


