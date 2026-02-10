import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/salary_payment_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../../../finance/data/models/expense_model.dart';
import '../../../finance/providers/expense_provider.dart';

/// Halaman Pengambilan Gaji
class SalaryPaymentPage extends ConsumerStatefulWidget {
  final String employeeId;
  final String employeeName;
  final String employeeCode;

  const SalaryPaymentPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
  });

  @override
  ConsumerState<SalaryPaymentPage> createState() => _SalaryPaymentPageState();
}

class _SalaryPaymentPageState extends ConsumerState<SalaryPaymentPage> {
  final _repository = EmployeeRepository();
  bool _isLoading = true;
  bool _isProcessing = false;

  Map<String, dynamic> _pendingSalary = {};
  List<SalaryPaymentModel> _paymentHistory = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final pending = await _repository.calculatePendingSalary(widget.employeeId);
    final history = await _repository.getEmployeePayments(widget.employeeId);

    setState(() {
      _pendingSalary = pending;
      _paymentHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _processPayment(PaymentType type) async {
    if (_pendingSalary['totalAmount'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gaji yang dapat diambil')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Karyawan: ${widget.employeeName}'),
            Text('Periode: ${_formatPeriod()}'),
            Text('Hari Kerja: ${_pendingSalary['paidDays']} hari'),
            const SizedBox(height: 8),
            Text(
              'Total: ${PriceFormatter.format(_pendingSalary['totalAmount'])}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            child: const Text('Proses Pembayaran'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    final payment = SalaryPaymentModel.create(
      employeeId: widget.employeeId,
      employeeName: widget.employeeName,
      employeeCode: widget.employeeCode,
      periodStart: _pendingSalary['periodStart'],
      periodEnd: _pendingSalary['periodEnd'],
      paidDays: _pendingSalary['paidDays'],
      dailyRate: _pendingSalary['dailyRate'],
      baseSalaryEarned: _pendingSalary['baseSalaryEarned'],
      overtimePay: _pendingSalary['overtimePay'],
      latePenalty: _pendingSalary['latePenalty'],
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      type: type,
      paidBy: 'Admin', // TODO: Get from logged in user
    );

    final success = await _repository.addSalaryPayment(payment);

    if (success) {
      // Catat ke pengeluaran keuangan
      final now = DateTime.now();
      final expense = ExpenseModel(
        id: const Uuid().v4(),
        category: 'karyawan',
        description:
            'Gaji ${widget.employeeName} (${widget.employeeCode}) - ${_pendingSalary['paidDays']} hari',
        amount: payment.totalAmount,
        expenseDate: now,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: now,
        updatedAt: now,
      );

      try {
        await ref.read(expensesProvider.notifier).addExpense(expense);
      } catch (e) {
        debugPrint('Error adding expense: $e');
      }

      setState(() => _isProcessing = false);

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Pembayaran ${PriceFormatter.format(payment.totalAmount)} berhasil diproses dan tercatat di keuangan'),
          backgroundColor: Colors.green,
        ),
      );
      _notesController.clear();
      _loadData(); // Refresh data
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPeriod() {
    if (_pendingSalary['periodStart'] == null) return '-';
    final start = _pendingSalary['periodStart'] as DateTime;
    final end = _pendingSalary['periodEnd'] as DateTime;
    final df = DateFormat('dd/MM/yyyy');
    return '${df.format(start)} - ${df.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pengambilan Gaji'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmployeeInfo(isDark),
                    const SizedBox(height: 16),
                    _buildPendingSalaryCard(isDark),
                    const SizedBox(height: 16),
                    _buildPaymentButton(isDark),
                    const SizedBox(height: 24),
                    _buildPaymentHistory(isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmployeeInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employeeName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode: ${widget.employeeCode}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSalaryCard(bool isDark) {
    final paidDays = _pendingSalary['paidDays'] as int? ?? 0;
    final dailyRate = _pendingSalary['dailyRate'] as double? ?? 0;
    final baseSalary = _pendingSalary['baseSalaryEarned'] as double? ?? 0;
    final overtime = _pendingSalary['overtimePay'] as double? ?? 0;
    final penalty = _pendingSalary['latePenalty'] as double? ?? 0;
    final total = _pendingSalary['totalAmount'] as double? ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gaji Belum Diambil',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatPeriod(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            PriceFormatter.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          _buildSalaryDetailRow('Hari Kerja', '$paidDays hari'),
          _buildSalaryDetailRow('Gaji/Hari', PriceFormatter.format(dailyRate)),
          _buildSalaryDetailRow(
              'Gaji Pokok', PriceFormatter.format(baseSalary)),
          if (overtime > 0)
            _buildSalaryDetailRow(
                'Lembur', '+ ${PriceFormatter.format(overtime)}'),
          if (penalty > 0)
            _buildSalaryDetailRow(
                'Potongan Telat', '- ${PriceFormatter.format(penalty)}'),
        ],
      ),
    );
  }

  Widget _buildSalaryDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Catatan (opsional)',
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                _isProcessing || (_pendingSalary['totalAmount'] ?? 0) <= 0
                    ? null
                    : () => _processPayment(PaymentType.full),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.payments_rounded),
            label: Text(
              _isProcessing ? 'Memproses...' : 'Proses Pembayaran Gaji',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Pembayaran',
          style: AppTextStyles.titleSmall.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_paymentHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat pembayaran',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = _paymentHistory[index];
              return _PaymentHistoryItem(payment: payment, isDark: isDark);
            },
          ),
      ],
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final SalaryPaymentModel payment;
  final bool isDark;

  const _PaymentHistoryItem({required this.payment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  df.format(payment.paymentDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${payment.paidDays} hari kerja • ${payment.periodFormatted}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            PriceFormatter.format(payment.totalAmount),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
