# API

[← До README](../README.md)

REST API на `http://<сервер>:5041`, без префікса версії. Інтерактивна документація: **Swagger UI** на `/swagger` (сама адреса сервера `/` перенаправляє туди). Кнопка **Authorize** у Swagger приймає access-токен.

- [Загальні правила](#загальні-правила)
- [Ролі й доступ](#ролі-й-доступ)
- [Ендпоінти](#ендпоінти): вхід · профіль · меню · замовлення клієнта · кухня · адміністрування · службові
- [Події реального часу (SignalR)](#події-реального-часу-signalr)
- [Push-сповіщення](#push-сповіщення)
- [Коди помилок](#коди-помилок)

## Загальні правила

**Формат відповіді.** Кожна відповідь має вигляд конверта, а HTTP-статус при цьому справжній:

```json
{ "succeeded": true, "message": null, "data": { }, "errors": [] }
```
```json
{ "succeeded": false, "message": "Кухня зараз не приймає замовлення", "data": null, "errors": ["order.canteen_paused"] }
```

Далі в таблицях у колонці «Відповідь» описано вміст `data`. «—» означає `data: null`.

**Автентифікація.** Заголовок `Authorization: Bearer <accessToken>`. Access-токен — JWT на 15 хв з claim'ами `sub` (id користувача), `role` і `sid` (id сесії). Refresh-токен непрозорий, живе 30 днів і змінюється під час кожного `/auth/refresh`.

**Мова.** `Accept-Language: en` перемикає тексти англійською; без заголовка або з будь-яким іншим значенням вони українською. Мова впливає на `message` помилок, документи `/legal/*`, назви страв, категорій і їдальні.

**Енуми** передаються рядками в PascalCase: `"Ready"`, `"GooglePay"`, `"Cook"`.

**Дати** передаються в ISO 8601 з часовим поясом, у UTC. Час перерв у розкладах передається як `"HH:mm"` за місцевим часом кампусу.

**Обмеження запитів.** На `/auth/*` діє ліміт: 20 запитів на хвилину з однієї IP-адреси, понад нього 429 `common.too_many_requests`.

## Ролі й доступ

| Роль | Як входить | Що може |
|---|---|---|
| `Customer` | телефон + SMS-код | меню, власні замовлення, профіль |
| `Cook` | email + пароль | черга, видача, стоп-лист, пауза |
| `Admin` | email + пароль | усе, що `Cook`, а також меню, розклади, кухарі, замовлення за день |
| `SuperAdmin` | email + пароль | усе, що `Admin`, а також керування адміністраторами |

Колонка «Доступ» у таблицях нижче:
- **усі** — без токена;
- **токен** — будь-який користувач, що увійшов;
- **клієнт** — лише `Customer` (персонал отримає 403);
- **кухня** — `Cook`, `Admin`, `SuperAdmin`;
- **адмін** — `Admin`, `SuperAdmin`.

Токен вимкненого працівника перестає діяти одразу: сервер перевіряє працівника в базі на кожному запиті.

## Ендпоінти

### Вхід (`AuthController`)

| Метод | Шлях | Доступ | Тіло запиту | Відповідь | Помилки |
|---|---|---|---|---|---|
| `POST` | `/auth/otp/request` | усі | `{ "phone": "+380671234567" }` | — | `auth.invalid_phone` 400, `auth.too_many_requests` 429 (новий код раз на 60 с) |
| `POST` | `/auth/otp/verify` | усі | `{ "phone", "code": "123456" }` | `{ accessToken, refreshToken, isNew }` | `auth.invalid_code` 400, `auth.too_many_attempts` 429, `auth.account_deactivated` 403 |
| `POST` | `/auth/staff/login` | усі | `{ "email", "password" }` | `{ accessToken, refreshToken, isNew: false }` | `auth.invalid_credentials` 401, `auth.account_deactivated` 403 |
| `POST` | `/auth/refresh` | усі | `{ "refreshToken" }` | нова пара токенів | `auth.invalid_token` 401 |
| `POST` | `/auth/logout` | токен | `{ "refreshToken" }` | — | |

- SMS-код має 6 цифр, діє 5 хв і дає 5 спроб. Поки SMS-провайдера не підключено, код пишеться в консоль сервера.
- Перший успішний `verify` для нового номера створює клієнта. `isNew: true` означає, що імені ще немає й застосунок має його спитати.
- Після `refresh` старий refresh-токен відкликано, а токен push переходить на нову сесію.

### Профіль (`MeController`)

| Метод | Шлях | Доступ | Тіло запиту | Відповідь | Помилки |
|---|---|---|---|---|---|
| `GET` | `/me` | токен | | `MeDto` | |
| `PATCH` | `/me` | токен | `{ "name": "Влад" }` | `MeDto` | `profile.invalid_name` 400 (2–100 символів) |
| `DELETE` | `/me` | токен | | — | `profile.staff_cannot_delete` 403, `profile.has_active_order` 409 |
| `PUT` | `/me/settings` | клієнт | `{ "orderPushEnabled": false }` | `MeDto` | `common.forbidden` 403 для персоналу |
| `PUT` | `/me/push-token` | токен | `{ "token": "<FCM token>" }` або `{ "token": null }` | — | |
| `GET` | `/me/notifications` | токен | | `NotificationDto[]`, останні 50 від нових | |
| `POST` | `/me/notifications/read` | токен | | — (усі позначаються прочитаними) | |

```jsonc
// MeDto
{ "id": "…", "role": "Customer", "name": "Влад", "phone": "+380671234567", "email": null, "orderPushEnabled": true }
// NotificationDto
{ "id": "…", "orderId": "…", "title": "Замовлення №7 готове!", "body": "Покажіть QR-код на видачі", "createdAt": "…", "isRead": false }
```

`DELETE /me` знеособлює клієнта: ім'я стирається, телефон звільняється, усі сесії й токени push відкликаються, сповіщення видаляються. Замовлення лишаються в базі без прив'язки до людини.

### Меню, перерви, їдальня

| Метод | Шлях | Доступ | Параметри | Відповідь | Помилки |
|---|---|---|---|---|---|
| `GET` | `/categories` | токен | | `[{ id, name }]` за `SortOrder` | |
| `GET` | `/dishes` | токен | `?categoryId=2&popular=true` (обидва необов'язкові) | `DishDto[]` | |
| `GET` | `/dishes/{id}` | токен | | `DishDto` | `menu.dish_not_found` 404 |
| `GET` | `/breaks` | токен | | `[{ id, startsAt, endsAt }]`: сьогоднішні перерви, що ще не почались | |
| `GET` | `/breaks/next` | токен | | найближча перерва (може бути завтра) або `null` | |
| `GET` | `/canteen` | токен | | `{ name, isAcceptingOrders, pausedAt }` | |

```jsonc
// DishDto
{
  "id": 1, "categoryId": 1, "name": "Чизбургер", "description": "Яловича котлета, сир чедер…",
  "price": 95.0, "weightG": 220, "kcal": 480, "imageUrl": "/images/menu/cheeseburger.jpg",
  "isPopular": true, "proteinG": 26, "fatG": 24, "carbsG": 40, "spicyLevel": 0,
  "isVegan": false, "isAvailable": true
}
```

Страви зі стоп-листа (`isAvailable: false`) у списку є, а архівовані адміністратором ні. `imageUrl` — відносний шлях до статичного файлу на тому самому сервері.

### Замовлення клієнта (`OrdersController`)

Доступ до всіх ендпоінтів цього розділу має лише **клієнт**.

| Метод | Шлях | Тіло / параметри | Відповідь | Помилки |
|---|---|---|---|---|
| `POST` | `/orders` | див. нижче | `OrderDto`, **201** | `order.empty` 400, `order.invalid_quantity` 400, `order.payment_required` 400, `order.break_not_found` 400, `order.canteen_paused` 409, `order.break_passed` 409, `order.dish_unavailable` 409 |
| `GET` | `/orders/my` | `?active=true`: лише ті, що в роботі | `OrderDto[]`, від нових | |
| `GET` | `/orders/my/history` | `?status=PickedUp\|Cancelled\|NotPickedUp&before=<ISO>&limit=20` | `{ items, hasMore, months }` | `order.invalid_history_filter` 400 |
| `GET` | `/orders/{id}` | | `OrderDto` | `order.not_found` 404 (і для чужого замовлення) |
| `POST` | `/orders/{id}/cancel` | | `OrderDto` | `order.not_found` 404, `order.cannot_cancel` 409 |
| `GET` | `/orders/my/rating-prompt` | | `[]` або `[{ orderId, number, items, pickedUpAt }]` | |
| `PUT` | `/orders/{id}/rating` | `{ "stars": 5, "tags": ["tasty","fast"], "comment": "…" }` | `{ stars, tags, comment, updatedAt }` | `rating.invalid_stars` 400, `rating.invalid_tag` 400, `rating.comment_too_long` 400, `order.not_found` 404, `rating.not_picked_up` 409, `rating.window_closed` 409 |
| `POST` | `/orders/{id}/rating/dismiss` | | — | `order.not_found` 404 |

```jsonc
// POST /orders
{
  "breakSlotId": 12,            // null = «якнайшвидше»
  "paymentProvider": "GooglePay", // або "ApplePay"; оплата імітується
  "items": [ { "dishId": 1, "quantity": 2 }, { "dishId": 18, "quantity": 1 } ]
}
```

```jsonc
// OrderDto
{
  "id": "…", "number": 7, "status": "Ready", "total": 220.0, "createdAt": "…",
  "breakSlot": { "id": 12, "startsAt": "…", "endsAt": "…" },
  "estimatedReadyAt": "…", "readyAt": "…", "paymentProvider": "GooglePay",
  "items": [ { "dishId": 1, "name": "Чизбургер", "quantity": 2, "unitPrice": 95.0 } ],
  "history": [ { "status": "Paid", "at": "…", "reason": null }, … ],
  "pickupToken": "…",   // лише поки status = Ready
  "rating": null,
  "rateUntil": null     // до коли можна оцінити; null — не можна
}
```

Як сервер обробляє замовлення:
- Ціни й назви він бере з бази, `total` рахує сам. Однакові страви в запиті об'єднуються в одну позицію; кількість однієї страви 1–20.
- Замовлення створюється вже оплаченим (`Paid`) і одразу з'являється на дошці кухні.
- Скасувати замовлення клієнт може у статусах `Paid` і `Accepted`. Оплата переходить у `Refunded`.
- В історії лише завершені замовлення. Наступна сторінка: `before` = `createdAt` останнього замовлення, `limit` 1–50. `months` підсумовує кількість і витрачену суму за кожен місяць усієї історії з тим самим фільтром; скасовані замовлення в суму не входять.
- Оцінити можна лише видане замовлення протягом 3 днів після видачі; повторний `PUT` змінює оцінку. Для 4–5 зірок дозволені теги `tasty`, `fast`, `hot`, `big_portion`, `no_queue`, для 1–3 — `cold`, `slow`, `small_portion`, `wrong_order`, `not_tasty`. Коментар до 500 символів.
- Картка «Як вам №…?» з'являється через 30 хв після видачі останнього замовлення і зникає після оцінки, «не зараз», нового замовлення або через 24 год.

### Кухня

Доступ до всіх ендпоінтів цього розділу має **кухня**.

| Метод | Шлях | Тіло | Відповідь | Помилки |
|---|---|---|---|---|
| `GET` | `/staff/orders` | | `StaffOrderDto[]`: замовлення в роботі на сьогодні й «якнайшвидше», спершу ті, що потрібні раніше | |
| `POST` | `/staff/orders/{id}/accept` | `{ "minutes": 15 }`: 5, 10, 15 або 20 | `StaffOrderDto` | `order.invalid_eta` 400, `order.not_found` 404, `order.invalid_transition` 409 |
| `PATCH` | `/staff/orders/{id}/status` | `{ "status": "Cooking", "reason": null }` | `StaffOrderDto` | `order.eta_required` 400 (для `Accepted`), `order.not_found` 404, `order.invalid_transition` 409 |
| `POST` | `/staff/orders/pickup` | `{ "token": "<PickupToken з QR>" }` | `StaffOrderDto` | `order.not_found` 404, `order.already_picked_up` 409, `order.not_ready` 409 |
| `GET` | `/staff/dishes` | | `[{ id, categoryId, name, isAvailable }]` | |
| `PATCH` | `/staff/dishes/{id}/availability` | `{ "isAvailable": false }` | `{ id, categoryId, name, isAvailable }` | `menu.dish_not_found` 404 |
| `PUT` | `/staff/canteen/accepting` | `{ "isAcceptingOrders": false }` | `{ name, isAcceptingOrders, pausedAt }` | |

```jsonc
// StaffOrderDto
{
  "id": "…", "number": 7, "status": "Cooking", "total": 220.0, "customerName": "Влад",
  "createdAt": "…", "breakSlot": null, "estimatedReadyAt": "…", "readyAt": null,
  "items": [ … ], "history": [ … ]
}
```

- `accept` ставить `estimatedReadyAt` = зараз + `minutes`, але не раніше за початок обраної перерви.
- Через `PATCH …/status` можна перевести замовлення в `Cooking`, `Ready`, `Cancelled` (з `reason`, яку побачить клієнт), `NotPickedUp` і `PickedUp` (видача без QR, коли телефон клієнта розрядився).
- Кухня може скасувати замовлення і в статусі `Cooking` (наприклад, закінчились продукти).
- Пауза не впливає на вже прийняті замовлення.

### Адміністрування

Доступ до всіх ендпоінтів цього розділу має **адмін**. Окремого інтерфейсу для них поки немає, тож адміністратор працює через Swagger.

**Персонал**

| Метод | Шлях | Тіло | Відповідь | Помилки |
|---|---|---|---|---|
| `GET` | `/admin/employees` | | `[{ id, email, name, role, isActive, createdAt }]` | |
| `POST` | `/admin/employees` | `{ "email", "password", "name", "role": "Cook" \| "Admin" }` | `EmployeeDto`, **201** | `employee.invalid_role` 400, `employee.invalid_email` 400, `employee.invalid_name` 400, `employee.weak_password` 400 (мінімум 8 символів), `employee.not_allowed` 403, `employee.email_taken` 409 |
| `POST` | `/admin/employees/{id}/deactivate` | | `EmployeeDto` | `employee.not_found` 404, `employee.not_allowed` 403, `employee.cannot_change_self` 409 |
| `POST` | `/admin/employees/{id}/activate` | | `EmployeeDto` | `employee.not_found` 404, `employee.not_allowed` 403 |
| `POST` | `/admin/employees/{id}/password` | `{ "password" }` | `EmployeeDto` | `employee.weak_password` 400, `employee.not_found` 404, `employee.not_allowed` 403 |

`Admin` керує кухарями, `SuperAdmin` кухарями й адміністраторами. Суперадміністратора через API не створити й не змінити: він береться з конфігурації. Вимкнення й зміна пароля відкликають усі сесії працівника.

**Меню**

| Метод | Шлях | Тіло | Відповідь | Помилки |
|---|---|---|---|---|
| `GET` | `/admin/categories` | | `[{ id, name, nameEn, sortOrder, dishCount }]` | |
| `POST` | `/admin/categories` | `{ "name", "sortOrder", "nameEn"? }` | категорія, **201** | `menu.invalid_name` 400 |
| `PUT` | `/admin/categories/{id}` | те саме | категорія | `menu.invalid_name` 400, `menu.category_not_found` 404 |
| `DELETE` | `/admin/categories/{id}` | | — | `menu.category_not_found` 404, `menu.category_not_empty` 409 |
| `GET` | `/admin/dishes` | | `AdminDishDto[]` (усі поля, окрім архівованих страв) | |
| `POST` | `/admin/dishes` | `SaveDishDto` | `AdminDishDto`, **201** | `menu.invalid_name` 400, `menu.invalid_price` 400, `menu.invalid_dish` 400, `menu.category_not_found` 404 |
| `PUT` | `/admin/dishes/{id}` | `SaveDishDto` | `AdminDishDto` | ті самі й `menu.dish_not_found` 404 |
| `DELETE` | `/admin/dishes/{id}` | | — (страву з минулих замовлень архівує, а не видаляє) | `menu.dish_not_found` 404 |
| `POST` | `/admin/dishes/{id}/image` | `multipart/form-data`, поле `file`: JPEG, PNG або WebP до 5 МБ | `AdminDishDto` | `menu.invalid_image` 400, `menu.dish_not_found` 404 |

```jsonc
// SaveDishDto: обов'язкові перші шість полів
{
  "categoryId": 1, "name": "Чизбургер", "description": "…", "price": 95, "weightG": 220, "kcal": 480,
  "isPopular": false, "isAvailable": true, "nameEn": "Cheeseburger", "descriptionEn": "…",
  "proteinG": 26, "fatG": 24, "carbsG": 40, "spicyLevel": 0, "isVegan": false
}
```

Кожна зміна меню надсилає всім підключеним застосункам подію `MenuChanged`, і меню в них оновлюється без перезапуску.

**Розклади дзвінків**

| Метод | Шлях | Тіло | Відповідь | Помилки |
|---|---|---|---|---|
| `GET` | `/admin/schedules` | | `[{ id, name, isActive, breaks: [{ start, end }] }]` | |
| `POST` | `/admin/schedules` | `{ "name": "Скорочений", "breaks": [{ "start": "09:30", "end": "09:40" }] }` | розклад, **201** | `schedule.invalid_name` 400, `schedule.invalid_breaks` 400, `schedule.name_taken` 409 |
| `POST` | `/admin/schedules/{id}/activate` | | розклад | `schedule.not_found` 404 |
| `DELETE` | `/admin/schedules/{id}` | | — | `schedule.not_found` 404, `schedule.active_cannot_be_deleted` 409 |

Перерви не мають перетинатися, кінець має бути пізніше за початок, у розкладі 1–20 перерв. Активація робить розклад єдиним активним і перебудовує майбутні перерви; ті, на які вже є замовлення, лишаються.

**Замовлення**

| Метод | Шлях | Параметри | Відповідь |
|---|---|---|---|
| `GET` | `/admin/orders` | `?date=2026-11-24` (типово сьогодні) | `StaffOrderDto[]`: усі замовлення дня, зокрема завершені, з історією |

### Службові

| Метод | Шлях | Доступ | Відповідь |
|---|---|---|---|
| `GET` | `/ping` | усі | `"pong"` (перевірка, що сервер живий; її використовує `scripts/demo.sh`) |
| `GET` | `/legal/{type}` | усі | `{ version, content }`: `type` = `terms`, `privacy` або `refund`; `content` у Markdown; `version` — перші 12 символів SHA-256 від тексту. Невідомий тип: `legal.not_found` 404 |
| `GET` | `/images/…` | усі | статичні фото страв з `wwwroot` |

## Події реального часу (SignalR)

Hub: `/hubs/orders`, потрібен токен. WebSocket не передає заголовків, тому токен іде в рядку запиту: `/hubs/orders?access_token=<accessToken>`. Застосунки лише слухають; методів, які клієнт може викликати, немає. Енуми в подіях — рядки.

| Подія | Кому | Коли | Вміст |
|---|---|---|---|
| `OrderCreated` | персонал (група `staff`) | клієнт оформив замовлення | `StaffOrderDto` |
| `OrderStatusChanged` | власник замовлення (група `user-{id}`) і персонал | будь-яка зміна статусу | `{ orderId, number, status, estimatedReadyAt }` |
| `CanteenChanged` | усі підключені | кухня поставила або зняла паузу | `{ name, isAcceptingOrders, pausedAt }` |
| `MenuChanged` | усі підключені | стоп-лист або будь-яка зміна меню адміністратором | `{ dishId }` (`null` для змін категорій) |

Подія повідомляє лише, що щось змінилось. Свіжі дані застосунки беруть через REST.

## Push-сповіщення

Сервер надсилає push через Firebase Cloud Messaging на всі пристрої клієнта, де відкрита сесія, якщо в нього ввімкнено `orderPushEnabled`. Незалежно від цього кожне сповіщення зберігається в `/me/notifications`.

| Коли | Заголовок (uk) | Текст (uk) | `data` |
|---|---|---|---|
| `Accepted` | Замовлення №7 прийнято | Буде готове приблизно о 12:40 | `type: order_status`, `orderId`, `status` |
| `Ready` | Замовлення №7 готове! | Покажіть QR-код на видачі | те саме |
| `Cancelled` кухнею | Замовлення №7 скасовано | `<причина>`. Кошти повернуто | те саме |
| `NotPickedUp` | Замовлення №7 не забрали | Час видачі минув, замовлення закрито | те саме |
| 30 хв після видачі | Як вам №7? | Оцініть одним дотиком: кухня читає кожен відгук | `type: rate_order`, `orderId` |

Про `Paid`, `Cooking`, `PickedUp` і скасування самим клієнтом push не надсилається, бо відкритий застосунок і так показує ці зміни. Тексти пишуться мовою, якою оформлено замовлення. Android-канал: `order_updates`, звук `gam`.

## Коди помилок

Повний список з текстами: `backend/src/ShenaPari.Api/Common/Errors.cs` (українською) і `Common/ErrorTexts.cs` (англійською).

| Група | Коди |
|---|---|
| `common` | `unauthorized` 401, `forbidden` 403, `validation` 400, `not_found` 404, `too_many_requests` 429, `server_error` 500 |
| `auth` | `invalid_phone` 400, `too_many_requests` 429, `invalid_code` 400, `too_many_attempts` 429, `invalid_credentials` 401, `account_deactivated` 403, `invalid_token` 401 |
| `profile` | `invalid_name` 400, `has_active_order` 409, `staff_cannot_delete` 403 |
| `employee` | `not_found` 404, `invalid_email` 400, `email_taken` 409, `weak_password` 400, `invalid_name` 400, `invalid_role` 400, `not_allowed` 403, `cannot_change_self` 409 |
| `schedule` | `not_found` 404, `invalid_name` 400, `name_taken` 409, `invalid_breaks` 400, `active_cannot_be_deleted` 409 |
| `menu` | `dish_not_found` 404, `category_not_found` 404, `invalid_name` 400, `invalid_price` 400, `invalid_dish` 400, `invalid_image` 400, `category_not_empty` 409 |
| `order` | `not_found` 404, `empty` 400, `invalid_quantity` 400, `break_not_found` 400, `break_passed` 409, `dish_unavailable` 409, `invalid_transition` 409, `already_picked_up` 409, `payment_required` 400, `canteen_paused` 409, `cannot_cancel` 409, `invalid_eta` 400, `eta_required` 400, `not_ready` 409, `invalid_history_filter` 400 |
| `rating` | `not_picked_up` 409, `window_closed` 409, `invalid_stars` 400, `invalid_tag` 400, `comment_too_long` 400 |
| `legal` | `not_found` 404 |

Код у відповіді має вигляд `група.код`, наприклад `order.canteen_paused`.
