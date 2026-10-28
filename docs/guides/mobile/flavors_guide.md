# Oversee flavors guide

How flavors, environments and tenants work in Oversee, with the terminal commands for each combination. For project setup and a quick start, see the [README](README.md).

## 1. The logic behind multi-tenancy

### One codebase, one app per business

Each business gets its own installable app: its own name, icon, and app ID on the phone and in the stores. All of them share the same code (features, networking, design system). A student downloads "SheNaPari", not "Oversee". Users never switch tenants at runtime.

### Two independent axes

| Axis | Question it answers | Mechanism | Layer |
|---|---|---|---|
| Tenant (business) | Which app is this? | Flavor + entrypoint | Native + Dart |
| Environment | Stage or prod backend? | `--dart-define=API_ENV` | Dart only |

Stage and prod are not flavors. They share the same app ID, so installing one replaces the other on a device. If side-by-side stage and prod installs are ever needed, an environment flavor dimension can be added later.

### Three switches in every run command

| Switch | Run config field | What it controls | Layer |
|---|---|---|---|
| `-t lib/main_shenapari.dart` | Dart entrypoint | Which tenant config the Dart code starts with | Dart |
| `--flavor shenapari` | Build flavor | Native identity: app ID, name, icon | Native |
| `--dart-define=API_ENV=stage` | Additional run args | Compile-time environment constant | Dart |

They are independent. Use matching names (`main_shenapari.dart` with `--flavor shenapari`) so a run never mixes tenants.

### What a flavor changes (native layer)

A flavor is a native concept. Flutter passes the name to Gradle and Xcode, and if no variant with that exact name exists, the build fails.

| | Android | iOS |
|---|---|---|
| Mechanism | `productFlavors` in Gradle | Build configurations + scheme in Xcode |
| App ID | `applicationId` | Bundle ID |
| App name | `resValue("string", "app_name", ...)` used by the manifest label | Display name in `Info.plist` via xcconfig |
| Icon | `android/app/src/<flavor>/res/` | Icon set `AppIcon-<flavor>` in `Assets.xcassets` |

App IDs:

- `com.simplesolutions.shenapari`
- `com.simplesolutions.other`

The project namespace is `com.simplesolutions.oversee` (the code package). It is not the app identity, and it stays the same for every flavor. Published app IDs cannot be changed later.

### What Dart configures (runtime layer)

```
main_<tenant>.dart
  -> bootstrap(tenantConfig)
       -> FlavorConfig.initialize(config)   // stores the tenant
       -> DI, theme, router read it
```

- `TenantConfig` is an immutable object: tenant id, app name, stage and prod base URLs, brand color, and later feature flags such as `hasDelivery`.
- `TenantConfig.baseUrl` picks the stage or prod URL from the compile-time `isStage` constant.
- `FlavorConfig` is a static holder that `bootstrap` fills once before `runApp()`. It is a bridge for bootstrap, DI setup and theme building. Once GetIt is in place, the config should be registered there and `FlavorConfig` removed.
- `Config.apiEnv`, `Config.stage`, `Config.prod` are the constants behind `String.fromEnvironment`. The default is `prod`, so a forgotten flag lands on the safe backend.

`String.fromEnvironment` is resolved at compile time. It must be used as `const`, the value is baked into the binary, and changing it needs a full rebuild (hot reload does not pick it up). It is not secret storage.

### Rules that keep it maintainable

- Features (`features/ordering`, `features/menu`, ...) are tenant-agnostic. They never contain `if (tenant == 'shenapari')`. Differences between businesses are data in `TenantConfig` (colors, URLs, feature flags).
- Widgets read colors from `Theme.of(context)`, never hardcoded hex values.
- Anything that costs money or calls a paid third party (SMS, payments) sits behind an interface. The stage/prod implementation is chosen at compile time through `API_ENV` and DI, never with a runtime toggle. This keeps mock code out of prod builds. The backend must also verify its own environment.
- Runtime debug menus are fine for convenience only (screen shortcuts, test data), never for switching real services.
- Stage builds show a `STAGE` banner (built with `Banner`, so it also appears in release builds).

## 2. Run commands

Run everything from `mobile/oversee`.

```bash
flutter pub get
flutter devices              # list emulators/simulators and their ids
```

```bash
# SheNaPari, stage backend
flutter run -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=stage

# SheNaPari, prod backend
flutter run -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=prod

# Other business, stage / prod
flutter run -t lib/main_other.dart --flavor other --dart-define=API_ENV=stage
flutter run -t lib/main_other.dart --flavor other --dart-define=API_ENV=prod

# Pick a specific device
flutter run -d <device-id> -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=stage
```

Android Studio run configurations (`shenapari (stage)`, `shenapari (prod)`, `other (stage)`, `other (prod)`):

| Field | Value |
|---|---|
| Dart entrypoint | `lib/main_<tenant>.dart` |
| Additional run args | `--dart-define=API_ENV=stage` or `prod` |
| Build flavor | `<tenant>` |
| Environment variables | leave empty |

## 3. Release builds

```bash
# Android app bundle (Play Store)
flutter build appbundle -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=prod

# Android APK (manual testing)
flutter build apk --release -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=prod

# iOS (requires signing configured in Xcode)
flutter build ipa -t lib/main_shenapari.dart --flavor shenapari --dart-define=API_ENV=prod
```

Known gaps before the first store upload:

- Android release builds are still signed with the debug key. A real keystore is needed, and it must never be committed to git.
- iOS release builds need an Apple Developer account and signing set up. Simulators only run debug mode.

## 4. Adding a new business

1. Create `lib/tenants/tenant_<name>.dart` with a `TenantConfig`.
2. Create `lib/main_<name>.dart` calling `bootstrap(tenant<Name>)`.
3. Add the flavor to `flavorizr.yaml` (name, app name, `applicationId`, `bundleId`).
4. Commit everything, then run `dart run flutter_flavorizr`. This needs the Ruby gem `xcodeproj` (`sudo gem install xcodeproj`). Keep the `instructions:` list limited to the entries used so far, otherwise the tool also generates its own main and app files:
   ```yaml
   instructions:
     - android:androidManifest
     - android:flavorizrGradle
     - android:buildGradle
     - ios:podfile
     - ios:xcconfig
     - ios:buildTargets
     - ios:schema
     - ios:plist
   ```
   Review `git diff` afterwards.
5. Create the iOS icon set the xcconfig expects:
   ```bash
   cd ios/Runner/Assets.xcassets
   cp -R AppIcon.appiconset AppIcon-<name>.appiconset
   ```
6. Add the assets folder `assets/tenants/<name>/` and declare it in `pubspec.yaml`.
7. Add run configurations for stage and prod.
8. Later: Android icons in `android/app/src/<name>/res/`, and Firebase config files per flavor.

## 5. Verify iOS flavors

```bash
xcodebuild -list -project ios/Runner.xcodeproj
```

Build Configurations should list `Debug-<flavor>`, `Release-<flavor>` and `Profile-<flavor>` for each flavor, and Schemes should list every flavor name.

## 6. Troubleshooting

| Error | Cause and fix |
|---|---|
| "Product Flavor ... contains custom resource values, but the feature is disabled" | Add `buildFeatures { resValues = true }` inside `android { }` in `app/build.gradle.kts` |
| "The Gradle project does not define a flavor" | The `--flavor` name does not match a Gradle product flavor |
| "None of the input catalogs contained ... AppIcon-<flavor>" (iOS) | Create the icon set: copy `AppIcon.appiconset` to `AppIcon-<flavor>.appiconset` |
| "Entrypoint isn't within the current project" | Open `mobile/oversee` as the project root |
| "Dart SDK is not configured" | Set Dart and Flutter SDK paths in Settings (the Dart SDK is at `<flutter>/bin/cache/dart-sdk`) |
| Red errors in `AndroidManifest.xml`, app still runs | IDE false positives. Open the `android` folder in its own window to clear them |
| Env shows `prod` when `stage` was expected | The `--dart-define` key does not match `Config.apiEnv`, or the flag was missing. Rebuild after changing it |
| Wrong app name under the icon | Manifest label must be `@string/app_name` |
