# Clase 6: Gestión de Memoria

## Objetivos de la Clase
- Dominar técnicas de optimización de memoria
- Implementar estrategias de caching eficientes
- Gestionar buffers y pools de memoria
- Optimizar consultas para uso eficiente de memoria

## 1. Introducción a la Gestión de Memoria

### ¿Qué es la Gestión de Memoria?
La gestión de memoria es el proceso de optimizar el uso de la memoria RAM para mejorar el rendimiento de las consultas SQL y operaciones de base de datos.

### Componentes de Memoria en MySQL
- **Buffer Pool**: Cache de páginas de datos
- **Query Cache**: Cache de resultados de consultas
- **Key Buffer**: Cache de índices
- **Sort Buffer**: Memoria para operaciones de ordenamiento
- **Join Buffer**: Memoria para operaciones de JOIN

## 2. Buffer Pool Optimization

### Configuración del Buffer Pool
```sql
-- Ver configuración actual del buffer pool
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'innodb_buffer_pool_instances';

-- Configuración recomendada (en my.cnf)
-- innodb_buffer_pool_size = 70-80% de la RAM total
-- innodb_buffer_pool_instances = 1 por GB de buffer pool
```

### Análisis del Buffer Pool
```sql
-- Ver estadísticas del buffer pool
SHOW ENGINE INNODB STATUS;

-- Análisis de hit ratio
SELECT 
    (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
    AS buffer_pool_hit_ratio
FROM information_schema.GLOBAL_STATUS
WHERE Variable_name IN ('Innodb_buffer_pool_reads', 'Innodb_buffer_pool_read_requests');
```

## 3. Query Cache Management

### Configuración del Query Cache
```sql
-- Ver configuración del query cache
SHOW VARIABLES LIKE 'query_cache%';

-- Configuración recomendada
SET GLOBAL query_cache_size = 268435456; -- 256MB
SET GLOBAL query_cache_type = ON;
SET GLOBAL query_cache_limit = 1048576; -- 1MB
```

### Análisis del Query Cache
```sql
-- Ver estadísticas del query cache
SHOW STATUS LIKE 'Qcache%';

-- Análisis de eficiencia
SELECT 
    Qcache_hits / (Qcache_hits + Qcache_inserts) * 100 AS hit_ratio
FROM (
    SELECT 
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hits') AS Qcache_hits,
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_inserts') AS Qcache_inserts
) AS stats;
```

## 4. Memory Buffers Optimization

### Sort Buffer
```sql
-- Configurar sort buffer para consultas grandes
SET SESSION sort_buffer_size = 2097152; -- 2MB

-- Consulta que se beneficia del sort buffer
SELECT 
    nombre,
    precio
FROM productos
ORDER BY precio DESC
LIMIT 1000;
```

### Join Buffer
```sql
-- Configurar join buffer para JOINs complejos
SET SESSION join_buffer_size = 1048576; -- 1MB

-- Consulta con múltiples JOINs
SELECT 
    c.nombre,
    p.nombre AS producto,
    v.monto
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
WHERE c.fecha_registro >= '2023-01-01';
```

## 5. Temporary Tables Management

### Configuración de Tablas Temporales
```sql
-- Ver configuración de tablas temporales
SHOW VARIABLES LIKE 'tmp_table_size';
SHOW VARIABLES LIKE 'max_heap_table_size';

-- Configuración recomendada
SET GLOBAL tmp_table_size = 134217728; -- 128MB
SET GLOBAL max_heap_table_size = 134217728; -- 128MB
```

### Optimización de Consultas con Tablas Temporales
```sql
-- Consulta que usa tabla temporal
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 10
ORDER BY precio_promedio DESC;
```

## 6. Memory Profiling

### Análisis de Uso de Memoria
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.categoria
ORDER BY monto_total DESC;

-- Ver perfil de memoria
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Análisis de Variables de Memoria
```sql
-- Ver uso actual de memoria
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME LIKE '%memory%'
    OR VARIABLE_NAME LIKE '%buffer%'
    OR VARIABLE_NAME LIKE '%cache%'
ORDER BY VARIABLE_NAME;
```

## 7. Caching Strategies

### Application-Level Caching
```sql
-- Consulta que se beneficia del caching
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;

-- Usar hints para controlar caching
SELECT /*+ USE_INDEX(products, idx_categoria) */
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;
```

### Result Set Caching
```sql
-- Consulta con resultado cacheable
SELECT 
    YEAR(fecha) AS año,
    MONTH(fecha) AS mes,
    SUM(monto) AS ventas_mes
FROM ventas
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY año, mes;
```

## 8. Memory Monitoring

### Monitoreo Continuo
```sql
-- Script de monitoreo de memoria
SELECT 
    NOW() AS timestamp,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data') AS buffer_pool_pages,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_free') AS buffer_pool_free_pages,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hits') AS query_cache_hits,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_inserts') AS query_cache_inserts;
```

### Alertas de Memoria
```sql
-- Verificar uso crítico de memoria
SELECT 
    CASE 
        WHEN (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_free') < 1000 
        THEN 'CRÍTICO: Buffer pool casi lleno'
        WHEN (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_free') < 5000 
        THEN 'ADVERTENCIA: Buffer pool con poco espacio libre'
        ELSE 'OK: Buffer pool con espacio suficiente'
    END AS estado_buffer_pool;
```

## 9. Memory Tuning Techniques

### Optimización de Consultas para Memoria
```sql
-- Consulta optimizada para uso eficiente de memoria
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas
FROM productos p
WHERE p.categoria IN ('Electrónicos', 'Ropa', 'Hogar')
GROUP BY p.categoria
ORDER BY total_ventas DESC
LIMIT 10;
```

### Uso de Índices para Reducir Memoria
```sql
-- Crear índice para reducir uso de memoria
CREATE INDEX idx_producto_categoria ON productos(categoria);

-- Consulta que usa el índice
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
WHERE categoria = 'Electrónicos';
```

## 10. Memory Best Practices

### Configuración Recomendada
```sql
-- Configuración de memoria recomendada para diferentes tamaños de servidor

-- Servidor pequeño (4GB RAM)
-- innodb_buffer_pool_size = 2G
-- query_cache_size = 256M
-- tmp_table_size = 64M
-- max_heap_table_size = 64M

-- Servidor mediano (16GB RAM)
-- innodb_buffer_pool_size = 12G
-- query_cache_size = 1G
-- tmp_table_size = 256M
-- max_heap_table_size = 256M

-- Servidor grande (64GB RAM)
-- innodb_buffer_pool_size = 48G
-- query_cache_size = 4G
-- tmp_table_size = 1G
-- max_heap_table_size = 1G
```

### Monitoreo y Mantenimiento
```sql
-- Script de mantenimiento de memoria
-- 1. Limpiar query cache periódicamente
FLUSH QUERY CACHE;

-- 2. Analizar tablas para optimizar estadísticas
ANALYZE TABLE productos;
ANALYZE TABLE ventas;

-- 3. Verificar fragmentación
SHOW TABLE STATUS LIKE 'ventas';
```

## Ejercicios Prácticos

### Ejercicio 1: Análisis del Buffer Pool
```sql
-- Analizar eficiencia del buffer pool
SELECT 
    (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
    AS buffer_pool_hit_ratio
FROM (
    SELECT 
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') AS Innodb_buffer_pool_reads,
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') AS Innodb_buffer_pool_read_requests
) AS stats;
```

### Ejercicio 2: Configuración del Query Cache
```sql
-- Configurar y analizar query cache
SET GLOBAL query_cache_size = 268435456; -- 256MB
SET GLOBAL query_cache_type = ON;

-- Ejecutar consulta cacheable
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;

-- Ver estadísticas del query cache
SHOW STATUS LIKE 'Qcache%';
```

### Ejercicio 3: Optimización de Sort Buffer
```sql
-- Configurar sort buffer para consulta grande
SET SESSION sort_buffer_size = 2097152; -- 2MB

-- Consulta que se beneficia del sort buffer
SELECT 
    nombre,
    precio,
    categoria
FROM productos
ORDER BY precio DESC, nombre
LIMIT 1000;
```

### Ejercicio 4: Análisis de Uso de Memoria
```sql
-- Analizar uso de memoria por consulta
SET profiling = 1;

-- Ejecutar consulta compleja
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total,
    AVG(v.monto) AS ticket_promedio
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.categoria
ORDER BY monto_total DESC;

-- Ver perfil de memoria
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Ejercicio 5: Monitoreo de Memoria
```sql
-- Script de monitoreo de memoria
SELECT 
    NOW() AS timestamp,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data') AS buffer_pool_pages,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_free') AS buffer_pool_free_pages,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hits') AS query_cache_hits,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_inserts') AS query_cache_inserts;
```

### Ejercicio 6: Optimización de JOINs
```sql
-- Configurar join buffer para JOINs complejos
SET SESSION join_buffer_size = 1048576; -- 1MB

-- Consulta con múltiples JOINs
SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    cat.nombre AS categoria,
    v.monto
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
JOIN categorias cat ON p.categoria_id = cat.id
WHERE c.fecha_registro >= '2023-01-01'
ORDER BY v.monto DESC;
```

### Ejercicio 7: Gestión de Tablas Temporales
```sql
-- Configurar tablas temporales
SET GLOBAL tmp_table_size = 134217728; -- 128MB
SET GLOBAL max_heap_table_size = 134217728; -- 128MB

-- Consulta que usa tabla temporal
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 5
ORDER BY precio_promedio DESC;
```

### Ejercicio 8: Análisis de Hit Ratio
```sql
-- Calcular hit ratio del query cache
SELECT 
    Qcache_hits / (Qcache_hits + Qcache_inserts) * 100 AS hit_ratio
FROM (
    SELECT 
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hits') AS Qcache_hits,
        (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_inserts') AS Qcache_inserts
) AS stats;
```

### Ejercicio 9: Optimización de Consultas para Memoria
```sql
-- Consulta optimizada para uso eficiente de memoria
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total
FROM productos p
JOIN ventas v ON p.id = v.producto_id
WHERE p.categoria IN ('Electrónicos', 'Ropa', 'Hogar')
    AND v.fecha >= '2023-01-01'
GROUP BY p.categoria
ORDER BY monto_total DESC
LIMIT 10;
```

### Ejercicio 10: Mantenimiento de Memoria
```sql
-- Script de mantenimiento de memoria
-- Limpiar query cache
FLUSH QUERY CACHE;

-- Analizar tablas para optimizar estadísticas
ANALYZE TABLE productos;
ANALYZE TABLE ventas;
ANALYZE TABLE clientes;

-- Verificar estado de las tablas
SHOW TABLE STATUS LIKE 'ventas';
SHOW TABLE STATUS LIKE 'productos';
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Buffer Pool**: Configuración y optimización del cache principal
2. **Query Cache**: Gestión del cache de resultados de consultas
3. **Memory Buffers**: Sort buffer, join buffer, y otros buffers
4. **Tablas Temporales**: Configuración y optimización
5. **Memory Profiling**: Análisis del uso de memoria
6. **Caching Strategies**: Estrategias de caching a nivel de aplicación
7. **Memory Monitoring**: Monitoreo continuo del uso de memoria
8. **Memory Tuning**: Técnicas de optimización de memoria
9. **Best Practices**: Configuraciones recomendadas
10. **Mantenimiento**: Scripts de mantenimiento de memoria

## Próxima Clase
En la siguiente clase exploraremos técnicas de monitoreo y profiling para identificar cuellos de botella y optimizar el rendimiento.

## Recursos Adicionales
- Documentación de configuración de memoria de MySQL
- Guías de tuning de rendimiento
- Herramientas de monitoreo de memoria
- Mejores prácticas de optimización
