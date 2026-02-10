import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:royal_charir_app/features/categories/data/repositories/category_repository.dart';
import 'package:royal_charir_app/features/categories/domain/entities/category.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getAll();
});
