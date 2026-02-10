import 'package:logger/logger.dart';
import '../../../../core/database/database_helper.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/salary_slip_model.dart';
import '../models/leave_request_model.dart';
import '../models/salary_payment_model.dart';

/// Repository untuk mengelola data karyawan
class EmployeeRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Logger _logger = Logger();

  static const String _employeesTable = 'employees';
  static const String _attendanceTable = 'employee_attendance';
  static const String _salarySlipsTable = 'salary_slips';
  static const String _leaveRequestsTable = 'leave_requests';
  static const String _salaryPaymentsTable = 'salary_payments';

  // ============= EMPLOYEE CRUD =============

  /// Get semua karyawan
  Future<List<EmployeeModel>> getAllEmployees({bool activeOnly = true}) async {
    try {
      final db = await _db.database;
      final query = activeOnly
          ? 'SELECT * FROM $_employeesTable WHERE is_active = 1 ORDER BY name'
          : 'SELECT * FROM $_employeesTable ORDER BY name';
      final maps = await db.rawQuery(query);
      return maps.map((m) => EmployeeModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employees: $e');
      return [];
    }
  }

  /// Get karyawan by ID
  Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_employeesTable WHERE id = ?',
        [id],
      );
      if (maps.isEmpty) return null;
      return EmployeeModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting employee by id: $e');
      return null;
    }
  }

  /// Get karyawan by department
  Future<List<EmployeeModel>> getEmployeesByDepartment(
      String department) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_employeesTable WHERE department = ? AND is_active = 1 ORDER BY name',
        [department],
      );
      return maps.map((m) => EmployeeModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employees by department: $e');
      return [];
    }
  }

  /// Tambah karyawan baru
  Future<bool> addEmployee(EmployeeModel employee) async {
    try {
      final db = await _db.database;
      await db.insert(_employeesTable, employee.toDatabase());
      _logger.i('Employee added: ${employee.name}');
      return true;
    } catch (e) {
      _logger.e('Error adding employee: $e');
      return false;
    }
  }

  /// Update karyawan
  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      final db = await _db.database;
      final updatedEmployee = employee.copyWith(updatedAt: DateTime.now());
      await db.update(
        _employeesTable,
        updatedEmployee.toDatabase(),
        where: 'id = ?',
        whereArgs: [employee.id],
      );
      _logger.i('Employee updated: ${employee.name}');
      return true;
    } catch (e) {
      _logger.e('Error updating employee: $e');
      return false;
    }
  }

  /// Hapus karyawan (soft delete)
  Future<bool> deleteEmployee(String id) async {
    try {
      final db = await _db.database;
      await db.update(
        _employeesTable,
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Employee soft deleted: $id');
      return true;
    } catch (e) {
      _logger.e('Error deleting employee: $e');
      return false;
    }
  }

  /// Generate kode karyawan baru
  Future<String> generateEmployeeCode() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_employeesTable',
      );
      final count = (result.first['count'] as int) + 1;
      return 'EMP${count.toString().padLeft(3, '0')}';
    } catch (e) {
      _logger.e('Error generating employee code: $e');
      return 'EMP${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Search karyawan
  Future<List<EmployeeModel>> searchEmployees(String query) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '''SELECT * FROM $_employeesTable 
           WHERE is_active = 1 AND (
             name LIKE ? OR employee_code LIKE ? OR position LIKE ?
           ) ORDER BY name''',
        ['%$query%', '%$query%', '%$query%'],
      );
      return maps.map((m) => EmployeeModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error searching employees: $e');
      return [];
    }
  }

  // ============= ATTENDANCE CRUD =============

  /// Get absensi hari ini untuk semua karyawan
  Future<List<AttendanceModel>> getTodayAttendance() async {
    try {
      final db = await _db.database;
      final today = DateTime.now();
      final dateStr =
          DateTime(today.year, today.month, today.day).toIso8601String();

      final maps = await db.rawQuery(
        'SELECT * FROM $_attendanceTable WHERE date = ? ORDER BY employee_name',
        [dateStr],
      );
      return maps.map((m) => AttendanceModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting today attendance: $e');
      return [];
    }
  }

  /// Get absensi karyawan dalam periode tertentu
  Future<List<AttendanceModel>> getEmployeeAttendance(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _db.database;
      final startStr = DateTime(startDate.year, startDate.month, startDate.day)
          .toIso8601String();
      final endStr =
          DateTime(endDate.year, endDate.month, endDate.day).toIso8601String();

      final maps = await db.rawQuery(
        '''SELECT * FROM $_attendanceTable 
           WHERE employee_id = ? AND date >= ? AND date <= ? 
           ORDER BY date DESC''',
        [employeeId, startStr, endStr],
      );
      return maps.map((m) => AttendanceModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employee attendance: $e');
      return [];
    }
  }

  /// Get absensi untuk bulan tertentu
  Future<List<AttendanceModel>> getMonthlyAttendance(
      int month, int year) async {
    try {
      final db = await _db.database;
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0); // Hari terakhir bulan

      final maps = await db.rawQuery(
        '''SELECT * FROM $_attendanceTable 
           WHERE date >= ? AND date <= ? 
           ORDER BY date, employee_name''',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      return maps.map((m) => AttendanceModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting monthly attendance: $e');
      return [];
    }
  }

  /// Check-in karyawan
  Future<AttendanceModel?> checkIn(
      String employeeId, String employeeName) async {
    try {
      final db = await _db.database;
      final today = DateTime.now();
      final dateStr =
          DateTime(today.year, today.month, today.day).toIso8601String();

      // Cek apakah sudah check-in hari ini
      final existing = await db.rawQuery(
        'SELECT * FROM $_attendanceTable WHERE employee_id = ? AND date = ?',
        [employeeId, dateStr],
      );

      if (existing.isNotEmpty) {
        _logger.w('Employee already checked in today');
        return AttendanceModel.fromDatabase(existing.first);
      }

      final attendance = AttendanceModel.checkInNow(
        employeeId: employeeId,
        employeeName: employeeName,
      );

      await db.insert(_attendanceTable, attendance.toDatabase());
      _logger.i('Check-in recorded for $employeeName');
      return attendance;
    } catch (e) {
      _logger.e('Error checking in: $e');
      return null;
    }
  }

  /// Check-out karyawan
  Future<bool> checkOut(String attendanceId) async {
    try {
      final db = await _db.database;
      final now = DateTime.now();

      await db.update(
        _attendanceTable,
        {
          'check_out': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [attendanceId],
      );
      _logger.i('Check-out recorded');
      return true;
    } catch (e) {
      _logger.e('Error checking out: $e');
      return false;
    }
  }

  /// Tambah absensi manual
  Future<bool> addAttendance(AttendanceModel attendance) async {
    try {
      final db = await _db.database;
      await db.insert(_attendanceTable, attendance.toDatabase());
      _logger.i('Attendance added for ${attendance.employeeName}');
      return true;
    } catch (e) {
      _logger.e('Error adding attendance: $e');
      return false;
    }
  }

  /// Update absensi
  Future<bool> updateAttendance(AttendanceModel attendance) async {
    try {
      final db = await _db.database;
      final updated = attendance.copyWith(updatedAt: DateTime.now());
      await db.update(
        _attendanceTable,
        updated.toDatabase(),
        where: 'id = ?',
        whereArgs: [attendance.id],
      );
      _logger.i('Attendance updated');
      return true;
    } catch (e) {
      _logger.e('Error updating attendance: $e');
      return false;
    }
  }

  /// Hitung statistik absensi bulanan untuk karyawan
  Future<Map<String, int>> getMonthlyAttendanceStats(
    String employeeId,
    int month,
    int year,
  ) async {
    try {
      final db = await _db.database;
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final maps = await db.rawQuery(
        '''SELECT status, COUNT(*) as count FROM $_attendanceTable 
           WHERE employee_id = ? AND date >= ? AND date <= ?
           GROUP BY status''',
        [employeeId, startDate.toIso8601String(), endDate.toIso8601String()],
      );

      final stats = <String, int>{};
      for (final m in maps) {
        stats[m['status'] as String] = m['count'] as int;
      }
      return stats;
    } catch (e) {
      _logger.e('Error getting attendance stats: $e');
      return {};
    }
  }

  // ============= SALARY SLIP CRUD =============

  /// Get semua slip gaji
  Future<List<SalarySlipModel>> getAllSalarySlips(
      {int? month, int? year}) async {
    try {
      final db = await _db.database;
      String query = 'SELECT * FROM $_salarySlipsTable';
      List<dynamic> args = [];

      if (month != null && year != null) {
        query += ' WHERE month = ? AND year = ?';
        args = [month, year];
      } else if (year != null) {
        query += ' WHERE year = ?';
        args = [year];
      }

      query += ' ORDER BY year DESC, month DESC, employee_name';

      final maps = await db.rawQuery(query, args);
      return maps.map((m) => SalarySlipModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting salary slips: $e');
      return [];
    }
  }

  /// Get slip gaji by ID
  Future<SalarySlipModel?> getSalarySlipById(String id) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_salarySlipsTable WHERE id = ?',
        [id],
      );
      if (maps.isEmpty) return null;
      return SalarySlipModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting salary slip: $e');
      return null;
    }
  }

  /// Get slip gaji karyawan
  Future<List<SalarySlipModel>> getEmployeeSalarySlips(
      String employeeId) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_salarySlipsTable WHERE employee_id = ? ORDER BY year DESC, month DESC',
        [employeeId],
      );
      return maps.map((m) => SalarySlipModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employee salary slips: $e');
      return [];
    }
  }

  /// Tambah slip gaji
  Future<bool> addSalarySlip(SalarySlipModel slip) async {
    try {
      final db = await _db.database;
      await db.insert(_salarySlipsTable, slip.toDatabase());
      _logger.i('Salary slip added: ${slip.slipNumber}');
      return true;
    } catch (e) {
      _logger.e('Error adding salary slip: $e');
      return false;
    }
  }

  /// Update slip gaji
  Future<bool> updateSalarySlip(SalarySlipModel slip) async {
    try {
      final db = await _db.database;
      final updated = slip.copyWith(updatedAt: DateTime.now());
      await db.update(
        _salarySlipsTable,
        updated.toDatabase(),
        where: 'id = ?',
        whereArgs: [slip.id],
      );
      _logger.i('Salary slip updated: ${slip.slipNumber}');
      return true;
    } catch (e) {
      _logger.e('Error updating salary slip: $e');
      return false;
    }
  }

  /// Generate nomor slip gaji
  Future<String> generateSlipNumber(int month, int year) async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_salarySlipsTable WHERE month = ? AND year = ?',
        [month, year],
      );
      final count = (result.first['count'] as int) + 1;
      final monthStr = month.toString().padLeft(2, '0');
      return 'SLIP-$year$monthStr-${count.toString().padLeft(3, '0')}';
    } catch (e) {
      _logger.e('Error generating slip number: $e');
      return 'SLIP-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generate slip gaji otomatis untuk semua karyawan
  /// SISTEM GAJI HARIAN:
  /// - Gaji dihitung per-hari berdasarkan kehadiran
  /// - Tidak hadir = tidak dapat gaji hari itu
  /// - Terlambat = potong 10.000 per 30 menit
  /// - Libur dibayar = dapat gaji
  /// - Libur tidak dibayar = tidak dapat gaji
  Future<List<SalarySlipModel>> generateMonthlySlips(
      int month, int year) async {
    try {
      final employees = await getAllEmployees();
      final slips = <SalarySlipModel>[];

      for (final emp in employees) {
        // Get all attendance for the month
        final attendances = await getEmployeeAttendance(
          emp.id,
          DateTime(year, month, 1),
          DateTime(year, month + 1, 0),
        );

        // Calculate working days and salary
        int paidDays = 0;
        int absentDays = 0;
        int lateDays = 0;
        int sickDays = 0;
        int leaveDays = 0;
        int holidayPaidDays = 0;
        int holidayUnpaidDays = 0;
        double totalOvertimeHours = 0;
        double totalLateMinutes = 0;

        for (final att in attendances) {
          totalOvertimeHours += att.overtimeHours ?? 0;

          // Hitung hari berdasarkan status
          if (attendanceStatusEarnsSalary(att.status)) {
            paidDays++;
          }

          switch (att.status) {
            case AttendanceStatus.present:
            case AttendanceStatus.workFromHome:
              break; // sudah dihitung di paidDays
            case AttendanceStatus.late:
              lateDays++;
              totalLateMinutes += att.lateMinutes; // akumulasi menit terlambat
              break;
            case AttendanceStatus.absent:
            case AttendanceStatus.permission:
              absentDays++;
              break;
            case AttendanceStatus.sick:
              sickDays++;
              break;
            case AttendanceStatus.leave:
              leaveDays++;
              break;
            case AttendanceStatus.holidayPaid:
              holidayPaidDays++;
              break;
            case AttendanceStatus.holidayUnpaid:
              holidayUnpaidDays++;
              break;
          }
        }

        // GAJI POKOK = gaji per hari × hari yang dibayar
        final dailyTotal = emp.totalDailySalary;
        final baseSalaryEarned = dailyTotal * paidDays;

        // POTONGAN TELAT = 10.000 per 30 menit
        // Hitung per 30 menit (pembulatan ke atas)
        final latePenaltyUnits = (totalLateMinutes / 30).ceil();
        final latePenalty = latePenaltyUnits * 10000.0;

        // LEMBUR = 1.5x tarif per jam
        final hourlyRate = dailyTotal / 8;
        final overtimePay = totalOvertimeHours * hourlyRate * 1.5;

        final slipNumber = await generateSlipNumber(month, year);

        final slip = SalarySlipModel.generate(
          slipNumber: slipNumber,
          employeeId: emp.id,
          employeeName: emp.name,
          employeeCode: emp.employeeCode,
          position: emp.position,
          department: emp.department,
          month: month,
          year: year,
          baseSalary:
              baseSalaryEarned, // Gaji yang diterima berdasarkan kehadiran
          transportAllowance: 0, // Sudah termasuk di daily salary
          mealAllowance: 0, // Sudah termasuk di daily salary
          otherAllowance: 0, // Sudah termasuk di daily salary
          overtimePay: overtimePay,
          latePenalty: latePenalty,
          absentPenalty: 0, // Tidak ada - karena tidak hadir = tidak dapat gaji
          totalWorkDays: paidDays + absentDays + holidayUnpaidDays,
          presentDays: paidDays,
          absentDays: absentDays,
          lateDays: lateDays,
          sickDays: sickDays,
          leaveDays: leaveDays,
          totalOvertimeHours: totalOvertimeHours,
          notes:
              'Gaji/hari: ${emp.dailySalary.toStringAsFixed(0)}, Hari dibayar: $paidDays, Libur dibayar: $holidayPaidDays, Libur tidak dibayar: $holidayUnpaidDays',
        );

        await addSalarySlip(slip);
        slips.add(slip);
      }

      _logger.i('Generated ${slips.length} salary slips for $month/$year');
      return slips;
    } catch (e) {
      _logger.e('Error generating monthly slips: $e');
      return [];
    }
  }

  /// Tandai slip sebagai sudah dibayar
  Future<bool> markSlipAsPaid(String slipId, String paidBy) async {
    try {
      final db = await _db.database;
      final now = DateTime.now();

      await db.update(
        _salarySlipsTable,
        {
          'status': SalarySlipStatus.paid.name,
          'paid_at': now.toIso8601String(),
          'paid_by': paidBy,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [slipId],
      );
      _logger.i('Salary slip marked as paid: $slipId');
      return true;
    } catch (e) {
      _logger.e('Error marking slip as paid: $e');
      return false;
    }
  }

  // ============= DATABASE INITIALIZATION =============

  /// Inisialisasi tabel employees (panggil saat app start)
  Future<void> initializeTables() async {
    try {
      final db = await _db.database;

      // Create employees table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_employeesTable (
          id TEXT PRIMARY KEY,
          employee_code TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          address TEXT,
          position TEXT NOT NULL,
          department TEXT NOT NULL,
          daily_salary REAL NOT NULL DEFAULT 0,
          daily_transport REAL DEFAULT 0,
          daily_meal REAL DEFAULT 0,
          daily_other REAL DEFAULT 0,
          last_salary_taken TEXT,
          join_date TEXT NOT NULL,
          birth_date TEXT,
          identity_number TEXT,
          bank_account TEXT,
          bank_name TEXT,
          emergency_contact TEXT,
          emergency_phone TEXT,
          photo_path TEXT,
          notes TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Migration: add new columns if they don't exist (for existing databases)
      try {
        await db.execute(
            'ALTER TABLE $_employeesTable ADD COLUMN daily_salary REAL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE $_employeesTable ADD COLUMN daily_transport REAL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE $_employeesTable ADD COLUMN daily_meal REAL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE $_employeesTable ADD COLUMN daily_other REAL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE $_employeesTable ADD COLUMN last_salary_taken TEXT');
      } catch (_) {}

      // Migrate old base_salary to daily_salary (divide by 26)
      try {
        await db.execute('''
          UPDATE $_employeesTable 
          SET daily_salary = COALESCE(base_salary / 26, 0)
          WHERE daily_salary IS NULL OR daily_salary = 0
        ''');
      } catch (_) {}

      // Create attendance table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_attendanceTable (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          date TEXT NOT NULL,
          check_in TEXT,
          check_out TEXT,
          status TEXT NOT NULL,
          notes TEXT,
          overtime_hours REAL,
          is_late INTEGER DEFAULT 0,
          late_minutes INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (employee_id) REFERENCES $_employeesTable(id)
        )
      ''');

      // Create salary slips table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_salarySlipsTable (
          id TEXT PRIMARY KEY,
          slip_number TEXT UNIQUE NOT NULL,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_code TEXT NOT NULL,
          position TEXT NOT NULL,
          department TEXT NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          base_salary REAL NOT NULL,
          transport_allowance REAL DEFAULT 0,
          meal_allowance REAL DEFAULT 0,
          other_allowance REAL DEFAULT 0,
          overtime_pay REAL DEFAULT 0,
          bonus REAL DEFAULT 0,
          other_income REAL DEFAULT 0,
          late_penalty REAL DEFAULT 0,
          absent_penalty REAL DEFAULT 0,
          bpjs_kesehatan REAL DEFAULT 0,
          bpjs_ketenagakerjaan REAL DEFAULT 0,
          tax_deduction REAL DEFAULT 0,
          loan_deduction REAL DEFAULT 0,
          other_deduction REAL DEFAULT 0,
          total_work_days INTEGER DEFAULT 0,
          present_days INTEGER DEFAULT 0,
          absent_days INTEGER DEFAULT 0,
          late_days INTEGER DEFAULT 0,
          sick_days INTEGER DEFAULT 0,
          leave_days INTEGER DEFAULT 0,
          total_overtime_hours REAL DEFAULT 0,
          notes TEXT,
          status TEXT NOT NULL,
          paid_at TEXT,
          paid_by TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (employee_id) REFERENCES $_employeesTable(id)
        )
      ''');

      // Create leave requests table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_leaveRequestsTable (
          id TEXT PRIMARY KEY,
          request_number TEXT UNIQUE NOT NULL,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_code TEXT NOT NULL,
          leave_type TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          total_days INTEGER NOT NULL,
          reason TEXT NOT NULL,
          attachment TEXT,
          status TEXT NOT NULL,
          approved_by TEXT,
          approved_at TEXT,
          rejection_reason TEXT,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (employee_id) REFERENCES $_employeesTable(id)
        )
      ''');

      // Create indexes
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_employees_name ON $_employeesTable(name)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_attendance_date ON $_attendanceTable(date)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_salary_period ON $_salarySlipsTable(year, month)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_leave_employee ON $_leaveRequestsTable(employee_id)');

      // Create salary payments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_salaryPaymentsTable (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_code TEXT NOT NULL,
          payment_date TEXT NOT NULL,
          period_start TEXT NOT NULL,
          period_end TEXT NOT NULL,
          paid_days INTEGER NOT NULL,
          daily_rate REAL NOT NULL,
          base_salary_earned REAL NOT NULL,
          overtime_pay REAL DEFAULT 0,
          late_penalty REAL DEFAULT 0,
          other_deduction REAL DEFAULT 0,
          total_amount REAL NOT NULL,
          notes TEXT,
          type TEXT NOT NULL,
          paid_by TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (employee_id) REFERENCES $_employeesTable(id)
        )
      ''');

      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_payment_employee ON $_salaryPaymentsTable(employee_id)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_payment_date ON $_salaryPaymentsTable(payment_date)');

      _logger.i('Employee tables initialized successfully');
    } catch (e) {
      _logger.e('Error initializing employee tables: $e');
    }
  }

  // ============= LEAVE REQUEST CRUD =============

  /// Get semua pengajuan cuti
  Future<List<LeaveRequestModel>> getAllLeaveRequests(
      {LeaveStatus? status}) async {
    try {
      final db = await _db.database;
      String query = 'SELECT * FROM $_leaveRequestsTable';
      List<dynamic> args = [];

      if (status != null) {
        query += ' WHERE status = ?';
        final statusStr = switch (status) {
          LeaveStatus.pending => 'Tertunda',
          LeaveStatus.approved => 'Disetujui',
          LeaveStatus.rejected => 'Ditolak',
          LeaveStatus.cancelled => 'Dibatalkan',
          LeaveStatus.completed => 'Selesai',
        };
        args = [statusStr];
      }

      query += ' ORDER BY created_at DESC';

      final maps = await db.rawQuery(query, args);
      return maps.map((m) => LeaveRequestModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting leave requests: $e');
      return [];
    }
  }

  /// Get pengajuan cuti by employee
  Future<List<LeaveRequestModel>> getEmployeeLeaveRequests(
      String employeeId) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_leaveRequestsTable WHERE employee_id = ? ORDER BY created_at DESC',
        [employeeId],
      );
      return maps.map((m) => LeaveRequestModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employee leave requests: $e');
      return [];
    }
  }

  /// Get pengajuan cuti by ID
  Future<LeaveRequestModel?> getLeaveRequestById(String id) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_leaveRequestsTable WHERE id = ?',
        [id],
      );
      if (maps.isEmpty) return null;
      return LeaveRequestModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting leave request: $e');
      return null;
    }
  }

  /// Tambah pengajuan cuti
  Future<bool> addLeaveRequest(LeaveRequestModel request) async {
    try {
      final db = await _db.database;
      await db.insert(_leaveRequestsTable, request.toDatabase());
      _logger.i('Leave request added: ${request.requestNumber}');
      return true;
    } catch (e) {
      _logger.e('Error adding leave request: $e');
      return false;
    }
  }

  /// Generate nomor pengajuan cuti
  Future<String> generateLeaveRequestNumber() async {
    try {
      final db = await _db.database;
      final now = DateTime.now();
      final monthStr = now.month.toString().padLeft(2, '0');

      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM $_leaveRequestsTable WHERE request_number LIKE ?",
        ['LEAVE-${now.year}$monthStr%'],
      );
      final count = (result.first['count'] as int) + 1;
      return 'LEAVE-${now.year}$monthStr-${count.toString().padLeft(3, '0')}';
    } catch (e) {
      _logger.e('Error generating leave request number: $e');
      return 'LEAVE-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Approve pengajuan cuti
  Future<bool> approveLeaveRequest(String id, String approvedBy) async {
    try {
      final db = await _db.database;
      final now = DateTime.now();

      await db.update(
        _leaveRequestsTable,
        {
          'status': LeaveStatus.approved.name,
          'approved_by': approvedBy,
          'approved_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Leave request approved: $id');
      return true;
    } catch (e) {
      _logger.e('Error approving leave request: $e');
      return false;
    }
  }

  /// Reject pengajuan cuti
  Future<bool> rejectLeaveRequest(String id, String rejectionReason) async {
    try {
      final db = await _db.database;
      final now = DateTime.now();

      await db.update(
        _leaveRequestsTable,
        {
          'status': LeaveStatus.rejected.name,
          'rejection_reason': rejectionReason,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Leave request rejected: $id');
      return true;
    } catch (e) {
      _logger.e('Error rejecting leave request: $e');
      return false;
    }
  }

  /// Cancel pengajuan cuti
  Future<bool> cancelLeaveRequest(String id) async {
    try {
      final db = await _db.database;
      final now = DateTime.now();

      await db.update(
        _leaveRequestsTable,
        {
          'status': LeaveStatus.cancelled.name,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Leave request cancelled: $id');
      return true;
    } catch (e) {
      _logger.e('Error cancelling leave request: $e');
      return false;
    }
  }

  /// Hitung saldo cuti karyawan untuk tahun tertentu
  Future<Map<LeaveType, LeaveBalanceModel>> getLeaveBalance(
    String employeeId,
    int year,
  ) async {
    try {
      final db = await _db.database;
      final startOfYear = DateTime(year, 1, 1).toIso8601String();
      final endOfYear = DateTime(year, 12, 31).toIso8601String();

      final balances = <LeaveType, LeaveBalanceModel>{};

      for (final type in LeaveType.values) {
        // Get used days (approved + completed)
        final usedResult = await db.rawQuery('''
          SELECT COALESCE(SUM(total_days), 0) as total FROM $_leaveRequestsTable 
          WHERE employee_id = ? 
            AND leave_type = ? 
            AND (status = 'Disetujui' OR status = 'Selesai')
            AND start_date >= ? AND start_date <= ?
        ''', [employeeId, type.name, startOfYear, endOfYear]);

        final used = (usedResult.first['total'] as num?)?.toInt() ?? 0;

        // Get pending days
        final pendingResult = await db.rawQuery('''
          SELECT COALESCE(SUM(total_days), 0) as total FROM $_leaveRequestsTable 
          WHERE employee_id = ? 
            AND leave_type = ? 
            AND status = 'Tertunda'
            AND start_date >= ? AND start_date <= ?
        ''', [employeeId, type.name, startOfYear, endOfYear]);

        final pending = (pendingResult.first['total'] as num?)?.toInt() ?? 0;

        balances[type] = LeaveBalanceModel(
          employeeId: employeeId,
          year: year,
          leaveType: type,
          totalEntitlement: getLeaveTypeMaxDaysPerYear(type),
          used: used,
          pending: pending,
        );
      }

      return balances;
    } catch (e) {
      _logger.e('Error getting leave balance: $e');
      return {};
    }
  }

  /// Get pending leave requests count
  Future<int> getPendingLeaveRequestsCount() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM $_leaveRequestsTable WHERE status = 'Tertunda'",
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      _logger.e('Error getting pending leave count: $e');
      return 0;
    }
  }

  // ============= EXPORT FUNCTIONS =============

  /// Export data karyawan ke CSV string
  Future<String> exportEmployeesToCsv() async {
    try {
      final employees = await getAllEmployees(activeOnly: false);
      final buffer = StringBuffer();

      // Header
      buffer.writeln(
          'Kode,Nama,Telepon,Email,Alamat,Jabatan,Departemen,Gaji/Hari,Transport/Hari,Makan/Hari,Lainnya/Hari,Tanggal Bergabung,Status');

      // Data
      for (final emp in employees) {
        buffer.writeln(
            '"${emp.employeeCode}","${emp.name}","${emp.phone ?? ''}","${emp.email ?? ''}","${emp.address ?? ''}","${emp.position}","${emp.department}",${emp.dailySalary},${emp.dailyTransport},${emp.dailyMeal},${emp.dailyOther},"${emp.joinDate.toIso8601String().split('T')[0]}","${emp.isActive ? 'Aktif' : 'Tidak Aktif'}"');
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Error exporting employees to CSV: $e');
      return '';
    }
  }

  /// Export absensi bulanan ke CSV
  Future<String> exportAttendanceToCsv(int month, int year) async {
    try {
      final employees = await getAllEmployees();
      final attendances = await getMonthlyAttendance(month, year);
      final buffer = StringBuffer();

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

      buffer.writeln('Rekap Absensi ${months[month]} $year');
      buffer.writeln('');

      // Header
      buffer.writeln(
          'Kode,Nama,Hadir,Tidak Hadir,Terlambat,Sakit,Cuti,Izin,Total Jam Kerja');

      // Data per karyawan
      for (final emp in employees) {
        final empAtt =
            attendances.where((a) => a.employeeId == emp.id).toList();

        int present = 0,
            absent = 0,
            late = 0,
            sick = 0,
            leave = 0,
            permission = 0;
        double totalHours = 0;

        for (final att in empAtt) {
          switch (att.status) {
            case AttendanceStatus.present:
              present++;
              break;
            case AttendanceStatus.absent:
              absent++;
              break;
            case AttendanceStatus.late:
              late++;
              break;
            case AttendanceStatus.sick:
              sick++;
              break;
            case AttendanceStatus.leave:
              leave++;
              break;
            case AttendanceStatus.permission:
              permission++;
              break;
            default:
              break;
          }
          if (att.workDuration != null) {
            totalHours += att.workDuration!.inMinutes / 60;
          }
        }

        buffer.writeln(
            '"${emp.employeeCode}","${emp.name}",$present,$absent,$late,$sick,$leave,$permission,${totalHours.toStringAsFixed(1)}');
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Error exporting attendance to CSV: $e');
      return '';
    }
  }

  /// Export slip gaji ke CSV
  Future<String> exportSalarySlipsToCsv(int month, int year) async {
    try {
      final slips = await getAllSalarySlips(month: month, year: year);
      final buffer = StringBuffer();

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

      buffer.writeln('Rekap Gaji ${months[month]} $year');
      buffer.writeln('');

      // Header
      buffer.writeln(
          'No Slip,Kode,Nama,Jabatan,Gaji Pokok,Total Tunjangan,Total Pendapatan,Total Potongan,Gaji Bersih,Status');

      for (final slip in slips) {
        final totalAllowance =
            slip.transportAllowance + slip.mealAllowance + slip.otherAllowance;
        buffer.writeln(
            '"${slip.slipNumber}","${slip.employeeCode}","${slip.employeeName}","${slip.position}",${slip.baseSalary},$totalAllowance,${slip.totalIncome},${slip.totalDeduction},${slip.netSalary},"${slip.statusDisplayName}"');
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Error exporting salary slips to CSV: $e');
      return '';
    }
  }

  // ============= SALARY PAYMENT CRUD =============

  /// Tambah pembayaran gaji
  Future<bool> addSalaryPayment(SalaryPaymentModel payment) async {
    try {
      final db = await _db.database;
      await db.insert(_salaryPaymentsTable, payment.toDatabase());

      // Update last_salary_taken pada employee
      await db.update(
        _employeesTable,
        {'last_salary_taken': payment.periodEnd.toIso8601String()},
        where: 'id = ?',
        whereArgs: [payment.employeeId],
      );

      _logger.i('Salary payment added: ${payment.id}');
      return true;
    } catch (e) {
      _logger.e('Error adding salary payment: $e');
      return false;
    }
  }

  /// Get semua pembayaran gaji karyawan
  Future<List<SalaryPaymentModel>> getEmployeePayments(
      String employeeId) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_salaryPaymentsTable WHERE employee_id = ? ORDER BY payment_date DESC',
        [employeeId],
      );
      return maps.map((m) => SalaryPaymentModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting employee payments: $e');
      return [];
    }
  }

  /// Get pembayaran terakhir karyawan
  Future<SalaryPaymentModel?> getLastPayment(String employeeId) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        'SELECT * FROM $_salaryPaymentsTable WHERE employee_id = ? ORDER BY payment_date DESC LIMIT 1',
        [employeeId],
      );
      if (maps.isEmpty) return null;
      return SalaryPaymentModel.fromDatabase(maps.first);
    } catch (e) {
      _logger.e('Error getting last payment: $e');
      return null;
    }
  }

  /// Hitung gaji yang belum diambil sejak terakhir kali
  /// Returns: {paidDays, baseSalaryEarned, overtimePay, latePenalty, totalAmount, periodStart, periodEnd}
  Future<Map<String, dynamic>> calculatePendingSalary(String employeeId) async {
    try {
      final employee = await getEmployeeById(employeeId);
      if (employee == null) {
        return _emptyPendingSalary();
      }

      // Tentukan periode dari last_salary_taken atau join_date
      DateTime periodStart;
      if (employee.lastSalaryTaken != null) {
        periodStart = employee.lastSalaryTaken!.add(const Duration(days: 1));
      } else {
        periodStart = employee.joinDate;
      }

      final periodEnd = DateTime.now();

      // Jika periodStart > periodEnd, tidak ada gaji yang pending
      if (periodStart.isAfter(periodEnd)) {
        return _emptyPendingSalary();
      }

      // Get absensi dalam periode
      final db = await _db.database;
      final attendances = await db.rawQuery('''
        SELECT * FROM $_attendanceTable 
        WHERE employee_id = ? 
        AND date >= ? 
        AND date <= ?
        ORDER BY date
      ''', [
        employeeId,
        DateTime(periodStart.year, periodStart.month, periodStart.day)
            .toIso8601String(),
        DateTime(periodEnd.year, periodEnd.month, periodEnd.day)
            .toIso8601String(),
      ]);

      int paidDays = 0;
      double overtimeHours = 0;
      int lateMinutes = 0;

      for (final att in attendances) {
        final status = _parseAttendanceStatus(att['status'] as String?);
        if (attendanceStatusEarnsSalary(status)) {
          paidDays++;
        }
        overtimeHours += (att['overtime_hours'] as num?)?.toDouble() ?? 0;
        lateMinutes += (att['late_minutes'] as num?)?.toInt() ?? 0;
      }

      final dailyRate = employee.totalDailySalary;
      final baseSalaryEarned = paidDays * dailyRate;
      final overtimePay = overtimeHours * (dailyRate / 8); // Asumsi 8 jam kerja
      final latePenalty =
          (lateMinutes / 60) * (dailyRate / 8); // Potongan per jam telat
      final totalAmount = baseSalaryEarned + overtimePay - latePenalty;

      return {
        'paidDays': paidDays,
        'dailyRate': dailyRate,
        'baseSalaryEarned': baseSalaryEarned,
        'overtimePay': overtimePay,
        'latePenalty': latePenalty,
        'totalAmount': totalAmount > 0 ? totalAmount : 0,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'employee': employee,
      };
    } catch (e) {
      _logger.e('Error calculating pending salary: $e');
      return _emptyPendingSalary();
    }
  }

  Map<String, dynamic> _emptyPendingSalary() {
    return {
      'paidDays': 0,
      'dailyRate': 0.0,
      'baseSalaryEarned': 0.0,
      'overtimePay': 0.0,
      'latePenalty': 0.0,
      'totalAmount': 0.0,
      'periodStart': DateTime.now(),
      'periodEnd': DateTime.now(),
      'employee': null,
    };
  }

  /// Parse attendance status from string (internal helper)
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

  /// Get semua pembayaran dalam periode
  Future<List<SalaryPaymentModel>> getAllPayments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _db.database;
      String query = 'SELECT * FROM $_salaryPaymentsTable';
      List<dynamic> args = [];

      if (startDate != null && endDate != null) {
        query += ' WHERE payment_date >= ? AND payment_date <= ?';
        args = [startDate.toIso8601String(), endDate.toIso8601String()];
      }

      query += ' ORDER BY payment_date DESC';

      final maps = await db.rawQuery(query, args);
      return maps.map((m) => SalaryPaymentModel.fromDatabase(m)).toList();
    } catch (e) {
      _logger.e('Error getting all payments: $e');
      return [];
    }
  }

  /// Get total pembayaran dalam periode
  Future<double> getTotalPayments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _db.database;
      String query =
          'SELECT SUM(total_amount) as total FROM $_salaryPaymentsTable';
      List<dynamic> args = [];

      if (startDate != null && endDate != null) {
        query += ' WHERE payment_date >= ? AND payment_date <= ?';
        args = [startDate.toIso8601String(), endDate.toIso8601String()];
      }

      final result = await db.rawQuery(query, args);
      return (result.first['total'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      _logger.e('Error getting total payments: $e');
      return 0;
    }
  }
}



