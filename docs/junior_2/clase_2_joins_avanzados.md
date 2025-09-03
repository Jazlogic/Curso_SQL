# Clase 2: JOINs Avanzados - Conexiones Complejas

## 📚 Descripción de la Clase
En esta clase profundizarás en los JOINs avanzados de SQL, aprendiendo técnicas más sofisticadas para combinar datos. Dominarás FULL OUTER JOIN, self-joins, múltiples JOINs, y técnicas de optimización que te permitirán crear consultas complejas y eficientes.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Usar FULL OUTER JOIN para combinar todos los registros de ambas tablas
- Implementar self-joins para relacionar una tabla consigo misma
- Crear consultas con múltiples JOINs (3 o más tablas)
- Aplicar técnicas de optimización para JOINs complejos
- Resolver problemas complejos usando combinaciones de JOINs
- Entender el orden de ejecución en JOINs múltiples

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### FULL OUTER JOIN - Unión Completa

FULL OUTER JOIN combina los resultados de LEFT JOIN y RIGHT JOIN, devolviendo todos los registros de ambas tablas.

#### Sintaxis de FULL OUTER JOIN
```sql
SELECT columnas
FROM tabla1
FULL OUTER JOIN tabla2 ON tabla1.clave = tabla2.clave;
```

**Explicación línea por línea:**
- `FULL OUTER JOIN`: incluye todos los registros de ambas tablas
- Registros sin coincidencia muestran NULL en las columnas de la otra tabla
- Útil para análisis completos de datos

**Nota**: MySQL no soporta FULL OUTER JOIN directamente, pero se puede simular con UNION.

#### Simulando FULL OUTER JOIN en MySQL
```sql
-- Simular FULL OUTER JOIN con UNION
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
```

**Explicación línea por línea:**
- `LEFT JOIN`: obtiene todos los productos
- `UNION`: combina resultados sin duplicados
- `RIGHT JOIN`: obtiene todas las categorías
- Resultado: todos los productos y todas las categorías

### Self-Joins - Uniendo una Tabla Consigo Misma

Self-join es una técnica donde una tabla se une consigo misma usando alias diferentes.

#### Casos de Uso de Self-Joins
- **Jerarquías**: Empleados y supervisores
- **Comparaciones**: Productos similares
- **Relaciones**: Usuarios y amigos
- **Secuencias**: Eventos consecutivos

#### Ejemplo de Self-Join
```sql
-- Tabla de empleados con supervisores
CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    supervisor_id INT,
    FOREIGN KEY (supervisor_id) REFERENCES empleados(id)
);

-- Self-join para obtener empleados con sus supervisores
SELECT 
    e.nombre AS empleado,
    s.nombre AS supervisor
FROM empleados e
LEFT JOIN empleados s ON e.supervisor_id = s.id;
```

**Explicación línea por línea:**
- `empleados e`: tabla principal con alias 'e'
- `empleados s`: misma tabla con alias 's' para supervisores
- `ON e.supervisor_id = s.id`: condición de auto-referencia
- `LEFT JOIN`: incluye empleados sin supervisor

### Múltiples JOINs - Combinando Varias Tablas

Los múltiples JOINs permiten combinar datos de tres o más tablas en una sola consulta.

#### Sintaxis de Múltiples JOINs
```sql
SELECT columnas
FROM tabla1
JOIN tabla2 ON tabla1.clave = tabla2.clave
JOIN tabla3 ON tabla2.clave = tabla3.clave
JOIN tabla4 ON tabla3.clave = tabla4.clave;
```

**Explicación línea por línea:**
- Los JOINs se ejecutan de izquierda a derecha
- Cada JOIN se basa en el resultado del anterior
- El orden puede afectar el rendimiento

#### Ejemplo de Múltiples JOINs
```sql
-- Consulta con 4 tablas: productos, categorias, pedidos, usuarios
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    u.nombre AS cliente,
    ped.fecha_pedido
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
INNER JOIN pedidos ped ON dp.pedido_id = ped.id
INNER JOIN usuarios u ON ped.usuario_id = u.id;
```

**Explicación línea por línea:**
- `productos p`: tabla principal
- `INNER JOIN categorias c`: une categorías
- `INNER JOIN detalle_pedidos dp`: une detalles de pedidos
- `INNER JOIN pedidos ped`: une pedidos
- `INNER JOIN usuarios u`: une usuarios
- Resultado: información completa de ventas

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Base de Datos Extendida

```sql
-- Extender la base de datos del ejemplo anterior
USE ecommerce_joins;

-- Tabla de detalle de pedidos
CREATE TABLE detalle_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Tabla de empleados con jerarquía
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    puesto VARCHAR(100),
    supervisor_id INT,
    salario DECIMAL(10,2),
    FOREIGN KEY (supervisor_id) REFERENCES empleados(id)
);

-- Insertar datos de detalle de pedidos
INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 999.99),
(2, 1, 1, 999.99),
(2, 7, 1, 1299.99),
(3, 3, 1, 29.99),
(3, 5, 1, 19.99),
(4, 4, 1, 599.99),
(5, 5, 1, 19.99),
(5, 6, 1, 15.99);

-- Insertar datos de empleados
INSERT INTO empleados (nombre, puesto, supervisor_id, salario) VALUES
('Juan Pérez', 'CEO', NULL, 10000.00),
('Ana García', 'Gerente Ventas', 1, 5000.00),
('Carlos López', 'Vendedor', 2, 3000.00),
('María Rodríguez', 'Vendedora', 2, 3000.00),
('José Martín', 'Gerente IT', 1, 5500.00),
('Laura Sánchez', 'Desarrolladora', 5, 4000.00);
```

### Ejemplo 2: FULL OUTER JOIN Simulado

```sql
-- Consulta 1: Simular FULL OUTER JOIN con UNION
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    'Producto' AS origen
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id

UNION

SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    'Categoria' AS origen
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
WHERE p.id IS NULL;

-- Explicación línea por línea:
-- LEFT JOIN: todos los productos con sus categorías
-- UNION: combina sin duplicados
-- RIGHT JOIN con WHERE p.id IS NULL: solo categorías sin productos
-- 'origen': indica de dónde viene cada registro

-- Consulta 2: Análisis completo de productos y categorías
SELECT 
    COALESCE(p.nombre, 'Sin Producto') AS producto,
    COALESCE(c.nombre, 'Sin Categoría') AS categoria,
    p.precio,
    p.stock
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id

UNION

SELECT 
    COALESCE(p.nombre, 'Sin Producto') AS producto,
    COALESCE(c.nombre, 'Sin Categoría') AS categoria,
    p.precio,
    p.stock
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
WHERE p.id IS NULL;

-- Explicación línea por línea:
-- COALESCE: reemplaza NULL con texto descriptivo
-- LEFT JOIN: todos los productos
-- RIGHT JOIN con filtro: categorías sin productos
-- Resultado: vista completa de productos y categorías
```

### Ejemplo 3: Self-Joins en Acción

```sql
-- Consulta 1: Empleados con sus supervisores
SELECT 
    e.nombre AS empleado,
    e.puesto,
    e.salario,
    COALESCE(s.nombre, 'Sin Supervisor') AS supervisor,
    s.puesto AS puesto_supervisor
FROM empleados e
LEFT JOIN empleados s ON e.supervisor_id = s.id;

-- Explicación línea por línea:
-- empleados e: tabla de empleados con alias 'e'
-- empleados s: misma tabla con alias 's' para supervisores
-- LEFT JOIN: incluye empleados sin supervisor
-- COALESCE: maneja empleados sin supervisor

-- Consulta 2: Jerarquía completa con niveles
SELECT 
    e.nombre AS empleado,
    e.puesto,
    s.nombre AS supervisor_directo,
    ss.nombre AS supervisor_del_supervisor
FROM empleados e
LEFT JOIN empleados s ON e.supervisor_id = s.id
LEFT JOIN empleados ss ON s.supervisor_id = ss.id;

-- Explicación línea por línea:
-- e: empleado principal
-- s: supervisor directo
-- ss: supervisor del supervisor (abuelo jerárquico)
-- Múltiples self-joins para mostrar jerarquía

-- Consulta 3: Empleados del mismo nivel
SELECT 
    e1.nombre AS empleado1,
    e2.nombre AS empleado2,
    e1.puesto,
    s.nombre AS supervisor_comun
FROM empleados e1
INNER JOIN empleados e2 ON e1.supervisor_id = e2.supervisor_id
INNER JOIN empleados s ON e1.supervisor_id = s.id
WHERE e1.id < e2.id;

-- Explicación línea por línea:
-- e1, e2: dos instancias de empleados
-- ON e1.supervisor_id = e2.supervisor_id: mismo supervisor
-- WHERE e1.id < e2.id: evita duplicados y auto-coincidencias
-- Encuentra empleados que reportan al mismo supervisor
```

### Ejemplo 4: Múltiples JOINs Complejos

```sql
-- Consulta 1: Reporte completo de ventas
SELECT 
    u.nombre AS cliente,
    u.email,
    ped.id AS pedido_id,
    ped.fecha_pedido,
    p.nombre AS producto,
    c.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal
FROM usuarios u
INNER JOIN pedidos ped ON u.id = ped.usuario_id
INNER JOIN detalle_pedidos dp ON ped.id = dp.pedido_id
INNER JOIN productos p ON dp.producto_id = p.id
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY ped.fecha_pedido DESC, u.nombre;

-- Explicación línea por línea:
-- usuarios u: información del cliente
-- pedidos ped: información del pedido
-- detalle_pedidos dp: productos en el pedido
-- productos p: información del producto
-- categorias c: categoría del producto
-- (dp.cantidad * dp.precio_unitario): cálculo del subtotal
-- ORDER BY: ordenar por fecha y cliente

-- Consulta 2: Análisis de ventas por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT ped.id) AS total_pedidos,
    COUNT(dp.id) AS total_items_vendidos,
    SUM(dp.cantidad) AS cantidad_total,
    SUM(dp.cantidad * dp.precio_unitario) AS ventas_total,
    AVG(dp.precio_unitario) AS precio_promedio
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
LEFT JOIN pedidos ped ON dp.pedido_id = ped.id
GROUP BY c.id, c.nombre
ORDER BY ventas_total DESC;

-- Explicación línea por línea:
-- LEFT JOIN: incluye categorías sin ventas
-- COUNT(DISTINCT ped.id): pedidos únicos
-- COUNT(dp.id): items vendidos
-- SUM(dp.cantidad): cantidad total vendida
-- SUM(cantidad * precio): ventas totales
-- GROUP BY: agrupa por categoría

-- Consulta 3: Top clientes con detalles completos
SELECT 
    u.nombre AS cliente,
    u.email,
    COUNT(DISTINCT ped.id) AS total_pedidos,
    SUM(dp.cantidad) AS items_comprados,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado,
    AVG(ped.total) AS promedio_por_pedido,
    MAX(ped.fecha_pedido) AS ultima_compra
FROM usuarios u
INNER JOIN pedidos ped ON u.id = ped.usuario_id
INNER JOIN detalle_pedidos dp ON ped.id = dp.pedido_id
GROUP BY u.id, u.nombre, u.email
HAVING total_gastado > 500
ORDER BY total_gastado DESC;

-- Explicación línea por línea:
-- INNER JOIN: solo usuarios con pedidos
-- COUNT(DISTINCT ped.id): pedidos únicos por cliente
-- SUM(cantidad * precio): total gastado por cliente
-- AVG(ped.total): promedio por pedido
-- HAVING total_gastado > 500: filtro después de agregación
-- ORDER BY: clientes que más gastan primero
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: FULL OUTER JOIN Simulado
**Objetivo**: Practicar la simulación de FULL OUTER JOIN con UNION.

**Instrucciones**:
1. Crear consulta que muestre todos los productos y todas las categorías
2. Identificar productos sin categoría y categorías sin productos
3. Crear reporte completo de usuarios y pedidos
4. Analizar datos faltantes en ambas direcciones

**Solución paso a paso:**

```sql
-- Consulta 1: Todos los productos y todas las categorías
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    p.precio,
    'Con Categoría' AS estado
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id

UNION

SELECT 
    NULL AS producto,
    c.nombre AS categoria,
    NULL AS precio,
    'Sin Productos' AS estado
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
WHERE p.id IS NULL;

-- Explicación:
-- LEFT JOIN: todos los productos con sus categorías
-- UNION: combina resultados
-- RIGHT JOIN + WHERE p.id IS NULL: categorías sin productos

-- Consulta 2: Identificar datos faltantes
SELECT 
    'Productos sin categoría' AS tipo,
    COUNT(*) AS cantidad
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE c.id IS NULL

UNION ALL

SELECT 
    'Categorías sin productos' AS tipo,
    COUNT(*) AS cantidad
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
WHERE p.id IS NULL;

-- Explicación:
-- UNION ALL: incluye duplicados si los hay
-- Cuenta productos sin categoría y categorías sin productos

-- Consulta 3: Reporte completo usuarios y pedidos
SELECT 
    u.nombre AS usuario,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre

UNION

SELECT 
    'HUÉRFANOS' AS usuario,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado
FROM pedidos p
LEFT JOIN usuarios u ON p.usuario_id = u.id
WHERE u.id IS NULL;

-- Explicación:
-- LEFT JOIN: todos los usuarios con pedidos
-- UNION: incluye pedidos huérfanos (sin usuario válido)
-- COALESCE: maneja valores NULL
```

### Ejercicio 2: Self-Joins Avanzados
**Objetivo**: Dominar self-joins para diferentes casos de uso.

**Instrucciones**:
1. Mostrar jerarquía completa de empleados
2. Encontrar empleados del mismo nivel jerárquico
3. Calcular diferencias salariales entre niveles
4. Identificar empleados sin subordinados

**Solución paso a paso:**

```sql
-- Consulta 1: Jerarquía completa con niveles
SELECT 
    e.nombre AS empleado,
    e.puesto,
    e.salario,
    s.nombre AS supervisor,
    ss.nombre AS gerente,
    CASE 
        WHEN e.supervisor_id IS NULL THEN 'Nivel 1 (CEO)'
        WHEN s.supervisor_id IS NULL THEN 'Nivel 2 (Gerente)'
        ELSE 'Nivel 3 (Empleado)'
    END AS nivel_jerarquico
FROM empleados e
LEFT JOIN empleados s ON e.supervisor_id = s.id
LEFT JOIN empleados ss ON s.supervisor_id = ss.id;

-- Explicación:
-- e: empleado principal
-- s: supervisor directo
-- ss: supervisor del supervisor
-- CASE: determina nivel jerárquico

-- Consulta 2: Empleados del mismo nivel con comparación salarial
SELECT 
    e1.nombre AS empleado1,
    e1.salario AS salario1,
    e2.nombre AS empleado2,
    e2.salario AS salario2,
    ABS(e1.salario - e2.salario) AS diferencia_salarial,
    s.nombre AS supervisor_comun
FROM empleados e1
INNER JOIN empleados e2 ON e1.supervisor_id = e2.supervisor_id
INNER JOIN empleados s ON e1.supervisor_id = s.id
WHERE e1.id < e2.id
ORDER BY diferencia_salarial DESC;

-- Explicación:
-- e1, e2: empleados del mismo supervisor
-- ABS: valor absoluto de la diferencia
-- WHERE e1.id < e2.id: evita duplicados

-- Consulta 3: Empleados sin subordinados
SELECT 
    e.nombre AS empleado,
    e.puesto,
    e.salario,
    'Sin Subordinados' AS estado
FROM empleados e
LEFT JOIN empleados sub ON e.id = sub.supervisor_id
WHERE sub.id IS NULL AND e.supervisor_id IS NOT NULL;

-- Explicación:
-- LEFT JOIN: empleados con posibles subordinados
-- WHERE sub.id IS NULL: no tiene subordinados
-- AND e.supervisor_id IS NOT NULL: excluye CEO
```

### Ejercicio 3: Múltiples JOINs Complejos
**Objetivo**: Crear consultas con múltiples tablas y análisis avanzados.

**Instrucciones**:
1. Crear reporte de ventas completo con todas las tablas
2. Analizar rendimiento por empleado (si tuvieran ventas)
3. Crear dashboard de métricas de negocio
4. Identificar productos más vendidos por categoría

**Solución paso a paso:**

```sql
-- Consulta 1: Reporte de ventas completo
SELECT 
    DATE(ped.fecha_pedido) AS fecha,
    u.nombre AS cliente,
    u.email,
    p.nombre AS producto,
    c.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal,
    ped.total AS total_pedido
FROM pedidos ped
INNER JOIN usuarios u ON ped.usuario_id = u.id
INNER JOIN detalle_pedidos dp ON ped.id = dp.pedido_id
INNER JOIN productos p ON dp.producto_id = p.id
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY ped.fecha_pedido DESC, subtotal DESC;

-- Explicación:
-- DATE(): extrae solo la fecha
-- Múltiples INNER JOINs para información completa
-- ORDER BY: ordena por fecha y valor

-- Consulta 2: Dashboard de métricas
SELECT 
    'Total Ventas' AS metric,
    CONCAT('$', FORMAT(SUM(dp.cantidad * dp.precio_unitario), 2)) AS valor
FROM detalle_pedidos dp

UNION ALL

SELECT 
    'Total Pedidos' AS metric,
    COUNT(DISTINCT ped.id) AS valor
FROM pedidos ped

UNION ALL

SELECT 
    'Clientes Únicos' AS metric,
    COUNT(DISTINCT u.id) AS valor
FROM usuarios u
INNER JOIN pedidos ped ON u.id = ped.usuario_id

UNION ALL

SELECT 
    'Productos Vendidos' AS metric,
    COUNT(DISTINCT p.id) AS valor
FROM productos p
INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id;

-- Explicación:
-- UNION ALL: combina métricas diferentes
-- FORMAT: formatea números con comas
-- COUNT(DISTINCT): cuenta únicos

-- Consulta 3: Productos más vendidos por categoría
SELECT 
    c.nombre AS categoria,
    p.nombre AS producto,
    SUM(dp.cantidad) AS total_vendido,
    SUM(dp.cantidad * dp.precio_unitario) AS ingresos,
    RANK() OVER (PARTITION BY c.id ORDER BY SUM(dp.cantidad) DESC) AS ranking
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
GROUP BY c.id, c.nombre, p.id, p.nombre
ORDER BY c.nombre, ranking;

-- Explicación:
-- RANK() OVER: ranking por categoría
-- PARTITION BY c.id: separa ranking por categoría
-- ORDER BY SUM(cantidad) DESC: ordena por cantidad vendida
```

---

## 📝 Resumen de Conceptos Clave

### JOINs Avanzados:
- **FULL OUTER JOIN**: Todos los registros de ambas tablas (simular con UNION en MySQL)
- **Self-JOIN**: Una tabla se une consigo misma usando alias
- **Múltiples JOINs**: Combinar 3 o más tablas en una consulta

### Técnicas Importantes:
- **UNION vs UNION ALL**: Sin duplicados vs con duplicados
- **Alias de tabla**: Esenciales para self-joins y claridad
- **COALESCE**: Manejo de valores NULL
- **Funciones de ventana**: RANK(), ROW_NUMBER() para análisis

### Optimización:
- **Orden de JOINs**: Puede afectar rendimiento
- **Índices**: Cruciales en columnas de JOIN
- **Filtros tempranos**: WHERE antes de JOINs cuando es posible
- **EXPLAIN**: Para analizar planes de ejecución

### Mejores Prácticas:
1. **Usa alias descriptivos** para todas las tablas
2. **Documenta consultas complejas** con comentarios
3. **Prueba con datos pequeños** antes de ejecutar en producción
4. **Considera el rendimiento** en consultas con muchas tablas
5. **Valida resultados** con consultas más simples

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Subconsultas básicas en WHERE, SELECT y FROM
- Subconsultas correlacionadas
- Operadores EXISTS, IN, ANY, ALL
- Comparación entre JOINs y subconsultas

---

## 💡 Consejos para el Éxito

1. **Dibuja diagramas**: Visualiza las relaciones entre tablas
2. **Empieza simple**: Construye consultas paso a paso
3. **Usa EXPLAIN**: Entiende cómo se ejecutan tus consultas
4. **Practica self-joins**: Son útiles en muchos casos reales
5. **Optimiza siempre**: Considera el rendimiento desde el inicio

---

## 🧭 Navegación

**← Anterior**: [Clase 1: JOINs Básicos](clase_1_joins_basicos.md)  
**Siguiente →**: [Clase 3: Subconsultas Básicas](clase_3_subconsultas_basicas.md)

---

*¡Excelente trabajo! Ahora dominas los JOINs avanzados en SQL. 🚀*
