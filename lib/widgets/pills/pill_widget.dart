import 'package:flutter/material.dart';
import '../../models/command_schema.dart';
import '../../services/capability_registry.dart';

class PillWidget extends StatelessWidget {
  final Variable variable;
  final ValueChanged<String> onValueChanged;

  const PillWidget({
    Key? key,
    required this.variable,
    required this.onValueChanged,
  }) : super(key: key);

  void _showOverlay(BuildContext context) {
    // Dynamically look up the correct handler from the plugin registry
    final handler = CapabilityRegistry.getHandler(variable.type);
    
    // Execute its distinct UI interaction (Modal, Dialog, Map, etc.)
    handler.handleInteraction(context, variable, onValueChanged);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = variable.value != null && variable.value!.isNotEmpty;
    
    return GestureDetector(
      onTap: () => _showOverlay(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: hasValue ? Colors.blueAccent.withOpacity(0.2) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: hasValue ? Colors.blueAccent : Colors.grey.shade600,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          hasValue ? variable.value! : variable.name,
          style: TextStyle(
            color: hasValue ? Colors.blueAccent : Colors.white70,
            fontWeight: hasValue ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
