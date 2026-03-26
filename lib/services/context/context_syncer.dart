import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContextSyncer {
  String get name;
  Permission get requiredPermission;

  Future<void> syncData(Isar isar);

  String get llmPromptInjection;
}
