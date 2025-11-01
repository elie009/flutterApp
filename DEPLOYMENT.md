# Deployment Guide for UtilityHub360 Mobile App

This guide covers deployment for both Android and iOS platforms.

## Prerequisites

### For Android
- Android Studio (latest version)
- Android SDK (API level 21 or higher)
- Java JDK 8 or higher
- Flutter SDK installed and configured

### For iOS
- macOS (required for iOS development)
- Xcode (latest version)
- CocoaPods (`sudo gem install cocoapods`)
- Flutter SDK installed and configured

## Initial Setup

1. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

2. **For iOS - Install CocoaPods**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Android Deployment

### Build Configuration

1. **Update App ID and Package Name**
   - Open `android/app/build.gradle`
   - Update `applicationId` to your package name (currently: `com.utilityhub360.app`)

2. **Update App Name and Icon**
   - App name is set in `android/app/src/main/AndroidManifest.xml`
   - Replace launcher icons in `android/app/src/main/res/mipmap-*/`

3. **Signing Configuration**
   - Create a keystore file:
     ```bash
     keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
     ```
   - Create `android/key.properties`:
     ```properties
     storePassword=<password>
     keyPassword=<password>
     keyAlias=upload
     storeFile=<path-to-keystore>
     ```
   - Update `android/app/build.gradle` to use signing config

### Build Commands

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

Output files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## iOS Deployment

### Build Configuration

1. **Update Bundle Identifier**
   - Open Xcode: `open ios/Runner.xcworkspace`
   - Select Runner target → General
   - Update Bundle Identifier (currently: `com.utilityhub360.app`)

2. **Update App Display Name**
   - In Xcode: Runner → Info.plist
   - Update `CFBundleDisplayName` (currently: `UtilityHub360`)

3. **Configure Signing & Capabilities**
   - In Xcode: Runner → Signing & Capabilities
   - Select your Team
   - Enable required capabilities:
     - Background Modes (for notifications)
     - Keychain Sharing (for secure storage)

4. **Update Version Numbers**
   - In Xcode: Runner → General
   - Update Version and Build numbers

### Build Commands

**Debug:**
```bash
flutter build ios --debug
```

**Release (for TestFlight/App Store):**
```bash
flutter build ios --release
```

**Archive in Xcode:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Product → Archive
3. Distribute App when archive completes

## App Store / Play Store Submission

### Android (Google Play Store)

1. **Prepare Assets**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (at least 2, various screen sizes)
   - Privacy policy URL

2. **Create Release on Play Console**
   - Upload the `.aab` file
   - Fill in store listing
   - Complete content rating
   - Submit for review

### iOS (App Store)

1. **Prepare Assets**
   - App icon (1024x1024 PNG)
   - Screenshots (various device sizes)
   - Privacy policy URL
   - App Store description

2. **Submit via Xcode**
   - Archive the app in Xcode
   - Select "Distribute App"
   - Choose "App Store Connect"
   - Upload and submit for review

## Configuration Updates

### API Base URL
Update the API base URL in `lib/config/app_config.dart`:
```dart
static const String baseUrl = 'https://api.utilityhub360.com/api';
```

### Environment-Specific Configs
For different environments (dev, staging, production), consider using:
- Environment variables
- Build flavors
- Configuration files

## Testing Before Release

### Android
```bash
# Install on connected device
flutter install

# Run tests
flutter test

# Run on specific device
flutter run -d <device-id>
```

### iOS
```bash
# Install on connected device
flutter install

# Run on iOS simulator
flutter run -d ios

# Run on physical device (requires Xcode)
flutter run -d <device-id>
```

## Troubleshooting

### Android Issues
- **Gradle sync fails**: Update Gradle version in `android/build.gradle`
- **Build fails**: Clean and rebuild: `flutter clean && flutter pub get`
- **Signing errors**: Verify `key.properties` file exists and is correct

### iOS Issues
- **Pod install fails**: Update CocoaPods: `sudo gem install cocoapods`
- **Signing errors**: Check Team and Bundle Identifier in Xcode
- **Build fails**: Clean build folder: `flutter clean && cd ios && pod install`

## Continuous Integration

Consider setting up CI/CD pipelines for automated builds:
- GitHub Actions
- Codemagic
- Bitrise
- Fastlane

## Additional Resources

- [Flutter Deployment Documentation](https://flutter.dev/docs/deployment)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)

