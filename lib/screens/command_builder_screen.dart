import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/icon_provider.dart';

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const count = 30;
    final angle = (2 * math.pi) / count;

    for (int i = 0; i < count; i++) {
      final x = center.dx + radius * math.cos(i * angle);
      final y = center.dy + radius * math.sin(i * angle);
      canvas.drawCircle(Offset(x, y), 0.75, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CommandBuilderScreen extends ConsumerStatefulWidget {
  final String category;
  final dynamic iconData;

  const CommandBuilderScreen({super.key, required this.category, required this.iconData});

  @override
  ConsumerState<CommandBuilderScreen> createState() => _CommandBuilderScreenState();
}

class _CommandBuilderScreenState extends ConsumerState<CommandBuilderScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': 'icons/fi-rr-shopping-cart.svg', 'label': 'Buy'},
    {'icon': 'icons/fi-rr-play-alt.svg', 'label': 'Play'},
    {'icon': 'icons/fi-rr-clock.svg', 'label': 'Schedule'},
    {'icon': 'icons/fi-rr-map-marker-plus.svg', 'label': 'Travel'}, // Assuming map marker + is travel based on design
    {'icon': 'icons/fi-rr-comment.svg', 'label': 'Talk'},
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _categories.indexWhere((c) => c['label'] == widget.category);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getCommandText(List<String> tray, String activeCategoryLabel) {
    if (tray.isEmpty) return '$activeCategoryLabel ...';
    
    if (activeCategoryLabel == 'Buy') {
      if (tray[0] == 'icons/fi-rr-ticket.svg') {
        if (tray.length > 1) {
          final type = tray[1];
          if (type == 'icons/fi-rr-plane.svg') return 'Get flight ticket ...';
          if (type == 'icons/fi-rr-train-side.svg' || type == 'icons/fi-rr-train.svg') return 'Get train ticket ...';
          if (type == 'icons/fi-rr-film.svg') return 'Get movie ticket ...';
          if (type == 'icons/fi-rr-theatre.svg') return 'Get theatre ticket ...';
          return 'Get ticket for ...';
        }
        return 'Get ticket ...';
      }
    }
    return '$activeCategoryLabel ...';
  }

  List<String> _getGridIcons(List<String> tray, String currentCategory) {
    if (tray.isEmpty) {
      // Level 1 Options depending on selected category
      switch (currentCategory) {
        case 'Buy':
          return [
            'icons/fi-rr-ticket.svg',
            'icons/fi-rr-carrot.svg',
            'icons/fi-rr-utensils.svg',
            'icons/fi-rr-cook-clothes-hanger.svg',
            'icons/fi-rr-key.svg',
            'icons/fi-rr-chart-pie.svg',
            'icons/fi-rr-copyright.svg',
            'icons/fi-rr-filter.svg',
            'icons/fi-rr-receipt.svg',
            'icons/fi-rr-list.svg',
          ];
        case 'Play':
          return [
            'icons/fi-rr-graduation-cap.svg',
            'icons/fi-rr-video-camera.svg',
            'icons/fi-rr-gym.svg',
            'icons/fi-rr-gamepad.svg',
            'icons/fi-rr-file-music.svg',
            'icons/fi-rr-pencil.svg',
            'icons/fi-rr-picture.svg',
            'icons/fi-rr-book-alt.svg',
            'icons/fi-rr-palette.svg',
            'icons/fi-rr-headset.svg',
            'icons/fi-rr-scan.svg', // Bottom left icon shown in Play mock
          ];
        case 'Schedule':
          return [
            'icons/fi-rr-calendar.svg',
            'icons/fi-rr-list-check.svg',
            'icons/fi-rr-transform.svg', // Closest match to the syncing/repeating icon
            'icons/fi-rr-alarm-clock.svg',
            'icons/fi-rr-train-side.svg',
            'icons/fi-rr-school-bus.svg',
          ];
        case 'Travel':
          return [
            'icons/fi-rr-share.svg',
            'icons/fi-rr-calendar.svg',
            'icons/fi-rr-woman-head.svg', // Assuming woman-head for the user/face icon shown
            'icons/fi-rr-walk.svg',
            'icons/fi-rr-bike.svg',
            'icons/fi-rr-car.svg',
            'icons/fi-rr-school-bus.svg',
            'icons/fi-rr-train-side.svg',
            'icons/fi-rr-plane.svg',
          ];
        case 'Talk':
          return [
            'icons/fi-rr-megaphone.svg',
            'icons/fi-rr-envelope-plus.svg',
            'icons/fi-rr-phone-call.svg',
            'icons/fi-rr-comment-alt.svg',
            'icons/fi-rr-microphone.svg',
          ];
        default:
          return [];
      }
    } else if (tray.first == 'icons/fi-rr-ticket.svg') {
      // Level 2 Options (Tickets in Buy)
      return [
        'icons/fi-rr-plane.svg',
        'icons/fi-rr-train-side.svg',
        'icons/fi-rr-school-bus.svg',
        'icons/fi-rr-ship.svg',
        'icons/fi-rr-gift.svg',
        'icons/fi-rr-film.svg',
        'icons/fi-rr-theatre.svg',
        'icons/fi-rr-microphone.svg',
        'icons/fi-rr-palette.svg',
        'icons/fi-rr-fish.svg',
        'icons/fi-rr-bank.svg',
        'icons/fi-rr-fortress.svg',
        'icons/fi-rr-paw.svg',
        'icons/fi-rr-ferris-wheel.svg',
        'icons/fi-rr-butterfly.svg',
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final iconState = ref.watch(iconProvider);
    final trayIcons = iconState.trayIcons;
    final activeCategory = _categories[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Very dark background
      body: SafeArea(
        child: Stack(
          children: [
            if (trayIcons.isEmpty)
              _buildLevel1(activeCategory)
            else
              _buildLevel2(trayIcons, activeCategory),

            // Close button (Visible on both levels)
            Positioned(
              top: 16,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  ref.read(iconProvider.notifier).clearTray();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevel1(Map<String, dynamic> activeCategory) {
    return Stack(
      children: [
        // Swipable pages for categories
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final pageCategory = _categories[index];
            final gridIcons = _getGridIcons([], pageCategory['label']);
            
            return Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 64.0), // Padding to avoid sidebar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Text Translation Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap on the icons below and personalise',
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pageCategory['label']} ...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),

                  // Grid Area
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: gridIcons.length,
                    itemBuilder: (context, gridIndex) {
                      final path = gridIcons[gridIndex];
                      return GestureDetector(
                        onTap: () {
                          // Tap selects icon and transitions to Level 2
                          ref.read(iconProvider.notifier).toggleIcon(path);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            path,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      );
                    },
                  ),

                  // Spacer to push the grid up, mimicking the level 2 layout without tray
                  const Spacer(flex: 5),
                ],
              ),
            );
          },
        ),

        // Static Right Sidebar Overlay
        Positioned(
          right: 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.asMap().entries.map((entry) {
                final isActive = entry.key == _currentIndex;
                final icon = entry.value['icon'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: _buildSidebarIcon(icon, isActive: isActive),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevel2(List<String> trayIcons, Map<String, dynamic> activeCategory) {
    final gridIcons = _getGridIcons(trayIcons, activeCategory['label']);
    final commandText = _getCommandText(trayIcons, activeCategory['label']);
    
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        ref.read(iconProvider.notifier).removeIcon(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.transparent, // Ensure it accepts touches in empty spaces
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Text Translation Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tap on the icons below and personalise',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      commandText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),

              // Grid Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: gridIcons.length,
                  itemBuilder: (context, index) {
                    final path = gridIcons[index];
                    final isSelected = trayIcons.contains(path);
                    return GestureDetector(
                      onTap: () {
                        ref.read(iconProvider.notifier).toggleIcon(path);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white24 : const Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          path,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(flex: 3),

              // Tray Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Initial category icon (Slot 0)
                    _buildTraySlot(iconData: activeCategory['icon'], isBase: true),
                    const SizedBox(width: 8),
                    
                    // Dynamic tray slots (Slots 1-4)
                    ...List.generate(4, (index) {
                      final iconPath = index < trayIcons.length ? trayIcons[index] : null;
                      return Padding(
                        padding: EdgeInsets.only(right: index < 3 ? 8.0 : 0.0),
                        child: _buildTraySlot(iconPath: iconPath),
                      );
                    }),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mic
                    _buildActionButton(Icons.mic_none, const Color(0xFF2A2A2A)),
                    
                    // Refresh (Center)
                    GestureDetector(
                      onTap: () {
                        ref.read(iconProvider.notifier).clearTray();
                      },
                      child: _buildActionButton(Icons.refresh, const Color(0xFF2A2A2A)),
                    ),
                    
                    // Execute (Right)
                    _buildActionButton(Icons.arrow_upward, Colors.white, iconColor: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarIcon(dynamic icon, {required bool isActive}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: icon is String
          ? SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
          : Icon(icon as IconData, color: Colors.white, size: 20),
    );
  }

  Widget _buildTraySlot({String? iconPath, dynamic iconData, bool isBase = false}) {
    final hasIcon = iconPath != null || (isBase && iconData != null);
    
    Widget innerChild;
    if (isBase && iconData != null) {
      innerChild = iconData is String
          ? SvgPicture.asset(iconData, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn))
          : Icon(iconData as IconData, color: Colors.black, size: 24);
    } else if (iconPath != null) {
      innerChild = SvgPicture.asset(iconPath, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn));
    } else {
      innerChild = const SizedBox();
    }

    if (!hasIcon) {
      // Empty dotted slot
      return CustomPaint(
        painter: DottedBorderPainter(),
        child: const SizedBox(width: 56, height: 56),
      );
    }

    // Filled slot widget
    final slotWidget = Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(child: innerChild),
    );

    // Make the slot draggable to remove it, unless it is the base category icon
    if (!isBase && iconPath != null) {
      return Draggable<String>(
        data: iconPath,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 64, // Slightly enlarged while dragging
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath, 
                width: 28, 
                height: 28, 
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)
              ),
            ),
          ),
        ),
        // What remains in the tray while dragging (an empty dotted slot)
        childWhenDragging: CustomPaint(
          painter: DottedBorderPainter(),
          child: const SizedBox(width: 56, height: 56),
        ),
        child: GestureDetector(
          // Allow tap-to-remove as a fallback/alternative to dragging
          onTap: () => ref.read(iconProvider.notifier).removeIcon(iconPath),
          child: slotWidget,
        ),
      );
    }

    return slotWidget;
  }

  Widget _buildActionButton(IconData icon, Color bgColor, {Color iconColor = Colors.white}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}
