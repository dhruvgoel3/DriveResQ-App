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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
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
                          color: PdfColor.fromHex('#FF9800'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Roadside Assistance',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
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
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        c.invoiceNumber.value,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _formatDate(DateTime.now()),
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(thickness: 2, color: PdfColor.fromHex('#FF9800')),
              pw.SizedBox(height: 16),

              // Job Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'JOB DETAILS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _detailRow(
                          'Job ID',
                          c.jobId.value.length >= 12
                              ? c.jobId.value.substring(0, 12).toUpperCase()
                              : c.jobId.value.toUpperCase(),
                        ),
                        _detailRow('Vehicle', job['vehicleType'] ?? '-'),
                        _detailRow('Problem', job['problem'] ?? '-'),
                        _detailRow('Location', job['locationName'] ?? '-'),
                        _detailRow('Duration', c.formattedDuration),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PAYMENT INFO',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _detailRow('Method', c.paymentMethod.value),
                        if (c.transactionIdController.text.isNotEmpty)
                          _detailRow(
                            'Transaction',
                            c.transactionIdController.text,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Services
              pw.Text(
                'SERVICES PERFORMED',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 8,
                children: c.selectedServices
                    .map(
                      (s) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#FFF3E0'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          s,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 20),

              // Cost Table
              pw.Text(
                'COST BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),

              // Parts table (if any)
              if (c.partsReplaced.isNotEmpty) ...[
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F5F5F5'),
                      ),
                      children: [
                        _tableHeader('Part Name'),
                        _tableHeader('Qty'),
                        _tableHeader('Rate'),
                        _tableHeader('Total'),
                      ],
                    ),
                    ...c.partsReplaced.map(
                      (p) => pw.TableRow(
                        children: [
                          _tableCell(p['name'] ?? '-'),
                          _tableCell('${p['quantity']}'),
                          _tableCell(
                            '₹${(p['costPerUnit'] as double? ?? 0).toStringAsFixed(0)}',
                          ),
                          _tableCell(
                            '₹${(p['total'] as double? ?? 0).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
              ],

              // Summary
              _summaryRow('Base Service Charge', c.baseCharge.value),
              _summaryRow('Labor Charges', c.laborCharges.value),
              _summaryRow('Parts Cost', c.partsTotal.value),
              _summaryRow('Travel Cost', c.travelCost.value),
              pw.Divider(color: PdfColors.grey300),
              _summaryRow('Subtotal', c.subtotal.value),
              _summaryRow('GST (18%)', c.gstAmount.value),
              pw.Divider(color: PdfColors.grey700, thickness: 1.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL AMOUNT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '₹${c.totalAmount.value.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#4CAF50'),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Powered by DriveResQ • Roadside Assistance',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            '₹${amount.toStringAsFixed(0)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}
