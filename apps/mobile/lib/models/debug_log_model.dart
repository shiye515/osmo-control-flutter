enum LogDirection { sent, received, system }

class DebugLogEntry {
  final DateTime timestamp;
  final LogDirection direction;
  final String message;
  final List<int>? rawBytes;

  const DebugLogEntry({
    required this.timestamp,
    required this.direction,
    required this.message,
    this.rawBytes,
  });

  String get hexBytes =>
      rawBytes?.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ') ?? '';
}
