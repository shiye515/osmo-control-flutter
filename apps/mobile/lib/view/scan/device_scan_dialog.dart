import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/scan_result_model.dart';
import '../../providers/ble_provider.dart';
import '../../providers/session_provider.dart';

/// Shows the device scan dialog as a modal bottom sheet.
/// Returns true if a device was connected, false otherwise.
Future<bool> showDeviceScanDialog(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const DeviceScanDialog(),
  );
  return result ?? false;
}

class DeviceScanDialog extends StatefulWidget {
  const DeviceScanDialog({super.key});

  @override
  State<DeviceScanDialog> createState() => _DeviceScanDialogState();
}

class _DeviceScanDialogState extends State<DeviceScanDialog> {
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
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        _startScan();
      }
    });
  }

  void _startScan() {
    final ble = context.read<BleProvider>();
    _autoConnectAttempted = false;
    ble.startScan();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final session = context.watch<SessionProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Try auto-connect when scan results update
    if (ble.scanResults.isNotEmpty && !_autoConnectAttempted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tryAutoConnect(session, ble.scanResults, l10n);
        }
      });
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.scanDevices,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (ble.isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _autoConnectAttempted = false;
                        ble.startScan();
                      },
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    if (!ble.isAvailable) _BleUnavailableBanner(l10n: l10n),
                    // Connected device section
                    if (session.isConnected)
                      _ConnectedDeviceTile(
                        deviceName: session.connectedDevice?.deviceName ?? 'Osmo',
                        onDisconnect: () => _onDisconnect(session),
                        l10n: l10n,
                      ),
                    if (ble.scanResults.isEmpty)
                      _EmptyState(isScanning: ble.isScanning, l10n: l10n)
                    else
                      ...ble.scanResults.map((result) {
                        final isRemembered =
                            session.rememberedDevice?.id == result.deviceId;
                        final isConnected = session.connectedDevice?.deviceId == result.deviceId;
                        if (isConnected) return const SizedBox.shrink(); // Skip already connected device
                        return _DeviceTile(
                          result: result,
                          isConnecting:
                              _connecting && _connectingId == result.deviceId,
                          isRemembered: isRemembered,
                          onConnect: () => _onConnect(result, session, l10n),
                          l10n: l10n,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onConnect(ScanResultModel result, SessionProvider session,
      AppLocalizations l10n) async {
    setState(() {
      _connecting = true;
      _connectingId = result.deviceId;
    });
    final success = await session.connect(result.deviceId, result.deviceName);
    if (!mounted) return;
    setState(() {
      _connecting = false;
      _connectingId = null;
    });
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectionFailed)),
      );
    }
  }

  void _tryAutoConnect(SessionProvider session, List<ScanResultModel> results,
      AppLocalizations l10n) {
    if (_autoConnectAttempted || _connecting) return;

    final remembered = session.rememberedDevice;
    if (remembered == null) return;

    // Skip auto-connect if user manually disconnected this device
    if (session.userDisconnectedDeviceId == remembered.id) return;

    // Skip auto-connect if already connected
    if (session.isConnected) return;

    final found = results.any((r) => r.deviceId == remembered.id);
    if (found) {
      _autoConnectAttempted = true;
      _onConnect(
        results.firstWhere((r) => r.deviceId == remembered.id),
        session,
        l10n,
      );
    }
  }

  void _onDisconnect(SessionProvider session) {
    session.disconnectManually();
  }
}

class _BleUnavailableBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _BleUnavailableBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(l10n.bluetoothDisabled),
      leading: const Icon(Icons.bluetooth_disabled),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(l10n.gotIt),
        ),
      ],
    );
  }
}

/// Tile showing the currently connected device with disconnect button.
class _ConnectedDeviceTile extends StatelessWidget {
  final String deviceName;
  final VoidCallback onDisconnect;
  final AppLocalizations l10n;
  const _ConnectedDeviceTile({
    required this.deviceName,
    required this.onDisconnect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth_connected,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          deviceName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: TextButton(
          onPressed: onDisconnect,
          child: Text(
            l10n.disconnect,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  final AppLocalizations l10n;
  const _EmptyState({required this.isScanning, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isScanning ? l10n.scanningDevices : l10n.noDevicesFound,
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
  final AppLocalizations l10n;
  const _DeviceTile({
    required this.result,
    required this.isConnecting,
    required this.isRemembered,
    required this.onConnect,
    required this.l10n,
  });

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
                l10n.previouslyConnected,
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
              child: Text(l10n.connect),
            ),
    );
  }
}
