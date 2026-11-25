# Розробка

[← До README](../README.md)

- [Що встановити](#що-встановити)
- [Сервер](#сервер)
- [Мобільні застосунки](#мобільні-застосунки)
- [Запуск на справжньому телефоні](#запуск-на-справжньому-телефоні)
- [Демо з будь-якої мережі](#демо-з-будь-якої-мережі)
- [Тести](#тести)
- [CI](#ci)
- [Правила роботи з кодом](#правила-роботи-з-кодом)

## Що встановити

| Інструмент | Версія |
|---|---|
| .NET SDK | 10.x |
| Flutter | stable, Dart ≥ 3.10.7 |
| Android Studio або Xcode | для емуляторів і збірки |
| ngrok | лише для демо з іншої мережі |

## Сервер

```bash
cd backend
dotnet run --project src/ShenaPari.Api
```

- Сервер слухає `0.0.0.0:5041`, тож телефон у тій самій Wi-Fi бачить його за IP комп'ютера.
- Swagger: http://localhost:5041/swagger.
- База: `src/ShenaPari.Api/shenapari.db`. Щоб почати з чистої, видаліть файл. Під час наступного старту він створиться з демо-даними.
- SMS-код для входу клієнта з'являється в консолі: `SMS to +380…: ShenaPari code: 123456`.

### Конфігурація

`appsettings.json` містить загальні налаштування, `appsettings.Development.json` — налаштування для розробки (рядок підключення, JWT-ключ, тестові акаунти, шлях до ключа Firebase). Будь-яке значення можна перевизначити змінною середовища: `Jwt__Key`, `ConnectionStrings__Default`, `Orders__NotPickedUpAfterMinutes`.

| Секція | Ключ | Типово | Що означає |
|---|---|---|---|
| `Jwt` | `Issuer`, `Audience`, `Key` | `shenapari`, `shenapari-app`, — | підпис токенів; `Key` щонайменше 32 символи |
| | `AccessTokenMinutes` / `RefreshTokenDays` | 15 / 30 | час життя токенів |
| `Campus` | `TimeZone` | `Europe/Kyiv` | часовий пояс розкладу |
| | `DaysAhead` | 7 | на скільки днів уперед генерувати перерви |
| `Orders` | `NotPickedUpAfterMinutes` | 30 | після скількох хвилин готове замовлення стає «не забрано» |
| | `RatingAskAfterMinutes` | 30 | коли просити оцінку після видачі |
| | `RatingCardHours` | 24 | скільки живе картка оцінки на головній |
| | `RatingWindowDays` | 3 | скільки днів можна оцінити й змінити оцінку |
| `RateLimit` | `AuthRequestsPerMinute` | 20 | ліміт на `/auth/*` з однієї IP |
| `Firebase` | `CredentialsPath` | `../../secrets/firebase-adminsdk.json` (dev) | ключ сервісного акаунта; без нього push лише пишеться в лог |
| `Seed` | `Employees` | dev: суперадмін і кухар | акаунти персоналу, які створюються під час старту |

### Push-сповіщення

Ключ сервісного акаунта Firebase кладеться в `backend/secrets/firebase-adminsdk.json`. Папка в `.gitignore`, і **комітити ключ не можна** (репозиторій публічний).

### Нова міграція

```bash
cd backend
dotnet tool restore
dotnet ef migrations add <Назва> --project src/ShenaPari.Api
```

Міграції застосовуються самі під час старту сервера.

## Мобільні застосунки

`mobile/` — це Flutter workspace, тому залежності ставляться однією командою для всіх трьох учасників. Код, згенерований для freezed, json_serializable і retrofit (`*.g.dart`, `*.freezed.dart`), у git не потрапляє, тож після клонування або перемикання гілки треба запустити `build_runner`, причому спершу в пакеті.

```bash
cd mobile
flutter pub get
(cd packages/shenapari_core && dart run build_runner build -d)   # кольори, лого
(cd shenapari && dart run build_runner build -d)                 # freezed, json, retrofit, ресурси
(cd kitchen && dart run build_runner build -d)
```

### Клієнт

```bash
cd mobile/shenapari
flutter run --dart-define-from-file=env/dev.json       # емулятор або симулятор
```

Адресу сервера задає `API_BASE_URL` (`lib/app/env.dart`). Якщо її немає, Android-емулятор іде на `http://10.0.2.2:5041`, а iOS-симулятор на `http://localhost:5041`.

| Файл | Для чого | У git |
|---|---|---|
| `env/dev.json` | емулятор або симулятор | так |
| `env/device.json` | справжній телефон у тій самій Wi-Fi (копія `device.example.json`) | ні |
| `env/demo.json` | демо через ngrok (копія `demo.example.json`) | ні |

Push працює лише на Android: Firebase ініціалізується тільки там (`app/bootstrap.dart`).

### Кухня

```bash
cd mobile/kitchen
flutter run                                                     # емулятор або симулятор
flutter run --dart-define-from-file=../shenapari/env/device.json   # справжній планшет
```

Вхід: `cook@shenapari.local` / `Cook12345!`.

### Android Studio

У `.run/` є готові конфігурації: «SheNaPari», «SheNaPari (телефон)», «SheNaPari (демо)», «ШеНаПарі Кухня», «ШеНаПарі Кухня (пристрій)», «ШеНаПарі Кухня (демо)».

## Запуск на справжньому телефоні

1. Телефон і комп'ютер в одній Wi-Fi.
2. IP комп'ютера: `ipconfig getifaddr en0` (macOS).
3. `cp env/device.example.json env/device.json` і вписати IP: `"API_BASE_URL": "http://192.168.0.10:5041"`.
4. Запустити конфігурацію «SheNaPari (телефон)» або `flutter run --dart-define-from-file=env/device.json`.

## Демо з будь-якої мережі

Коли телефон і комп'ютер у різних мережах (університетська Wi-Fi, роздача з телефона, мобільний інтернет), `scripts/demo.sh` запускає сервер і відкриває його через ngrok на постійну адресу.

Налаштування один раз:

1. Акаунт ngrok і `ngrok config add-authtoken <токен>`.
2. Безплатний статичний домен (Dashboard → Domains).
3. `cp mobile/shenapari/env/demo.example.json mobile/shenapari/env/demo.json` і вписати домен.

Далі:

```bash
scripts/demo.sh        # сервер (якщо ще не запущений) + тунель; Ctrl+C зупиняє обидва
```

Застосунки збираються конфігураціями «SheNaPari (демо)» та «ШеНаПарі Кухня (демо)». Комп'ютер має лишатися ввімкненим і в мережі. Лог сервера пишеться в `backend/demo.log`.

## Тести

```bash
cd backend && dotnet test                  # 118 інтеграційних тестів
cd mobile/shenapari && flutter test        # 348
cd mobile/kitchen && flutter test          # 60
```

**Сервер.** `tests/ShenaPari.Api.Tests` піднімає справжній API через `WebApplicationFactory<Program>` на окремій тимчасовій SQLite. SMS і push замінено заглушками, тож тести перевіряють і надіслані коди, і push. SignalR перевіряється через LongPolling поверх TestServer.

**Застосунки.** Тести дзеркалять `lib/`. Мінімум для фічі: Cubit (успіх і помилка, `bloc_test`), use case, `toEntity()` з перетвореннями. Моки — `mocktail`. Окремі тести перевіряють, що кожен ключ перекладу є і в `uk.json`, і в `en.json`, а ключі пакета (`CoreKeys`) є в перекладах кожного застосунку.

## CI

| Workflow | Коли | Кроки |
|---|---|---|
| `backend-ci.yml` | push у `main`/`develop` і PR, якщо змінено `backend/**` | `dotnet restore` → `dotnet build -warnaserror` → `dotnet test` → перевірка, що модель не має незастосованих змін (`dotnet ef migrations has-pending-model-changes`) → перевірка вразливих пакетів → звіт тестів як артефакт |
| `mobile-ci.yml` | push у `main`/`develop` і PR, якщо змінено `mobile/**` | `flutter pub get` → `build_runner` і `flutter analyze` для `shenapari_core` → `build_runner`, `flutter analyze`, `flutter test` для клієнта → те саме для кухні |

## Правила роботи з кодом

- Кожен крок робиться в окремій гілці, PR завжди відкривається в `main`.
- Код і коментарі пишуться англійською, тексти для користувача українською (у клієнті ще й англійською).
- Правила архітектури: [architecture.md](architecture.md). Опис API для розробника сервера: `backend/README.md`.
