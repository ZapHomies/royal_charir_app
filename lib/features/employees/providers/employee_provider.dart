import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/employee_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/salary_slip_model.dart';
import '../data/models/leave_request_model.dart';
import '../data/repositories/employee_repository.dart';

/// Employee Repository Provider
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

/// All Employees Provider
final employeesProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllEmployees();
});

/// All Employees (including inactive) Provider
final allEmployeesProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllEmployees(activeOnly: false);
});

/// Single Employee Provider
final employeeProvider =
    FutureProvider.family<EmployeeModel?, String>((ref, id) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeById(id);
});

/// Employees by Department Provider
final employeesByDepartmentProvider =
    FutureProvider.family<List<EmployeeModel>, String>((ref, department) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeesByDepartment(department);
});

/// Search Employees Provider
final employeeSearchProvider =
    FutureProvider.family<List<EmployeeModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(employeesProvider).value ?? [];
  }
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.searchEmployees(query);
});

/// Today's Attendance Provider
final todayAttendanceProvider =
    FutureProvider<List<AttendanceModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getTodayAttendance();
});

/// Monthly Attendance Provider
final monthlyAttendanceProvider =
    FutureProvider.family<List<AttendanceModel>, ({int month, int year})>(
        (ref, params) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getMonthlyAttendance(params.month, params.year);
});

/// Employee Attendance Provider
final employeeAttendanceProvider = FutureProvider.family<
    List<AttendanceModel>,
    ({
      String employeeId,
      DateTime startDate,
      DateTime endDate
    })>((ref, params) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeAttendance(
      params.employeeId, params.startDate, params.endDate);
});

/// Salary Slips Provider
final salarySlipsProvider =
    FutureProvider.family<List<SalarySlipModel>, ({int? month, int? year})>(
        (ref, params) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllSalarySlips(month: params.month, year: params.year);
});

/// Employee Salary Slips Provider
final employeeSalarySlipsProvider =
    FutureProvider.family<List<SalarySlipModel>, String>(
        (ref, employeeId) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeSalarySlips(employeeId);
});

/// Single Salary Slip Provider
final salarySlipProvider =
    FutureProvider.family<SalarySlipModel?, String>((ref, id) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getSalarySlipById(id);
});

/// Employee Stats Provider - statistik ringkasan
final employeeStatsProvider = FutureProvider<EmployeeStats>((ref) async {
  final employees = await ref.watch(employeesProvider.future);
  final todayAttendance = await ref.watch(todayAttendanceProvider.future);

  final now = DateTime.now();
  final slips = await ref
      .watch(salarySlipsProvider((month: now.month, year: now.year)).future);

  double totalSalaryThisMonth = 0;
  for (final slip in slips) {
    totalSalaryThisMonth += slip.netSalary;
  }

  int presentToday = 0;
  int absentToday = 0;
  int lateToday = 0;

  for (final att in todayAttendance) {
    switch (att.status) {
      case AttendanceStatus.present:
        presentToday++;
        break;
      case AttendanceStatus.absent:
        absentToday++;
        break;
      case AttendanceStatus.late:
        lateToday++;
        break;
      default:
        break;
    }
  }

  // Hitung yang belum absen hari ini
  final checkedInIds = todayAttendance.map((a) => a.employeeId).toSet();
  final notCheckedIn =
      employees.where((e) => !checkedInIds.contains(e.id)).length;

  return EmployeeStats(
    totalEmployees: employees.length,
    presentToday: presentToday,
    absentToday: absentToday + notCheckedIn,
    lateToday: lateToday,
    totalSalaryThisMonth: totalSalaryThisMonth,
  );
});

/// Model untuk statistik karyawan
class EmployeeStats {
  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double totalSalaryThisMonth;

  const EmployeeStats({
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.totalSalaryThisMonth,
  });
}

/// Selected period for attendance view
final selectedAttendancePeriodProvider =
    StateProvider<({int month, int year})>((ref) {
  final now = DateTime.now();
  return (month: now.month, year: now.year);
});

/// Selected employee for detail view
final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

/// Employee search query provider
final employeeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Department filter provider
final departmentFilterProvider = StateProvider<String?>((ref) => null);

// ============= LEAVE REQUEST PROVIDERS =============

/// All Leave Requests Provider
final leaveRequestsProvider =
    FutureProvider.family<List<LeaveRequestModel>, LeaveStatus?>(
        (ref, status) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllLeaveRequests(status: status);
});

/// Pending Leave Requests Provider
final pendingLeaveRequestsProvider =
    FutureProvider<List<LeaveRequestModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllLeaveRequests(status: LeaveStatus.pending);
});

/// Employee Leave Requests Provider
final employeeLeaveRequestsProvider =
    FutureProvider.family<List<LeaveRequestModel>, String>(
        (ref, employeeId) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeLeaveRequests(employeeId);
});

/// Leave Balance Provider
final leaveBalanceProvider = FutureProvider.family<
    Map<LeaveType, LeaveBalanceModel>,
    ({String employeeId, int year})>((ref, params) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getLeaveBalance(params.employeeId, params.year);
});

/// Pending Leave Count Provider
final pendingLeaveCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getPendingLeaveRequestsCount();
});
