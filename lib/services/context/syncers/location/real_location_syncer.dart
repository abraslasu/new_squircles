import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_location.dart';
import '../../context_syncer.dart';

class RealLocationSyncer implements ContextSyncer {
  @override
  String get name => 'location';

  @override
  Permission get requiredPermission => Permission.locationWhenInUse;

  @override
  String get llmPromptInjection => 
      "You have access to the user's current GPS location. Query the database to estimate travel times, suggest nearby places, or fetch weather context.";

  @override
  Future<void> syncData(Isar isar) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    final deviceLocation = DeviceLocation()
      ..latitude = position.latitude
      ..longitude = position.longitude
      ..timestamp = DateTime.now()
      ..reverseGeocodedName = "Unknown Location"; // Optional mapping step

    await isar.writeTxn(() async {
      await isar.deviceLocations.clear();
      await isar.deviceLocations.put(deviceLocation);
    });
  }
}
