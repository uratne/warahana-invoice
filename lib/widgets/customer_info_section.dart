import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class CustomerInfoSection extends StatelessWidget {
  final TextEditingController customerNameController;
  final String selectedTitle;
  final DateTime selectedDate;
  final Function(String) onTitleChanged;
  final Function(DateTime) onDateChanged;

  const CustomerInfoSection({
    super.key,
    required this.customerNameController,
    required this.selectedTitle,
    required this.selectedDate,
    required this.onTitleChanged,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DropdownButton<String>(
              value: selectedTitle,
              items: ['Mr', 'Mrs', 'Ms', 'Dr']
                  .map((title) => DropdownMenuItem(
                        value: title,
                        child: Text(title),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onTitleChanged(value);
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 300,
              child: TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                  Text(Formatters.formatDate(selectedDate)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}