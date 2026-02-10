import 'package:uuid/uuid.dart';

/// Helper function to parse SalarySlipStatus from string
SalarySlipStatus _parseStatus(String? statusStr) {
  switch (statusStr) {
    case 'draft':
      return SalarySlipStatus.draft;
    case 'Disetujui':
      return SalarySlipStatus.approved;
    case 'Lunas':
      return SalarySlipStatus.paid;
    case 'Dibatalkan':
      return SalarySlipStatus.cancelled;
    default:
      return SalarySlipStatus.draft;
  }
}

/// Helper function to convert SalarySlipStatus to string
String _statusToString(SalarySlipStatus status) {
  switch (status) {
    case SalarySlipStatus.draft:
      return 'draft';
    case SalarySlipStatus.approved:
      return 'Disetujui';
    case SalarySlipStatus.paid:
      return 'Lunas';
    case SalarySlipStatus.cancelled:
      return 'Dibatalkan';
  }
}

/// Salary Slip Model - Model untuk slip gaji karyawan
class SalarySlipModel {
  final String id;
  final String slipNumber; // Nomor slip: SLIP-202601-001
  final String employeeId;
  final String employeeName;
  final String employeeCode;
  final String position;
  final String department;
  final int month; // Bulan gaji (1-12)
  final int year; // Tahun gaji

  // Pendapatan
  final double baseSalary; // Gaji pokok
  final double transportAllowance; // Tunjangan transport
  final double mealAllowance; // Tunjangan makan
  final double otherAllowance; // Tunjangan lain
  final double overtimePay; // Uang lembur
  final double bonus; // Bonus
  final double otherIncome; // Pendapatan lain

  // Potongan
  final double latePenalty; // Potongan terlambat
  final double absentPenalty; // Potongan tidak hadir
  final double bpjsKesehatan; // BPJS Kesehatan
  final double bpjsKetenagakerjaan; // BPJS Ketenagakerjaan
  final double taxDeduction; // Potongan pajak
  final double loanDeduction; // Potongan pinjaman
  final double otherDeduction; // Potongan lain

  // Summary absensi
  final int totalWorkDays; // Total hari kerja
  final int presentDays; // Hari hadir
  final int absentDays; // Hari tidak hadir
  final int lateDays; // Hari terlambat
  final int sickDays; // Hari sakit
  final int leaveDays; // Hari cuti
  final double totalOvertimeHours; // Total jam lembur

  final String? notes;
  final SalarySlipStatus status;
  final DateTime? paidAt; // Tanggal dibayar
  final String? paidBy; // Dibayar oleh
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalarySlipModel({
    required this.id,
    required this.slipNumber,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.position,
    required this.department,
    required this.month,
    required this.year,
    required this.baseSalary,
    this.transportAllowance = 0,
    this.mealAllowance = 0,
    this.otherAllowance = 0,
    this.overtimePay = 0,
    this.bonus = 0,
    this.otherIncome = 0,
    this.latePenalty = 0,
    this.absentPenalty = 0,
    this.bpjsKesehatan = 0,
    this.bpjsKetenagakerjaan = 0,
    this.taxDeduction = 0,
    this.loanDeduction = 0,
    this.otherDeduction = 0,
    this.totalWorkDays = 0,
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
    this.sickDays = 0,
    this.leaveDays = 0,
    this.totalOvertimeHours = 0,
    this.notes,
    this.status = SalarySlipStatus.draft,
    this.paidAt,
    this.paidBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total pendapatan
  double get totalIncome =>
      baseSalary +
      transportAllowance +
      mealAllowance +
      otherAllowance +
      overtimePay +
      bonus +
      otherIncome;

  /// Total potongan
  double get totalDeduction =>
      latePenalty +
      absentPenalty +
      bpjsKesehatan +
      bpjsKetenagakerjaan +
      taxDeduction +
      loanDeduction +
      otherDeduction;

  /// Gaji bersih (Take Home Pay)
  double get netSalary => totalIncome - totalDeduction;

  /// Periode gaji dalam format string
  String get periodFormatted {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[month]} $year';
  }

  /// Status display name
  String get statusDisplayName => getSalarySlipStatusDisplayName(status);

  /// Factory untuk generate slip gaji
  factory SalarySlipModel.generate({
    required String slipNumber,
    required String employeeId,
    required String employeeName,
    required String employeeCode,
    required String position,
    required String department,
    required int month,
    required int year,
    required double baseSalary,
    double transportAllowance = 0,
    double mealAllowance = 0,
    double otherAllowance = 0,
    double overtimePay = 0,
    double bonus = 0,
    double otherIncome = 0,
    double latePenalty = 0,
    double absentPenalty = 0,
    double bpjsKesehatan = 0,
    double bpjsKetenagakerjaan = 0,
    double taxDeduction = 0,
    double loanDeduction = 0,
    double otherDeduction = 0,
    int totalWorkDays = 0,
    int presentDays = 0,
    int absentDays = 0,
    int lateDays = 0,
    int sickDays = 0,
    int leaveDays = 0,
    double totalOvertimeHours = 0,
    String? notes,
  }) {
    final now = DateTime.now();
    return SalarySlipModel(
      id: const Uuid().v4(),
      slipNumber: slipNumber,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeCode: employeeCode,
      position: position,
      department: department,
      month: month,
      year: year,
      baseSalary: baseSalary,
      transportAllowance: transportAllowance,
      mealAllowance: mealAllowance,
      otherAllowance: otherAllowance,
      overtimePay: overtimePay,
      bonus: bonus,
      otherIncome: otherIncome,
      latePenalty: latePenalty,
      absentPenalty: absentPenalty,
      bpjsKesehatan: bpjsKesehatan,
      bpjsKetenagakerjaan: bpjsKetenagakerjaan,
      taxDeduction: taxDeduction,
      loanDeduction: loanDeduction,
      otherDeduction: otherDeduction,
      totalWorkDays: totalWorkDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      sickDays: sickDays,
      leaveDays: leaveDays,
      totalOvertimeHours: totalOvertimeHours,
      notes: notes,
      status: SalarySlipStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// From database map
  factory SalarySlipModel.fromDatabase(Map<String, dynamic> map) {
    return SalarySlipModel(
      id: map['id'] as String,
      slipNumber: map['slip_number'] as String,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      employeeCode: map['employee_code'] as String,
      position: map['position'] as String,
      department: map['department'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      baseSalary: (map['base_salary'] as num).toDouble(),
      transportAllowance: (map['transport_allowance'] as num?)?.toDouble() ?? 0,
      mealAllowance: (map['meal_allowance'] as num?)?.toDouble() ?? 0,
      otherAllowance: (map['other_allowance'] as num?)?.toDouble() ?? 0,
      overtimePay: (map['overtime_pay'] as num?)?.toDouble() ?? 0,
      bonus: (map['bonus'] as num?)?.toDouble() ?? 0,
      otherIncome: (map['other_income'] as num?)?.toDouble() ?? 0,
      latePenalty: (map['late_penalty'] as num?)?.toDouble() ?? 0,
      absentPenalty: (map['absent_penalty'] as num?)?.toDouble() ?? 0,
      bpjsKesehatan: (map['bpjs_kesehatan'] as num?)?.toDouble() ?? 0,
      bpjsKetenagakerjaan:
          (map['bpjs_ketenagakerjaan'] as num?)?.toDouble() ?? 0,
      taxDeduction: (map['tax_deduction'] as num?)?.toDouble() ?? 0,
      loanDeduction: (map['loan_deduction'] as num?)?.toDouble() ?? 0,
      otherDeduction: (map['other_deduction'] as num?)?.toDouble() ?? 0,
      totalWorkDays: (map['total_work_days'] as num?)?.toInt() ?? 0,
      presentDays: (map['present_days'] as num?)?.toInt() ?? 0,
      absentDays: (map['absent_days'] as num?)?.toInt() ?? 0,
      lateDays: (map['late_days'] as num?)?.toInt() ?? 0,
      sickDays: (map['sick_days'] as num?)?.toInt() ?? 0,
      leaveDays: (map['leave_days'] as num?)?.toInt() ?? 0,
      totalOvertimeHours:
          (map['total_overtime_hours'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String?,
      status: _parseStatus(map['status'] as String?),
      paidAt: map['paid_at'] != null
          ? DateTime.parse(map['paid_at'] as String)
          : null,
      paidBy: map['paid_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'slip_number': slipNumber,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'position': position,
      'department': department,
      'month': month,
      'year': year,
      'base_salary': baseSalary,
      'transport_allowance': transportAllowance,
      'meal_allowance': mealAllowance,
      'other_allowance': otherAllowance,
      'overtime_pay': overtimePay,
      'bonus': bonus,
      'other_income': otherIncome,
      'late_penalty': latePenalty,
      'absent_penalty': absentPenalty,
      'bpjs_kesehatan': bpjsKesehatan,
      'bpjs_ketenagakerjaan': bpjsKetenagakerjaan,
      'tax_deduction': taxDeduction,
      'loan_deduction': loanDeduction,
      'other_deduction': otherDeduction,
      'total_work_days': totalWorkDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'sick_days': sickDays,
      'leave_days': leaveDays,
      'total_overtime_hours': totalOvertimeHours,
      'notes': notes,
      'status': _statusToString(status),
      'paid_at': paidAt?.toIso8601String(),
      'paid_by': paidBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  SalarySlipModel copyWith({
    String? id,
    String? slipNumber,
    String? employeeId,
    String? employeeName,
    String? employeeCode,
    String? position,
    String? department,
    int? month,
    int? year,
    double? baseSalary,
    double? transportAllowance,
    double? mealAllowance,
    double? otherAllowance,
    double? overtimePay,
    double? bonus,
    double? otherIncome,
    double? latePenalty,
    double? absentPenalty,
    double? bpjsKesehatan,
    double? bpjsKetenagakerjaan,
    double? taxDeduction,
    double? loanDeduction,
    double? otherDeduction,
    int? totalWorkDays,
    int? presentDays,
    int? absentDays,
    int? lateDays,
    int? sickDays,
    int? leaveDays,
    double? totalOvertimeHours,
    String? notes,
    SalarySlipStatus? status,
    DateTime? paidAt,
    String? paidBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalarySlipModel(
      id: id ?? this.id,
      slipNumber: slipNumber ?? this.slipNumber,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      position: position ?? this.position,
      department: department ?? this.department,
      month: month ?? this.month,
      year: year ?? this.year,
      baseSalary: baseSalary ?? this.baseSalary,
      transportAllowance: transportAllowance ?? this.transportAllowance,
      mealAllowance: mealAllowance ?? this.mealAllowance,
      otherAllowance: otherAllowance ?? this.otherAllowance,
      overtimePay: overtimePay ?? this.overtimePay,
      bonus: bonus ?? this.bonus,
      otherIncome: otherIncome ?? this.otherIncome,
      latePenalty: latePenalty ?? this.latePenalty,
      absentPenalty: absentPenalty ?? this.absentPenalty,
      bpjsKesehatan: bpjsKesehatan ?? this.bpjsKesehatan,
      bpjsKetenagakerjaan: bpjsKetenagakerjaan ?? this.bpjsKetenagakerjaan,
      taxDeduction: taxDeduction ?? this.taxDeduction,
      loanDeduction: loanDeduction ?? this.loanDeduction,
      otherDeduction: otherDeduction ?? this.otherDeduction,
      totalWorkDays: totalWorkDays ?? this.totalWorkDays,
      presentDays: presentDays ?? this.presentDays,
      absentDays: absentDays ?? this.absentDays,
      lateDays: lateDays ?? this.lateDays,
      sickDays: sickDays ?? this.sickDays,
      leaveDays: leaveDays ?? this.leaveDays,
      totalOvertimeHours: totalOvertimeHours ?? this.totalOvertimeHours,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paidBy: paidBy ?? this.paidBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalarySlipModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SalarySlipModel(id: $id, slip: $slipNumber, employee: $employeeName, net: $netSalary)';
}

/// Status slip gaji
enum SalarySlipStatus {
  draft, // Draft / belum final
  approved, // Sudah disetujui
  paid, // Sudah dibayar
  cancelled, // Dibatalkan
}

/// Get display name for SalarySlipStatus
String getSalarySlipStatusDisplayName(SalarySlipStatus status) {
  switch (status) {
    case SalarySlipStatus.draft:
      return 'Draft';
    case SalarySlipStatus.approved:
      return 'Disetujui';
    case SalarySlipStatus.paid:
      return 'Sudah Dibayar';
    case SalarySlipStatus.cancelled:
      return 'Dibatalkan';
  }
}




