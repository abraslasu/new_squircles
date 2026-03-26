class Variable {
  final String id;
  final String name;
  final String type; // e.g. "text", "date", "location", "list"
  final String? value;
  final List<String>? options; // For list type
  final bool isRequired;
  final Map<String, dynamic>? metadata; // Extensible payload for custom UI overlays

  Variable({
    required this.id,
    required this.name,
    required this.type,
    this.value,
    this.options,
    this.isRequired = true,
    this.metadata,
  });

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'text',
      value: json['value'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isRequired: json['isRequired'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'options': options,
      'isRequired': isRequired,
      if (metadata != null) 'metadata': metadata,
    };
  }

  Variable copyWith({
    String? id,
    String? name,
    String? type,
    String? value,
    List<String>? options,
    bool? isRequired,
    Map<String, dynamic>? metadata,
  }) {
    return Variable(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CommandSchema {
  final String id;
  final String intent; // e.g., "book_flight"
  final String template; // e.g., "Get a flight to {destination} on {date}"
  final List<Variable> variables;

  CommandSchema({
    required this.id,
    required this.intent,
    required this.template,
    required this.variables,
  });

  factory CommandSchema.fromJson(Map<String, dynamic> json) {
    return CommandSchema(
      id: json['id'] as String,
      intent: json['intent'] as String,
      template: json['template'] as String,
      variables: (json['variables'] as List<dynamic>)
          .map((e) => Variable.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'intent': intent,
      'template': template,
      'variables': variables.map((e) => e.toJson()).toList(),
    };
  }
}
