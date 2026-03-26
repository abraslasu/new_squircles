import 'package:flutter/material.dart';
import '../../models/command_schema.dart';

class DateTimeOverlay extends StatelessWidget {
  final Variable variable;
  final ValueChanged<String> onSelected;

  const DateTimeOverlay({
    Key? key,
    required this.variable,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select ${variable.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // A simplified placeholder list for quick date/time picking
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildOption('Today'),
              _buildOption('Tomorrow'),
              _buildOption('Next Week'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Here we would use showDatePicker or showTimePicker
                // Returning a mock string for now
                onSelected('Custom Date');
              },
              child: const Text('Pick Custom'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOption(String text) {
    return ActionChip(
      backgroundColor: Colors.grey.shade800,
      label: Text(text, style: const TextStyle(color: Colors.white)),
      onPressed: () => onSelected(text),
    );
  }
}
