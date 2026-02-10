/// Customer Model
class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final String customerType; // 'wholesale' or 'retail'
  final String? notes;
  final double totalDebt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    required this.customerType,
    this.notes,
    this.totalDebt = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From database map
  factory CustomerModel.fromDatabase(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      email: map['email'] as String?,
      customerType: map['customer_type'] as String,
      notes: map['notes'] as String?,
      totalDebt: (map['total_debt'] as num?)?.toDouble() ?? 0.0,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'customer_type': customerType,
      'notes': notes,
      'total_debt': totalDebt,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    String? customerType,
    String? notes,
    double? totalDebt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      customerType: customerType ?? this.customerType,
      notes: notes ?? this.notes,
      totalDebt: totalDebt ?? this.totalDebt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Has debt
  bool get hasDebt => totalDebt > 0;

  /// Is wholesale customer
  bool get isWholesale => customerType == 'wholesale';

  /// Is retail customer
  bool get isRetail => customerType == 'retail';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomerModel(id: $id, name: $name, type: $customerType)';
}
