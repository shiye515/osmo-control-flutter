import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/camera_modes.dart';
import '../l10n/app_localizations.dart';
import '../models/camera_status_model.dart';
import '../models/gps_point_model.dart';
import 'status_tile.dart';

/// Grid of status tiles displaying all available camera status.
/// Includes a 2x2 mode selector tile.
class StatusTilesGrid extends StatelessWidget {
  final CameraStatusModel status;
  final bool isConnected;
  final String? deviceName;
  final int deviceId;
  final bool gpsEnabled;
  final GpsPointModel? gpsPoint;
  final VoidCallback? onShowScanDialog;
  final VoidCallback? onRecordControl;
  final void Function(int mode)? onModeSelected;

  const StatusTilesGrid({
    super.key,
    required this.status,
    required this.isConnected,
    required this.deviceId,
    this.gpsEnabled = false,
    this.gpsPoint,
    this.deviceName,
    this.onShowScanDialog,
    this.onRecordControl,
    this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Remaining small tiles in 4-column grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: _buildSmallTiles(theme, l10n),
        ),
        const SizedBox(height: 8),
        // First row: Mode selector (2x2) + 2 small tiles
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Mode selector tile
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _ModeSelectorTile(
                  currentMode: status.cameraMode,
                  deviceId: deviceId,
                  onModeSelected: onModeSelected,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Right side: 2 small tiles stacked
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: _RecordControlTile(
                      isRecording: status.isRecording,
                      cameraMode: status.cameraMode,
                      onTap: onRecordControl,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildSmallTiles(ThemeData theme, AppLocalizations l10n) {
    return [
      AspectRatio(
        aspectRatio: 1.0,
        child: _ConnectionTile(
          deviceName: deviceName ?? 'Osmo',
          onTap: onShowScanDialog,
        ),
      ),
      // Battery
      StatusTile(
        icon: Icons.battery_5_bar_rounded,
        label: l10n.battery,
        value: status.batteryDisplay,
        iconColor: status.batteryPercent < 20
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Storage
      StatusTile(
        icon: Icons.sd_card_outlined,
        label: l10n.storage,
        value: status.storageDisplay,
        iconColor: status.remainCapacityMB < 1024
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Remaining recording time
      StatusTile(
        icon: Icons.timer_outlined,
        label: l10n.remaining,
        value: status.remainTimeDisplay,
      ),
      // Resolution
      StatusTile(
        icon: Icons.high_quality_outlined,
        label: l10n.resolution,
        value: status.resolutionDisplay,
      ),
      // Frame rate
      StatusTile(
        icon: Icons.speed_outlined,
        label: l10n.frameRate,
        value: status.fpsDisplay,
      ),
      // EIS mode
      StatusTile(
        icon: Icons.gps_fixed,
        label: l10n.eisMode,
        value: status.eisModeDisplay,
      ),
      // Recording time
      StatusTile(
        icon: Icons.timer_sharp,
        label: l10n.recording,
        value: status.recordTimeDisplay,
        iconColor: status.isRecording
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
      // Temperature
      StatusTile(
        icon: Icons.device_thermostat_outlined,
        label: l10n.temperature,
        value: status.isOverheating ? l10n.overheating : l10n.normal,
        iconColor: status.isOverheating
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Camera status
      StatusTile(
        icon: _getStatusIcon(status.cameraStatus),
        label: l10n.status,
        value: status.cameraStatusDisplay,
        iconColor: status.isRecording
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Power mode (sleep indicator)
      if (status.isSleeping)
        StatusTile(
          icon: Icons.bedtime,
          label: l10n.power,
          value: l10n.sleep,
          iconColor: Colors.orange,
        ),
      // GPS tile
      _GpsTile(
        enabled: gpsEnabled,
        gpsPoint: gpsPoint,
        l10n: l10n,
      ),
    ];
  }

  IconData _getStatusIcon(int cameraStatus) {
    switch (cameraStatus) {
      case 0:
        return Icons.power_off;
      case 1:
        return Icons.power;
      case 2:
        return Icons.play_circle_outline;
      case 3:
        return Icons.fiber_manual_record;
      case 5:
        return Icons.fiber_manual_record;
      default:
        return Icons.power;
    }
  }
}

/// 2x2 Mode selector tile with scroll wheel.
class _ModeSelectorTile extends StatefulWidget {
  final int currentMode;
  final int deviceId;
  final void Function(int mode)? onModeSelected;

  const _ModeSelectorTile({
    required this.currentMode,
    required this.deviceId,
    this.onModeSelected,
  });

  @override
  State<_ModeSelectorTile> createState() => _ModeSelectorTileState();
}

class _ModeSelectorTileState extends State<_ModeSelectorTile> {
  late FixedExtentScrollController _scrollController;
  Timer? _debounceTimer;
  int _selectedIndex = 0;
  bool _isUserScrolling = false;

  List<CameraModeDef> get _supportedModes => getSupportedModes(widget.deviceId);

  int _findModeIndex(int mode) {
    for (int i = 0; i < _supportedModes.length; i++) {
      if (_supportedModes[i].mode == mode) return i;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _findModeIndex(widget.currentMode);
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(_ModeSelectorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMode != widget.currentMode && !_isUserScrolling) {
      final newIndex = _findModeIndex(widget.currentMode);
      if (newIndex != _selectedIndex) {
        _selectedIndex = newIndex;
        _scrollController.animateToItem(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    if (oldWidget.deviceId != widget.deviceId) {
      _selectedIndex = _findModeIndex(widget.currentMode);
      _scrollController.dispose();
      _scrollController =
          FixedExtentScrollController(initialItem: _selectedIndex);
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _isUserScrolling = false;
      if (_selectedIndex < _supportedModes.length) {
        final selectedMode = _supportedModes[_selectedIndex].mode;
        if (selectedMode != widget.currentMode) {
          HapticFeedback.mediumImpact();
          widget.onModeSelected?.call(selectedMode);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Center indicator
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
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
              diameterRatio: 1.2,
              perspective: 0.005,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                _selectedIndex = index;
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _supportedModes.length,
                builder: (context, index) {
                  final mode = _supportedModes[index];
                  final isSelected = index == _selectedIndex;

                  return Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: isSelected ? 1.0 : 0.4,
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
                          const SizedBox(width: 6),
                          Text(
                            mode.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
    );
  }
}

/// Connection status tile - tap to show scan dialog.
class _ConnectionTile extends StatelessWidget {
  final String deviceName;
  final VoidCallback? onTap;

  const _ConnectionTile({
    required this.deviceName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_connected,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              deviceName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Record control tile - smart tile that shows record/stop/photo based on state.
class _RecordControlTile extends StatelessWidget {
  final bool isRecording;
  final int cameraMode;
  final VoidCallback? onTap;
  final AppLocalizations l10n;

  const _RecordControlTile({
    required this.isRecording,
    required this.cameraMode,
    this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isPhotoMode = cameraMode == 0x05;
    final iconData = isRecording
        ? Icons.stop_circle
        : (isPhotoMode ? Icons.camera_alt : Icons.fiber_manual_record);
    final label = isRecording ? l10n.stop : (isPhotoMode ? l10n.photo : l10n.record);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isRecording
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 28,
              color: isRecording
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isRecording
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// GPS data tile - shows GPS coordinates when enabled.
class _GpsTile extends StatelessWidget {
  final bool enabled;
  final GpsPointModel? gpsPoint;
  final AppLocalizations l10n;

  const _GpsTile({
    required this.enabled,
    this.gpsPoint,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconData;
    String label;
    String value;
    Color? iconColor;

    if (!enabled) {
      iconData = Icons.location_off;
      label = 'GPS';
      value = l10n.gpsNotEnabled;
      iconColor = theme.colorScheme.onSurfaceVariant;
    } else if (gpsPoint == null) {
      iconData = Icons.location_searching;
      label = 'GPS';
      value = l10n.gpsAcquiring;
      iconColor = theme.colorScheme.primary;
    } else {
      iconData = Icons.location_on;
      label = '${gpsPoint!.latitude.toStringAsFixed(4)}';
      value = '${gpsPoint!.longitude.toStringAsFixed(4)}';
      iconColor = theme.colorScheme.primary;
    }

    return StatusTile(
      icon: iconData,
      label: label,
      value: value,
      iconColor: iconColor,
    );
  }
}
