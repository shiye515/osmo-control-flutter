## Context

The GPS push feature is designed to send location data from the mobile app to DJI camera devices via BLE. The specification in `openspec/specs/gps-push/spec.md` correctly defines the DJI R SDK protocol format (CmdSet=0x00, CmdID=0x17) with 48-byte payload. However, the current implementation in `protocol_codec.dart` uses an incorrect DUML protocol format (cmdSet=0x04, cmdId=0x08) with a truncated 20-byte payload.

**Current Implementation Issues:**
1. Uses `ProtocolCodec.buildCommand` (DUML) instead of `DjiRProtocol.buildFrame` (DJI R SDK)
2. Wrong command identifiers: cmdSet=0x04, cmdId=0x08 instead of cmdSet=0x00, cmdId=0x17
3. Payload missing: year_month_day, hour_minute_second, speed components, accuracy estimates, satellite_number
4. Payload order wrong: latitude first instead of longitude first per spec

## Goals / Non-Goals

**Goals:**
- Implement correct DJI R SDK protocol frame format for GPS push
- Build 48-byte payload with all required fields per spec
- Pass full GpsPointModel data from GPS provider to session provider
- Use proper CRC-16 and CRC-32 as defined in DjiRProtocol

**Non-Goals:**
- Changing the GPS data model (already correct)
- Changing the GPS push frequency options (already correct)
- Changing UI display logic (already correct)

## Decisions

### Decision 1: Use DjiRProtocol for GPS push

**Choice:** Add `buildPushGps` method to `DjiRProtocol` class

**Rationale:**
- DjiRProtocol already handles DJI R SDK frame format with CRC-16/CRC-32
- ProtocolCodec uses DUML format which is wrong for GPS push
- GPS push is a control-plane command (CmdSet=0x00) like sleep/wake, not camera command

**Alternatives considered:**
- Modify ProtocolCodec: Would require adding R SDK format, creating confusion
- Create new class: Unnecessary, DjiRProtocol already exists

### Decision 2: Float encoding for speed components

**Choice:** Use IEEE 754 single-precision float format (4 bytes)

**Rationale:**
- DJI R SDK spec defines speed_to_north/east/downward as `float` type
- Dart uses double (64-bit), need to convert to float32 for BLE transmission
- Byte order: LSB first (little-endian) per DJI R SDK convention

### Decision 3: Timestamp encoding (UTC+8)

**Choice:** Encode timestamp with (hour+8) offset per spec

**Rationale:**
- DJI spec explicitly requires `(hour+8)*10000 + minute*100 + second`
- This converts UTC to China Standard Time (UTC+8)
- Mobile GPS timestamp is typically UTC from geolocator

## Risks / Trade-offs

**Speed conversion precision loss**
- Converting double (m/s) to float (cm/s) may lose precision
- Mitigation: Multiply by 100 first, then convert to float32

**Missing satellite count**
- geolocator package doesn't provide satellite count
- Mitigation: Use placeholder value (e.g., 10) until platform-specific implementation

**Negative speed handling**
- geolocator returns speed=-1 when unavailable
- Mitigation: Send 0 for speed components when speed < 0

## Migration Plan

1. Add `buildPushGps` to `DjiRProtocol`
2. Update `SessionProvider.pushGps` to use new method with full parameters
3. Update `GpsProvider._pushGpsData` to pass all GpsPointModel fields
4. Remove or mark deprecated the old `ProtocolCodec.buildPushGps`
5. Test with actual camera device to verify push works