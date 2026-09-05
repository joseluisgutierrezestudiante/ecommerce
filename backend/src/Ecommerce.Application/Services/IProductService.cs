using Ecommerce.Application.DTOs;

namespace Ecommerce.Application.Services;

public interface IProductService
{
    Task<IReadOnlyList<ProductResponseDto>> GetAllAsync();
    Task<ProductResponseDto?> GetByIdAsync(int id);
    Task<ProductResponseDto> CreateAsync(CreateProductDto dto);
    Task<bool> UpdateAsync(int id, UpdateProductDto dto);
    Task<bool> DeleteAsync(int id);
}