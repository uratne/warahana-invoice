import 'package:flutter/material.dart';

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