-- =============================================================
--  E-COMMERCE — Esquema relacional (MySQL 8+)
--  Motor: InnoDB | Charset: utf8mb4 | Cotejamiento: utf8mb4_unicode_ci
--
--  Decisiones de diseño arquitectónico:
--   · Cumple 1FN, 2FN y 3FN (ver notas al final).
--   · Integridad referencial garantizada con claves foráneas.
--   · Restricciones de borrado explícitas (CASCADE / RESTRICT).
--   · Índices estratégicos para búsquedas frecuentes de productos.
--   · CHECK constraints para invariantes de negocio.
--   · NUNCA usar float/double para dinero → DECIMAL(12,2).
--   · Borrado lógico (IsActive) en entidades de negocio sensibles.
--   · Snapshot de precio/nombre en OrderItems (desnormalización
--     INTENCIONAL para historial inmutable de ventas).
-- =============================================================

CREATE DATABASE IF NOT EXISTS ecommerce
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ecommerce;

-- =============================================================
-- 1. ROLES (tabla de dominio)
-- =============================================================
CREATE TABLE IF NOT EXISTS Roles (
    Id   INT UNSIGNED AUTO_INCREMENT,
    Name VARCHAR(30) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (Id),
    CONSTRAINT UQ_Roles_Name UNIQUE (Name)
) ENGINE=InnoDB;

-- =============================================================
-- 2. USERS
-- =============================================================
CREATE TABLE IF NOT EXISTS Users (
    Id           BIGINT UNSIGNED AUTO_INCREMENT,
    RoleId       INT UNSIGNED NOT NULL,
    Email        VARCHAR(190) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName    VARCHAR(80)  NOT NULL,
    LastName     VARCHAR(80)  NOT NULL,
    Phone        VARCHAR(30)  NULL,
    IsActive     TINYINT(1)   NOT NULL DEFAULT 1,
    CreatedAt    DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UpdatedAt    DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                             ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Users PRIMARY KEY (Id),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId)
        REFERENCES Roles (Id)
        ON DELETE RESTRICT,          -- no se borran roles en uso
    CONSTRAINT CHK_Users_IsActive CHECK (IsActive IN (0, 1))
) ENGINE=InnoDB;

-- Índice: búsqueda de usuarios por rol + estado (reportes admin)
CREATE INDEX IX_Users_Role_Activity ON Users (RoleId, IsActive);

-- =============================================================
-- 3. CATEGORIES (jerárquica, 3FN: se separó de Products)
-- =============================================================
CREATE TABLE IF NOT EXISTS Categories (
    Id          INT UNSIGNED AUTO_INCREMENT,
    ParentId    INT UNSIGNED NULL,
    Name        VARCHAR(100) NOT NULL,
    Slug        VARCHAR(120) NOT NULL,
    Description VARCHAR(500) NULL,
    IsActive    TINYINT(1)   NOT NULL DEFAULT 1,
    CreatedAt   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Categories PRIMARY KEY (Id),
    CONSTRAINT UQ_Categories_Name UNIQUE (Name),
    CONSTRAINT UQ_Categories_Slug UNIQUE (Slug),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentId)
        REFERENCES Categories (Id)
        ON DELETE RESTRICT           -- no romper jerarquías
) ENGINE=InnoDB;

-- Índice: búsqueda frecuente de subcategorías de una categoría
CREATE INDEX IX_Categories_Parent ON Categories (ParentId);

-- =============================================================
-- 4. PRODUCTS  (tabla de mayor tráfico de lectura)
-- =============================================================
CREATE TABLE IF NOT EXISTS Products (
    Id            BIGINT UNSIGNED AUTO_INCREMENT,
    CategoryId    INT UNSIGNED    NOT NULL,
    Sku           VARCHAR(50)     NOT NULL,
    Name          VARCHAR(150)    NOT NULL,
    Slug          VARCHAR(170)    NOT NULL,
    Description   VARCHAR(1000)   NULL,
    Price         DECIMAL(12,2)   NOT NULL,   -- dinero: jamás FLOAT
    CompareAtPrice DECIMAL(12,2)  NULL,       -- precio tachado (oferta)
    Stock         INT UNSIGNED    NOT NULL DEFAULT 0,
    ImageCoverUrl VARCHAR(500)    NULL,
    IsActive      TINYINT(1)      NOT NULL DEFAULT 1,
    RowVersion    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                 ON UPDATE CURRENT_TIMESTAMP(6),
    CreatedAt     DATETIME(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UpdatedAt     DATETIME(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                 ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Products PRIMARY KEY (Id),
    CONSTRAINT UQ_Products_Sku UNIQUE (Sku),
    CONSTRAINT UQ_Products_Slug UNIQUE (Slug),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId)
        REFERENCES Categories (Id)
        ON DELETE RESTRICT,          -- categoría con productos no se borra
    CONSTRAINT CHK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Products_ComparePrice CHECK (CompareAtPrice IS NULL OR CompareAtPrice >= 0),
    CONSTRAINT CHK_Products_Stock CHECK (Stock >= 0)
) ENGINE=InnoDB;

-- ÍNDICES ESTRATÉGICOS (búsqueda frecuente de productos):
-- (a) lista por categoría activa   → filtro de vitrina
CREATE INDEX IX_Products_Category_Active
    ON Products (CategoryId, IsActive);

-- (b) búsqueda por disponibilidad  → vitrina + admin
CREATE INDEX IX_Products_Active ON Products (IsActive);

-- (c) ordenamiento por novedad/actualización
CREATE INDEX IX_Products_UpdatedAt ON Products (UpdatedAt);

-- (d) rango de precios (filtro "precio entre")
CREATE INDEX IX_Products_Price ON Products (Price);

-- (e) BÚSQUEDA DE TEXTO LIBRE (el buscador del e-commerce)
--     FULLTEXT sobre nombre + descripción.
CREATE FULLTEXT INDEX FTX_Products_Search
    ON Products (Name, Description);

-- (f) búsqueda por SKU exacta (inventario) → cubierta por UQ_Products_Sku

-- =============================================================
-- 5. PRODUCT IMAGES (1 producto → N imágenes)
-- =============================================================
CREATE TABLE IF NOT EXISTS ProductImages (
    Id         BIGINT UNSIGNED AUTO_INCREMENT,
    ProductId  BIGINT UNSIGNED NOT NULL,
    Url        VARCHAR(500) NOT NULL,
    SortOrder  INT UNSIGNED NOT NULL DEFAULT 0,
    IsActive   TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT PK_ProductImages PRIMARY KEY (Id),
    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductId)
        REFERENCES Products (Id)
        ON DELETE CASCADE            -- imágenes no viven sin su producto
) ENGINE=InnoDB;

CREATE INDEX IX_ProductImages_Product ON ProductImages (ProductId);

-- =============================================================
-- 6. ADDRESSES (3FN: dirección fuera de Orders y Users)
-- =============================================================
CREATE TABLE IF NOT EXISTS Addresses (
    Id          BIGINT UNSIGNED AUTO_INCREMENT,
    UserId      BIGINT UNSIGNED NOT NULL,
    Street      VARCHAR(150) NOT NULL,
    City        VARCHAR(80)  NOT NULL,
    State       VARCHAR(80)  NOT NULL,
    PostalCode  VARCHAR(20)  NOT NULL,
    Country     VARCHAR(60)  NOT NULL,
    IsDefault   TINYINT(1)   NOT NULL DEFAULT 0,
    CreatedAt   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Addresses PRIMARY KEY (Id),
    CONSTRAINT FK_Addresses_Users FOREIGN KEY (UserId)
        REFERENCES Users (Id)
        ON DELETE CASCADE            -- direcciones son subordinadas del usuario
) ENGINE=InnoDB;

CREATE INDEX IX_Addresses_User ON Addresses (UserId);

-- =============================================================
-- 7. CARTS / CART ITEMS (carrito activo del usuario)
-- =============================================================
CREATE TABLE IF NOT EXISTS Carts (
    Id        BIGINT UNSIGNED AUTO_INCREMENT,
    UserId    BIGINT UNSIGNED NOT NULL,
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UpdatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Carts PRIMARY KEY (Id),
    CONSTRAINT FK_Carts_Users FOREIGN KEY (UserId)
        REFERENCES Users (Id)
        ON DELETE CASCADE,
    CONSTRAINT UQ_Carts_User UNIQUE (UserId)   -- 1 carrito activo por usuario
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS CartItems (
    Id        BIGINT UNSIGNED AUTO_INCREMENT,
    CartId    BIGINT UNSIGNED NOT NULL,
    ProductId BIGINT UNSIGNED NOT NULL,
    Quantity  INT UNSIGNED    NOT NULL DEFAULT 1,
    CreatedAt DATETIME(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_CartItems PRIMARY KEY (Id),
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartId)
        REFERENCES Carts (Id)
        ON DELETE CASCADE,           -- sin carrito no hay items
    CONSTRAINT FK_CartItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products (Id)
        ON DELETE RESTRICT,          -- nunca romper referencia al producto
    CONSTRAINT UQ_CartItems_Cart_Product UNIQUE (CartId, ProductId),
    CONSTRAINT CHK_CartItems_Quantity CHECK (Quantity > 0)
) ENGINE=InnoDB;

CREATE INDEX IX_CartItems_Product ON CartItems (ProductId);

-- =============================================================
-- 8. ORDERS / ORDER ITEMS (núcleo transaccional)
-- =============================================================
CREATE TABLE IF NOT EXISTS Orders (
    Id            BIGINT UNSIGNED AUTO_INCREMENT,
    UserId        BIGINT UNSIGNED  NOT NULL,
    OrderNumber   VARCHAR(20)      NOT NULL,
    Status        VARCHAR(20)      NOT NULL DEFAULT 'Pending',
    Subtotal      DECIMAL(12,2)    NOT NULL,
    ShippingCost  DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    Tax           DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    Total         DECIMAL(12,2)    NOT NULL,
    -- Snapshot de envío (historial inmutable de negocio)
    ShippingAddressId BIGINT UNSIGNED NULL,
    ShipFirstName VARCHAR(80)  NULL,
    ShipLastName  VARCHAR(80)  NULL,
    ShipStreet    VARCHAR(150) NULL,
    ShipCity      VARCHAR(80)  NULL,
    ShipState     VARCHAR(80)  NULL,
    ShipPostalCode VARCHAR(20) NULL,
    ShipCountry   VARCHAR(60)  NULL,
    PaidAt        DATETIME(6)  NULL,
    CreatedAt     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UpdatedAt     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                             ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Orders PRIMARY KEY (Id),
    CONSTRAINT UQ_Orders_Number UNIQUE (OrderNumber),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId)
        REFERENCES Users (Id)
        ON DELETE RESTRICT,          -- historial de compras no se borra
    CONSTRAINT FK_Orders_Addresses FOREIGN KEY (ShippingAddressId)
        REFERENCES Addresses (Id)
        ON DELETE SET NULL,          -- la orden sobrevive si borran la dirección
    CONSTRAINT CHK_Orders_Total CHECK (Total >= 0),
    CONSTRAINT CHK_Orders_Subtotal CHECK (Subtotal >= 0),
    CONSTRAINT CHK_Orders_Status CHECK (
        Status IN ('Pending','Paid','Shipped','Delivered','Cancelled'))
) ENGINE=InnoDB;

-- Índices de consultas frecuentes: mis órdenes (userId+created), seguimiento por estado
CREATE INDEX IX_Orders_User_Created ON Orders (UserId, CreatedAt);
CREATE INDEX IX_Orders_Status ON Orders (Status);

CREATE TABLE IF NOT EXISTS OrderItems (
    Id                  BIGINT UNSIGNED AUTO_INCREMENT,
    OrderId             BIGINT UNSIGNED NOT NULL,
    ProductId           BIGINT UNSIGNED NOT NULL,
    ProductSku          VARCHAR(50)  NOT NULL,
    ProductNameSnapshot VARCHAR(150) NOT NULL,
    UnitPrice           DECIMAL(12,2) NOT NULL,   -- histórico: no cambia aunque suba el producto
    Quantity            INT UNSIGNED  NOT NULL,
    LineTotal           DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_OrderItems PRIMARY KEY (Id),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId)
        REFERENCES Orders (Id)
        ON DELETE CASCADE,           -- los items son parte de la orden
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products (Id)
        ON DELETE RESTRICT,          -- auditoría de ventas intacta
    CONSTRAINT CHK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CHK_OrderItems_LineTotal CHECK (LineTotal >= 0)
) ENGINE=InnoDB;

CREATE INDEX IX_OrderItems_Order ON OrderItems (OrderId);
CREATE INDEX IX_OrderItems_Product ON OrderItems (ProductId);

-- =============================================================
-- 9. PAYMENTS (simulado por ahora)
-- =============================================================
CREATE TABLE IF NOT EXISTS Payments (
    Id            BIGINT UNSIGNED AUTO_INCREMENT,
    OrderId       BIGINT UNSIGNED NOT NULL,
    Method        VARCHAR(20)  NOT NULL,
    Amount        DECIMAL(12,2) NOT NULL,
    TransactionId VARCHAR(100) NULL,
    Status        VARCHAR(20)  NOT NULL DEFAULT 'Pending',
    PaidAt        DATETIME(6)  NULL,
    CreatedAt     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Payments PRIMARY KEY (Id),
    CONSTRAINT UQ_Payments_Transaction UNIQUE (TransactionId),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderId)
        REFERENCES Orders (Id)
        ON DELETE RESTRICT,          -- pagos nunca se eliminan
    CONSTRAINT CHK_Payments_Amount CHECK (Amount >= 0),
    CONSTRAINT CHK_Payments_Status CHECK (
        Status IN ('Pending','Approved','Declined','Refunded'))
) ENGINE=InnoDB;

CREATE INDEX IX_Payments_Order ON Payments (OrderId);

-- =============================================================
-- 10. REVIEWS (rating comprobable: 1 por usuario por producto)
-- =============================================================
CREATE TABLE IF NOT EXISTS Reviews (
    Id         BIGINT UNSIGNED AUTO_INCREMENT,
    ProductId  BIGINT UNSIGNED NOT NULL,
    UserId     BIGINT UNSIGNED NOT NULL,
    Rating     TINYINT UNSIGNED NOT NULL,
    Comment    VARCHAR(1000) NULL,
    IsApproved TINYINT(1) NOT NULL DEFAULT 0,
    CreatedAt  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT PK_Reviews PRIMARY KEY (Id),
    CONSTRAINT FK_Reviews_Products FOREIGN KEY (ProductId)
        REFERENCES Products (Id)
        ON DELETE CASCADE,           -- reseñas mueren con el producto (borrado físico)
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (UserId)
        REFERENCES Users (Id)
        ON DELETE RESTRICT,
    CONSTRAINT UQ_Reviews_Product_User UNIQUE (ProductId, UserId),
    CONSTRAINT CHK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE INDEX IX_Reviews_Product_Approved ON Reviews (ProductId, IsApproved);

-- =============================================================
-- SEED (datos de arranque)
-- =============================================================
INSERT INTO Roles (Name) VALUES ('Admin'), ('Customer')
ON DUPLICATE KEY UPDATE Name = VALUES(Name);

-- Ejemplo mínimo de categorías + productos para probar FULLTEXT:
INSERT INTO Categories (Name, Slug, Description) VALUES
    ('Computacion', 'computacion', 'Laptops, monitores y accesorios'),
    ('Electronica', 'electronica', 'Audio, video y gadgets')
ON DUPLICATE KEY UPDATE Slug = VALUES(Slug);

INSERT INTO Products (CategoryId, Sku, Name, Slug, Description, Price, Stock, IsActive)
SELECT c.Id, 'SKU-LAP-001', 'Laptop Gamer', 'laptop-gamer', 'RTX 4060, 16GB RAM, 512GB SSD', 899.99, 15, 1
FROM Categories c WHERE c.Slug = 'computacion'
ON DUPLICATE KEY UPDATE Sku = VALUES(Sku);

INSERT INTO Products (CategoryId, Sku, Name, Slug, Description, Price, Stock, IsActive)
SELECT c.Id, 'SKU-MON-027', 'Monitor 27 Full HD', 'monitor-27-full-hd', 'Pantalla 27 pulgadas 144Hz', 249.99, 30, 1
FROM Categories c WHERE c.Slug = 'computacion'
ON DUPLICATE KEY UPDATE Sku = VALUES(Sku);

-- =============================================================
--  NOTAS DE NORMALIZACIÓN
--  · 1FN: columnas atómicas, sin listas; imágenes en su propia tabla.
--  · 2FN: PKs simples (AUTO_INCREMENT), cero dependencias parciales.
--  · 3FN: Category sacada de Products; Address sacada de Orders/Users;
--        snapshots de venta son excepción deliberada (historial inmutable).
--  · Índices estratégicos sobre columnas de WHERE/ORDER BY de mayor uso.
-- =============================================================