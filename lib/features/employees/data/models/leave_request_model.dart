import 'package:uuid/uuid.dart';

/// Helper function to parse LeaveType from string
LeaveType _parseLeaveType(String? typeStr) {
  switch (typeStr) {
    case 'annual':
      return LeaveType.annual;
    case 'sick':
      return LeaveType.sick;
    case 'maternity':
      return LeaveType.maternity;
    case 'paternity':
      return LeaveType.paternity;
    case 'marriage':
      return LeaveType.marriage;
    case 'bereavement':
      return LeaveType.bereavement;
    case 'unpaid':
      return LeaveType.unpaid;
    case 'emergency':
      return LeaveType.emergency;
    case 'other':
      return LeaveType.other;
    default:
      return LeaveType.annual;
  }
}

/// Helper function to parse LeaveStatus from string
LeaveStatus _parseLeaveStatus(String? statusStr) {
  switch (statusStr) {
    case 'Tertunda':
      return LeaveStatus.pending;
    case 'Disetujui':
      return LeaveStatus.approved;
    case 'Ditolak':
      return LeaveStatus.rejected;
    case 'Dibatalkan':
      return LeaveStatus.cancelled;
    case 'Selesai':
      return LeaveStatus.completed;
    default:
      return LeaveStatus.pending;
  }
}

/// Helper function to convert LeaveType to string
String _leaveTypeToString(LeaveType type) {
  switch (type) {
    case LeaveType.annual:
      return 'annual';
    case LeaveType.sick:
      return 'sick';
    case LeaveType.maternity:
      return 'maternity';
    case LeaveType.paternity:
      return 'paternity';
    case LeaveType.marriage:
      return 'marriage';
    case LeaveType.bereavement:
      return 'bereavement';
    case LeaveType.unpaid:
      return 'unpaid';
    case LeaveType.emergency:
      return 'emergency';
    case LeaveType.other:
      return 'other';
  }
}

/// Helper function to convert LeaveStatus to string
String _leaveStatusToString(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return 'Tertunda';
    case LeaveStatus.approved:
      return 'Disetujui';
    case LeaveStatus.rejected:
      return 'Ditolak';
    case LeaveStatus.cancelled:
      return 'Dibatalkan';
    case LeaveStatus.completed:
      return 'Selesai';
  }
}

/// Leave Request Model - Model untuk pengajuan cuti karyawan
class LeaveRequestModel {
  final String id;
  final String requestNumber; // LEAVE-202601-001
  final String employeeId;
  final String employeeName;
  final String employeeCode;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String? attachment; // Path to attachment file
  final LeaveStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeaveRequestModel({
    required this.id,
    required this.requestNumber,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.attachment,
    this.status = LeaveStatus.pending,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory untuk membuat request cuti baru
  factory LeaveRequestModel.create({
    required String requestNumber,
    required String employeeId,
    required String employeeName,
    required String employeeCode,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachment,
    String? notes,
  }) {
    final now = DateTime.now();
    // Hitung total hari (exclude weekends optionally)
    int totalDays = 0;
    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      // Skip weekend jika bukan cuti penting
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        totalDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return LeaveRequestModel(
      id: const Uuid().v4(),
      requestNumber: requestNumber,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeCode: employeeCode,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      attachment: attachment,
      notes: notes,
      status: LeaveStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// From database map
  factory LeaveRequestModel.fromDatabase(Map<String, dynamic> map) {
    return LeaveRequestModel(
      id: map['id'] as String,
      requestNumber: map['request_number'] as String,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      employeeCode: map['employee_code'] as String,
      leaveType: _parseLeaveType(map['leave_type'] as String?),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      totalDays: map['total_days'] as int,
      reason: map['reason'] as String,
      attachment: map['attachment'] as String?,
      status: _parseLeaveStatus(map['status'] as String?),
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String)
          : null,
      rejectionReason: map['rejection_reason'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'request_number': requestNumber,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'leave_type': _leaveTypeToString(leaveType),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'reason': reason,
      'attachment': attachment,
      'status': _leaveStatusToString(status),
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  LeaveRequestModel copyWith({
    String? id,
    String? requestNumber,
    String? employeeId,
    String? employeeName,
    String? employeeCode,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    String? attachment,
    LeaveStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      attachment: attachment ?? this.attachment,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cek apakah bisa diapprove
  bool get canBeApproved => status == LeaveStatus.pending;

  /// Cek apakah bisa direject
  bool get canBeRejected => status == LeaveStatus.pending;

  /// Cek apakah bisa dicancel
  bool get canBeCancelled =>
      status == LeaveStatus.pending || status == LeaveStatus.approved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LeaveRequestModel(id: $id, employee: $employeeName, type: ${getLeaveTypeDisplayName(leaveType)}, status: ${getLeaveStatusDisplayName(status)})';
}

/// Tipe cuti
enum LeaveType {
  annual, // Cuti tahunan
  sick, // Sakit
  maternity, // Cuti melahirkan
  paternity, // Cuti ayah
  marriage, // Cuti nikah
  bereavement, // Cuti duka
  unpaid, // Cuti tanpa gaji
  emergency, // Cuti darurat
  other, // Lainnya
}

/// Get display name for LeaveType
String getLeaveTypeDisplayName(LeaveType type) {
  switch (type) {
    case LeaveType.annual:
      return 'Cuti Tahunan';
    case LeaveType.sick:
      return 'Sakit';
    case LeaveType.maternity:
      return 'Cuti Melahirkan';
    case LeaveType.paternity:
      return 'Cuti Ayah';
    case LeaveType.marriage:
      return 'Cuti Nikah';
    case LeaveType.bereavement:
      return 'Cuti Duka';
    case LeaveType.unpaid:
      return 'Cuti Tanpa Gaji';
    case LeaveType.emergency:
      return 'Cuti Darurat';
    case LeaveType.other:
      return 'Lainnya';
  }
}

/// Get icon for LeaveType
String getLeaveTypeIcon(LeaveType type) {
  switch (type) {
    case LeaveType.annual:
      return '🏖️';
    case LeaveType.sick:
      return '🏥';
    case LeaveType.maternity:
      return '🤱';
    case LeaveType.paternity:
      return '👨‍🍼';
    case LeaveType.marriage:
      return '💒';
    case LeaveType.bereavement:
      return '🖤';
    case LeaveType.unpaid:
      return '💰';
    case LeaveType.emergency:
      return '🚨';
    case LeaveType.other:
      return '📋';
  }
}

/// Get max days per year for LeaveType
int getLeaveTypeMaxDaysPerYear(LeaveType type) {
  switch (type) {
    case LeaveType.annual:
      return 12;
    case LeaveType.sick:
      return 14;
    case LeaveType.maternity:
      return 90;
    case LeaveType.paternity:
      return 3;
    case LeaveType.marriage:
      return 3;
    case LeaveType.bereavement:
      return 3;
    case LeaveType.unpaid:
      return 30;
    case LeaveType.emergency:
      return 5;
    case LeaveType.other:
      return 7;
  }
}

/// Status pengajuan cuti
enum LeaveStatus {
  pending, // Menunggu persetujuan
  approved, // Disetujui
  rejected, // Ditolak
  cancelled, // Dibatalkan
  completed, // Selesai (sudah lewat tanggal)
}

/// Get display name for LeaveStatus
String getLeaveStatusDisplayName(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return 'Menunggu';
    case LeaveStatus.approved:
      return 'Disetujui';
    case LeaveStatus.rejected:
      return 'Ditolak';
    case LeaveStatus.cancelled:
      return 'Dibatalkan';
    case LeaveStatus.completed:
      return 'Selesai';
  }
}

/// Get icon for LeaveStatus
String getLeaveStatusIcon(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return '⏳';
    case LeaveStatus.approved:
      return '✅';
    case LeaveStatus.rejected:
      return '❌';
    case LeaveStatus.cancelled:
      return '🚫';
    case LeaveStatus.completed:
      return '✔️';
  }
}

/// Model untuk saldo cuti karyawan
class LeaveBalanceModel {
  final String employeeId;
  final int year;
  final LeaveType leaveType;
  final int totalEntitlement; // Jatah awal
  final int used; // Sudah dipakai
  final int pending; // Sedang diajukan

  const LeaveBalanceModel({
    required this.employeeId,
    required this.year,
    required this.leaveType,
    required this.totalEntitlement,
    required this.used,
    required this.pending,
  });

  /// Sisa cuti
  int get remaining => totalEntitlement - used - pending;

  /// Apakah masih bisa ambil cuti
  bool canTakeLeave(int days) => remaining >= days;
}




