## 1. Protocol Implementation

- [x] 1.1 Add `buildPushGps` method to `DjiRProtocol` class in `lib/api/dji_r_protocol.dart`
- [x] 1.2 Implement 48-byte payload encoding: year_month_day, hour_minute_second, coordinates, height
- [x] 1.3 Implement speed components encoding: speed_to_north, speed_to_east, speed_to_downward (float32, cm/s)
- [x] 1.4 Implement accuracy estimates encoding: vertical, horizontal, speed accuracy (uint32)
- [x] 1.5 Add float32 conversion utility for speed components (IEEE 754 little-endian)

## 2. Provider Updates

- [x] 2.1 Update `SessionProvider.pushGps` to accept full `GpsPointModel` instead of just coordinates
- [x] 2.2 Update `GpsProvider._pushGpsData` to pass all fields from `lastGpsPoint` to `pushGps`
- [x] 2.3 Handle unavailable speed data (speed=-1) by sending 0 for speed components
- [x] 2.4 Use placeholder satellite count (10) since geolocator doesn't provide this

## 3. Cleanup

- [x] 3.1 Mark deprecated or remove `ProtocolCodec.buildPushGps` method
- [ ] 3.2 Test GPS push with BLE packet logging to verify correct frame format