## 1. Provider Changes

- [x] 1.1 Remove `_pushIntervalSec` field and related SharedPreferences logic from `GpsProvider`
- [x] 1.2 Remove `_autoPushTimer` and timer-related methods (`_startAutoPush`, `_stopAutoPush`)
- [x] 1.3 Add real-time push logic in `_locationSubscription` listen callback
- [x] 1.4 Keep `autoPushEnabled` toggle but remove frequency selection

## 2. UI Changes

- [x] 2.1 Remove frequency selection dropdown/segmented control from `gps_settings_view.dart`
- [x] 2.2 Keep auto-push toggle switch

## 3. Cleanup

- [ ] 3.1 Remove unused localization strings for frequency options (optional)
- [ ] 3.2 Test real-time GPS push with camera device