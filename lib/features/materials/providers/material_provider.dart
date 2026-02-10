import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/material_repository.dart';
import '../domain/entities/material.dart';

/// Material Repository Provider
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository();
});

/// Materials State Notifier
class MaterialsNotifier
    extends StateNotifier<AsyncValue<List<ProductMaterial>>> {
  final MaterialRepository _repository;

  MaterialsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    state = const AsyncValue.loading();
    try {
      final materials = await _repository.getAll(activeOnly: true);
      state = AsyncValue.data(materials);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh materials
  Future<void> refresh() async {
    await _loadMaterials();
  }

  /// Add new material
  Future<void> addMaterial(ProductMaterial material) async {
    try {
      await _repository.create(material);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update material
  Future<void> updateMaterial(ProductMaterial material) async {
    try {
      await _repository.update(material);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete material
  Future<void> deleteMaterial(String id) async {
    try {
      await _repository.delete(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Adjust stock
  Future<void> adjustStock(String id, double adjustment) async {
    try {
      await _repository.adjustStock(id, adjustment);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Materials Provider
final materialsProvider =
    StateNotifierProvider<MaterialsNotifier, AsyncValue<List<ProductMaterial>>>(
  (ref) => MaterialsNotifier(ref.watch(materialRepositoryProvider)),
);

/// Low Stock Materials Provider
final lowStockMaterialsProvider =
    FutureProvider<List<ProductMaterial>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.getLowStock();
});

/// Material Stats Provider
final materialStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);

  final totalMaterials = await repository.getCount();
  final lowStockCount = (await repository.getLowStock()).length;
  final totalValue = await repository.getTotalStockValue();

  return {
    'totalMaterials': totalMaterials,
    'lowStockCount': lowStockCount,
    'totalValue': totalValue,
  };
});
