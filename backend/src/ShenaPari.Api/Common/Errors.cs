namespace ShenaPari.Api.Common;

// All error codes of the API in one file: this is the contract with the Flutter app.

public static class CommonErrors
{
    public static readonly Error Unauthorized = new("common.unauthorized", "Потрібно увійти в акаунт", 401);
    public static readonly Error Forbidden = new("common.forbidden", "Недостатньо прав", 403);
    public static readonly Error Validation = new("common.validation", "Некоректні дані запиту", 400);
    public static readonly Error NotFound = new("common.not_found", "Не знайдено", 404);
    public static readonly Error TooManyRequests = new("common.too_many_requests", "Забагато запитів, спробуйте за хвилину", 429);
    public static readonly Error ServerError = new("common.server_error", "Помилка сервера, спробуйте пізніше", 500);
}

public static class AuthErrors
{
    public static readonly Error InvalidPhone = new("auth.invalid_phone", "Номер має бути у форматі +380XXXXXXXXX", 400);
    public static readonly Error TooManyRequests = new("auth.too_many_requests", "Новий код можна запросити через 60 секунд", 429);
    public static readonly Error InvalidCode = new("auth.invalid_code", "Невірний або прострочений код", 400);
    public static readonly Error TooManyAttempts = new("auth.too_many_attempts", "Забагато спроб, запросіть новий код", 429);
    public static readonly Error InvalidCredentials = new("auth.invalid_credentials", "Невірний email або пароль", 401);
    public static readonly Error AccountDeactivated = new("auth.account_deactivated", "Акаунт вимкнено. Зверніться до адміністратора", 403);
    public static readonly Error InvalidToken = new("auth.invalid_token", "Сесія завершилась, увійдіть знову", 401);
}

public static class ProfileErrors
{
    public static readonly Error InvalidName = new("profile.invalid_name", "Ім'я має містити від 2 до 100 символів", 400);
}

public static class EmployeeErrors
{
    public static readonly Error NotFound = new("employee.not_found", "Працівника не знайдено", 404);
    public static readonly Error InvalidEmail = new("employee.invalid_email", "Некоректний email", 400);
    public static readonly Error EmailTaken = new("employee.email_taken", "Працівник з таким email уже існує", 409);
    public static readonly Error WeakPassword = new("employee.weak_password", "Пароль має містити щонайменше 8 символів", 400);
    public static readonly Error InvalidName = new("employee.invalid_name", "Ім'я має містити від 2 до 100 символів", 400);
    public static readonly Error InvalidRole = new("employee.invalid_role", "Можна створити лише кухаря або адміна", 400);
    public static readonly Error NotAllowed = new("employee.not_allowed", "Недостатньо прав для цього працівника", 403);
    public static readonly Error CannotChangeSelf = new("employee.cannot_change_self", "Не можна вимкнути власний акаунт", 409);
}

public static class ScheduleErrors
{
    public static readonly Error NotFound = new("schedule.not_found", "Розклад не знайдено", 404);
    public static readonly Error InvalidName = new("schedule.invalid_name", "Назва має містити від 2 до 100 символів", 400);
    public static readonly Error NameTaken = new("schedule.name_taken", "Розклад з такою назвою вже існує", 409);
    public static readonly Error InvalidBreaks = new("schedule.invalid_breaks", "Перерви не мають перетинатися, а кінець має бути пізніше за початок", 400);
    public static readonly Error ActiveCannotBeDeleted = new("schedule.active_cannot_be_deleted", "Активний розклад не можна видалити", 409);
}

public static class MenuErrors
{
    public static readonly Error DishNotFound = new("menu.dish_not_found", "Страву не знайдено", 404);
    public static readonly Error CategoryNotFound = new("menu.category_not_found", "Категорію не знайдено", 404);
    public static readonly Error InvalidName = new("menu.invalid_name", "Назва закоротка або задовга", 400);
    public static readonly Error InvalidPrice = new("menu.invalid_price", "Ціна має бути більшою за нуль", 400);
    public static readonly Error InvalidDish = new("menu.invalid_dish", "Некоректні дані страви", 400);
    public static readonly Error InvalidImage = new("menu.invalid_image", "Потрібне фото JPEG, PNG або WebP до 5 МБ", 400);
    public static readonly Error CategoryNotEmpty = new("menu.category_not_empty", "Спершу перенесіть або видаліть страви цієї категорії", 409);
    public static readonly Error DishInUse = new("menu.dish_in_use", "Страва є в замовленнях. Сховайте її замість видалення", 409);
}

public static class OrderErrors
{
    public static readonly Error NotFound = new("order.not_found", "Замовлення не знайдено", 404);
    public static readonly Error Empty = new("order.empty", "У замовленні немає страв", 400);
    public static readonly Error InvalidQuantity = new("order.invalid_quantity", "Кількість має бути від 1 до 20", 400);
    public static readonly Error BreakNotFound = new("order.break_not_found", "Перерву не знайдено", 400);
    public static readonly Error BreakPassed = new("order.break_passed", "Ця перерва вже почалась, оберіть іншу", 409);
    public static readonly Error DishUnavailable = new("order.dish_unavailable", "Деякі страви зараз недоступні", 409);
    public static readonly Error InvalidTransition = new("order.invalid_transition", "Така зміна статусу неможлива", 409);
    public static readonly Error AlreadyPickedUp = new("order.already_picked_up", "Замовлення вже видано", 409);
    public static readonly Error PaymentRequired = new("order.payment_required", "Оберіть спосіб оплати", 400);
    public static readonly Error CanteenPaused = new("order.canteen_paused", "Кухня зараз не приймає замовлення", 409);
    public static readonly Error CannotCancel = new("order.cannot_cancel", "Замовлення вже готується, скасувати не можна", 409);
    public static readonly Error InvalidEta = new("order.invalid_eta", "Час готовності: 5, 10, 15 або 20 хвилин", 400);
    public static readonly Error EtaRequired = new("order.eta_required", "Щоб прийняти замовлення, вкажіть час готовності", 400);
    public static readonly Error NotReady = new("order.not_ready", "Замовлення ще не готове", 409);
}
