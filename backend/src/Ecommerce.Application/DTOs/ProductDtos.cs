using System.ComponentModel.DataAnnotations;

namespace Ecommerce.Application.DTOs;

public record CreateProductDto(
    [Required, MaxLength(150)] string Name,
    [MaxLength(500)] string? Description,
    [Range(0.01, double.MaxValue)] decimal Price,
    [Required, MaxLength(100)] string Category,
    string? ImageUrl,
    [Range(0, int.MaxValue)] int Stock);

public record UpdateProductDto(
    [Required, MaxLength(150)] string Name,
    [MaxLength(500)] string? Description,
    [Range(0.01, double.MaxValue)] decimal Price,
    [Required, MaxLength(100)] string Category,
    string? ImageUrl,
    [Range(0, int.MaxValue)] int Stock,
    bool IsActive);

public record ProductResponseDto(
    int Id,
    string Name,
    string? Description,
    decimal Price,
    string Category,
    string? ImageUrl,
    int Stock,
    bool IsActive,
    DateTime CreatedAt,
    DateTime UpdatedAt);