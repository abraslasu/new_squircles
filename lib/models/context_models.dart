// import 'package:isar/isar.dart';

// part 'context_models.g.dart';

// NOTE: Uncomment these when running build_runner to generate Isar code.
// @collection
class ContactInfo {
  // Id id = Isar.autoIncrement;
  int? id;

  // @Index(type: IndexType.value)
  String? name;

  String? phoneNumber;
  String? email;
  bool isStarred = false;
  DateTime? lastContacted;
}

// @collection
class CalendarEvent {
  // Id id = Isar.autoIncrement;
  int? id;

  // @Index(type: IndexType.value)
  String? title;

  DateTime? startTime;
  DateTime? endTime;
  String? location;
}
