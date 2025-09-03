# Clase 9: Optimización de Consultas

## Objetivos de la Clase
- Comprender técnicas avanzadas de optimización de consultas
- Analizar y mejorar el rendimiento de consultas complejas
- Implementar estrategias de optimización específicas
- Monitorear y medir mejoras de rendimiento

## Contenido Teórico

### 1. ¿Qué es la Optimización de Consultas?

**Optimización de Consultas** es el proceso de mejorar el rendimiento de las consultas SQL mediante técnicas específicas, análisis de planes de ejecución y ajustes en la estructura de datos.

#### Objetivos de la Optimización:
- **Reducir tiempo de ejecución**: Consultas más rápidas
- **Minimizar uso de recursos**: Menos CPU, memoria y I/O
- **Mejorar escalabilidad**: Soporte para más usuarios
- **Optimizar throughput**: Más consultas por segundo

### 2. Análisis de Planes de Ejecución

#### EXPLAIN - Herramienta Principal
```sql
-- Análisis básico
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- Análisis detallado con formato JSON
EXPLAIN FORMAT=JSON SELECT * FROM productos WHERE precio > 100;

-- Análisis con estadísticas de ejecución (MySQL 8.0+)
EXPLAIN ANALYZE SELECT * FROM productos WHERE precio > 100;
```

#### Interpretación de EXPLAIN:
- **id**: Número de secuencia de la consulta
- **select_type**: Tipo de consulta (SIMPLE, PRIMARY, SUBQUERY, etc.)
- **table**: Tabla o alias utilizado
- **type**: Tipo de acceso (ALL, index, range, ref, const, etc.)
- **possible_keys**: Índices que podrían usarse
- **key**: Índice realmente utilizado
- **key_len**: Longitud del índice utilizado
- **ref**: Columnas comparadas con el índice
- **rows**: Número estimado de filas examinadas
- **Extra**: Información adicional sobre la ejecución

### 3. Técnicas de Optimización

#### Optimización de JOINs
```sql
-- JOIN ineficiente
SELECT * FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN productos p ON v.producto_id = p.id;

-- JOIN optimizado
SELECT v.id, v.fecha_venta, v.total,
       c.nombre as cliente,
       p.nombre as producto
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN productos p ON v.producto_id = p.id
WHERE v.fecha_venta >= '2024-01-01';
```

#### Optimización de Subconsultas
```sql
-- Subconsulta ineficiente
SELECT * FROM productos 
WHERE categoria_id IN (
    SELECT id FROM categorias WHERE activa = TRUE
);

-- JOIN optimizado
SELECT p.* FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.activa = TRUE;
```

#### Optimización de Agregaciones
```sql
-- Agregación ineficiente
SELECT COUNT(*) FROM ventas WHERE fecha_venta >= '2024-01-01';

-- Agregación optimizada con índice
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
SELECT COUNT(*) FROM ventas WHERE fecha_venta >= '2024-01-01';
```

### 4. Estrategias de Optimización Específicas

#### Uso de Índices Estratégicos
```sql
-- Índice compuesto para consultas complejas
CREATE INDEX idx_ventas_cliente_fecha_estado ON ventas(cliente_id, fecha_venta, estado);

-- Índice parcial para datos específicos
CREATE INDEX idx_productos_activos ON productos(nombre) WHERE activo = TRUE;

-- Índice de cobertura para evitar acceso a tabla
CREATE INDEX idx_ventas_cobertura ON ventas(cliente_id, fecha_venta, total);
```

#### Optimización de Consultas con LIMIT
```sql
-- Consulta ineficiente con LIMIT
SELECT * FROM productos ORDER BY precio DESC LIMIT 10;

-- Consulta optimizada
SELECT * FROM productos 
WHERE precio >= (
    SELECT precio FROM productos ORDER BY precio DESC LIMIT 9, 1
)
ORDER BY precio DESC LIMIT 10;
```

#### Optimización de Consultas con DISTINCT
```sql
-- DISTINCT ineficiente
SELECT DISTINCT categoria FROM productos;

-- Optimización con GROUP BY
SELECT categoria FROM productos GROUP BY categoria;

-- Optimización con índice
CREATE INDEX idx_productos_categoria ON productos(categoria);
SELECT DISTINCT categoria FROM productos;
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Ventas

#### Consultas No Optimizadas:
```sql
-- Crear base de datos
CREATE DATABASE ventas_optimizacion;
USE ventas_optimizacion;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(100),
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente'
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id)
);

-- Insertar datos de ejemplo
INSERT INTO clientes (nombre, email, ciudad, estado) VALUES
('Juan Pérez', 'juan@email.com', 'Ciudad de México', 'CDMX'),
('María García', 'maria@email.com', 'Guadalajara', 'Jalisco'),
('Carlos López', 'carlos@email.com', 'Monterrey', 'Nuevo León');

INSERT INTO productos (nombre, precio, categoria, stock) VALUES
('Laptop', 15000.00, 'Electrónicos', 10),
('Mouse', 500.00, 'Electrónicos', 50),
('Sofá', 8000.00, 'Hogar', 5);

INSERT INTO ventas (cliente_id, fecha_venta, total, estado) VALUES
(1, '2024-01-15', 15500.00, 'completada'),
(2, '2024-01-16', 1000.00, 'completada'),
(3, '2024-01-17', 8000.00, 'pendiente');

INSERT INTO detalle_ventas VALUES
(1, 1, 1, 15000.00, 15000.00),
(1, 2, 1, 500.00, 500.00),
(2, 2, 2, 500.00, 1000.00),
(3, 3, 1, 8000.00, 8000.00);
```

### Ejemplo 2: Análisis de Rendimiento

#### Consultas para Analizar:
```sql
-- Consulta 1: Ventas por cliente (no optimizada)
EXPLAIN SELECT 
    c.nombre,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as total_ingresos
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre;

-- Consulta 2: Productos más vendidos (no optimizada)
EXPLAIN SELECT 
    p.nombre,
    SUM(dv.cantidad) as total_vendido,
    SUM(dv.subtotal) as ingresos_totales
FROM productos p
JOIN detalle_ventas dv ON p.id = dv.producto_id
JOIN ventas v ON dv.venta_id = v.id
WHERE v.estado = 'completada'
GROUP BY p.id, p.nombre
ORDER BY total_vendido DESC;
```

## Ejercicios Prácticos

### Ejercicio 1: Analizar y Optimizar Consultas Básicas
**Objetivo**: Analizar consultas simples y aplicar optimizaciones.

```sql
-- Consulta no optimizada
EXPLAIN SELECT * FROM productos WHERE precio > 1000;

-- Crear índice para optimizar
CREATE INDEX idx_productos_precio ON productos(precio);

-- Analizar después de la optimización
EXPLAIN SELECT * FROM productos WHERE precio > 1000;

-- Consulta con múltiples condiciones
EXPLAIN SELECT * FROM productos 
WHERE precio > 1000 AND categoria = 'Electrónicos' AND activo = TRUE;

-- Crear índice compuesto
CREATE INDEX idx_productos_precio_categoria_activo ON productos(precio, categoria, activo);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM productos 
WHERE precio > 1000 AND categoria = 'Electrónicos' AND activo = TRUE;
```

### Ejercicio 2: Optimizar JOINs Complejos
**Objetivo**: Optimizar consultas con múltiples JOINs.

```sql
-- Consulta con JOINs no optimizada
EXPLAIN SELECT 
    c.nombre as cliente,
    p.nombre as producto,
    v.fecha_venta,
    v.total,
    dv.cantidad,
    dv.precio_unitario
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
WHERE v.fecha_venta >= '2024-01-01'
AND v.estado = 'completada'
ORDER BY v.fecha_venta DESC;

-- Crear índices para optimizar JOINs
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_detalle_ventas_venta ON detalle_ventas(venta_id);
CREATE INDEX idx_detalle_ventas_producto ON detalle_ventas(producto_id);

-- Crear índices compuestos
CREATE INDEX idx_ventas_fecha_estado ON ventas(fecha_venta, estado);
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);

-- Analizar consulta optimizada
EXPLAIN SELECT 
    c.nombre as cliente,
    p.nombre as producto,
    v.fecha_venta,
    v.total,
    dv.cantidad,
    dv.precio_unitario
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
WHERE v.fecha_venta >= '2024-01-01'
AND v.estado = 'completada'
ORDER BY v.fecha_venta DESC;
```

### Ejercicio 3: Optimizar Subconsultas
**Objetivo**: Convertir subconsultas ineficientes en JOINs optimizados.

```sql
-- Subconsulta ineficiente
EXPLAIN SELECT * FROM productos 
WHERE id IN (
    SELECT producto_id FROM detalle_ventas 
    WHERE cantidad > 5
);

-- Convertir a JOIN optimizado
EXPLAIN SELECT DISTINCT p.* FROM productos p
JOIN detalle_ventas dv ON p.id = dv.producto_id
WHERE dv.cantidad > 5;

-- Subconsulta con EXISTS
EXPLAIN SELECT * FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM ventas v 
    WHERE v.cliente_id = c.id 
    AND v.total > 10000
);

-- Optimizar con JOIN
EXPLAIN SELECT DISTINCT c.* FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
WHERE v.total > 10000;

-- Crear índices para optimizar
CREATE INDEX idx_detalle_ventas_cantidad ON detalle_ventas(cantidad);
CREATE INDEX idx_ventas_total ON ventas(total);
```

### Ejercicio 4: Optimizar Agregaciones
**Objetivo**: Optimizar consultas con funciones de agregación.

```sql
-- Agregación no optimizada
EXPLAIN SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio,
    MAX(precio) as precio_maximo,
    MIN(precio) as precio_minimo
FROM productos
WHERE activo = TRUE
GROUP BY categoria;

-- Crear índices para optimizar agregaciones
CREATE INDEX idx_productos_categoria_activo ON productos(categoria, activo);
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);

-- Analizar consulta optimizada
EXPLAIN SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio,
    MAX(precio) as precio_maximo,
    MIN(precio) as precio_minimo
FROM productos
WHERE activo = TRUE
GROUP BY categoria;

-- Agregación con HAVING
EXPLAIN SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio
FROM productos
WHERE activo = TRUE
GROUP BY categoria
HAVING COUNT(*) > 1;
```

### Ejercicio 5: Optimizar Consultas con ORDER BY
**Objetivo**: Optimizar consultas que requieren ordenamiento.

```sql
-- Ordenamiento no optimizado
EXPLAIN SELECT * FROM productos 
WHERE activo = TRUE
ORDER BY precio DESC
LIMIT 10;

-- Crear índice para optimizar ORDER BY
CREATE INDEX idx_productos_activo_precio ON productos(activo, precio);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM productos 
WHERE activo = TRUE
ORDER BY precio DESC
LIMIT 10;

-- Ordenamiento con múltiples columnas
EXPLAIN SELECT * FROM ventas 
WHERE estado = 'completada'
ORDER BY fecha_venta DESC, total DESC
LIMIT 20;

-- Crear índice compuesto para ordenamiento
CREATE INDEX idx_ventas_estado_fecha_total ON ventas(estado, fecha_venta, total);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM ventas 
WHERE estado = 'completada'
ORDER BY fecha_venta DESC, total DESC
LIMIT 20;
```

### Ejercicio 6: Optimizar Consultas con LIMIT y OFFSET
**Objetivo**: Optimizar paginación de resultados.

```sql
-- Paginación ineficiente
EXPLAIN SELECT * FROM productos 
ORDER BY precio DESC
LIMIT 10 OFFSET 100;

-- Optimización con subconsulta
EXPLAIN SELECT * FROM productos 
WHERE precio <= (
    SELECT precio FROM productos 
    ORDER BY precio DESC 
    LIMIT 1 OFFSET 109
)
ORDER BY precio DESC
LIMIT 10;

-- Crear índice para optimizar paginación
CREATE INDEX idx_productos_precio_desc ON productos(precio DESC);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM productos 
WHERE precio <= (
    SELECT precio FROM productos 
    ORDER BY precio DESC 
    LIMIT 1 OFFSET 109
)
ORDER BY precio DESC
LIMIT 10;
```

### Ejercicio 7: Optimizar Consultas con DISTINCT
**Objetivo**: Optimizar consultas que usan DISTINCT.

```sql
-- DISTINCT no optimizado
EXPLAIN SELECT DISTINCT categoria FROM productos WHERE activo = TRUE;

-- Optimización con GROUP BY
EXPLAIN SELECT categoria FROM productos 
WHERE activo = TRUE
GROUP BY categoria;

-- Crear índice para optimizar DISTINCT
CREATE INDEX idx_productos_categoria_activo ON productos(categoria, activo);

-- Analizar consulta optimizada
EXPLAIN SELECT DISTINCT categoria FROM productos WHERE activo = TRUE;

-- DISTINCT con múltiples columnas
EXPLAIN SELECT DISTINCT categoria, activo FROM productos;

-- Optimización con índice compuesto
CREATE INDEX idx_productos_categoria_activo_compuesto ON productos(categoria, activo);

-- Analizar consulta optimizada
EXPLAIN SELECT DISTINCT categoria, activo FROM productos;
```

### Ejercicio 8: Crear Sistema de Monitoreo de Consultas
**Objetivo**: Implementar sistema para monitorear rendimiento de consultas.

```sql
-- Crear tabla de monitoreo de consultas
CREATE TABLE monitoreo_consultas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    consulta_hash VARCHAR(64) NOT NULL,
    consulta_sql TEXT NOT NULL,
    tiempo_ejecucion DECIMAL(10,6),
    filas_examinadas INT,
    filas_devueltas INT,
    fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100),
    base_datos VARCHAR(100)
);

-- Crear tabla de consultas lentas
CREATE TABLE consultas_lentas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    consulta_hash VARCHAR(64) NOT NULL,
    consulta_sql TEXT NOT NULL,
    tiempo_ejecucion DECIMAL(10,6),
    fecha_deteccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    optimizacion_sugerida TEXT
);

-- Procedimiento para monitorear consultas
DELIMITER //
CREATE PROCEDURE monitorear_consulta(
    IN consulta_sql TEXT,
    IN tiempo_ejecucion DECIMAL(10,6),
    IN filas_examinadas INT,
    IN filas_devueltas INT
)
BEGIN
    DECLARE consulta_hash VARCHAR(64);
    DECLARE consulta_existente INT;
    
    -- Generar hash de la consulta
    SET consulta_hash = SHA2(consulta_sql, 256);
    
    -- Verificar si la consulta ya existe
    SELECT COUNT(*) INTO consulta_existente
    FROM monitoreo_consultas
    WHERE consulta_hash = consulta_hash;
    
    -- Insertar o actualizar registro
    IF consulta_existente = 0 THEN
        INSERT INTO monitoreo_consultas (
            consulta_hash, consulta_sql, tiempo_ejecucion, 
            filas_examinadas, filas_devueltas
        ) VALUES (
            consulta_hash, consulta_sql, tiempo_ejecucion,
            filas_examinadas, filas_devueltas
        );
    ELSE
        UPDATE monitoreo_consultas 
        SET tiempo_ejecucion = tiempo_ejecucion,
            filas_examinadas = filas_examinadas,
            filas_devueltas = filas_devueltas,
            fecha_ejecucion = NOW()
        WHERE consulta_hash = consulta_hash;
    END IF;
    
    -- Detectar consultas lentas
    IF tiempo_ejecucion > 1.0 THEN
        INSERT INTO consultas_lentas (consulta_hash, consulta_sql, tiempo_ejecucion)
        VALUES (consulta_hash, consulta_sql, tiempo_ejecucion);
    END IF;
    
    SELECT 'Consulta monitoreada' AS resultado;
END//
DELIMITER ;

-- Procedimiento para analizar consultas lentas
DELIMITER //
CREATE PROCEDURE analizar_consultas_lentas()
BEGIN
    SELECT 
        cl.consulta_sql,
        cl.tiempo_ejecucion,
        cl.fecha_deteccion,
        mc.filas_examinadas,
        mc.filas_devueltas,
        CASE 
            WHEN mc.filas_examinadas > mc.filas_devueltas * 10 THEN 'Crear índices'
            WHEN cl.consulta_sql LIKE '%SELECT *%' THEN 'Especificar columnas'
            WHEN cl.consulta_sql LIKE '%IN (SELECT%' THEN 'Convertir a JOIN'
            ELSE 'Revisar plan de ejecución'
        END AS optimizacion_sugerida
    FROM consultas_lentas cl
    JOIN monitoreo_consultas mc ON cl.consulta_hash = mc.consulta_hash
    ORDER BY cl.tiempo_ejecucion DESC
    LIMIT 10;
END//
DELIMITER ;
```

### Ejercicio 9: Optimizar Consultas Complejas
**Objetivo**: Optimizar consultas con múltiples operaciones.

```sql
-- Consulta compleja no optimizada
EXPLAIN SELECT 
    c.nombre as cliente,
    c.ciudad,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as total_ingresos,
    AVG(v.total) as promedio_venta,
    MAX(v.total) as venta_maxima
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE v.estado = 'completada' OR v.estado IS NULL
GROUP BY c.id, c.nombre, c.ciudad
HAVING COUNT(v.id) > 0
ORDER BY total_ingresos DESC
LIMIT 10;

-- Optimización paso a paso
-- 1. Crear índices necesarios
CREATE INDEX idx_ventas_cliente_estado ON ventas(cliente_id, estado);
CREATE INDEX idx_ventas_total ON ventas(total);

-- 2. Optimizar la consulta
EXPLAIN SELECT 
    c.nombre as cliente,
    c.ciudad,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as total_ingresos,
    AVG(v.total) as promedio_venta,
    MAX(v.total) as venta_maxima
FROM clientes c
INNER JOIN ventas v ON c.id = v.cliente_id
WHERE v.estado = 'completada'
GROUP BY c.id, c.nombre, c.ciudad
ORDER BY total_ingresos DESC
LIMIT 10;

-- Consulta con subconsulta optimizada
EXPLAIN SELECT 
    p.nombre as producto,
    p.categoria,
    COUNT(dv.venta_id) as veces_vendido,
    SUM(dv.cantidad) as total_vendido,
    SUM(dv.subtotal) as ingresos_totales
FROM productos p
JOIN detalle_ventas dv ON p.id = dv.producto_id
JOIN ventas v ON dv.venta_id = v.id
WHERE v.estado = 'completada'
AND v.fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.id, p.nombre, p.categoria
HAVING COUNT(dv.venta_id) > 1
ORDER BY ingresos_totales DESC;
```

### Ejercicio 10: Caso de Estudio Completo
**Objetivo**: Optimizar sistema completo de e-commerce.

```sql
-- Crear sistema de e-commerce optimizado
CREATE DATABASE ecommerce_optimizado;
USE ecommerce_optimizado;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    fecha_envio DATE,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    metodo_pago VARCHAR(50)
);

-- Tabla de detalle de pedidos
CREATE TABLE detalle_pedidos (
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (pedido_id, producto_id)
);

-- Crear índices para optimización
-- Índices para clientes
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
CREATE INDEX idx_clientes_estado ON clientes(estado);
CREATE INDEX idx_clientes_activo ON clientes(activo);

-- Índices para productos
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_stock ON productos(stock);

-- Índices compuestos para productos
CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id, activo);
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);

-- Índices para pedidos
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
CREATE INDEX idx_pedidos_fecha_envio ON pedidos(fecha_envio);

-- Índices compuestos para pedidos
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);
CREATE INDEX idx_pedidos_estado_fecha ON pedidos(estado, fecha_pedido);

-- Índices para detalle de pedidos
CREATE INDEX idx_detalle_pedidos_producto ON detalle_pedidos(producto_id);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipos y accesorios deportivos');

INSERT INTO productos (nombre, descripcion, precio, categoria_id, stock) VALUES
('Laptop', 'Computadora portátil', 15000.00, 1, 10),
('Mouse', 'Mouse inalámbrico', 500.00, 1, 50),
('Sofá', 'Sofá de 3 plazas', 8000.00, 2, 5),
('Pelota', 'Pelota de fútbol', 200.00, 3, 20);

INSERT INTO clientes (nombre, apellido, email, ciudad, estado) VALUES
('Juan', 'Pérez', 'juan.perez@email.com', 'Ciudad de México', 'CDMX'),
('María', 'García', 'maria.garcia@email.com', 'Guadalajara', 'Jalisco'),
('Carlos', 'López', 'carlos.lopez@email.com', 'Monterrey', 'Nuevo León');

INSERT INTO pedidos (cliente_id, fecha_pedido, total, estado) VALUES
(1, '2024-01-15', 15500.00, 'entregado'),
(2, '2024-01-16', 1000.00, 'enviado'),
(3, '2024-01-17', 8000.00, 'procesando');

INSERT INTO detalle_pedidos VALUES
(1, 1, 1, 15000.00, 15000.00),  -- Laptop
(1, 2, 1, 500.00, 500.00),      -- Mouse
(2, 2, 2, 500.00, 1000.00),     -- Mouse x2
(3, 3, 1, 8000.00, 8000.00);    -- Sofá

-- Consultas optimizadas para el sistema
-- 1. Productos más vendidos
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    c.nombre as categoria,
    SUM(dp.cantidad) as total_vendido,
    SUM(dp.subtotal) as ingresos_totales
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
JOIN detalle_pedidos dp ON p.id = dp.producto_id
JOIN pedidos ped ON dp.pedido_id = ped.id
WHERE ped.estado = 'entregado'
GROUP BY p.id, p.nombre, p.precio, c.nombre
ORDER BY total_vendido DESC;

-- 2. Clientes por región
EXPLAIN SELECT 
    c.estado,
    c.ciudad,
    COUNT(DISTINCT c.id) as total_clientes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ingresos_totales
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.activo = TRUE
GROUP BY c.estado, c.ciudad
ORDER BY ingresos_totales DESC;

-- 3. Productos con stock bajo
EXPLAIN SELECT 
    p.nombre,
    p.stock,
    p.precio,
    c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock < 10
AND p.activo = TRUE
ORDER BY p.stock ASC;

-- 4. Ventas por mes
EXPLAIN SELECT 
    YEAR(p.fecha_pedido) as año,
    MONTH(p.fecha_pedido) as mes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ingresos_totales,
    AVG(p.total) as promedio_pedido
FROM pedidos p
WHERE p.estado = 'entregado'
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año DESC, mes DESC;

-- 5. Clientes con más compras
EXPLAIN SELECT 
    c.nombre,
    c.apellido,
    c.email,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as total_gastado,
    AVG(p.total) as promedio_pedido
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado = 'entregado'
GROUP BY c.id, c.nombre, c.apellido, c.email
ORDER BY total_gastado DESC
LIMIT 10;
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Optimización de Consultas**: Mejora del rendimiento mediante técnicas específicas
2. **EXPLAIN**: Herramienta para analizar planes de ejecución
3. **Índices Estratégicos**: Creación de índices para optimizar consultas
4. **JOINs Optimizados**: Mejora del rendimiento de uniones
5. **Monitoreo**: Seguimiento del rendimiento de consultas

### Próximos Pasos:
- Aprender técnicas avanzadas de optimización
- Estudiar optimización de bases de datos distribuidas
- Practicar con casos complejos de rendimiento

### Recursos Adicionales:
- Documentación sobre optimización en MySQL
- Herramientas de análisis de rendimiento
- Casos de estudio de optimización
