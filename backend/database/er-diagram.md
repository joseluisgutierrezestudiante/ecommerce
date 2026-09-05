# Diagrama Entidad-Relación

Esquema de la base de datos `ecommerce` (MySQL 8.0, InnoDB, generado y versionado por EF Core).

> **Cómo visualizarlo:**
> - En GitHub: el bloque Mermaid se renderiza solo en la vista previa del archivo.
> - En VS Code: extensión *Markdown Preview Mermaid Support* → vista previa.
> - En línea: copia el bloque Mermaid y pégalo en https://mermaid.live

```mermaid
erDiagram
    ROLES ||--o{ USERS : "pertenece a (RESTRICT)"

    USERS ||--o{ ADDRESSES : "tiene (CASCADE)"
    USERS ||--o| CARTS : "posee (CASCADE)"
    USERS ||--o{ ORDERS : "realiza (RESTRICT)"
    USERS ||--o{ REVIEWS : "escribe (RESTRICT)"

    CATEGORIES ||--o{ CATEGORIES : "subcategoría de (RESTRICT)"
    CATEGORIES ||--o{ PRODUCTS : "clasifica (RESTRICT)"

    PRODUCTS ||--o{ PRODUCTIMAGES : "fotos (CASCADE)"
    PRODUCTS ||--o{ ORDERITEMS : "vendido en (RESTRICT)"
    PRODUCTS ||--o{ CARTITEMS : "agregado al carrito (RESTRICT)"
    PRODUCTS ||--o{ REVIEWS : "reseñas (CASCADE)"

    CARTS ||--o{ CARTITEMS : "contiene (CASCADE)"

    ORDERS ||--o{ ORDERITEMS : "incluye (CASCADE)"
    ORDERS ||--o{ PAYMENTS : "pagos (RESTRICT)"
    ADDRESSES ||--o{ ORDERS : "envío (SET NULL)"

    ROLES {
        int Id PK
        string Name UK
    }

    USERS {
        bigint Id PK
        int RoleId FK
        string Email UK
        string PasswordHash
        string FirstName
        string LastName
        string Phone
        bool IsActive
        datetime CreatedAt
        datetime UpdatedAt
    }

    CATEGORIES {
        int Id PK
        int ParentId FK
        string Name UK
        string Slug UK
        string Description
        bool IsActive
        datetime CreatedAt
    }

    PRODUCTS {
        bigint Id PK
        int CategoryId FK
        string Sku UK
        string Name
        string Slug UK
        string Description
        decimal Price
        decimal CompareAtPrice
        int Stock
        string ImageCoverUrl
        bool IsActive
        datetime CreatedAt
        datetime UpdatedAt
    }

    PRODUCTIMAGES {
        bigint Id PK
        bigint ProductId FK
        string Url
        int SortOrder
        bool IsActive
    }

    ADDRESSES {
        bigint Id PK
        bigint UserId FK
        string Street
        string City
        string State
        string PostalCode
        string Country
        bool IsDefault
        datetime CreatedAt
    }

    CARTS {
        bigint Id PK
        bigint UserId FK UK
        datetime CreatedAt
        datetime UpdatedAt
    }

    CARTITEMS {
        bigint Id PK
        bigint CartId FK
        bigint ProductId FK
        int Quantity
        datetime CreatedAt
    }

    ORDERS {
        bigint Id PK
        bigint UserId FK
        bigint ShippingAddressId FK
        string OrderNumber UK
        string Status
        decimal Subtotal
        decimal ShippingCost
        decimal Tax
        decimal Total
        string ShipFirstName
        string ShipLastName
        string ShipStreet
        string ShipCity
        string ShipState
        string ShipPostalCode
        string ShipCountry
        datetime PaidAt
        datetime CreatedAt
        datetime UpdatedAt
    }

    ORDERITEMS {
        bigint Id PK
        bigint OrderId FK
        bigint ProductId FK
        string ProductSku
        string ProductNameSnapshot
        decimal UnitPrice
        int Quantity
        decimal LineTotal
    }

    PAYMENTS {
        bigint Id PK
        bigint OrderId FK
        string TransactionId UK
        string Method
        decimal Amount
        string Status
        datetime PaidAt
        datetime CreatedAt
    }

    REVIEWS {
        bigint Id PK
        bigint ProductId FK
        bigint UserId FK
        tinyint Rating
        string Comment
        bool IsApproved
        datetime CreatedAt
    }
```

## Notas de diseño

| Elemento | Detalle |
|---|---|
| Integridad referencial | FKs con `RESTRICT`, `CASCADE` o `SET NULL` según la regla de negocio (ver flechas del diagrama) |
| Restricciones `CHECK` | Precios/stock/importes ≥ 0 · `Quantity` > 0 · `Rating` 1–5 · estados de `Orders` y `Payments` en listas cerradas |
| Igualdad (UNIQUE) | `Roles.Name` · `Users.Email` · `Categories.Name/Slug` · `Products.Sku/Slug` · `Carts.UserId` · `CartItems(CartId,ProductId)` · `Orders.OrderNumber` · `Payments.TransactionId` · `Reviews(ProductId,UserId)` |
| Índices estratégicos | Búsqueda/catálogo de productos, historial de órdenes por usuario, estado de órdenes, reseñas aprobadas por producto |
| Texto libre | Índice `FULLTEXT` sobre `Products(Name, Description)` |
| Snapshot comercial | `OrderItems` conserva `ProductSku`, `ProductNameSnapshot` y `UnitPrice` aunque el producto cambie después |
| Identificadores | `bigint` para entidades de alto volumen; `int` para catálogos cortos |
| Dinero | `DECIMAL(12,2)` en todos los importes |