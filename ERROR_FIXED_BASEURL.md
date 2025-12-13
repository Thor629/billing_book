# Error Fixed - AppConfig.baseUrl

## Problem
The `purchase_order_service.dart` was using `AppConfig.baseUrl` which doesn't exist.

## Error Messages
```
The getter 'baseUrl' isn't defined for the type 'AppConfig'.
```

This error appeared 5 times in the file.

## Root Cause
The correct property name in `AppConfig` is `apiBaseUrl`, not `baseUrl`.

## Solution Applied
Changed all occurrences from:
```dart
AppConfig.baseUrl
```

To:
```dart
AppConfig.apiBaseUrl
```

## Files Fixed
- `flutter_app/lib/services/purchase_order_service.dart` (5 occurrences)

## Verification
✅ No diagnostics found - all errors resolved

## Next Steps
1. **Hot Restart** Flutter app (press `R`)
2. **Test** Purchase Orders feature
3. Should work without errors now

---

**Status**: ✅ **FIXED**
