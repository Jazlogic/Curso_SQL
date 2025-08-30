# 🎯 Senior 4: Optimización Avanzada y Análisis de Consultas

## 📖 Teoría

### ¿Qué es la Optimización de Consultas?
La optimización de consultas es el proceso de mejorar el rendimiento de las consultas SQL mediante el análisis del plan de ejecución y la implementación de técnicas de optimización.

### Herramientas de Análisis
1. **EXPLAIN**: Muestra el plan de ejecución de una consulta
2. **EXPLAIN ANALYZE**: Ejecuta la consulta y muestra estadísticas detalladas
3. **SHOW PROFILE**: Muestra información de rendimiento de consultas
4. **Performance Schema**: Monitoreo avanzado del rendimiento

### Técnicas de Optimización
- **Índices**: Crear y mantener índices apropiados
- **Reescritura de Consultas**: Mejorar la estructura lógica
- **Particionamiento**: Dividir tablas grandes en partes más pequeñas
- **Normalización/Desnormalización**: Balancear estructura vs rendimiento

### Factores de Rendimiento
- **Tamaño de datos**: Volumen de información procesada
- **Complejidad de consultas**: Número de JOINs y subconsultas
- **Configuración del servidor**: Memoria, CPU, configuración MySQL
- **Diseño de esquema**: Estructura de tablas y relaciones

## 💡 Ejemplos Prácticos

### Ejemplo 1: Análisis con EXPLAIN
```sql
-- Analizar plan de ejecución
EXPLAIN SELECT 
    p.nombre, p.precio, c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock > 10 AND p.precio < 100
ORDER BY p.precio DESC;

-- Resultado muestra:
-- type: ref (usa índice)
-- key: idx_productos_stock_precio
-- rows: 150 (filas estimadas)
-- Extra: Using where; Using filesort
```

### Ejemplo 2: Optimización con Índices
```sql
-- Crear índice compuesto para la consulta anterior
CREATE INDEX idx_productos_stock_precio ON productos(stock, precio);

-- Crear índice para JOIN
CREATE INDEX idx_productos_categoria ON productos(categoria_id);

-- Verificar uso de índices
SHOW INDEX FROM productos;
```

### Ejemplo 3: Reescritura de Consulta
```sql
-- Consulta original (ineficiente)
SELECT * FROM productos p
WHERE p.id IN (
    SELECT DISTINCT producto_id 
    FROM productos_pedido 
    WHERE cantidad > 5
);

-- Consulta optimizada con JOIN
SELECT DISTINCT p.* 
FROM productos p
INNER JOIN productos_pedido pp ON p.id = pp.producto_id
WHERE pp.cantidad > 5;
```

## 🎯 Ejercicios

### Ejercicio 1: Análisis y Optimización de Consultas
Analiza y optimiza las siguientes consultas:

1. Consulta compleja con múltiples JOINs
2. Consulta con subconsultas anidadas
3. Consulta con funciones agregadas y GROUP BY
4. Consulta con ORDER BY y LIMIT
5. Consulta con UNION y múltiples tablas

**Solución:**
```sql
-- 1. Consulta compleja con múltiples JOINs
-- CONSULTA ORIGINAL (ineficiente)
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    cat.nombre AS categoria,
    pp.cantidad,
    pp.precio_unitario,
    ped.fecha_pedido
FROM clientes c
INNER JOIN pedidos ped ON c.id = ped.cliente_id
INNER JOIN productos_pedido pp ON ped.id = pp.pedido_id
INNER JOIN productos p ON pp.producto_id = p.id
INNER JOIN categorias cat ON p.categoria_id = cat.id
WHERE ped.estado = 'Completado'
AND ped.fecha_pedido >= '2024-01-01'
ORDER BY ped.fecha_pedido DESC;

-- OPTIMIZACIÓN: Crear índices apropiados
CREATE INDEX idx_pedidos_estado_fecha ON pedidos(estado, fecha_pedido);
CREATE INDEX idx_productos_pedido_pedido ON productos_pedido(pedido_id);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);

-- CONSULTA OPTIMIZADA: Usar índices y limitar columnas
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    cat.nombre AS categoria,
    pp.cantidad,
    pp.precio_unitario,
    ped.fecha_pedido
FROM pedidos ped
INNER JOIN clientes c ON ped.cliente_id = c.id
INNER JOIN productos_pedido pp ON ped.id = pp.pedido_id
INNER JOIN productos p ON pp.producto_id = p.id
INNER JOIN categorias cat ON p.categoria_id = cat.id
WHERE ped.estado = 'Completado'
AND ped.fecha_pedido >= '2024-01-01'
ORDER BY ped.fecha_pedido DESC;

-- 2. Consulta con subconsultas anidadas
-- CONSULTA ORIGINAL (ineficiente)
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    (SELECT COUNT(*) FROM productos_pedido pp WHERE pp.producto_id = p.id) AS total_ventas
FROM productos p
WHERE p.stock > 0;

-- OPTIMIZACIÓN: Reemplazar subconsulta con JOIN
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    COALESCE(COUNT(pp.id), 0) AS total_ventas
FROM productos p
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
WHERE p.stock > 0
GROUP BY p.id, p.nombre, p.precio;

-- 3. Consulta con funciones agregadas
-- CONSULTA ORIGINAL (ineficiente)
EXPLAIN SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    AVG(p.precio) AS precio_promedio,
    SUM(p.stock) AS stock_total
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 5;

-- OPTIMIZACIÓN: Usar índices y limitar datos
CREATE INDEX idx_productos_categoria_precio ON productos(categoria_id, precio);
CREATE INDEX idx_productos_categoria_stock ON productos(categoria_id, stock);

-- CONSULTA OPTIMIZADA
EXPLAIN SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    ROUND(AVG(p.precio), 2) AS precio_promedio,
    SUM(p.stock) AS stock_total
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
WHERE p.activo = 1
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 5;
```

### Ejercicio 2: Análisis de Planes de Ejecución
Analiza los siguientes planes de ejecución e identifica problemas:

1. Plan con table scan completo
2. Plan con múltiples subconsultas
3. Plan con ordenamiento costoso
4. Plan con JOINs ineficientes
5. Plan con uso incorrecto de índices

**Solución:**
```sql
-- 1. Plan con table scan completo
EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%laptop%';

-- PROBLEMA: LIKE con comodín al inicio no puede usar índices
-- SOLUCIÓN: Crear índice de texto completo o reestructurar consulta
CREATE FULLTEXT INDEX idx_productos_nombre ON productos(nombre);

-- Consulta optimizada
EXPLAIN SELECT * FROM productos 
WHERE MATCH(nombre) AGAINST('laptop' IN NATURAL LANGUAGE MODE);

-- 2. Plan con múltiples subconsultas
EXPLAIN SELECT 
    p.nombre,
    (SELECT COUNT(*) FROM productos_pedido pp WHERE pp.producto_id = p.id) AS ventas,
    (SELECT AVG(precio) FROM productos WHERE categoria_id = p.categoria_id) AS precio_promedio_categoria
FROM productos p;

-- PROBLEMA: Subconsultas se ejecutan para cada fila
-- SOLUCIÓN: Usar JOINs y agregaciones
EXPLAIN SELECT 
    p.nombre,
    COALESCE(COUNT(pp.id), 0) AS ventas,
    ROUND(AVG(p2.precio), 2) AS precio_promedio_categoria
FROM productos p
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
LEFT JOIN productos p2 ON p.categoria_id = p2.categoria_id
GROUP BY p.id, p.nombre, p.categoria_id;

-- 3. Plan con ordenamiento costoso
EXPLAIN SELECT 
    p.nombre, p.precio, c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.precio DESC, p.nombre;

-- PROBLEMA: ORDER BY requiere ordenamiento en memoria
-- SOLUCIÓN: Crear índice compuesto para ORDER BY
CREATE INDEX idx_productos_precio_nombre ON productos(precio DESC, nombre);

-- 4. Plan con JOINs ineficientes
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    cat.nombre AS categoria
FROM clientes c
CROSS JOIN productos p
CROSS JOIN categorias cat
WHERE c.id = 1 AND p.categoria_id = cat.id;

-- PROBLEMA: CROSS JOIN innecesario
-- SOLUCIÓN: Usar INNER JOIN apropiado
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    cat.nombre AS categoria
FROM clientes c
INNER JOIN productos p ON p.categoria_id = cat.id
INNER JOIN categorias cat ON p.categoria_id = cat.id
WHERE c.id = 1;
```

### Ejercicio 3: Optimización de Índices
Crea y optimiza índices para:

1. Consultas de búsqueda por texto
2. Consultas de rango y comparación
3. Consultas con JOINs múltiples
4. Consultas con ORDER BY y GROUP BY
5. Consultas con funciones de fecha

**Solución:**
```sql
-- 1. Índices para búsqueda por texto
-- Índice para búsquedas exactas
CREATE INDEX idx_productos_nombre_exacto ON productos(nombre);

-- Índice de texto completo para búsquedas complejas
CREATE FULLTEXT INDEX idx_productos_nombre_descripcion ON productos(nombre, descripcion);

-- Índice para búsquedas con LIKE (solo si no empieza con comodín)
CREATE INDEX idx_productos_nombre_like ON productos(nombre);

-- 2. Índices para consultas de rango
-- Índice compuesto para filtros múltiples
CREATE INDEX idx_productos_precio_stock ON productos(precio, stock);

-- Índice para rangos de fechas
CREATE INDEX idx_pedidos_fecha_estado ON pedidos(fecha_pedido, estado);

-- Índice para rangos de precios
CREATE INDEX idx_productos_precio_rango ON productos(precio);

-- 3. Índices para JOINs múltiples
-- Índice para la tabla principal del JOIN
CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id, activo);

-- Índice para la tabla de relación
CREATE INDEX idx_productos_pedido_producto_pedido ON productos_pedido(producto_id, pedido_id);

-- Índice para la tabla de pedidos
CREATE INDEX idx_pedidos_cliente_fecha_estado ON pedidos(cliente_id, fecha_pedido, estado);

-- 4. Índices para ORDER BY y GROUP BY
-- Índice para ordenamiento por precio
CREATE INDEX idx_productos_precio_orden ON productos(precio DESC);

-- Índice para agrupación por categoría
CREATE INDEX idx_productos_categoria_stock ON productos(categoria_id, stock);

-- Índice compuesto para ordenamiento y agrupación
CREATE INDEX idx_productos_categoria_precio_stock ON productos(categoria_id, precio DESC, stock);

-- 5. Índices para funciones de fecha
-- Índice para consultas por año
CREATE INDEX idx_pedidos_fecha_anio ON pedidos(YEAR(fecha_pedido));

-- Índice para consultas por mes
CREATE INDEX idx_pedidos_fecha_mes ON pedidos(MONTH(fecha_pedido));

-- Índice para consultas por día de la semana
CREATE INDEX idx_pedidos_fecha_dia ON pedidos(DAYOFWEEK(fecha_pedido));

-- Índice para consultas de rango de fechas
CREATE INDEX idx_pedidos_fecha_rango ON pedidos(fecha_pedido);
```

### Ejercicio 4: Particionamiento y Optimización de Esquemas
Implementa técnicas avanzadas para:

1. Particionar tablas grandes por fecha
2. Crear tablas de resumen para reportes
3. Implementar archivo de datos optimizado
4. Usar vistas materializadas
5. Optimizar tipos de datos

**Solución:**
```sql
-- 1. Particionamiento por fecha
-- Crear tabla particionada por año
CREATE TABLE pedidos_particionados (
    id INT,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    estado VARCHAR(50)
) PARTITION BY RANGE (YEAR(fecha_pedido)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- 2. Tablas de resumen para reportes
-- Crear tabla de resumen diario
CREATE TABLE resumen_ventas_diario (
    fecha DATE PRIMARY KEY,
    total_ventas DECIMAL(12,2),
    total_pedidos INT,
    clientes_activos INT,
    productos_vendidos INT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Procedimiento para actualizar resumen
DELIMITER //
CREATE PROCEDURE actualizar_resumen_ventas_diario(IN fecha_resumen DATE)
BEGIN
    INSERT INTO resumen_ventas_diario (
        fecha, total_ventas, total_pedidos, clientes_activos, productos_vendidos
    )
    SELECT 
        fecha_resumen,
        COALESCE(SUM(total), 0),
        COUNT(*),
        COUNT(DISTINCT cliente_id),
        COUNT(DISTINCT pp.producto_id)
    FROM pedidos p
    LEFT JOIN productos_pedido pp ON p.id = pp.pedido_id
    WHERE DATE(p.fecha_pedido) = fecha_resumen
    AND p.estado = 'Completado'
    ON DUPLICATE KEY UPDATE
        total_ventas = VALUES(total_ventas),
        total_pedidos = VALUES(total_pedidos),
        clientes_activos = VALUES(clientes_activos),
        productos_vendidos = VALUES(productos_vendidos),
        fecha_actualizacion = NOW();
END //
DELIMITER ;

-- 3. Optimización de tipos de datos
-- Tabla optimizada con tipos apropiados
CREATE TABLE productos_optimizados (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(8,2) UNSIGNED NOT NULL,
    stock SMALLINT UNSIGNED DEFAULT 0,
    categoria_id TINYINT UNSIGNED NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_categoria_activo (categoria_id, activo),
    INDEX idx_precio_stock (precio, stock),
    INDEX idx_nombre (nombre)
) ENGINE=InnoDB;

-- 4. Vistas materializadas (simuladas con tablas)
CREATE TABLE vista_materializada_productos_categoria (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(100),
    total_productos INT,
    precio_promedio DECIMAL(8,2),
    stock_total INT,
    ultima_actualizacion TIMESTAMP
);

-- Trigger para mantener vista materializada actualizada
DELIMITER //
CREATE TRIGGER sync_vista_materializada_productos
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO vista_materializada_productos_categoria (
        categoria_id, nombre_categoria, total_productos, 
        precio_promedio, stock_total, ultima_actualizacion
    )
    SELECT 
        c.id, c.nombre, COUNT(p.id), 
        ROUND(AVG(p.precio), 2), SUM(p.stock), NOW()
    FROM categorias c
    INNER JOIN productos p ON c.id = p.categoria_id
    WHERE c.id = NEW.categoria_id
    GROUP BY c.id, c.nombre
    ON DUPLICATE KEY UPDATE
        total_productos = VALUES(total_productos),
        precio_promedio = VALUES(precio_promedio),
        stock_total = VALUES(stock_total),
        ultima_actualizacion = NOW();
END //
DELIMITER ;
```

### Ejercicio 5: Monitoreo y Análisis de Rendimiento
Implementa técnicas de monitoreo para:

1. Analizar consultas lentas
2. Monitorear uso de índices
3. Identificar cuellos de botella
4. Optimizar configuración del servidor
5. Crear reportes de rendimiento

**Solución:**
```sql
-- 1. Habilitar monitoreo de consultas lentas
-- Configurar en my.cnf o usar variables de sesión
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2; -- Consultas que toman más de 2 segundos
SET GLOBAL log_queries_not_using_indexes = 'ON';

-- 2. Crear tabla para monitorear consultas lentas
CREATE TABLE consultas_lentas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta TEXT,
    tiempo_ejecucion DECIMAL(10,6),
    filas_examinadas INT,
    filas_enviadas INT,
    fecha_ejecucion TIMESTAMP,
    usuario VARCHAR(100),
    host VARCHAR(100)
);

-- 3. Procedimiento para analizar rendimiento de índices
DELIMITER //
CREATE PROCEDURE analizar_rendimiento_indices()
BEGIN
    -- Mostrar estadísticas de uso de índices
    SELECT 
        TABLE_NAME,
        INDEX_NAME,
        CARDINALITY,
        SUB_PART,
        PACKED,
        NULLABLE,
        INDEX_TYPE
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
    ORDER BY TABLE_NAME, INDEX_NAME;
    
    -- Mostrar índices no utilizados
    SELECT 
        s.TABLE_NAME,
        s.INDEX_NAME,
        s.CARDINALITY
    FROM information_schema.STATISTICS s
    LEFT JOIN information_schema.INDEX_STATISTICS i 
        ON s.TABLE_NAME = i.TABLE_NAME 
        AND s.INDEX_NAME = i.INDEX_NAME
    WHERE s.TABLE_SCHEMA = DATABASE()
    AND i.INDEX_NAME IS NULL;
END //
DELIMITER ;

-- 4. Procedimiento para identificar cuellos de botella
DELIMITER //
CREATE PROCEDURE identificar_cuellos_botella()
BEGIN
    -- Mostrar tablas con más filas
    SELECT 
        TABLE_NAME,
        TABLE_ROWS,
        DATA_LENGTH,
        INDEX_LENGTH,
        ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Tamaño (MB)'
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
    ORDER BY TABLE_ROWS DESC
    LIMIT 10;
    
    -- Mostrar consultas más frecuentes
    SELECT 
        DIGEST_TEXT AS consulta,
        COUNT_STAR AS ejecuciones,
        ROUND(SUM_TIMER_WAIT / 1000000000, 2) AS tiempo_total_segundos,
        ROUND(AVG_TIMER_WAIT / 1000000, 2) AS tiempo_promedio_ms
    FROM performance_schema.events_statements_summary_by_digest
    WHERE SCHEMA_NAME = DATABASE()
    ORDER BY COUNT_STAR DESC
    LIMIT 10;
END //
DELIMITER ;

-- 5. Crear reporte de rendimiento
CREATE TABLE reporte_rendimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_reporte DATE,
    total_tablas INT,
    total_indices INT,
    tablas_grandes INT,
    indices_no_utilizados INT,
    consultas_lentas INT,
    tiempo_total_consultas DECIMAL(10,2),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para generar reporte diario
DELIMITER //
CREATE PROCEDURE generar_reporte_rendimiento()
BEGIN
    DECLARE total_tablas INT;
    DECLARE total_indices INT;
    DECLARE tablas_grandes INT;
    DECLARE indices_no_utilizados INT;
    DECLARE consultas_lentas INT;
    
    -- Contar tablas
    SELECT COUNT(*) INTO total_tablas
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE();
    
    -- Contar índices
    SELECT COUNT(*) INTO total_indices
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE();
    
    -- Contar tablas grandes (> 1M filas)
    SELECT COUNT(*) INTO tablas_grandes
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_ROWS > 1000000;
    
    -- Contar consultas lentas del día
    SELECT COUNT(*) INTO consultas_lentas
    FROM consultas_lentas
    WHERE DATE(fecha_ejecucion) = CURDATE();
    
    -- Insertar reporte
    INSERT INTO reporte_rendimiento (
        fecha_reporte, total_tablas, total_indices, 
        tablas_grandes, indices_no_utilizados, 
        consultas_lentas, tiempo_total_consultas
    ) VALUES (
        CURDATE(), total_tablas, total_indices,
        tablas_grandes, indices_no_utilizados,
        consultas_lentas, 0
    );
END //
DELIMITER ;
```

## 📝 Resumen de Conceptos Clave
- ✅ EXPLAIN muestra el plan de ejecución de las consultas
- ✅ Los índices apropiados son fundamentales para el rendimiento
- ✅ La reescritura de consultas puede mejorar significativamente el rendimiento
- ✅ El particionamiento ayuda con tablas grandes
- ✅ El monitoreo continuo es esencial para mantener el rendimiento
- ✅ La optimización es un proceso iterativo y continuo

## 🔗 Próximo Nivel
Continúa con `docs/senior_5` para aprender sobre administración de bases de datos y seguridad.

---

**💡 Consejo: Practica analizando planes de ejecución con EXPLAIN y experimentando con diferentes estructuras de índices. La optimización requiere práctica y experiencia.**
