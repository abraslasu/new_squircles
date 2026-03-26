import 'package:flutter/material.dart';
import '../../models/command_schema.dart';

class LocationOverlay extends StatelessWidget {
  final Variable variable;
  final ValueChanged<String> onSelected;

  const LocationOverlay({
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
          // Simplified location input
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search for a place...',
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
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.blueAccent),
            title: const Text('Current Location', style: TextStyle(color: Colors.white)),
            onTap: () {
              onSelected('Current Location');
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              onSelected('Home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.work, color: Colors.white70),
            title: const Text('Work', style: TextStyle(color: Colors.white)),
            onTap: () {
              onSelected('Work');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
