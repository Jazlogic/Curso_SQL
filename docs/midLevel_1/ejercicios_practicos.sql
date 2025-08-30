-- 🔶 Mid-Level 1: Ejercicios Prácticos de JOINs
-- Archivo con datos de ejemplo y consultas adicionales para practicar

-- =====================================================
-- SISTEMA DE TIENDA ONLINE - DATOS DE EJEMPLO
-- =====================================================

USE tienda_online;

-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónica', 'Productos electrónicos y gadgets'),
('Informática', 'Computadoras y accesorios'),
('Gaming', 'Productos para videojuegos'),
('Accesorios', 'Accesorios varios'),
('Hogar', 'Productos para el hogar');

-- Insertar productos
INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Laptop HP Pavilion', 899.99, 15, 2),
('Mouse Gaming RGB', 45.50, 50, 3),
('Teclado Mecánico', 89.99, 25, 3),
('Monitor 24" Samsung', 199.99, 30, 1),
('Auriculares Bluetooth', 79.99, 40, 1),
('Impresora HP LaserJet', 299.99, 10, 2),
('Webcam HD', 59.99, 35, 1),
('SSD 500GB', 89.99, 20, 2),
('Joystick Xbox', 39.99, 45, 3),
('Lámpara LED', 29.99, 60, 5);

-- Insertar clientes
INSERT INTO clientes (nombre, apellido, email) VALUES
('Juan', 'García', 'juan.garcia@email.com'),
('María', 'López', 'maria.lopez@email.com'),
('Carlos', 'Rodríguez', 'carlos.rodriguez@email.com'),
('Ana', 'Martínez', 'ana.martinez@email.com'),
('Luis', 'Fernández', 'luis.fernandez@email.com'),
('Carmen', 'González', 'carmen.gonzalez@email.com');

-- Insertar pedidos
INSERT INTO pedidos (cliente_id, total, estado) VALUES
(1, 945.49, 'Completado'),
(2, 299.99, 'Completado'),
(3, 135.49, 'Pendiente'),
(4, 199.99, 'Completado'),
(5, 89.99, 'Pendiente'),
(1, 159.98, 'Completado');

-- Insertar productos en pedidos
INSERT INTO productos_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 899.99),  -- Laptop
(1, 2, 1, 45.50),   -- Mouse
(2, 6, 1, 299.99),  -- Impresora
(3, 3, 1, 89.99),   -- Teclado
(3, 2, 1, 45.50),   -- Mouse
(4, 4, 1, 199.99),  -- Monitor
(5, 8, 1, 89.99),   -- SSD
(6, 4, 1, 199.99),  -- Monitor
(6, 5, 1, 79.99);   -- Auriculares

-- =====================================================
-- CONSULTAS ADICIONALES PARA PRACTICAR
-- =====================================================

-- 1. Mostrar el top 5 de clientes que más han gastado
SELECT 
    c.nombre, c.apellido,
    SUM(p.total) AS total_gastado,
    COUNT(p.id) AS total_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido
ORDER BY total_gastado DESC
LIMIT 5;

-- 2. Mostrar productos con su categoría y total vendido
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    p.precio AS precio_actual,
    SUM(pp.cantidad) AS total_vendido,
    SUM(pp.cantidad * pp.precio_unitario) AS ingresos_totales
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
GROUP BY p.id, p.nombre, c.nombre, p.precio
ORDER BY ingresos_totales DESC;

-- 3. Mostrar clientes que han comprado productos de múltiples categorías
SELECT 
    c.nombre, c.apellido,
    COUNT(DISTINCT cat.id) AS categorias_diferentes,
    GROUP_CONCAT(DISTINCT cat.nombre) AS categorias
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
INNER JOIN productos pr ON pp.producto_id = pr.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
GROUP BY c.id, c.nombre, c.apellido
HAVING COUNT(DISTINCT cat.id) > 1;

-- 4. Mostrar productos con stock bajo que han sido muy vendidos
SELECT 
    p.nombre,
    p.stock,
    SUM(pp.cantidad) AS total_vendido,
    CASE 
        WHEN p.stock < 20 THEN 'Stock Bajo'
        WHEN p.stock < 40 THEN 'Stock Medio'
        ELSE 'Stock Alto'
    END AS nivel_stock
FROM productos p
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
GROUP BY p.id, p.nombre, p.stock
HAVING p.stock < 40
ORDER BY total_vendido DESC;

-- 5. Mostrar el historial completo de un cliente específico
SELECT 
    c.nombre, c.apellido,
    p.fecha_pedido,
    p.total,
    p.estado,
    pr.nombre AS producto,
    pp.cantidad,
    pp.precio_unitario,
    (pp.cantidad * pp.precio_unitario) AS subtotal
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
INNER JOIN productos pr ON pp.producto_id = pr.id
WHERE c.id = 1  -- Cambiar ID para ver otros clientes
ORDER BY p.fecha_pedido DESC;

-- =====================================================
-- CONSULTAS AVANZADAS CON MÚLTIPLES JOINs
-- =====================================================

-- 6. Análisis de rentabilidad por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT p.id) AS total_productos,
    AVG(p.precio) AS precio_promedio,
    SUM(pp.cantidad) AS unidades_vendidas,
    SUM(pp.cantidad * pp.precio_unitario) AS ingresos_totales,
    ROUND((SUM(pp.cantidad * pp.precio_unitario) / SUM(pp.cantidad)), 2) AS precio_promedio_vendido
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
GROUP BY c.id, c.nombre
ORDER BY ingresos_totales DESC;

-- 7. Análisis de comportamiento de clientes
SELECT 
    c.nombre, c.apellido,
    c.fecha_registro,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado,
    AVG(p.total) AS promedio_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido,
    DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_desde_ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre, c.apellido, c.fecha_registro
ORDER BY total_gastado DESC;

-- 8. Productos más populares por mes (si tuvieras fechas de pedido)
SELECT 
    MONTH(p.fecha_pedido) AS mes,
    pr.nombre AS producto,
    c.nombre AS categoria,
    SUM(pp.cantidad) AS unidades_vendidas,
    SUM(pp.cantidad * pp.precio_unitario) AS ingresos_mes
FROM pedidos p
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
INNER JOIN productos pr ON pp.producto_id = pr.id
INNER JOIN categorias c ON pr.categoria_id = c.id
WHERE p.estado = 'Completado'
GROUP BY MONTH(p.fecha_pedido), pr.id, pr.nombre, c.nombre
ORDER BY mes, unidades_vendidas DESC;

-- =====================================================
-- CONSULTAS DE MANTENIMIENTO Y AUDITORÍA
-- =====================================================

-- 9. Verificar integridad referencial
SELECT 
    'Productos sin categoría' AS problema,
    COUNT(*) AS cantidad
FROM productos 
WHERE categoria_id IS NULL
UNION ALL
SELECT 
    'Pedidos sin cliente' AS problema,
    COUNT(*) AS cantidad
FROM pedidos 
WHERE cliente_id IS NULL
UNION ALL
SELECT 
    'Productos en pedidos sin producto' AS problema,
    COUNT(*) AS cantidad
FROM productos_pedido pp
LEFT JOIN productos p ON pp.producto_id = p.id
WHERE p.id IS NULL;

-- 10. Análisis de productos huérfanos
SELECT 
    p.nombre,
    p.precio,
    p.stock,
    'Sin ventas' AS estado
FROM productos p
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
WHERE pp.id IS NULL
UNION ALL
SELECT 
    p.nombre,
    p.precio,
    p.stock,
    'Sin stock' AS estado
FROM productos p
WHERE p.stock = 0;

-- =====================================================
-- CONSULTAS PARA REPORTES EJECUTIVOS
-- =====================================================

-- 11. Resumen ejecutivo de ventas
SELECT 
    'Total de Ventas' AS metric,
    COUNT(DISTINCT p.id) AS valor
FROM pedidos p
WHERE p.estado = 'Completado'
UNION ALL
SELECT 
    'Total de Ingresos' AS metric,
    ROUND(SUM(p.total), 2) AS valor
FROM pedidos p
WHERE p.estado = 'Completado'
UNION ALL
SELECT 
    'Total de Clientes' AS metric,
    COUNT(DISTINCT c.id) AS valor
FROM clientes c
UNION ALL
SELECT 
    'Total de Productos' AS metric,
    COUNT(DISTINCT pr.id) AS valor
FROM productos pr;

-- 12. Top categorías por rendimiento
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT pr.id) AS productos_disponibles,
    SUM(pr.stock) AS stock_total,
    SUM(pp.cantidad) AS unidades_vendidas,
    SUM(pp.cantidad * pp.precio_unitario) AS ingresos_totales,
    ROUND((SUM(pp.cantidad * pp.precio_unitario) / SUM(pr.stock)), 2) AS rentabilidad_por_stock
FROM categorias c
LEFT JOIN productos pr ON c.id = pr.categoria_id
LEFT JOIN productos_pedido pp ON pr.id = pp.producto_id
GROUP BY c.id, c.nombre
ORDER BY ingresos_totales DESC;

-- =====================================================
-- FIN DEL ARCHIVO DE EJERCICIOS
-- =====================================================
-- 
-- Para practicar más, intenta:
-- 1. Modificar las consultas para agregar más filtros
-- 2. Crear consultas que combinen múltiples conceptos
-- 3. Agregar más datos de ejemplo
-- 4. Crear índices para mejorar el rendimiento
-- 5. Analizar el plan de ejecución de las consultas
