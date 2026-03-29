import 'package:flutter/material.dart';
import '../../models/command_schema.dart';

class ContactSelectionOverlay extends StatelessWidget {
  final Variable variable;
  final ValueChanged<String> onSelected;

  const ContactSelectionOverlay({
    Key? key,
    required this.variable,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock contacts for now. In Phase 4, this will pull from Isar / native contacts.
    final mockContacts = [
      {'name': 'Alice Smith', 'initials': 'AS', 'color': Colors.blue},
      {'name': 'Bob Jones', 'initials': 'BJ', 'color': Colors.green},
      {'name': 'Charlie Brown', 'initials': 'CB', 'color': Colors.orange},
      {'name': 'Diana Prince', 'initials': 'DP', 'color': Colors.purple},
      {'name': 'Evan Wright', 'initials': 'EW', 'color': Colors.red},
    ];

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
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                onSelected(value);
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Fixed height for the list to allow scrolling in bottom sheet
            child: ListView.builder(
              itemCount: mockContacts.length,
              itemBuilder: (context, index) {
                final contact = mockContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: contact['color'] as Color,
                    child: Text(
                      contact['initials'] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    contact['name'] as String,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onSelected(contact['name'] as String);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
