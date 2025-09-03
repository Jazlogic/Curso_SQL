-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 2: CONSULTAS AVANZADAS
-- =====================================================

-- Base de datos para ejercicios
CREATE DATABASE ecommerce_joins;
USE ecommerce_joins;

-- Tablas del sistema
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE detalle_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y gadgets'),
('Ropa', 'Vestimenta y accesorios'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipamiento deportivo'),
('Libros', 'Literatura y material educativo');

INSERT INTO productos (nombre, precio, categoria_id, stock) VALUES
('iPhone 14', 999.99, 1, 25),
('Samsung Galaxy S23', 899.99, 1, 30),
('Camiseta Nike', 29.99, 2, 100),
('Sofá 3 plazas', 599.99, 3, 5),
('Balón de fútbol', 19.99, 4, 50),
('El Quijote', 15.99, 5, 20),
('Laptop Dell', 1299.99, 1, 15),
('Jeans Levi\'s', 79.99, 2, 75);

INSERT INTO usuarios (nombre, email) VALUES
('Ana García', 'ana.garcia@email.com'),
('Carlos López', 'carlos.lopez@email.com'),
('María Rodríguez', 'maria.rodriguez@email.com'),
('José Martín', 'jose.martin@email.com'),
('Laura Sánchez', 'laura.sanchez@email.com');

INSERT INTO pedidos (usuario_id, total) VALUES
(1, 999.99),
(2, 1329.98),
(3, 45.98),
(1, 599.99),
(4, 35.98);

INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 999.99),
(2, 1, 1, 999.99),
(2, 7, 1, 1299.99),
(3, 3, 1, 29.99),
(3, 5, 1, 19.99),
(4, 4, 1, 599.99),
(5, 5, 1, 19.99),
(5, 6, 1, 15.99);

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: JOINs BÁSICOS
-- =====================================================

-- Ejercicio 1: INNER JOIN - Productos con categorías
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 2: LEFT JOIN - Todos los productos
SELECT 
    p.nombre AS producto,
    p.precio,
    COALESCE(c.nombre, 'Sin Categoría') AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 3: RIGHT JOIN - Todas las categorías
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 4: Pedidos con información de usuarios
SELECT 
    p.id AS pedido_id,
    u.nombre AS cliente,
    p.fecha_pedido,
    p.total
FROM pedidos p
INNER JOIN usuarios u ON p.usuario_id = u.id;

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: JOINs AVANZADOS
-- =====================================================

-- Ejercicio 1: FULL OUTER JOIN simulado
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
UNION
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 2: Múltiples JOINs
SELECT 
    u.nombre AS cliente,
    p.id AS pedido_id,
    pr.nombre AS producto,
    dp.cantidad,
    dp.precio_unitario
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id
INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
INNER JOIN productos pr ON dp.producto_id = pr.id;

-- Ejercicio 3: Análisis de ventas por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT p.id) AS total_productos,
    SUM(dp.cantidad) AS total_vendido,
    SUM(dp.cantidad * dp.precio_unitario) AS ingresos_totales
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
GROUP BY c.id, c.nombre;

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: SUBCONSULTAS BÁSICAS
-- =====================================================

-- Ejercicio 1: Productos más caros que el promedio
SELECT 
    nombre AS producto,
    precio
FROM productos
WHERE precio > (
    SELECT AVG(precio)
    FROM productos
);

-- Ejercicio 2: Usuarios con estadísticas
SELECT 
    u.nombre AS usuario,
    u.email,
    (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id) AS total_pedidos,
    (SELECT COALESCE(SUM(total), 0) FROM pedidos p WHERE p.usuario_id = u.id) AS total_gastado
FROM usuarios u;

-- Ejercicio 3: Productos con información de ventas
SELECT 
    p.nombre AS producto,
    p.precio,
    (SELECT COALESCE(SUM(dp.cantidad), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS total_vendido
FROM productos p;

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: SUBCONSULTAS AVANZADAS
-- =====================================================

-- Ejercicio 1: Subconsulta correlacionada
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);

-- Ejercicio 2: EXISTS - Usuarios con pedidos
SELECT 
    u.nombre AS usuario,
    u.email
FROM usuarios u
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.usuario_id = u.id
);

-- Ejercicio 3: IN - Productos de categorías populares
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.categoria_id IN (
    SELECT categoria_id
    FROM productos
    GROUP BY categoria_id
    HAVING COUNT(*) > 1
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: FUNCIONES DE VENTANA
-- =====================================================

-- Ejercicio 1: Ranking de productos por precio
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (ORDER BY p.precio DESC) AS numero_fila,
    RANK() OVER (ORDER BY p.precio DESC) AS ranking,
    DENSE_RANK() OVER (ORDER BY p.precio DESC) AS ranking_denso
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 2: Ranking por categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    RANK() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Ejercicio 3: Análisis de tendencias
SELECT 
    p.nombre AS producto,
    p.precio,
    LAG(p.precio, 1) OVER (ORDER BY p.precio) AS precio_anterior,
    p.precio - LAG(p.precio, 1) OVER (ORDER BY p.precio) AS diferencia_precio
FROM productos p
ORDER BY p.precio;

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: VISTAS
-- =====================================================

-- Ejercicio 1: Vista de productos con categorías
CREATE VIEW vista_productos_categoria AS
SELECT 
    p.id,
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Usar la vista
SELECT * FROM vista_productos_categoria WHERE precio > 100;

-- Ejercicio 2: Vista de usuarios con estadísticas
CREATE VIEW vista_usuarios_estadisticas AS
SELECT 
    u.id,
    u.nombre AS usuario,
    u.email,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email;

-- Usar la vista
SELECT * FROM vista_usuarios_estadisticas WHERE total_gastado > 500;

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: CTEs
-- =====================================================

-- Ejercicio 1: CTE simple
WITH productos_ventas AS (
    SELECT 
        p.id,
        p.nombre,
        p.precio,
        c.nombre AS categoria,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, p.precio, c.nombre
)
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    SUM(total_vendido) AS total_vendido_categoria
FROM productos_ventas
GROUP BY categoria;

-- Ejercicio 2: CTE múltiple
WITH ventas_mensuales AS (
    SELECT 
        YEAR(p.fecha_pedido) AS año,
        MONTH(p.fecha_pedido) AS mes,
        SUM(p.total) AS ventas_totales
    FROM pedidos p
    GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
),
tendencias_ventas AS (
    SELECT 
        *,
        LAG(ventas_totales, 1) OVER (ORDER BY año, mes) AS ventas_mes_anterior
    FROM ventas_mensuales
)
SELECT 
    año,
    mes,
    ventas_totales,
    ventas_mes_anterior,
    ventas_totales - ventas_mes_anterior AS diferencia
FROM tendencias_ventas;

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: CONSULTAS COMPLEJAS
-- =====================================================

-- Ejercicio 1: Análisis completo de ventas
WITH ventas_analisis AS (
    SELECT 
        YEAR(p.fecha_pedido) AS año,
        MONTH(p.fecha_pedido) AS mes,
        u.nombre AS usuario,
        pr.nombre AS producto,
        c.nombre AS categoria,
        dp.cantidad,
        dp.precio_unitario,
        (dp.cantidad * dp.precio_unitario) AS subtotal
    FROM pedidos p
    INNER JOIN usuarios u ON p.usuario_id = u.id
    INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
    INNER JOIN productos pr ON dp.producto_id = pr.id
    INNER JOIN categorias c ON pr.categoria_id = c.id
),
resumen_ventas AS (
    SELECT 
        categoria,
        COUNT(DISTINCT usuario) AS usuarios_unicos,
        SUM(cantidad) AS total_vendido,
        SUM(subtotal) AS ingresos_totales
    FROM ventas_analisis
    GROUP BY categoria
)
SELECT 
    categoria,
    usuarios_unicos,
    total_vendido,
    ingresos_totales,
    RANK() OVER (ORDER BY ingresos_totales DESC) AS ranking_ingresos
FROM resumen_ventas;

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: OPTIMIZACIÓN
-- =====================================================

-- Ejercicio 1: Análisis de rendimiento
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100;

-- Crear índices para optimizar
CREATE INDEX idx_precio ON productos (precio);
CREATE INDEX idx_categoria_id ON productos (categoria_id);

-- Consulta optimizada
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100;

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Dashboard ejecutivo completo
WITH metricas_generales AS (
    SELECT 
        'Total Ventas' AS metric,
        CONCAT('$', FORMAT(SUM(p.total), 2)) AS valor
    FROM pedidos p
    
    UNION ALL
    
    SELECT 
        'Total Pedidos' AS metric,
        COUNT(*) AS valor
    FROM pedidos p
    
    UNION ALL
    
    SELECT 
        'Usuarios Únicos' AS metric,
        COUNT(DISTINCT u.id) AS valor
    FROM usuarios u
    INNER JOIN pedidos p ON u.id = p.usuario_id
    
    UNION ALL
    
    SELECT 
        'Productos Vendidos' AS metric,
        COUNT(DISTINCT p.id) AS valor
    FROM productos p
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
)
SELECT * FROM metricas_generales;

-- Análisis de productos más vendidos
WITH productos_vendidos AS (
    SELECT 
        p.nombre AS producto,
        c.nombre AS categoria,
        SUM(dp.cantidad) AS total_vendido,
        SUM(dp.cantidad * dp.precio_unitario) AS ingresos_generados,
        RANK() OVER (ORDER BY SUM(dp.cantidad) DESC) AS ranking_ventas
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, c.nombre
)
SELECT 
    producto,
    categoria,
    total_vendido,
    ingresos_generados,
    ranking_ventas
FROM productos_vendidos
WHERE ranking_ventas <= 5
ORDER BY ranking_ventas;
