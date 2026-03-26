import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/device_contact.dart';
import '../models/device_event.dart';
import '../models/device_location.dart';

import 'context/context_sync_service.dart';

class DatabaseService {
  static late Isar isar;
  static late ContextSyncService syncService;

  static Future<void> init() async {
    debugPrint('Initializing Isar database...');
    
    // Check if Isar is already opened
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [
          DeviceContactSchema,
          DeviceEventSchema,
          DeviceLocationSchema,
        ],
        directory: dir.path,
      );
    } else {
      isar = Isar.getInstance()!;
    }

    syncService = ContextSyncService(isar);
    await syncService.initialize();
  }

  static Future<void> runInitialSync() async {
    debugPrint('Running initial background sync...');
    
    // Iterates through registered syncers and syncs data if permission is granted
    await syncService.syncAllGrantedCapabilities();
    
    debugPrint('Background sync complete.');
  }

  static Future<String> getPromptInjection() async {
    return await syncService.getDynamicPromptInjection();
  }
}
