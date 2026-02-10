/// Stock Opname Item Model
class StockOpnameItemModel {
  final String id;
  final String opnameId;
  final String productId;
  final String productName;
  final int systemStock;
  final int physicalStock;
  final int difference;
  final String? notes;

  const StockOpnameItemModel({
    required this.id,
    required this.opnameId,
    required this.productId,
    required this.productName,
    required this.systemStock,
    required this.physicalStock,
    required this.difference,
    this.notes,
  });

  factory StockOpnameItemModel.fromDatabase(Map<String, dynamic> map) {
    return StockOpnameItemModel(
      id: map['id'] as String,
      opnameId: map['opname_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      systemStock: map['system_stock'] as int,
      physicalStock: map['physical_stock'] as int,
      difference: map['difference'] as int,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'opname_id': opnameId,
      'product_id': productId,
      'product_name': productName,
      'system_stock': systemStock,
      'physical_stock': physicalStock,
      'difference': difference,
      'notes': notes,
    };
  }

  bool get hasDiscrepancy => difference != 0;
  bool get isOverage => difference > 0;
  bool get isShortage => difference < 0;
}

/// Stock Opname Model
class StockOpnameModel {
  final String id;
  final String opnameNumber;
  final DateTime opnameDate;
  final String status; // 'draft', 'completed'
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final List<StockOpnameItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockOpnameModel({
    required this.id,
    required this.opnameNumber,
    required this.opnameDate,
    required this.status,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockOpnameModel.fromDatabase(Map<String, dynamic> map) {
    return StockOpnameModel(
      id: map['id'] as String,
      opnameNumber: map['opname_number'] as String,
      opnameDate: DateTime.parse(map['opname_date'] as String),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'opname_number': opnameNumber,
      'opname_date': opnameDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StockOpnameModel copyWith({
    String? id,
    String? opnameNumber,
    DateTime? opnameDate,
    String? status,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    List<StockOpnameItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockOpnameModel(
      id: id ?? this.id,
      opnameNumber: opnameNumber ?? this.opnameNumber,
      opnameDate: opnameDate ?? this.opnameDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDraft => status == 'draft';
  bool get isCompleted => status == 'completed';
  int get totalDiscrepancies => items.where((i) => i.hasDiscrepancy).length;
}
