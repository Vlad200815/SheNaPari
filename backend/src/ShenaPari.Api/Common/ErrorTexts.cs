
namespace ShenaPari.Api.Common;

/// The text an error is shown with, in the language of the request.
/// `Errors.cs` holds the Ukrainian text (the default); the English ones are
/// here by code. A test makes sure every error has one.
public static class ErrorTexts
{
    public static string For(Error error) =>
        Lang.IsEnglish
        && English.TryGetValue(error.Code, out var text)
            ? text
            : error.Message;

    public static readonly IReadOnlyDictionary<string, string> English = new Dictionary<string, string>
    {
        ["common.unauthorized"] = "Please sign in",
        ["common.forbidden"] = "Not allowed",
        ["common.validation"] = "Invalid request data",
        ["common.not_found"] = "Not found",
        ["common.too_many_requests"] = "Too many requests, please try again in a minute",
        ["common.server_error"] = "Server error, please try again later",

        ["auth.invalid_phone"] = "The number must look like +380XXXXXXXXX",
        ["auth.too_many_requests"] = "You can request a new code in 60 seconds",
        ["auth.invalid_code"] = "The code is wrong or has expired",
        ["auth.too_many_attempts"] = "Too many attempts, please request a new code",
        ["auth.invalid_credentials"] = "Wrong email or password",
        ["auth.account_deactivated"] = "The account is disabled. Please contact the administrator",
        ["auth.invalid_token"] = "Your session has ended, please sign in again",

        ["profile.invalid_name"] = "The name must be 2 to 100 characters long",
        ["profile.has_active_order"] = "Pick up or cancel your active order first",
        ["profile.staff_cannot_delete"] = "A staff account is deleted by the administrator",

        ["employee.not_found"] = "Employee not found",
        ["employee.invalid_email"] = "Invalid email",
        ["employee.email_taken"] = "An employee with this email already exists",
        ["employee.weak_password"] = "The password must be at least 8 characters long",
        ["employee.invalid_name"] = "The name must be 2 to 100 characters long",
        ["employee.invalid_role"] = "Only a cook or an admin can be created",
        ["employee.not_allowed"] = "Not allowed for this employee",
        ["employee.cannot_change_self"] = "You can't disable your own account",

        ["schedule.not_found"] = "Schedule not found",
        ["schedule.invalid_name"] = "The name must be 2 to 100 characters long",
        ["schedule.name_taken"] = "A schedule with this name already exists",
        ["schedule.invalid_breaks"] = "Breaks must not overlap, and each must end after it starts",
        ["schedule.active_cannot_be_deleted"] = "The active schedule can't be deleted",

        ["menu.dish_not_found"] = "Dish not found",
        ["menu.category_not_found"] = "Category not found",
        ["menu.invalid_name"] = "The name is too short or too long",
        ["menu.invalid_price"] = "The price must be greater than zero",
        ["menu.invalid_dish"] = "Invalid dish data",
        ["menu.invalid_image"] = "A JPEG, PNG or WebP photo up to 5 MB is required",
        ["menu.category_not_empty"] = "Move or delete the dishes of this category first",

        ["order.not_found"] = "Order not found",
        ["order.empty"] = "The order has no dishes",
        ["order.invalid_quantity"] = "The quantity must be from 1 to 20",
        ["order.break_not_found"] = "Break not found",
        ["order.break_passed"] = "This break has already started, please choose another one",
        ["order.dish_unavailable"] = "Some dishes are not available right now",
        ["order.invalid_transition"] = "This status change is not possible",
        ["order.already_picked_up"] = "The order has already been handed over",
        ["order.payment_required"] = "Please choose a payment method",
        ["order.canteen_paused"] = "The kitchen isn't taking orders right now",
        ["order.cannot_cancel"] = "The order is already being cooked and can't be cancelled",
        ["order.invalid_eta"] = "Ready time: 5, 10, 15 or 20 minutes",
        ["order.eta_required"] = "Set the ready time to accept the order",
        ["order.not_ready"] = "The order isn't ready yet",
        ["order.invalid_history_filter"] = "The history has only picked up, cancelled and not picked up orders",

        ["legal.not_found"] = "Document not found",
    };
}
