# E-Commerce

E-commerce profesional en desarrollo. Backend: **ASP.NET Core Web API (.NET 10)** con arquitectura en capas y **MySQL** como base de datos.

## Estado actual

- ✅ Proyecto Web API listo y funcionando
- ✅ Arquitectura por capas (Domain / Application / Infrastructure / API)
- ✅ CRUD de productos completo con Swagger
- ✅ Base de datos MySQL con migraciones EF Core

## Estructura

```
backend/
├── Ecommerce.slnx
└── src/
    ├── Ecommerce.Domain/          → Entidades (núcleo, sin dependencias)
    ├── Ecommerce.Application/     → DTOs, servicios, reglas de negocio
    ├── Ecommerce.Infrastructure/  → EF Core, repositorios, migraciones
    └── Ecommerce.Api/             → Web API (controllers, configuración)
```

## Requisitos

- .NET SDK 10
- MySQL Server 8+ (corriendo en localhost:3306)
- VS Code con extensiones C# Dev Kit

## Configuración inicial

1. Crea la base de datos en MySQL:
   ```sql
   CREATE DATABASE IF NOT EXISTS ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. Configura la cadena de conexión en **user-secrets** (no se sube a git):
   ```powershell
   cd backend/src/Ecommerce.Api
   dotnet user-secrets init
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=localhost;Port=3306;Database=ecommerce;User=root;Password=TU_CLAVE;"
   ```

3. Aplica las migraciones:
   ```powershell
   cd backend
   dotnet ef database update --project src/Ecommerce.Infrastructure --startup-project src/Ecommerce.Api
   ```

## Ejecutar

```powershell
cd backend
dotnet run --project src/Ecommerce.Api
```

Abre **http://localhost:5179/swagger/index.html** para probar los endpoints.

## Endpoints actuales

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/products` | Lista productos activos |
| GET | `/api/products/{id}` | Producto por id |
| POST | `/api/products` | Crear producto |
| PUT | `/api/products/{id}` | Actualizar producto |
| DELETE | `/api/products/{id}` | Eliminar producto |

## Roadmap

- [ ] Autenticación JWT + roles (Admin/Cliente)
- [ ] Categorías
- [ ] Carrito de compras
- [ ] Órdenes
- [ ] Pago (simulado)
- [ ] Frontend (HTML/CSS/JS)