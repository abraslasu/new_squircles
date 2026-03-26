import 'package:flutter/material.dart';
import '../models/command_schema.dart';
import '../widgets/overlays/date_time_overlay.dart';
import '../widgets/overlays/location_overlay.dart';
import '../widgets/overlays/list_selection_overlay.dart';

abstract class VariableHandler {
  void handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged);
}

class CapabilityRegistry {
  static final Map<String, VariableHandler> _handlers = {};

  static void register(String typeName, VariableHandler handler) {
    _handlers[typeName] = handler;
  }

  static VariableHandler getHandler(String typeName) {
    // If the LLM generates an unknown type, gracefully fallback to text input.
    return _handlers[typeName] ?? TextVariableHandler();
  }

  static void registerDefaults() {
    register('text', TextVariableHandler());
    register('number', TextVariableHandler());
    register('date', DateTimeVariableHandler());
    register('time', DateTimeVariableHandler());
    register('location', LocationVariableHandler());
    register('list', ListVariableHandler());
  }
}

class TextVariableHandler implements VariableHandler {
  @override
  void handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged) {
    final controller = TextEditingController(text: variable.value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter ${variable.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Type here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onValueChanged(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class DateTimeVariableHandler implements VariableHandler {
  @override
  void handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimeOverlay(
        variable: variable,
        onSelected: (val) {
          onValueChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class LocationVariableHandler implements VariableHandler {
  @override
  void handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationOverlay(
        variable: variable,
        onSelected: (val) {
          onValueChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ListVariableHandler implements VariableHandler {
  @override
  void handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ListSelectionOverlay(
        variable: variable,
        onSelected: (val) {
          onValueChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }
}
