# UtilityHub360 Mobile App

A cross-platform Flutter application for financial management with support for Android and iOS.

## Features

- 🏠 Dashboard - Quick overview of financial status
- 💰 Transactions - Track all financial transactions
- 📄 Bills & Utilities - Manage and pay bills
- 💳 Loan Management - Track loans and payments
- 💵 Income Sources - Manage income streams
- 🏦 Bank Accounts - Track account balances
- 🔔 Notifications - Important alerts
- ⚙️ Settings - Profile and preferences

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for platform-specific builds)
- Android SDK / Xcode Command Line Tools

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (for models with json_serializable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```

## Build for Production

### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Configuration

### API Base URL
Update the API base URL in `lib/config/app_config.dart`:
```dart
static const String baseUrl = 'https://api.utilityhub360.com/api';
```

## Project Structure

```
lib/
├── config/          # App configuration
├── models/          # Data models
├── services/        # API services
├── providers/          # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── utils/           # Utilities and helpers
└── main.dart        # App entry point
```

## Security Features

- Secure token storage using flutter_secure_storage
- Biometric authentication support
- SSL pinning (configure in network layer)
- Encrypted local data storage

## License

Copyright © 2024 UtilityHub360

