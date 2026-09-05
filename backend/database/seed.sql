-- ============================================================
--  seed.sql - Datos de demostración para la base e-commerce
--  Proyecto: e-commerce | MySQL 8.0
--
--  Aplicar:
--    cd backend
--    .\scripts\mysql.ps1 -File .\database\seed.sql
--
--  ADVERTENCIA: este script es IDEMPOTENTE con respecto al esquema
--  vacío. Si se re-ejecuta sobre datos existentes, fallará por
--  restricciones UNIQUE (comportamiento intencional).
-- ============================================================

USE `ecommerce`;

-- ------------------------------------------------------------------
-- 1. ROLES
-- ------------------------------------------------------------------
INSERT INTO `Roles` (`Id`, `Name`) VALUES
  (1, 'Admin'),
  (2, 'Cliente');

-- ------------------------------------------------------------------
-- 2. USUARIOS
--    PasswordHash = hash BCrypt de la palabra "password".
--    SOLO para demo; reemplazar cuando se implemente autenticación.
-- ------------------------------------------------------------------
INSERT INTO `Users`
  (`Id`, `RoleId`, `Email`, `PasswordHash`, `FirstName`, `LastName`,
   `Phone`, `IsActive`, `CreatedAt`, `UpdatedAt`)
VALUES
  (1, 1, 'admin@ecommerce.com',
   '$2a$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
   'Administrador', 'Sistema', '3000000001', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
  (2, 2, 'cliente@demo.com',
   '$2a$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
   'Cliente', 'Demo', '3000000002', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 3. CATEGORÍAS (árbol: Tecnología → Laptops / Accesorios)
-- ------------------------------------------------------------------
INSERT INTO `Categories` (`Id`, `ParentId`, `Name`, `Slug`, `Description`, `IsActive`, `CreatedAt`)
VALUES
  (1, NULL, 'Tecnología',   'tecnologia',   'Productos de tecnología y cómputo', 1, UTC_TIMESTAMP(6)),
  (2, 1,    'Laptops',      'laptops',      'Computadoras portátiles',           1, UTC_TIMESTAMP(6)),
  (3, 1,    'Accesorios',   'accesorios',   'Periféricos y accesorios',          1, UTC_TIMESTAMP(6)),
  (4, NULL, 'Oficina',      'oficina',      'Artículos para la oficina',         1, UTC_TIMESTAMP(6)),
  (5, 4,    'Escritorios',  'escritorios',  'Muebles de escritorio',             1, UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 4. PRODUCTOS
-- ------------------------------------------------------------------
INSERT INTO `Products`
  (`Id`, `CategoryId`, `Sku`, `Name`, `Slug`, `Description`, `Price`,
   `CompareAtPrice`, `Stock`, `ImageCoverUrl`, `IsActive`, `CreatedAt`, `UpdatedAt`)
VALUES
  (1, 2, 'LP-001', 'Laptop Gamer Asus ROG', 'laptop-gamer-asus-rog',
   'Intel i7, 16 GB RAM, 512 GB SSD, RTX 4060', 4599.99, 4999.99, 10,
   'https://example.com/img/laptop-rog.jpg', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
  (2, 2, 'LP-002', 'Laptop Ultrabook Dell XPS 13', 'laptop-ultrabook-dell-xps-13',
   'Ultraligera, pantalla FHD, 13 pulgadas', 3899.00, NULL, 5,
   'https://example.com/img/laptop-xps.jpg', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
  (3, 3, 'AC-001', 'Mouse Inalámbrico Logitech MX', 'mouse-inalambrico-logitech-mx',
   'Ergonómico, batería por USB-C', 249.90, 299.90, 25,
   NULL, 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
  (4, 3, 'AC-002', 'Teclado Mecánico K70 RGB', 'teclado-mecanico-k70-rgb',
   'Switch Rojo, retroiluminación RGB', 399.50, 449.00, 15,
   'https://example.com/img/teclado-k70.jpg', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
  (5, 5, 'ES-001', 'Escritorio L 120 cm', 'escritorio-l-120-cm',
   'Madera nórdica, estructura metálica', 899.00, 999.00, 8,
   NULL, 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 5. IMÁGENES DE PRODUCTOS
-- ------------------------------------------------------------------
INSERT INTO `ProductImages` (`Id`, `ProductId`, `Url`, `SortOrder`, `IsActive`)
VALUES
  (1, 1, 'https://example.com/img/laptop-rog-1.jpg', 1, 1),
  (2, 1, 'https://example.com/img/laptop-rog-2.jpg', 2, 1),
  (3, 4, 'https://example.com/img/teclado-k70-2.jpg', 1, 1);

-- ------------------------------------------------------------------
-- 6. DIRECCIONES
-- ------------------------------------------------------------------
INSERT INTO `Addresses`
  (`Id`, `UserId`, `Street`, `City`, `State`, `PostalCode`, `Country`,
   `IsDefault`, `CreatedAt`)
VALUES
  (1, 2, 'Calle 123 # 45-67', 'Bogotá', 'Cundinamarca', '110111', 'Colombia', 1, UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 7. CARRITO Y ARTÍCULOS DEL CARRITO
-- ------------------------------------------------------------------
INSERT INTO `Carts` (`Id`, `UserId`, `CreatedAt`, `UpdatedAt`) VALUES
  (1, 2, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6));

INSERT INTO `CartItems` (`Id`, `CartId`, `ProductId`, `Quantity`, `CreatedAt`) VALUES
  (1, 1, 3, 2, UTC_TIMESTAMP(6)),
  (2, 1, 1, 1, UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 8. ÓRDENES + ARTÍCULOS + PAGO
--    Orden #1: pendiente, vinculada a la dirección del cliente.
-- ------------------------------------------------------------------
INSERT INTO `Orders`
  (`Id`, `UserId`, `OrderNumber`, `Status`, `Subtotal`, `ShippingCost`,
   `Tax`, `Total`, `ShippingAddressId`, `ShipFirstName`, `ShipLastName`,
   `ShipStreet`, `ShipCity`, `ShipState`, `ShipPostalCode`, `ShipCountry`,
   `PaidAt`, `CreatedAt`, `UpdatedAt`)
VALUES
  (1, 2, 'ORD-000001', 'Pending', 5099.79, 15.00, 0.00, 5114.79,
   1, 'Cliente', 'Demo', 'Calle 123 # 45-67', 'Bogotá', 'Cundinamarca',
   '110111', 'Colombia', NULL, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6));

INSERT INTO `OrderItems`
  (`Id`, `OrderId`, `ProductId`, `ProductSku`, `ProductNameSnapshot`,
   `UnitPrice`, `Quantity`, `LineTotal`)
VALUES
  (1, 1, 3, 'AC-001', 'Mouse Inalámbrico Logitech MX', 249.90, 2, 499.80),
  (2, 1, 1, 'LP-001', 'Laptop Gamer Asus ROG',           4599.99, 1, 4599.99);

INSERT INTO `Payments`
  (`Id`, `OrderId`, `Method`, `Amount`, `TransactionId`, `Status`,
   `PaidAt`, `CreatedAt`)
VALUES
  (1, 1, 'card', 5114.79, 'TXN-DEMO-0001', 'Pending', NULL, UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- 9. RESEÑAS
-- ------------------------------------------------------------------
INSERT INTO `Reviews`
  (`Id`, `ProductId`, `UserId`, `Rating`, `Comment`, `IsApproved`, `CreatedAt`)
VALUES
  (1, 1, 2, 5, 'Excelente equipo, corre todo sin problemas.', 1, UTC_TIMESTAMP(6)),
  (2, 3, 2, 4, 'Buen mouse, un poco caro.', 1, UTC_TIMESTAMP(6));

-- ------------------------------------------------------------------
-- VERIFICACIÓN VISUAL
-- ------------------------------------------------------------------
SELECT 'RESUMEN DE CARGA' AS seccion;
SELECT
  (SELECT COUNT(*) FROM Roles)       AS roles,
  (SELECT COUNT(*) FROM Users)       AS usuarios,
  (SELECT COUNT(*) FROM Categories)  AS categorias,
  (SELECT COUNT(*) FROM Products)    AS productos,
  (SELECT COUNT(*) FROM Orders)      AS ordenes,
  (SELECT COUNT(*) FROM Payments)    AS pagos,
  (SELECT COUNT(*) FROM Reviews)     AS resenas;