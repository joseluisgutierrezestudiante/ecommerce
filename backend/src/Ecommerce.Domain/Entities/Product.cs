using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ecommerce.Domain.Entities;

public class Product
{
    public long Id { get; set; }

    public int CategoryId { get; set; }

    [Required]
    [MaxLength(50)]
    public string Sku { get; set; } = string.Empty;

    [Required]
    [MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(170)]
    public string Slug { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    [Column(TypeName = "decimal(12,2)")]
    [Range(0, double.MaxValue)]
    public decimal Price { get; set; }

    [Column(TypeName = "decimal(12,2)")]
    [Range(0, double.MaxValue)]
    public decimal? CompareAtPrice { get; set; }

    [Range(0, int.MaxValue)]
    public int Stock { get; set; }

    [MaxLength(500)]
    public string? ImageCoverUrl { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Category Category { get; set; } = null!;

    public ICollection<ProductImage> Images { get; set; } = [];

    public ICollection<CartItem> CartItems { get; set; } = [];

    public ICollection<OrderItem> OrderItems { get; set; } = [];

    public ICollection<Review> Reviews { get; set; } = [];
}