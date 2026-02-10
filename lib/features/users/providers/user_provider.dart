import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final usersProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});

class UserNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.getAllUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      await _repository.addUser(user);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _repository.updateUser(user);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _repository.deleteUser(id);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }
}
