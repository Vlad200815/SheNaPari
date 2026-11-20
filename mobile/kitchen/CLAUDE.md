# ШеНаПарі Кухня — застосунок для персоналу

Черга замовлень, видача за QR, стоп-лист і пауза для кухні їдальні. Окремий застосунок (`com.shenapari.kitchen`), головний пристрій — Android-планшет горизонтально, на телефоні той самий інтерфейс вертикально. Завжди темна тема. Дизайн: https://claude.ai/artifact/XjY6drysxreutUfdq8EETc

## Команди

```bash
flutter pub get                                                     # увесь workspace (../pubspec.yaml)
(cd ../packages/shenapari_core && dart run build_runner build -d)   # спершу пакет
dart run build_runner build -d
flutter analyze && flutter test
flutter run                                    # симулятор / емулятор; бекенд на http://localhost:5041 (Android-емулятор — 10.0.2.2)
flutter run --dart-define-from-file=../shenapari/env/device.json   # справжній планшет у тій самій Wi-Fi
dart run flutter_launcher_icons                # після зміни assets/icon/*
```

В Android Studio: запуски «ШеНаПарі Кухня» (емулятор) і «ШеНаПарі Кухня (пристрій)» (`.run/` у корені репо).

Вхід — пошта й пароль персоналу (`POST /auth/staff/login`), тестовий кухар `cook@shenapari.local` / `Cook12345!` у режимі розробки (див. `../../backend/README.md`).

## Архітектура й правила

Ті самі, що в клієнта (`../shenapari/CLAUDE.md`): Clean Architecture + Cubit, feature-first, `Result<T>`, роутер сам веде за статусом сесії. Мережа, сесія, сховище, тема, лого, шторки — з `package:shenapari_core`; тексти пакета (`CoreKeys`) мають бути й у `assets/translations` кухні (тест перевіряє). Кнопка дії — `KitchenButton` (жовта, темний текст, 56 dp).
