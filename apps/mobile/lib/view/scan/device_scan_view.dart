import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/scan_result_model.dart';
import '../../providers/ble_provider.dart';
import '../../providers/session_provider.dart';

class DeviceScanView extends StatefulWidget {
  const DeviceScanView({super.key});

  @override
  State<DeviceScanView> createState() => _DeviceScanViewState();
}

class _DeviceScanViewState extends State<DeviceScanView> {
  bool _connecting = false;
  String? _connectingId;
  bool _autoConnectAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load remembered device first
      context.read<SessionProvider>().loadRememberedDevice();
      // Then start scan
      context.read<BleProvider>().startScan();
    });
  }

  void _tryAutoConnect(SessionProvider session, List<ScanResultModel> results) {
    if (_autoConnectAttempted || _connecting) return;

    final remembered = session.rememberedDevice;
    if (remembered == null) return;

    // Check if remembered device is in scan results
    final found = results.any((r) => r.deviceId == remembered.id);
    if (found) {
      _autoConnectAttempted = true;
      _onConnect(
        results.firstWhere((r) => r.deviceId == remembered.id),
        session,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final session = context.watch<SessionProvider>();

    // Try auto-connect when scan results update
    if (ble.scanResults.isNotEmpty && !_autoConnectAttempted) {
      _tryAutoConnect(session, ble.scanResults);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描设备'),
        actions: [
          if (ble.isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _autoConnectAttempted = false;
                ble.startScan();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (!ble.isAvailable)
            const _BleUnavailableBanner(),
          if (session.rememberedDevice != null && !_autoConnectAttempted)
            _AutoConnectBanner(deviceName: session.rememberedDevice!.name),
          Expanded(
            child: ble.scanResults.isEmpty
                ? _EmptyState(isScanning: ble.isScanning)
                : ListView.builder(
                    itemCount: ble.scanResults.length,
                    itemBuilder: (context, i) {
                      final result = ble.scanResults[i];
                      final isRemembered =
                          session.rememberedDevice?.id == result.deviceId;
                      return _DeviceTile(
                        result: result,
                        isConnecting:
                            _connecting && _connectingId == result.deviceId,
                        isRemembered: isRemembered,
                        onConnect: () => _onConnect(result, session),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConnect(
      ScanResultModel result, SessionProvider session) async {
    setState(() {
      _connecting = true;
      _connectingId = result.deviceId;
    });
    final success =
        await session.connect(result.deviceId, result.deviceName);
    if (!mounted) return;
    setState(() {
      _connecting = false;
      _connectingId = null;
    });
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('连接失败，请重试')),
      );
    }
  }
}

class _AutoConnectBanner extends StatelessWidget {
  final String deviceName;
  const _AutoConnectBanner({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '正在寻找 $deviceName...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BleUnavailableBanner extends StatelessWidget {
  const _BleUnavailableBanner();

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text('蓝牙未开启，请开启蓝牙后重试'),
      leading: const Icon(Icons.bluetooth_disabled),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('知道了'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isScanning ? '正在扫描附近设备...' : '未发现设备',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResultModel result;
  final bool isConnecting;
  final bool isRemembered;
  final VoidCallback onConnect;
  const _DeviceTile(
      {required this.result,
      required this.isConnecting,
      required this.isRemembered,
      required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isRemembered ? Icons.bluetooth_connected : Icons.bluetooth,
        color: isRemembered ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Row(
        children: [
          Text(result.deviceName),
          if (isRemembered) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '曾连接',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(result.deviceId),
      trailing: isConnecting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: onConnect,
              child: const Text('连接'),
            ),
    );
  }
}
