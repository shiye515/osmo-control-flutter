import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../config/app_theme.dart';
import '../../models/camera_status_model.dart';
import '../../models/session_device_model.dart';
import '../../providers/session_provider.dart';
import '../../ui/control_button.dart';
import '../../ui/mode_scroll_selector.dart';
import '../../ui/status_tiles_grid.dart';

class WorkbenchView extends StatelessWidget {
  const WorkbenchView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final device = session.connectedDevice;
    final status = session.cameraStatus;

    // If not connected, redirect to scan page
    if (device == null || !device.isAuthenticated) {
      // Use post-frame callback to avoid modifying during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/scan');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ToastificationWrapper(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => session.requestVersion(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status tiles grid (top of workbench)
              StatusTilesGrid(
                status: status,
                isConnected: device.isAuthenticated,
                deviceName: device.deviceName,
                onRefresh: () => session.requestVersion(),
                onDisconnect: () {
                  session.disconnect();
                  context.go('/scan');
                },
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModeScrollSelector(
                    currentMode: status.cameraMode,
                    onModeSelected: (mode) => session.switchMode(mode),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Device info
              _DeviceInfoCard(device: device, status: status),
              const SizedBox(height: 16),

              // Quick actions
              _QuickActionsCard(session: session),
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
              icon:
                  isRecording ? Icons.stop_circle : Icons.radio_button_checked,
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
            Text('设备信息', style: Theme.of(context).textTheme.titleSmall),
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
    final hasRememberedDevice = session.rememberedDevice != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('快捷操作', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (isSleeping)
                  Chip(
                    avatar: const Icon(Icons.bedtime,
                        size: 16, color: Colors.orange),
                    label: const Text('休眠中',
                        style: TextStyle(color: Colors.orange)),
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isConnected && !isSleeping
                        ? () => _onSleep(context, session)
                        : null,
                    icon: const Icon(Icons.bedtime_outlined),
                    label: const Text('休眠'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isConnected ? () => _onWake(context, session) : null,
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
            if (hasRememberedDevice) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _onForgetDevice(context, session),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('忘记此设备'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
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

  void _onForgetDevice(BuildContext context, SessionProvider session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('忘记设备'),
        content: Text(
            '确定要忘记 "${session.rememberedDevice?.name}" 吗？\n下次启动应用将不会自动连接。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('忘记'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await session.forgetDevice();
      if (context.mounted) {
        toastification.show(
          context: context,
          title: const Text('已忘记设备'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }
}
