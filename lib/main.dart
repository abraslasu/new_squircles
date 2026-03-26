import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/database_service.dart';
import 'services/capability_registry.dart';
import 'providers/permission_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (!isFirstLaunch) {
    // Already onboarded, initialize DB immediately
    await DatabaseService.init();
  }

  // Register capabilities (Overlays and Interactions)
  CapabilityRegistry.registerDefaults();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: VisualCommandApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class VisualCommandApp extends StatelessWidget {
  final bool isFirstLaunch;
  const VisualCommandApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Language UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: isFirstLaunch ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
