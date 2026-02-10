import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../inventory/providers/product_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../data/models/order_model.dart';
import '../../providers/order_provider.dart';

/// Cart Item
class CartItem {
  final ProductModel product;
  int quantity;
  double get subtotal => product.price * quantity;

  CartItem({required this.product, this.quantity = 1});
}

/// Order Form Page - Simple Cart System
class OrderFormPage extends ConsumerStatefulWidget {
  final CustomerModel? preselectedCustomer;

  const OrderFormPage({super.key, this.preselectedCustomer});

  @override
  ConsumerState<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends ConsumerState<OrderFormPage> {
  CustomerModel? _selectedCustomer;
  final List<CartItem> _cart = [];
  bool _isLoading = false;

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.preselectedCustomer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Baru'),
        actions: [
          if (_cart.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${_cart.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: _showCartSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          // Customer Selection
          _buildCustomerSection(),
          const Divider(height: 1),
          // Product List
          Expanded(child: _buildProductList()),
        ],
      ),
      bottomNavigationBar: _cart.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Icon(Icons.person_outline),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedCustomer == null
                ? const Text('Pilih Pelanggan')
                : Text(
                    _selectedCustomer!.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
          FilledButton.icon(
            onPressed: _selectCustomer,
            icon: const Icon(Icons.search, size: 18),
            label: Text(_selectedCustomer == null ? 'Pilih' : 'Ubah'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('Tidak ada produk'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = products[index];
            final inCart = _cart.any((item) => item.product.id == product.id);

            return Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(PriceFormatter.format(product.price)),
                trailing: inCart
                    ? Chip(
                        label: Text(
                          '${_cart.firstWhere((i) => i.product.id == product.id).quantity}',
                        ),
                      )
                    : FilledButton(
                        onPressed: product.stock > 0
                            ? () => _addToCart(product)
                            : null,
                        child: const Text('Tambah'),
                      ),
                onTap: inCart ? _showCartSheet : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total (${_cart.length} items)'),
                Text(
                  PriceFormatter.format(_totalAmount),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _isLoading ? null : _checkout,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih pelanggan terlebih dahulu')),
      );
      return;
    }

    setState(() => _cart.add(CartItem(product: product)));
  }

  Future<void> _selectCustomer() async {
    final customersAsync = ref.read(customersProvider);
    final customers = customersAsync.valueOrNull ?? [];

    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No customers found. Add customers first.')),
      );
      return;
    }

    final selected = await showDialog<CustomerModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Pelanggan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading:
                    Icon(customer.isWholesale ? Icons.business : Icons.person),
                title: Text(customer.name),
                subtitle: Text(customer.isWholesale ? 'Grosir' : 'Eceran'),
                onTap: () => Navigator.pop(context, customer),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedCustomer = selected);
    }
  }

  Future<void> _showCartSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cart (${_cart.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Items
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          title: Text(item.product.name),
                          subtitle:
                              Text(PriceFormatter.format(item.product.price)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: item.quantity > 1
                                    ? () {
                                        setState(() => item.quantity--);
                                        setModalState(() {});
                                      }
                                    : null,
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: item.quantity < item.product.stock
                                    ? () {
                                        setState(() => item.quantity++);
                                        setModalState(() {});
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: AppColors.error),
                                onPressed: () {
                                  setState(() => _cart.removeAt(index));
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18)),
                        Text(
                          PriceFormatter.format(_totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _checkout() async {
    if (_selectedCustomer == null || _cart.isEmpty) return;

    // Payment dialog
    final paid = await showDialog<double>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: ${PriceFormatter.format(_totalAmount)}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Dibayar',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.text = _totalAmount.toInt().toString();
                      },
                      child: const Text('Lunas'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.text = '0';
                      },
                      child: const Text('Belum Bayar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;
                Navigator.pop(context, amount);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (paid == null) return;

    setState(() => _isLoading = true);

    try {
      final remaining = (_totalAmount - paid).clamp(0.0, _totalAmount);
      final order = OrderModel(
        id: '',
        orderNumber: '',
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        orderType: _selectedCustomer!.customerType,
        orderDate: DateTime.now(),
        totalAmount: _totalAmount,
        finalAmount: _totalAmount,
        paymentStatus: paid >= _totalAmount
            ? 'Lunas'
            : paid > 0
                ? 'Sebagian'
                : 'Belum Bayar',
        paidAmount: paid,
        remainingAmount: remaining,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final items = _cart
          .map((item) => OrderItemModel(
                id: '',
                orderId: '',
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                unitPrice: item.product.price,
                subtotal: item.subtotal,
              ))
          .toList();

      await ref.read(ordersProvider.notifier).createOrder(order, items);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
