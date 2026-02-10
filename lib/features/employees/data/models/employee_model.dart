import 'package:uuid/uuid.dart';

/// Employee Model - Model untuk data karyawan
class EmployeeModel {
  final String id;
  final String employeeCode; // Kode karyawan: EMP001, EMP002, dll
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String position; // Jabatan: manager, staff, warehouse, driver, etc
  final String department; // Divisi: production, sales, warehouse, admin
  final double dailySalary; // Gaji per-hari
  final double dailyTransport; // Tunjangan transport per-hari
  final double dailyMeal; // Tunjangan makan per-hari
  final double dailyOther; // Tunjangan lain per-hari
  final DateTime? lastSalaryTaken; // Tanggal terakhir ambil gaji
  final DateTime joinDate; // Tanggal bergabung
  final DateTime? birthDate; // Tanggal lahir
  final String? identityNumber; // NIK/KTP
  final String? bankAccount; // Nomor rekening
  final String? bankName; // Nama bank
  final String? emergencyContact; // Kontak darurat
  final String? emergencyPhone; // Telepon darurat
  final String? photoPath; // Foto karyawan
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.position,
    required this.department,
    required this.dailySalary,
    this.dailyTransport = 0,
    this.dailyMeal = 0,
    this.dailyOther = 0,
    this.lastSalaryTaken,
    required this.joinDate,
    this.birthDate,
    this.identityNumber,
    this.bankAccount,
    this.bankName,
    this.emergencyContact,
    this.emergencyPhone,
    this.photoPath,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total gaji harian (gaji + semua tunjangan per hari)
  double get totalDailySalary =>
      dailySalary + dailyTransport + dailyMeal + dailyOther;

  /// Perkiraan gaji bulanan (26 hari kerja)
  double get estimatedMonthlySalary => totalDailySalary * 26;

  /// Factory untuk membuat employee baru
  factory EmployeeModel.create({
    required String employeeCode,
    required String name,
    String? phone,
    String? email,
    String? address,
    required String position,
    required String department,
    required double dailySalary,
    double dailyTransport = 0,
    double dailyMeal = 0,
    double dailyOther = 0,
    required DateTime joinDate,
    DateTime? birthDate,
    String? identityNumber,
    String? bankAccount,
    String? bankName,
    String? emergencyContact,
    String? emergencyPhone,
    String? photoPath,
    String? notes,
  }) {
    final now = DateTime.now();
    return EmployeeModel(
      id: const Uuid().v4(),
      employeeCode: employeeCode,
      name: name,
      phone: phone,
      email: email,
      address: address,
      position: position,
      department: department,
      dailySalary: dailySalary,
      dailyTransport: dailyTransport,
      dailyMeal: dailyMeal,
      dailyOther: dailyOther,
      lastSalaryTaken: null,
      joinDate: joinDate,
      birthDate: birthDate,
      identityNumber: identityNumber,
      bankAccount: bankAccount,
      bankName: bankName,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      photoPath: photoPath,
      notes: notes,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// From database map
  factory EmployeeModel.fromDatabase(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as String,
      employeeCode: map['employee_code'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      position: map['position'] as String,
      department: map['department'] as String,
      dailySalary: (map['daily_salary'] as num?)?.toDouble() ??
          (map['base_salary'] as num?)?.toDouble() ??
          0,
      dailyTransport: (map['daily_transport'] as num?)?.toDouble() ?? 0,
      dailyMeal: (map['daily_meal'] as num?)?.toDouble() ?? 0,
      dailyOther: (map['daily_other'] as num?)?.toDouble() ?? 0,
      lastSalaryTaken: map['last_salary_taken'] != null
          ? DateTime.parse(map['last_salary_taken'] as String)
          : null,
      joinDate: DateTime.parse(map['join_date'] as String),
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      identityNumber: map['identity_number'] as String?,
      bankAccount: map['bank_account'] as String?,
      bankName: map['bank_name'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
      emergencyPhone: map['emergency_phone'] as String?,
      photoPath: map['photo_path'] as String?,
      notes: map['notes'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'position': position,
      'department': department,
      'daily_salary': dailySalary,
      'daily_transport': dailyTransport,
      'daily_meal': dailyMeal,
      'daily_other': dailyOther,
      'last_salary_taken': lastSalaryTaken?.toIso8601String(),
      'join_date': joinDate.toIso8601String(),
      'birth_date': birthDate?.toIso8601String(),
      'identity_number': identityNumber,
      'bank_account': bankAccount,
      'bank_name': bankName,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'photo_path': photoPath,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? position,
    String? department,
    double? dailySalary,
    double? dailyTransport,
    double? dailyMeal,
    double? dailyOther,
    DateTime? lastSalaryTaken,
    DateTime? joinDate,
    DateTime? birthDate,
    String? identityNumber,
    String? bankAccount,
    String? bankName,
    String? emergencyContact,
    String? emergencyPhone,
    String? photoPath,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      position: position ?? this.position,
      department: department ?? this.department,
      dailySalary: dailySalary ?? this.dailySalary,
      dailyTransport: dailyTransport ?? this.dailyTransport,
      dailyMeal: dailyMeal ?? this.dailyMeal,
      dailyOther: dailyOther ?? this.dailyOther,
      lastSalaryTaken: lastSalaryTaken ?? this.lastSalaryTaken,
      joinDate: joinDate ?? this.joinDate,
      birthDate: birthDate ?? this.birthDate,
      identityNumber: identityNumber ?? this.identityNumber,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Hitung lama bekerja
  Duration get workDuration => DateTime.now().difference(joinDate);

  /// Lama bekerja dalam tahun
  int get yearsOfService => workDuration.inDays ~/ 365;

  /// Lama bekerja dalam bulan
  int get monthsOfService => workDuration.inDays ~/ 30;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EmployeeModel(id: $id, code: $employeeCode, name: $name, position: $position)';
}

/// Daftar jabatan karyawan
class EmployeePositions {
  static const String manager = 'Manager';
  static const String supervisor = 'Supervisor';
  static const String staff = 'Staff';
  static const String warehouse = 'Gudang';
  static const String driver = 'Driver';
  static const String production = 'Produksi';
  static const String sales = 'Sales';
  static const String admin = 'Admin';
  static const String security = 'Security';
  static const String cleaning = 'Cleaning Service';

  static List<String> get all => [
        manager,
        supervisor,
        staff,
        warehouse,
        driver,
        production,
        sales,
        admin,
        security,
        cleaning,
      ];
}

/// Daftar departemen
class EmployeeDepartments {
  static const String production = 'Produksi';
  static const String warehouse = 'Gudang';
  static const String sales = 'Penjualan';
  static const String admin = 'Administrasi';
  static const String finance = 'Keuangan';
  static const String general = 'Umum';

  static List<String> get all => [
        production,
        warehouse,
        sales,
        admin,
        finance,
        general,
      ];
}



