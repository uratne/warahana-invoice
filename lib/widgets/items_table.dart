import 'package:flutter/material.dart';
import '../models/invoice_item.dart';
import 'item_row.dart';

class ItemsTable extends StatelessWidget {
  final List<InvoiceItem> items;
  final VoidCallback onChanged;
  final Function(int) onDeleteRow;
  final VoidCallback onAddRow;

  const ItemsTable({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onDeleteRow,
    required this.onAddRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Unit Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Total Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              // Table Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemRow(
                    item: items[index],
                    onChanged: onChanged,
                    onDelete: items.length > 1 ? () => onDeleteRow(index) : null,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onAddRow,
          icon: const Icon(Icons.add),
          label: const Text('Add Row'),
        ),
      ],
    );
  }
}