import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/gps_provider.dart';
import '../../utils/format_utils.dart';

class GpsSettingsView extends StatelessWidget {
  const GpsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final gps = context.watch<GpsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('GPS 设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前位置', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  if (gps.lastGpsPoint != null) ...[
                    _InfoRow(
                        label: '纬度',
                        value: gps.lastGpsPoint!.latitude.toStringAsFixed(6)),
                    _InfoRow(
                        label: '经度',
                        value: gps.lastGpsPoint!.longitude.toStringAsFixed(6)),
                    _InfoRow(
                        label: '海拔',
                        value:
                            '${gps.lastGpsPoint!.altitude.toStringAsFixed(1)} m'),
                    _InfoRow(
                        label: '精度',
                        value:
                            '${gps.lastGpsPoint!.accuracy.toStringAsFixed(1)} m'),
                    _InfoRow(
                        label: '时间',
                        value: FormatUtils.formatTime(
                            gps.lastGpsPoint!.timestamp)),
                  ] else
                    const Text('暂无位置数据',
                        style: TextStyle(color: Colors.grey)),
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
                  Text('自动推送', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('启用 GPS 自动推送'),
                    subtitle: const Text('自动将手机GPS位置推送到设备'),
                    value: gps.autoPushEnabled,
                    onChanged: gps.setAutoPushEnabled,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '推送频率: ${FormatUtils.formatFrequency(gps.frequencyHz)}',
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
            label: const Text('立即推送当前位置'),
          ),
        ],
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
