import 'dart:typed_data';

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

  /// Convert double to IEEE 754 float32 bytes (little-endian).
  static List<int> _float32ToBytes(double value) {
    final buffer = ByteData(4);
    buffer.setFloat32(0, value, Endian.little);
    return buffer.buffer.asUint8List().toList();
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

  /// Build switch camera mode command (CmdSet=0x1D, CmdID=0x04).
  /// Requires device_id from camera connection response.
  /// mode: camera mode value (0x00=slow motion, 0x01=video, 0x02=timelapse, 0x05=photo, etc.)
  static List<int> buildSwitchModeCommand(int mode, {required int deviceId}) {
    final payload = <int>[];
    // device_id (4B, LSB first)
    payload.addAll([
      deviceId & 0xFF,
      (deviceId >> 8) & 0xFF,
      (deviceId >> 16) & 0xFF,
      (deviceId >> 24) & 0xFF,
    ]);
    // mode (1B)
    payload.add(mode);
    // reserved (4B)
    payload.addAll([0x00, 0x00, 0x00, 0x00]);
    return buildFrame(cmdSet: 0x1D, cmdId: 0x04, payload: payload);
  }

  /// Build toggle recording command (CmdSet=0x1D, CmdID=0x03).
  /// recordCtrl: 0=start recording, 1=stop recording
  static List<int> buildToggleRecordingCommand({required int deviceId, int recordCtrl = 0}) {
    final payload = <int>[];
    // device_id (4B, LSB first)
    payload.addAll([
      deviceId & 0xFF,
      (deviceId >> 8) & 0xFF,
      (deviceId >> 16) & 0xFF,
      (deviceId >> 24) & 0xFF,
    ]);
    // record_ctrl (1B): 0=start, 1=stop
    payload.add(recordCtrl);
    // reserved (4B)
    payload.addAll([0x00, 0x00, 0x00, 0x00]);
    return buildFrame(cmdSet: 0x1D, cmdId: 0x03, payload: payload);
  }

  /// Build take snapshot command (CmdSet=0x1D, CmdID=0x03, start recording).
  /// For photo mode, use same recording command to trigger snapshot.
  static List<int> buildTakeSnapshotCommand({required int deviceId}) {
    return buildToggleRecordingCommand(deviceId: deviceId, recordCtrl: 0);
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

  /// Build GPS data push command (CmdSet=0x00, CmdID=0x17).
  /// Payload is 48 bytes with date/time, position, speed, accuracy, and satellite count.
  static List<int> buildPushGps({
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double altitude,
    required double speedNorth,
    required double speedEast,
    required double speedDownward,
    required int verticalAccuracy,
    required int horizontalAccuracy,
    required int speedAccuracy,
    required int satelliteCount,
  }) {
    final payload = <int>[];

    // year_month_day (int32_t): year*10000 + month*100 + day
    final yearMonthDay = timestamp.year * 10000 + timestamp.month * 100 + timestamp.day;
    payload.addAll([
      yearMonthDay & 0xFF,
      (yearMonthDay >> 8) & 0xFF,
      (yearMonthDay >> 16) & 0xFF,
      (yearMonthDay >> 24) & 0xFF,
    ]);

    // hour_minute_second (int32_t): (hour+8)*10000 + minute*100 + second
    // Note: Spec requires UTC+8 timezone offset
    final hourMinuteSecond = ((timestamp.hour + 8) % 24) * 10000 + timestamp.minute * 100 + timestamp.second;
    payload.addAll([
      hourMinuteSecond & 0xFF,
      (hourMinuteSecond >> 8) & 0xFF,
      (hourMinuteSecond >> 16) & 0xFF,
      (hourMinuteSecond >> 24) & 0xFF,
    ]);

    // gps_longitude (int32_t): actual * 10^7
    final lngInt = (longitude * 1e7).round();
    payload.addAll([
      lngInt & 0xFF,
      (lngInt >> 8) & 0xFF,
      (lngInt >> 16) & 0xFF,
      (lngInt >> 24) & 0xFF,
    ]);

    // gps_latitude (int32_t): actual * 10^7
    final latInt = (latitude * 1e7).round();
    payload.addAll([
      latInt & 0xFF,
      (latInt >> 8) & 0xFF,
      (latInt >> 16) & 0xFF,
      (latInt >> 24) & 0xFF,
    ]);

    // height (int32_t): mm
    final heightInt = (altitude * 1000).round();
    payload.addAll([
      heightInt & 0xFF,
      (heightInt >> 8) & 0xFF,
      (heightInt >> 16) & 0xFF,
      (heightInt >> 24) & 0xFF,
    ]);

    // speed_to_north (float): cm/s
    payload.addAll(_float32ToBytes(speedNorth * 100)); // m/s -> cm/s

    // speed_to_east (float): cm/s
    payload.addAll(_float32ToBytes(speedEast * 100)); // m/s -> cm/s

    // speed_to_downward (float): cm/s
    payload.addAll(_float32ToBytes(speedDownward * 100)); // m/s -> cm/s

    // vertical_accuracy_estimate (uint32_t): mm
    payload.addAll([
      verticalAccuracy & 0xFF,
      (verticalAccuracy >> 8) & 0xFF,
      (verticalAccuracy >> 16) & 0xFF,
      (verticalAccuracy >> 24) & 0xFF,
    ]);

    // horizontal_accuracy_estimate (uint32_t): mm
    payload.addAll([
      horizontalAccuracy & 0xFF,
      (horizontalAccuracy >> 8) & 0xFF,
      (horizontalAccuracy >> 16) & 0xFF,
      (horizontalAccuracy >> 24) & 0xFF,
    ]);

    // speed_accuracy_estimate (uint32_t): cm/s
    payload.addAll([
      speedAccuracy & 0xFF,
      (speedAccuracy >> 8) & 0xFF,
      (speedAccuracy >> 16) & 0xFF,
      (speedAccuracy >> 24) & 0xFF,
    ]);

    // satellite_number (uint32_t)
    payload.addAll([
      satelliteCount & 0xFF,
      (satelliteCount >> 8) & 0xFF,
      (satelliteCount >> 16) & 0xFF,
      (satelliteCount >> 24) & 0xFF,
    ]);

    // Use cmdType=0x01 (ack optional) per spec
    return buildFrame(cmdSet: 0x00, cmdId: 0x17, payload: payload, cmdType: 0x01);
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