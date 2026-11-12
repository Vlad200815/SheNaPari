using System.Net.Mail;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Employees;

/// Staff accounts. Who may manage whom:
///   Admin      → Cooks
///   SuperAdmin → Cooks and Admins
/// Nobody can create or touch a SuperAdmin through the API (it comes from configuration).
public class EmployeeService(AppDbContext db, PasswordService passwords, TimeProvider clock)
{
    public async Task<List<EmployeeDto>> GetAllAsync()
    {
        var list = await db.Employees.OrderBy(e => e.Role).ThenBy(e => e.Email).ToListAsync();
        return list.Select(ToDto).ToList();
    }

    public async Task<Result<EmployeeDto>> CreateAsync(UserRole actorRole, CreateEmployeeDto dto)
    {
        if (dto.Role is not (UserRole.Cook or UserRole.Admin)) return EmployeeErrors.InvalidRole;
        if (!CanManage(actorRole, dto.Role)) return EmployeeErrors.NotAllowed;

        var email = dto.Email.Trim().ToLowerInvariant();
        if (!MailAddress.TryCreate(email, out _)) return EmployeeErrors.InvalidEmail;
        var name = dto.Name.Trim();
        if (name.Length is < 2 or > 100) return EmployeeErrors.InvalidName;
        if (dto.Password.Length < PasswordService.MinLength) return EmployeeErrors.WeakPassword;
        if (await db.Employees.AnyAsync(e => e.Email == email)) return EmployeeErrors.EmailTaken;

        var employee = new Employee { Email = email, Name = name, Role = dto.Role, CreatedAt = clock.GetUtcNow() };
        employee.Credentials = new UserCredentials { PasswordHash = passwords.Hash(employee, dto.Password) };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();
        return ToDto(employee);
    }

    /// Switches the account off and signs it out everywhere (all refresh tokens revoked).
    public async Task<Result<EmployeeDto>> DeactivateAsync(Guid actorId, UserRole actorRole, Guid id)
    {
        if (id == actorId) return EmployeeErrors.CannotChangeSelf;
        var (employee, error) = await FindManageableAsync(actorRole, id);
        if (employee is null) return error!;

        employee.DeactivatedAt ??= clock.GetUtcNow();
        await RevokeSessionsAsync(id);
        await db.SaveChangesAsync();
        return ToDto(employee);
    }

    public async Task<Result<EmployeeDto>> ActivateAsync(UserRole actorRole, Guid id)
    {
        var (employee, error) = await FindManageableAsync(actorRole, id);
        if (employee is null) return error!;

        employee.DeactivatedAt = null;
        await db.SaveChangesAsync();
        return ToDto(employee);
    }

    /// Admin sets a new password (there is no e-mail reset in the MVP); old sessions are closed.
    public async Task<Result<EmployeeDto>> SetPasswordAsync(UserRole actorRole, Guid id, string password)
    {
        if (password.Length < PasswordService.MinLength) return EmployeeErrors.WeakPassword;
        var (employee, error) = await FindManageableAsync(actorRole, id);
        if (employee is null) return error!;

        var hash = passwords.Hash(employee, password);
        if (employee.Credentials is null) employee.Credentials = new UserCredentials { PasswordHash = hash };
        else employee.Credentials.PasswordHash = hash;
        await RevokeSessionsAsync(id);
        await db.SaveChangesAsync();
        return ToDto(employee);
    }

    private async Task<(Employee?, Error?)> FindManageableAsync(UserRole actorRole, Guid id)
    {
        var employee = await db.Employees.Include(e => e.Credentials).FirstOrDefaultAsync(e => e.Id == id);
        if (employee is null) return (null, EmployeeErrors.NotFound);
        if (!CanManage(actorRole, employee.Role)) return (null, EmployeeErrors.NotAllowed);
        return (employee, null);
    }

    private static bool CanManage(UserRole actor, UserRole target) => (actor, target) switch
    {
        (UserRole.SuperAdmin, UserRole.Cook or UserRole.Admin) => true,
        (UserRole.Admin, UserRole.Cook) => true,
        _ => false,
    };

    private Task RevokeSessionsAsync(Guid userId)
    {
        var now = clock.GetUtcNow();
        return db.RefreshTokens
            .Where(t => t.UserId == userId && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedAt, now));
    }

    private static EmployeeDto ToDto(Employee e) => new(e.Id, e.Email, e.Name, e.Role, e.IsActive, e.CreatedAt);
}
