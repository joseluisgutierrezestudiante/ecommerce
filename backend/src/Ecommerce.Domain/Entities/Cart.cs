namespace Ecommerce.Domain.Entities;

public class Cart
{
    public long Id { get; set; }

    public long UserId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;

    public ICollection<CartItem> Items { get; set; } = [];
}