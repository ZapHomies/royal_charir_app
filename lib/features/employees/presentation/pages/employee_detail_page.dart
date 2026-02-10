import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/employee_model.dart';
import '../../providers/employee_provider.dart';
import 'employee_form_page.dart';
import 'salary_payment_page.dart';

/// Halaman detail karyawan
class EmployeeDetailPage extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeeAsync = ref.watch(employeeProvider(employeeId));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: employeeAsync.when(
        data: (employee) {
          if (employee == null) {
            return const Center(child: Text('Karyawan tidak ditemukan'));
          }
          return _EmployeeDetailContent(employee: employee);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmployeeDetailContent extends ConsumerWidget {
  final EmployeeModel employee;

  const _EmployeeDetailContent({required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // App Bar with profile
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          employee.name.isNotEmpty
                              ? employee.name[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      employee.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        employee.employeeCode,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeFormPage(employeeId: employee.id),
                  ),
                ).then((_) => ref.invalidate(employeeProvider(employee.id)));
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Karyawan'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Jabatan',
                        value: employee.position,
                        icon: Icons.work_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Departemen',
                        value: employee.department,
                        icon: Icons.business_rounded,
                        color: AppColors.accent,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Masa Kerja',
                        value: '${employee.yearsOfService} tahun',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.info,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Gaji/Hari',
                        value: PriceFormatter.formatCompact(
                            employee.totalDailySalary),
                        icon: Icons.attach_money_rounded,
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Salary Payment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalaryPaymentPage(
                            employeeId: employee.id,
                            employeeName: employee.name,
                            employeeCode: employee.employeeCode,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text(
                      'Ambil Gaji',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Info
                _buildSection(
                    'Informasi Pribadi',
                    Icons.person_rounded,
                    [
                      _InfoRow(
                          label: 'Telepon',
                          value: employee.phone ?? '-',
                          isDark: isDark),
                      _InfoRow(
                          label: 'Email',
                          value: employee.email ?? '-',
                          isDark: isDark),
                      _InfoRow(
                          label: 'Alamat',
                          value: employee.address ?? '-',
                          isDark: isDark),
                      _InfoRow(
                          label: 'NIK',
                          value: employee.identityNumber ?? '-',
                          isDark: isDark),
                      _InfoRow(
                        label: 'Tanggal Lahir',
                        value: employee.birthDate != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(employee.birthDate!)
                            : '-',
                        isDark: isDark,
                      ),
                    ],
                    isDark),

                const SizedBox(height: 16),

                // Work Info
                _buildSection(
                    'Informasi Pekerjaan',
                    Icons.work_rounded,
                    [
                      _InfoRow(
                          label: 'Kode Karyawan',
                          value: employee.employeeCode,
                          isDark: isDark),
                      _InfoRow(
                          label: 'Jabatan',
                          value: employee.position,
                          isDark: isDark),
                      _InfoRow(
                          label: 'Departemen',
                          value: employee.department,
                          isDark: isDark),
                      _InfoRow(
                        label: 'Tanggal Bergabung',
                        value: DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(employee.joinDate),
                        isDark: isDark,
                      ),
                    ],
                    isDark),

                const SizedBox(height: 16),

                // Salary Info
                _buildSection(
                    'Informasi Gaji (Per-Hari)',
                    Icons.attach_money_rounded,
                    [
                      _InfoRow(
                        label: 'Gaji Per-Hari',
                        value: PriceFormatter.format(employee.dailySalary),
                        isDark: isDark,
                        isHighlighted: true,
                      ),
                      _InfoRow(
                        label: 'Transport/Hari',
                        value: PriceFormatter.format(employee.dailyTransport),
                        isDark: isDark,
                      ),
                      _InfoRow(
                        label: 'Makan/Hari',
                        value: PriceFormatter.format(employee.dailyMeal),
                        isDark: isDark,
                      ),
                      _InfoRow(
                        label: 'Tunjangan Lain/Hari',
                        value: PriceFormatter.format(employee.dailyOther),
                        isDark: isDark,
                      ),
                      const Divider(),
                      _InfoRow(
                        label: 'Total Gaji/Hari',
                        value: PriceFormatter.format(employee.totalDailySalary),
                        isDark: isDark,
                        isHighlighted: true,
                        valueColor: AppColors.success,
                      ),
                      _InfoRow(
                        label: 'Estimasi/Bulan (26 hari)',
                        value: PriceFormatter.format(
                            employee.estimatedMonthlySalary),
                        isDark: isDark,
                        valueColor: AppColors.info,
                      ),
                    ],
                    isDark),

                const SizedBox(height: 16),

                // Bank Info
                _buildSection(
                    'Informasi Bank',
                    Icons.account_balance_rounded,
                    [
                      _InfoRow(
                          label: 'Nama Bank',
                          value: employee.bankName ?? '-',
                          isDark: isDark),
                      _InfoRow(
                          label: 'No. Rekening',
                          value: employee.bankAccount ?? '-',
                          isDark: isDark),
                    ],
                    isDark),

                const SizedBox(height: 16),

                // Emergency Contact
                _buildSection(
                    'Kontak Darurat',
                    Icons.emergency_rounded,
                    [
                      _InfoRow(
                          label: 'Nama',
                          value: employee.emergencyContact ?? '-',
                          isDark: isDark),
                      _InfoRow(
                          label: 'Telepon',
                          value: employee.emergencyPhone ?? '-',
                          isDark: isDark),
                    ],
                    isDark),

                if (employee.notes != null && employee.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                      'Catatan',
                      Icons.notes_rounded,
                      [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            employee.notes!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                      isDark),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title, IconData icon, List<Widget> children, bool isDark) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          ...children,
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Karyawan?'),
        content: Text('Apakah Anda yakin ingin menghapus ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final repository = ref.read(employeeRepositoryProvider);
              await repository.deleteEmployee(employee.id);
              ref.invalidate(employeesProvider);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Karyawan berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _QuickStatCard({
    required this.label,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isHighlighted;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isHighlighted = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ??
                    (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

