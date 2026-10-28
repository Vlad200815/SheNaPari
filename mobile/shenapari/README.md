### ⚡ Quick Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (models, API clients, assets)
dart run build_runner build --delete-conflicting-outputs

# 3. Generate localization
flutter pub run easy_localization:generate -S assets/translations
flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart

# 4. Generate app icon
flutter pub run flutter_launcher_icons
# iOS only
cd ios && pod install
```

### 🔨 Full Clean Build

```bash
flutter clean 
dart run build_runner build --delete-conflicting-outputs 
flutter pub run easy_localization:generate -S assets/translations 
flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
```

---

## 📦 Build

### 🤖 Android

```bash
# Release APK
flutter build apk --release

# Release App Bundle (Play Store)
flutter build appbundle --release
```

### 🍎 iOS

```bash
flutter pub get && cd ios && pod install
# Then open ios/Runner.xcworkspace in Xcode and archive
```

---

## 🧪 Code Quality

```bash
# Static analysis
flutter analyze --fatal-infos --fatal-warnings

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

---
