import '../utils/byte_utils.dart';
import '../config/app_constants.dart';

/// DUML (DJI Unified Message Language) protocol codec.
/// Encodes/decodes command frames for Osmo device communication.
class ProtocolCodec {
  static int _sequenceNumber = 0;

  static int _nextSeq() {
    _sequenceNumber = (_sequenceNumber + 1) & 0xFFFF;
    return _sequenceNumber;
  }

  /// Build a DUML command frame.
  static List<int> buildCommand({
    required int cmdSet,
    required int cmdId,
    required List<int> payload,
    int senderId = 0x02,
    int receiverId = 0x1B,
  }) {
    final seq = _nextSeq();
    final payloadLength = payload.length;
    final frameLength = 14 + payloadLength; // SOF(1) + len(2) + hdr_crc8(1) + snd/rcv(2) + seq(2) + flags/enc(2) + cmdset/id(2) + payload + crc16(2)

    final frame = List<int>.filled(frameLength, 0);
    frame[0] = AppConstants.dumlHeaderByte; // SOF
    frame[1] = frameLength & 0xFF;
    frame[2] = (frameLength >> 8) & 0x03 | (AppConstants.dumlVersion << 2);
    frame[3] = ByteUtils.crc8(frame.sublist(0, 3));
    frame[4] = senderId;
    frame[5] = receiverId;
    frame[6] = seq & 0xFF;
    frame[7] = (seq >> 8) & 0xFF;
    frame[8] = 0x40; // flags: needsAck
    frame[9] = 0x00; // encryption: none
    frame[10] = cmdSet;
    frame[11] = cmdId;

    for (int i = 0; i < payloadLength; i++) {
      frame[12 + i] = payload[i];
    }

    final crc16 = ByteUtils.crc16(frame.sublist(0, frameLength - 2));
    frame[frameLength - 2] = crc16 & 0xFF;
    frame[frameLength - 1] = (crc16 >> 8) & 0xFF;

    return frame;
  }

  /// Camera recording toggle command.
  static List<int> buildToggleRecording() {
    return buildCommand(cmdSet: 0x01, cmdId: 0x4B, payload: [0x01]);
  }

  /// Camera snapshot command.
  static List<int> buildTakeSnapshot() {
    return buildCommand(cmdSet: 0x01, cmdId: 0x37, payload: [0x01]);
  }

  /// Switch camera mode command.
  static List<int> buildSwitchMode(int mode) {
    return buildCommand(cmdSet: 0x01, cmdId: 0x34, payload: [mode]);
  }

  /// Sleep command.
  static List<int> buildSleep() {
    return buildCommand(cmdSet: 0x00, cmdId: 0x1A, payload: [0x01]);
  }

  /// Wake command.
  static List<int> buildWake() {
    return buildCommand(cmdSet: 0x00, cmdId: 0x1A, payload: [0x00]);
  }

  /// Reboot camera command.
  static List<int> buildReboot() {
    return buildCommand(cmdSet: 0x00, cmdId: 0x1B, payload: []);
  }

  /// Request version command.
  static List<int> buildRequestVersion() {
    return buildCommand(cmdSet: 0x00, cmdId: 0x01, payload: []);
  }

  /// GPS push command.
  static List<int> buildPushGps({
    required double latitude,
    required double longitude,
    required double altitude,
  }) {
    final payload = List<int>.filled(20, 0);
    final latInt = (latitude * 1e7).round();
    final lngInt = (longitude * 1e7).round();
    final altInt = (altitude * 1000).round();

    payload[0] = latInt & 0xFF;
    payload[1] = (latInt >> 8) & 0xFF;
    payload[2] = (latInt >> 16) & 0xFF;
    payload[3] = (latInt >> 24) & 0xFF;
    payload[4] = lngInt & 0xFF;
    payload[5] = (lngInt >> 8) & 0xFF;
    payload[6] = (lngInt >> 16) & 0xFF;
    payload[7] = (lngInt >> 24) & 0xFF;
    payload[8] = altInt & 0xFF;
    payload[9] = (altInt >> 8) & 0xFF;
    payload[10] = (altInt >> 16) & 0xFF;
    payload[11] = (altInt >> 24) & 0xFF;

    return buildCommand(cmdSet: 0x04, cmdId: 0x08, payload: payload);
  }

  /// Parse a response frame, returning the payload bytes if valid.
  static List<int>? parseResponse(List<int> data) {
    if (data.length < 13) return null;
    if (data[0] != AppConstants.dumlHeaderByte) return null;
    final length = data[1] | ((data[2] & 0x03) << 8);
    if (data.length < length) return null;
    // Return payload (bytes 12..length-3)
    if (length <= 14) return [];
    return data.sublist(12, length - 2);
  }
}
