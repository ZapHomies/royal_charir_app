class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'admin', 'staff', 'cashier', 'retail', 'wholesale'
  final bool isActive;
  final String?
      password; // Only for local storage/auth, not synced back to Laravel usually
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  // Database Mapping
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String,
      isActive: (map['is_active'] as int) == 1,
      password: map['password'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // API Mapping (Laravel Sync)
  Map<String, dynamic> toJson() {
    return {
      'uuid': id, // Laravel uses uuid
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      // Password not synced by default for security
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uuid'] as String? ??
          json['id'].toString(), // Handle both uuid and id
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'retail',
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == 1),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers
  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isCashier => role == 'cashier';
}
