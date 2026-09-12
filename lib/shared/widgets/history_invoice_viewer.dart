import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../utils/helpers/app_snackbar.dart';

/// Generates and shares a PDF invoice from historical completedJobs data.
/// Unlike the live InvoiceGenerator which needs a controller, this works
/// purely from a Map of completion data.
class HistoryInvoiceViewer {
  /// Generate PDF from completedJobs data and share it.
  static Future<void> viewAndShare(
    Map<String, dynamic> completionData,
    BuildContext context,
  ) async {
    try {
      AppSnackbar.info('Generating invoice...', title: 'Please Wait');

      final file = await _generatePdf(completionData);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'DriveResQ Invoice ${completionData['invoiceNumber'] ?? ''}',
        ),
      );
    } catch (e) {
      AppSnackbar.error('Failed to generate invoice');
    }
  }

  static Future<File> _generatePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final invoiceNumber = data['invoiceNumber'] ?? 'N/A';
    final services = List<String>.from(data['servicesPerformed'] ?? []);
    final parts = List<Map<String, dynamic>>.from(data['partsReplaced'] ?? []);
    final baseCharge = (data['baseCharge'] ?? 0).toDouble();
    final laborCharges = (data['laborCharges'] ?? 0).toDouble();
    final travelCost = (data['travelCost'] ?? 0).toDouble();
    final partsTotal = (data['partsTotal'] ?? 0).toDouble();
    final subtotal = (data['subtotal'] ?? 0).toDouble();
    final totalAmount = (data['totalAmount'] ?? 0).toDouble();
    final cashCollected = data['cashCollected'] ?? false;

    // Duration
    String duration = '—';
    if (data['durationMinutes'] != null) {
      final mins = data['durationMinutes'] as int;
      final h = mins ~/ 60;
      final m = mins % 60;
      duration = h > 0 ? '${h}h ${m}m' : '${m}m';
    }

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
                          color: PdfColor.fromHex('#6C63FF'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Roadside Assistance',
                        style: const pw.TextStyle(
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
                        invoiceNumber,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColor.fromHex('#6C63FF')),
              pw.SizedBox(height: 16),

              // Job details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('JOB DETAILS'),
                        pw.SizedBox(height: 6),
                        _detailRow(
                          'Job ID',
                          (data['jobId'] ?? '').toString().length >= 12
                              ? (data['jobId'] ?? '')
                                    .toString()
                                    .substring(0, 12)
                                    .toUpperCase()
                              : (data['jobId'] ?? '').toString().toUpperCase(),
                        ),
                        _detailRow('Vehicle', data['vehicleType'] ?? '-'),
                        _detailRow('Problem', data['problem'] ?? '-'),
                        _detailRow('Location', data['locationName'] ?? '-'),
                        _detailRow('Duration', duration),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('SETTLEMENT'),
                        pw.SizedBox(height: 6),
                        _detailRow('Method', 'Cash / Settle directly'),
                        _detailRow(
                          'Status',
                          cashCollected ? 'Collected' : 'Pending',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Services
              _sectionTitle('SERVICES PERFORMED'),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 8,
                children: services
                    .map(
                      (s) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EDE7F6'),
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

              // Cost breakdown
              _sectionTitle('COST BREAKDOWN'),
              pw.SizedBox(height: 8),

              if (parts.isNotEmpty) ...[
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
                    ...parts.map(
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

              _summaryRow('Base Service Charge', baseCharge),
              _summaryRow('Labor Charges', laborCharges),
              _summaryRow('Parts Cost', partsTotal),
              _summaryRow('Travel Cost', travelCost),
              pw.Divider(color: PdfColors.grey300),
              _summaryRow('Subtotal', subtotal),
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
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#4CAF50'),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Powered by DriveResQ • Roadside Assistance',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey700,
      ),
    );
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
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
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
}
