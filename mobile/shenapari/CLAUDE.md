# Shenapari — Flutter Mobile App

This is the user-facing Flutter mobile app (iOS + Android) for the Shenapari B2B SaaS platform.

## Project knowledge base

Full project knowledge lives in `../../brain/`. Start at `../../brain/START-HERE.md` for any project question.

- `../../brain/PRINCIPLES.md` — engineering rules (TDD mandatory, modular boundaries, SOLID/DRY/YAGNI/KISS)
- `../../brain/PLANNING.md` — how we plan, write tasks, Definition of Done
- `../../brain/wiki/mobile/mobile-app.md` — this app's status, screens, known issues
- `../../brain/wiki/mobile/flutter-architecture.md` — Flutter architecture patterns and conventions

## Architecture

Clean Architecture with feature-first vertical slices + BLoC (MVVM base classes).

```
lib/src/
  core/           — base classes (BasePage/BaseViewModel/BaseView), DI, network, widgets
  features/       — vertical slices by business capability:
    auth/         — phone OTP login (data/domain/presentation/di)
    menu/         — product catalog browsing
    cart/         — shopping cart
    ordering/     — order placement, details, rating
    profile/      — user profile, registration
    info/         — onboarding, legal, notifications, support
    app/          — root shell, tab navigation
```

Each feature follows: `data/` (models, repos impl, remote sources) → `domain/` (entities, repo interfaces, use cases) → `presentation/` (pages, view models, widgets) → `di/` (feature-level DI registration).

## Key conventions

- Every screen: `BasePage<VM, State, Event, Action>` — typed ViewModel lifecycle
- State management: `BaseViewModel` extends BLoC; one ViewModel per screen
- DI: `get_it` — register in feature-level locators, wired from `data_locator.dart` / `use_case_locator.dart`
- Navigation: `go_router` — routes in `navigation.dart`
- Networking: Dio + Retrofit + 3-interceptor stack (DeviceHeaders → Auth → Retry)
- Tokens: `flutter_secure_storage` (Keystore/Keychain)
- Code gen: `build_runner` (freezed, json_serializable, retrofit_generator, flutter_gen)
- Localization: `easy_localization` (`en.json` / `uk.json`)

## TDD

Tests first (Red → Green → Refactor). Currently `test/` has only `widget_test.dart` — test infrastructure needs to be built. Use `bloc_test` for ViewModel tests, `mocktail` for mocks.

## Autonomous brain obligation

After building any feature → write `brain/raw/features/YYYY-MM-DD-feature-name.md` and ingest it.
