using System.ComponentModel.DataAnnotations;

namespace Ecommerce.Application.DTOs;

public record CreateProductDto(
    int CategoryId,
    [Required, MaxLength(50)] string Sku,
    [Required, MaxLength(150)] string Name,
    [MaxLength(1000)] string? Description,
    [Range(0, double.MaxValue)] decimal Price,
    [Range(0, double.MaxValue)] decimal? CompareAtPrice,
    [Range(0, int.MaxValue)] int Stock,
    [MaxLength(500)] string? ImageCoverUrl);

public record UpdateProductDto(
    int CategoryId,
    [Required, MaxLength(50)] string Sku,
    [Required, MaxLength(150)] string Name,
    [MaxLength(1000)] string? Description,
    [Range(0, double.MaxValue)] decimal Price,
    [Range(0, double.MaxValue)] decimal? CompareAtPrice,
    [Range(0, int.MaxValue)] int Stock,
    [MaxLength(500)] string? ImageCoverUrl,
    bool IsActive);

public record ProductResponseDto(
    long Id,
    int CategoryId,
    string CategoryName,
    string Sku,
    string Name,
    string Slug,
    string? Description,
    decimal Price,
    decimal? CompareAtPrice,
    int Stock,
    string? ImageCoverUrl,
    bool IsActive,
    DateTime CreatedAt,
    DateTime UpdatedAt);