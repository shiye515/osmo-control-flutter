## Why

GPS data push to DJI camera devices is currently non-functional due to using the wrong protocol format. The existing implementation uses DUML protocol (cmdSet=0x04, cmdId=0x08) but DJI R SDK requires a completely different frame format (cmdSet=0x00, cmdId=0x17) with a 48-byte payload containing date/time, speed components, accuracy estimates, and satellite count.

## What Changes

- Fix GPS push command to use DJI R SDK protocol frame format instead of DUML
- Build correct 48-byte payload structure:
  - year_month_day (int32): year*10000 + month*100 + day
  - hour_minute_second (int32): (hour+8)*10000 + minute*100 + second (UTC+8 timezone)
  - gps_longitude/gps_latitude (int32): actual * 10^7
  - height (int32): altitude in mm
  - speed_to_north/speed_to_east/speed_to_downward (float): cm/s
  - vertical/horizontal/speed accuracy estimates (uint32): mm or cm/s
  - satellite_number (uint32)
- Update session_provider.dart to pass full GPS data (speed components, accuracy, timestamp)
- Use DjiRProtocol.buildFrame for proper frame construction

## Capabilities

### New Capabilities

(None - this is a bug fix, not a new feature)

### Modified Capabilities

- `gps-push`: Fix GPS push payload structure to match DJI R SDK protocol specification (CmdSet=0x00, CmdID=0x17)

## Impact

- `lib/api/protocol_codec.dart`: Replace buildPushGps or remove it
- `lib/api/dji_r_protocol.dart`: Add buildPushGps method using DJI R SDK frame format
- `lib/providers/session_provider.dart`: Update pushGps to pass full GpsPointModel data
- `lib/providers/gps_provider.dart`: Update _pushGpsData to pass all required fields
- GPS push will now correctly send speed, accuracy, and timestamp data to camera