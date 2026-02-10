import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/leave_request_model.dart';
import '../../providers/employee_provider.dart';

/// Halaman manajemen pengajuan cuti
class LeaveManagementPage extends ConsumerStatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  ConsumerState<LeaveManagementPage> createState() =>
      _LeaveManagementPageState();
}

class _LeaveManagementPageState extends ConsumerState<LeaveManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = ref.watch(pendingLeaveCountProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manajemen Cuti'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tertunda'),
                  const SizedBox(width: 8),
                  pendingCount.when(
                    data: (count) => count > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Tab(text: 'Disetujui'),
            const Tab(text: 'Semua'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LeaveRequestList(status: LeaveStatus.pending),
          _LeaveRequestList(status: LeaveStatus.approved),
          _LeaveRequestList(status: null),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeaveDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Ajukan Cuti', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddLeaveDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddLeaveRequestSheet(),
    ).then((_) {
      ref.invalidate(leaveRequestsProvider);
      ref.invalidate(pendingLeaveCountProvider);
    });
  }
}

/// List pengajuan cuti
class _LeaveRequestList extends ConsumerWidget {
  final LeaveStatus? status;

  const _LeaveRequestList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(leaveRequestsProvider(status));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 48,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pengajuan cuti',
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
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _LeaveRequestCard(request: request)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn()
                .slideY(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

/// Card pengajuan cuti
class _LeaveRequestCard extends ConsumerWidget {
  final LeaveRequestModel request;

  const _LeaveRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

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
          onTap: () => _showDetailDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getTypeColor(request.leaveType)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          getLeaveTypeIcon(request.leaveType),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                request.employeeName,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              _StatusBadge(status: request.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getLeaveTypeDisplayName(request.leaveType),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _getTypeColor(request.leaveType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Date Range
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${dateFormat.format(request.startDate)} - ${dateFormat.format(request.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${request.totalDays} hari',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Reason
                const SizedBox(height: 8),
                Text(
                  request.reason,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Actions for pending
                if (request.status == LeaveStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _rejectRequest(context, ref),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        child: const Text('Tolak'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _approveRequest(context, ref),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success),
                        child: const Text('Setujui',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return AppColors.primary;
      case LeaveType.sick:
        return AppColors.warning;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return AppColors.accent;
      case LeaveType.marriage:
        return AppColors.info;
      case LeaveType.bereavement:
        return Colors.grey;
      case LeaveType.emergency:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Row(
          children: [
            Text(getLeaveTypeIcon(request.leaveType)),
            const SizedBox(width: 8),
            Text('Detail Pengajuan'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('No. Pengajuan', request.requestNumber, isDark),
              _DetailRow('Nama', request.employeeName, isDark),
              _DetailRow('Kode', request.employeeCode, isDark),
              _DetailRow('Tipe Cuti',
                  getLeaveTypeDisplayName(request.leaveType), isDark),
              _DetailRow('Tanggal Mulai', dateFormat.format(request.startDate),
                  isDark),
              _DetailRow('Tanggal Selesai', dateFormat.format(request.endDate),
                  isDark),
              _DetailRow('Total Hari', '${request.totalDays} hari', isDark),
              _DetailRow(
                  'Status', getLeaveStatusDisplayName(request.status), isDark),
              const SizedBox(height: 12),
              Text('Alasan:', style: AppTextStyles.labelMedium),
              const SizedBox(height: 4),
              Text(request.reason, style: AppTextStyles.bodySmall),
              if (request.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Text('Alasan Penolakan:',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.error)),
                const SizedBox(height: 4),
                Text(request.rejectionReason!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Cuti?'),
        content: Text(
            'Apakah Anda yakin ingin menyetujui pengajuan cuti ${request.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Setujui', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(employeeRepositoryProvider);
      await repository.approveLeaveRequest(request.id, 'Admin');
      ref.invalidate(leaveRequestsProvider);
      ref.invalidate(pendingLeaveCountProvider);

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cuti disetujui!')),
      );
    }
  }

  void _rejectRequest(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Cuti?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Berikan alasan penolakan untuk ${request.employeeName}:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      final repository = ref.read(employeeRepositoryProvider);
      await repository.rejectLeaveRequest(request.id, reasonController.text);
      ref.invalidate(leaveRequestsProvider);
      ref.invalidate(pendingLeaveCountProvider);

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cuti ditolak')),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              )),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

/// Status badge
class _StatusBadge extends StatelessWidget {
  final LeaveStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getLeaveStatusIcon(status),
              style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            getLeaveStatusDisplayName(status),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case LeaveStatus.pending:
        return AppColors.warning;
      case LeaveStatus.approved:
        return AppColors.success;
      case LeaveStatus.rejected:
        return AppColors.error;
      case LeaveStatus.cancelled:
        return Colors.grey;
      case LeaveStatus.completed:
        return AppColors.info;
    }
  }
}

/// Bottom sheet untuk menambah pengajuan cuti
class _AddLeaveRequestSheet extends ConsumerStatefulWidget {
  const _AddLeaveRequestSheet();

  @override
  ConsumerState<_AddLeaveRequestSheet> createState() =>
      _AddLeaveRequestSheetState();
}

class _AddLeaveRequestSheetState extends ConsumerState<_AddLeaveRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  LeaveType _selectedType = LeaveType.annual;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeesProvider);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Ajukan Cuti Baru',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // Select Employee
              employeesAsync.when(
                data: (employees) => DropdownButtonFormField<String>(
                  value: _selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Karyawan',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  items: employees.map((e) {
                    return DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.employeeCode} - ${e.name}'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedEmployeeId = value),
                  validator: (value) => value == null ? 'Pilih karyawan' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading employees'),
              ),
              const SizedBox(height: 16),

              // Leave Type
              DropdownButtonFormField<LeaveType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Cuti',
                  prefixIcon: Icon(Icons.event_note_rounded),
                ),
                items: LeaveType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(getLeaveTypeIcon(type)),
                        const SizedBox(width: 8),
                        Text(getLeaveTypeDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                            if (_endDate.isBefore(_startDate)) {
                              _endDate = _startDate;
                            }
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(dateFormat.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(dateFormat.format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan',
                  prefixIcon: Icon(Icons.note_rounded),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Masukkan alasan' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Ajukan Cuti',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployeeId == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(employeeRepositoryProvider);
      final employees = await ref.read(employeesProvider.future);
      final employee = employees.firstWhere((e) => e.id == _selectedEmployeeId);

      final requestNumber = await repository.generateLeaveRequestNumber();

      final request = LeaveRequestModel.create(
        requestNumber: requestNumber,
        employeeId: employee.id,
        employeeName: employee.name,
        employeeCode: employee.employeeCode,
        leaveType: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text.trim(),
      );

      await repository.addLeaveRequest(request);

      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cuti berhasil diajukan!')),
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


