/// Order Item Model
class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromDatabase(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

/// Order Model
class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String orderType; // 'wholesale' or 'retail'
  final DateTime orderDate;
  final double totalAmount;
  final double discount;
  final double finalAmount;
  final String paymentStatus; // 'paid', 'unpaid', 'partial'
  final double paidAmount;
  final double remainingAmount;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.orderType,
    required this.orderDate,
    required this.totalAmount,
    this.discount = 0.0,
    required this.finalAmount,
    required this.paymentStatus,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    this.notes,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromDatabase(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      customerId: map['customer_id'] as String,
      customerName: map['customer_name'] as String,
      orderType: map['order_type'] as String,
      orderDate: DateTime.parse(map['order_date'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map['final_amount'] as num).toDouble(),
      paymentStatus: map['payment_status'] as String,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_type': orderType,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'discount': discount,
      'final_amount': finalAmount,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? orderType,
    DateTime? orderDate,
    double? totalAmount,
    double? discount,
    double? finalAmount,
    String? paymentStatus,
    double? paidAmount,
    double? remainingAmount,
    String? notes,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderType: orderType ?? this.orderType,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Payment status helpers - Using Indonesian values consistent with database
  bool get isPaid => paymentStatus == 'Lunas';
  bool get isUnpaid =>
      paymentStatus == 'Belum Bayar' || paymentStatus == 'unpaid';
  bool get isPartial =>
      paymentStatus == 'Sebagian' || paymentStatus == 'partial';
  bool get isWholesale => orderType == 'wholesale';
  bool get isRetail => orderType == 'retail';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
