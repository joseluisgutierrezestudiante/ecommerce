using Ecommerce.Domain.Entities;

namespace Ecommerce.Application.Services;

public interface IProductRepository
{
    Task<IReadOnlyList<Product>> GetAllAsync();
    Task<Product?> GetByIdAsync(long id);
    Task<bool> CategoryExistsAsync(int categoryId);
    Task<Product> AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(Product product);
}