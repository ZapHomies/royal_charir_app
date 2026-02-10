import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/services/employee_print_service.dart';
import '../../providers/employee_provider.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/salary_slip_model.dart';
import 'employee_form_page.dart';
import 'employee_detail_page.dart';
import 'attendance_page.dart';
import 'salary_slip_page.dart';
import 'leave_management_page.dart';

/// Halaman utama manajemen karyawan dengan tab navigation
class EmployeeManagementPage extends ConsumerStatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  ConsumerState<EmployeeManagementPage> createState() =>
      _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends ConsumerState<EmployeeManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          _buildHeader(isDark),

          // Tab Bar
          _buildTabBar(isDark),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _EmployeeListTab(),
                _AttendanceTab(),
                _SalaryTab(),
                _StatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Karyawan',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Kelola karyawan, absensi, dan slip gaji',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats summary
              _buildQuickStats(isDark),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    final statsAsync = ref.watch(employeeStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildMiniStat(
            '${stats.totalEmployees}',
            'Karyawan',
            Icons.people_rounded,
            AppColors.primary,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildMiniStat(
            '${stats.presentToday}',
            'Hadir',
            Icons.check_circle_rounded,
            AppColors.success,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildMiniStat(
            '${stats.absentToday}',
            'Tidak Hadir',
            Icons.cancel_rounded,
            AppColors.error,
            isDark,
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMiniStat(
      String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle:
            AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(icon: Icon(Icons.people_rounded), text: 'Karyawan'),
          Tab(icon: Icon(Icons.access_time_rounded), text: 'Absensi'),
          Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Slip Gaji'),
          Tab(icon: Icon(Icons.analytics_rounded), text: 'Statistik'),
        ],
      ),
    );
  }

  Widget? _buildFAB(bool isDark) {
    // Only show FAB on employee list tab
    if (_tabController.index != 0) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeFormPage()),
        ).then((_) => ref.invalidate(employeesProvider));
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.person_add_rounded, color: Colors.white),
      label:
          const Text('Tambah Karyawan', style: TextStyle(color: Colors.white)),
    ).animate().scale(delay: 300.ms, duration: 200.ms);
  }
}

/// Tab 1: Daftar Karyawan
class _EmployeeListTab extends ConsumerWidget {
  const _EmployeeListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeesProvider);
    final searchQuery = ref.watch(employeeSearchQueryProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              ref.read(employeeSearchQueryProvider.notifier).state = value;
            },
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Cari karyawan...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Employee List
        Expanded(
          child: employeesAsync.when(
            data: (employees) {
              // Filter by search query
              final filtered = searchQuery.isEmpty
                  ? employees
                  : employees
                      .where((e) =>
                          e.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          e.employeeCode
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          e.position
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final employee = filtered[index];
                  return _EmployeeCard(employee: employee)
                      .animate(delay: Duration(milliseconds: 50 * index))
                      .fadeIn()
                      .slideX(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child:
                  Text('Error: $e', style: TextStyle(color: AppColors.error)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada karyawan',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan karyawan pertama dengan tombol di bawah',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk menampilkan karyawan
class _EmployeeCard extends ConsumerWidget {
  final EmployeeModel employee;

  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeDetailPage(employeeId: employee.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              employee.employeeCode,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${employee.position} • ${employee.department}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${PriceFormatter.format(employee.totalDailySalary)}/hari',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${employee.yearsOfService} tahun',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab 2: Absensi
class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayAttendance = ref.watch(todayAttendanceProvider);

    return Column(
      children: [
        // Quick Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.login_rounded,
                  label: 'Check-In',
                  color: AppColors.success,
                  onTap: () => _showCheckInDialog(context, ref),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.logout_rounded,
                  label: 'Check-Out',
                  color: AppColors.warning,
                  onTap: () => _showCheckOutDialog(context, ref),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Rekap',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AttendancePage()),
                    );
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),

        // Today's Attendance List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Absensi Hari Ini',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: todayAttendance.when(
            data: (attendances) {
              if (attendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada absensi hari ini',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  final att = attendances[index];
                  return _AttendanceCard(attendance: att)
                      .animate(delay: Duration(milliseconds: 50 * index))
                      .fadeIn()
                      .slideY(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  void _showCheckInDialog(BuildContext context, WidgetRef ref) async {
    final employees = await ref.read(employeesProvider.future);
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada karyawan terdaftar')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CheckInDialog(employees: employees),
    ).then((_) => ref.invalidate(todayAttendanceProvider));
  }

  void _showCheckOutDialog(BuildContext context, WidgetRef ref) async {
    final attendances = await ref.read(todayAttendanceProvider.future);
    final notCheckedOut = attendances.where((a) => a.checkOut == null).toList();

    if (notCheckedOut.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua karyawan sudah check-out')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CheckOutDialog(attendances: notCheckedOut),
    ).then((_) => ref.invalidate(todayAttendanceProvider));
  }
}

/// Card untuk quick action
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card untuk menampilkan absensi
class _AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const _AttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(attendance.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                getAttendanceStatusIcon(attendance.status),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  getAttendanceStatusDisplayName(attendance.status),
                  style: AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ],
            ),
          ),

          // Times
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (attendance.checkIn != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_rounded,
                        size: 12, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(attendance.checkIn!),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (attendance.checkOut != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(attendance.checkOut!),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.sick:
        return AppColors.info;
      case AttendanceStatus.leave:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}

/// Tab 3: Slip Gaji
class _SalaryTab extends ConsumerWidget {
  const _SalaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final slipsAsync =
        ref.watch(salarySlipsProvider((month: now.month, year: now.year)));

    return Column(
      children: [
        // Generate Salary Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generate Slip Gaji',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Buat slip gaji otomatis untuk bulan ini',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _generateSlips(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Period selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Slip Gaji ${DateFormat('MMMM y', 'id_ID').format(DateTime.now())}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalarySlipPage()),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),

        // Salary slips list
        Expanded(
          child: slipsAsync.when(
            data: (slips) {
              if (slips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada slip gaji bulan ini',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: slips.length,
                itemBuilder: (context, index) {
                  final slip = slips[index];
                  return _SalarySlipCard(slip: slip);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Future<void> _generateSlips(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final repository = ref.read(employeeRepositoryProvider);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await repository.generateMonthlySlips(now.month, now.year);
      Navigator.pop(context);
      ref.invalidate(salarySlipsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slip gaji berhasil di-generate!')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

/// Card untuk slip gaji
class _SalarySlipCard extends StatelessWidget {
  final dynamic slip;

  const _SalarySlipCard({required this.slip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slip.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  slip.slipNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.format(slip.netSalary),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: slip.status == SalarySlipStatus.paid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  slip.statusDisplayName,
                  style: AppTextStyles.caption.copyWith(
                    color: slip.status == SalarySlipStatus.paid
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab 4: Statistik
class _StatisticsTab extends ConsumerWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(employeeStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: statsAsync.when(
        data: (stats) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Karyawan',
                    value: '${stats.totalEmployees}',
                    icon: Icons.people_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Hadir Hari Ini',
                    value: '${stats.presentToday}',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Terlambat Hari Ini',
                    value: '${stats.lateToday}',
                    icon: Icons.access_time_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Gaji Bulan Ini',
                    value: PriceFormatter.formatCompact(
                        stats.totalSalaryThisMonth),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.info,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Department breakdown
            Text(
              'Karyawan per Departemen',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...EmployeeDepartments.all.map((dept) {
              return FutureBuilder<List<EmployeeModel>>(
                future: ref
                    .read(employeeRepositoryProvider)
                    .getEmployeesByDepartment(dept),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _DepartmentRow(
                    department: dept,
                    count: count,
                    isDark: isDark,
                  );
                },
              );
            }),

            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Aksi Cepat',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Leave Management Button
            _QuickActionButton(
              icon: Icons.event_note_rounded,
              label: 'Manajemen Cuti',
              subtitle: 'Kelola pengajuan cuti karyawan',
              color: AppColors.accent,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LeaveManagementPage()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Export Buttons
            _QuickActionButton(
              icon: Icons.print_rounded,
              label: 'Cetak Laporan Absensi',
              subtitle: 'Export absensi ke PDF',
              color: AppColors.info,
              isDark: isDark,
              onTap: () async {
                final now = DateTime.now();
                final employees = await ref.read(employeesProvider.future);
                final attendances = await ref.read(monthlyAttendanceProvider(
                    (month: now.month, year: now.year)).future);
                await EmployeePrintService.printAttendanceReport(
                  employees: employees,
                  attendances: attendances,
                  month: now.month,
                  year: now.year,
                );
              },
            ),
            const SizedBox(height: 8),

            _QuickActionButton(
              icon: Icons.file_download_rounded,
              label: 'Export Data ke CSV',
              subtitle: 'Download data karyawan',
              color: AppColors.success,
              isDark: isDark,
              onTap: () => _showExportDialog(context, ref),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  final String department;
  final int count;
  final bool isDark;

  const _DepartmentRow({
    required this.department,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            department,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count orang',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button for statistics tab
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Export dialog
void _showExportDialog(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Data Karyawan'),
            subtitle: const Text('Export semua data karyawan ke CSV'),
            onTap: () async {
              Navigator.pop(context);
              final repository = ref.read(employeeRepositoryProvider);
              final csv = await repository.exportEmployeesToCsv();
              _showCsvResult(context, 'Data Karyawan', csv);
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('Rekap Absensi'),
            subtitle: const Text('Export absensi bulan ini ke CSV'),
            onTap: () async {
              Navigator.pop(context);
              final repository = ref.read(employeeRepositoryProvider);
              final now = DateTime.now();
              final csv =
                  await repository.exportAttendanceToCsv(now.month, now.year);
              _showCsvResult(context, 'Rekap Absensi', csv);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Rekap Gaji'),
            subtitle: const Text('Export slip gaji bulan ini ke CSV'),
            onTap: () async {
              Navigator.pop(context);
              final repository = ref.read(employeeRepositoryProvider);
              final now = DateTime.now();
              final csv =
                  await repository.exportSalarySlipsToCsv(now.month, now.year);
              _showCsvResult(context, 'Rekap Gaji', csv);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    ),
  );
}

void _showCsvResult(BuildContext context, String title, String csv) {
  if (csv.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak ada data untuk diexport')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$title - CSV'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: csv));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data sudah di-copy ke clipboard!')),
            );
          },
          child: const Text('Copy ke Clipboard'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

/// Dialog Check-In Batch (Checklist)
class _CheckInDialog extends ConsumerStatefulWidget {
  final List<EmployeeModel> employees;

  const _CheckInDialog({required this.employees});

  @override
  ConsumerState<_CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<_CheckInDialog> {
  final Set<String> _selectedEmployeeIds = {};
  bool _isLoading = false;
  AttendanceStatus _selectedStatus = AttendanceStatus.present;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      title: Row(
        children: [
          Icon(Icons.login_rounded, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            'Check-In Karyawan',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status selector
            Text(
              'Status Absensi:',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _StatusChip(
                  status: AttendanceStatus.present,
                  isSelected: _selectedStatus == AttendanceStatus.present,
                  onTap: () => setState(
                      () => _selectedStatus = AttendanceStatus.present),
                ),
                _StatusChip(
                  status: AttendanceStatus.sick,
                  isSelected: _selectedStatus == AttendanceStatus.sick,
                  onTap: () =>
                      setState(() => _selectedStatus = AttendanceStatus.sick),
                ),
                _StatusChip(
                  status: AttendanceStatus.permission,
                  isSelected: _selectedStatus == AttendanceStatus.permission,
                  onTap: () => setState(
                      () => _selectedStatus = AttendanceStatus.permission),
                ),
                _StatusChip(
                  status: AttendanceStatus.leave,
                  isSelected: _selectedStatus == AttendanceStatus.leave,
                  onTap: () =>
                      setState(() => _selectedStatus = AttendanceStatus.leave),
                ),
                _StatusChip(
                  status: AttendanceStatus.holidayPaid,
                  isSelected: _selectedStatus == AttendanceStatus.holidayPaid,
                  onTap: () => setState(
                      () => _selectedStatus = AttendanceStatus.holidayPaid),
                ),
                _StatusChip(
                  status: AttendanceStatus.holidayUnpaid,
                  isSelected: _selectedStatus == AttendanceStatus.holidayUnpaid,
                  onTap: () => setState(
                      () => _selectedStatus = AttendanceStatus.holidayUnpaid),
                ),
                _StatusChip(
                  status: AttendanceStatus.workFromHome,
                  isSelected: _selectedStatus == AttendanceStatus.workFromHome,
                  onTap: () => setState(
                      () => _selectedStatus = AttendanceStatus.workFromHome),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Select all / deselect all
            Row(
              children: [
                Text(
                  'Pilih Karyawan (${_selectedEmployeeIds.length}/${widget.employees.length}):',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedEmployeeIds.length ==
                          widget.employees.length) {
                        _selectedEmployeeIds.clear();
                      } else {
                        _selectedEmployeeIds.clear();
                        _selectedEmployeeIds
                            .addAll(widget.employees.map((e) => e.id));
                      }
                    });
                  },
                  child: Text(
                    _selectedEmployeeIds.length == widget.employees.length
                        ? 'Batalkan Semua'
                        : 'Pilih Semua',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Employee list with checkboxes
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: widget.employees.length,
                  itemBuilder: (context, index) {
                    final emp = widget.employees[index];
                    final isSelected = _selectedEmployeeIds.contains(emp.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedEmployeeIds.add(emp.id);
                          } else {
                            _selectedEmployeeIds.remove(emp.id);
                          }
                        });
                      },
                      title: Text(emp.name),
                      subtitle: Text('${emp.employeeCode} • ${emp.position}'),
                      secondary: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          emp.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      activeColor: AppColors.success,
                      dense: true,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Waktu: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedEmployeeIds.isEmpty || _isLoading
              ? null
              : _performBatchCheckIn,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text('Check-In (${_selectedEmployeeIds.length})'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
        ),
      ],
    );
  }

  Future<void> _performBatchCheckIn() async {
    if (_selectedEmployeeIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(employeeRepositoryProvider);
      int successCount = 0;

      for (final employeeId in _selectedEmployeeIds) {
        final employee = widget.employees.firstWhere((e) => e.id == employeeId);

        if (_selectedStatus == AttendanceStatus.present) {
          await repository.checkIn(employee.id, employee.name);
        } else {
          // For other statuses (sick, permission, leave, WFH), create attendance with that status
          final attendance = AttendanceModel.create(
            employeeId: employee.id,
            employeeName: employee.name,
            date: DateTime.now(),
            checkIn: DateTime.now(),
            status: _selectedStatus,
          );
          await repository.addAttendance(attendance);
        }
        successCount++;
      }

      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '$successCount karyawan berhasil di-check-in dengan status ${getAttendanceStatusDisplayName(_selectedStatus)}!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

/// Status chip for attendance selection
class _StatusChip extends StatelessWidget {
  final AttendanceStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(getAttendanceStatusIcon(status),
                style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              getAttendanceStatusDisplayName(status),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.sick:
        return AppColors.warning;
      case AttendanceStatus.leave:
        return AppColors.info;
      case AttendanceStatus.permission:
        return AppColors.accent;
      case AttendanceStatus.holidayPaid:
        return Colors.green;
      case AttendanceStatus.holidayUnpaid:
        return Colors.grey;
      case AttendanceStatus.workFromHome:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

/// Dialog Check-Out Batch (Checklist)
class _CheckOutDialog extends ConsumerStatefulWidget {
  final List<AttendanceModel> attendances;

  const _CheckOutDialog({required this.attendances});

  @override
  ConsumerState<_CheckOutDialog> createState() => _CheckOutDialogState();
}

class _CheckOutDialogState extends ConsumerState<_CheckOutDialog> {
  final Set<String> _selectedAttendanceIds = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      title: Row(
        children: [
          Icon(Icons.logout_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          Text(
            'Check-Out Karyawan',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select all / deselect all
            Row(
              children: [
                Text(
                  'Pilih Karyawan (${_selectedAttendanceIds.length}/${widget.attendances.length}):',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedAttendanceIds.length ==
                          widget.attendances.length) {
                        _selectedAttendanceIds.clear();
                      } else {
                        _selectedAttendanceIds.clear();
                        _selectedAttendanceIds
                            .addAll(widget.attendances.map((a) => a.id));
                      }
                    });
                  },
                  child: Text(
                    _selectedAttendanceIds.length == widget.attendances.length
                        ? 'Batalkan Semua'
                        : 'Pilih Semua',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Attendance list with checkboxes
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: widget.attendances.length,
                  itemBuilder: (context, index) {
                    final att = widget.attendances[index];
                    final isSelected = _selectedAttendanceIds.contains(att.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedAttendanceIds.add(att.id);
                          } else {
                            _selectedAttendanceIds.remove(att.id);
                          }
                        });
                      },
                      title: Text(att.employeeName),
                      subtitle: Text(
                        'Check-in: ${att.checkIn != null ? DateFormat("HH:mm").format(att.checkIn!) : "-"}',
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(getAttendanceStatusIcon(att.status)),
                      ),
                      activeColor: AppColors.warning,
                      dense: true,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Waktu Check-Out: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedAttendanceIds.isEmpty || _isLoading
              ? null
              : _performBatchCheckOut,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text('Check-Out (${_selectedAttendanceIds.length})'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
        ),
      ],
    );
  }

  Future<void> _performBatchCheckOut() async {
    if (_selectedAttendanceIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(employeeRepositoryProvider);
      int successCount = 0;

      for (final attendanceId in _selectedAttendanceIds) {
        await repository.checkOut(attendanceId);
        successCount++;
      }

      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount karyawan berhasil check-out!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
