namespace Ecommerce.Domain.Entities;

public class CartItem
{
    public long Id { get; set; }

    public long CartId { get; set; }

    public long ProductId { get; set; }

    public int Quantity { get; set; } = 1;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Cart Cart { get; set; } = null!;

    public Product Product { get; set; } = null!;
}