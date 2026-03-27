import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../controllers/job_completion_controller.dart';

class InvoiceGenerator {
  static Future<File> generateAndSave(JobCompletionController c) async {
    final pdf = _buildPdf(c);
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${c.invoiceNumber.value}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> generateAndShare(JobCompletionController c) async {
    final file = await generateAndSave(c);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'DriveResQ Invoice ${c.invoiceNumber.value}');
  }

  static pw.Document _buildPdf(JobCompletionController c) {
    final job = c.jobData.value ?? {};
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#F57C00');
    final secondaryColor = PdfColor.fromHex('#424242');
    final surfaceColor = PdfColor.fromHex('#FAFAFA');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Brand Info
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DriveResQ',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Professional Roadside Assistance',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: secondaryColor,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    // Invoice Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _buildInvoiceDetailRow('Invoice No.', c.invoiceNumber.value),
                        _buildInvoiceDetailRow('Date', _formatDate(DateTime.now())),
                        _buildInvoiceDetailRow(
                            'Job ID',
                            c.jobId.value.length > 8
                                ? c.jobId.value.substring(0, 8).toUpperCase()
                                : c.jobId.value.toUpperCase()),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // ─── Customer & Job Info ───
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildInfoSection(
                      title: 'Billed To (Customer Info)',
                      color: primaryColor,
                      children: [
                        _buildInfoText('Name: ${job['driverName'] ?? 'Customer'}'),
                        _buildInfoText('Phone: ${job['driverPhone'] ?? '-'}'),
                        _buildInfoText('Location: ${job['locationName'] ?? '-'}'),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: _buildInfoSection(
                      title: 'Vehicle & Job Details',
                      color: primaryColor,
                      children: [
                        _buildInfoText('Vehicle: ${job['vehicleType'] ?? '-'}'),
                        _buildInfoText('Reg No: ${job['vehicleNumber'] ?? '-'}'),
                        _buildInfoText('Reported Problem: ${job['problem'] ?? '-'}'),
                        _buildInfoText('Duration: ${c.formattedDuration}'),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 32),

              // ─── Services Table ───
              pw.Text(
                'Services Performed',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              if (c.selectedServices.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.selectedServices
                        .map((s) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.grey600,
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.SizedBox(width: 6),
                                  pw.Text(s, style: const pw.TextStyle(fontSize: 10)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                )
              else
                pw.Text('No specific services listed.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),

              pw.SizedBox(height: 24),

              // ─── Charges Breakup Table ───
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFE0B2')),
                      children: [
                        _buildTableHeader('Description'),
                        _buildTableHeader('Qty', align: pw.TextAlign.center),
                        _buildTableHeader('Rate', align: pw.TextAlign.right),
                        _buildTableHeader('Amount', align: pw.TextAlign.right),
                      ],
                    ),

                    // Base Charge
                    _buildTableRow('Base Service Charge', '-', '-', c.baseCharge.value),
                    
                    // Labor Charges
                    if (c.laborCharges.value > 0)
                      _buildTableRow('Labor Charges', '-', '-', c.laborCharges.value),

                    // Travel Cost
                    if (c.travelCost.value > 0)
                      _buildTableRow('Travel Cost / Distance Fee', '-', '-', c.travelCost.value),

                    // Parts Replaced
                    if (c.partsReplaced.isNotEmpty)
                      ...c.partsReplaced.map(
                        (p) => _buildTableRow(
                          'Part: ${p['name'] ?? '-'}',
                          '${p['quantity'] ?? 1}',
                          '₹${(p['costPerUnit'] as double? ?? 0).toStringAsFixed(2)}',
                          p['total'] as double? ?? 0,
                        ),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // ─── Totals Section ───
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Payment Terms & Notes',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '1. All prices are in INR (₹).',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          '2. Payment to be settled directly with the mechanic.',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 12),
                        // Watermark / Status Stamp
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: c.cashCollected.value
                                    ? PdfColors.green
                                    : PdfColors.orange,
                                width: 2),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            c.cashCollected.value ? 'PAYMENT RECEIVED' : 'PAYMENT PENDING',
                            style: pw.TextStyle(
                              color: c.cashCollected.value
                                  ? PdfColors.green
                                  : PdfColors.orange,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: surfaceColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        children: [
                          _buildSummaryRow('Subtotal', c.subtotal.value),
                          _buildSummaryRow('GST (18%)', c.gstAmount.value),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Grand Total',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                              pw.Text(
                                '₹${c.totalAmount.value.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ─── Footer ───
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Thank you for trusting DriveResQ!',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'If you have any questions about this invoice, please contact support.',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildInvoiceDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            '$label: ',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoSection({
    required String title,
    required PdfColor color,
    required List<pw.Widget> children,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColor.fromHex('#424242'),
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#424242'),
        ),
      ),
    );
  }

  static pw.TableRow _buildTableRow(String desc, String qty, String rate, double amount) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: pw.Text(desc, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: pw.Text(qty,
              textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: pw.Text(rate,
              textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: pw.Text('₹${amount.toStringAsFixed(2)}',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#424242'),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
