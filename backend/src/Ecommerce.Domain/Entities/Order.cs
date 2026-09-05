namespace Ecommerce.Domain.Entities;

public static class OrderStatus
{
    public const string Pending = "Pending";
    public const string Paid = "Paid";
    public const string Shipped = "Shipped";
    public const string Delivered = "Delivered";
    public const string Cancelled = "Cancelled";
}

public class Order
{
    public long Id { get; set; }

    public long UserId { get; set; }

    public string OrderNumber { get; set; } = string.Empty;

    public string Status { get; set; } = OrderStatus.Pending;

    public decimal Subtotal { get; set; }

    public decimal ShippingCost { get; set; }

    public decimal Tax { get; set; }

    public decimal Total { get; set; }

    public long? ShippingAddressId { get; set; }

    public string? ShipFirstName { get; set; }

    public string? ShipLastName { get; set; }

    public string? ShipStreet { get; set; }

    public string? ShipCity { get; set; }

    public string? ShipState { get; set; }

    public string? ShipPostalCode { get; set; }

    public string? ShipCountry { get; set; }

    public DateTime? PaidAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;

    public Address? ShippingAddress { get; set; }

    public ICollection<OrderItem> Items { get; set; } = [];

    public ICollection<Payment> Payments { get; set; } = [];
}