import 'package:isar/isar.dart';

part 'device_location.g.dart';

@collection
class DeviceLocation {
  Id id = Isar.autoIncrement;

  late double latitude;
  late double longitude;

  @Index(type: IndexType.value)
  late DateTime timestamp;

  String? reverseGeocodedName; // Optional: To store "Home", "Current Street", etc.
}
