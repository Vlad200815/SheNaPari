# Shenapari — Flutter Mobile App

This is the user-facing Flutter mobile app (iOS + Android) for the Shenapari B2B SaaS platform.

## Architecture

Clean Architecture with feature-first vertical slices + BLoC (MVVM base classes).

```
lib/src/
  app/            — config, constants, localization, navigation (go_router routes)
  core/           — base classes (BasePage/BaseViewModel/BaseView), DI, network, session, widgets
  features/       — vertical slices by business capability:
    auth/         — phone OTP login
    menu/         — product catalog browsing
    cart/         — shopping cart
    ordering/     — order placement, details, rating
    profile/      — user profile, registration
    info/         — onboarding, legal, notifications, support
    root/         — root shell, tab navigation
```

Each feature follows: `data/` (models, repos impl, remote sources) → `domain/` (entities, repo interfaces, use cases) → `presentation/` (pages, view models, widgets) → `di/` (feature-level DI registration).

## Key conventions

- Every screen: `BasePage<VM, State, Event, Action>` — typed ViewModel lifecycle
- State management: `BaseViewModel` extends BLoC; one ViewModel per screen
- DI: `get_it` — each feature has its own locator (e.g. `AuthLocator`), wired in `Di.setup()` in `core/di/di.dart`
- Navigation: `go_router` — routes in `lib/src/app/navigation.dart`
- Networking: Dio + Retrofit + 3-interceptor stack (DeviceHeaders → Auth → Retry)
- Tokens: `flutter_secure_storage` (Keystore/Keychain)
- Code gen: `build_runner` (freezed, json_serializable, retrofit_generator, flutter_gen)
- Localization: `easy_localization` (`assets/translations/en.json` / `uk.json`)

## TDD

Tests first (Red → Green → Refactor). Use `bloc_test` for ViewModel tests, `mocktail` for mocks.
