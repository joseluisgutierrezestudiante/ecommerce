using Ecommerce.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ecommerce.Infrastructure.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductImage> ProductImages => Set<ProductImage>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Review> Reviews => Set<Review>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        ConfigureRoles(builder);
        ConfigureUsers(builder);
        ConfigureCategories(builder);
        ConfigureProducts(builder);
        ConfigureProductImages(builder);
        ConfigureAddresses(builder);
        ConfigureCarts(builder);
        ConfigureCartItems(builder);
        ConfigureOrders(builder);
        ConfigureOrderItems(builder);
        ConfigurePayments(builder);
        ConfigureReviews(builder);
    }

    private static void ConfigureRoles(ModelBuilder b)
    {
        b.Entity<Role>(e =>
        {
            e.HasKey(r => r.Id);
            e.Property(r => r.Name).HasMaxLength(30);
            e.HasIndex(r => r.Name).IsUnique();
        });
    }

    private static void ConfigureUsers(ModelBuilder b)
    {
        b.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);
            e.Property(u => u.Email).HasMaxLength(190);
            e.Property(u => u.PasswordHash).HasMaxLength(255);
            e.Property(u => u.FirstName).HasMaxLength(80);
            e.Property(u => u.LastName).HasMaxLength(80);
            e.Property(u => u.Phone).HasMaxLength(30);
            e.HasIndex(u => u.Email).IsUnique();

            // Índice estratégico: reportes de usuarios activos por rol
            e.HasIndex(u => new { u.RoleId, u.IsActive });

            e.HasOne(u => u.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(u => u.RoleId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureCategories(ModelBuilder b)
    {
        b.Entity<Category>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Name).HasMaxLength(100);
            e.Property(c => c.Slug).HasMaxLength(120);
            e.Property(c => c.Description).HasMaxLength(500);
            e.HasIndex(c => c.Name).IsUnique();
            e.HasIndex(c => c.Slug).IsUnique();

            // Índice: búsqueda frecuente de subcategorías
            e.HasIndex(c => c.ParentId);

            e.HasOne(c => c.Parent)
                .WithMany(c => c.Children)
                .HasForeignKey(c => c.ParentId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureProducts(ModelBuilder b)
    {
        b.Entity<Product>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.Sku).HasMaxLength(50);
            e.Property(p => p.Name).HasMaxLength(150);
            e.Property(p => p.Slug).HasMaxLength(170);
            e.Property(p => p.Description).HasMaxLength(1000);
            e.Property(p => p.Price).HasPrecision(12, 2);
            e.Property(p => p.CompareAtPrice).HasPrecision(12, 2);
            e.Property(p => p.ImageCoverUrl).HasMaxLength(500);

            e.HasIndex(p => p.Sku).IsUnique();
            e.HasIndex(p => p.Slug).IsUnique();

            // ÍNDICES ESTRATÉGICOS para búsqueda frecuente de productos:
            e.HasIndex(p => new { p.CategoryId, p.IsActive }); // vitrina por categoría
            e.HasIndex(p => p.IsActive);                        // catálogo publicado
            e.HasIndex(p => p.UpdatedAt);                       // ordenar por novedad
            e.HasIndex(p => p.Price);                           // filtro por rango de precio
            // NOTE: índice FULLTEXT sobre (Name, Description) se crea con SQL directo en la migración.

            e.ToTable("Products", t =>
            {
                t.HasCheckConstraint("CHK_Products_Price", "Price >= 0");
                t.HasCheckConstraint("CHK_Products_ComparePrice", "CompareAtPrice IS NULL OR CompareAtPrice >= 0");
                t.HasCheckConstraint("CHK_Products_Stock", "Stock >= 0");
            });

            e.HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.Restrict); // categoría con productos no se borra
        });
    }

    private static void ConfigureProductImages(ModelBuilder b)
    {
        b.Entity<ProductImage>(e =>
        {
            e.HasKey(i => i.Id);
            e.Property(i => i.Url).HasMaxLength(500);

            e.HasIndex(i => i.ProductId);

            e.HasOne(i => i.Product)
                .WithMany(p => p.Images)
                .HasForeignKey(i => i.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureAddresses(ModelBuilder b)
    {
        b.Entity<Address>(e =>
        {
            e.HasKey(a => a.Id);
            e.Property(a => a.Street).HasMaxLength(150);
            e.Property(a => a.City).HasMaxLength(80);
            e.Property(a => a.State).HasMaxLength(80);
            e.Property(a => a.PostalCode).HasMaxLength(20);
            e.Property(a => a.Country).HasMaxLength(60);

            e.HasIndex(a => a.UserId);

            e.HasOne(a => a.User)
                .WithMany(u => u.Addresses)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureCarts(ModelBuilder b)
    {
        b.Entity<Cart>(e =>
        {
            e.HasKey(c => c.Id);

            // 1 carrito activo por usuario
            e.HasIndex(c => c.UserId).IsUnique();

            e.HasOne(c => c.User)
                .WithOne(u => u.Cart)
                .HasForeignKey<Cart>(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureCartItems(ModelBuilder b)
    {
        b.Entity<CartItem>(e =>
        {
            e.HasKey(i => i.Id);

            e.HasIndex(i => i.ProductId);
            e.HasIndex(i => new { i.CartId, i.ProductId }).IsUnique();

            e.ToTable("CartItems", t => t
                .HasCheckConstraint("CHK_CartItems_Quantity", "Quantity > 0"));

            e.HasOne(i => i.Cart)
                .WithMany(c => c.Items)
                .HasForeignKey(i => i.CartId)
                .OnDelete(DeleteBehavior.Cascade); // sin carrito no hay items

            e.HasOne(i => i.Product)
                .WithMany(p => p.CartItems)
                .HasForeignKey(i => i.ProductId)
                .OnDelete(DeleteBehavior.Restrict); // nunca romper referencia al producto
        });
    }

    private static void ConfigureOrders(ModelBuilder b)
    {
        b.Entity<Order>(e =>
        {
            e.HasKey(o => o.Id);
            e.Property(o => o.OrderNumber).HasMaxLength(20);
            e.Property(o => o.Status).HasMaxLength(20);
            e.Property(o => o.Subtotal).HasPrecision(12, 2);
            e.Property(o => o.ShippingCost).HasPrecision(12, 2);
            e.Property(o => o.Tax).HasPrecision(12, 2);
            e.Property(o => o.Total).HasPrecision(12, 2);
            e.Property(o => o.ShipFirstName).HasMaxLength(80);
            e.Property(o => o.ShipLastName).HasMaxLength(80);
            e.Property(o => o.ShipStreet).HasMaxLength(150);
            e.Property(o => o.ShipCity).HasMaxLength(80);
            e.Property(o => o.ShipState).HasMaxLength(80);
            e.Property(o => o.ShipPostalCode).HasMaxLength(20);
            e.Property(o => o.ShipCountry).HasMaxLength(60);

            e.HasIndex(o => o.OrderNumber).IsUnique();

            // Índices de consultas frecuentes: historial del usuario + estado
            e.HasIndex(o => new { o.UserId, o.CreatedAt });
            e.HasIndex(o => o.Status);

            e.ToTable("Orders", t =>
            {
                t.HasCheckConstraint("CHK_Orders_Subtotal", "Subtotal >= 0");
                t.HasCheckConstraint("CHK_Orders_Total", "Total >= 0");
                t.HasCheckConstraint("CHK_Orders_Status", "Status IN ('Pending','Paid','Shipped','Delivered','Cancelled')");
            });

            e.HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict); // historial de compras no se borra

            e.HasOne(o => o.ShippingAddress)
                .WithMany()
                .HasForeignKey(o => o.ShippingAddressId)
                .OnDelete(DeleteBehavior.SetNull); // la orden sobrevive si borran la dirección
        });
    }

    private static void ConfigureOrderItems(ModelBuilder b)
    {
        b.Entity<OrderItem>(e =>
        {
            e.HasKey(i => i.Id);
            e.Property(i => i.ProductSku).HasMaxLength(50);
            e.Property(i => i.ProductNameSnapshot).HasMaxLength(150);
            e.Property(i => i.UnitPrice).HasPrecision(12, 2);
            e.Property(i => i.LineTotal).HasPrecision(12, 2);

            e.HasIndex(i => i.OrderId);
            e.HasIndex(i => i.ProductId);

            e.ToTable("OrderItems", t =>
            {
                t.HasCheckConstraint("CHK_OrderItems_Quantity", "Quantity > 0");
                t.HasCheckConstraint("CHK_OrderItems_UnitPrice", "UnitPrice >= 0");
                t.HasCheckConstraint("CHK_OrderItems_LineTotal", "LineTotal >= 0");
            });

            e.HasOne(i => i.Order)
                .WithMany(o => o.Items)
                .HasForeignKey(i => i.OrderId)
                .OnDelete(DeleteBehavior.Cascade); // items son parte de la orden

            e.HasOne(i => i.Product)
                .WithMany(p => p.OrderItems)
                .HasForeignKey(i => i.ProductId)
                .OnDelete(DeleteBehavior.Restrict); // auditoría de ventas intacta
        });
    }

    private static void ConfigurePayments(ModelBuilder b)
    {
        b.Entity<Payment>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.Method).HasMaxLength(20);
            e.Property(p => p.Amount).HasPrecision(12, 2);
            e.Property(p => p.TransactionId).HasMaxLength(100);
            e.Property(p => p.Status).HasMaxLength(20);

            e.HasIndex(p => p.OrderId);
            e.HasIndex(p => p.TransactionId).IsUnique();

            e.ToTable("Payments", t =>
            {
                t.HasCheckConstraint("CHK_Payments_Amount", "Amount >= 0");
                t.HasCheckConstraint("CHK_Payments_Status", "Status IN ('Pending','Approved','Declined','Refunded')");
            });

            e.HasOne(p => p.Order)
                .WithMany(o => o.Payments)
                .HasForeignKey(p => p.OrderId)
                .OnDelete(DeleteBehavior.Restrict); // pagos nunca se eliminan
        });
    }

    private static void ConfigureReviews(ModelBuilder b)
    {
        b.Entity<Review>(e =>
        {
            e.HasKey(r => r.Id);
            e.Property(r => r.Comment).HasMaxLength(1000);

            e.HasIndex(r => new { r.ProductId, r.IsApproved });
            e.HasIndex(r => new { r.ProductId, r.UserId }).IsUnique(); // 1 reseña por usuario y producto

            e.ToTable("Reviews", t => t
                .HasCheckConstraint("CHK_Reviews_Rating", "Rating BETWEEN 1 AND 5"));

            e.HasOne(r => r.Product)
                .WithMany(p => p.Reviews)
                .HasForeignKey(r => r.ProductId)
                .OnDelete(DeleteBehavior.Cascade); // reseñas mueren con el producto

            e.HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}