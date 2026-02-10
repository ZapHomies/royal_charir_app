import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';

/// Finance Management Page
class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider);
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Finance Management'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with summary
          _buildFinanceSummary(ordersAsync, customersAsync, isDark),

          // Tab bar
          _buildTabBar(isDark),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRevenueTab(ordersAsync, isDark),
                _buildReceivablesTab(ordersAsync, customersAsync, isDark),
                _buildExpensesTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummary(
    AsyncValue<List<OrderModel>> ordersAsync,
    AsyncValue<List<CustomerModel>> customersAsync,
    bool isDark,
  ) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      animationDelay: 100.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Overview',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Financial summary cards
          ordersAsync.when(
            data: (orders) {
              final totalRevenue =
                  orders.fold(0.0, (sum, o) => sum + o.finalAmount);
              final totalReceived =
                  orders.fold(0.0, (sum, o) => sum + o.paidAmount);
              final totalReceivables = totalRevenue - totalReceived;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Revenue',
                            PriceFormatter.format(totalRevenue),
                            Icons.trending_up_rounded,
                            AppColors.success,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem(
                            'Received',
                            PriceFormatter.format(totalReceived),
                            Icons.check_circle_rounded,
                            AppColors.info,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem(
                            'Receivables',
                            PriceFormatter.format(totalReceivables),
                            Icons.pending_rounded,
                            AppColors.warning,
                            isDark,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildSummaryItem(
                        'Total Revenue',
                        PriceFormatter.format(totalRevenue),
                        Icons.trending_up_rounded,
                        AppColors.success,
                        isDark,
                        horizontal: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Received',
                              PriceFormatter.format(totalReceived),
                              Icons.check_circle_rounded,
                              AppColors.info,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryItem(
                              'Receivables',
                              PriceFormatter.format(totalReceivables),
                              Icons.pending_rounded,
                              AppColors.warning,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    bool horizontal = false,
  }) {
    if (horizontal) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
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
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        labelStyle:
            AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Pendapatan'),
          Tab(text: 'Receivables'),
          Tab(text: 'Expenses'),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildRevenueTab(
      AsyncValue<List<OrderModel>> ordersAsync, bool isDark) {
    return ordersAsync.when(
      data: (orders) {
        final paidOrders = orders.where((o) => o.isPaid).toList();

        if (paidOrders.isEmpty) {
          return _buildEmptyState(
            'No Revenue Yet',
            'Completed sales will appear here',
            Icons.trending_up_rounded,
            AppColors.success,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: paidOrders.length,
          itemBuilder: (context, index) {
            final order = paidOrders[index];
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              animationDelay: Duration(milliseconds: index * 50),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.orderNumber,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${PriceFormatter.format(order.finalAmount)}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(order.orderDate),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildReceivablesTab(AsyncValue<List<OrderModel>> ordersAsync,
      AsyncValue<List<CustomerModel>> customersAsync, bool isDark) {
    return ordersAsync.when(
      data: (orders) {
        final unpaidOrders = orders.where((o) => !o.isPaid).toList();

        if (unpaidOrders.isEmpty) {
          return _buildEmptyState(
            'No Receivables',
            'All payments have been received!',
            Icons.check_circle_rounded,
            AppColors.success,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: unpaidOrders.length,
          itemBuilder: (context, index) {
            final order = unpaidOrders[index];
            final remaining = order.remainingAmount;

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              animationDelay: Duration(milliseconds: index * 50),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      order.isPartial
                          ? Icons.pending_rounded
                          : Icons.warning_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.orderNumber,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (order.isPartial)
                          Text(
                            'Paid: ${PriceFormatter.format(order.paidAmount)} of ${PriceFormatter.format(order.finalAmount)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        PriceFormatter.format(remaining),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isPartial
                              ? AppColors.info.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.isPartial ? 'Sebagian' : 'UNPAID',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: order.isPartial
                                ? AppColors.info
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildExpensesTab(bool isDark) {
    final expensesAsync = ref.watch(expensesProvider);
    final selectedCategory = ref.watch(selectedExpenseCategoryProvider);

    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip('Semua', null, selectedCategory, isDark),
              ...ExpenseModel.categories.map((cat) => _buildCategoryChip(
                    ExpenseModel.getCategoryDisplayName(cat),
                    cat,
                    selectedCategory,
                    isDark,
                  )),
            ],
          ),
        ),

        // Expense List
        Expanded(
          child: expensesAsync.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return _buildEmptyState(
                  'Belum Ada Pengeluaran',
                  'Tambahkan pengeluaran untuk tracking biaya',
                  Icons.receipt_long_rounded,
                  AppColors.error,
                  showButton: true,
                  buttonText: 'Tambah Pengeluaran',
                  onButtonPressed: () => _showAddExpenseDialog(isDark),
                );
              }

              // Calculate total
              final total =
                  expenses.fold<double>(0, (sum, e) => sum + e.amount);

              return Column(
                children: [
                  // Total summary
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.dangerGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pengeluaran',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              PriceFormatter.format(total),
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${expenses.length} item',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 12),
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return _buildExpenseCard(expense, index, isDark);
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      String label, String? category, String? selectedCategory, bool isDark) {
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(selectedExpenseCategoryProvider.notifier).state = category;
          if (category == null) {
            ref.read(expensesProvider.notifier).clearFilter();
          } else {
            ref.read(expensesProvider.notifier).setFilter(category: category);
          }
        },
        backgroundColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        selectedColor: AppColors.error.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: isSelected
              ? AppColors.error
              : isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
        ),
        checkmarkColor: AppColors.error,
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index, bool isDark) {
    final categoryColor = _getCategoryColor(expense.category);
    final dateFormat = DateFormat('dd MMM yyyy');

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      animationDelay: Duration(milliseconds: index * 30),
      onTap: () => _showExpenseOptions(expense, isDark),
      child: Row(
        children: [
          // Category Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: categoryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: AppTextStyles.labelLarge.copyWith(
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ExpenseModel.getCategoryDisplayName(expense.category),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: categoryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(expense.expenseDate),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Text(
            PriceFormatter.format(expense.amount),
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bahan':
        return AppColors.info;
      case 'karyawan':
        return AppColors.success;
      case 'maintenance':
        return AppColors.warning;
      case 'operasional':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'bahan':
        return Icons.inventory_2_rounded;
      case 'karyawan':
        return Icons.people_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      case 'operasional':
        return Icons.business_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  void _showExpenseOptions(ExpenseModel expense, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(expense.description, style: AppTextStyles.titleMedium),
            Text(
              PriceFormatter.format(expense.amount),
              style:
                  AppTextStyles.headlineSmall.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.info),
              ),
              title: const Text('Edit Pengeluaran'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                _showEditExpenseDialog(expense, isDark);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_rounded, color: AppColors.error),
              ),
              title: const Text('Hapus Pengeluaran'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteExpense(expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(bool isDark) {
    _showExpenseForm(null, isDark);
  }

  void _showEditExpenseDialog(ExpenseModel expense, bool isDark) {
    _showExpenseForm(expense, isDark);
  }

  void _showExpenseForm(ExpenseModel? expense, bool isDark) {
    final isEdit = expense != null;
    final descController =
        TextEditingController(text: expense?.description ?? '');
    final amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(0) : '',
    );
    final notesController = TextEditingController(text: expense?.notes ?? '');
    String selectedCategory = expense?.category ?? 'bahan';
    DateTime selectedDate = expense?.expenseDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEdit ? Icons.edit_rounded : Icons.add_rounded,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ExpenseModel.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(ExpenseModel.getCategoryDisplayName(cat)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Contoh: Beli kain katun',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd MMMM yyyy').format(selectedDate),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => _saveExpense(
                expense,
                descController.text,
                amountController.text,
                selectedCategory,
                selectedDate,
                notesController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense(
    ExpenseModel? existing,
    String description,
    String amountText,
    String category,
    DateTime date,
    String notes,
  ) async {
    Navigator.pop(context);

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
      );
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    try {
      final expense = ExpenseModel(
        id: existing?.id ?? const Uuid().v4(),
        category: category,
        description: description,
        amount: amount,
        expenseDate: date,
        notes: notes.isNotEmpty ? notes : null,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existing != null) {
        await ref.read(expensesProvider.notifier).updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengeluaran berhasil diupdate'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await ref.read(expensesProvider.notifier).addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengeluaran berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _confirmDeleteExpense(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Pengeluaran'),
          ],
        ),
        content: Text('Hapus "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(expensesProvider.notifier)
                    .deleteExpense(expense.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengeluaran berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool showButton = false,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (showButton && buttonText != null) ...[
            const SizedBox(height: 24),
            GradientButton(
              text: buttonText,
              icon: Icons.add_rounded,
              onPressed: onButtonPressed ?? () {},
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}



