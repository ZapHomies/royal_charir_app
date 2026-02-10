import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/reports/data/models/sales_report_model.dart';
import '../utils/price_formatter.dart';

/// Report Print Service for Sales & Stock Reports
class ReportPrintService {
  // Paper size for 9.5" x 11"
  static const PdfPageFormat pageFormat = PdfPageFormat(
    9.5 * PdfPageFormat.inch,
    11 * PdfPageFormat.inch,
    marginAll: 0.5 * PdfPageFormat.inch,
  );

  /// Print Sales Report
  static Future<void> printSalesReport(
    SalesReportModel report, {
    bool preview = true,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildReportHeader('SALES REPORT'),
                pw.SizedBox(height: 10),

                // Period
                pw.Text(
                  'Period: ${DateFormat('dd MMM yyyy').format(report.startDate)} - ${DateFormat('dd MMM yyyy').format(report.endDate)}',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),

                // Summary Statistics
                _buildSummarySection(report),
                pw.SizedBox(height: 20),

                // Top Products
                if (report.topProducts.isNotEmpty) ...[
                  pw.Text(
                    'TOP PRODUCTS',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  _buildTopItemsTable(report.topProducts, 'Product'),
                  pw.SizedBox(height: 15),
                ],

                // Top Customers
                if (report.topCustomers.isNotEmpty) ...[
                  pw.Text(
                    'TOP CUSTOMERS',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  _buildTopItemsTable(report.topCustomers, 'Customer'),
                ],

                pw.Spacer(),

                // Footer
                _buildReportFooter(),
              ],
            );
          },
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await pdf.save();

      if (preview) {
        // Try layoutPdf for preview, fallback to sharePdf if it fails
        try {
          await Printing.layoutPdf(
            onLayout: (format) async => pdfBytes,
            name:
                'Sales_Report_${DateFormat('yyyyMMdd').format(report.startDate)}.pdf',
            format: pageFormat,
          );
        } catch (e) {
          // Fallback to share/save dialog
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename:
                'Sales_Report_${DateFormat('yyyyMMdd').format(report.startDate)}.pdf',
          );
        }
      } else {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename:
              'Sales_Report_${DateFormat('yyyyMMdd').format(report.startDate)}.pdf',
        );
      }
    } catch (e) {
      print('Error in printSalesReport: $e');
      rethrow;
    }
  }

  /// Print Stock Report
  static Future<void> printStockReport(
    StockReportModel report, {
    bool preview = true,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildReportHeader('STOCK REPORT'),
                pw.SizedBox(height: 10),

                // Date
                pw.Text(
                  'Date: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),

                // Summary
                _buildStockSummary(report),
                pw.SizedBox(height: 15),

                // Stock Table
                pw.Text(
                  'STOCK DETAILS',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                _buildStockTable(report.items),

                pw.Spacer(),

                // Footer
                _buildReportFooter(),
              ],
            );
          },
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await pdf.save();

      if (preview) {
        // Try layoutPdf for preview, fallback to sharePdf if it fails
        try {
          await Printing.layoutPdf(
            onLayout: (format) async => pdfBytes,
            name:
                'Stock_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
            format: pageFormat,
          );
        } catch (e) {
          // Fallback to share/save dialog
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename:
                'Stock_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
          );
        }
      } else {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename:
              'Stock_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
        );
      }
    } catch (e) {
      print('Error in printStockReport: $e');
      rethrow;
    }
  }

  // Helpers
  static pw.Widget _buildReportHeader(String title) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'ROYAL CHARIR',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Furniture & Textile Products',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: 200,
                height: 2,
                color: PdfColors.black,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(SalesReportModel report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ringkasan',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 5),
          _buildSummaryRow('Total Orders', '${report.totalOrders}'),
          _buildSummaryRow(
              'Total Sales', PriceFormatter.format(report.totalSales)),
          _buildSummaryRow(
              'Total Paid', PriceFormatter.format(report.totalPaid)),
          _buildSummaryRow('Total Outstanding',
              PriceFormatter.format(report.totalRemaining)),
          pw.Divider(thickness: 1),
          _buildSummaryRow('Paid Orders', '${report.paidOrders}'),
          _buildSummaryRow('Partial Payments', '${report.partialOrders}'),
          _buildSummaryRow('Unpaid Orders', '${report.unpaidOrders}'),
        ],
      ),
    );
  }

  static pw.Widget _buildStockSummary(StockReportModel report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Total Products', '${report.totalProducts}'),
                _buildSummaryRow(
                    'Low Stock Items', '${report.lowStockProducts}'),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                    'Out of Stock', '${report.outOfStockProducts}'),
                _buildSummaryRow('Total Value',
                    PriceFormatter.format(report.totalStockValue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTopItemsTable(
      List<SalesReportItem> items, String type) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(100),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Tidak', bold: true, centered: true),
            _buildTableCell(type, bold: true),
            _buildTableCell('Qty', bold: true, centered: true),
            _buildTableCell('Amount', bold: true, rightAlign: true),
          ],
        ),
        // Items
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${index + 1}', centered: true),
              _buildTableCell(item.name),
              _buildTableCell('${item.count}', centered: true),
              _buildTableCell(PriceFormatter.format(item.amount),
                  rightAlign: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildStockTable(List<ProductStockInfo> items) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(60),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Tidak', bold: true, centered: true),
            _buildTableCell('Product', bold: true),
            _buildTableCell('Stock', bold: true, centered: true),
            _buildTableCell('Min', bold: true, centered: true),
            _buildTableCell('Status', bold: true, centered: true),
          ],
        ),
        // Items (limit to first 30 for space)
        ...items.take(30).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          String status;
          if (item.status == 'out') {
            status = 'OUT';
          } else if (item.status == 'low') {
            status = 'LOW';
          } else {
            status = 'OK';
          }
          return pw.TableRow(
            children: [
              _buildTableCell('${index + 1}', centered: true),
              _buildTableCell(item.productName),
              _buildTableCell('${item.stock} ${item.unit}', centered: true),
              _buildTableCell('${item.minStock}', centered: true),
              _buildTableCell(status, centered: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text,
      {bool bold = false, bool centered = false, bool rightAlign = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: centered
          ? pw.Alignment.center
          : rightAlign
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildReportFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            'ROYAL CHARIR - Furniture & Textile Products',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'Printed: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

