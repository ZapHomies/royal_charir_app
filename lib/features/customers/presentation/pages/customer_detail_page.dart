import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/services/dot_matrix_print_service.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/wholesale_price.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../orders/presentation/pages/order_detail_page.dart';
import '../../../inventory/data/repositories/product_repository.dart';
import 'customer_form_page.dart';

/// Customer Detail Page - Shows customer info, special prices, and order history
class CustomerDetailPage extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WholesalePrice> _specialPrices = [];
  List<OrderModel> _orders = [];
  Map<String, String> _productNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final customerRepo = CustomerRepository();
      final orderRepo = OrderRepository();
      final productRepo = ProductRepository();

      // Load special prices
      final prices = await customerRepo.getWholesalePrices(widget.customer.id);

      // Load product names for special prices
      final productNames = <String, String>{};
      for (final price in prices) {
        final product = await productRepo.getProductById(price.productId);
        if (product != null) {
          productNames[price.productId] = product.name;
        }
      }

      // Load orders
      final orders = await orderRepo.getOrdersByCustomer(widget.customer.id);

      setState(() {
        _specialPrices = prices;
        _productNames = productNames;
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.customer.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _navigateToEdit(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Customer Header Card
                _buildHeaderCard(isDark),
                const SizedBox(height: 16),
                // Tab Bar
                _buildTabBar(isDark),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(isDark),
                      _buildSpecialPricesTab(isDark),
                      _buildOrderHistoryTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    final isWholesale = widget.customer.isWholesale;
    final typeColor = isWholesale ? AppColors.accent : AppColors.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.customer.name.isNotEmpty
                      ? widget.customer.name[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isWholesale ? 'Pelanggan Grosir' : 'Pelanggan Eceran',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.customer.hasDebt) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.warning_rounded,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Piutang: ${PriceFormatter.format(widget.customer.totalDebt)}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Harga Khusus'),
          Tab(text: 'Pesanan'),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildInfoTab(bool isDark) {
    final customer = widget.customer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(Icons.phone_rounded, 'Telepon',
              customer.phone ?? 'Belum diisi', isDark),
          _buildInfoItem(Icons.email_rounded, 'Email',
              customer.email ?? 'Belum diisi', isDark),
          _buildInfoItem(Icons.location_on_rounded, 'Alamat',
              customer.address ?? 'Belum diisi', isDark),
          _buildInfoItem(Icons.notes_rounded, 'Catatan',
              customer.notes ?? 'Tidak ada catatan', isDark),
          const SizedBox(height: 16),
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pesanan',
                  '${_orders.length}',
                  Icons.receipt_long_rounded,
                  AppColors.primary,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Belum Bayar',
                  '${_orders.where((o) => o.paymentStatus == 'Belum Bayar' || o.paymentStatus == 'unpaid').length}',
                  Icons.pending_rounded,
                  AppColors.warning,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Harga Khusus',
                  '${_specialPrices.length}',
                  Icons.sell_rounded,
                  AppColors.accent,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialPricesTab(bool isDark) {
    if (_specialPrices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sell_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Harga Khusus',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan harga khusus dari edit pelanggan',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _specialPrices.length,
      itemBuilder: (context, index) {
        final price = _specialPrices[index];
        final productName =
            _productNames[price.productId] ?? 'Produk Tidak Dikenal';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  productName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                PriceFormatter.format(price.price),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: index * 50)).fadeIn().slideX(
              begin: 0.1,
              end: 0,
            );
      },
    );
  }

  Widget _buildOrderHistoryTab(bool isDark) {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pesanan',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    // Group orders by status
    final paidOrders =
        _orders.where((o) => o.paymentStatus == 'Lunas').toList();
    final unpaidOrders = _orders
        .where((o) =>
            o.paymentStatus == 'Belum Bayar' || o.paymentStatus == 'unpaid')
        .toList();
    final partialOrders = _orders
        .where((o) =>
            o.paymentStatus == 'Sebagian' || o.paymentStatus == 'partial')
        .toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Status filter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.labelSmall,
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: 'Lunas (${paidOrders.length})'),
                Tab(text: 'Belum Bayar (${unpaidOrders.length})'),
                Tab(text: 'Cicilan (${partialOrders.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderList(paidOrders, isDark),
                _buildOrderList(unpaidOrders, isDark),
                _buildOrderList(partialOrders, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, bool isDark) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesanan dalam kategori ini',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = order.paymentStatus == 'Lunas'
            ? AppColors.success
            : order.paymentStatus == 'Sebagian'
                ? AppColors.warning
                : AppColors.error;

        return GestureDetector(
          onTap: () => _showOrderActions(order, isDark),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Order number + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(order.paymentStatus),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Amount info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          PriceFormatter.format(order.finalAmount),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (order.remainingAmount > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Sisa Bayar',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            PriceFormatter.format(order.remainingAmount),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Detail',
                        Icons.visibility_rounded,
                        AppColors.info,
                        () => _navigateToOrderDetail(order),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (order.paymentStatus != 'Lunas')
                      Expanded(
                        child: _buildActionButton(
                          'Bayar',
                          Icons.payment_rounded,
                          AppColors.success,
                          () => _showPaymentDialog(order),
                        ),
                      ),
                    if (order.paymentStatus != 'Lunas')
                      const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Cetak',
                        Icons.print_rounded,
                        AppColors.accent,
                        () => _showPrintOptions(order),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: index * 30)).fadeIn().slideX(
                begin: 0.05,
                end: 0,
              ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
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
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Lunas':
        return 'LUNAS';
      case 'Sebagian':
      case 'partial':
        return 'CICILAN';
      case 'Belum Bayar':
      case 'unpaid':
        return 'BELUM BAYAR';
      default:
        return status.toUpperCase();
    }
  }

  void _showOrderActions(OrderModel order, bool isDark) {
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
            const SizedBox(height: 20),
            Text(
              order.orderNumber,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildBottomSheetOption(
              'Lihat Detail Order',
              Icons.visibility_rounded,
              AppColors.info,
              () {
                Navigator.pop(context);
                _navigateToOrderDetail(order);
              },
            ),
            if (order.paymentStatus != 'Lunas')
              _buildBottomSheetOption(
                'Bayar Cicilan',
                Icons.payment_rounded,
                AppColors.success,
                () {
                  Navigator.pop(context);
                  _showPaymentDialog(order);
                },
              ),
            _buildBottomSheetOption(
              'Print Nota',
              Icons.receipt_rounded,
              AppColors.accent,
              () {
                Navigator.pop(context);
                _printInvoice(order);
              },
            ),
            _buildBottomSheetOption(
              'Print Surat Jalan',
              Icons.local_shipping_rounded,
              AppColors.warning,
              () {
                Navigator.pop(context);
                _printDeliveryOrder(order);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }

  void _navigateToOrderDetail(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(order: order),
      ),
    );
    _loadData();
  }

  void _showPrintOptions(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
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
            const SizedBox(height: 20),
            Text('Opsi Cetak', style: AppTextStyles.titleMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPrintCard(
                    'Nota / Invoice',
                    Icons.receipt_rounded,
                    AppColors.primary,
                    () {
                      Navigator.pop(context);
                      _printInvoice(order);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrintCard(
                    'Surat Jalan',
                    Icons.local_shipping_rounded,
                    AppColors.accent,
                    () {
                      Navigator.pop(context);
                      _printDeliveryOrder(order);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printInvoice(OrderModel order) async {
    try {
      await DotMatrixPrintService.printInvoice(order, widget.customer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencetak: $e')),
        );
      }
    }
  }

  Future<void> _printDeliveryOrder(OrderModel order) async {
    try {
      await DotMatrixPrintService.printDeliveryOrder(order, widget.customer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencetak: $e')),
        );
      }
    }
  }

  void _showPaymentDialog(OrderModel order) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.payment_rounded, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Text('Bayar Cicilan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa tagihan: ${PriceFormatter.format(order.remainingAmount)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Bayar',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickAmountChip(
                    controller, order.remainingAmount * 0.5, 'Setengah'),
                const SizedBox(width: 8),
                _buildQuickAmountChip(
                    controller, order.remainingAmount, 'Lunas'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _processPayment(order, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(
      TextEditingController controller, double amount, String label) {
    return InkWell(
      onTap: () => controller.text = amount.toStringAsFixed(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(OrderModel order, String amountText) async {
    Navigator.pop(context);

    final amount = double.tryParse(amountText.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    try {
      final orderRepo = OrderRepository();
      await orderRepo.updatePayment(order.id, amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran ${PriceFormatter.format(amount)} berhasil'),
          backgroundColor: AppColors.success,
        ),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _navigateToEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(customer: widget.customer),
      ),
    );
    _loadData(); // Refresh after edit
  }
}
