import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_event.dart';
import '../../context_syncer.dart';

class MockCalendarSyncer implements ContextSyncer {
  @override
  String get name => 'calendar';

  @override
  Permission get requiredPermission => Permission.calendarFullAccess;

  @override
  String get llmPromptInjection => 
      "You have access to the user's calendar. Query the local database for schedule conflicts or upcoming events.";

  @override
  Future<void> syncData(Isar isar) async {
    final now = DateTime.now();
    final mockEvents = [
      DeviceEvent()..title = "Team Standup"..startTime = now.add(const Duration(hours: 1))..endTime = now.add(const Duration(hours: 1, minutes: 30)),
      DeviceEvent()..title = "Dentist Appointment"..startTime = now.add(const Duration(days: 1))..endTime = now.add(const Duration(days: 1, hours: 1)),
      DeviceEvent()..title = "Dinner with Sarah"..startTime = now.add(const Duration(days: 2, hours: 19))..endTime = now.add(const Duration(days: 2, hours: 21))..location = "Italian Restaurant",
    ];

    await isar.writeTxn(() async {
      await isar.deviceEvents.clear();
      await isar.deviceEvents.putAll(mockEvents);
    });
  }
}
