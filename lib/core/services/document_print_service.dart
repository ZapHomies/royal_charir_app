import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../features/orders/data/models/order_model.dart';
import '../utils/price_formatter.dart';

/// Document Print Service for Invoice & Delivery Note
/// With Royal Charir logo support
class DocumentPrintService {
  DocumentPrintService._();

  static pw.MemoryImage? _logoImage;

  /// Load logo image
  static Future<pw.MemoryImage?> _loadLogo() async {
    if (_logoImage != null) return _logoImage;

    try {
      final data = await rootBundle.load('assets/images/logo.png');
      _logoImage = pw.MemoryImage(data.buffer.asUint8List());
      return _logoImage;
    } catch (e) {
      print('Failed to load logo: $e');
      return null;
    }
  }

  /// Print Invoice with preview
  static Future<void> printInvoice(OrderModel order,
      {bool preview = true}) async {
    final pdf = pw.Document();
    final logo = await _loadLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(logo, 'INVOICE', order.orderNumber),
            pw.SizedBox(height: 20),
            _buildOrderInfo(order),
            pw.SizedBox(height: 20),
            _buildItemsTable(order),
            pw.SizedBox(height: 20),
            _buildTotalSection(order),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildNotesSection(order.notes!),
            ],
            pw.Spacer(),
            _buildSignatureSection(),
            pw.SizedBox(height: 16),
            _buildFooter('Invoice'),
          ],
        ),
      ),
    );

    if (preview) {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Invoice_${order.orderNumber}',
      );
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Invoice_${order.orderNumber}.pdf',
      );
    }
  }

  /// Print Delivery Note (Surat Jalan) with preview
  static Future<void> printDeliveryNote(OrderModel order,
      {bool preview = true}) async {
    final pdf = pw.Document();
    final logo = await _loadLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(logo, 'SURAT JALAN',
                'SJ-${order.orderNumber.replaceFirst('ORD', '')}'),
            pw.SizedBox(height: 20),
            _buildDeliveryInfo(order),
            pw.SizedBox(height: 20),
            _buildDeliveryItemsTable(order),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildNotesSection(order.notes!),
            ],
            pw.Spacer(),
            _buildSignatureSection(),
            pw.SizedBox(height: 16),
            _buildFooter('Surat Jalan'),
          ],
        ),
      ),
    );

    if (preview) {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'SuratJalan_${order.orderNumber}',
      );
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'SuratJalan_${order.orderNumber}.pdf',
      );
    }
  }

  /// Build header with logo
  static pw.Widget _buildHeader(
      pw.MemoryImage? logo, String docType, String docNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo (grayscale)
          if (logo != null)
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text('RC',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    )),
              ),
            ),
          pw.SizedBox(width: 16),
          // Company Info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ROYAL CHARIR',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Furniture & Textile',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Jl. Tirtorejo, RT.03/RW.02, Nanggungan, Cukir, Diwek, Jombang',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Telp/WA: 0858-5300-5902 / 085-645-652-646',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          // Document Type & Number
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  docType,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  docNumber,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderInfo(OrderModel order) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Kepada', order.customerName),
                _buildInfoRow(
                    'Tipe',
                    order.orderType == 'Grosir' ||
                            order.orderType == 'wholesale'
                        ? 'Grosir'
                        : 'Eceran'),
                _buildInfoRow('Tanggal', dateFormat.format(order.orderDate)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Status', _getPaymentStatusText(order.paymentStatus)),
                if (order.paidAmount > 0)
                  _buildInfoRow(
                      'Dibayar', PriceFormatter.format(order.paidAmount)),
                if (order.remainingAmount > 0)
                  _buildInfoRow(
                      'Sisa', PriceFormatter.format(order.remainingAmount)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
      case 'paid':
        return 'LUNAS';
      case 'sebagian':
      case 'partial':
        return 'SEBAGIAN';
      default:
        return 'BELUM BAYAR';
    }
  }

  static pw.Widget _buildDeliveryInfo(OrderModel order) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Kepada', order.customerName),
          _buildInfoRow('Tanggal', dateFormat.format(order.orderDate)),
          _buildInfoRow('No. Order', order.orderNumber),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build items table - only show rows that have data
  static pw.Widget _buildItemsTable(OrderModel order) {
    // Don't show empty rows - only actual items
    if (order.items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text(
            'Tidak ada item',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 12),
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('No', bold: true, centered: true),
            _buildTableCell('Nama Barang', bold: true),
            _buildTableCell('Qty', bold: true, centered: true),
            _buildTableCell('Harga', bold: true, rightAlign: true),
            _buildTableCell('Jumlah', bold: true, rightAlign: true),
          ],
        ),
        // Items - only actual items, no empty rows
        ...order.items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${i + 1}', centered: true),
              _buildTableCell(item.productName),
              _buildTableCell('${item.quantity}', centered: true),
              _buildTableCell(PriceFormatter.format(item.unitPrice),
                  rightAlign: true),
              _buildTableCell(PriceFormatter.format(item.subtotal),
                  rightAlign: true),
            ],
          );
        }),
      ],
    );
  }

  /// Build delivery items table - only show rows that have data
  static pw.Widget _buildDeliveryItemsTable(OrderModel order) {
    if (order.items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text(
            'Tidak ada item',
            style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 12),
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('No', bold: true, centered: true),
            _buildTableCell('Nama Barang', bold: true),
            _buildTableCell('Qty', bold: true, centered: true),
            _buildTableCell('Satuan', bold: true, centered: true),
            _buildTableCell('Keterangan', bold: true, centered: true),
          ],
        ),
        // Items - only actual items, no empty rows
        ...order.items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${i + 1}', centered: true),
              _buildTableCell(item.productName),
              _buildTableCell('${item.quantity}', centered: true),
              _buildTableCell('pcs', centered: true),
              _buildTableCell(''), // Keterangan kosong
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTotalSection(OrderModel order) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            _buildTotalRow(
                'Subtotal', PriceFormatter.format(order.totalAmount)),
            if (order.discount > 0)
              _buildTotalRow(
                  'Diskon', '- ${PriceFormatter.format(order.discount)}'),
            pw.Divider(color: PdfColors.grey400),
            _buildTotalRow('TOTAL', PriceFormatter.format(order.finalAmount),
                bold: true),
            pw.SizedBox(height: 8),
            _buildTotalRow('Dibayar', PriceFormatter.format(order.paidAmount)),
            if (order.remainingAmount > 0)
              _buildTotalRow(
                  'Sisa', PriceFormatter.format(order.remainingAmount),
                  highlight: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: highlight ? PdfColors.red700 : PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: highlight ? PdfColors.red700 : PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotesSection(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Catatan:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.amber900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            notes,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSignatureBox('Hormat Kami'),
        _buildSignatureBox('Penerima'),
      ],
    );
  }

  static pw.Widget _buildSignatureBox(String title) {
    return pw.Container(
      width: 150,
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 50),
          pw.Container(
            width: 120,
            decoration: const pw.BoxDecoration(
              border:
                  pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500)),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '(                              )',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {bool bold = false, bool centered = false, bool rightAlign = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: centered
          ? pw.Alignment.center
          : rightAlign
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(String docType) {
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Royal Charir - $docType',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Dicetak: $now',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
