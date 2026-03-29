import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class StatusChip extends StatelessWidget {
  final bool connected;
  const StatusChip({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: connected
            ? AppTheme.connectedColor.withOpacity(0.1)
            : AppTheme.disconnectedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connected
              ? AppTheme.connectedColor
              : AppTheme.disconnectedColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: connected
                  ? AppTheme.connectedColor
                  : AppTheme.disconnectedColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            connected ? '已连接' : '未连接',
            style: TextStyle(
              fontSize: 12,
              color: connected
                  ? AppTheme.connectedColor
                  : AppTheme.disconnectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
