# Authentication Flow in UtilityHub360 Flutter App

## 🔐 Overview

The app automatically checks user authentication and redirects to the login page if the user has no valid session.

## ✅ How It Works

### 1. **Automatic Route Protection**

The app uses `GoRouter` with redirect logic that automatically:
- ✅ Checks if user is authenticated
- ✅ Redirects to `/landing` (login page) if not authenticated
- ✅ Redirects to `/` (home/dashboard) if already authenticated and trying to access login pages
- ✅ Allows access to public routes (login, register, forgot password, etc.)

**Location**: `lib/config/router.dart`

### 2. **Session Management**

**AuthService** handles all authentication logic:
- Stores user data and tokens securely
- Restores session on app startup
- Checks authentication status
- Handles login/logout/token refresh

**Location**: `lib/services/auth_service.dart`

### 3. **Protected Routes**

All routes except these are protected and require authentication:
- `/login`
- `/register`
- `/auth-selection`
- `/landing`
- `/forgot-password`
- `/security-pin`
- `/pin-login`
- `/pin-setup`
- `/launch`
- `/onboarding`

## 🚀 Usage Examples

### Method 1: Automatic (Recommended)

The router automatically handles authentication. No additional code needed!

```dart
// User tries to access dashboard
context.go('/');

// If not authenticated, automatically redirected to:
// /landing (login page)
```

### Method 2: Manual Check in Widget

Use `AuthService` to manually check authentication:

```dart
import '../services/auth_service.dart';

class MyScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await AuthService.checkAuthAndRedirect(context);
    if (!isAuthenticated) {
      // User was redirected to login
      print('User not authenticated');
    }
  }
}
```

### Method 3: Using AuthWrapper Widget

Wrap any widget with `AuthWrapper` for automatic auth checking:

```dart
import '../widgets/auth_wrapper.dart';

class MyProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text('Protected Content')),
        body: Center(child: Text('Only authenticated users see this')),
      ),
      onUnauthenticated: () {
        print('User was not authenticated');
      },
    );
  }
}
```

## 🔑 Key Methods

### Check if User is Authenticated

```dart
bool isLoggedIn = AuthService.isAuthenticated();
```

### Get Current User

```dart
User? currentUser = AuthService.getCurrentUser();
if (currentUser != null) {
  print('Welcome ${currentUser.name}');
}
```

### Login

```dart
final result = await AuthService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success']) {
  // Login successful, router will auto-redirect to home
  context.go('/');
} else {
  // Show error message
  print(result['message']);
}
```

### Logout

```dart
await AuthService.logout();
context.go('/landing'); // Redirect to login
```

### Verify Token is Valid

```dart
bool isValid = await AuthService.verifyTokenValid();
if (!isValid) {
  // Token expired or invalid
  await AuthService.logout();
  context.go('/landing');
}
```

## 🛠️ How It's Initialized

In `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize API service
  ApiService().init();
  
  // Initialize auth service and restore user session
  await AuthService.init(); // ← Restores session if exists
  
  runApp(UtilityHub360App());
}
```

## 🔍 Debug Auth Flow

Added debug prints to see auth flow in console:

```
🔐 Auth Check: isLoggedIn=false, location=/dashboard
🔒 Redirecting to /landing - User not authenticated
```

```
🔐 Auth Check: isLoggedIn=true, location=/login
✅ Redirecting to / - User already authenticated
```

## 📱 App Flow

```
App Start
    ↓
AuthService.init() → Restore session from storage
    ↓
Is session valid?
    ↓              ↓
   YES            NO
    ↓              ↓
Go to /     Go to /landing
(Dashboard)    (Login)
```

## 🔐 Session Storage

- **Token**: Stored securely using `flutter_secure_storage`
- **User Data**: Stored in Hive (local database)
- **Auto-restore**: On app restart, session is automatically restored if valid

## ✨ Features

✅ Automatic session restoration on app restart
✅ Automatic redirect to login if not authenticated
✅ Automatic redirect to home if already logged in
✅ Token refresh on expiration
✅ Secure token storage
✅ Debug logging for troubleshooting

## 🚨 Important Notes

1. **Session expires**: If the user closes the app and reopens, session is restored automatically
2. **Token refresh**: Tokens are automatically refreshed when expired
3. **Manual logout**: User can logout from settings, which clears all stored data
4. **No session**: If no valid session exists, user is redirected to login

## 🎯 Testing

### Test 1: Protected Route Access
1. Open app without being logged in
2. Try to navigate to `/dashboard` or any protected route
3. Should automatically redirect to `/landing`

### Test 2: Session Restoration
1. Login to the app
2. Close the app completely
3. Reopen the app
4. Should remain logged in and go to dashboard

### Test 3: Logout
1. Login to the app
2. Go to settings → Logout
3. Should redirect to login page
4. Trying to access protected routes should redirect back to login
