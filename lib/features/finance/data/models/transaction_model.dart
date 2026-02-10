/// Financial transaction types
enum TransactionType {
  income, // Sales income
  expense, // Business expenses
  payment, // Customer payment received
  refund, // Refund issued
}

/// Transaction status
enum TransactionStatus {
  pending,
  completed,
  cancelled,
}

/// Financial transaction model
class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final TransactionStatus status;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.orderId,
    this.customerId,
    this.customerName,
    this.status = TransactionStatus.completed,
    this.category,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? description,
    String? orderId,
    String? customerId,
    String? customerName,
    TransactionStatus? status,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'status': status.name,
      'category': category,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.income,
      ),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      orderId: json['order_id'] as String?,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}



