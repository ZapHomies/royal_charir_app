class WholesalePrice {
  final String id;
  final String customerId;
  final String productId;
  final double price;

  WholesalePrice({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'product_id': productId,
      'price': price,
    };
  }

  factory WholesalePrice.fromMap(Map<String, dynamic> map) {
    return WholesalePrice(
      id: map['id'],
      customerId: map['customer_id'],
      productId: map['product_id'],
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}


