using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<OtpCode> OtpCodes => Set<OtpCode>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Dish> Dishes => Set<Dish>();
    public DbSet<BreakSlot> BreakSlots => Set<BreakSlot>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>(e =>
        {
            e.HasIndex(u => u.Phone).IsUnique();
            e.Property(u => u.Phone).HasMaxLength(20);
            e.Property(u => u.Name).HasMaxLength(100);
            e.Property(u => u.Role).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<OtpCode>(e =>
        {
            e.HasIndex(o => o.Phone);
            e.Property(o => o.Phone).HasMaxLength(20);
        });

        b.Entity<RefreshToken>(e =>
        {
            e.HasIndex(t => t.TokenHash).IsUnique();
        });

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
        });

        b.Entity<OrderItem>(e => e.Property(i => i.UnitPrice).HasPrecision(10, 2));
    }
}
