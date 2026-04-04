## 1. Dependencies and Configuration

- [x] 1.1 Add `flutter_background_service` dependency to pubspec.yaml
- [x] 1.2 Add `flutter_local_notifications` dependency for Android foreground notification
- [x] 1.3 Add `permission_handler` dependency for unified permission management
- [x] 1.4 Run `flutter pub get` to install dependencies
- [x] 1.5 Update AndroidManifest.xml with foreground service type declaration
- [x] 1.6 Verify iOS Info.plist background mode configuration

## 2. Permission Management Service

- [x] 2.1 Create `lib/services/permission_service.dart` for unified permission management
- [x] 2.2 Implement method to check all required permissions status
- [x] 2.3 Implement method to request specific permission
- [x] 2.4 Implement method to open system settings for permanently denied
- [x] 2.5 Define permission list with names and purpose descriptions

## 3. Permission Management UI

- [x] 3.1 Create `lib/ui/permission_list_tile.dart` widget for permission entry
- [x] 3.2 Implement permission status indicator (granted/denied/permanently denied)
- [x] 3.3 Add "Request Permission" button for denied permissions
- [x] 3.4 Add "Open Settings" button for permanently denied permissions
- [x] 3.5 Add permission section to settings view
- [x] 3.6 Implement permission status refresh on app resume

## 4. Background Service Implementation

- [x] 4.1 Create `lib/services/background_service.dart` for foreground service management
- [x] 4.2 Implement service initialization with notification configuration
- [x] 4.3 Implement service start method (called on app launch)
- [x] 4.4 Implement location acquisition within background service (Android)
- [x] 4.5 Implement BLE connection maintenance in background service
- [x] 4.6 Handle service lifecycle events (start, stop on app termination)

## 5. Location Service Updates

- [x] 5.1 Add `allowBackgroundLocationUpdates` configuration for iOS
- [x] 5.2 Add `pausesLocationUpdatesAutomatically` handling for iOS
- [x] 5.3 Implement automatic `always` permission request on app launch
- [x] 5.4 Add background mode configuration in LocationService
- [x] 5.5 Integrate with PermissionService for status checks

## 6. GPS Provider Updates

- [x] 6.1 Remove manual toggle, auto-enable background mode on GPS enable
- [x] 6.2 Start foreground service automatically when GPS is enabled
- [x] 6.3 Integrate with BackgroundService for Android
- [x] 6.4 Handle permission denial with user guidance

## 7. App Initialization

- [x] 7.1 Initialize background service in main.dart
- [x] 7.2 Initialize PermissionService and register with providers
- [x] 7.3 Add localized strings for permission names and descriptions (en, zh, ja)
- [x] 7.4 Add localized strings for permission status labels

## 8. Testing and Verification

- [ ] 8.1 Test permission list display on settings page
- [ ] 8.2 Test permission request button behavior
- [ ] 8.3 Test "Open Settings" button for permanently denied
- [ ] 8.4 Test permission status refresh on app resume
- [ ] 8.5 Test Android foreground service with screen locked
- [ ] 8.6 Test iOS background location with screen locked
- [ ] 8.7 Test BLE data push while in background
- [ ] 8.8 Test automatic permission request flows on both platforms