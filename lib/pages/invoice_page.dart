import 'package:flutter/material.dart';
import '../models/invoice_item.dart';
import '../widgets/invoice_header.dart';
import '../widgets/customer_info_section.dart';
import '../widgets/items_table.dart';
import '../widgets/financial_summary.dart';
import '../services/pdf_service.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _serviceChargeController = TextEditingController(text: '0');
  final TextEditingController _advancePaymentController = TextEditingController();
  final FocusNode _serviceChargeFocusNode = FocusNode();
  String _selectedTitle = 'Mr';
  DateTime _selectedDate = DateTime.now();
  final List<InvoiceItem> _items = [InvoiceItem()];

  @override
  void initState() {
    super.initState();
    _serviceChargeFocusNode.addListener(_onServiceChargeFocusChange);
    _serviceChargeController.addListener(_onServiceChargeTextChange);
  }

  void _onServiceChargeFocusChange() {
    if (_serviceChargeFocusNode.hasFocus) {
      // Clear the field if it's "0" when focused
      if (_serviceChargeController.text == '0') {
        _serviceChargeController.clear();
      }
    } else {
      // Reset to '0' if empty when focus is lost
      if (_serviceChargeController.text.trim().isEmpty) {
        _serviceChargeController.text = '0';
      }
    }
  }

  void _onServiceChargeTextChange() {
    // Ensure we don't have just empty space
    if (_serviceChargeController.text.trim().isEmpty && !_serviceChargeFocusNode.hasFocus) {
      _serviceChargeController.text = '0';
    }
  }

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

  void _addNewRow() {
    setState(() {
    _serviceChargeFocusNode.dispose();
      _items.add(InvoiceItem());
    });
  }

  void _removeRow(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _generateAndDownloadPDF() async {
    await PdfService.generateAndSharePdf(
      customerName: _customerNameController.text,
      selectedTitle: _selectedTitle,
      selectedDate: _selectedDate,
      items: _items,
      subtotal: _subtotal,
      serviceChargePercentage: _serviceChargePercentage,
      serviceChargeAmount: _serviceChargeAmount,
      advancePayment: _advancePayment,
      balance: _balance,
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
            const InvoiceHeader(),
            const SizedBox(height: 24),

            CustomerInfoSection(
              customerNameController: _customerNameController,
              selectedTitle: _selectedTitle,
              selectedDate: _selectedDate,
              onTitleChanged: (title) {
                setState(() {
                  _selectedTitle = title;
                });
              },
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 24),

            ItemsTable(
              items: _items,
              onChanged: () => setState(() {}),
              onDeleteRow: _removeRow,
              onAddRow: _addNewRow,
            ),
            const SizedBox(height: 32),

            FinancialSummary(
              subtotal: _subtotal,
              serviceChargeController: _serviceChargeController,
              serviceChargePercentage: _serviceChargePercentage,
              serviceChargeAmount: _serviceChargeAmount,
              advancePaymentController: _advancePaymentController,
              balance: _balance,
              onChanged: () => setState(() {}),
              serviceChargeFocusNode: _serviceChargeFocusNode,
            ),
            const SizedBox(height: 32),

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