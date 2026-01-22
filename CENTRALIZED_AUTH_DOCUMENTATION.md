# Centralized Authentication & Session Management

This document explains the centralized authentication system implemented in the UtilityHub360 Flutter app.

## Overview

The app now has a comprehensive, centralized authentication system that:
- ✅ Automatically checks if user sessions are valid across all screens
- ✅ Redirects to login when session expires
- ✅ Monitors session validity periodically (every 30 seconds)
- ✅ Checks authentication when app resumes from background
- ✅ Provides consistent auth checks across the entire app

## Architecture

### 1. **SessionManager** (`lib/services/session_manager.dart`)

The `SessionManager` is a singleton service that:
- Runs periodic session validity checks (every 30 seconds)
- Verifies tokens are still present in storage
- Triggers logout when session expires
- Notifies listeners about session expiration

**Key Features:**
```dart
// Initialize in main.dart
SessionManager.init();

// Manually check session validity
bool isValid = await SessionManager.checkSessionValidity();

// Add callback for session expiration
SessionManager.addSessionExpiredCallback(() {
  print('Session expired!');
});
```

### 2. **AuthGuard Widget** (`lib/widgets/auth_guard.dart`)

The `AuthGuard` is a wrapper widget that:
- Wraps protected screens to ensure user is authenticated
- Checks authentication when screen is first loaded
- Re-checks when app comes back to foreground
- Shows loading indicator while checking
- Automatically redirects to `/landing` if not authenticated
- Shows a snackbar when session expires

**Usage:**
```dart
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const AuthGuard(
    child: DashboardScreen(),
  ),
),
```

### 3. **Router Integration** (`lib/config/router.dart`)

All protected routes are now wrapped with `AuthGuard`:
- Dashboard
- Transactions
- Bills & Loans
- Bank Accounts
- Settings & Profile
- All other protected screens

Public routes (login, register, landing) are NOT wrapped with `AuthGuard`.

## How It Works

### App Startup
1. App initializes services in `main.dart`
2. `AuthService.init()` restores user session from storage
3. `SessionManager.init()` starts periodic session monitoring
4. Router checks authentication and redirects accordingly

### Navigation to Protected Screen
1. User navigates to a protected route (e.g., `/dashboard`)
2. `AuthGuard` widget wraps the screen
3. `AuthGuard` checks if user is authenticated
4. If authenticated: Shows the screen
5. If not authenticated: Redirects to `/landing`

### Session Monitoring (Automatic)
1. `SessionManager` runs a timer every 30 seconds
2. Checks if token exists in storage
3. Verifies user is still authenticated
4. If session expired: Triggers logout and notifies listeners
5. `AuthGuard` receives notification and redirects to login

### App Resume from Background
1. User brings app back to foreground
2. `AuthGuard` (via `WidgetsBindingObserver`) detects app resume
3. Re-checks authentication immediately
4. Redirects to login if session expired while app was in background

### Manual Logout
1. User clicks logout in settings
2. `AuthService.logout()` clears tokens and user data
3. Router redirect logic sends user to `/landing`
4. `SessionManager` stops checking (no active session)

## Configuration

### Adjust Session Check Interval

In `lib/services/session_manager.dart`:
```dart
// Change from 30 seconds to your preferred interval
static const Duration _checkInterval = Duration(seconds: 30);
```

### Enable Backend Token Verification

Uncomment in `session_manager.dart`:
```dart
// Verify token with backend
final isValid = await AuthService.verifyTokenValid();
if (!isValid) {
  await _handleSessionExpired();
}
```

### Disable Periodic Checks for Specific Screens

```dart
GoRoute(
  path: '/some-route',
  builder: (context, state) => const AuthGuard(
    checkSessionPeriodically: false, // Disable for this screen
    child: SomeScreen(),
  ),
),
```

## Benefits

1. **Security**: Automatic session expiration detection prevents unauthorized access
2. **User Experience**: Seamless redirects with loading indicators
3. **Consistency**: Same auth logic across all screens
4. **Maintainability**: Centralized auth checks - easy to update
5. **Reliability**: Multiple layers of auth checking (router + guard + periodic)

## Testing the System

### Test Session Expiration
1. Login to the app
2. Manually clear tokens using:
   ```dart
   await StorageService.clearTokens();
   ```
3. Wait 30 seconds (or trigger a navigation)
4. App should automatically redirect to login

### Test App Resume
1. Login to the app
2. Put app in background (press home button)
3. Clear tokens or wait for token expiration
4. Resume the app
5. `AuthGuard` should immediately check and redirect to login

### Test Manual Logout
1. Login to the app
2. Go to Settings
3. Click Logout
4. Confirm logout
5. Should redirect to login screen immediately

## Debug Logs

The system includes extensive debug logging:
- `📱 SessionManager:` - Session monitoring logs
- `🔐 AuthGuard:` - Screen-level auth checks
- `🔀 ROUTER:` - Router-level redirects
- `🔓 AuthService:` - Logout and login operations

Enable these in your console to track authentication flow.

## Future Enhancements

Potential improvements:
- [ ] Add biometric re-authentication
- [ ] Implement sliding session expiration (extend on activity)
- [ ] Add "Session Expiring Soon" warning dialog
- [ ] Support offline mode with cached credentials
- [ ] Add rate limiting for auth checks

## Troubleshooting

### Issue: Infinite redirect loop
**Solution**: Ensure public routes are not wrapped with `AuthGuard`

### Issue: Session checks too frequent
**Solution**: Increase `_checkInterval` in `SessionManager`

### Issue: User not redirected on logout
**Solution**: Check that `router.dart` redirect logic includes logout cases

### Issue: "Session expired" shows multiple times
**Solution**: Ensure only one `AuthGuard` wraps each screen (not nested)

## Files Modified

- ✅ `lib/services/session_manager.dart` (NEW)
- ✅ `lib/widgets/auth_guard.dart` (NEW)
- ✅ `lib/main.dart` (Updated)
- ✅ `lib/config/router.dart` (Updated - all protected routes)
- ✅ `lib/services/auth_service.dart` (Enhanced with logout flag)
- ✅ `lib/services/api_service.dart` (Fixed token refresh loop)
- ✅ `lib/screens/settings/settings_screen.dart` (Improved logout)

## Summary

You now have a production-ready, centralized authentication system that automatically monitors and enforces valid sessions across your entire Flutter app. All protected screens are guarded, and sessions are checked both on navigation and periodically in the background.
