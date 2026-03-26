import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_contact.dart';
import '../../context_syncer.dart';

class MockContactsSyncer implements ContextSyncer {
  @override
  String get name => 'contacts';

  @override
  Permission get requiredPermission => Permission.contacts;

  @override
  String get llmPromptInjection => 
      "You have access to the user's local contacts. Query the local database if they ask to message, call, or pay someone.";

  @override
  Future<void> syncData(Isar isar) async {
    final mockContacts = [
      DeviceContact()..displayName = "Mom"..phoneNumbers = ["555-0101"]..isStarred = true,
      DeviceContact()..displayName = "John Doe"..phoneNumbers = ["555-0102"]..emails = ["john@example.com"],
      DeviceContact()..displayName = "Sarah Smith"..phoneNumbers = ["555-0103"]..isStarred = true,
      DeviceContact()..displayName = "Boss"..phoneNumbers = ["555-0104"],
      DeviceContact()..displayName = "Pizza Place"..phoneNumbers = ["555-0105"],
    ];

    await isar.writeTxn(() async {
      await isar.deviceContacts.clear();
      await isar.deviceContacts.putAll(mockContacts);
    });
  }
}
