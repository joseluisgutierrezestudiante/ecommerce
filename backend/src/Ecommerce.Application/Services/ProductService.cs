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

    public async Task<ProductResponseDto?> GetByIdAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        return product is null ? null : ToDto(product);
    }

    public async Task<ProductResponseDto> CreateAsync(CreateProductDto dto)
    {
        var product = new Product
        {
            Name = dto.Name,
            Description = dto.Description,
            Price = dto.Price,
            Category = dto.Category,
            ImageUrl = dto.ImageUrl,
            Stock = dto.Stock,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(product);
        return ToDto(created);
    }

    public async Task<bool> UpdateAsync(int id, UpdateProductDto dto)
    {
        var product = await _repository.GetByIdAsync(id);

        if (product is null)
            return false;

        product.Name = dto.Name;
        product.Description = dto.Description;
        product.Price = dto.Price;
        product.Category = dto.Category;
        product.ImageUrl = dto.ImageUrl;
        product.Stock = dto.Stock;
        product.IsActive = dto.IsActive;
        product.UpdatedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(product);
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);

        if (product is null)
            return false;

        await _repository.DeleteAsync(product);
        return true;
    }

    private static ProductResponseDto ToDto(Product product) => new(
        product.Id,
        product.Name,
        product.Description,
        product.Price,
        product.Category,
        product.ImageUrl,
        product.Stock,
        product.IsActive,
        product.CreatedAt,
        product.UpdatedAt);
}