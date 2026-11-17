# ШеНаПарі — Flutter-застосунок

Клієнт для замовлення їжі в університетській їдальні (iOS + Android). Бекенд — `../../backend` (ASP.NET Core), опис API й тестові акаунти в `../../backend/README.md`.

## Команди

```bash
flutter pub get
dart run build_runner build -d          # freezed, json_serializable, retrofit, flutter_gen
flutter analyze
flutter test
flutter run --dart-define-from-file=env/dev.json      # емулятор / симулятор
flutter run --dart-define-from-file=env/device.json   # справжній телефон у тій самій Wi-Fi
```

Без `API_BASE_URL` застосунок сам іде на комп'ютер розробника: Android-емулятор → `http://10.0.2.2:5041`, iOS-симулятор → `http://localhost:5041`. Для телефона скопіюй `env/device.example.json` у `env/device.json` (у git не потрапляє) і впиши IP Mac (`ipconfig getifaddr en0`). У Android Studio ті самі запуски є на кнопці Run: «SheNaPari» і «SheNaPari (телефон)» (`.run/` у корені репо).

## Архітектура

Clean Architecture + Cubit/Bloc + Feature-First. Залежності: `presentation → domain ← data`.

```
lib/
  main.dart            — лише bootstrap()
  app/                 — bootstrap, DI (di.dart), env, router (redirect за статусом сесії), splash
  core/                — технічне, без бізнес-логіки:
    result/            — sealed Result<T> (Ok/Err) і Failure
    network/           — Dio, AuthInterceptor, ApiEnvelope, apiCall
    session/           — SessionRepository (єдине джерело правди про вхід), SessionCubit
    storage/           — TokenStorage (secure storage), AppPrefs (прапорці)
    ui/                — тема, AppText, AppButton, снекбари
  features/<feature>/
    data/              — Retrofit API, *Dto (з toEntity()), *RepositoryImpl
    domain/            — entities, інтерфейс репозиторію, use cases
    presentation/<екран>/ — *_cubit.dart, *_state.dart, *_page.dart, widgets/
    <feature>_module.dart — реєстрація в get_it
```

## Правила коду

- **Кожна відповідь API — конверт** `{succeeded, message, data, errors:[коди]}` з правдивим HTTP-статусом. Розпаковує лише `apiCall` / `apiCallVoid` у `core/network`. Тип `Failure` визначається за HTTP-статусом (400 Validation, 401 Unauthorized, 403 Forbidden, 404 NotFound, 409 Conflict, інше Server). `failure.message` — готовий текст українською, `failure.code` — код на кшталт `order.canteen_paused` (усі в `backend/.../Common/Errors.cs`). Рішення на екрані — за типом або кодом, не за текстом.
- Репозиторії повертають `Result<T>`, без винятків і без try/catch усередині.
- Енуми з API приходять рядками; у кожного енума є `unknown`, парсимо через `values.asNameMap()[s] ?? unknown`.
- domain — чистий Dart: без Flutter, Dio, `json_annotation`. DTO (суфікс `Dto`) не виходять за межі `data/`.
- Use case лише там, де є кілька кроків або логіка клієнта. Правила, які перевіряє сервер, не дублюємо.
- Cubit за замовчуванням, Bloc для debounce і стрімів (SignalR). Стан — `freezed` з полем `status`. Cubit не має полів, що дублюють `state`, і не знає про `BuildContext`.
- Після входу/виходу ніхто не викликає `context.go` вручну: `SessionRepository` змінює статус, роутер робить redirect сам.
- Refresh токена — лише в `AuthInterceptor` (один спільний refresh на паралельні 401).
- DI: `get_it` (`sl`), модуль на фічу; Cubit — `registerFactory`. `sl` викликаємо лише в модулях і `BlocProvider`.
- Код і коментарі англійською, тексти для користувача українською.

## Тести

Тест спершу, потім код. `bloc_test` для Cubit, `mocktail` для моків. Тести дзеркалять `lib/`. Мінімум: Cubit (успіх і помилка), use case, `toEntity()` з перетвореннями.

Старі екрани (BasePage) видалено з `lib/src`; їхній вигляд можна підглянути в історії: `git show 87bf227:mobile/shenapari/lib/src/<шлях>`.
