## Implementation Fix Only

This change is a pure implementation bug fix. The requirements in `openspec/specs/gps-push/spec.md` are already correct and define the expected behavior:

- GPS push command uses CmdSet=0x00, CmdID=0x17
- 48-byte payload with all required fields (year_month_day, hour_minute_second, coordinates, height, speed components, accuracy estimates, satellite_number)

The current implementation incorrectly uses:
- DUML protocol (cmdSet=0x04, cmdId=0x08) instead of DJI R SDK protocol
- Truncated 20-byte payload instead of 48-byte

No requirement changes needed - only implementation changes to match existing specification.