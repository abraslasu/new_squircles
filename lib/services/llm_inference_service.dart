import 'dart:io';
import 'package:flutter/services.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the LLM Inference Service
final llmServiceProvider = Provider<LlmInferenceService>((ref) {
  return LlmInferenceService();
});

/// A service to handle loading and running the on-device Large Language Model.
class LlmInferenceService {
  Llama? _llama;
  bool _isInitialized = false;

  /// The expected name of the model file in `assets/models/`
  /// Recommendation: Use a 2B to 4B parameter model quantized to 4-bit (Q4_K_M).
  /// For example: 'gemma-2b-it-q4_k_m.gguf' or 'phi-3-mini-4k-instruct-q4.gguf'
  final String _modelFileName = 'gemma-2b-it-q4_k_m.gguf';

  bool get isInitialized => _isInitialized;

  /// Initializes the local LLM. 
  /// This involves copying the large model file from the app bundle (assets) 
  /// to the device's local file system so the `llama_cpp` C++ engine can read it.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Get the local documents directory (where we can write files)
      final appDocDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDocDir.path}/$_modelFileName';
      final file = File(modelPath);

      // 2. Check if the model has already been copied from assets to the disk
      if (!await file.exists()) {
        print('🧠 Copying LLM model from assets to device storage. This may take a minute...');
        
        // Load from assets (make sure this is declared in pubspec.yaml)
        final byteData = await rootBundle.load('assets/models/$_modelFileName');
        
        // Write to local storage
        await file.writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        print('🧠 Model successfully copied to $modelPath');
      } else {
        print('🧠 Model already exists at $modelPath');
      }

      // 3. Initialize the Llama CPP engine
      // We pass the path to the model on disk and configure the context parameters.
      final contextParams = ContextParams()
        ..nCtx = 2048 // Context window (how many tokens it can remember at once)
        ..nThreads = 4; // Use 4 CPU threads (adjust based on target device)
        // Note: For advanced iOS performance, you would enable Metal/CoreML here if the wrapper supports it.

      _llama = Llama(
        modelPath,
        contextParams,
      );

      _isInitialized = true;
      print('🧠 Local LLM Engine Successfully Initialized!');

    } catch (e) {
      print('❌ Failed to initialize Local LLM: $e');
      throw Exception('Could not load the on-device AI model. Ensure the .gguf file exists in assets/models/.');
    }
  }

  /// Sends a prompt to the local LLM and returns the full generated text response.
  /// Note: In Phase 5 Step 5, we will convert this to a streaming function (generator)
  /// so we can update the UI instantly as tokens are generated.
  Future<String> generateResponse(String prompt) async {
    if (!_isInitialized || _llama == null) {
      throw Exception('LLM is not initialized. Call initialize() first.');
    }

    try {
      print('🧠 Prompting Local LLM (Expect ~1-3 second delay based on hardware)...');
      
      // Set the prompt. The model will start generating immediately in the background C++ thread.
      _llama!.setPrompt(prompt);
      
      String fullResponse = '';
      
      // We must wait for the C++ engine to finish generating the full response.
      // A more advanced implementation for UI responsiveness would stream this.
      while (true) {
        final (text, isFinished) = _llama!.getNextToken();
        fullResponse += text;
        if (isFinished) {
          break;
        }
      }
      
      print('🧠 Inference Complete.');
      return fullResponse;

    } catch (e) {
      print('❌ Inference failed: $e');
      return '{"error": "Failed to generate command."}';
    }
  }

  /// Closes the C++ engine and frees up the device RAM.
  void dispose() {
    _llama?.dispose();
    _isInitialized = false;
  }
}
