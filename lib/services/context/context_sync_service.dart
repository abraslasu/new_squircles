import 'package:device_info_plus/device_info_plus.dart';
import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';

import 'context_syncer.dart';

import 'syncers/calendar/mock_calendar_syncer.dart';
import 'syncers/calendar/real_calendar_syncer.dart';

import 'syncers/contacts/mock_contacts_syncer.dart';
import 'syncers/contacts/real_contacts_syncer.dart';

import 'syncers/location/mock_location_syncer.dart';
import 'syncers/location/real_location_syncer.dart';

class ContextSyncService {
  final Isar _isar;
  final List<ContextSyncer> _syncers = [];

  ContextSyncService(this._isar);

  Future<void> initialize() async {
    bool isPhysicalDevice = true;
    
    // Web isn't typically physical iOS/Android device info, so check for mobile
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
       final plugin = DeviceInfoPlugin();
       if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await plugin.iosInfo;
          isPhysicalDevice = iosInfo.isPhysicalDevice;
       } else if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await plugin.androidInfo;
          isPhysicalDevice = androidInfo.isPhysicalDevice;
       }
    }

    if (isPhysicalDevice) {
      _syncers.addAll([
        RealContactsSyncer(),
        RealCalendarSyncer(),
        RealLocationSyncer(),
      ]);
    } else {
      _syncers.addAll([
        MockContactsSyncer(),
        MockCalendarSyncer(),
        MockLocationSyncer(),
      ]);
    }
  }

  /// Iterates through all registered syncers. If the permission is granted, syncs data into Isar.
  Future<void> syncAllGrantedCapabilities() async {
    for (final syncer in _syncers) {
      // Check OS level permission status
      final status = await syncer.requiredPermission.status;
      
      // We also consider limited as granted for things like photos
      if (status.isGranted || status.isLimited) {
        try {
          await syncer.syncData(_isar);
        } catch (e) {
          debugPrint('Error syncing ${syncer.name}: $e');
        }
      }
    }
  }

  /// Compiles a dynamic string based ONLY on the capabilities the user has granted.
  Future<String> getDynamicPromptInjection() async {
    List<String> injections = [];
    
    for (final syncer in _syncers) {
      final status = await syncer.requiredPermission.status;
      if (status.isGranted || status.isLimited) {
        injections.add(syncer.llmPromptInjection);
      }
    }

    return injections.join("\n");
  }
}
