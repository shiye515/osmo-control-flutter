import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/session_provider.dart';
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

    return Scaffold(
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
              onDisconnect: () {
                session.disconnect();
                context.go('/scan');
              },
              onRecordControl: () => _onRecordControl(session),
            ),
            const SizedBox(height: 16),

            // Mode selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ModeScrollSelector(
                  currentMode: status.cameraMode,
                  deviceId: session.cameraDeviceId,
                  onModeSelected: (mode) => session.switchMode(mode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRecordControl(SessionProvider session) {
    final status = session.cameraStatus;
    if (status.isRecording) {
      session.toggleRecording();
    } else if (status.cameraMode == 0x05) {
      // Photo mode
      session.takeSnapshot();
    } else {
      session.toggleRecording();
    }
  }
}
