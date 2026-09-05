using System.ComponentModel.DataAnnotations.Schema;

namespace Ecommerce.Domain.Entities;

public static class PaymentStatus
{
    public const string Pending = "Pending";
    public const string Approved = "Approved";
    public const string Declined = "Declined";
    public const string Refunded = "Refunded";
}

public class Payment
{
    public long Id { get; set; }

    public long OrderId { get; set; }

    public string Method { get; set; } = string.Empty;

    [Column(TypeName = "decimal(12,2)")]
    public decimal Amount { get; set; }

    public string? TransactionId { get; set; }

    public string Status { get; set; } = PaymentStatus.Pending;

    public DateTime? PaidAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Order Order { get; set; } = null!;
}