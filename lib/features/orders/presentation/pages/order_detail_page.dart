import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/document_upload_widget.dart';
import '../../../../core/services/document_image_service.dart';
import '../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../../core/services/dot_matrix_print_service.dart';

/// Order Detail Page with Printing
class OrderDetailPage extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Color statusColor;
    if (order.isPaid) {
      statusColor = Colors.green;
    } else if (order.isPartial) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.orderNumber}'),
        actions: [
          // Print Invoice
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Invoice',
            onPressed: () => _printInvoice(context, ref),
          ),
          // More menu
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delivery_note',
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, size: 18),
                    SizedBox(width: 8),
                    Text('Print Delivery Note'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Pembayaran',
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 18),
                    SizedBox(width: 8),
                    Text('Tambah Pembayaran'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delivery_note') {
                _printDeliveryNote(context, ref);
              } else if (value == 'Pembayaran') {
                _addPayment(context, ref);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Detail Pesanan',
                            style: theme.textTheme.titleMedium),
                        Chip(
                          label: Text(
                            order.paymentStatus.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildDetailRow('Order Number', order.orderNumber),
                    _buildDetailRow(
                        'Tanggal',
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(order.orderDate)),
                    _buildDetailRow('Pelanggan', order.customerName),
                    _buildDetailRow(
                        'Type', order.isWholesale ? 'Grosir' : 'Eceran'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('item', style: theme.textTheme.titleMedium),
                    const Divider(),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    Text(
                                      '${item.quantity} x ${PriceFormatter.format(item.unitPrice)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                PriceFormatter.format(item.subtotal),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Summary', style: theme.textTheme.titleMedium),
                    const Divider(),
                    _buildSummaryRow('Subtotal', order.totalAmount),
                    if (order.discount > 0)
                      _buildSummaryRow('Discount', -order.discount,
                          color: Colors.green),
                    const Divider(),
                    _buildSummaryRow(
                      'Grand Total',
                      order.finalAmount,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Lunas', order.paidAmount,
                        color: Colors.green),
                    if (order.remainingAmount > 0)
                      _buildSummaryRow(
                        'Sisa',
                        order.remainingAmount,
                        color: Colors.red,
                        isBold: true,
                      ),
                  ],
                ),
              ),
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catatan', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(order.notes!),
                    ],
                  ),
                ),
              ),
            ],

            // Document Upload Section
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('Dokumen Pesanan',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Surat Jalan
                    DocumentUploadWidget(
                      orderId: order.id,
                      documentType: DocumentType.deliveryNote,
                      onDocumentChanged: (path) {
                        // Document saved automatically
                      },
                    ),
                    const SizedBox(height: 12),
                    // Nota/Invoice
                    DocumentUploadWidget(
                      orderId: order.id,
                      documentType: DocumentType.invoice,
                      onDocumentChanged: (path) {
                        // Document saved automatically
                      },
                    ),
                    const SizedBox(height: 12),
                    // Bukti Pembayaran
                    DocumentUploadWidget(
                      orderId: order.id,
                      documentType: DocumentType.paymentProof,
                      onDocumentChanged: (path) {
                        // Document saved automatically
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            PriceFormatter.format(amount.abs()),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing invoice...')),
        );
      }

      // Get customer data directly from repository
      final customerRepo = CustomerRepository();
      CustomerModel? customer;

      // First try to get from provider
      final customersAsync = ref.read(customersProvider);
      customersAsync.whenData((customers) {
        final found = customers.where((c) => c.id == order.customerId).toList();
        if (found.isNotEmpty) {
          customer = found.first;
        }
      });

      // If not found in provider, get from repository
      customer ??= await customerRepo.getCustomerById(order.customerId);

      // If still not found, create a dummy customer from order data
      // This handles retail customers that were created during checkout
      if (customer == null) {
        final now = DateTime.now();
        customer = CustomerModel(
          id: order.customerId,
          name: order.customerName,
          phone: '',
          address: '',
          customerType: order.orderType == 'Eceran' ? 'retail' : 'wholesale',
          createdAt: now,
          updatedAt: now,
        );
      }

      // Print invoice
      await DotMatrixPrintService.printInvoice(order, customer!);
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
  }

  Future<void> _printDeliveryNote(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing delivery note...')),
        );
      }

      // Get customer data directly from repository
      final customerRepo = CustomerRepository();
      CustomerModel? customer;

      // First try to get from provider
      final customersAsync = ref.read(customersProvider);
      customersAsync.whenData((customers) {
        final found = customers.where((c) => c.id == order.customerId).toList();
        if (found.isNotEmpty) {
          customer = found.first;
        }
      });

      // If not found in provider, get from repository
      customer ??= await customerRepo.getCustomerById(order.customerId);

      // If still not found, create a dummy customer from order data
      if (customer == null) {
        final now = DateTime.now();
        customer = CustomerModel(
          id: order.customerId,
          name: order.customerName,
          phone: '',
          address: '',
          customerType: order.isWholesale ? 'wholesale' : 'retail',
          createdAt: now,
          updatedAt: now,
        );
      }

      // Print delivery order
      await DotMatrixPrintService.printDeliveryOrder(order, customer!);
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
  }

  Future<void> _addPayment(BuildContext context, WidgetRef ref) async {
    if (order.remainingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order is fully paid')),
      );
      return;
    }

    // Show payment dialog with upload option
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PaymentDialogWithUpload(
        orderId: order.id,
        remainingAmount: order.remainingAmount,
      ),
    );

    if (result != null &&
        result['amount'] != null &&
        result['amount'] > 0 &&
        context.mounted) {
      try {
        await ref
            .read(ordersProvider.notifier)
            .updatePayment(order.id, result['amount']);
        if (context.mounted) {
          Navigator.pop(context); // Go back to list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment updated successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

/// Payment Dialog with Upload functionality
class _PaymentDialogWithUpload extends StatefulWidget {
  final String orderId;
  final double remainingAmount;

  const _PaymentDialogWithUpload({
    required this.orderId,
    required this.remainingAmount,
  });

  @override
  State<_PaymentDialogWithUpload> createState() =>
      _PaymentDialogWithUploadState();
}

class _PaymentDialogWithUploadState extends State<_PaymentDialogWithUpload> {
  final _controller = TextEditingController();
  String? _paymentProofPath;
  bool _showUpload = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Tambah Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa Tagihan: ${PriceFormatter.format(widget.remainingAmount)}',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pembayaran',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                _controller.text = widget.remainingAmount.toInt().toString();
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Bayar Lunas'),
            ),
            const Divider(height: 24),
            // Upload payment proof toggle
            InkWell(
              onTap: () => setState(() => _showUpload = !_showUpload),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _showUpload
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.receipt_long,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upload Bukti Pembayaran (Opsional)',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_paymentProofPath != null)
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                  ],
                ),
              ),
            ),
            // Upload widget
            if (_showUpload) ...[
              const SizedBox(height: 12),
              DocumentUploadWidget(
                orderId: widget.orderId,
                documentType: DocumentType.paymentProof,
                existingPath: _paymentProofPath,
                onDocumentChanged: (path) {
                  setState(() => _paymentProofPath = path);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_controller.text) ?? 0;
            Navigator.pop(context, {
              'amount': value,
              'proofPath': _paymentProofPath,
            });
          },
          child: const Text('Konfirmasi'),
        ),
      ],
    );
  }
}
