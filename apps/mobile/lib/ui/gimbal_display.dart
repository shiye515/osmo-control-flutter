import 'package:flutter/material.dart';
import '../utils/format_utils.dart';

class GimbalDisplay extends StatelessWidget {
  final double pitch;
  final double roll;
  final double yaw;
  const GimbalDisplay(
      {super.key,
      required this.pitch,
      required this.roll,
      required this.yaw});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('云台角度', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AngleDisplay(label: 'Pitch', value: pitch),
                _AngleDisplay(label: 'Roll', value: roll),
                _AngleDisplay(label: 'Yaw', value: yaw),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AngleDisplay extends StatelessWidget {
  final String label;
  final double value;
  const _AngleDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          FormatUtils.formatGimbalAngle(value),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
