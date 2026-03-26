import 'package:isar/isar.dart';

part 'device_event.g.dart';

@collection
class DeviceEvent {
  Id id = Isar.autoIncrement;

  String? eventId;
  String? calendarId;

  @Index(type: IndexType.value)
  late String title;

  String? description;

  @Index(type: IndexType.value)
  late DateTime startTime;

  late DateTime endTime;

  String? location;
}
