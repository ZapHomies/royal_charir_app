import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/wholesale_price.dart';
import '../../providers/customer_provider.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../inventory/providers/product_provider.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  final CustomerModel? customer;

  const CustomerFormPage({super.key, this.customer});

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // Menu pelanggan hanya untuk pelanggan grosir
  String _customerType = 'Grosir';
  bool _isLoading = false;

  // Wholesale Prices
  List<WholesalePrice> _wholesalePrices = [];
  bool _isLoadingPrices = false;
  final _uuid = const Uuid();
  late String _customerId;

  @override
  void initState() {
    super.initState();
    _customerId = widget.customer?.id ?? _uuid.v4();

    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _notesController.text = widget.customer!.notes ?? '';
      _customerType = widget.customer!.customerType;
      _loadWholesalePrices();
    }
  }

  Future<void> _loadWholesalePrices() async {
    setState(() => _isLoadingPrices = true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final prices = await repo.getWholesalePrices(_customerId);
      if (mounted) {
        setState(() {
          _wholesalePrices = prices;
        });
      }
    } catch (e) {
      debugPrint('Error loading prices: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPrices = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama Pelanggan
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama pelanggan harus diisi';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Customer Type - Menu pelanggan dikhususkan untuk grosir
            // Tipe customer sudah diset sebagai Grosir secara default
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.store_rounded, color: AppColors.accent, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipe Pelanggan',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text('Grosir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accent,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telepon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Wholesale Prices Section
            if (_customerType == 'Grosir') ...[
              const Divider(),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga Khusus',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _showAddPriceDialog,
                    tooltip: 'Tambah Harga',
                  ),
                ],
              ),
              const Gap(8),
              if (_isLoadingPrices)
                const Center(child: CircularProgressIndicator())
              else if (_wholesalePrices.isEmpty)
                const Text('Belum ada harga khusus.',
                    style: TextStyle(color: Colors.grey))
              else
                ..._wholesalePrices.map((wp) {
                  final productsAsync = ref.watch(productsProvider);
                  final product = productsAsync.asData?.value
                      .firstWhere((p) => p.id == wp.productId,
                          orElse: () => ProductModel(
                                id: '',
                                name: 'Produk Tidak Dikenal',
                                category: '',
                                price: 0,
                                stock: 0,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                isActive: true,
                              ));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(product?.name ?? 'Produk Tidak Dikenal'),
                      subtitle: Text('Harga Khusus: Rp ${wp.price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _wholesalePrices.remove(wp);
                          });
                        },
                      ),
                    ),
                  );
                }),
              const Gap(24),
            ],

            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _saveCustomer,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Perbarui Pelanggan' : 'Tambah Pelanggan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPriceDialog() async {
    final productsAsync = ref.read(productsProvider);
    if (!productsAsync.hasValue) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Produk belum dimuat')));
      return;
    }

    final products = productsAsync.value!;
    ProductModel? selectedProduct;
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Harga Khusus'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductModel>(
                decoration: const InputDecoration(labelText: 'Produk'),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (val) => setState(() => selectedProduct = val),
              ),
              const Gap(16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                    labelText: 'Harga', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (selectedProduct != null && priceController.text.isNotEmpty) {
                final price = double.tryParse(priceController.text) ?? 0;
                // Check if already exists
                final exists = _wholesalePrices
                    .any((wp) => wp.productId == selectedProduct!.id);
                if (exists) {
                  setState(() {
                    _wholesalePrices.removeWhere(
                        (wp) => wp.productId == selectedProduct!.id);
                  });
                }

                final wp = WholesalePrice(
                  id: const Uuid().v4(),
                  customerId: _customerId,
                  productId: selectedProduct!.id,
                  price: price,
                );
                setState(() {
                  _wholesalePrices.add(wp);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customer = CustomerModel(
        id: _customerId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        customerType: _customerType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        totalDebt: widget.customer?.totalDebt ?? 0.0,
        isActive: widget.customer?.isActive ?? true,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.customer == null) {
        await ref.read(customersProvider.notifier).addCustomer(customer);
      } else {
        await ref.read(customersProvider.notifier).updateCustomer(customer);
      }

      // Save Wholesale Prices
      if (_customerType == 'Grosir') {
        final repo = ref.read(customerRepositoryProvider);
        await repo.deleteWholesalePricesByCustomerId(_customerId);
        for (final wp in _wholesalePrices) {
          await repo.saveWholesalePrice(wp);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.customer == null
                  ? 'Pelanggan berhasil ditambahkan'
                  : 'Pelanggan berhasil diperbarui',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
