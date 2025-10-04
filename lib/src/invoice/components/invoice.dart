import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class InvoiceItem {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();

  double get total {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    return qty * unitPrice;
  }

  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    unitPriceController.dispose();
  }
}

class _InvoicePageState extends State<InvoicePage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _serviceChargeController = TextEditingController();
  final TextEditingController _advancePaymentController = TextEditingController();
  String _selectedTitle = 'Mr';
  DateTime _selectedDate = DateTime.now();
  final List<InvoiceItem> _items = [InvoiceItem()];

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  double get _serviceChargePercentage {
    return double.tryParse(_serviceChargeController.text) ?? 0;
  }

  double get _serviceChargeAmount {
    return _subtotal * (_serviceChargePercentage / 100);
  }

  double get _advancePayment {
    return double.tryParse(_advancePaymentController.text) ?? 0;
  }

  double get _balance {
    return _subtotal + _serviceChargeAmount - _advancePayment;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  void _addNewRow() {
    setState(() {
      _items.add(InvoiceItem());
    });
  }

  void _removeRow(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Warahara Riverside Cottage',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Udawalawa',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
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
                        '$_selectedTitle ${_customerNameController.text}',
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
                        _formatDate(_selectedDate),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Description', isHeader: true),
                      _buildTableCell('Qty', isHeader: true),
                      _buildTableCell('Unit Price', isHeader: true),
                      _buildTableCell('Total Price', isHeader: true),
                    ],
                  ),
                  // Data Rows
                  for (var item in _items)
                    pw.TableRow(
                      children: [
                        _buildTableCell(item.descriptionController.text),
                        _buildTableCell(item.qtyController.text),
                        _buildTableCell('LKR ${item.unitPriceController.text}'),
                        _buildTableCell('LKR ${_formatCurrency(item.total)}'),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Financial Summary
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 300,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Subtotal', 'LKR ${_formatCurrency(_subtotal)}'),
                      if (_serviceChargePercentage > 0) ...[
                        _buildSummaryRow(
                          'Service Charge ($_serviceChargePercentage%)',
                          'LKR ${_formatCurrency(_serviceChargeAmount)}',
                        ),
                      ],
                      _buildSummaryRow(
                        'Advance Payment',
                        'LKR ${_formatCurrency(_advancePayment)}',
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
                              'LKR ${_formatCurrency(_balance)}',
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
              ),
            ],
          );
        },
      ),
    );

    // Save and download the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${_formatDate(_selectedDate).replaceAll('/', '-')}.pdf',
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
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

  @override
  void dispose() {
    _customerNameController.dispose();
    _serviceChargeController.dispose();
    _advancePaymentController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 5.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cottage Name
            Text(
              'Warahara Riverside Cottage',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            // Location
            Text(
              'Udawalawa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 24),

            // Invoice Header - aligned to left
            Text(
              'INVOICE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 24),

            // Customer Name - smaller width
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedTitle,
                  items: ['Mr', 'Mrs', 'Ms', 'Dr']
                      .map((title) => DropdownMenuItem(
                            value: title,
                            child: Text(title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTitle = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Picker - smaller width
            SizedBox(
              width: 250,
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Items Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Table Rows
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _items[index].descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Description',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _items[index].qtyController,
                                decoration: const InputDecoration(
                                  hintText: 'Qty',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _items[index].unitPriceController,
                                decoration: const InputDecoration(
                                  hintText: 'Price',
                                  prefixText: 'LKR ',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey[100],
                                ),
                                child: Text(
                                  'LKR ${_formatCurrency(_items[index].total)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _items.length > 1 ? () => _removeRow(index) : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add Row Button
            ElevatedButton.icon(
              onPressed: _addNewRow,
              icon: const Icon(Icons.add),
              label: const Text('Add Row'),
            ),
            const SizedBox(height: 32),

            // Financial Summary Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container()), // Spacer to push content to right
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'LKR ${_formatCurrency(_subtotal)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Service Charge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Charge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _serviceChargeController,
                                    decoration: InputDecoration(
                                      hintText: '%',
                                      suffixText: '%',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {}),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            if (_serviceChargePercentage > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'LKR ${_formatCurrency(_serviceChargeAmount)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Advance Payment
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Advance Payment',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: _advancePaymentController,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixText: 'LKR ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => setState(() {}),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Balance (Total)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance Due',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'LKR ${_formatCurrency(_balance)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Share PDF Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _generateAndDownloadPDF,
                icon: const Icon(Icons.share),
                label: const Text('Share PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}