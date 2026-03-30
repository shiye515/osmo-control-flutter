import 'package:flutter/material.dart';
import '../models/camera_status_model.dart';
import 'status_tile.dart';

/// Grid of status tiles displaying all available camera status.
class StatusTilesGrid extends StatelessWidget {
  final CameraStatusModel status;
  final bool isConnected;
  final String? deviceName;
  final VoidCallback? onDisconnect;

  const StatusTilesGrid({
    super.key,
    required this.status,
    required this.isConnected,
    this.deviceName,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final tiles = _buildTiles(theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: tiles,
        ),
      ],
    );
  }

  List<Widget> _buildTiles(ThemeData theme) {
    return [
      // Connection status (clickable to disconnect)
      _ConnectionTile(
        deviceName: deviceName ?? 'Osmo',
        onDisconnect: onDisconnect,
      ),
      // Battery
      StatusTile(
        icon: Icons.battery_5_bar_rounded,
        label: '电量',
        value: status.batteryDisplay,
        iconColor: status.batteryPercent < 20
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Storage
      StatusTile(
        icon: Icons.sd_card_outlined,
        label: '存储',
        value: status.storageDisplay,
        iconColor: status.remainCapacityMB < 1024
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Remaining recording time
      StatusTile(
        icon: Icons.timer_outlined,
        label: '剩余',
        value: status.remainTimeDisplay,
      ),
      // Camera mode
      StatusTile(
        icon: _getModeIcon(status.cameraMode),
        label: '模式',
        value: status.cameraModeDisplay,
      ),
      // Resolution + FPS
      StatusTile(
        icon: Icons.videocam_outlined,
        label: status.resolutionDisplay,
        value: status.fpsDisplay,
      ),
      // Recording time
      StatusTile(
        icon: Icons.timer_sharp,
        label: '录制',
        value: status.recordTimeDisplay,
        iconColor: status.isRecording
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
      // Temperature
      StatusTile(
        icon: Icons.device_thermostat_outlined,
        label: '温度',
        value: status.isOverheating ? '过热' : '正常',
        iconColor: status.isOverheating
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Camera status
      StatusTile(
        icon: _getStatusIcon(status.cameraStatus),
        label: '状态',
        value: status.cameraStatusDisplay,
        iconColor: status.isRecording
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      // Power mode (sleep indicator)
      if (status.isSleeping)
        StatusTile(
          icon: Icons.bedtime,
          label: '电源',
          value: '休眠',
          iconColor: Colors.orange,
        ),
    ];
  }

  IconData _getModeIcon(int mode) {
    switch (mode) {
      case 0x00:
        return Icons.slow_motion_video;
      case 0x01:
        return Icons.videocam;
      case 0x02:
        return Icons.timelapse;
      case 0x05:
        return Icons.camera_alt;
      case 0x0A:
        return Icons.motion_photos_on;
      case 0x28:
        return Icons.nights_stay;
      case 0x34:
        return Icons.person_pin;
      default:
        return Icons.videocam;
    }
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

/// Connection status tile with disconnect action.
class _ConnectionTile extends StatelessWidget {
  final String deviceName;
  final VoidCallback? onDisconnect;

  const _ConnectionTile({
    required this.deviceName,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onDisconnect,
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
              // '已连接',
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
