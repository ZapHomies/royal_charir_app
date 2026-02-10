import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../features/employees/data/models/employee_model.dart';
import '../../features/employees/data/models/salary_slip_model.dart';
import '../../features/employees/data/models/attendance_model.dart';
import '../utils/price_formatter.dart';

/// Service untuk print slip gaji dan laporan karyawan
class EmployeePrintService {
  // A4 Portrait format
  static const PdfPageFormat a4Format = PdfPageFormat.a4;

  // Text styles
  static final _companyNameStyle = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );

  static final _titleStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
  );

  static const _normalStyle = pw.TextStyle(fontSize: 10);

  static final _boldStyle = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
  );

  static const _smallStyle = pw.TextStyle(fontSize: 9);

  static final _headerStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  /// Print Slip Gaji ke PDF
  static Future<void> printSalarySlip(SalarySlipModel slip) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    pdf.addPage(
      pw.Page(
        pageFormat: a4Format,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildSlipHeader(slip),
              pw.SizedBox(height: 20),

              // Employee Info
              _buildEmployeeInfo(slip),
              pw.SizedBox(height: 20),

              // Income & Deductions in two columns
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Pendapatan
                  pw.Expanded(
                    child: _buildIncomeSection(slip),
                  ),
                  pw.SizedBox(width: 20),
                  // Potongan
                  pw.Expanded(
                    child: _buildDeductionSection(slip),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Attendance Summary
              _buildAttendanceSummary(slip),
              pw.SizedBox(height: 20),

              // Net Salary
              _buildNetSalary(slip),
              pw.SizedBox(height: 30),

              // Signatures
              _buildSignatures(),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Dicetak pada: ${dateFormat.format(DateTime.now())}',
                  style: _smallStyle,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SlipGaji_${slip.slipNumber}',
      format: a4Format,
    );
  }

  static pw.Widget _buildSlipHeader(SalarySlipModel slip) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ROYAL CHARIR', style: _companyNameStyle),
                pw.Text('Furniture & Bedding Textile', style: _smallStyle),
                pw.Text('Jl. Tirtorejo, Nanggungan, Cukir, Diwek',
                    style: _smallStyle),
                pw.Text('Jombang 61471 | WA: 0858-5300-5902',
                    style: _smallStyle),
              ],
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
              ),
              child: pw.Column(
                children: [
                  pw.Text('SLIP GAJI', style: _titleStyle),
                  pw.Text(slip.periodFormatted, style: _boldStyle),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          height: 2,
          color: PdfColors.black,
        ),
      ],
    );
  }

  static pw.Widget _buildEmployeeInfo(SalarySlipModel slip) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Kode Karyawan', slip.employeeCode),
                _infoRow('Nama', slip.employeeName),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Jabatan', slip.position),
                _infoRow('Departemen', slip.department),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('No. Slip', slip.slipNumber),
                _infoRow('Status', slip.statusDisplayName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text('$label:', style: _smallStyle),
          ),
          pw.Text(value, style: _boldStyle),
        ],
      ),
    );
  }

  static pw.Widget _buildIncomeSection(SalarySlipModel slip) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          _sectionHeader('PENDAPATAN', PdfColors.green700),
          _amountRow('Gaji Pokok', slip.baseSalary),
          _amountRow('Tunjangan Transport', slip.transportAllowance),
          _amountRow('Tunjangan Makan', slip.mealAllowance),
          _amountRow('Tunjangan Lain', slip.otherAllowance),
          _amountRow('Lembur', slip.overtimePay),
          _amountRow('Bonus', slip.bonus),
          _amountRow('Pendapatan Lain', slip.otherIncome),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.green100,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL PENDAPATAN', style: _boldStyle),
                pw.Text(PriceFormatter.format(slip.totalIncome),
                    style: _boldStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDeductionSection(SalarySlipModel slip) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          _sectionHeader('POTONGAN', PdfColors.red700),
          _amountRow('Potongan Telat', slip.latePenalty),
          _amountRow('Potongan Absen', slip.absentPenalty),
          _amountRow('BPJS Kesehatan', slip.bpjsKesehatan),
          _amountRow('BPJS Ketenagakerjaan', slip.bpjsKetenagakerjaan),
          _amountRow('Potongan Pajak', slip.taxDeduction),
          _amountRow('Potongan Pinjaman', slip.loanDeduction),
          _amountRow('Potongan Lain', slip.otherDeduction),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.red100,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL POTONGAN', style: _boldStyle),
                pw.Text(PriceFormatter.format(slip.totalDeduction),
                    style: _boldStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionHeader(String title, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(4),
          topRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Text(title, style: _headerStyle),
    );
  }

  static pw.Widget _amountRow(String label, double amount) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: _normalStyle),
          pw.Text(PriceFormatter.format(amount), style: _normalStyle),
        ],
      ),
    );
  }

  static pw.Widget _buildAttendanceSummary(SalarySlipModel slip) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('RINGKASAN KEHADIRAN', style: _boldStyle),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _attendanceStat('Hari Kerja', '${slip.totalWorkDays}'),
              _attendanceStat('Hadir', '${slip.presentDays}'),
              _attendanceStat('Tidak Hadir', '${slip.absentDays}'),
              _attendanceStat('Terlambat', '${slip.lateDays}'),
              _attendanceStat('Sakit', '${slip.sickDays}'),
              _attendanceStat('Cuti', '${slip.leaveDays}'),
              _attendanceStat('Lembur', '${slip.totalOvertimeHours}j'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _attendanceStat(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(5),
        margin: const pw.EdgeInsets.symmetric(horizontal: 2),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Column(
          children: [
            pw.Text(value, style: _boldStyle),
            pw.Text(label, style: pw.TextStyle(fontSize: 7)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildNetSalary(SalarySlipModel slip) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GAJI BERSIH (TAKE HOME PAY)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            PriceFormatter.format(slip.netSalary),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBox('Dibuat Oleh'),
        _signatureBox('Disetujui Oleh'),
        _signatureBox('Penerima'),
      ],
    );
  }

  static pw.Widget _signatureBox(String title) {
    return pw.Column(
      children: [
        pw.Text(title, style: _smallStyle),
        pw.SizedBox(height: 40),
        pw.Container(
          width: 100,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide()),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('(                                )', style: _smallStyle),
      ],
    );
  }

  /// Print Laporan Absensi Bulanan ke PDF
  static Future<void> printAttendanceReport({
    required List<EmployeeModel> employees,
    required List<AttendanceModel> attendances,
    required int month,
    required int year,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ROYAL CHARIR', style: _companyNameStyle),
                    pw.Text('Laporan Absensi Karyawan', style: _normalStyle),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Periode: ${months[month]} $year',
                        style: _boldStyle),
                    pw.Text('Dicetak: ${dateFormat.format(DateTime.now())}',
                        style: _smallStyle),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(height: 1, color: PdfColors.black),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: _smallStyle,
          ),
        ),
        build: (context) {
          final rows = <pw.TableRow>[];

          // Header
          rows.add(pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _tableCell('Tidak', header: true),
              _tableCell('Kode', header: true),
              _tableCell('Nama Karyawan', header: true),
              _tableCell('Hadir', header: true),
              _tableCell('Absen', header: true),
              _tableCell('Telat', header: true),
              _tableCell('Sakit', header: true),
              _tableCell('Cuti', header: true),
              _tableCell('Izin', header: true),
              _tableCell('Total Jam', header: true),
            ],
          ));

          // Data rows
          for (var i = 0; i < employees.length; i++) {
            final emp = employees[i];
            final empAttendances =
                attendances.where((a) => a.employeeId == emp.id).toList();

            int present = 0,
                absent = 0,
                late = 0,
                sick = 0,
                leave = 0,
                permission = 0;
            double totalHours = 0;

            for (final att in empAttendances) {
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

            rows.add(pw.TableRow(
              children: [
                _tableCell('${i + 1}'),
                _tableCell(emp.employeeCode),
                _tableCell(emp.name),
                _tableCell('$present', center: true),
                _tableCell('$absent', center: true),
                _tableCell('$late', center: true),
                _tableCell('$sick', center: true),
                _tableCell('$leave', center: true),
                _tableCell('$permission', center: true),
                _tableCell(totalHours.toStringAsFixed(1), center: true),
              ],
            ));
          }

          return [
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FixedColumnWidth(40),
                4: const pw.FixedColumnWidth(40),
                5: const pw.FixedColumnWidth(40),
                6: const pw.FixedColumnWidth(40),
                7: const pw.FixedColumnWidth(40),
                8: const pw.FixedColumnWidth(40),
                9: const pw.FixedColumnWidth(55),
              },
              children: rows,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'LaporanAbsensi_${months[month]}_$year',
      format: PdfPageFormat.a4.landscape,
    );
  }

  static pw.Widget _tableCell(String text,
      {bool header = false, bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: header
            ? _headerStyle.copyWith(color: PdfColors.black)
            : _smallStyle,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}
