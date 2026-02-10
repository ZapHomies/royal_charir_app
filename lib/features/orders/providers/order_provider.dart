import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/order_model.dart';
import '../data/repositories/order_repository.dart';

/// Order Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Orders State Notifier
class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderRepository _repository;

  OrdersNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getAllOrders();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadOrders();
  }

  Future<void> createOrder(OrderModel order, List<OrderItemModel> items) async {
    try {
      await _repository.createOrder(order, items);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePayment(String orderId, double amount) async {
    try {
      await _repository.updatePayment(orderId, amount);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Orders Provider
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>(
  (ref) => OrdersNotifier(ref.watch(orderRepositoryProvider)),
);

/// Today's Orders Provider
final todayOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getTodayOrders();
});

/// Unpaid Orders Provider
final unpaidOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getAllOrders(paymentStatus: 'Belum Bayar');
});

/// Order Stats Provider
final orderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);

  final totalOrders = await repository.getOrderCount();
  final todayOrders = await repository.getTodayOrders();
  final todayRevenue = await repository.getTotalRevenue(
    startDate: DateTime.now().subtract(const Duration(days: 1)),
  );

  return {
    'totalOrders': totalOrders,
    'todayOrders': todayOrders.length,
    'todayRevenue': todayRevenue,
  };
});

/// Selected Payment Status Filter
final selectedPaymentStatusProvider = StateProvider<String?>((ref) => null);
