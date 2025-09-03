# Clase 2: Optimización de Rendimiento

## Objetivos de la Clase
- Dominar técnicas de optimización de consultas SQL
- Analizar planes de ejecución y identificar cuellos de botella
- Implementar estrategias de indexación avanzada
- Aplicar técnicas de tuning de base de datos

## 1. Introducción a la Optimización de Rendimiento

### ¿Qué es la Optimización de Rendimiento?
La optimización de rendimiento es el proceso de mejorar la velocidad y eficiencia de las consultas SQL y operaciones de base de datos. Involucra identificar problemas de rendimiento, analizar causas raíz y aplicar soluciones específicas.

### Métricas de Rendimiento
- **Tiempo de Ejecución**: Duración total de la consulta
- **Throughput**: Número de operaciones por segundo
- **Uso de CPU**: Porcentaje de procesador utilizado
- **Uso de Memoria**: Cantidad de RAM consumida
- **I/O de Disco**: Operaciones de lectura/escritura

## 2. Análisis de Planes de Ejecución

### EXPLAIN - Análisis Básico
```sql
-- Análisis básico del plan de ejecución
EXPLAIN SELECT 
    p.nombre,
    SUM(v.cantidad) AS total_vendido
FROM productos p
JOIN ventas v ON p.id = v.producto_id
WHERE p.categoria = 'Electrónicos'
GROUP BY p.nombre
ORDER BY total_vendido DESC;
```

**Explicación de columnas importantes:**
- **id**: Identificador de la operación
- **select_type**: Tipo de consulta (SIMPLE, PRIMARY, SUBQUERY, etc.)
- **table**: Tabla involucrada
- **type**: Tipo de acceso (ALL, index, range, ref, etc.)
- **possible_keys**: Índices que podrían usarse
- **key**: Índice realmente usado
- **rows**: Número estimado de filas examinadas
- **Extra**: Información adicional sobre la operación

### EXPLAIN ANALYZE - Análisis Detallado
```sql
-- Análisis detallado con métricas reales
EXPLAIN ANALYZE SELECT 
    c.nombre,
    COUNT(v.id) AS total_compras,
    SUM(v.monto) AS monto_total
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE c.fecha_registro >= '2023-01-01'
GROUP BY c.id, c.nombre
HAVING COUNT(v.id) > 5
ORDER BY monto_total DESC;
```

**Información adicional proporcionada:**
- **Tiempo real de ejecución**: Tiempo exacto de cada operación
- **Filas reales procesadas**: Número exacto de filas
- **Costos de operaciones**: Costo relativo de cada paso

## 3. Identificación de Problemas de Rendimiento

### Consultas con Full Table Scan
```sql
-- Problema: Full table scan sin índice
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Solución: Crear índice en la columna categoria
CREATE INDEX idx_categoria ON productos(categoria);

-- Verificar mejora
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';
```

### Consultas con JOINs Ineficientes
```sql
-- Problema: JOIN sin índices apropiados
EXPLAIN SELECT 
    p.nombre,
    v.fecha,
    v.monto
FROM productos p
JOIN ventas v ON p.id = v.producto_id
WHERE p.categoria = 'Electrónicos'
    AND v.fecha >= '2023-01-01';

-- Solución: Crear índices compuestos
CREATE INDEX idx_producto_categoria ON productos(id, categoria);
CREATE INDEX idx_venta_producto_fecha ON ventas(producto_id, fecha);
```

### Consultas con Subconsultas Ineficientes
```sql
-- Problema: Subconsulta correlacionada
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria = p.categoria) AS precio_promedio_categoria
FROM productos p;

-- Solución: Usar JOIN con agregación
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    cat.precio_promedio
FROM productos p
JOIN (
    SELECT categoria, AVG(precio) AS precio_promedio
    FROM productos
    GROUP BY categoria
) cat ON p.categoria = cat.categoria;
```

## 4. Estrategias de Indexación Avanzada

### Índices Compuestos
```sql
-- Índice compuesto para consultas multi-columna
CREATE INDEX idx_ventas_producto_fecha_monto ON ventas(producto_id, fecha, monto);

-- Consulta optimizada para el índice compuesto
SELECT 
    producto_id,
    fecha,
    monto
FROM ventas
WHERE producto_id = 123
    AND fecha >= '2023-01-01'
    AND fecha <= '2023-12-31'
ORDER BY fecha;
```

**Reglas para índices compuestos:**
1. **Selectividad**: Columna más selectiva primero
2. **Ordenamiento**: Columna de ORDER BY al final
3. **Filtros**: Columnas de WHERE al principio

### Índices Parciales
```sql
-- Índice parcial para datos específicos
CREATE INDEX idx_ventas_activas ON ventas(fecha, monto) 
WHERE estado = 'activa';

-- Consulta que aprovecha el índice parcial
SELECT fecha, SUM(monto) 
FROM ventas 
WHERE estado = 'activa' 
    AND fecha >= '2023-01-01'
GROUP BY fecha;
```

### Índices de Texto Completo
```sql
-- Índice de texto completo para búsquedas
CREATE FULLTEXT INDEX idx_descripcion_fulltext ON productos(descripcion);

-- Búsqueda de texto completo
SELECT 
    nombre,
    descripcion,
    MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE) AS relevancia
FROM productos
WHERE MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE)
ORDER BY relevancia DESC;
```

## 5. Optimización de Consultas Específicas

### Optimización de GROUP BY
```sql
-- Consulta no optimizada
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria
ORDER BY total_productos DESC;

-- Optimización: Usar índice en categoria
CREATE INDEX idx_categoria ON productos(categoria);

-- Consulta optimizada con LIMIT
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria
ORDER BY total_productos DESC
LIMIT 10;
```

### Optimización de ORDER BY
```sql
-- Problema: ORDER BY sin índice
EXPLAIN SELECT * FROM ventas ORDER BY fecha DESC LIMIT 100;

-- Solución: Crear índice para ORDER BY
CREATE INDEX idx_ventas_fecha ON ventas(fecha DESC);

-- Verificar optimización
EXPLAIN SELECT * FROM ventas ORDER BY fecha DESC LIMIT 100;
```

### Optimización de DISTINCT
```sql
-- Problema: DISTINCT costoso
EXPLAIN SELECT DISTINCT categoria FROM productos;

-- Solución: Usar GROUP BY si es apropiado
EXPLAIN SELECT categoria FROM productos GROUP BY categoria;

-- O crear índice en la columna
CREATE INDEX idx_categoria ON productos(categoria);
```

## 6. Optimización de Consultas con JOINs

### Orden de JOINs
```sql
-- Consulta con múltiples JOINs
EXPLAIN SELECT 
    c.nombre,
    p.nombre AS producto,
    v.monto
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
WHERE c.fecha_registro >= '2023-01-01'
    AND p.categoria = 'Electrónicos';

-- Optimización: Reordenar JOINs por selectividad
EXPLAIN SELECT 
    c.nombre,
    p.nombre AS producto,
    v.monto
FROM productos p
JOIN ventas v ON p.id = v.producto_id
JOIN clientes c ON v.cliente_id = c.id
WHERE p.categoria = 'Electrónicos'
    AND c.fecha_registro >= '2023-01-01';
```

### Uso de EXISTS vs IN
```sql
-- Usar EXISTS para mejor rendimiento
EXPLAIN SELECT 
    c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM ventas v 
    WHERE v.cliente_id = c.id 
        AND v.fecha >= '2023-01-01'
);

-- Comparar con IN (menos eficiente para grandes datasets)
EXPLAIN SELECT 
    c.nombre
FROM clientes c
WHERE c.id IN (
    SELECT DISTINCT cliente_id 
    FROM ventas 
    WHERE fecha >= '2023-01-01'
);
```

## 7. Optimización de Consultas con Agregaciones

### Optimización de COUNT
```sql
-- COUNT(*) vs COUNT(columna)
EXPLAIN SELECT COUNT(*) FROM ventas;  -- Más eficiente
EXPLAIN SELECT COUNT(id) FROM ventas; -- Menos eficiente si hay NULLs

-- COUNT con filtros
EXPLAIN SELECT COUNT(*) FROM ventas WHERE fecha >= '2023-01-01';
```

### Optimización de SUM y AVG
```sql
-- Agregación con filtros tempranos
EXPLAIN SELECT 
    categoria,
    SUM(precio) AS total_precio
FROM productos
WHERE precio > 100
GROUP BY categoria;

-- Usar índice compuesto
CREATE INDEX idx_categoria_precio ON productos(categoria, precio);
```

## 8. Técnicas de Caching y Materialización

### Vistas Materializadas
```sql
-- Crear vista materializada para consultas complejas
CREATE MATERIALIZED VIEW ventas_resumen AS
SELECT 
    p.categoria,
    YEAR(v.fecha) AS año,
    MONTH(v.fecha) AS mes,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total,
    AVG(v.monto) AS monto_promedio
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.categoria, YEAR(v.fecha), MONTH(v.fecha);

-- Crear índice en la vista materializada
CREATE INDEX idx_ventas_resumen_categoria ON ventas_resumen(categoria, año, mes);

-- Consulta optimizada usando la vista
SELECT * FROM ventas_resumen 
WHERE categoria = 'Electrónicos' 
    AND año = 2023
ORDER BY mes;
```

### Caching de Consultas
```sql
-- Consulta que se beneficia del cache
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;

-- Para MySQL: Usar query cache
SET GLOBAL query_cache_size = 268435456; -- 256MB
SET GLOBAL query_cache_type = ON;
```

## 9. Monitoreo y Profiling

### Análisis de Rendimiento de Consultas
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta
SELECT 
    p.nombre,
    SUM(v.cantidad) AS total_vendido
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.nombre
ORDER BY total_vendido DESC
LIMIT 10;

-- Ver perfil de rendimiento
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Análisis de Uso de Índices
```sql
-- Verificar uso de índices
SHOW INDEX FROM ventas;

-- Análisis de uso de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas';
```

## 10. Herramientas de Optimización

### MySQL Workbench - Visual Explain
```sql
-- Usar Visual Explain para análisis gráfico
EXPLAIN FORMAT=JSON SELECT 
    c.nombre,
    COUNT(v.id) AS total_compras
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre
HAVING COUNT(v.id) > 5;
```

### Análisis de Slow Query Log
```sql
-- Configurar slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2; -- Log queries > 2 segundos
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';

-- Analizar queries lentas
-- Usar mysqldumpslow o pt-query-digest
```

## Ejercicios Prácticos

### Ejercicio 1: Análisis de Plan de Ejecución
```sql
-- Analizar y optimizar esta consulta
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100
    AND c.nombre = 'Electrónicos'
ORDER BY p.precio DESC;

-- Crear índices necesarios
CREATE INDEX idx_producto_precio ON productos(precio);
CREATE INDEX idx_categoria_nombre ON categorias(nombre);
CREATE INDEX idx_producto_categoria_precio ON productos(categoria_id, precio);
```

### Ejercicio 2: Optimización de JOINs
```sql
-- Optimizar consulta con múltiples JOINs
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.nombre AS producto,
    v.fecha,
    v.monto
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
JOIN categorias cat ON p.categoria_id = cat.id
WHERE c.fecha_registro >= '2023-01-01'
    AND cat.nombre = 'Electrónicos'
    AND v.monto > 500;

-- Crear índices compuestos
CREATE INDEX idx_cliente_fecha_registro ON clientes(fecha_registro);
CREATE INDEX idx_venta_cliente_producto ON ventas(cliente_id, producto_id, monto);
CREATE INDEX idx_producto_categoria ON productos(categoria_id);
```

### Ejercicio 3: Optimización de Agregaciones
```sql
-- Optimizar consulta de agregación
EXPLAIN SELECT 
    YEAR(v.fecha) AS año,
    MONTH(v.fecha) AS mes,
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total
FROM ventas v
JOIN productos p ON v.producto_id = p.id
WHERE v.fecha >= '2023-01-01'
GROUP BY YEAR(v.fecha), MONTH(v.fecha), p.categoria
ORDER BY año, mes, monto_total DESC;

-- Crear índice compuesto
CREATE INDEX idx_venta_fecha_producto ON ventas(fecha, producto_id, monto);
CREATE INDEX idx_producto_categoria ON productos(categoria);
```

### Ejercicio 4: Optimización de Subconsultas
```sql
-- Convertir subconsulta correlacionada a JOIN
-- Consulta original (ineficiente)
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id) AS precio_promedio
FROM productos p
WHERE p.precio > 100;

-- Consulta optimizada
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    cat.precio_promedio
FROM productos p
JOIN (
    SELECT categoria_id, AVG(precio) AS precio_promedio
    FROM productos
    GROUP BY categoria_id
) cat ON p.categoria_id = cat.categoria_id
WHERE p.precio > 100;
```

### Ejercicio 5: Optimización de ORDER BY
```sql
-- Optimizar ORDER BY con LIMIT
EXPLAIN SELECT 
    nombre,
    precio
FROM productos
ORDER BY precio DESC
LIMIT 20;

-- Crear índice para ORDER BY
CREATE INDEX idx_producto_precio_desc ON productos(precio DESC);
```

### Ejercicio 6: Optimización de DISTINCT
```sql
-- Optimizar DISTINCT
EXPLAIN SELECT DISTINCT categoria FROM productos;

-- Usar GROUP BY como alternativa
EXPLAIN SELECT categoria FROM productos GROUP BY categoria;

-- Crear índice si es necesario
CREATE INDEX idx_categoria ON productos(categoria);
```

### Ejercicio 7: Optimización de EXISTS
```sql
-- Usar EXISTS en lugar de IN
EXPLAIN SELECT 
    c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM ventas v 
    WHERE v.cliente_id = c.id 
        AND v.fecha >= '2023-01-01'
        AND v.monto > 1000
);

-- Crear índices apropiados
CREATE INDEX idx_venta_cliente_fecha_monto ON ventas(cliente_id, fecha, monto);
```

### Ejercicio 8: Optimización de COUNT
```sql
-- Optimizar COUNT con condiciones
EXPLAIN SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
WHERE precio > 50
GROUP BY categoria;

-- Crear índice compuesto
CREATE INDEX idx_producto_categoria_precio ON productos(categoria, precio);
```

### Ejercicio 9: Optimización de Vistas
```sql
-- Crear vista materializada para consultas complejas
CREATE MATERIALIZED VIEW resumen_ventas_mensual AS
SELECT 
    YEAR(fecha) AS año,
    MONTH(fecha) AS mes,
    COUNT(*) AS total_ventas,
    SUM(monto) AS monto_total,
    AVG(monto) AS monto_promedio,
    COUNT(DISTINCT cliente_id) AS clientes_unicos
FROM ventas
GROUP BY YEAR(fecha), MONTH(fecha);

-- Crear índice en la vista
CREATE INDEX idx_resumen_año_mes ON resumen_ventas_mensual(año, mes);
```

### Ejercicio 10: Análisis de Rendimiento Completo
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta compleja
SELECT 
    c.nombre AS cliente,
    p.categoria,
    COUNT(v.id) AS total_compras,
    SUM(v.monto) AS monto_total,
    AVG(v.monto) AS ticket_promedio
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
WHERE c.fecha_registro >= '2023-01-01'
    AND v.fecha >= '2023-01-01'
GROUP BY c.id, c.nombre, p.categoria
HAVING COUNT(v.id) > 3
ORDER BY monto_total DESC
LIMIT 50;

-- Analizar perfil
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;

-- Verificar uso de índices
SHOW INDEX FROM ventas;
SHOW INDEX FROM clientes;
SHOW INDEX FROM productos;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Análisis de Planes de Ejecución**: EXPLAIN y EXPLAIN ANALYZE
2. **Identificación de Problemas**: Full table scans, JOINs ineficientes, subconsultas
3. **Estrategias de Indexación**: Índices compuestos, parciales, de texto completo
4. **Optimización de Consultas**: GROUP BY, ORDER BY, DISTINCT, EXISTS vs IN
5. **Optimización de JOINs**: Orden de JOINs, uso de EXISTS
6. **Optimización de Agregaciones**: COUNT, SUM, AVG
7. **Caching y Materialización**: Vistas materializadas, query cache
8. **Monitoreo**: Profiling, análisis de índices
9. **Herramientas**: MySQL Workbench, slow query log

## Próxima Clase
En la siguiente clase exploraremos técnicas avanzadas de indexación, incluyendo índices especializados, particionamiento y estrategias de mantenimiento.

## Recursos Adicionales
- Documentación de EXPLAIN
- Guías de optimización de MySQL
- Herramientas de profiling
- Mejores prácticas de indexación
