import 'package:uuid/uuid.dart';

/// Helper function to parse AttendanceStatus from string
AttendanceStatus _parseAttendanceStatus(String? statusStr) {
  switch (statusStr) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'sick':
      return AttendanceStatus.sick;
    case 'leave':
      return AttendanceStatus.leave;
    case 'permission':
      return AttendanceStatus.permission;
    case 'holiday':
    case 'holidayPaid':
      return AttendanceStatus.holidayPaid;
    case 'holidayUnpaid':
      return AttendanceStatus.holidayUnpaid;
    case 'workFromHome':
      return AttendanceStatus.workFromHome;
    default:
      return AttendanceStatus.absent;
  }
}

/// Helper function to convert AttendanceStatus to string
String _attendanceStatusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'present';
    case AttendanceStatus.absent:
      return 'absent';
    case AttendanceStatus.late:
      return 'late';
    case AttendanceStatus.sick:
      return 'sick';
    case AttendanceStatus.leave:
      return 'leave';
    case AttendanceStatus.permission:
      return 'permission';
    case AttendanceStatus.holidayPaid:
      return 'holidayPaid';
    case AttendanceStatus.holidayUnpaid:
      return 'holidayUnpaid';
    case AttendanceStatus.workFromHome:
      return 'workFromHome';
  }
}

/// Attendance Model - Model untuk data absensi karyawan
class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName; // Cache name untuk display
  final DateTime date;
  final DateTime? checkIn; // Jam masuk
  final DateTime? checkOut; // Jam pulang
  final AttendanceStatus status;
  final String? notes;
  final double? overtimeHours; // Jam lembur
  final bool isLate; // Terlambat
  final int lateMinutes; // Berapa menit terlambat
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.overtimeHours,
    this.isLate = false,
    this.lateMinutes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory untuk membuat attendance baru
  factory AttendanceModel.create({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    DateTime? checkIn,
    DateTime? checkOut,
    required AttendanceStatus status,
    String? notes,
    double? overtimeHours,
    bool isLate = false,
    int lateMinutes = 0,
  }) {
    final now = DateTime.now();
    return AttendanceModel(
      id: const Uuid().v4(),
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      status: status,
      notes: notes,
      overtimeHours: overtimeHours,
      isLate: isLate,
      lateMinutes: lateMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check-in sekarang
  factory AttendanceModel.checkInNow({
    required String employeeId,
    required String employeeName,
    DateTime? standardCheckIn, // Jam masuk standar (default 08:00)
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final standard =
        standardCheckIn ?? DateTime(now.year, now.month, now.day, 8, 0);

    final isLate = now.isAfter(standard);
    final lateMinutes = isLate ? now.difference(standard).inMinutes : 0;

    return AttendanceModel(
      id: const Uuid().v4(),
      employeeId: employeeId,
      employeeName: employeeName,
      date: today,
      checkIn: now,
      checkOut: null,
      status: AttendanceStatus.present,
      notes: null,
      overtimeHours: null,
      isLate: isLate,
      lateMinutes: lateMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// From database map
  factory AttendanceModel.fromDatabase(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      date: DateTime.parse(map['date'] as String),
      checkIn: map['check_in'] != null
          ? DateTime.parse(map['check_in'] as String)
          : null,
      checkOut: map['check_out'] != null
          ? DateTime.parse(map['check_out'] as String)
          : null,
      status: _parseAttendanceStatus(map['status'] as String?),
      notes: map['notes'] as String?,
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble(),
      isLate: map['is_late'] == 1,
      lateMinutes: (map['late_minutes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// To database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'status': _attendanceStatusToString(status),
      'notes': notes,
      'overtime_hours': overtimeHours,
      'is_late': isLate ? 1 : 0,
      'late_minutes': lateMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    String? notes,
    double? overtimeHours,
    bool? isLate,
    int? lateMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      isLate: isLate ?? this.isLate,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Durasi kerja hari ini
  Duration? get workDuration {
    if (checkIn != null && checkOut != null) {
      return checkOut!.difference(checkIn!);
    }
    return null;
  }

  /// Jam kerja dalam format string
  String get workHoursFormatted {
    final duration = workDuration;
    if (duration == null) return '-';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}j ${minutes}m';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttendanceModel(id: $id, employee: $employeeName, date: $date, status: $status)';
}

/// Status absensi
enum AttendanceStatus {
  present, // Hadir - dapat gaji
  absent, // Tidak hadir - tidak dapat gaji
  late, // Terlambat (otomatis dari check-in) - dapat gaji dikurangi
  sick, // Sakit - tergantung kebijakan
  leave, // Cuti - tergantung kebijakan
  permission, // Izin - tidak dapat gaji
  holidayPaid, // Libur dibayar - dapat gaji
  holidayUnpaid, // Libur tidak dibayar - tidak dapat gaji
  workFromHome, // WFH - dapat gaji
}

/// Get display name for AttendanceStatus
String getAttendanceStatusDisplayName(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'Hadir';
    case AttendanceStatus.absent:
      return 'Tidak Hadir';
    case AttendanceStatus.late:
      return 'Terlambat';
    case AttendanceStatus.sick:
      return 'Sakit';
    case AttendanceStatus.leave:
      return 'Cuti';
    case AttendanceStatus.permission:
      return 'Izin';
    case AttendanceStatus.holidayPaid:
      return 'Libur (Gaji)';
    case AttendanceStatus.holidayUnpaid:
      return 'Libur (Tanpa Gaji)';
    case AttendanceStatus.workFromHome:
      return 'WFH';
  }
}

/// Get icon for AttendanceStatus
String getAttendanceStatusIcon(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return '✅';
    case AttendanceStatus.absent:
      return '❌';
    case AttendanceStatus.late:
      return '⏰';
    case AttendanceStatus.sick:
      return '🏥';
    case AttendanceStatus.leave:
      return '🏖️';
    case AttendanceStatus.permission:
      return '📝';
    case AttendanceStatus.holidayPaid:
      return '🎉';
    case AttendanceStatus.holidayUnpaid:
      return '🚫';
    case AttendanceStatus.workFromHome:
      return '🏠';
  }
}

/// Check if status earns salary
bool attendanceStatusEarnsSalary(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
    case AttendanceStatus.late:
    case AttendanceStatus.holidayPaid:
    case AttendanceStatus.workFromHome:
    case AttendanceStatus.sick:
    case AttendanceStatus.leave:
      return true;
    case AttendanceStatus.absent:
    case AttendanceStatus.permission:
    case AttendanceStatus.holidayUnpaid:
      return false;
  }
}



