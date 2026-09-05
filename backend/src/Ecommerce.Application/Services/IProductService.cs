using Ecommerce.Application.DTOs;

namespace Ecommerce.Application.Services;

public interface IProductService
{
    Task<IReadOnlyList<ProductResponseDto>> GetAllAsync();
    Task<ProductResponseDto?> GetByIdAsync(long id);
    Task<ProductResponseDto?> CreateAsync(CreateProductDto dto);
    Task<bool> UpdateAsync(long id, UpdateProductDto dto);
    Task<bool> DeleteAsync(long id);
}