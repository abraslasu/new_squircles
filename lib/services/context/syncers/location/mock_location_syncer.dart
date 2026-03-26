import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_location.dart';
import '../../context_syncer.dart';

class MockLocationSyncer implements ContextSyncer {
  @override
  String get name => 'location';

  @override
  Permission get requiredPermission => Permission.locationWhenInUse;

  @override
  String get llmPromptInjection => 
      "You have access to the user's current GPS location. Query the database to estimate travel times, suggest nearby places, or fetch weather context.";

  @override
  Future<void> syncData(Isar isar) async {
    final mockLocation = DeviceLocation()
      ..latitude = 37.7749 // San Francisco
      ..longitude = -122.4194
      ..timestamp = DateTime.now()
      ..reverseGeocodedName = "San Francisco, CA";

    await isar.writeTxn(() async {
      await isar.deviceLocations.clear();
      await isar.deviceLocations.put(mockLocation);
    });
  }
}
