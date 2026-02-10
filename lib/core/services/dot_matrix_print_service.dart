import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/orders/data/models/order_model.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../utils/price_formatter.dart';
import 'package:intl/intl.dart';

/// Print Service for Epson LX-310 Dot Matrix
/// Paper: NCR 9.5" x 5.5" continuous form LANDSCAPE
class DotMatrixPrintService {
  // Paper size for LANDSCAPE continuous form (9.5" width x 5.5" height)
  static const PdfPageFormat landscapeFormat = PdfPageFormat(
    9.5 * PdfPageFormat.inch, // width
    5.5 * PdfPageFormat.inch, // height (half form)
    marginLeft: 0.3 * PdfPageFormat.inch,
    marginRight: 0.3 * PdfPageFormat.inch,
    marginTop: 0.2 * PdfPageFormat.inch,
    marginBottom: 0.2 * PdfPageFormat.inch,
  );

  // Text styles optimized for dot matrix
  static final _companyNameStyle = pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
  );

  static final _titleStyle = pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
  );

  static final _subtitleStyle = const pw.TextStyle(fontSize: 8);

  static final _normalStyle = const pw.TextStyle(fontSize: 8);

  static final _boldStyle = pw.TextStyle(
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
  );

  static final _smallStyle = const pw.TextStyle(fontSize: 7);

  /// Print Invoice (NOTA) - Landscape format
  static Future<void> printInvoice(
      OrderModel order, CustomerModel customer) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: landscapeFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // === TOP SECTION: Company + Title + Doc Info ===
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Company Info
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ROYAL CHARIR', style: _companyNameStyle),
                        pw.Text('Furniture & Bedding Textile',
                            style: _subtitleStyle),
                        pw.SizedBox(height: 2),
                        pw.Text('Jl. Tirtorejo, RT.03/RW.02, Nanggungan',
                            style: _smallStyle),
                        pw.Text('Cukir, Diwek, Jombang 61471',
                            style: _smallStyle),
                        pw.Text('WA: 0858-5300-5902 / 085-645-652-646',
                            style: _smallStyle),
                      ],
                    ),
                  ),
                  // Center: Document Title
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 1.5),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text('NOTA / INVOICE', style: _titleStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right: Document Info
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildInfoPair('Tidak', order.orderNumber),
                        _buildInfoPair(
                            'Tanggal', dateFormat.format(order.orderDate)),
                        _buildInfoPair(
                            'Jam', timeFormat.format(order.orderDate)),
                        _buildInfoPair('Tipe', order.orderType.toUpperCase()),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 0.5, height: 8),

              // === CUSTOMER INFO ===
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Kepada Yth: ', style: _normalStyle),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(customer.name, style: _boldStyle),
                        if (customer.address != null &&
                            customer.address!.isNotEmpty)
                          pw.Text(customer.address!, style: _smallStyle),
                        if (customer.phone != null &&
                            customer.phone!.isNotEmpty)
                          pw.Text('Telp: ${customer.phone}',
                              style: _smallStyle),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),

              // === ITEMS TABLE ===
              _buildInvoiceTable(order),

              pw.SizedBox(height: 6),

              // === BOTTOM SECTION: Notes + Totals ===
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Notes
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Catatan:', style: _smallStyle),
                        pw.Container(
                          height: 35,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          padding: const pw.EdgeInsets.all(3),
                          child:
                              pw.Text(order.notes ?? '-', style: _smallStyle),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  // Right: Totals
                  pw.Expanded(
                    flex: 2,
                    child: _buildTotalsSection(order),
                  ),
                ],
              ),

              pw.Spacer(),

              // === SIGNATURE ROW ===
              _buildInvoiceSignatures(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Nota_${order.orderNumber}',
      format: landscapeFormat,
    );
  }

  /// Print Delivery Order (SURAT JALAN) - Landscape format
  static Future<void> printDeliveryOrder(
      OrderModel order, CustomerModel customer) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Extract driver name from notes
    String? driverName;
    String? notesWithoutDriver;
    if (order.notes != null) {
      final match = RegExp(r'Supir:\s*(.+)').firstMatch(order.notes!);
      driverName = match?.group(1)?.trim();
      notesWithoutDriver =
          order.notes!.replaceAll(RegExp(r'Supir:\s*.+'), '').trim();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: landscapeFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // === TOP SECTION ===
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Company
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ROYAL CHARIR', style: _companyNameStyle),
                        pw.Text('Furniture & Bedding Textile',
                            style: _subtitleStyle),
                        pw.SizedBox(height: 2),
                        pw.Text('Jl. Tirtorejo, RT.03/RW.02, Nanggungan',
                            style: _smallStyle),
                        pw.Text('Cukir, Diwek, Jombang 61471',
                            style: _smallStyle),
                        pw.Text('WA: 0858-5300-5902 / 085-645-652-646',
                            style: _smallStyle),
                      ],
                    ),
                  ),
                  // Center: Title
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 1.5),
                        ),
                        child: pw.Text('SURAT JALAN', style: _titleStyle),
                      ),
                    ),
                  ),
                  // Right: Doc Info
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildInfoPair('Tidak',
                            'SJ-${order.orderNumber.replaceFirst("ORD-", "")}'),
                        _buildInfoPair(
                            'Tanggal', dateFormat.format(order.orderDate)),
                        _buildInfoPair('Ref', order.orderNumber),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 0.5, height: 8),

              // === CUSTOMER + DRIVER ===
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Text('Tujuan: ', style: _normalStyle),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(customer.name, style: _boldStyle),
                              if (customer.address != null)
                                pw.Text(customer.address!, style: _smallStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (driverName != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text('Supir: ', style: _normalStyle),
                          pw.Text(driverName, style: _boldStyle),
                        ],
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 6),

              // === ITEMS TABLE (No Price) ===
              _buildDeliveryTable(order),

              pw.SizedBox(height: 6),

              // === NOTES ===
              if (notesWithoutDriver != null && notesWithoutDriver.isNotEmpty)
                pw.Row(
                  children: [
                    pw.Text('Catatan: ', style: _smallStyle),
                    pw.Expanded(
                      child: pw.Text(notesWithoutDriver, style: _smallStyle),
                    ),
                  ],
                ),

              pw.Spacer(),

              // === SIGNATURE ROW ===
              _buildDeliverySignatures(),

              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Barang yang sudah dibeli tidak dapat ditukar/dikembalikan',
                  style:
                      pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SuratJalan_${order.orderNumber}',
      format: landscapeFormat,
    );
  }

  // ==================== HELPER WIDGETS ====================

  static pw.Widget _buildInfoPair(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 50,
            child: pw.Text('$label:', style: _smallStyle),
          ),
          pw.Text(value, style: _boldStyle),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceTable(OrderModel order) {
    final items = order.items;

    // Return empty message if no items
    if (items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.TableBorder.all(width: 0.5),
        ),
        child: pw.Center(
          child:
              pw.Text('Tidak ada item', style: const pw.TextStyle(fontSize: 8)),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(22), // No
        1: const pw.FlexColumnWidth(4), // Nama Barang
        2: const pw.FixedColumnWidth(35), // Qty
        3: const pw.FixedColumnWidth(28), // Sat
        4: const pw.FixedColumnWidth(60), // Harga
        5: const pw.FixedColumnWidth(70), // Jumlah
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('No', header: true, center: true),
            _tableCell('Nama Barang', header: true),
            _tableCell('Qty', header: true, center: true),
            _tableCell('Sat', header: true, center: true),
            _tableCell('Harga', header: true, right: true),
            _tableCell('Jumlah', header: true, right: true),
          ],
        ),
        // Items - only actual items, no empty rows
        ...items.asMap().entries.map((e) {
          final idx = e.key + 1;
          final item = e.value;
          return pw.TableRow(
            children: [
              _tableCell('$idx', center: true),
              _tableCell(item.productName),
              _tableCell('${item.quantity}', center: true),
              _tableCell('pcs', center: true),
              _tableCell(PriceFormatter.formatCompact(item.unitPrice),
                  right: true),
              _tableCell(PriceFormatter.formatCompact(item.subtotal),
                  right: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildDeliveryTable(OrderModel order) {
    final items = order.items;

    // Return empty message if no items
    if (items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.TableBorder.all(width: 0.5),
        ),
        child: pw.Center(
          child:
              pw.Text('Tidak ada item', style: const pw.TextStyle(fontSize: 8)),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(25), // No
        1: const pw.FlexColumnWidth(5), // Nama Barang
        2: const pw.FixedColumnWidth(45), // Qty
        3: const pw.FixedColumnWidth(40), // Satuan
        4: const pw.FlexColumnWidth(2), // Keterangan
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('No', header: true, center: true),
            _tableCell('Nama Barang', header: true),
            _tableCell('Qty', header: true, center: true),
            _tableCell('Satuan', header: true, center: true),
            _tableCell('Keterangan', header: true, center: true),
          ],
        ),
        // Items - only actual items, no empty rows
        ...items.asMap().entries.map((e) {
          final idx = e.key + 1;
          final item = e.value;
          return pw.TableRow(
            children: [
              _tableCell('$idx', center: true),
              _tableCell(item.productName),
              _tableCell('${item.quantity}', center: true),
              _tableCell('pcs', center: true),
              _tableCell(''),
            ],
          );
        }),
      ],
    );
  }

  static pw.TableRow _emptyRow(int cols) {
    return pw.TableRow(
      children: List.generate(cols, (_) => _tableCell('')),
    );
  }

  static pw.Widget _tableCell(String text,
      {bool header = false, bool center = false, bool right = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: pw.Text(
        text,
        style: header ? _boldStyle : _normalStyle,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildTotalsSection(OrderModel order) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        children: [
          _totalLine('Subtotal', order.totalAmount),
          if (order.discount > 0) _totalLine('Diskon', -order.discount),
          pw.Divider(thickness: 0.5, height: 4),
          _totalLine('TOTAL', order.finalAmount, bold: true),
          pw.Divider(thickness: 0.5, height: 4),
          _totalLine('Dibayar', order.paidAmount),
          _totalLine('Sisa', order.remainingAmount, bold: true),
          pw.SizedBox(height: 2),
          pw.Text(
            'Status: ${_statusText(order.paymentStatus)}',
            style: _boldStyle,
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalLine(String label, double amount,
      {bool bold = false}) {
    final style = bold ? _boldStyle : _normalStyle;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(PriceFormatter.formatCompact(amount), style: style),
        ],
      ),
    );
  }

  static String _statusText(String status) {
    switch (status) {
      case 'Lunas':
        return 'LUNAS';
      case 'Sebagian':
      case 'partial':
        return 'SEBAGIAN';
      case 'Belum Bayar':
      case 'unpaid':
        return 'BELUM BAYAR';
      default:
        return status.toUpperCase();
    }
  }

  static pw.Widget _buildInvoiceSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBox('Hormat Kami,'),
        _signatureBox('Penerima,'),
      ],
    );
  }

  static pw.Widget _buildDeliverySignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBox('Pengirim,'),
        _signatureBox('Supir,'),
        _signatureBox('Penerima,'),
      ],
    );
  }

  static pw.Widget _signatureBox(String title) {
    return pw.Column(
      children: [
        pw.Text(title, style: _smallStyle),
        pw.SizedBox(height: 25),
        pw.Container(
          width: 70,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
        ),
        pw.Text('(              )', style: _smallStyle),
      ],
    );
  }
}
