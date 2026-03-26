import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'command_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  
  // Track the center of the sparkle button to calculate distances for drag-to-select
  Offset _sparkleCenter = Offset.zero;
  final GlobalKey _sparkleKey = GlobalKey();

  // The categories matching the design strictly
  final List<Map<String, dynamic>> _categories = [
    {'icon': 'icons/fi-rr-shopping-cart.svg', 'label': 'Buy'},
    {'icon': 'icons/fi-rr-play-alt.svg', 'label': 'Play'},
    {'icon': 'icons/fi-rr-clock.svg', 'label': 'Schedule'},
    {'icon': 'icons/fi-rr-map-marker-plus.svg', 'label': 'Travel'},
    {'icon': 'icons/fi-rr-comment.svg', 'label': 'Talk'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Get the position of the sparkle button after the layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSparklePosition();
    });
  }

  void _updateSparklePosition() {
    final RenderBox? renderBox = _sparkleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _sparkleCenter = Offset(
        position.dx + renderBox.size.width / 2,
        position.dy + renderBox.size.height / 2,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isExpanded = true;
      _controller.forward();
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _handleSelectionRelease(details.globalPosition);
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }
  
  void _handleSelectionRelease(Offset releasePosition) {
    if (_sparkleCenter == Offset.zero) return;

    // Radius of the expanded icons
    final double radius = 80.0; 
    
    // Define the angles for the 5 icons (expanded to give more space between icons)
    final double startAngle = -math.pi / 1.8; // Move top icon higher
    final double endAngle = math.pi / 1.8; // Move bottom icon lower
    final double angleStep = (endAngle - startAngle) / (_categories.length - 1);

    // Calculate the distance from the sparkle button to where the finger was released
    final distance = (releasePosition - _sparkleCenter).distance;

    // If the finger was dragged far enough out (into the menu ring)
    if (distance > radius * 0.5) {
      // Find the angle of the drag
      final dragVector = releasePosition - _sparkleCenter;
      final dragAngle = math.atan2(dragVector.dy, dragVector.dx);

      // Find which category angle is closest to the drag angle
      double minDiff = double.infinity;
      int selectedIndex = -1;

      for (int i = 0; i < _categories.length; i++) {
        final itemAngle = startAngle + (i * angleStep);
        
        // Ensure angles are compared correctly (handling the wrap around pi)
        double diff = (itemAngle - dragAngle).abs();
        if (diff > math.pi) diff = 2 * math.pi - diff;

        if (diff < minDiff) {
          minDiff = diff;
          selectedIndex = i;
        }
      }

      // If a match is found and the angle difference isn't too extreme
      // (Using a wider tolerance now since the items are spread further apart)
      if (selectedIndex != -1 && minDiff < (angleStep * 1.5)) {
        final category = _categories[selectedIndex];
        _navigateToCategory(category['label'], category['icon']);
      }
    }
  }

  void _navigateToCategory(String label, dynamic iconData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CommandBuilderScreen(category: label, iconData: iconData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Very dark background
      body: Stack(
        children: [
          // Background text
          AnimatedOpacity(
            opacity: _isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: const Text(
                  'Unlock what\nyou need',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Icons
          Positioned(
            left: 32,
            bottom: 48,
            child: _buildBottomButton(Icons.flashlight_on),
          ),
          Positioned(
            right: 32,
            bottom: 48,
            child: _buildBottomButton(Icons.camera_alt),
          ),

          // Menu Items
          ..._buildMenuItems(),

          // Main Sparkle Button
          Positioned(
            right: 24,
            top: MediaQuery.of(context).size.height / 2 - 32,
            child: GestureDetector(
              key: _sparkleKey,
              onLongPressStart: _onLongPressStart,
              onLongPressEnd: _onLongPressEnd,
              // Removed the onTap callback so it ONLY responds to long presses
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _isExpanded ? Colors.transparent : const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'icons/fi-rr-magic-wand.svg', // Sparkles icon
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      _isExpanded ? Colors.white54 : Colors.white, 
                      BlendMode.srcIn
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 24),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [];
    final double radius = 80.0; // Keeps the icons closer to the sparkle button
    
    // Spread the icons across a wider angle to give them more breathing room
    final double startAngle = -math.pi / 1.8;
    final double endAngle = math.pi / 1.8;
    final double angleStep = (endAngle - startAngle) / (_categories.length - 1);

    for (int i = 0; i < _categories.length; i++) {
      final angle = startAngle + (i * angleStep);
      final iconData = _categories[i]['icon'];

      items.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = Curves.easeOutBack.transform(_controller.value);
            final double currentRadius = radius * value;
            return Positioned(
              // Center of sparkle button is at right: 56, top: height/2
              // Math is calculated from center, minus half icon width (28)
              right: 56 - 28 + (currentRadius * math.cos(angle)),
              top: MediaQuery.of(context).size.height / 2 - 28 + (currentRadius * math.sin(angle)),
              child: Transform.scale(
                scale: _controller.value,
                child: Opacity(
                  opacity: _controller.value.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconData is String
                  ? SvgPicture.asset(
                      iconData,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    )
                  : Icon(iconData as IconData, color: Colors.black, size: 28),
            ),
          ),
        ),
      );
    }
    return items;
  }
}
