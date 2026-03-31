import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';
import '../../providers/gps_provider.dart';
import '../../ui/status_tiles_grid.dart';
import '../scan/device_scan_dialog.dart';

class WorkbenchView extends StatefulWidget {
  const WorkbenchView({super.key});

  @override
  State<WorkbenchView> createState() => _WorkbenchViewState();
}

class _WorkbenchViewState extends State<WorkbenchView> {
  bool _hasShownAutoDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoShowDialog();
    });
  }

  void _checkAutoShowDialog() {
    final session = context.read<SessionProvider>();
    final device = session.connectedDevice;

    // Auto show dialog on startup if not connected
    if ((device == null || !device.isAuthenticated) && !_hasShownAutoDialog) {
      _hasShownAutoDialog = true;
      _showScanDialog();
    }
  }

  Future<void> _showScanDialog() async {
    final connected = await showDeviceScanDialog(context);
    if (connected) {
      // Connection successful, dialog closed automatically
      setState(() {
        _hasShownAutoDialog = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final gps = context.watch<GpsProvider>();
    final device = session.connectedDevice;
    final status = session.cameraStatus;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => session.requestVersion(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status tiles grid with integrated mode selector
            StatusTilesGrid(
              status: status,
              isConnected: device != null && device.isAuthenticated,
              deviceName: device?.deviceName,
              deviceId: session.cameraDeviceId,
              gpsEnabled: gps.gpsEnabled,
              gpsPoint: gps.lastGpsPoint,
              onShowScanDialog: _showScanDialog,
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
