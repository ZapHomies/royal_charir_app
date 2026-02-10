import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium/premium_widgets.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/services/document_image_service.dart';
import '../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_detail_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Premium Order List Page
class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersProvider);
    final selectedStatus = ref.watch(selectedPaymentStatusProvider);
    final globalSearchQuery = ref.watch(globalSearchQueryProvider);

    return Column(
      children: [
        // Status Filter
        _buildStatusFilter(context, ref, selectedStatus, isDark),

        // Order List
        Expanded(
          child: ordersAsync.when(
            data: (orders) => _buildOrderList(
              context,
              ref,
              orders,
              selectedStatus,
              globalSearchQuery,
              isDark,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorState(context, ref, error),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(
    BuildContext context,
    WidgetRef ref,
    String? selectedStatus,
    bool isDark,
  ) {
    final viewMode = ref.watch(orderViewModeProvider);

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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip(
                            context, ref, 'All', null, selectedStatus, isDark),
                        _buildStatusChip(context, ref, 'Lunas', 'Lunas',
                            selectedStatus, isDark,
                            color: AppColors.success,
                            icon: Icons.check_circle_rounded),
                        _buildStatusChip(context, ref, 'Belum Bayar',
                            'Belum Bayar', selectedStatus, isDark,
                            color: AppColors.error, icon: Icons.cancel_rounded),
                        _buildStatusChip(context, ref, 'Sebagian', 'Sebagian',
                            selectedStatus, isDark,
                            color: AppColors.warning,
                            icon: Icons.pending_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ViewModeToggle(
                  currentMode: viewMode,
                  onModeChanged: (mode) {
                    ref.read(orderViewModeProvider.notifier).state = mode;
                  },
                  availableModes: const [ViewMode.list, ViewMode.compact],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatusChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String? value,
    String? selectedValue,
    bool isDark, {
    Color? color,
    IconData? icon,
  }) {
    final isSelected = value == selectedValue;
    final chipColor = color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(selectedPaymentStatusProvider.notifier).state =
                isSelected ? null : value;
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [chipColor, chipColor.withValues(alpha: 0.8)],
                    )
                  : null,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    WidgetRef ref,
    List<OrderModel> orders,
    String? selectedStatus,
    String globalSearchQuery,
    bool isDark,
  ) {
    final viewMode = ref.watch(orderViewModeProvider);

    // Filter by search query
    var filtered = globalSearchQuery.isEmpty
        ? orders
        : orders.where((o) {
            final query = globalSearchQuery.toLowerCase();
            return o.orderNumber.toLowerCase().contains(query) ||
                o.customerName.toLowerCase().contains(query);
          }).toList();

    // Filter by payment status
    filtered = selectedStatus == null
        ? filtered
        : filtered.where((o) => o.paymentStatus == selectedStatus).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(globalSearchQuery, isDark);
    }

    // Compact view
    if (viewMode == ViewMode.compact) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildOrderCompactCard(
              context, filtered[index], index, isDark);
        },
      );
    }

    // List view (default)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, filtered[index], index, isDark);
      },
    );
  }

  Widget _buildOrderCompactCard(
    BuildContext context,
    OrderModel order,
    int index,
    bool isDark,
  ) {
    Color statusColor;
    if (order.isPaid) {
      statusColor = AppColors.success;
    } else if (order.isPartial) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.error;
    }

    final dateFormat = DateFormat('dd/MM HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Order info
                Expanded(
                  child: Row(
                    children: [
                      // Order number & customer
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              order.customerName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Date
                      Text(
                        dateFormat.format(order.orderDate),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Amount
                      Text(
                        PriceFormatter.formatCompact(order.finalAmount),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    int index,
    bool isDark,
  ) {
    Color statusColor;
    IconData statusIcon;

    if (order.isPaid) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (order.isPartial) {
      statusColor = AppColors.warning;
      statusIcon = Icons.pending_rounded;
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
    }

    final typeColor = order.isWholesale ? AppColors.accent : AppColors.info;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      animationDelay: Duration(milliseconds: index * 50),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
      },
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              // Order icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withValues(alpha: 0.2),
                      typeColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.orderNumber,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                            order.isWholesale ? 'Grosir' : 'Eceran',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Document indicator
                        _DocumentIndicator(orderId: order.id),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerName,
                      style: AppTextStyles.bodySmall.copyWith(
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
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          order.paymentStatus.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yy, HH:mm').format(order.orderDate),
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

          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer row - Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Jumlah',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    PriceFormatter.format(order.finalAmount),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
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
                      'Sisa',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      PriceFormatter.format(order.remainingAmount),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
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
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isEmpty
                  ? Icons.receipt_long_outlined
                  : Icons.search_off_rounded,
              size: 48,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty ? 'No orders yet' : 'No results found',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Your orders will appear here'
                : 'Try a different search term',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
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
          Text('Error loading orders', style: AppTextStyles.titleMedium),
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
            onPressed: () => ref.invalidate(ordersProvider),
          ),
        ],
      ),
    );
  }
}

/// Widget to show document upload indicators for an order
class _DocumentIndicator extends StatefulWidget {
  final String orderId;

  const _DocumentIndicator({required this.orderId});

  @override
  State<_DocumentIndicator> createState() => _DocumentIndicatorState();
}

class _DocumentIndicatorState extends State<_DocumentIndicator> {
  bool _hasDeliveryNote = false;
  bool _hasInvoice = false;
  bool _hasPaymentProof = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentStatus();
  }

  Future<void> _loadDocumentStatus() async {
    final docs =
        await DocumentImageService.instance.getOrderDocuments(widget.orderId);
    if (mounted) {
      setState(() {
        _hasDeliveryNote = docs.any((d) => d.type == DocumentType.deliveryNote);
        _hasInvoice = docs.any((d) => d.type == DocumentType.invoice);
        _hasPaymentProof = docs.any((d) => d.type == DocumentType.paymentProof);
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox.shrink();
    if (!_hasDeliveryNote && !_hasInvoice && !_hasPaymentProof) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasDeliveryNote)
          Tooltip(
            message: 'Surat Jalan',
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 12,
                color: AppColors.info,
              ),
            ),
          ),
        if (_hasInvoice)
          Tooltip(
            message: 'Nota',
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 12,
                color: AppColors.warning,
              ),
            ),
          ),
        if (_hasPaymentProof)
          Tooltip(
            message: 'Bukti Bayar',
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.payment_rounded,
                size: 12,
                color: AppColors.success,
              ),
            ),
          ),
      ],
    );
  }
}
