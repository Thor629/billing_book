# Unauthorized Error Fix - Complete Guide

## Problem
User was getting "Unauthorized" error when loading organizations after login.

## Root Causes Identified
1. **Token Expiration**: Backend tokens expire after 120 minutes
2. **No Token Expiry Tracking**: Frontend wasn't tracking when tokens expire
3. **Poor Error Handling**: No clear feedback when authentication fails
4. **No Automatic Logout**: Expired tokens weren't being cleared

## Solutions Implemented

### 1. Enhanced Token Management
- **Added token expiry tracking**: Now saves `expires_at` from backend
- **Added expiry validation**: Checks if token is expired before API calls
- **Auto-logout on expiry**: Automatically clears expired tokens

### 2. Better Logging & Debugging
- **ApiClient logging**: Shows when token is found/missing
- **AuthService logging**: Tracks login, logout, and token operations
- **OrganizationProvider logging**: Shows loading progress and errors

### 3. Improved Error Handling
- **Detects authentication errors**: Identifies "Unauthorized" errors
- **User-friendly messages**: Shows "Session expired. Please login again."
- **Logout button**: Provides easy way to re-login when session expires

### 4. Enhanced UI Feedback
- **OrganizationSelectorDialog**: Shows clear error messages
- **Login button**: Appears when authentication fails
- **Retry option**: For non-auth errors

## Files Modified

### Frontend
1. **flutter_app/lib/services/api_client.dart**
   - Added debug logging for token operations
   - Enhanced response logging

2. **flutter_app/lib/services/auth_service.dart**
   - Added token expiry tracking
   - Added expiry validation in `isAuthenticated()`
   - Enhanced logging for all operations

3. **flutter_app/lib/core/constants/app_config.dart**
   - Added `tokenExpiryKey` constant

4. **flutter_app/lib/providers/organization_provider.dart**
   - Better error detection for auth failures
   - User-friendly error messages

5. **flutter_app/lib/screens/organization/organization_selector_dialog.dart**
   - Shows "Session Expired" UI for auth errors
   - Provides "Login Again" button
   - Better error display

6. **flutter_app/lib/main.dart**
   - Clears organization data on logout

## How to Test

### Test 1: Fresh Login
1. Stop the Flutter app
2. Clear app data (or uninstall/reinstall)
3. Start the app
4. Login with valid credentials
5. **Expected**: Should load organizations successfully

### Test 2: Check Logs
1. After login, check console for:
   ```
   AuthService: Token saved successfully
   AuthService: Token expiry saved: [timestamp]
   ApiClient: Token found and added to headers
   OrganizationProvider: Loaded X organizations
   ```

### Test 3: Token Expiration (Manual)
1. Login successfully
2. Wait 120 minutes (or modify backend to use shorter expiry for testing)
3. Try to access any feature
4. **Expected**: Should show "Session expired" message with "Login Again" button

### Test 4: Invalid Token
1. Login successfully
2. Manually corrupt the token in storage (for testing)
3. Restart app
4. **Expected**: Should show "Unauthorized" error with logout option

## Debugging Steps

If you still see "Unauthorized" error:

### Step 1: Check Backend is Running
```bash
cd backend
php artisan serve
```
Should see: `Server started on http://localhost:8000`

### Step 2: Check Database Connection
```bash
cd backend
php artisan migrate:status
```
Should show all migrations as "Ran"

### Step 3: Test Login API Directly
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```
Should return token and user data

### Step 4: Test Organizations API
```bash
# Replace YOUR_TOKEN with actual token from login
curl -X GET http://localhost:8000/api/organizations \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```
Should return organizations list

### Step 5: Check Flutter Console Logs
Look for these messages:
- ✅ `AuthService: Token saved successfully`
- ✅ `ApiClient: Token found and added to headers`
- ❌ `ApiClient: WARNING - No token found in storage!`
- ❌ `401 Unauthorized - Token may be expired or invalid`

## Common Issues & Solutions

### Issue 1: "No token found in storage"
**Cause**: Token not saved during login
**Solution**: 
- Check if login API returns token
- Verify `AuthService.login()` saves token
- Check console for "Token saved successfully"

### Issue 2: "Token expired"
**Cause**: Token older than 120 minutes
**Solution**: 
- Click "Login Again" button
- Re-enter credentials
- Token will be refreshed

### Issue 3: Backend returns 401
**Cause**: Invalid or malformed token
**Solution**:
- Logout and login again
- Check backend logs: `tail -f backend/storage/logs/laravel.log`
- Verify Sanctum is configured correctly

### Issue 4: Organizations not loading
**Cause**: User has no organizations
**Solution**:
- Create organization screen should appear
- Create your first organization
- Will be auto-selected

## Backend Token Configuration

Current settings in `AuthController.php`:
```php
// Token expires in 120 minutes (2 hours)
$token = $user->createToken('auth-token', ['*'], now()->addMinutes(120))->plainTextToken;
```

To change expiry time:
```php
// 24 hours
now()->addMinutes(1440)

// 7 days
now()->addDays(7)

// 30 days
now()->addDays(30)
```

## Next Steps

1. **Test the fix**: Follow testing steps above
2. **Monitor logs**: Check console for any errors
3. **Report results**: Let me know if issue persists
4. **Optional**: Implement token refresh mechanism for seamless experience

## Token Refresh (Future Enhancement)

For better UX, consider implementing automatic token refresh:
- Refresh token 5 minutes before expiry
- Silent refresh in background
- No interruption to user workflow

This is not implemented yet but can be added if needed.
