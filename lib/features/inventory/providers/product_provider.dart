import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Products State Notifier
class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductRepository _repository;

  ProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getAllProducts(activeOnly: true);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh products
  Future<void> refresh() async {
    await _loadProducts();
  }

  /// Add new product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update stock (set absolute value)
  Future<void> updateStock(String id, int newStock) async {
    try {
      await _repository.updateStock(id, newStock);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Adjust stock (add or subtract delta)
  Future<void> adjustStock(String id, int adjustment) async {
    try {
      await _repository.adjustStock(id, adjustment);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Products Provider
final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>(
  (ref) => ProductsNotifier(ref.watch(productRepositoryProvider)),
);

/// Low Stock Products Provider
final lowStockProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLowStockProducts();
});

/// Product Categories Provider
final productCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getAllCategories();
});

/// Selected Category Filter Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Products by Category Provider
final productsByCategoryProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final repository = ref.watch(productRepositoryProvider);

  if (category == null || category.isEmpty) {
    return repository.getAllProducts(activeOnly: true);
  }

  return repository.getAllProducts(activeOnly: true, category: category);
});

/// Product Stats Provider
final productStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  final totalProducts = await repository.getProductCount();
  final lowStockCount = (await repository.getLowStockProducts()).length;
  final totalValue = await repository.getTotalStockValue();

  return {
    'totalProducts': totalProducts,
    'lowStockCount': lowStockCount,
    'totalValue': totalValue,
  };
});
