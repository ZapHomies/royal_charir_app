/// Expense Model untuk tracking pengeluaran
class ExpenseModel {
  final String id;
  final String
      category; // 'bahan', 'karyawan', 'maintenance', 'operasional', 'lainnya'
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? notes;
  final String? receiptPath; // path foto struk
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.notes,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Expense categories
  static const List<String> categories = [
    'bahan',
    'karyawan',
    'maintenance',
    'operasional',
    'lainnya',
  ];

  /// Get category display name
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'bahan':
        return 'Beli Bahan';
      case 'karyawan':
        return 'Gaji Karyawan';
      case 'maintenance':
        return 'Maintenance';
      case 'operasional':
        return 'Operasional';
      case 'lainnya':
        return 'Lainnya';
      default:
        return category;
    }
  }

  /// From database map
  factory ExpenseModel.fromDatabase(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date'] as String),
      notes: map['notes'] as String?,
      receiptPath: map['receipt_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String(),
      'notes': notes,
      'receipt_path': receiptPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  ExpenseModel copyWith({
    String? id,
    String? category,
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? notes,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ExpenseModel(id: $id, category: $category, amount: $amount)';
}


