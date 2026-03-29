import 'package:flutter/foundation.dart';

import '../models/debug_log_model.dart';
import '../utils/byte_utils.dart';
import 'session_provider.dart';

class DebugProvider extends ChangeNotifier {
  SessionProvider? _sessionProvider;

  List<DebugLogEntry> get logs => _sessionProvider?.logs ?? [];

  void updateSession(SessionProvider session) {
    _sessionProvider = session;
    notifyListeners();
  }

  Future<void> sendRawHex(String hexInput) async {
    final bytes = ByteUtils.fromHex(hexInput);
    if (bytes.isEmpty) return;
    await _sessionProvider?.sendRawCommand(bytes);
    notifyListeners();
  }

  void clearLogs() {
    _sessionProvider?.clearLogs();
    notifyListeners();
  }
}
