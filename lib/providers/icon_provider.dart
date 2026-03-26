import 'package:flutter_riverpod/flutter_riverpod.dart';

class IconState {
  final List<String> trayIcons;

  IconState({required this.trayIcons});

  IconState copyWith({List<String>? trayIcons}) {
    return IconState(
      trayIcons: trayIcons ?? this.trayIcons,
    );
  }
}

class IconNotifier extends StateNotifier<IconState> {
  IconNotifier() : super(IconState(trayIcons: []));

  void toggleIcon(String iconPath) {
    if (state.trayIcons.contains(iconPath)) {
      state = state.copyWith(
        trayIcons: state.trayIcons.where((icon) => icon != iconPath).toList(),
      );
    } else {
      state = state.copyWith(
        trayIcons: [...state.trayIcons, iconPath],
      );
    }
  }

  void removeIcon(String iconPath) {
    if (state.trayIcons.contains(iconPath)) {
      state = state.copyWith(
        trayIcons: state.trayIcons.where((icon) => icon != iconPath).toList(),
      );
    }
  }

  void clearTray() {
    state = state.copyWith(trayIcons: []);
  }
}

final iconProvider = StateNotifierProvider<IconNotifier, IconState>((ref) {
  return IconNotifier();
});
