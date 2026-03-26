import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_squircles/main.dart';
import 'package:new_squircles/providers/permission_provider.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    // We mock SharedPreferences for the test
    SharedPreferences.setMockInitialValues({'isFirstLaunch': false});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const VisualCommandApp(isFirstLaunch: false),
      ),
    );

    // Verify that the initial screen text is present (from HomeScreen/MainScreen)
    expect(find.text('Unlock what\nyou need'), findsOneWidget);
  });
}
