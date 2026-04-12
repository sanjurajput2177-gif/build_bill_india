import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class PdfService {
  static Future<pw.Document> generateReceiptDocument({
    required Payment payment,
    required CompanyProfile profile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(profile.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        if (profile.phone.isNotEmpty) pw.Text(profile.phone, style: const pw.TextStyle(fontSize: 10)),
                        if (profile.gstNo.isNotEmpty) pw.Text('GST: ${profile.gstNo}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        if (profile.panNo.isNotEmpty) pw.Text('PAN: ${profile.panNo}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ]
                    ),
                    pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF2563EB))),
                  ]
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Text('Received From:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Text(payment.clientName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(payment.date)}', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Amount Received:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Rs. ${payment.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.green)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Payment Mode: ${payment.mode}', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 80, height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 4),
                        pw.Text('Signature', style: const pw.TextStyle(fontSize: 9)),
                      ]
                    )
                  ]
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }

  static Future<pw.Document> generateStatementDocument({
    required String clientName,
    required List<Payment> payments,
    required CompanyProfile profile,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF2563EB),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'B',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(profile.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      if (profile.phone.isNotEmpty) pw.Text(profile.phone, style: const pw.TextStyle(fontSize: 10)),
                      if (profile.gstNo.isNotEmpty) pw.Text('GST: ${profile.gstNo}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (profile.panNo.isNotEmpty) pw.Text('PAN: ${profile.panNo}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('PAYMENT STATEMENT', style: pw.TextStyle(fontSize: 18, color: PdfColor.fromInt(0xFF2563EB), fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 12),
              pw.Text('Client: $clientName', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: ['Date', 'Payment Mode', 'Amount (Rs)'],
                data: payments.map((p) => [
                  DateFormat('dd/MM/yyyy').format(p.date),
                  p.mode,
                  p.amount.toStringAsFixed(2)
                ]).toList(),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {2: pw.Alignment.centerRight},
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Received: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text('Rs. ${payments.fold(0.0, (sum, p) => sum + p.amount).toStringAsFixed(2)}', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Generated by BuildBill India', style: pw.TextStyle(color: PdfColors.grey, fontStyle: pw.FontStyle.italic, fontSize: 9))
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  static Future<pw.Document> generateDocument({
    required Invoice invoice,
    required CompanyProfile profile,
  }) async {
    final pdf = pw.Document();
    
    const brandColor = PdfColor.fromInt(0xFF2563EB); // Blue-600
    const darkText = PdfColor.fromInt(0xFF1E1E1E);
    const grayText = PdfColor.fromInt(0xFF505050);
    const lightGray = PdfColor.fromInt(0xFFF3F4F6); // gray-100

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- HEADER ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 45,
                    height: 45,
                    decoration: pw.BoxDecoration(
                      color: brandColor,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'B',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 26, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Text(profile.name.isNotEmpty ? profile.name : 'BuildBill India', 
                    style: pw.TextStyle(fontSize: 22, color: darkText, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text('MEASUREMENT SHEET', style: pw.TextStyle(fontSize: 18, color: brandColor, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey400, thickness: 1),
          pw.SizedBox(height: 12),

          // --- COMPANY & CLIENT INFO ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Left Side (From)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Contractor / Company:', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text(profile.name, style: pw.TextStyle(color: darkText, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    if (profile.phone.isNotEmpty) pw.Text('Phone: ${profile.phone}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    if (profile.email.isNotEmpty) pw.Text('Email: ${profile.email}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    if (profile.gstNo.isNotEmpty) pw.Text('GST: ${profile.gstNo}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    if (profile.panNo.isNotEmpty) pw.Text('PAN: ${profile.panNo}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                  ],
                ),
              ),
              
              // Middle (Bill To)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Client / Site Details:', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text(invoice.clientName, style: pw.TextStyle(color: darkText, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    if (invoice.clientPhone.isNotEmpty) 
                      pw.Text('Phone: ${invoice.clientPhone}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                    if (invoice.clientAddress != null && invoice.clientAddress!.isNotEmpty) 
                      pw.Text('Address: ${invoice.clientAddress}', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                  ],
                ),
              ),

              // Right Side (Bill Details)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                      pw.Text('Bill No: ', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                      pw.Text(invoice.id, style: pw.TextStyle(color: darkText, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                      pw.Text('Date: ', style: const pw.TextStyle(color: grayText, fontSize: 10)),
                      pw.Text(DateFormat('dd/MM/yyyy').format(invoice.date), style: pw.TextStyle(color: darkText, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // --- MEASUREMENT SHEET TABLE ---
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: lightGray),
            headerStyle: pw.TextStyle(color: darkText, fontSize: 9, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(color: darkText, fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            columnWidths: {
              0: const pw.FlexColumnWidth(3.5), // Description
              1: const pw.FlexColumnWidth(1.0), // No.
              2: const pw.FlexColumnWidth(1.2), // L
              3: const pw.FlexColumnWidth(1.2), // W
              4: const pw.FlexColumnWidth(1.2), // H
              5: const pw.FlexColumnWidth(1.8), // Total Qty
              6: const pw.FlexColumnWidth(1.5), // Rate
              7: const pw.FlexColumnWidth(2.0), // Amount
            },
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
              7: pw.Alignment.centerRight,
            },
            headers: ['Description / Particulars', 'No.', 'L', 'W', 'D/H', 'Total Qty', 'Rate', 'Amount'],
            data: invoice.items.map((item) {
              String unitLabel = 'Units';
              if (item.type == 'volume') {
                unitLabel = 'Cu.Ft';
              } else if (item.type == 'area') {
                unitLabel = 'Sq.Ft';
              } else if (item.type == 'sqyard') {
                unitLabel = 'Sq.Yd';
              }
              
              return [
                item.description,
                item.quantity.toString(),
                "${item.length.ft}' ${item.length.inch}\"",
                "${item.width.ft}' ${item.width.inch}\"",
                item.type == 'volume' ? "${item.height?.ft ?? 0}' ${item.height?.inch ?? 0}\"" : "-",
                "${item.totalUnits.toStringAsFixed(2)} $unitLabel",
                item.rate.toStringAsFixed(2),
                item.subtotal.toStringAsFixed(2),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 16),

          // Amount in Words
          pw.Row(
            children: [
              pw.Text('Amount in words: ', style: pw.TextStyle(color: grayText, fontSize: 8, fontStyle: pw.FontStyle.italic)),
              pw.Expanded(
                child: pw.Text('${_numberToWords(invoice.totalAmount.toInt())} Only', 
                  style: pw.TextStyle(color: darkText, fontSize: 9, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          ),
          
          pw.SizedBox(height: 8),

          // --- TOTALS & BANK DETAILS & SIGNATURE ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Left Side (Bank Details & Paid Stamp)
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (profile.bankDetails.isNotEmpty) ...[
                      pw.Text('BANK DETAILS:', style: pw.TextStyle(color: grayText, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(profile.bankDetails, style: const pw.TextStyle(color: darkText, fontSize: 9)),
                      pw.SizedBox(height: 12),
                    ],
                    if (invoice.balance <= 0)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.green, width: 2),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text('PAID', style: pw.TextStyle(color: PdfColors.green, fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      ),
                  ],
                ),
              ),
              
              pw.SizedBox(width: 24),

              // Totals Box
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      _summaryRow('Subtotal:', 'Rs. ${invoice.subtotal.toStringAsFixed(2)}', grayText, darkText),
                      if (invoice.gstAmount > 0) ...[
                        _summaryRow('CGST (${invoice.gstPercentage / 2}%):', 'Rs. ${(invoice.gstAmount / 2).toStringAsFixed(2)}', grayText, darkText),
                        _summaryRow('SGST (${invoice.gstPercentage / 2}%):', 'Rs. ${(invoice.gstAmount / 2).toStringAsFixed(2)}', grayText, darkText),
                      ],
                      pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                      _summaryRow('Grand Total:', 'Rs. ${invoice.totalAmount.toStringAsFixed(2)}', brandColor, darkText, isBold: true, fontSize: 11),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 32),
          
          // Signature Area
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Container(width: 100, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text("Client's Signature", style: const pw.TextStyle(fontSize: 10, color: grayText)),
                ]
              ),
              pw.Column(
                children: [
                  pw.Container(width: 100, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text("Authorized Signatory", style: const pw.TextStyle(fontSize: 10, color: grayText)),
                ]
              ),
            ]
          ),
        ],
        footer: (context) => pw.Center(
          child: pw.Text('Generated by BuildBill India', style: pw.TextStyle(color: PdfColors.grey, fontStyle: pw.FontStyle.italic, fontSize: 9))
        ),
      ),
    );
    return pdf;
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'Zero';
    
    final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 
                   'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String convert(int n) {
      if (n < 20) return units[n];
      if (n < 100) return '${tens[n ~/ 10]}${n % 10 > 0 ? " ${units[n % 10]}" : ""}';
      if (n < 1000) return '${units[n ~/ 100]} Hundred${n % 100 > 0 ? " and ${convert(n % 100)}" : ""}';
      if (n < 100000) return '${convert(n ~/ 1000)} Thousand${n % 1000 > 0 ? " ${convert(n % 1000)}" : ""}';
      if (n < 10000000) return '${convert(n ~/ 100000)} Lakh${n % 100000 > 0 ? " ${convert(n % 100000)}" : ""}';
      return '${convert(n ~/ 10000000)} Crore${n % 10000000 > 0 ? " ${convert(n % 10000000)}" : ""}';
    }

    return 'Rupees ${convert(number)}';
  }

  static pw.Widget _summaryRow(String label, String value, PdfColor labelColor, PdfColor valueColor, {bool isBold = false, double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: labelColor, fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(color: valueColor, fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static Future<void> shareInvoicePdf({
    required Invoice invoice,
    required CompanyProfile profile,
  }) async {
    final pdf = await generateDocument(invoice: invoice, profile: profile);
    final bytes = await pdf.save();
    
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Measurement_Sheet_${invoice.clientName.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<Uint8List> getInvoicePdfBytes({
    required Invoice invoice,
    required CompanyProfile profile,
    PdfPageFormat? format,
  }) async {
    final pdf = await generateDocument(invoice: invoice, profile: profile);
    return pdf.save();
  }
}
