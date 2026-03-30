import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../config/app_theme.dart';
import '../../models/camera_status_model.dart';
import '../../models/session_device_model.dart';
import '../../providers/session_provider.dart';
import '../../ui/control_button.dart';
import '../../ui/mode_selector.dart';
import '../../ui/status_tiles_grid.dart';

class WorkbenchView extends StatelessWidget {
  const WorkbenchView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final device = session.connectedDevice;
    final status = session.cameraStatus;

    return ToastificationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('欧思魔控'),
        ),
        body: RefreshIndicator(
          onRefresh: () async => session.requestVersion(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (device != null && device.isAuthenticated) ...[
                // Status tiles grid (top of workbench)
                StatusTilesGrid(
                  status: status,
                  isConnected: device.isAuthenticated,
                  deviceName: device.deviceName,
                  onRefresh: () => session.requestVersion(),
                  onDisconnect: () => session.disconnect(),
                ),
                const SizedBox(height: 16),

                // Recording control
                _RecordingCard(
                  isRecording: status.isRecording,
                  onToggle: () => _onToggleRecording(context, session),
                  onSnapshot: () => _onSnapshot(context, session),
                ),
                const SizedBox(height: 16),

                // Mode selector
                ModeSelector(
                  currentMode: status.cameraMode,
                  onModeSelected: (mode) => session.switchMode(mode),
                ),
                const SizedBox(height: 16),

                // Device info
                _DeviceInfoCard(device: device, status: status),
                const SizedBox(height: 16),

                // Quick actions
                _QuickActionsCard(session: session),
              ] else ...[
                // Not connected - show scan button
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Icon(
                        Icons.bluetooth_disabled,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '未连接设备',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push('/scan'),
                        icon: const Icon(Icons.search),
                        label: const Text('扫描设备'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onToggleRecording(BuildContext context, SessionProvider session) async {
    final wasRecording = session.cameraStatus.isRecording;
    await session.toggleRecording();

    // Wait a moment for response to be processed
    await Future.delayed(const Duration(milliseconds: 300));

    if (context.mounted) {
      final nowRecording = session.cameraStatus.isRecording;
      // Only show toast if state actually changed
      if (nowRecording != wasRecording) {
        toastification.show(
          context: context,
          title: Text(nowRecording ? '开始录制' : '停止录制'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        toastification.show(
          context: context,
          title: const Text('操作失败'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _onSnapshot(BuildContext context, SessionProvider session) async {
    await session.takeSnapshot();
    if (context.mounted) {
      toastification.show(
        context: context,
        title: const Text('已拍照'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }
}

class _RecordingCard extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onToggle;
  final VoidCallback onSnapshot;
  const _RecordingCard({
    required this.isRecording,
    required this.onToggle,
    required this.onSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ControlButton(
              label: isRecording ? '停止录制' : '开始录制',
              icon: isRecording ? Icons.stop_circle : Icons.radio_button_checked,
              color: isRecording
                  ? AppTheme.recordingColor
                  : Theme.of(context).colorScheme.primary,
              onPressed: onToggle,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSnapshot,
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  final SessionDeviceModel device;
  final CameraStatusModel status;
  const _DeviceInfoCard({required this.device, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('设备信息',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _InfoRow(label: '设备名称', value: device.deviceName),
            _InfoRow(label: '设备ID', value: device.deviceId),
            if (device.firmwareVersion != null)
              _InfoRow(label: '固件版本', value: device.firmwareVersion!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final SessionProvider session;
  const _QuickActionsCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isSleeping = session.isSleeping;
    final isConnected = session.isConnected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('快捷操作',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (isSleeping)
                  Chip(
                    avatar: const Icon(Icons.bedtime, size: 16, color: Colors.orange),
                    label: const Text('休眠中', style: TextStyle(color: Colors.orange)),
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isConnected && !isSleeping ? () => _onSleep(context, session) : null,
                    icon: const Icon(Icons.bedtime_outlined),
                    label: const Text('休眠'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isConnected ? () => _onWake(context, session) : null,
                    icon: const Icon(Icons.wb_sunny_outlined),
                    label: const Text('唤醒'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => session.requestVersion(),
                    icon: const Icon(Icons.info_outlined),
                    label: const Text('版本'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSleep(BuildContext context, SessionProvider session) async {
    await session.sleep();
    if (context.mounted) {
      toastification.show(
        context: context,
        title: const Text('已发送休眠命令'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  void _onWake(BuildContext context, SessionProvider session) async {
    await session.wake();
    if (context.mounted) {
      toastification.show(
        context: context,
        title: const Text('已发送唤醒命令'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }
}