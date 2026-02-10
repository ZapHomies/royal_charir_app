import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';

/// Expense Repository Provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

/// All Expenses Provider
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>(
        (ref) {
  return ExpensesNotifier(ref.read(expenseRepositoryProvider));
});

/// Expenses Notifier
class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;

  String? _categoryFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final expenses = await _repository.getAllExpenses(
        category: _categoryFilter,
        startDate: _startDate,
        endDate: _endDate,
      );
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadExpenses();
  }

  void setFilter({String? category, DateTime? startDate, DateTime? endDate}) {
    _categoryFilter = category;
    _startDate = startDate;
    _endDate = endDate;
    _loadExpenses();
  }

  void clearFilter() {
    _categoryFilter = null;
    _startDate = null;
    _endDate = null;
    _loadExpenses();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.createExpense(expense);
      await _loadExpenses();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      await _loadExpenses();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await _loadExpenses();
    } catch (e) {
      rethrow;
    }
  }
}

/// Total Expenses Provider
final totalExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return repository.getTotalExpenses();
});

/// Today's Expenses Provider
final todayExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return repository.getTodayExpenses();
});

/// Month Expenses Provider
final monthExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return repository.getMonthExpenses();
});

/// Expenses by Category Provider
final expensesByCategoryProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return repository.getExpensesByCategory();
});

/// Selected Expense Category Filter
final selectedExpenseCategoryProvider = StateProvider<String?>((ref) => null);
