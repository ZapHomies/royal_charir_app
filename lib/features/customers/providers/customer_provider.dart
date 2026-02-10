import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/customer_model.dart';
import '../data/repositories/customer_repository.dart';

/// Customer Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

/// Customers State Notifier (Wholesale Only)
class CustomersNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final CustomerRepository _repository;

  CustomersNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final customers = await _repository.getAllCustomers(activeOnly: true);
      // Filter to wholesale customers only
      final wholesaleCustomers =
          customers.where((c) => c.customerType == 'Grosir').toList();
      state = AsyncValue.data(wholesaleCustomers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _repository.createCustomer(customer);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Customers Provider
final customersProvider =
    StateNotifierProvider<CustomersNotifier, AsyncValue<List<CustomerModel>>>(
  (ref) => CustomersNotifier(ref.watch(customerRepositoryProvider)),
);

/// Customers with Debt Provider
final customersWithDebtProvider =
    FutureProvider<List<CustomerModel>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomersWithDebt();
});

/// Customer Stats Provider
final customerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);

  final totalCustomers = await repository.getCustomerCount();
  final totalDebt = await repository.getTotalDebt();
  final customersWithDebt = (await repository.getCustomersWithDebt()).length;

  return {
    'totalCustomers': totalCustomers,
    'totalDebt': totalDebt,
    'customersWithDebt': customersWithDebt,
  };
});

/// Selected Customer Type Filter
final selectedCustomerTypeProvider = StateProvider<String?>((ref) => null);

