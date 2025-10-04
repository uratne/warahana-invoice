import 'package:flutter/material.dart';
import 'package:invoice/src/invoice/components/invoice.dart';

void main() {
  runApp(const InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: const InvoicePage(title: 'Warahana Riverside Cottage'),
    );
  }
}
