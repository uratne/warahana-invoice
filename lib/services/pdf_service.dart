import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/invoice_item.dart';
import '../utils/formatters.dart';

class PdfService {
  static Future<void> generateAndSharePdf({
    required String customerName,
    required String selectedTitle,
    required DateTime selectedDate,
    required List<InvoiceItem> items,
    required double subtotal,
    required double serviceChargePercentage,
    required double serviceChargeAmount,
    required double advancePayment,
    required double balance,
  }) async {
    final pdf = pw.Document();

    // Load logo image
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header section
            _buildHeader(logoImage, selectedTitle, customerName, selectedDate),
            
            pw.SizedBox(height: 30),
            
            // Items Table Header
            pw.Text(
              'ITEMS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            
            // Items Table
            _buildItemsTable(items),
            
            pw.SizedBox(height: 30),
            
            // Financial Summary
            _buildFinancialSummary(
              subtotal,
              serviceChargePercentage,
              serviceChargeAmount,
              advancePayment,
              balance,
            ),
          ];
        },
      ),
    );

    // Save and share the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${Formatters.formatDate(selectedDate).replaceAll('/', '-')}.pdf',
    );
  }

  static pw.Widget _buildHeader(
    pw.ImageProvider logoImage,
    String selectedTitle,
    String customerName,
    DateTime selectedDate,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Centered Logo
        pw.Center(
          child: pw.Container(
            width: 80,
            height: 80,
            child: pw.Image(
              logoImage,
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        
        // Centered Company Name
        pw.Center(
          child: pw.Text(
            'Warahana Riverside Cottage',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        
        // Centered Location
        pw.Center(
          child: pw.Text(
            'Udawalawa',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(height: 30),

        // Invoice Title
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        pw.SizedBox(height: 20),

        // Customer Info
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Customer Name:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '$selectedTitle $customerName',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Date:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  Formatters.formatDate(selectedDate),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    return pw.Table.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 12,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellStyle: const pw.TextStyle(fontSize: 11),
      cellPadding: const pw.EdgeInsets.all(8),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      data: [
        // Header row
        ['Description', 'Qty', 'Unit Price', 'Total Price'],
        // Data rows
        ...items.map((item) => [
          item.descriptionController.text,
          item.qtyController.text,
          'LKR ${item.unitPriceController.text}',
          'LKR ${Formatters.formatCurrency(item.total)}',
        ]).toList(),
      ],
    );
  }

  static pw.Widget _buildFinancialSummary(
    double subtotal,
    double serviceChargePercentage,
    double serviceChargeAmount,
    double advancePayment,
    double balance,
  ) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 300,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          children: [
            _buildSummaryRow('Subtotal', 'LKR ${Formatters.formatCurrency(subtotal)}'),
            if (serviceChargePercentage > 0) ...[
              _buildSummaryRow(
                'Service Charge ($serviceChargePercentage%)',
                'LKR ${Formatters.formatCurrency(serviceChargeAmount)}',
              ),
            ],
            _buildSummaryRow(
              'Advance Payment',
              'LKR ${Formatters.formatCurrency(advancePayment)}',
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(8),
                  bottomRight: pw.Radius.circular(8),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Balance Due',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'LKR ${Formatters.formatCurrency(balance)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}