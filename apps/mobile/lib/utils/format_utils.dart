import 'package:intl/intl.dart';

class FormatUtils {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  static String formatGimbalAngle(double angle) =>
      '${angle.toStringAsFixed(1)}°';

  static String formatRssi(int rssi) => '$rssi dBm';

  static String formatBattery(int? percent) =>
      percent != null ? '$percent%' : '--';

  static String formatFrequency(double hz) =>
      hz >= 1.0 ? '${hz.toStringAsFixed(1)} Hz' : '${(hz * 1000).round()} ms';

  static String cameraModeName(int mode) {
    switch (mode) {
      case 0:
        return '录像';
      case 1:
        return '拍照';
      case 2:
        return '慢动作';
      case 3:
        return '延时';
      default:
        return '未知';
    }
  }
}
