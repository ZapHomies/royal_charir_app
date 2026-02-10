import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/employee_model.dart';
import '../../providers/employee_provider.dart';

/// Halaman form untuk menambah/edit karyawan
class EmployeeFormPage extends ConsumerStatefulWidget {
  final String? employeeId; // null = tambah baru

  const EmployeeFormPage({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEdit = false;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _transportController = TextEditingController();
  final _mealController = TextEditingController();
  final _otherAllowanceController = TextEditingController();
  final _identityController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPosition = EmployeePositions.staff;
  String _selectedDepartment = EmployeeDepartments.general;
  DateTime _joinDate = DateTime.now();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.employeeId != null;
    if (_isEdit) {
      _loadEmployee();
    }
  }

  Future<void> _loadEmployee() async {
    final repository = ref.read(employeeRepositoryProvider);
    final employee = await repository.getEmployeeById(widget.employeeId!);
    if (employee != null) {
      setState(() {
        _nameController.text = employee.name;
        _phoneController.text = employee.phone ?? '';
        _emailController.text = employee.email ?? '';
        _addressController.text = employee.address ?? '';
        _baseSalaryController.text = employee.dailySalary.toStringAsFixed(0);
        _transportController.text = employee.dailyTransport.toStringAsFixed(0);
        _mealController.text = employee.dailyMeal.toStringAsFixed(0);
        _otherAllowanceController.text = employee.dailyOther.toStringAsFixed(0);
        _identityController.text = employee.identityNumber ?? '';
        _bankAccountController.text = employee.bankAccount ?? '';
        _bankNameController.text = employee.bankName ?? '';
        _emergencyContactController.text = employee.emergencyContact ?? '';
        _emergencyPhoneController.text = employee.emergencyPhone ?? '';
        _notesController.text = employee.notes ?? '';
        _selectedPosition = employee.position;
        _selectedDepartment = employee.department;
        _joinDate = employee.joinDate;
        _birthDate = employee.birthDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _baseSalaryController.dispose();
    _transportController.dispose();
    _mealController.dispose();
    _otherAllowanceController.dispose();
    _identityController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Karyawan' : 'Tambah Karyawan'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveEmployee,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Simpan'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data Pribadi
              _buildSectionTitle('Data Pribadi', Icons.person_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline_rounded,
                  required: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'No. Telepon',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Alamat',
                  icon: Icons.location_on_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _identityController,
                        label: 'NIK/KTP',
                        icon: Icons.badge_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Tanggal Lahir',
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ], isDark),

              const SizedBox(height: 24),

              // Data Pekerjaan
              _buildSectionTitle('Data Pekerjaan', Icons.work_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Jabatan',
                        value: _selectedPosition,
                        items: EmployeePositions.all,
                        onChanged: (v) =>
                            setState(() => _selectedPosition = v!),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Departemen',
                        value: _selectedDepartment,
                        items: EmployeeDepartments.all,
                        onChanged: (v) =>
                            setState(() => _selectedDepartment = v!),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  label: 'Tanggal Bergabung',
                  value: _joinDate,
                  onChanged: (date) => setState(() => _joinDate = date!),
                  isDark: isDark,
                  required: true,
                ),
              ], isDark),

              const SizedBox(height: 24),

              // Data Gaji
              _buildSectionTitle(
                  'Data Gaji', Icons.attach_money_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: _baseSalaryController,
                  label: 'Gaji Per-Hari (Rp)',
                  icon: Icons.money_rounded,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _transportController,
                        label: 'Transport/Hari',
                        icon: Icons.directions_car_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _mealController,
                        label: 'Makan/Hari',
                        icon: Icons.restaurant_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _otherAllowanceController,
                  label: 'Tunjangan Lain/Hari',
                  icon: Icons.add_card_rounded,
                  keyboardType: TextInputType.number,
                ),
              ], isDark),

              const SizedBox(height: 24),

              // Data Bank
              _buildSectionTitle(
                  'Data Bank', Icons.account_balance_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _bankNameController,
                        label: 'Nama Bank',
                        icon: Icons.account_balance_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bankAccountController,
                        label: 'No. Rekening',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ], isDark),

              const SizedBox(height: 24),

              // Kontak Darurat
              _buildSectionTitle(
                  'Kontak Darurat', Icons.emergency_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emergencyContactController,
                        label: 'Nama Kontak Darurat',
                        icon: Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _emergencyPhoneController,
                        label: 'No. Telepon Darurat',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
              ], isDark),

              const SizedBox(height: 24),

              // Catatan
              _buildSectionTitle('Catatan', Icons.notes_rounded, isDark),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan tambahan',
                  icon: Icons.note_rounded,
                  maxLines: 3,
                ),
              ], isDark),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children, bool isDark) {
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
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (value) => value?.isEmpty == true ? '$label wajib diisi' : null
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    required bool isDark,
    bool required = false,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          value != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(value)
              : 'Pilih tanggal',
          style: TextStyle(
            color: value != null
                ? (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)
                : (isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(employeeRepositoryProvider);

      if (_isEdit) {
        final existing = await repository.getEmployeeById(widget.employeeId!);
        if (existing != null) {
          final updated = existing.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            position: _selectedPosition,
            department: _selectedDepartment,
            dailySalary: double.tryParse(_baseSalaryController.text) ?? 0,
            dailyTransport: double.tryParse(_transportController.text) ?? 0,
            dailyMeal: double.tryParse(_mealController.text) ?? 0,
            dailyOther: double.tryParse(_otherAllowanceController.text) ?? 0,
            joinDate: _joinDate,
            birthDate: _birthDate,
            identityNumber: _identityController.text.trim(),
            bankAccount: _bankAccountController.text.trim(),
            bankName: _bankNameController.text.trim(),
            emergencyContact: _emergencyContactController.text.trim(),
            emergencyPhone: _emergencyPhoneController.text.trim(),
            notes: _notesController.text.trim(),
            updatedAt: DateTime.now(),
          );
          await repository.updateEmployee(updated);
        }
      } else {
        final code = await repository.generateEmployeeCode();
        final employee = EmployeeModel.create(
          employeeCode: code,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          position: _selectedPosition,
          department: _selectedDepartment,
          dailySalary: double.tryParse(_baseSalaryController.text) ?? 0,
          dailyTransport: double.tryParse(_transportController.text) ?? 0,
          dailyMeal: double.tryParse(_mealController.text) ?? 0,
          dailyOther: double.tryParse(_otherAllowanceController.text) ?? 0,
          joinDate: _joinDate,
          birthDate: _birthDate,
          identityNumber: _identityController.text.trim(),
          bankAccount: _bankAccountController.text.trim(),
          bankName: _bankNameController.text.trim(),
          emergencyContact: _emergencyContactController.text.trim(),
          emergencyPhone: _emergencyPhoneController.text.trim(),
          notes: _notesController.text.trim(),
        );
        await repository.addEmployee(employee);
      }

      HapticFeedback.mediumImpact();
      ref.invalidate(employeesProvider);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Karyawan berhasil diupdate!'
              : 'Karyawan berhasil ditambahkan!'),
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

