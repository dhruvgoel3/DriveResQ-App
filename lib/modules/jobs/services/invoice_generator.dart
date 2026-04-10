import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../controllers/job_completion_controller.dart';

/// A professional utility service for generating and managing PDF invoices.
///
/// This service handles the creation of tax-compliant invoice documents
/// based on job completion data, including labor costs, parts, and travel fees.
class InvoiceGenerator {
  /// Generates a PDF invoice and saves it to the application's local documents directory.
  ///
  /// Returns the [File] object pointing to the generated PDF.
  static Future<File> generateAndSave(JobCompletionController c) async {
    try {
      final pdf = _buildPdf(c);
      final bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'invoice_${c.invoiceNumber.value}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes);
      /* print stripped */
      return file;
    } catch (e) {
      /* print stripped */
      rethrow;
    }
  }

  /// Generates a PDF invoice and triggers a system share dialog.
  static Future<void> generateAndShare(JobCompletionController c) async {
    try {
      final file = await generateAndSave(c);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'DriveResQ Service Invoice - #${c.invoiceNumber.value}');
    } catch (e) {
      /* print stripped */
    }
  }

  // ---------------------------------------------------------------------------
  // 📄 PDF CONSTRUCTION ENGINE
  // ---------------------------------------------------------------------------

  static pw.Document _buildPdf(JobCompletionController c) {
    final job = c.jobData.value ?? {};
    final pdf = pw.Document(
      author: 'DriveResQ',
      title: 'Invoice ${c.invoiceNumber.value}',
    );

    // Dynamic Color Palette
    final primaryColor = PdfColor.fromHex('#F57C00'); // DriveResQ Orange
    final secondaryColor = PdfColor.fromHex('#263238'); // Deep Blue Grey
    const lightGrey = PdfColors.grey200;
    final surfaceColor = PdfColor.fromHex('#FAFAFA');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── BRANDING HEADER ───
              _buildHeader(primaryColor, secondaryColor, c),
              pw.SizedBox(height: 30),

              // ─── BILLING & VEHICLE INFO ───
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildInfoBox(
                      title: 'Customer Details',
                      themeColor: primaryColor,
                      details: [
                        'Name: ${job['driverName'] ?? 'Valued Customer'}',
                        'Phone: ${job['driverPhone'] ?? 'N/A'}',
                        'Location: ${job['locationName'] ?? 'Point of Breakdown'}',
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildInfoBox(
                      title: 'Service Summary',
                      themeColor: primaryColor,
                      details: [
                        'Vehicle Type: ${job['vehicleType'] ?? 'N/A'}',
                        'Reg Number: ${job['vehicleNumber'] ?? 'N/A'}',
                        'Problem: ${job['problem'] ?? 'Standard Repair'}',
                        'Time Taken: ${c.formattedDuration}',
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // ─── SERVICES LIST ───
              _buildSectionTitle('Services Performed', primaryColor),
              pw.SizedBox(height: 10),
              _buildServicesGrid(c, lightGrey, surfaceColor),
              pw.SizedBox(height: 30),

              // ─── FINANCIAL BREAKDOWN ───
              _buildSectionTitle('Charges Details', primaryColor),
              pw.SizedBox(height: 10),
              _buildChargesTable(c, primaryColor, lightGrey),
              pw.SizedBox(height: 20),

              // ─── PAYMENT STATUS & TOTALS ───
              _buildTotalsSection(
                c,
                primaryColor,
                secondaryColor,
                surfaceColor,
              ),

              pw.Spacer(),

              // ─── FOOTER ───
              _buildFooter(secondaryColor),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ---------------------------------------------------------------------------
  // 🧩 COMPONENT BUILDERS
  // ---------------------------------------------------------------------------

  static pw.Widget _buildHeader(
    PdfColor primary,
    PdfColor secondary,
    JobCompletionController c,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2.5)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DriveResQ',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: primary,
                ),
              ),
              pw.Text(
                'ROADSIDE ASSISTANCE NETWORK',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: secondary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: secondary,
                ),
              ),
              pw.SizedBox(height: 4),
              _buildSmallLabelValue('Number', '#${c.invoiceNumber.value}'),
              _buildSmallLabelValue('Date', _formatDate(DateTime.now())),
              _buildSmallLabelValue(
                'Ref ID',
                c.jobId.value.substring(0, 8).toUpperCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoBox({
    required String title,
    required PdfColor themeColor,
    required List<String> details,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: themeColor,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: details
                .map(
                  (d) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text(
                      d,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildServicesGrid(
    JobCompletionController c,
    PdfColor border,
    PdfColor bg,
  ) {
    if (c.selectedServices.isEmpty) {
      return pw.Text(
        'No specific service sub-types selected.',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      );
    }
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border.all(color: border),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Wrap(
        spacing: 12,
        runSpacing: 6,
        children: c.selectedServices
            .map(
              (s) => pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    width: 3,
                    height: 3,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.orange,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(s, style: const pw.TextStyle(fontSize: 8.5)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _buildChargesTable(
    JobCompletionController c,
    PdfColor primary,
    PdfColor border,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange50),
          children: [
            _buildCell('Description', isHeader: true),
            _buildCell('Qty', isHeader: true, align: pw.TextAlign.center),
            _buildCell('Amount', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        _buildDataRow('Standard Base Service Fee', '1', c.baseCharge.value),
        if (c.laborCharges.value > 0)
          _buildDataRow(
            'Professional Labor/Technical Work',
            '1',
            c.laborCharges.value,
          ),
        if (c.travelCost.value > 0)
          _buildDataRow('Travel & Dispatch Fee', '1', c.travelCost.value),
        ...c.partsReplaced.map(
          (p) => _buildDataRow(
            'Part: ${p['name'] ?? 'Generic Part'}',
            '${p['quantity'] ?? 1}',
            p['total'] as double? ?? 0.0,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotalsSection(
    JobCompletionController c,
    PdfColor primary,
    PdfColor secondary,
    PdfColor bg,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: c.cashCollected.value
                        ? PdfColors.green700
                        : PdfColors.orange700,
                    width: 1.5,
                  ),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  c.cashCollected.value
                      ? 'PAYMENT RECEIVED'
                      : 'PAYMENT PENDING',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: c.cashCollected.value
                        ? PdfColors.green700
                        : PdfColors.orange700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '• All values are calculated in Indian Rupees (INR).',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                '• This is a computer-generated document.',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: bg,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              children: [
                _buildSummaryLine('Sub-Total', c.subtotal.value),
                _buildSummaryLine('Taxes (GST 18%)', c.gstAmount.value),
                pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Payable',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: secondary,
                      ),
                    ),
                    pw.Text(
                      '₹${c.totalAmount.value.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(PdfColor color) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'THANK YOU FOR USING DRIVERESQ',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Reliable Support, Every Mile of the Way.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 🛠 HELPERS
  // ---------------------------------------------------------------------------

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: color,
        letterSpacing: 1,
      ),
    );
  }

  static pw.Widget _buildSmallLabelValue(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildCell(
    String content, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        content,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.TableRow _buildDataRow(String desc, String qty, double amount) {
    return pw.TableRow(
      children: [
        _buildCell(desc),
        _buildCell(qty, align: pw.TextAlign.center),
        _buildCell('₹${amount.toStringAsFixed(2)}', align: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _buildSummaryLine(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
