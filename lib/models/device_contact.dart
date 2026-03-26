import 'package:isar/isar.dart';

part 'device_contact.g.dart';

@collection
class DeviceContact {
  Id id = Isar.autoIncrement;

  String? deviceId;

  @Index(type: IndexType.value)
  late String displayName;

  List<String> phoneNumbers = [];
  List<String> emails = [];

  bool isStarred = false;
}
