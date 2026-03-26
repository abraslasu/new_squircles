import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/device_contact.dart';
import '../../context_syncer.dart';

class RealContactsSyncer implements ContextSyncer {
  @override
  String get name => 'contacts';

  @override
  Permission get requiredPermission => Permission.contacts;

  @override
  String get llmPromptInjection => 
      "You have access to the user's local contacts. Query the local database if they ask to message, call, or pay someone.";

  @override
  Future<void> syncData(Isar isar) async {
    final hasPermission = await FlutterContacts.requestPermission(readonly: true);
    if (!hasPermission) return;

    final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: false);

    final deviceContacts = contacts.map((contact) {
      return DeviceContact()
        ..deviceId = contact.id
        ..displayName = contact.displayName
        ..phoneNumbers = contact.phones.map((e) => e.number).toList()
        ..emails = contact.emails.map((e) => e.address).toList()
        ..isStarred = contact.isStarred;
    }).toList();

    await isar.writeTxn(() async {
      await isar.deviceContacts.clear(); // Complete rewrite for simple sync
      await isar.deviceContacts.putAll(deviceContacts);
    });
  }
}
