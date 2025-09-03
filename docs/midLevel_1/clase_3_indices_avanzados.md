# Clase 3: Índices Avanzados

## Objetivos de la Clase
- Dominar técnicas avanzadas de indexación
- Diseñar índices especializados para diferentes tipos de consultas
- Implementar estrategias de mantenimiento de índices
- Optimizar el rendimiento mediante indexación inteligente

## 1. Introducción a Índices Avanzados

### ¿Qué son los Índices Avanzados?
Los índices avanzados son estructuras de datos especializadas que van más allá de los índices básicos B-tree, diseñados para optimizar consultas específicas y mejorar el rendimiento en escenarios complejos.

### Tipos de Índices Avanzados
- **Índices Compuestos**: Múltiples columnas en un solo índice
- **Índices Parciales**: Solo para un subconjunto de filas
- **Índices de Texto Completo**: Para búsquedas de texto
- **Índices Funcionales**: Basados en expresiones
- **Índices Espaciales**: Para datos geográficos
- **Índices Hash**: Para búsquedas de igualdad exacta

## 2. Índices Compuestos Avanzados

### Diseño de Índices Compuestos
```sql
-- Crear índice compuesto optimizado
CREATE INDEX idx_ventas_producto_fecha_monto ON ventas(producto_id, fecha, monto);

-- Consulta que aprovecha el índice compuesto
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

**Reglas de diseño:**
1. **Selectividad**: Columna más selectiva primero
2. **Filtros**: Columnas de WHERE al principio
3. **Ordenamiento**: Columna de ORDER BY al final
4. **Cobertura**: Incluir columnas del SELECT si es posible

### Índices de Cobertura
```sql
-- Índice de cobertura que incluye todas las columnas necesarias
CREATE INDEX idx_ventas_cobertura ON ventas(
    producto_id, 
    fecha, 
    monto, 
    cliente_id, 
    cantidad
);

-- Consulta que usa solo el índice (no accede a la tabla)
SELECT 
    producto_id,
    fecha,
    monto,
    cliente_id
FROM ventas
WHERE producto_id = 123
    AND fecha >= '2023-01-01';
```

**Ventajas de índices de cobertura:**
- **Menos I/O**: No necesita acceder a la tabla principal
- **Mayor velocidad**: Solo lee del índice
- **Menos bloqueos**: Reduce contención en la tabla

## 3. Índices Parciales

### Índices con Condiciones
```sql
-- Índice parcial para datos activos
CREATE INDEX idx_ventas_activas ON ventas(fecha, monto) 
WHERE estado = 'activa';

-- Consulta que aprovecha el índice parcial
SELECT 
    fecha,
    SUM(monto) AS total_diario
FROM ventas
WHERE estado = 'activa'
    AND fecha >= '2023-01-01'
GROUP BY fecha;
```

### Índices Parciales para Datos Recientes
```sql
-- Índice solo para datos del último año
CREATE INDEX idx_ventas_recientes ON ventas(producto_id, fecha)
WHERE fecha >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR);

-- Consulta optimizada para datos recientes
SELECT 
    producto_id,
    COUNT(*) AS ventas_recientes
FROM ventas
WHERE fecha >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
GROUP BY producto_id;
```

## 4. Índices de Texto Completo

### Configuración de Texto Completo
```sql
-- Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion_fulltext ON productos(descripcion);

-- Búsqueda en modo natural
SELECT 
    nombre,
    descripcion,
    MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE) AS relevancia
FROM productos
WHERE MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE)
ORDER BY relevancia DESC;
```

### Búsqueda Booleana
```sql
-- Búsqueda booleana avanzada
SELECT 
    nombre,
    descripcion
FROM productos
WHERE MATCH(descripcion) AGAINST('+smartphone +camera -tablet' IN BOOLEAN MODE);
```

**Operadores booleanos:**
- `+`: Palabra requerida
- `-`: Palabra excluida
- `*`: Comodín
- `"frase"`: Frase exacta

### Búsqueda con Expansión de Consulta
```sql
-- Búsqueda con expansión automática
SELECT 
    nombre,
    descripcion
FROM productos
WHERE MATCH(descripcion) AGAINST('smartphone' WITH QUERY EXPANSION);
```

## 5. Índices Funcionales

### Índices Basados en Expresiones
```sql
-- Índice funcional para búsquedas case-insensitive
CREATE INDEX idx_nombre_lower ON productos((LOWER(nombre)));

-- Consulta que usa el índice funcional
SELECT * FROM productos WHERE LOWER(nombre) = 'smartphone';
```

### Índices con Funciones de Fecha
```sql
-- Índice funcional para búsquedas por año
CREATE INDEX idx_ventas_año ON ventas((YEAR(fecha)));

-- Consulta optimizada
SELECT 
    YEAR(fecha) AS año,
    COUNT(*) AS total_ventas
FROM ventas
WHERE YEAR(fecha) = 2023
GROUP BY YEAR(fecha);
```

### Índices con Concatenación
```sql
-- Índice funcional para búsquedas combinadas
CREATE INDEX idx_nombre_categoria ON productos((CONCAT(nombre, ' ', categoria)));

-- Consulta que usa concatenación
SELECT * FROM productos 
WHERE CONCAT(nombre, ' ', categoria) LIKE '%smartphone electrónicos%';
```

## 6. Índices Espaciales

### Configuración de Índices Espaciales
```sql
-- Crear tabla con datos espaciales
CREATE TABLE ubicaciones (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    coordenadas POINT,
    SPATIAL INDEX idx_coordenadas (coordenadas)
);

-- Insertar datos espaciales
INSERT INTO ubicaciones (id, nombre, coordenadas) VALUES
(1, 'Oficina Central', POINT(-74.0059, 40.7128)),
(2, 'Sucursal Norte', POINT(-73.9857, 40.7589)),
(3, 'Sucursal Sur', POINT(-74.0060, 40.6892));
```

### Consultas Espaciales
```sql
-- Búsqueda por proximidad
SELECT 
    nombre,
    ST_DISTANCE(coordenadas, POINT(-74.0059, 40.7128)) AS distancia
FROM ubicaciones
WHERE ST_DISTANCE(coordenadas, POINT(-74.0059, 40.7128)) < 1000
ORDER BY distancia;
```

## 7. Índices Hash

### Configuración de Índices Hash
```sql
-- Crear índice hash para búsquedas de igualdad
CREATE INDEX idx_cliente_hash ON clientes(id) USING HASH;

-- Consulta optimizada para hash
SELECT * FROM clientes WHERE id = 12345;
```

**Características de índices hash:**
- **Rápido para igualdad**: O(1) para búsquedas exactas
- **No soporta rangos**: No funciona con <, >, BETWEEN
- **No soporta ordenamiento**: No funciona con ORDER BY

## 8. Estrategias de Mantenimiento de Índices

### Análisis de Uso de Índices
```sql
-- Verificar uso de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas'
ORDER BY CARDINALITY DESC;
```

### Identificación de Índices No Utilizados
```sql
-- Consulta para identificar índices no utilizados
SELECT 
    t.TABLE_NAME,
    t.INDEX_NAME,
    t.CARDINALITY
FROM information_schema.STATISTICS t
LEFT JOIN (
    SELECT DISTINCT TABLE_NAME, INDEX_NAME
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'tu_base_datos'
) u ON t.TABLE_NAME = u.TABLE_NAME AND t.INDEX_NAME = u.INDEX_NAME
WHERE t.TABLE_SCHEMA = 'tu_base_datos'
    AND u.INDEX_NAME IS NULL;
```

### Reconstrucción de Índices
```sql
-- Reconstruir índice para optimizar
ALTER TABLE ventas DROP INDEX idx_ventas_producto_fecha;
CREATE INDEX idx_ventas_producto_fecha ON ventas(producto_id, fecha);

-- Analizar tabla para actualizar estadísticas
ANALYZE TABLE ventas;
```

## 9. Optimización de Índices para Diferentes Patrones de Consulta

### Consultas de Búsqueda
```sql
-- Índice optimizado para búsquedas
CREATE INDEX idx_productos_busqueda ON productos(nombre, categoria, precio);

-- Consulta de búsqueda optimizada
SELECT 
    nombre,
    categoria,
    precio
FROM productos
WHERE nombre LIKE 'smartphone%'
    AND categoria = 'Electrónicos'
    AND precio BETWEEN 100 AND 1000
ORDER BY precio;
```

### Consultas de Agregación
```sql
-- Índice optimizado para agregaciones
CREATE INDEX idx_ventas_agregacion ON ventas(fecha, producto_id, monto);

-- Consulta de agregación optimizada
SELECT 
    DATE(fecha) AS dia,
    COUNT(*) AS total_ventas,
    SUM(monto) AS monto_total
FROM ventas
WHERE fecha >= '2023-01-01'
GROUP BY DATE(fecha)
ORDER BY dia;
```

### Consultas de Ordenamiento
```sql
-- Índice optimizado para ordenamiento
CREATE INDEX idx_productos_ordenamiento ON productos(categoria, precio DESC, nombre);

-- Consulta de ordenamiento optimizada
SELECT 
    nombre,
    categoria,
    precio
FROM productos
WHERE categoria = 'Electrónicos'
ORDER BY precio DESC, nombre
LIMIT 20;
```

## 10. Monitoreo y Tuning de Índices

### Análisis de Rendimiento de Índices
```sql
-- Habilitar profiling para análisis
SET profiling = 1;

-- Ejecutar consulta
SELECT 
    p.nombre,
    SUM(v.monto) AS total_ventas
FROM productos p
JOIN ventas v ON p.id = v.producto_id
WHERE p.categoria = 'Electrónicos'
    AND v.fecha >= '2023-01-01'
GROUP BY p.nombre
ORDER BY total_ventas DESC;

-- Analizar perfil
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Análisis de Fragmentación
```sql
-- Verificar fragmentación de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    ROUND(CARDINALITY / COUNT(*) * 100, 2) AS selectividad_porcentaje
FROM information_schema.STATISTICS s
JOIN (
    SELECT TABLE_NAME, COUNT(*) as total_rows
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = 'tu_base_datos'
) t ON s.TABLE_NAME = t.TABLE_NAME
WHERE s.TABLE_SCHEMA = 'tu_base_datos'
GROUP BY TABLE_NAME, INDEX_NAME, CARDINALITY;
```

## Ejercicios Prácticos

### Ejercicio 1: Diseño de Índice Compuesto
```sql
-- Analizar consulta y diseñar índice compuesto óptimo
EXPLAIN SELECT 
    cliente_id,
    producto_id,
    fecha,
    monto
FROM ventas
WHERE cliente_id = 123
    AND fecha >= '2023-01-01'
    AND fecha <= '2023-12-31'
    AND monto > 100
ORDER BY fecha DESC;

-- Crear índice compuesto optimizado
CREATE INDEX idx_ventas_cliente_fecha_monto ON ventas(cliente_id, fecha, monto);

-- Verificar mejora
EXPLAIN SELECT 
    cliente_id,
    producto_id,
    fecha,
    monto
FROM ventas
WHERE cliente_id = 123
    AND fecha >= '2023-01-01'
    AND fecha <= '2023-12-31'
    AND monto > 100
ORDER BY fecha DESC;
```

### Ejercicio 2: Índice de Cobertura
```sql
-- Crear índice de cobertura para consulta específica
CREATE INDEX idx_ventas_cobertura_completa ON ventas(
    producto_id,
    fecha,
    monto,
    cliente_id,
    cantidad,
    descuento
);

-- Consulta que usa solo el índice
SELECT 
    producto_id,
    fecha,
    monto,
    cliente_id
FROM ventas
WHERE producto_id = 456
    AND fecha >= '2023-01-01'
ORDER BY fecha;
```

### Ejercicio 3: Índice Parcial
```sql
-- Crear índice parcial para datos activos
CREATE INDEX idx_productos_activos ON productos(nombre, precio)
WHERE estado = 'activo';

-- Consulta optimizada
SELECT 
    nombre,
    precio
FROM productos
WHERE estado = 'activo'
    AND precio > 100
ORDER BY precio DESC;
```

### Ejercicio 4: Índice de Texto Completo
```sql
-- Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion_fulltext ON productos(descripcion);

-- Búsqueda natural
SELECT 
    nombre,
    descripcion,
    MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE) AS relevancia
FROM productos
WHERE MATCH(descripcion) AGAINST('smartphone camera' IN NATURAL LANGUAGE MODE)
ORDER BY relevancia DESC;
```

### Ejercicio 5: Índice Funcional
```sql
-- Crear índice funcional para búsquedas case-insensitive
CREATE INDEX idx_nombre_lower ON productos((LOWER(nombre)));

-- Consulta optimizada
SELECT * FROM productos WHERE LOWER(nombre) LIKE '%smartphone%';
```

### Ejercicio 6: Análisis de Uso de Índices
```sql
-- Analizar uso de índices en una tabla
SELECT 
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas'
ORDER BY CARDINALITY DESC;
```

### Ejercicio 7: Optimización de Consulta Compleja
```sql
-- Analizar y optimizar consulta compleja
EXPLAIN SELECT 
    c.nombre AS cliente,
    p.categoria,
    COUNT(v.id) AS total_compras,
    SUM(v.monto) AS monto_total
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN productos p ON v.producto_id = p.id
WHERE c.fecha_registro >= '2023-01-01'
    AND p.categoria = 'Electrónicos'
    AND v.fecha >= '2023-01-01'
GROUP BY c.id, c.nombre, p.categoria
HAVING COUNT(v.id) > 3
ORDER BY monto_total DESC;

-- Crear índices necesarios
CREATE INDEX idx_cliente_fecha_registro ON clientes(fecha_registro);
CREATE INDEX idx_venta_cliente_fecha ON ventas(cliente_id, fecha, monto);
CREATE INDEX idx_producto_categoria ON productos(categoria);
```

### Ejercicio 8: Índice para Consultas de Rango
```sql
-- Crear índice optimizado para consultas de rango
CREATE INDEX idx_ventas_fecha_monto ON ventas(fecha, monto);

-- Consulta de rango optimizada
SELECT 
    DATE(fecha) AS dia,
    COUNT(*) AS total_ventas,
    AVG(monto) AS monto_promedio
FROM ventas
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31'
    AND monto BETWEEN 100 AND 1000
GROUP BY DATE(fecha)
ORDER BY dia;
```

### Ejercicio 9: Índice para Consultas de Ordenamiento
```sql
-- Crear índice para ordenamiento eficiente
CREATE INDEX idx_productos_ordenamiento ON productos(categoria, precio DESC, nombre);

-- Consulta de ordenamiento optimizada
SELECT 
    nombre,
    categoria,
    precio
FROM productos
WHERE categoria = 'Electrónicos'
ORDER BY precio DESC, nombre
LIMIT 50;
```

### Ejercicio 10: Mantenimiento de Índices
```sql
-- Reconstruir índice fragmentado
ALTER TABLE ventas DROP INDEX idx_ventas_producto_fecha;
CREATE INDEX idx_ventas_producto_fecha ON ventas(producto_id, fecha);

-- Actualizar estadísticas
ANALYZE TABLE ventas;

-- Verificar mejora
SHOW INDEX FROM ventas;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Índices Compuestos**: Diseño y optimización para consultas multi-columna
2. **Índices de Cobertura**: Incluir todas las columnas necesarias
3. **Índices Parciales**: Solo para subconjuntos de datos
4. **Índices de Texto Completo**: Búsquedas avanzadas de texto
5. **Índices Funcionales**: Basados en expresiones y funciones
6. **Índices Espaciales**: Para datos geográficos
7. **Índices Hash**: Para búsquedas de igualdad exacta
8. **Mantenimiento**: Análisis, reconstrucción y optimización
9. **Monitoreo**: Análisis de uso y rendimiento
10. **Estrategias**: Optimización para diferentes patrones de consulta

## Próxima Clase
En la siguiente clase exploraremos técnicas de particionamiento de tablas para manejar grandes volúmenes de datos de manera eficiente.

## Recursos Adicionales
- Documentación de índices de MySQL
- Guías de diseño de índices
- Herramientas de análisis de rendimiento
- Mejores prácticas de indexación
