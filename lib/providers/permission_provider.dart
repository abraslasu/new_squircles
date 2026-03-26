import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provides the SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class PermissionStateNotifier extends StateNotifier<Map<Permission, PermissionStatus>> {
  PermissionStateNotifier() : super({
    Permission.locationWhenInUse: PermissionStatus.denied,
    Permission.calendarFullAccess: PermissionStatus.denied,
    Permission.contacts: PermissionStatus.denied,
  }) {
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final locationStatus = await Permission.locationWhenInUse.status;
    
    // Using calendarFullAccess for iOS 17+ or calendar for older
    final calendarStatus = await Permission.calendarFullAccess.status;
    final contactsStatus = await Permission.contacts.status;

    state = {
      Permission.locationWhenInUse: locationStatus,
      Permission.calendarFullAccess: calendarStatus,
      Permission.contacts: contactsStatus,
    };
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    state = {
      ...state,
      permission: status,
    };
  }

  bool get areAllPermissionsRequested {
    return state.values.every((status) => status != PermissionStatus.denied);
  }
}

final permissionProvider = StateNotifierProvider<PermissionStateNotifier, Map<Permission, PermissionStatus>>((ref) {
  return PermissionStateNotifier();
});
