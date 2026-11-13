using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text.Json.Serialization;
using Microsoft.OpenApi;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Canteens;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Employees;
using ShenaPari.Api.Entities;
using ShenaPari.Api.Schedules;
using ShenaPari.Api.Menu;
using ShenaPari.Api.Orders;
using ShenaPari.Api.Push;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseSqlite(builder.Configuration.GetConnectionString("Default")));

// --- Auth ---
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddOptions<JwtOptions>().Bind(builder.Configuration.GetSection("Jwt")).ValidateOnStart();
builder.Services.AddSingleton<ISmsSender, LogSmsSender>();
builder.Services.AddScoped<TokenService>();
builder.Services.AddSingleton<PasswordService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<EmployeeService>();

var jwt = builder.Configuration.GetSection("Jwt").Get<JwtOptions>()
          ?? throw new InvalidOperationException("Missing Jwt config section");
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.MapInboundClaims = false; // keep "sub" and "role" as-is
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidIssuer = jwt.Issuer,
            ValidAudience = jwt.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
            RoleClaimType = "role",
            ClockSkew = TimeSpan.FromSeconds(30),
        };
        // WebSockets can't send an Authorization header, so the SignalR client passes
        // the JWT as ?access_token=... — accept it, but only for the hub path.
        o.Events = new JwtBearerEvents
        {
            // 401/403 come from the auth middleware, not from controllers:
            // write them in the same Result envelope as everything else.
            OnChallenge = ctx =>
            {
                ctx.HandleResponse();
                return WriteError(ctx.Response, CommonErrors.Unauthorized);
            },
            OnForbidden = ctx => WriteError(ctx.Response, CommonErrors.Forbidden),
            // A deactivated employee must lose access at once, not when the 15-minute
            // access token expires, so staff tokens are re-checked against the DB.
            OnTokenValidated = async ctx =>
            {
                if (ctx.Principal!.IsInRole(nameof(UserRole.Customer))) return;
                var db = ctx.HttpContext.RequestServices.GetRequiredService<AppDbContext>();
                var id = ctx.Principal.UserId();
                var active = await db.Employees.AnyAsync(e => e.Id == id && e.DeactivatedAt == null);
                if (!active) ctx.Fail("Account deactivated");
            },
            OnMessageReceived = ctx =>
            {
                var token = ctx.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(token) && ctx.HttpContext.Request.Path.StartsWithSegments("/hubs"))
                    ctx.Token = token;
                return Task.CompletedTask;
            },
        };
    });
builder.Services.AddAuthorization(Policies.Register);

// --- Menu & orders ---
builder.Services.AddOptions<CampusOptions>().Bind(builder.Configuration.GetSection("Campus"));
builder.Services.AddSingleton<CampusClock>();
builder.Services.AddScoped<MenuAdminService>();
builder.Services.AddScoped<ScheduleService>();
builder.Services.AddHostedService<SlotGenerationService>();
builder.Services.AddOptions<OrderOptions>().Bind(builder.Configuration.GetSection("Orders"));
// --- Push notifications ---
// With a Firebase service account key the server sends real pushes;
// without one it still runs and only logs them.
var firebaseKey = builder.Configuration["Firebase:CredentialsPath"];
if (!string.IsNullOrWhiteSpace(firebaseKey)) firebaseKey = Path.GetFullPath(firebaseKey, builder.Environment.ContentRootPath);
if (File.Exists(firebaseKey))
    builder.Services.AddSingleton<IPushSender>(sp =>
        new FcmPushSender(firebaseKey, sp.GetRequiredService<ILogger<FcmPushSender>>()));
else
    builder.Services.AddSingleton<IPushSender, LogPushSender>();
builder.Services.AddScoped<PushService>();

builder.Services.AddScoped<OrderNotifier>();
builder.Services.AddScoped<OrderService>();
builder.Services.AddScoped<CanteenService>();
builder.Services.AddHostedService<OrderExpiryService>();
builder.Services.AddSignalR()
    .AddJsonProtocol(o => o.PayloadSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

// Enums go over the wire as text ("Ready"), not numbers (3): readable and safe to reorder.
builder.Services.AddControllers()
    .AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()))
    // Malformed JSON / missing fields → the same envelope instead of the default ProblemDetails.
    .ConfigureApiBehaviorOptions(o => o.InvalidModelStateResponseFactory = _ =>
        Result<object?>.Fail(CommonErrors.Validation).ToActionResult());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(o =>
{
    // "Authorize" button in Swagger UI: paste an access token to call protected endpoints.
    o.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
    });
    o.AddSecurityRequirement(doc => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", doc)] = [],
    });
});

var app = builder.Build();

await DbSeeder.SeedAsync(app.Services);

// Unhandled exception → 500 in the envelope (details go to the log, not to the client).
app.UseExceptionHandler(e => e.Run(ctx => WriteError(ctx.Response, CommonErrors.ServerError)));
// Unknown URL → 404 in the envelope.
app.UseStatusCodePages(ctx => ctx.HttpContext.Response.StatusCode == 404
    ? WriteError(ctx.HttpContext.Response, CommonErrors.NotFound)
    : Task.CompletedTask);

// Dish photos: files in wwwroot/ are served as-is, e.g. /images/dishes/5-ab12.jpg
app.UseStaticFiles();

// Swagger stays on: it doubles as API documentation for the coursework report.
app.UseSwagger();
app.UseSwaggerUI();
// Opening the bare server address (http://localhost:5041) lands on Swagger.
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<OrdersHub>("/hubs/orders");

app.Run();

static Task WriteError(HttpResponse response, Error error)
{
    if (response.HasStarted) return Task.CompletedTask;
    response.StatusCode = error.Status;
    return response.WriteAsJsonAsync(Result<object?>.Fail(error));
}
