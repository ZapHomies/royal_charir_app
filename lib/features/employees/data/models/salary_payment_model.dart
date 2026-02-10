import 'package:uuid/uuid.dart';

/// Model untuk pembayaran/pengambilan gaji karyawan
class SalaryPaymentModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeCode;
  final DateTime paymentDate;
  final DateTime periodStart; // Awal periode gaji yang dibayar
  final DateTime periodEnd; // Akhir periode gaji yang dibayar
  final int paidDays; // Jumlah hari yang dibayar
  final double dailyRate; // Gaji per hari
  final double baseSalaryEarned; // Gaji pokok yang diperoleh
  final double overtimePay; // Uang lembur
  final double latePenalty; // Potongan telat
  final double otherDeduction; // Potongan lain
  final double totalAmount; // Total yang dibayar
  final String? notes;
  final PaymentType type; // Full atau kasbon
  final String? paidBy; // Dibayar oleh
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalaryPaymentModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.paymentDate,
    required this.periodStart,
    required this.periodEnd,
    required this.paidDays,
    required this.dailyRate,
    required this.baseSalaryEarned,
    this.overtimePay = 0,
    this.latePenalty = 0,
    this.otherDeduction = 0,
    required this.totalAmount,
    this.notes,
    required this.type,
    this.paidBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create new payment
  factory SalaryPaymentModel.create({
    required String employeeId,
    required String employeeName,
    required String employeeCode,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int paidDays,
    required double dailyRate,
    required double baseSalaryEarned,
    double overtimePay = 0,
    double latePenalty = 0,
    double otherDeduction = 0,
    String? notes,
    required PaymentType type,
    String? paidBy,
  }) {
    final now = DateTime.now();
    final total = baseSalaryEarned + overtimePay - latePenalty - otherDeduction;
    return SalaryPaymentModel(
      id: const Uuid().v4(),
      employeeId: employeeId,
      employeeName: employeeName,
      employeeCode: employeeCode,
      paymentDate: now,
      periodStart: periodStart,
      periodEnd: periodEnd,
      paidDays: paidDays,
      dailyRate: dailyRate,
      baseSalaryEarned: baseSalaryEarned,
      overtimePay: overtimePay,
      latePenalty: latePenalty,
      otherDeduction: otherDeduction,
      totalAmount: total,
      notes: notes,
      type: type,
      paidBy: paidBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// From database
  factory SalaryPaymentModel.fromDatabase(Map<String, dynamic> map) {
    return SalaryPaymentModel(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      employeeCode: map['employee_code'] as String,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: DateTime.parse(map['period_end'] as String),
      paidDays: (map['paid_days'] as num).toInt(),
      dailyRate: (map['daily_rate'] as num).toDouble(),
      baseSalaryEarned: (map['base_salary_earned'] as num).toDouble(),
      overtimePay: (map['overtime_pay'] as num?)?.toDouble() ?? 0,
      latePenalty: (map['late_penalty'] as num?)?.toDouble() ?? 0,
      otherDeduction: (map['other_deduction'] as num?)?.toDouble() ?? 0,
      totalAmount: (map['total_amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      type: _parsePaymentType(map['type'] as String?),
      paidBy: map['paid_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'payment_date': paymentDate.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'paid_days': paidDays,
      'daily_rate': dailyRate,
      'base_salary_earned': baseSalaryEarned,
      'overtime_pay': overtimePay,
      'late_penalty': latePenalty,
      'other_deduction': otherDeduction,
      'total_amount': totalAmount,
      'notes': notes,
      'type': _paymentTypeToString(type),
      'paid_by': paidBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Periode dalam format string
  String get periodFormatted {
    final startStr =
        '${periodStart.day}/${periodStart.month}/${periodStart.year}';
    final endStr = '${periodEnd.day}/${periodEnd.month}/${periodEnd.year}';
    return '$startStr - $endStr';
  }
}

/// Tipe pembayaran
enum PaymentType {
  full, // Pembayaran penuh
  advance, // Kasbon / uang muka
  partial, // Sebagian
}

/// Parse payment type from string
PaymentType _parsePaymentType(String? typeStr) {
  switch (typeStr) {
    case 'Lunas':
      return PaymentType.full;
    case 'advance':
      return PaymentType.advance;
    case 'Sebagian':
      return PaymentType.partial;
    default:
      return PaymentType.full;
  }
}

/// Convert payment type to string
String _paymentTypeToString(PaymentType type) {
  switch (type) {
    case PaymentType.full:
      return 'Lunas';
    case PaymentType.advance:
      return 'advance';
    case PaymentType.partial:
      return 'Sebagian';
  }
}

/// Get display name for PaymentType
String getPaymentTypeDisplayName(PaymentType type) {
  switch (type) {
    case PaymentType.full:
      return 'Pembayaran Penuh';
    case PaymentType.advance:
      return 'Kasbon';
    case PaymentType.partial:
      return 'Sebagian';
  }
}


