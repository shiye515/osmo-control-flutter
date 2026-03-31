import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/session_provider.dart';
import '../../providers/gps_provider.dart';
import '../../ui/status_tiles_grid.dart';

class WorkbenchView extends StatelessWidget {
  const WorkbenchView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final gps = context.watch<GpsProvider>();
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
            // Status tiles grid with integrated mode selector
            StatusTilesGrid(
              status: status,
              isConnected: device.isAuthenticated,
              deviceName: device.deviceName,
              deviceId: session.cameraDeviceId,
              gpsEnabled: gps.gpsEnabled,
              gpsPoint: gps.lastGpsPoint,
              onDisconnect: () {
                session.disconnect();
                context.go('/scan');
              },
              onRecordControl: () => _onRecordControl(session),
              onModeSelected: (mode) => session.switchMode(mode),
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
