import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/camera_modes.dart';

/// Scroll wheel mode selector similar to iOS time picker.
/// Sends mode switch command after scroll ends.
class ModeScrollSelector extends StatefulWidget {
  final int currentMode;
  final void Function(int mode) onModeSelected;

  const ModeScrollSelector({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  State<ModeScrollSelector> createState() => _ModeScrollSelectorState();
}

class _ModeScrollSelectorState extends State<ModeScrollSelector> {
  late FixedExtentScrollController _scrollController;
  Timer? _debounceTimer;
  int _selectedIndex = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = getCameraModeIndex(widget.currentMode);
    _scrollController = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(ModeScrollSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update position when currentMode changes externally (e.g., from status push)
    if (oldWidget.currentMode != widget.currentMode && !_isUserScrolling) {
      final newIndex = getCameraModeIndex(widget.currentMode);
      if (newIndex != _selectedIndex) {
        _selectedIndex = newIndex;
        _scrollController.animateToItem(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollStart() {
    _isUserScrolling = true;
    _debounceTimer?.cancel();
  }

  void _onScrollEnd() {
    // Wait for scroll to settle, then send command after 500ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _isUserScrolling = false;
      if (_selectedIndex < kCameraModes.length) {
        final selectedMode = kCameraModes[_selectedIndex].mode;
        if (selectedMode != widget.currentMode) {
          HapticFeedback.mediumImpact();
          widget.onModeSelected(selectedMode);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '相机模式',
            style: theme.textTheme.titleSmall,
          ),
        ),
        // Scroll wheel
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              // Center indicator
              Center(
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Scroll wheel
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _onScrollStart();
                  } else if (notification is ScrollEndNotification) {
                    _onScrollEnd();
                  }
                  return false;
                },
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 44,
                  diameterRatio: 1.5,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    _selectedIndex = index;
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: kCameraModes.length,
                    builder: (context, index) {
                      final mode = kCameraModes[index];
                      final isSelected = index == _selectedIndex;

                      return Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isSelected ? 1.0 : 0.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                mode.icon,
                                size: 20,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mode.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}