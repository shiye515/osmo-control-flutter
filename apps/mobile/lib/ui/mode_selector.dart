import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../utils/format_utils.dart';

class ModeSelector extends StatelessWidget {
  final int currentMode;
  final void Function(int mode) onModeSelected;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  static const List<int> _modes = [
    AppConstants.cameraModeVideo,
    AppConstants.cameraModePhoto,
    AppConstants.cameraModeSlow,
    AppConstants.cameraModeTimelapse,
  ];

  static const List<IconData> _icons = [
    Icons.videocam,
    Icons.camera_alt,
    Icons.slow_motion_video,
    Icons.timelapse,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('拍摄模式', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_modes.length, (i) {
                final mode = _modes[i];
                final isSelected = mode == currentMode;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
                    child: InkWell(
                      onTap: () => onModeSelected(mode),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  width: 2)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _icons[i],
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FormatUtils.cameraModeName(mode),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
