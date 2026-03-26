import 'package:flutter/material.dart';
import '../../models/command_schema.dart';
import 'pill_widget.dart';

class TextCommandWidget extends StatefulWidget {
  final CommandSchema schema;
  final ValueChanged<CommandSchema> onSchemaUpdated;

  const TextCommandWidget({
    Key? key,
    required this.schema,
    required this.onSchemaUpdated,
  }) : super(key: key);

  @override
  State<TextCommandWidget> createState() => _TextCommandWidgetState();
}

class _TextCommandWidgetState extends State<TextCommandWidget> {
  late CommandSchema _currentSchema;

  @override
  void initState() {
    super.initState();
    _currentSchema = widget.schema;
  }

  void _updateVariable(String variableId, String newValue) {
    setState(() {
      final updatedVariables = _currentSchema.variables.map((v) {
        if (v.id == variableId) {
          return v.copyWith(value: newValue);
        }
        return v;
      }).toList();

      _currentSchema = CommandSchema(
        id: _currentSchema.id,
        intent: _currentSchema.intent,
        template: _currentSchema.template,
        variables: updatedVariables,
      );
    });

    widget.onSchemaUpdated(_currentSchema);
  }

  List<InlineSpan> _buildTextSpans() {
    // A simple regex to find tokens like {destination} or {date}
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(_currentSchema.template);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: _currentSchema.template,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        )
      ];
    }

    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (var match in matches) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: _currentSchema.template.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      }

      final variableName = match.group(1);
      
      // Find the corresponding variable
      final variable = _currentSchema.variables.firstWhere(
        (v) => v.id == variableName || v.name.toLowerCase() == variableName?.toLowerCase(),
        orElse: () => Variable(
          id: variableName ?? 'unknown',
          name: variableName ?? 'Unknown',
          type: 'text', // Defaults to our text registry handler
        ),
      );

      // Add the pill widget as a WidgetSpan
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: PillWidget(
            variable: variable,
            onValueChanged: (newValue) => _updateVariable(variable.id, newValue),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add any remaining text
    if (lastMatchEnd < _currentSchema.template.length) {
      spans.add(
        TextSpan(
          text: _currentSchema.template.substring(lastMatchEnd),
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: RichText(
        text: TextSpan(
          children: _buildTextSpans(),
        ),
      ),
    );
  }
}
