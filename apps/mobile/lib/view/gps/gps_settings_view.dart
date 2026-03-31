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
                      onChanged: (value) async {
                        if (value) {
                          // Will auto-start GPS
                          gps.setAutoPushEnabled(true);
                        } else {
                          gps.setAutoPushEnabled(false);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pushInterval,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(value: 2, label: Text(l10n.interval2s)),
                        ButtonSegment(value: 5, label: Text(l10n.interval5s)),
                        ButtonSegment(value: 10, label: Text(l10n.interval10s)),
                      ],
                      selected: {gps.pushIntervalSec},
                      onSelectionChanged: (Set<int> selection) {
                        gps.setPushIntervalSec(selection.first);
                        gps.savePushIntervalState();
                      },
                    ),
                  ],
                ),
              ),
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