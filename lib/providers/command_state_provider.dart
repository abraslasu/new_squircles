import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/llm_inference_service.dart';
import '../services/prompt_builder_service.dart';
import '../services/taxonomy_service.dart';
import '../models/intents/intent_schema.dart';
import 'icon_provider.dart';

/// Represents the current state of the AI Inference engine.
enum AICommandStatus {
  idle,       // Waiting for user input
  thinking,   // Sent to LLM, waiting for response
  resolved,   // Got response, UI is updated
  error       // Something went wrong (e.g., hallucination, network error if using cloud)
}

/// The state class that holds the current output of the AI.
class CommandState {
  final AICommandStatus status;
  final ExecutableIntent? resolvedIntent;
  final String translationTemplate;
  final String errorMessage;

  CommandState({
    this.status = AICommandStatus.idle,
    this.resolvedIntent,
    this.translationTemplate = '',
    this.errorMessage = '',
  });

  CommandState copyWith({
    AICommandStatus? status,
    ExecutableIntent? resolvedIntent,
    String? translationTemplate,
    String? errorMessage,
  }) {
    return CommandState(
      status: status ?? this.status,
      resolvedIntent: resolvedIntent ?? this.resolvedIntent,
      translationTemplate: translationTemplate ?? this.translationTemplate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// The Riverpod provider for the AI Command State
final commandStateProvider = StateNotifierProvider<CommandStateNotifier, CommandState>((ref) {
  return CommandStateNotifier(ref);
});

/// The Notifier that bridges the Icon Selections (UI) to the AI Brain.
class CommandStateNotifier extends StateNotifier<CommandState> {
  final Ref _ref;
  Timer? _debounceTimer;

  CommandStateNotifier(this._ref) : super(CommandState()) {
    // 1. Listen to the user's icon selections (Tray)
    _ref.listen(iconProvider, (previous, next) {
      if (previous?.trayIcons != next.trayIcons) {
        _onIconsChanged(next.trayIcons);
      }
    });

    // 2. Initialize the Taxonomy & LLM Services silently in the background
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Load the taxonomy mapping file
    await _ref.read(taxonomyServiceProvider).loadTaxonomy();
    // Pre-warm the LLaMA C++ engine
    await _ref.read(llmServiceProvider).initialize();
  }

  /// Called every time an icon is added or removed from the tray.
  void _onIconsChanged(List<String> trayIcons) {
    // If the tray is empty, reset everything.
    if (trayIcons.isEmpty) {
      _debounceTimer?.cancel();
      state = CommandState(status: AICommandStatus.idle);
      return;
    }

    // Enter "Thinking" state immediately to show UI loading indicators
    state = state.copyWith(status: AICommandStatus.thinking, translationTemplate: 'Thinking...');

    // Debounce: Wait 800ms to see if the user taps another icon before querying the LLM
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _runInference(trayIcons);
    });
  }

  /// Triggers the actual AI Brain to process the icons.
  Future<void> _runInference(List<String> selectedIcons) async {
    try {
      final llmService = _ref.read(llmServiceProvider);
      final promptBuilder = _ref.read(promptBuilderProvider);
      final taxonomyService = _ref.read(taxonomyServiceProvider);

      // 1. Build the massive system prompt using the semantic tags and local DB context
      final prompt = promptBuilder.buildMasterPrompt(selectedIcons, taxonomyService);

      // 2. Run the offline LLM inference (This will take 1-3 seconds on an iPhone)
      final rawJsonResponse = await llmService.generateResponse(prompt);

      // 3. Parse the strict JSON output into our Dart models
      final parsedIntent = ExecutableIntent.fromJsonString(rawJsonResponse);

      // 4. Extract the translation sentence for the UI
      // We parse the raw JSON again just to grab the "translation" field since the
      // ExecutableIntent classes focus on the variables, not the sentence.
      String translationText = 'Unknown Command';
      try {
        import 'dart:convert';
        final data = jsonDecode(rawJsonResponse);
        translationText = data['translation'] ?? translationText;
      } catch (_) {}

      // 5. Update the State (This instantly updates Phase 3 UI)
      state = state.copyWith(
        status: AICommandStatus.resolved,
        resolvedIntent: parsedIntent,
        translationTemplate: translationText,
      );

    } catch (e) {
      print('❌ AI Inference Error: $e');
      state = state.copyWith(
        status: AICommandStatus.error,
        errorMessage: 'Failed to process command. Make sure the local LLM model is downloaded.',
      );
    }
  }
}
