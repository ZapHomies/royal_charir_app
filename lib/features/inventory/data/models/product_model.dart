/// ProductModel - Aligned with Laravel (Enhanced with minStock and unit)
class ProductModel {
  final String id;
  final String name;
  final String category;
  final String? description;
  final double price;
  final double wholesalePrice;
  final int stock;
  final int minStock;
  final String unit;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    double? wholesalePrice,
    this.stock = 0,
    this.minStock = 10,
    this.unit = 'pcs',
    this.imagePath,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  }) : wholesalePrice = wholesalePrice ?? price;

  /// Convert from database map
  factory ProductModel.fromDatabase(Map<String, dynamic> map) {
    final price = (map['price'] as num).toDouble();
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      price: price,
      wholesalePrice: (map['wholesale_price'] as num?)?.toDouble() ?? price,
      stock: map['stock'] as int,
      minStock: map['min_stock'] as int? ?? 10,
      unit: map['unit'] as String? ?? 'pcs',
      imagePath: map['image_path'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'wholesale_price': wholesalePrice,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For API/Sync (match Laravel format exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'image': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// From API/Sync response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      minStock: json['min_stock'] as int? ?? 10,
      unit: json['unit'] as String? ?? 'pcs',
      imagePath: json['image'] as String?,
      isActive: true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Copy with
  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    double? wholesalePrice,
    int? stock,
    int? minStock,
    String? unit,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Is out of stock
  bool get isOutOfStock => stock <= 0;

  /// Is low stock (less than minStock)
  bool get isLowStock => stock > 0 && stock < minStock;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, price: $price, stock: $stock)';
}
