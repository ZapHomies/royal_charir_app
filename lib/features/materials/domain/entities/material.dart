/// Material Entity - Bahan untuk pembuatan produk (kain, silicon, spon, dll)
class ProductMaterial {
  final String id;
  final String name;
  final String? description;
  final String unit; // meter, kg, pcs, lembar, dll
  final double stock;
  final double minStock;
  final double pricePerUnit;
  final String? supplier;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMaterial({
    required this.id,
    required this.name,
    this.description,
    this.unit = 'pcs',
    this.stock = 0,
    this.minStock = 10,
    this.pricePerUnit = 0,
    this.supplier,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
      'stock': stock,
      'min_stock': minStock,
      'price_per_unit': pricePerUnit,
      'supplier': supplier,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductMaterial.fromMap(Map<String, dynamic> map) {
    return ProductMaterial(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      unit: map['unit'] as String? ?? 'pcs',
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      minStock: (map['min_stock'] as num?)?.toDouble() ?? 10,
      pricePerUnit: (map['price_per_unit'] as num?)?.toDouble() ?? 0,
      supplier: map['supplier'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ProductMaterial copyWith({
    String? id,
    String? name,
    String? description,
    String? unit,
    double? stock,
    double? minStock,
    double? pricePerUnit,
    String? supplier,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      supplier: supplier ?? this.supplier,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
