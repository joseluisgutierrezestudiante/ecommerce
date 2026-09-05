# E-Commerce

E-commerce profesional en desarrollo. Backend: **ASP.NET Core Web API (.NET 10)** con arquitectura en capas y **MySQL** como base de datos.

## Estado actual

- ✅ Proyecto Web API listo y funcionando
- ✅ Arquitectura por capas (Domain / Application / Infrastructure / API)
- ✅ CRUD de productos completo con Swagger
- ✅ Base de datos MySQL con migraciones EF Core
- ✅ Esquema relacional completo: 12 tablas (roles, users, categories, products, productimages, addresses, carts, cartitems, orders, orderitems, payments, reviews) con FKs, índices estratégicos (incl. FULLTEXT) y restricciones CHECK
- ✅ Scripts de gestión de BD para terminal (misma base que administra MySQL Workbench)

## Estructura

```
backend/
├── Ecommerce.slnx
├── database/                    → SQL/scripts de la base de datos
│   ├── ecommerce_schema.sql     → diseño de referencia del esquema
│   ├── seed.sql                 → datos de demostración (roles, productos, órdenes…)
│   └── er-diagram.md            → diagrama entidad-relación (Mermaid)
├── scripts/                     → utilidades CLI para la BD
│   ├── mysql.ps1                → cliente MySQL seguro (consultas/archivos SQL)
│   └── db-info.ps1              → resumen profesional del estado de la BD
└── src/
    ├── Ecommerce.Domain/          → Entidades (núcleo, sin dependencias)
    ├── Ecommerce.Application/     → DTOs, servicios, reglas de negocio
    ├── Ecommerce.Infrastructure/  → EF Core, repositorios, migraciones
    └── Ecommerce.Api/             → Web API (controllers, configuración)
```

## Base de datos

### Conexión en MySQL Workbench (GUI)

Servidor MySQL escucha en `127.0.0.1:3306` (Windows local, para Workbench usar `localhost`).

| Parámetro | Valor |
|---|---|
| Connection Method | Standard (TCP/IP) |
| Hostname | `127.0.0.1` |
| Port | `3306` |
| Username | `root` |
| Password | (la de tu servidor MySQL local) |
| Default Schema | `ecommerce` |

En Workbench: **Database → Manage Connections** → `+` → introduce los datos → Test Connection.

### Conexión desde la terminal / opencode (CLI)

Los scripts de `backend/scripts/` conectan a la **misma base** que administras en
Workbench, gestionando la contraseña de forma segura:

```powershell
cd backend

# Consulta libre
.\scripts\mysql.ps1 -Sql "SELECT * FROM categories;"

# Ejecutar un archivo SQL
.\scripts\mysql.ps1 -File .\database\seed.sql

# Resumen del estado de la base (tablas, filas, motor)
.\scripts\db-info.ps1
.\scripts\db-info.ps1 -Full     # añade columnas e índices
```

La contraseña se toma de la variable de entorno `MYSQL_PWD`, del parámetro
`-Password`, o se pide interactivamente. **Nunca** se almacena en el repositorio.

### Datos de demostración

Carga roles, usuarios, categorías, 5 productos, imágenes, carrito, una orden
completa con pago y reseñas:

```powershell
cd backend
.\scripts\mysql.ps1 -File .\database\seed.sql
```

> El script se ejecuta sobre un esquema **vacío** (falla si ya hay datos por las
> restricciones UNIQUE, a propósito). Ver el diagrama ER en `database/er-diagram.md`.

### Esquema vigente

El esquema real es generado y versionado por **EF Core** (migración `InitialCreate`),
no por el script SQL (que queda como diseño de referencia). Para regenerarlo:

```powershell
cd backend
$env:MYSQL_PWD = "tu-clave"

# Si cambias las entidades:
dotnet ef migrations add NombreDeLaMigracion --project src/Ecommerce.Infrastructure --startup-project src/Ecommerce.Api

# Aplicar migraciones pendientes:
dotnet ef database update --project src/Ecommerce.Infrastructure --startup-project src/Ecommerce.Api
```

## Requisitos

- .NET SDK 10
- MySQL Server 8+ (corriendo en localhost:3306)
- MySQL Workbench (opcional, para gestión visual)
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