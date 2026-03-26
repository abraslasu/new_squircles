import 'package:flutter/material.dart';
import '../../models/command_schema.dart';

class ListSelectionOverlay extends StatelessWidget {
  final Variable variable;
  final ValueChanged<String> onSelected;

  const ListSelectionOverlay({
    Key? key,
    required this.variable,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = variable.options ?? [];

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
          if (options.isEmpty)
            const Text(
              'No options available',
              style: TextStyle(color: Colors.white54),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onSelected(option);
                  },
                );
              },
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
