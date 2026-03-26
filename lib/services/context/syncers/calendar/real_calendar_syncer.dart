import 'package:device_calendar/device_calendar.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_event.dart';
import '../../context_syncer.dart';

class RealCalendarSyncer implements ContextSyncer {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  @override
  String get name => 'calendar';

  @override
  Permission get requiredPermission => Permission.calendarFullAccess;

  @override
  String get llmPromptInjection => 
      "You have access to the user's calendar. Query the local database for schedule conflicts or upcoming events.";

  @override
  Future<void> syncData(Isar isar) async {
    final permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return;

      final now = DateTime.now();
      final oneWeekFromNow = now.add(const Duration(days: 7));

      List<DeviceEvent> allEvents = [];

      for (final calendar in calendarsResult.data!) {
        if (calendar.isReadOnly == true) continue; // Optional filtering

        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(startDate: now, endDate: oneWeekFromNow));

        if (eventsResult.isSuccess && eventsResult.data != null) {
          for (final event in eventsResult.data!) {
            if (event.start != null && event.end != null) {
              allEvents.add(DeviceEvent()
                ..eventId = event.eventId
                ..calendarId = calendar.id
                ..title = event.title ?? 'Untitled Event'
                ..description = event.description
                ..startTime = event.start!
                ..endTime = event.end!
                ..location = event.location);
            }
          }
        }
      }

      await isar.writeTxn(() async {
        await isar.deviceEvents.clear();
        await isar.deviceEvents.putAll(allEvents);
      });
    }
  }
}
