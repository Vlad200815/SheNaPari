using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<UserCredentials> UserCredentials => Set<UserCredentials>();
    public DbSet<VerificationCode> VerificationCodes => Set<VerificationCode>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Dish> Dishes => Set<Dish>();
    public DbSet<BellSchedule> BellSchedules => Set<BellSchedule>();
    public DbSet<BreakSlot> BreakSlots => Set<BreakSlot>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<OrderStatusChange> OrderStatusChanges => Set<OrderStatusChange>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Canteen> Canteens => Set<Canteen>();

    protected override void ConfigureConventions(ModelConfigurationBuilder c)
    {
        // SQLite has no native date/time or decimal types, so EF Core cannot
        // compare or ORDER BY DateTimeOffset/decimal columns inside a query.
        // Storing them as numbers fixes that:
        //  - DateTimeOffset → long (UTC ticks), sortable and comparable
        //  - decimal → double, fine for canteen prices (2 decimals)
        c.Properties<DateTimeOffset>().HaveConversion<DateTimeOffsetToBinaryConverter>();
        c.Properties<decimal>().HaveConversion<double>();
    }

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>(e =>
        {
            e.Property(u => u.Name).HasMaxLength(100);
            e.Property(u => u.Role).HasConversion<string>().HasMaxLength(20);
        });

        // Unique indexes ignore NULLs, so employees (no phone) and customers (no e-mail)
        // can share the Users table.
        b.Entity<Customer>(e =>
        {
            e.HasIndex(c => c.Phone).IsUnique();
            e.Property(c => c.Phone).HasMaxLength(20);
        });

        b.Entity<Employee>(e =>
        {
            e.HasIndex(x => x.Email).IsUnique();
            e.Property(x => x.Email).HasMaxLength(200);
            e.HasOne(x => x.Credentials).WithOne()
                .HasForeignKey<UserCredentials>(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        b.Entity<UserCredentials>(e => e.HasKey(c => c.UserId));

        b.Entity<VerificationCode>(e =>
        {
            e.HasIndex(o => o.Phone);
            e.Property(o => o.Phone).HasMaxLength(20);
        });

        b.Entity<RefreshToken>(e =>
        {
            e.HasIndex(t => t.TokenHash).IsUnique();
            e.HasIndex(t => t.PushToken);
            e.Property(t => t.PushToken).HasMaxLength(500);
        });

        b.Entity<BellSchedule>(e =>
        {
            e.HasIndex(s => s.Name).IsUnique();
            e.Property(s => s.Name).HasMaxLength(100);
            e.HasMany(s => s.Breaks).WithOne().HasForeignKey(x => x.BellScheduleId).OnDelete(DeleteBehavior.Cascade);
        });

        b.Entity<BreakSlot>(e => e.HasIndex(s => s.StartsAt));

        b.Entity<Category>(e => e.Property(c => c.Name).HasMaxLength(100));

        b.Entity<Dish>(e =>
        {
            e.Property(d => d.Name).HasMaxLength(200);
            e.Property(d => d.Price).HasPrecision(10, 2);
        });

        b.Entity<Order>(e =>
        {
            e.HasIndex(o => o.PickupToken).IsUnique();
            e.Property(o => o.Total).HasPrecision(10, 2);
            // Stored as text so the DB is readable in psql/pgAdmin.
            e.Property(o => o.Status).HasConversion<string>().HasMaxLength(20);
            e.HasIndex(o => o.Status);
            e.HasIndex(o => o.CreatedAt);
            e.HasMany(o => o.StatusChanges).WithOne().HasForeignKey(c => c.OrderId).OnDelete(DeleteBehavior.Cascade);
            e.HasMany(o => o.Payments).WithOne().HasForeignKey(p => p.OrderId).OnDelete(DeleteBehavior.Cascade);
        });

        b.Entity<OrderItem>(e =>
        {
            e.Property(i => i.UnitPrice).HasPrecision(10, 2);
            e.Property(i => i.NameSnapshot).HasMaxLength(200);
        });

        b.Entity<OrderStatusChange>(e =>
        {
            e.Property(c => c.Status).HasConversion<string>().HasMaxLength(20);
            e.Property(c => c.Reason).HasMaxLength(300);
        });

        b.Entity<Payment>(e =>
        {
            e.Property(p => p.Amount).HasPrecision(10, 2);
            e.Property(p => p.Provider).HasConversion<string>().HasMaxLength(20);
            e.Property(p => p.Status).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<Canteen>(e => e.Property(c => c.Name).HasMaxLength(100));
    }
}
