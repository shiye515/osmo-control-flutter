import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/gps_provider.dart';
import '../../utils/format_utils.dart';

class GpsSettingsView extends StatelessWidget {
  const GpsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final gps = context.watch<GpsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return ToastificationWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.gpsSettings)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // GPS 启用开关
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.gpsAcquisition, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(l10n.enableGps),
                      subtitle: Text(
                        gps.gpsEnabled
                            ? l10n.gpsAcquiringLocation
                            : l10n.gpsDisabled,
                        style: TextStyle(
                          color: gps.gpsEnabled
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      value: gps.gpsEnabled,
                      onChanged: (value) async {
                        final success = await gps.setGpsEnabled(value);
                        if (!success && value && context.mounted) {
                          // Permission denied
                          toastification.show(
                            context: context,
                            title: Text(l10n.locationPermissionDenied),
                            description: Text(l10n.allowLocationInSettings),
                            type: ToastificationType.warning,
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 当前位置
            Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.currentLocation, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  if (gps.lastGpsPoint != null) ...[
                    _InfoRow(
                        label: l10n.latitude,
                        value: gps.lastGpsPoint!.latitude.toStringAsFixed(6)),
                    _InfoRow(
                        label: l10n.longitude,
                        value: gps.lastGpsPoint!.longitude.toStringAsFixed(6)),
                    _InfoRow(
                        label: l10n.altitude,
                        value:
                            '${gps.lastGpsPoint!.altitude.toStringAsFixed(1)} m'),
                    _InfoRow(
                        label: l10n.accuracy,
                        value:
                            '${gps.lastGpsPoint!.accuracy.toStringAsFixed(1)} m'),
                    _InfoRow(
                        label: l10n.time,
                        value: FormatUtils.formatTime(
                            gps.lastGpsPoint!.timestamp)),
                  ] else
                    Text(l10n.noLocationData,
                        style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.autoPush, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(l10n.enableGpsAutoPush),
                    subtitle: Text(l10n.autoPushDescription),
                    value: gps.autoPushEnabled,
                    onChanged: gps.setAutoPushEnabled,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.pushFrequency(FormatUtils.formatFrequency(gps.frequencyHz)),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: gps.frequencyHz,
                    min: 0.1,
                    max: 10.0,
                    divisions: 99,
                    label: FormatUtils.formatFrequency(gps.frequencyHz),
                    onChanged: gps.setFrequencyHz,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: gps.lastGpsPoint == null
                ? null
                : () {
                    final p = gps.lastGpsPoint!;
                    gps.pushGpsNow(p.latitude, p.longitude, p.altitude);
                  },
            icon: const Icon(Icons.send),
            label: Text(l10n.pushNow),
          ),
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
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
