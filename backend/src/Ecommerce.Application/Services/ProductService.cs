using Ecommerce.Application.DTOs;
using Ecommerce.Domain.Entities;

namespace Ecommerce.Application.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _repository;

    public ProductService(IProductRepository repository)
    {
        _repository = repository;
    }

    public async Task<IReadOnlyList<ProductResponseDto>> GetAllAsync()
    {
        var products = await _repository.GetAllAsync();
        return products.Select(ToDto).ToList();
    }

    public async Task<ProductResponseDto?> GetByIdAsync(long id)
    {
        var product = await _repository.GetByIdAsync(id);
        return product is null ? null : ToDto(product);
    }

    public async Task<ProductResponseDto?> CreateAsync(CreateProductDto dto)
    {
        if (!await _repository.CategoryExistsAsync(dto.CategoryId))
            return null;

        var product = new Product
        {
            CategoryId = dto.CategoryId,
            Sku = dto.Sku,
            Name = dto.Name,
            Slug = dto.Name.ToLowerInvariant().Replace(" ", "-"),
            Description = dto.Description,
            Price = dto.Price,
            CompareAtPrice = dto.CompareAtPrice,
            Stock = dto.Stock,
            ImageCoverUrl = dto.ImageCoverUrl,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(product);
        return ToDto(created);
    }

    public async Task<bool> UpdateAsync(long id, UpdateProductDto dto)
    {
        var product = await _repository.GetByIdAsync(id);

        if (product is null || !await _repository.CategoryExistsAsync(dto.CategoryId))
            return false;

        product.CategoryId = dto.CategoryId;
        product.Sku = dto.Sku;
        product.Name = dto.Name;
        product.Slug = dto.Name.ToLowerInvariant().Replace(" ", "-");
        product.Description = dto.Description;
        product.Price = dto.Price;
        product.CompareAtPrice = dto.CompareAtPrice;
        product.Stock = dto.Stock;
        product.ImageCoverUrl = dto.ImageCoverUrl;
        product.IsActive = dto.IsActive;
        product.UpdatedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(product);
        return true;
    }

    public async Task<bool> DeleteAsync(long id)
    {
        var product = await _repository.GetByIdAsync(id);

        if (product is null)
            return false;

        // Borrado lógico: preserva historial de ventas y reseñas (RESTRICT físico)
        product.IsActive = false;
        product.UpdatedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(product);
        return true;
    }

    private static ProductResponseDto ToDto(Product p) => new(
        p.Id,
        p.CategoryId,
        p.Category?.Name ?? string.Empty,
        p.Sku,
        p.Name,
        p.Slug,
        p.Description,
        p.Price,
        p.CompareAtPrice,
        p.Stock,
        p.ImageCoverUrl,
        p.IsActive,
        p.CreatedAt,
        p.UpdatedAt);
}