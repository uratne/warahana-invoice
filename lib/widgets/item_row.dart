import 'package:flutter/material.dart';
import '../models/invoice_item.dart';
import '../models/catalog_item.dart';
import '../utils/formatters.dart';
import 'catalog_autocomplete.dart';

class ItemRow extends StatelessWidget {
  final InvoiceItem item;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  const ItemRow({
    super.key,
    required this.item,
    required this.onChanged,
    this.onDelete,
  });

  void _onCatalogItemSelected(CatalogItem catalogItem) {
    // Populate description and unit price from catalog
    item.descriptionController.text = catalogItem.description;
    item.unitPriceController.text = catalogItem.unitPrice.toString();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
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
            child: CatalogAutocomplete(
              controller: item.descriptionController,
              onItemSelected: _onCatalogItemSelected,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.qtyController,
              decoration: const InputDecoration(
                hintText: 'Qty',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.unitPriceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                prefixText: 'LKR ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => onChanged(),
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
                'LKR ${Formatters.formatCurrency(item.total)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
