using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;

namespace ShenaPari.Api.Common;

/// One failure: a stable machine code for the app ("order.not_ready"),
/// a text for the user, and the HTTP status the controller should answer with.
public record Error(string Code, string Message, int Status);

/// Every API response has this shape, success or failure:
///   { "succeeded": true,  "message": null, "data": {...}, "errors": [] }
///   { "succeeded": false, "message": "Замовлення ще не готове", "data": null, "errors": ["order.not_ready"] }
/// It mirrors Result&lt;T&gt; in the Flutter app. HTTP status codes stay meaningful (400/401/404/409...).
public class Result<T>
{
    public bool Succeeded { get; }
    public string? Message { get; }
    public T? Data { get; }
    public List<string> Errors { get; }

    [JsonIgnore] public int Status { get; }

    private Result(bool succeeded, T? data, string? message, List<string> errors, int status)
    {
        Succeeded = succeeded;
        Data = data;
        Message = message;
        Errors = errors;
        Status = status;
    }

    public static Result<T> Ok(T? data, int status = 200) => new(true, data, null, [], status);
    public static Result<T> Fail(Error e) => new(false, default, e.Message, [e.Code], e.Status);

    // Lets services write `return dto;` and `return OrderErrors.NotReady;`.
    public static implicit operator Result<T>(T data) => Ok(data);
    public static implicit operator Result<T>(Error error) => Fail(error);
}

/// Success without a payload ("data": null).
public static class Result
{
    public static Result<object?> Ok() => Result<object?>.Ok(null);
}

public static class ResultExtensions
{
    /// Result → HTTP response with the right status code and the envelope as the body.
    public static ActionResult ToActionResult<T>(this Result<T> result, int successStatus = 200) =>
        new ObjectResult(result) { StatusCode = result.Succeeded ? successStatus : result.Status };
}
