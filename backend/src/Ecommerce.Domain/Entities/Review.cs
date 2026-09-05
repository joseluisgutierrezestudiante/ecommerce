namespace Ecommerce.Domain.Entities;

public class Review
{
    public long Id { get; set; }

    public long ProductId { get; set; }

    public long UserId { get; set; }

    public byte Rating { get; set; }

    public string? Comment { get; set; }

    public bool IsApproved { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Product Product { get; set; } = null!;

    public User User { get; set; } = null!;
}