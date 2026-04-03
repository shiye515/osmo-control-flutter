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
            // Position info card
            _PositionInfoCard(gps: gps, l10n: l10n),
            const SizedBox(height: 12),

            // Speed info card
            _SpeedInfoCard(gps: gps, l10n: l10n),
            const SizedBox(height: 12),

            // Accuracy info card
            _AccuracyInfoCard(gps: gps, l10n: l10n),
            const SizedBox(height: 16),

            // Auto push card
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
                        await gps.setAutoPushEnabled(value);
                      },
                      contentPadding: EdgeInsets.zero,
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

class _PositionInfoCard extends StatelessWidget {
  final GpsProvider gps;
  final AppLocalizations l10n;

  const _PositionInfoCard({required this.gps, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final point = gps.lastGpsPoint;
    final na = l10n.notAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.positionInfo, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.latitude,
              value: point != null ? '${point.latitude.toStringAsFixed(6)}°' : na,
            ),
            _InfoRow(
              label: l10n.longitude,
              value: point != null ? '${point.longitude.toStringAsFixed(6)}°' : na,
            ),
            _InfoRow(
              label: l10n.altitude,
              value: point != null ? '${point.altitude.toStringAsFixed(1)} m' : na,
            ),
            _InfoRow(
              label: l10n.time,
              value: point != null ? FormatUtils.formatTime(point.timestamp) : na,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedInfoCard extends StatelessWidget {
  final GpsProvider gps;
  final AppLocalizations l10n;

  const _SpeedInfoCard({required this.gps, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final point = gps.lastGpsPoint;
    final na = l10n.notAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.speedInfo, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.speed,
              value: point != null && point.hasSpeed
                  ? '${point.speed.toStringAsFixed(2)} m/s'
                  : na,
            ),
            _InfoRow(
              label: l10n.speedNorth,
              value: point != null && point.hasSpeed
                  ? '${point.speedNorth.toStringAsFixed(2)} m/s'
                  : na,
            ),
            _InfoRow(
              label: l10n.speedEast,
              value: point != null && point.hasSpeed
                  ? '${point.speedEast.toStringAsFixed(2)} m/s'
                  : na,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccuracyInfoCard extends StatelessWidget {
  final GpsProvider gps;
  final AppLocalizations l10n;

  const _AccuracyInfoCard({required this.gps, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final point = gps.lastGpsPoint;
    final na = l10n.notAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accuracyInfo, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _InfoRow(
              label: l10n.horizontalAccuracy,
              value: point != null ? '±${point.accuracy.toStringAsFixed(1)} m' : na,
            ),
            _InfoRow(
              label: l10n.verticalAccuracy,
              value: point?.verticalAccuracy != null
                  ? '±${point!.verticalAccuracy!.toStringAsFixed(1)} m'
                  : na,
            ),
            _InfoRow(
              label: l10n.speedAccuracy,
              value: point?.speedAccuracy != null
                  ? '±${point!.speedAccuracy!.toStringAsFixed(2)} m/s'
                  : na,
            ),
            _InfoRow(
              label: l10n.satelliteCount,
              value: na,
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