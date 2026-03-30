import '../utils/dji_r_crc.dart';

/// DJI R SDK protocol frame encoder/parser.
/// SOF: 0xAA, uses CRC-16 (header) and CRC-32 (full frame).
class DjiRProtocol {
  static const int sof = 0xAA;

  static int _sequenceNumber = 0;

  static int _nextSeq() {
    _sequenceNumber = (_sequenceNumber + 1) & 0xFFFF;
    return _sequenceNumber;
  }

  /// Build a DJI R SDK command frame.
  /// Frame structure:
  /// | SOF | Ver/Len | CmdType | ENC | RES | SEQ | CRC-16 | DATA | CRC-32 |
  /// | 1B  | 2B      | 1B      | 1B  | 3B  | 2B  | 2B     | nB   | 4B     |
  static List<int> buildFrame({
    required int cmdSet,
    required int cmdId,
    required List<int> payload,
    int cmdType = 0x01, // 1: needs ack but optional
    int encType = 0x00, // 0: no encryption
  }) {
    final seq = _nextSeq();
    final dataLen = 2 + payload.length; // CmdSet + CmdID + Payload
    final frameLen = 12 + dataLen + 4; // Header(12) + Data + CRC32(4)

    final frame = <int>[];

    // SOF
    frame.add(sof);

    // Ver/Len (2B, LSB first, version=0)
    frame.add(frameLen & 0xFF);
    frame.add((frameLen >> 8) & 0x03);

    // CmdType
    frame.add(cmdType);

    // ENC (encryption type + padding length)
    frame.add(encType);

    // RES (3B reserved)
    frame.addAll([0x00, 0x00, 0x00]);

    // SEQ (2B, LSB first)
    frame.add(seq & 0xFF);
    frame.add((seq >> 8) & 0xFF);

    // CRC-16 (header, first 10 bytes)
    final headerCrc = DjiRcrc.crc16(frame.sublist(0, 10));
    frame.add(headerCrc & 0xFF);
    frame.add((headerCrc >> 8) & 0xFF);

    // DATA: CmdSet + CmdID + Payload
    frame.add(cmdSet);
    frame.add(cmdId);
    frame.addAll(payload);

    // CRC-32 (whole frame except last 4 bytes)
    final fullCrc = DjiRcrc.crc32(frame);
    frame.addAll([
      fullCrc & 0xFF,
      (fullCrc >> 8) & 0xFF,
      (fullCrc >> 16) & 0xFF,
      (fullCrc >> 24) & 0xFF,
    ]);

    return frame;
  }

  /// Parse a DJI R SDK frame, returns parsed data or null if invalid.
  static DjiRFrame? parse(List<int> data) {
    if (data.isEmpty) return null;
    if (data[0] != sof) return null;

    // Get frame length
    if (data.length < 3) return null;
    final frameLen = data[1] | ((data[2] & 0x03) << 8);
    if (data.length < frameLen) return null;

    // Verify CRC-16 (first 10 bytes)
    if (frameLen < 12) return null;
    final headerCrc = DjiRcrc.crc16(data.sublist(0, 10));
    final expectedHeaderCrc = data[10] | (data[11] << 8);
    if (headerCrc != expectedHeaderCrc) return null;

    // Verify CRC-32
    final fullCrc = DjiRcrc.crc32(data.sublist(0, frameLen - 4));
    final expectedFullCrc = data[frameLen - 4] |
        (data[frameLen - 3] << 8) |
        (data[frameLen - 2] << 16) |
        (data[frameLen - 1] << 24);
    if (fullCrc != expectedFullCrc) return null;

    // Extract fields
    final cmdType = data[3];
    final encType = data[4];
    final seq = data[8] | (data[9] << 8);
    final cmdSet = data[12];
    final cmdId = data[13];
    final payload = data.sublist(14, frameLen - 4);
    final isAck = (cmdType & 0x20) != 0;

    return DjiRFrame(
      frameLen: frameLen,
      cmdType: cmdType,
      encType: encType,
      seq: seq,
      cmdSet: cmdSet,
      cmdId: cmdId,
      payload: payload,
      isAck: isAck,
    );
  }

  /// Build connection request (CmdSet=0x00, CmdID=0x19).
  static List<int> buildConnectionRequest({
    required int deviceId,
    required List<int> macAddr,
    int verifyMode = 0,
    int verifyData = 0,
  }) {
    // Payload structure:
    // | device_id(4) | mac_len(1) | mac(16) | fw_ver(4) | conidx(1) | verify_mode(1) | verify_data(2) | reserved(4) |
    final payload = <int>[];

    // device_id (4B, LSB first)
    payload.addAll([
      deviceId & 0xFF,
      (deviceId >> 8) & 0xFF,
      (deviceId >> 16) & 0xFF,
      (deviceId >> 24) & 0xFF,
    ]);

    // mac_addr_len (1B)
    payload.add(macAddr.length.clamp(0, 16));

    // mac_addr (16B, padded with zeros)
    payload.addAll(macAddr);
    for (int i = macAddr.length; i < 16; i++) {
      payload.add(0x00);
    }

    // fw_version (4B, fill with 0)
    payload.addAll([0x00, 0x00, 0x00, 0x00]);

    // conidx (1B, reserved)
    payload.add(0x00);

    // verify_mode (1B): 0=no verify, 1=need verify, 2=verify result
    payload.add(verifyMode);

    // verify_data (2B, LSB first)
    payload.addAll([verifyData & 0xFF, (verifyData >> 8) & 0xFF]);

    // reserved (4B)
    payload.addAll([0x00, 0x00, 0x00, 0x00]);

    return buildFrame(cmdSet: 0x00, cmdId: 0x19, payload: payload);
  }

  /// Build connection ack (CmdSet=0x00, CmdID=0x19, isAck=true).
  static List<int> buildConnectionAck({
    required int deviceId,
    int cameraIndex = 0,
  }) {
    final payload = <int>[];

    // device_id (4B)
    payload.addAll([
      deviceId & 0xFF,
      (deviceId >> 8) & 0xFF,
      (deviceId >> 16) & 0xFF,
      (deviceId >> 24) & 0xFF,
    ]);

    // camera_index (1B)
    payload.add(cameraIndex);

    // reserved (5B)
    payload.addAll([0x00, 0x00, 0x00, 0x00, 0x00]);

    return buildFrame(
      cmdSet: 0x00,
      cmdId: 0x19,
      payload: payload,
      cmdType: 0x21, // 0x01 | 0x20 (ack flag)
    );
  }

  /// Build power mode command (CmdSet=0x00, CmdID=0x1A).
  /// powerMode: 0=normal, 3=sleep
  static List<int> buildPowerModeCommand({required int powerMode}) {
    return buildFrame(cmdSet: 0x00, cmdId: 0x1A, payload: [powerMode]);
  }

  /// Build sleep command (powerMode=3).
  static List<int> buildSleepCommand() {
    return buildPowerModeCommand(powerMode: 3);
  }

  /// Build wake command (powerMode=0).
  static List<int> buildWakeCommand() {
    return buildPowerModeCommand(powerMode: 0);
  }

  /// Build request camera status command (CmdSet=0x1D, CmdID=0x01).
  /// This requests the camera to send a status push (0x1D02).
  static List<int> buildRequestStatus() {
    return buildFrame(cmdSet: 0x1D, cmdId: 0x01, payload: []);
  }

  /// Build status subscription command (CmdSet=0x1D, CmdID=0x05).
  /// Subscribes to periodic status push (0x1D02).
  /// pushMode: 3=periodic + on-change
  /// pushFreq: 20=2Hz
  static List<int> buildStatusSubscription({
    int pushMode = 3,
    int pushFreq = 20,
  }) {
    return buildFrame(
      cmdSet: 0x1D,
      cmdId: 0x05,
      payload: [pushMode, pushFreq, 0x00, 0x00, 0x00, 0x00],
    );
  }

  /// Generate wake-up advertisement data for a sleeping camera.
  /// Format: [10, 0xFF, 'W','K','P', MAC(reversed)]
  static List<int> buildWakeUpAdvData(String macAddress) {
    final macBytes = macAddress
        .split(':')
        .map((s) => int.parse(s, radix: 16))
        .toList();

    return [
      10,
      0xFF,
      0x57, // 'W'
      0x4B, // 'K'
      0x50, // 'P'
      ...macBytes.reversed,
    ];
  }

  /// Parse connection request/response payload.
  static ConnectionPayload? parseConnectionPayload(List<int> payload) {
    if (payload.length < 33) return null;

    final deviceId = payload[0] | (payload[1] << 8) | (payload[2] << 16) | (payload[3] << 24);
    final macLen = payload[4];
    final macAddr = payload.sublist(5, 5 + macLen.clamp(0, 16));
    final verifyMode = payload[26];
    final verifyData = payload[27] | (payload[28] << 8);
    final cameraIndex = payload.length > 33 ? payload[33] : 0;

    return ConnectionPayload(
      deviceId: deviceId,
      macAddr: macAddr,
      verifyMode: verifyMode,
      verifyData: verifyData,
      cameraIndex: cameraIndex,
    );
  }
}

/// DJI R SDK parsed frame.
class DjiRFrame {
  final int frameLen;
  final int cmdType;
  final int encType;
  final int seq;
  final int cmdSet;
  final int cmdId;
  final List<int> payload;
  final bool isAck;

  DjiRFrame({
    required this.frameLen,
    required this.cmdType,
    required this.encType,
    required this.seq,
    required this.cmdSet,
    required this.cmdId,
    required this.payload,
    required this.isAck,
  });

  @override
  String toString() {
    return 'DjiRFrame(cmdSet=$cmdSet, cmdId=$cmdId, seq=$seq, isAck=$isAck, payloadLen=${payload.length})';
  }
}

/// Connection request/response payload.
class ConnectionPayload {
  final int deviceId;
  final List<int> macAddr;
  final int verifyMode;
  final int verifyData;
  final int cameraIndex;

  ConnectionPayload({
    required this.deviceId,
    required this.macAddr,
    required this.verifyMode,
    required this.verifyData,
    required this.cameraIndex,
  });
}