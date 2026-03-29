import 'dart:convert';

class ExecutableIntent {
  final String intent;
  final Map<String, dynamic> variables;

  ExecutableIntent({
    required this.intent,
    required this.variables,
  });

  factory ExecutableIntent.fromJsonString(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      return ExecutableIntent(
        intent: json['intent'] as String? ?? 'unknown',
        variables: json['variables'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      return ExecutableIntent(intent: 'unknown', variables: {});
    }
  }
}
