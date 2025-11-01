# UtilityHub360 Flutter App - Setup Guide

## ✅ Project Structure

The Flutter project has been successfully created with the following structure:

```
flutterApp/
├── lib/
│   ├── config/              # App configuration & routing
│   │   ├── app_config.dart
│   │   └── router.dart
│   ├── models/              # Data models
│   │   ├── user.dart
│   │   ├── transaction.dart
│   │   ├── bill.dart
│   │   ├── loan.dart
│   │   ├── income_source.dart
│   │   ├── bank_account.dart
│   │   ├── notification.dart
│   │   └── dashboard_summary.dart
│   ├── services/            # Business logic & API
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── data_service.dart
│   │   └── storage_service.dart
│   ├── screens/             # UI Screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── transactions/
│   │   │   └── transactions_screen.dart
│   │   ├── bills/
│   │   │   ├── bills_screen.dart
│   │   │   └── bill_detail_screen.dart
│   │   ├── loans/
│   │   │   ├── loans_screen.dart
│   │   │   └── loan_detail_screen.dart
│   │   ├── income/
│   │   │   └── income_sources_screen.dart
│   │   ├── bank/
│   │   │   └── bank_accounts_screen.dart
│   │   ├── notifications/
│   │   │   └── notifications_screen.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── profile_screen.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── bottom_nav_bar.dart
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   └── summary_card.dart
│   ├── utils/               # Utilities
│   │   ├── theme.dart
│   │   ├── formatters.dart
│   │   └── navigation_helper.dart
│   └── main.dart           # App entry point
├── android/                 # Android configuration
├── ios/                       # iOS configuration
└── pubspec.yaml            # Dependencies

```

## 🚀 Getting Started

### 1. Install Dependencies

```bash
# Navigate to project directory
cd flutterApp

# Install Flutter packages
flutter pub get
```

### 2. Configure API Base URL

Update the API base URL in `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'https://api.utilityhub360.com/api';
```

### 3. iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

### 4. Run the App

```bash
# Check available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>
```

## 📱 Features Implemented

### ✅ Authentication
- Login with email/password
- User registration
- Token-based authentication
- Auto token refresh
- Secure token storage

### ✅ Dashboard
- Total balance summary
- Monthly income display
- Pending bills count & amount
- Upcoming payments (next 7 days)
- Recent transactions (last 5)
- Pull-to-refresh

### ✅ Transactions
- List all transactions
- Filter by type (Income/Expense)
- Search functionality
- Pull-to-refresh & pagination

### ✅ Bills & Utilities
- View all bills
- Filter by status (Pending/Paid/Overdue)
- Mark bills as paid
- Bill detail view
- Overdue bills highlighting

### ✅ Loan Management
- View active loans
- Loan details
- Make loan payments
- Payment history

### ✅ Income Sources
- List income sources
- Total monthly income summary
- Add/Edit/Delete income sources

### ✅ Bank Accounts
- List all bank accounts
- Total balance summary
- Account details

### ✅ Notifications
- View all notifications
- Filter by status (Read/Unread)
- Mark as read
- Pull-to-refresh

### ✅ Settings & Profile
- User profile management
- Biometric authentication toggle
- App settings
- Logout functionality

## 🎨 Design Features

- Material Design 3
- Clean, modern UI
- Card-based layouts
- Color-coded status indicators
- Responsive design
- Loading states
- Error handling
- Empty states

## 🔒 Security Features

- Secure token storage (flutter_secure_storage)
- Token auto-refresh
- Biometric authentication support
- Encrypted local storage
- SSL/TLS communication

## 📦 Dependencies Used

### Core
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `flutter_secure_storage` - Secure storage
- `shared_preferences` - Local storage
- `hive` - Local database

### UI
- `google_fonts` - Typography
- `pull_to_refresh` - Refresh functionality
- `shimmer` - Loading animations

### Utilities
- `intl` - Date/number formatting
- `equatable` - Value equality
- `local_auth` - Biometric authentication

## 🔧 Configuration

### Android
- Minimum SDK: 21
- Target SDK: 34
- Package: `com.utilityhub360.app`

### iOS
- Minimum iOS: 12.0
- Bundle ID: `com.utilityhub360.app`

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📱 Build for Production

### Android
```bash
# APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for device
flutter build ios --release

# Then open Xcode to archive and distribute
open ios/Runner.xcworkspace
```

See `DEPLOYMENT.md` for detailed deployment instructions.

## 🐛 Troubleshooting

### Common Issues

1. **Build fails**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **iOS Pod issues**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   ```

3. **Android Gradle issues**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```

## 📝 Next Steps

1. **Update API Base URL** in `lib/config/app_config.dart`
2. **Test authentication** with your backend
3. **Customize app icon and splash screen**
4. **Configure push notifications** (if needed)
5. **Add app signing keys** for production builds
6. **Test on physical devices** (iOS & Android)
7. **Submit to app stores**

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://material.io/design)

---

**Note**: Make sure your backend API is running and accessible at the configured base URL before testing the app.

