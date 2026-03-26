import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

import '../providers/permission_provider.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() async {
    // Save that user has completed onboarding
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('isFirstLaunch', false);

    // Navigate to Home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only navigate via buttons
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          _ConceptPage(onNext: _nextPage),
          _PrivacyPage(onNext: _nextPage),
          _PermissionsPage(onNext: _nextPage),
          _SyncPage(onComplete: _finishOnboarding),
        ],
      ),
    );
  }
}

class _ConceptPage extends StatelessWidget {
  final VoidCallback onNext;
  const _ConceptPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Lottie Animation Placeholder for Concept
            SizedBox(
              height: 200,
              child: Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_tno6cg2w.json',
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.auto_awesome, size: 100, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              "Combine icons to\ncommand your world.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "A new visual language to do things faster, seamlessly.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  final VoidCallback onNext;
  const _PrivacyPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Lottie Animation Placeholder for Privacy
            SizedBox(
              height: 200,
              child: Lottie.network(
                'https://assets8.lottiefiles.com/packages/lf20_b3z1hzzg.json',
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.security, size: 100, color: Colors.greenAccent),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              "Your AI needs context.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "To give you sensible defaults, we need to know your world. Your data never leaves your device.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Understood", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends ConsumerWidget {
  final VoidCallback onNext;
  const _PermissionsPage({required this.onNext});

  Future<void> _handlePermissionRequest(
      BuildContext context, WidgetRef ref, Permission permission) async {
    final notifier = ref.read(permissionProvider.notifier);
    await notifier.requestPermission(permission);
    
    if (context.mounted) {
      final status = ref.read(permissionProvider)[permission];
      if (status != PermissionStatus.granted) {
        // Feedback when the OS silently rejects or the user hits deny.
        // Often happens on iOS when Info.plist keys are missing during development.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission restricted or denied. Check device settings.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Enable Context",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Allow access to the following to power your AI.",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _PermissionCard(
                    icon: Icons.location_on,
                    title: "Location",
                    description: "Suggest places near you and calculate travel times.",
                    status: permissions[Permission.locationWhenInUse] ?? PermissionStatus.denied,
                    onRequest: () async => await _handlePermissionRequest(context, ref, Permission.locationWhenInUse),
                  ),
                  const SizedBox(height: 16),
                  _PermissionCard(
                    icon: Icons.calendar_today,
                    title: "Calendar",
                    description: "Avoid double-booking and suggest actions based on schedule.",
                    status: permissions[Permission.calendarFullAccess] ?? PermissionStatus.denied,
                    onRequest: () async => await _handlePermissionRequest(context, ref, Permission.calendarFullAccess),
                  ),
                  const SizedBox(height: 16),
                  _PermissionCard(
                    icon: Icons.contacts,
                    title: "Contacts",
                    description: "Easily send money, messages, or share ETAs.",
                    status: permissions[Permission.contacts] ?? PermissionStatus.denied,
                    onRequest: () async => await _handlePermissionRequest(context, ref, Permission.contacts),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus status;
  final Future<void> Function() onRequest;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onRequest,
  });

  @override
  State<_PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<_PermissionCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);
    await widget.onRequest();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGranted = widget.status.isGranted;
    final isPermanentlyDenied = widget.status.isPermanentlyDenied;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, size: 28, color: isGranted ? Colors.greenAccent : Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isGranted)
            const Icon(Icons.check_circle, color: Colors.greenAccent)
          else if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
            )
          else
            TextButton(
              onPressed: _handleTap,
              style: TextButton.styleFrom(
                backgroundColor: isPermanentlyDenied 
                    ? Colors.grey.withValues(alpha: 0.2) 
                    : Colors.blueAccent.withValues(alpha: 0.2),
                foregroundColor: isPermanentlyDenied 
                    ? Colors.white54 
                    : Colors.blueAccent,
              ),
              child: Text(isPermanentlyDenied ? "Denied" : "Allow"),
            ),
        ],
      ),
    );
  }
}

class _SyncPage extends StatefulWidget {
  final VoidCallback onComplete;
  const _SyncPage({required this.onComplete});

  @override
  State<_SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<_SyncPage> {
  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    // Delay to show loading UI
    await Future.delayed(const Duration(milliseconds: 500));
    
    await DatabaseService.init();
    await DatabaseService.runInitialSync();
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: Lottie.network(
                'https://assets3.lottiefiles.com/packages/lf20_p10nxqxe.json',
                errorBuilder: (context, error, stackTrace) =>
                    const CircularProgressIndicator(color: Colors.cyanAccent),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Building your local\nknowledge graph...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Fetching events, contacts, and locations.",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
