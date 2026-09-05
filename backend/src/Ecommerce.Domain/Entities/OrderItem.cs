using System.ComponentModel.DataAnnotations.Schema;

namespace Ecommerce.Domain.Entities;

public class OrderItem
{
    public long Id { get; set; }

    public long OrderId { get; set; }

    public long ProductId { get; set; }

    public string ProductSku { get; set; } = string.Empty;

    public string ProductNameSnapshot { get; set; } = string.Empty;

    [Column(TypeName = "decimal(12,2)")]
    public decimal UnitPrice { get; set; }

    public int Quantity { get; set; }

    [Column(TypeName = "decimal(12,2)")]
    public decimal LineTotal { get; set; }

    public Order Order { get; set; } = null!;

    public Product Product { get; set; } = null!;
}