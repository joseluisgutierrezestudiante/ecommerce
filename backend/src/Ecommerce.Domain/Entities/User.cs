namespace Ecommerce.Domain.Entities;

public class User
{
    public long Id { get; set; }

    public int RoleId { get; set; }

    public string Email { get; set; } = string.Empty;

    public string PasswordHash { get; set; } = string.Empty;

    public string FirstName { get; set; } = string.Empty;

    public string LastName { get; set; } = string.Empty;

    public string? Phone { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Role Role { get; set; } = null!;

    public Cart? Cart { get; set; }

    public ICollection<Address> Addresses { get; set; } = [];

    public ICollection<Order> Orders { get; set; } = [];

    public ICollection<Review> Reviews { get; set; } = [];
}