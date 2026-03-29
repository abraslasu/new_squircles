import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/intents/intent_schema.dart';

/// Provider for the native Execution Service
final executionServiceProvider = Provider<ExecutionService>((ref) {
  return ExecutionService();
});

/// A service responsible for sending ExecutableIntents down to the native iOS shell.
class ExecutionService {
  static const MethodChannel _channel = MethodChannel('com.squircles.visual/execute');

  /// Takes an ExecutableIntent, serializes it, and sends it to the native iOS handler.
  Future<void> executeIntent(ExecutableIntent intent) async {
    try {
      print('🚀 Sending Intent to Native iOS Shell: ${intent.intentType}');
      
      // Serialize the Intent into a standard dictionary/map for iOS
      final payload = intent.toJson();
      
      // Invoke the native method
      final result = await _channel.invokeMethod<bool>('executeIntent', payload);
      
      if (result == true) {
        print('✅ Intent successfully handed off to iOS.');
      } else {
        print('⚠️ iOS rejected the Intent handoff.');
      }
    } on PlatformException catch (e) {
      print('❌ Failed to execute intent natively: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error during intent execution: $e');
    }
  }
}
