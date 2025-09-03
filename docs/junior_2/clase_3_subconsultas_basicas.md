# Clase 3: Subconsultas Básicas - Consultas Anidadas

## 📚 Descripción de la Clase
En esta clase aprenderás las subconsultas básicas en SQL, una técnica poderosa que te permite anidar consultas dentro de otras consultas. Dominarás el uso de subconsultas en WHERE, SELECT y FROM, entendiendo cuándo y cómo usarlas para resolver problemas complejos de manera elegante y eficiente.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las subconsultas y por qué son útiles
- Usar subconsultas en la cláusula WHERE para filtros complejos
- Implementar subconsultas en la cláusula SELECT para cálculos dinámicos
- Aplicar subconsultas en la cláusula FROM como tablas virtuales
- Comparar subconsultas con JOINs y entender cuándo usar cada una
- Optimizar subconsultas para mejor rendimiento

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Subconsultas?

Las **subconsultas** (también llamadas consultas anidadas o subqueries) son consultas SQL que se ejecutan dentro de otra consulta. Son una herramienta fundamental para resolver problemas complejos que requieren múltiples pasos de procesamiento.

#### Características de las Subconsultas:
- **Anidamiento**: Una consulta dentro de otra
- **Independencia**: Pueden ejecutarse por separado
- **Resultado único**: Devuelven un valor, una fila o múltiples filas
- **Contexto**: Acceden a datos de la consulta externa

#### Ventajas de las Subconsultas:
- **Legibilidad**: Código más claro y comprensible
- **Modularidad**: Dividen problemas complejos en partes simples
- **Flexibilidad**: Se adaptan a diferentes contextos
- **Mantenibilidad**: Fáciles de modificar y depurar

### Sintaxis General de Subconsultas

```sql
SELECT columnas
FROM tabla1
WHERE columna OPERADOR (
    SELECT columna
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `SELECT columnas`: consulta principal (externa)
- `WHERE columna OPERADOR`: condición que usa la subconsulta
- `(SELECT columna FROM tabla2 WHERE condicion)`: subconsulta (interna)
- Los paréntesis son obligatorios para delimitar la subconsulta

### 1. Subconsultas en WHERE - Filtros Dinámicos

Las subconsultas en WHERE permiten crear filtros basados en resultados de otras consultas.

#### 1.1 Subconsultas con Operadores de Comparación
```sql
SELECT columnas
FROM tabla1
WHERE columna OPERADOR (
    SELECT columna
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `WHERE columna OPERADOR`: condición de comparación
- `OPERADOR`: puede ser =, >, <, >=, <=, !=
- La subconsulta debe devolver un solo valor
- Si devuelve múltiples valores, se produce error

#### 1.2 Ejemplo Básico de Subconsulta en WHERE
```sql
-- Encontrar productos más caros que el precio promedio
SELECT 
    nombre,
    precio
FROM productos
WHERE precio > (
    SELECT AVG(precio)
    FROM productos
);
```

**Explicación línea por línea:**
- `WHERE precio >`: compara precio con resultado de subconsulta
- `(SELECT AVG(precio) FROM productos)`: calcula precio promedio
- `AVG(precio)`: función agregada que devuelve un solo valor
- Resultado: productos con precio superior al promedio

### 2. Subconsultas en SELECT - Cálculos Dinámicos

Las subconsultas en SELECT permiten incluir cálculos basados en otras tablas.

#### 2.1 Sintaxis de Subconsulta en SELECT
```sql
SELECT 
    columna1,
    columna2,
    (SELECT columna FROM tabla2 WHERE condicion) AS alias
FROM tabla1;
```

**Explicación línea por línea:**
- `(SELECT columna FROM tabla2 WHERE condicion)`: subconsulta en SELECT
- `AS alias`: nombre para la columna calculada
- La subconsulta debe devolver un solo valor por fila
- Se ejecuta para cada fila de la consulta principal

#### 2.2 Ejemplo de Subconsulta en SELECT
```sql
-- Mostrar productos con el nombre de su categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    (SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id) AS categoria
FROM productos p;
```

**Explicación línea por línea:**
- `p.nombre AS producto`: nombre del producto
- `p.precio`: precio del producto
- `(SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id)`: subconsulta
- `WHERE c.id = p.categoria_id`: condición de relación
- `AS categoria`: alias para la columna calculada

### 3. Subconsultas en FROM - Tablas Virtuales

Las subconsultas en FROM actúan como tablas temporales o virtuales.

#### 3.1 Sintaxis de Subconsulta en FROM
```sql
SELECT columnas
FROM (
    SELECT columnas
    FROM tabla
    WHERE condicion
) AS alias_tabla
WHERE condicion_adicional;
```

**Explicación línea por línea:**
- `FROM (SELECT ...)`: subconsulta que actúa como tabla
- `AS alias_tabla`: alias obligatorio para la tabla virtual
- `WHERE condicion_adicional`: filtros adicionales en la consulta externa
- Útil para simplificar consultas complejas

#### 3.2 Ejemplo de Subconsulta en FROM
```sql
-- Encontrar productos con ventas superiores al promedio
SELECT 
    p.nombre,
    p.precio,
    ventas.total_vendido
FROM productos p
INNER JOIN (
    SELECT 
        producto_id,
        SUM(cantidad) AS total_vendido
    FROM detalle_pedidos
    GROUP BY producto_id
) AS ventas ON p.id = ventas.producto_id
WHERE ventas.total_vendido > (
    SELECT AVG(total_vendido)
    FROM (
        SELECT SUM(cantidad) AS total_vendido
        FROM detalle_pedidos
        GROUP BY producto_id
    ) AS promedio_ventas
);
```

**Explicación línea por línea:**
- `INNER JOIN (SELECT ...) AS ventas`: subconsulta como tabla virtual
- `SUM(cantidad) AS total_vendido`: suma ventas por producto
- `GROUP BY producto_id`: agrupa por producto
- `WHERE ventas.total_vendido >`: filtra por ventas superiores al promedio
- Subconsulta anidada para calcular el promedio

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Base de Datos Extendida

```sql
-- Usar la base de datos del ejemplo anterior
USE ecommerce_joins;

-- Agregar más datos para ejemplos de subconsultas
INSERT INTO productos (nombre, precio, categoria_id, stock) VALUES
('iPad Pro', 1099.99, 1, 12),
('MacBook Air', 1299.99, 1, 8),
('Zapatillas Adidas', 89.99, 2, 45),
('Mesa de escritorio', 299.99, 3, 15),
('Raqueta de tenis', 149.99, 4, 20),
('Diccionario Oxford', 25.99, 5, 30);

INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 2, 1, 899.99),
(2, 3, 2, 29.99),
(2, 5, 1, 19.99),
(3, 1, 1, 999.99),
(4, 6, 1, 15.99),
(4, 7, 1, 1299.99),
(5, 8, 1, 79.99),
(5, 9, 1, 1099.99);

-- Agregar más pedidos
INSERT INTO pedidos (usuario_id, total) VALUES
(2, 89.98),
(3, 1019.98),
(4, 1315.98),
(5, 1179.98);
```

### Ejemplo 2: Subconsultas en WHERE

```sql
-- Consulta 1: Productos más caros que el precio promedio
SELECT 
    nombre AS producto,
    precio,
    'Superior al promedio' AS categoria_precio
FROM productos
WHERE precio > (
    SELECT AVG(precio)
    FROM productos
);

-- Explicación línea por línea:
-- WHERE precio >: compara con resultado de subconsulta
-- (SELECT AVG(precio) FROM productos): calcula precio promedio
-- AVG(precio): función agregada que devuelve un solo valor
-- Resultado: productos con precio superior al promedio

-- Consulta 2: Productos de la categoría más popular
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE c.id = (
    SELECT categoria_id
    FROM productos
    GROUP BY categoria_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Explicación línea por línea:
-- WHERE c.id =: compara ID de categoría
-- (SELECT categoria_id FROM productos GROUP BY categoria_id ORDER BY COUNT(*) DESC LIMIT 1): subconsulta
-- GROUP BY categoria_id: agrupa por categoría
-- ORDER BY COUNT(*) DESC: ordena por cantidad de productos
-- LIMIT 1: toma solo la categoría con más productos

-- Consulta 3: Usuarios que han gastado más que el promedio
SELECT 
    u.nombre AS usuario,
    u.email,
    SUM(p.total) AS total_gastado
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email
HAVING SUM(p.total) > (
    SELECT AVG(total_gastado)
    FROM (
        SELECT SUM(total) AS total_gastado
        FROM pedidos
        GROUP BY usuario_id
    ) AS gastos_por_usuario
);

-- Explicación línea por línea:
-- HAVING SUM(p.total) >: filtra después de agregación
-- (SELECT AVG(total_gastado) FROM (SELECT SUM(total) AS total_gastado FROM pedidos GROUP BY usuario_id) AS gastos_por_usuario): subconsulta anidada
-- Subconsulta interna: calcula gasto total por usuario
-- Subconsulta externa: calcula promedio de gastos
-- HAVING: filtra grupos con gasto superior al promedio
```

### Ejemplo 3: Subconsultas en SELECT

```sql
-- Consulta 1: Productos con información de categoría usando subconsulta
SELECT 
    p.nombre AS producto,
    p.precio,
    p.stock,
    (SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id) AS categoria,
    (SELECT c.descripcion FROM categorias c WHERE c.id = p.categoria_id) AS descripcion_categoria
FROM productos p;

-- Explicación línea por línea:
-- p.nombre AS producto: nombre del producto
-- p.precio: precio del producto
-- p.stock: stock disponible
-- (SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id): subconsulta para nombre de categoría
-- (SELECT c.descripcion FROM categorias c WHERE c.id = p.categoria_id): subconsulta para descripción
-- WHERE c.id = p.categoria_id: condición de relación

-- Consulta 2: Usuarios con estadísticas de pedidos
SELECT 
    u.nombre AS usuario,
    u.email,
    (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id) AS total_pedidos,
    (SELECT SUM(total) FROM pedidos p WHERE p.usuario_id = u.id) AS total_gastado,
    (SELECT AVG(total) FROM pedidos p WHERE p.usuario_id = u.id) AS promedio_por_pedido,
    (SELECT MAX(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id) AS ultima_compra
FROM usuarios u;

-- Explicación línea por línea:
-- u.nombre AS usuario: nombre del usuario
-- u.email: email del usuario
-- (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id): cuenta pedidos del usuario
-- (SELECT SUM(total) FROM pedidos p WHERE p.usuario_id = u.id): suma total gastado
-- (SELECT AVG(total) FROM pedidos p WHERE p.usuario_id = u.id): promedio por pedido
-- (SELECT MAX(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id): última compra
-- WHERE p.usuario_id = u.id: condición de relación en cada subconsulta

-- Consulta 3: Productos con información de ventas
SELECT 
    p.nombre AS producto,
    p.precio,
    p.stock,
    (SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS total_vendido,
    (SELECT COUNT(DISTINCT dp.pedido_id) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS pedidos_con_producto,
    (SELECT SUM(dp.cantidad * dp.precio_unitario) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS ingresos_generados
FROM productos p;

-- Explicación línea por línea:
-- p.nombre AS producto: nombre del producto
-- p.precio: precio del producto
-- p.stock: stock disponible
-- (SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): cantidad total vendida
-- (SELECT COUNT(DISTINCT dp.pedido_id) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): pedidos únicos con el producto
-- (SELECT SUM(dp.cantidad * dp.precio_unitario) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): ingresos generados
-- WHERE dp.producto_id = p.id: condición de relación en cada subconsulta
```

### Ejemplo 4: Subconsultas en FROM

```sql
-- Consulta 1: Top 3 productos más vendidos con información completa
SELECT 
    p.nombre AS producto,
    p.precio,
    ventas.total_vendido,
    ventas.ingresos_generados,
    c.nombre AS categoria
FROM productos p
INNER JOIN (
    SELECT 
        producto_id,
        SUM(cantidad) AS total_vendido,
        SUM(cantidad * precio_unitario) AS ingresos_generados
    FROM detalle_pedidos
    GROUP BY producto_id
    ORDER BY SUM(cantidad) DESC
    LIMIT 3
) AS ventas ON p.id = ventas.producto_id
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Explicación línea por línea:
-- INNER JOIN (SELECT ...) AS ventas: subconsulta como tabla virtual
-- SELECT producto_id, SUM(cantidad) AS total_vendido, SUM(cantidad * precio_unitario) AS ingresos_generados: columnas de la tabla virtual
-- FROM detalle_pedidos: tabla fuente de la subconsulta
-- GROUP BY producto_id: agrupa por producto
-- ORDER BY SUM(cantidad) DESC: ordena por cantidad vendida
-- LIMIT 3: toma solo los 3 productos más vendidos
-- ON p.id = ventas.producto_id: condición de unión con tabla virtual

-- Consulta 2: Usuarios con ranking de gastos
SELECT 
    u.nombre AS usuario,
    u.email,
    gastos.total_gastado,
    gastos.total_pedidos,
    gastos.promedio_por_pedido,
    RANK() OVER (ORDER BY gastos.total_gastado DESC) AS ranking_gastos
FROM usuarios u
INNER JOIN (
    SELECT 
        usuario_id,
        SUM(total) AS total_gastado,
        COUNT(*) AS total_pedidos,
        AVG(total) AS promedio_por_pedido
    FROM pedidos
    GROUP BY usuario_id
) AS gastos ON u.id = gastos.usuario_id
ORDER BY gastos.total_gastado DESC;

-- Explicación línea por línea:
-- INNER JOIN (SELECT ...) AS gastos: subconsulta como tabla virtual
-- SELECT usuario_id, SUM(total) AS total_gastado, COUNT(*) AS total_pedidos, AVG(total) AS promedio_por_pedido: estadísticas por usuario
-- FROM pedidos: tabla fuente
-- GROUP BY usuario_id: agrupa por usuario
-- RANK() OVER (ORDER BY gastos.total_gastado DESC): ranking por gasto total
-- ON u.id = gastos.usuario_id: condición de unión

-- Consulta 3: Análisis de categorías con subconsulta compleja
SELECT 
    c.nombre AS categoria,
    c.descripcion,
    stats.total_productos,
    stats.precio_promedio,
    stats.total_vendido,
    stats.ingresos_totales
FROM categorias c
INNER JOIN (
    SELECT 
        p.categoria_id,
        COUNT(p.id) AS total_productos,
        AVG(p.precio) AS precio_promedio,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_totales
    FROM productos p
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.categoria_id
) AS stats ON c.id = stats.categoria_id
ORDER BY stats.ingresos_totales DESC;

-- Explicación línea por línea:
-- INNER JOIN (SELECT ...) AS stats: subconsulta como tabla virtual
-- SELECT p.categoria_id, COUNT(p.id) AS total_productos, AVG(p.precio) AS precio_promedio: estadísticas por categoría
-- LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id: une con ventas
-- COALESCE(SUM(dp.cantidad), 0): maneja categorías sin ventas
-- COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0): maneja ingresos nulos
-- GROUP BY p.categoria_id: agrupa por categoría
-- ON c.id = stats.categoria_id: condición de unión
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Subconsultas en WHERE
**Objetivo**: Practicar subconsultas en la cláusula WHERE para filtros dinámicos.

**Instrucciones**:
1. Encontrar productos más caros que el precio promedio
2. Mostrar usuarios que han hecho más pedidos que el promedio
3. Identificar categorías con más productos que el promedio
4. Encontrar productos con stock superior al promedio

**Solución paso a paso:**

```sql
-- Consulta 1: Productos más caros que el precio promedio
SELECT 
    nombre AS producto,
    precio,
    ROUND((SELECT AVG(precio) FROM productos), 2) AS precio_promedio
FROM productos
WHERE precio > (
    SELECT AVG(precio)
    FROM productos
);

-- Explicación:
-- WHERE precio >: compara con resultado de subconsulta
-- (SELECT AVG(precio) FROM productos): calcula precio promedio
-- ROUND((SELECT AVG(precio) FROM productos), 2): muestra el promedio para referencia

-- Consulta 2: Usuarios con más pedidos que el promedio
SELECT 
    u.nombre AS usuario,
    u.email,
    COUNT(p.id) AS total_pedidos
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email
HAVING COUNT(p.id) > (
    SELECT AVG(total_pedidos)
    FROM (
        SELECT COUNT(*) AS total_pedidos
        FROM pedidos
        GROUP BY usuario_id
    ) AS pedidos_por_usuario
);

-- Explicación:
-- HAVING COUNT(p.id) >: filtra después de agregación
-- (SELECT AVG(total_pedidos) FROM (SELECT COUNT(*) AS total_pedidos FROM pedidos GROUP BY usuario_id) AS pedidos_por_usuario): subconsulta anidada
-- Subconsulta interna: cuenta pedidos por usuario
-- Subconsulta externa: calcula promedio de pedidos

-- Consulta 3: Categorías con más productos que el promedio
SELECT 
    c.nombre AS categoria,
    c.descripcion,
    COUNT(p.id) AS total_productos
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre, c.descripcion
HAVING COUNT(p.id) > (
    SELECT AVG(total_productos)
    FROM (
        SELECT COUNT(*) AS total_productos
        FROM productos
        GROUP BY categoria_id
    ) AS productos_por_categoria
);

-- Explicación:
-- HAVING COUNT(p.id) >: filtra categorías con más productos
-- (SELECT AVG(total_productos) FROM (SELECT COUNT(*) AS total_productos FROM productos GROUP BY categoria_id) AS productos_por_categoria): subconsulta anidada
-- Subconsulta interna: cuenta productos por categoría
-- Subconsulta externa: calcula promedio de productos por categoría

-- Consulta 4: Productos con stock superior al promedio
SELECT 
    nombre AS producto,
    precio,
    stock,
    ROUND((SELECT AVG(stock) FROM productos), 2) AS stock_promedio
FROM productos
WHERE stock > (
    SELECT AVG(stock)
    FROM productos
);

-- Explicación:
-- WHERE stock >: compara stock con promedio
-- (SELECT AVG(stock) FROM productos): calcula stock promedio
-- ROUND((SELECT AVG(stock) FROM productos), 2): muestra el promedio para referencia
```

### Ejercicio 2: Subconsultas en SELECT
**Objetivo**: Practicar subconsultas en la cláusula SELECT para cálculos dinámicos.

**Instrucciones**:
1. Mostrar productos con información de categoría usando subconsultas
2. Crear reporte de usuarios con estadísticas completas
3. Mostrar productos con información de ventas
4. Crear vista de categorías con estadísticas

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con información de categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    p.stock,
    (SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id) AS categoria,
    (SELECT c.descripcion FROM categorias c WHERE c.id = p.categoria_id) AS descripcion_categoria
FROM productos p
ORDER BY p.precio DESC;

-- Explicación:
-- (SELECT c.nombre FROM categorias c WHERE c.id = p.categoria_id): subconsulta para nombre de categoría
-- (SELECT c.descripcion FROM categorias c WHERE c.id = p.categoria_id): subconsulta para descripción
-- WHERE c.id = p.categoria_id: condición de relación
-- ORDER BY p.precio DESC: ordena por precio descendente

-- Consulta 2: Usuarios con estadísticas completas
SELECT 
    u.nombre AS usuario,
    u.email,
    (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id) AS total_pedidos,
    (SELECT COALESCE(SUM(total), 0) FROM pedidos p WHERE p.usuario_id = u.id) AS total_gastado,
    (SELECT COALESCE(AVG(total), 0) FROM pedidos p WHERE p.usuario_id = u.id) AS promedio_por_pedido,
    (SELECT MAX(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id) AS ultima_compra,
    (SELECT MIN(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id) AS primera_compra
FROM usuarios u
ORDER BY (SELECT COALESCE(SUM(total), 0) FROM pedidos p WHERE p.usuario_id = u.id) DESC;

-- Explicación:
-- (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id): cuenta pedidos del usuario
-- (SELECT COALESCE(SUM(total), 0) FROM pedidos p WHERE p.usuario_id = u.id): suma total gastado
-- (SELECT COALESCE(AVG(total), 0) FROM pedidos p WHERE p.usuario_id = u.id): promedio por pedido
-- (SELECT MAX(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id): última compra
-- (SELECT MIN(fecha_pedido) FROM pedidos p WHERE p.usuario_id = u.id): primera compra
-- COALESCE: maneja valores NULL
-- ORDER BY: ordena por total gastado

-- Consulta 3: Productos con información de ventas
SELECT 
    p.nombre AS producto,
    p.precio,
    p.stock,
    (SELECT COALESCE(SUM(dp.cantidad), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS total_vendido,
    (SELECT COALESCE(COUNT(DISTINCT dp.pedido_id), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS pedidos_con_producto,
    (SELECT COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS ingresos_generados,
    (SELECT COALESCE(AVG(dp.precio_unitario), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS precio_promedio_vendido
FROM productos p
ORDER BY (SELECT COALESCE(SUM(dp.cantidad), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) DESC;

-- Explicación:
-- (SELECT COALESCE(SUM(dp.cantidad), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): cantidad total vendida
-- (SELECT COALESCE(COUNT(DISTINCT dp.pedido_id), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): pedidos únicos
-- (SELECT COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): ingresos generados
-- (SELECT COALESCE(AVG(dp.precio_unitario), 0) FROM detalle_pedidos dp WHERE dp.producto_id = p.id): precio promedio vendido
-- COALESCE: maneja valores NULL
-- ORDER BY: ordena por cantidad vendida

-- Consulta 4: Categorías con estadísticas
SELECT 
    c.nombre AS categoria,
    c.descripcion,
    (SELECT COUNT(*) FROM productos p WHERE p.categoria_id = c.id) AS total_productos,
    (SELECT COALESCE(AVG(p.precio), 0) FROM productos p WHERE p.categoria_id = c.id) AS precio_promedio,
    (SELECT COALESCE(SUM(p.stock), 0) FROM productos p WHERE p.categoria_id = c.id) AS stock_total,
    (SELECT COALESCE(SUM(dp.cantidad), 0) FROM productos p INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id WHERE p.categoria_id = c.id) AS total_vendido
FROM categorias c
ORDER BY (SELECT COUNT(*) FROM productos p WHERE p.categoria_id = c.id) DESC;

-- Explicación:
-- (SELECT COUNT(*) FROM productos p WHERE p.categoria_id = c.id): cuenta productos por categoría
-- (SELECT COALESCE(AVG(p.precio), 0) FROM productos p WHERE p.categoria_id = c.id): precio promedio
-- (SELECT COALESCE(SUM(p.stock), 0) FROM productos p WHERE p.categoria_id = c.id): stock total
-- (SELECT COALESCE(SUM(dp.cantidad), 0) FROM productos p INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id WHERE p.categoria_id = c.id): total vendido
-- COALESCE: maneja valores NULL
-- ORDER BY: ordena por cantidad de productos
```

### Ejercicio 3: Subconsultas en FROM
**Objetivo**: Practicar subconsultas en la cláusula FROM como tablas virtuales.

**Instrucciones**:
1. Crear ranking de productos más vendidos
2. Analizar usuarios por nivel de gasto
3. Crear reporte de categorías con estadísticas
4. Identificar productos con mejor rendimiento

**Solución paso a paso:**

```sql
-- Consulta 1: Ranking de productos más vendidos
SELECT 
    p.nombre AS producto,
    p.precio,
    ventas.total_vendido,
    ventas.ingresos_generados,
    ventas.pedidos_unicos,
    c.nombre AS categoria,
    RANK() OVER (ORDER BY ventas.total_vendido DESC) AS ranking_ventas
FROM productos p
INNER JOIN (
    SELECT 
        producto_id,
        SUM(cantidad) AS total_vendido,
        SUM(cantidad * precio_unitario) AS ingresos_generados,
        COUNT(DISTINCT pedido_id) AS pedidos_unicos
    FROM detalle_pedidos
    GROUP BY producto_id
) AS ventas ON p.id = ventas.producto_id
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY ventas.total_vendido DESC;

-- Explicación:
-- INNER JOIN (SELECT ...) AS ventas: subconsulta como tabla virtual
-- SELECT producto_id, SUM(cantidad) AS total_vendido, SUM(cantidad * precio_unitario) AS ingresos_generados, COUNT(DISTINCT pedido_id) AS pedidos_unicos: estadísticas por producto
-- FROM detalle_pedidos: tabla fuente
-- GROUP BY producto_id: agrupa por producto
-- RANK() OVER (ORDER BY ventas.total_vendido DESC): ranking por ventas
-- ON p.id = ventas.producto_id: condición de unión

-- Consulta 2: Usuarios por nivel de gasto
SELECT 
    u.nombre AS usuario,
    u.email,
    gastos.total_gastado,
    gastos.total_pedidos,
    gastos.promedio_por_pedido,
    gastos.ultima_compra,
    CASE 
        WHEN gastos.total_gastado >= 1000 THEN 'Alto'
        WHEN gastos.total_gastado >= 500 THEN 'Medio'
        WHEN gastos.total_gastado > 0 THEN 'Bajo'
        ELSE 'Sin compras'
    END AS nivel_gasto
FROM usuarios u
LEFT JOIN (
    SELECT 
        usuario_id,
        SUM(total) AS total_gastado,
        COUNT(*) AS total_pedidos,
        AVG(total) AS promedio_por_pedido,
        MAX(fecha_pedido) AS ultima_compra
    FROM pedidos
    GROUP BY usuario_id
) AS gastos ON u.id = gastos.usuario_id
ORDER BY gastos.total_gastado DESC;

-- Explicación:
-- LEFT JOIN (SELECT ...) AS gastos: subconsulta como tabla virtual
-- SELECT usuario_id, SUM(total) AS total_gastado, COUNT(*) AS total_pedidos, AVG(total) AS promedio_por_pedido, MAX(fecha_pedido) AS ultima_compra: estadísticas por usuario
-- FROM pedidos: tabla fuente
-- GROUP BY usuario_id: agrupa por usuario
-- CASE: categoriza por nivel de gasto
-- LEFT JOIN: incluye usuarios sin pedidos

-- Consulta 3: Categorías con estadísticas completas
SELECT 
    c.nombre AS categoria,
    c.descripcion,
    stats.total_productos,
    stats.precio_promedio,
    stats.stock_total,
    stats.total_vendido,
    stats.ingresos_totales,
    ROUND(stats.ingresos_totales / stats.total_productos, 2) AS ingresos_por_producto
FROM categorias c
INNER JOIN (
    SELECT 
        p.categoria_id,
        COUNT(p.id) AS total_productos,
        AVG(p.precio) AS precio_promedio,
        SUM(p.stock) AS stock_total,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_totales
    FROM productos p
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.categoria_id
) AS stats ON c.id = stats.categoria_id
ORDER BY stats.ingresos_totales DESC;

-- Explicación:
-- INNER JOIN (SELECT ...) AS stats: subconsulta como tabla virtual
-- SELECT p.categoria_id, COUNT(p.id) AS total_productos, AVG(p.precio) AS precio_promedio, SUM(p.stock) AS stock_total, COALESCE(SUM(dp.cantidad), 0) AS total_vendido, COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_totales: estadísticas por categoría
-- FROM productos p: tabla principal
-- LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id: une con ventas
-- GROUP BY p.categoria_id: agrupa por categoría
-- ROUND(stats.ingresos_totales / stats.total_productos, 2): calcula ingresos por producto
-- COALESCE: maneja valores NULL

-- Consulta 4: Productos con mejor rendimiento
SELECT 
    p.nombre AS producto,
    p.precio,
    p.stock,
    rendimiento.total_vendido,
    rendimiento.ingresos_generados,
    rendimiento.pedidos_unicos,
    rendimiento.rotacion_stock,
    c.nombre AS categoria,
    RANK() OVER (ORDER BY rendimiento.rotacion_stock DESC) AS ranking_rotacion
FROM productos p
INNER JOIN (
    SELECT 
        producto_id,
        SUM(cantidad) AS total_vendido,
        SUM(cantidad * precio_unitario) AS ingresos_generados,
        COUNT(DISTINCT pedido_id) AS pedidos_unicos,
        ROUND(SUM(cantidad) / (SELECT stock FROM productos WHERE id = producto_id), 2) AS rotacion_stock
    FROM detalle_pedidos
    GROUP BY producto_id
) AS rendimiento ON p.id = rendimiento.producto_id
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE rendimiento.rotacion_stock > 0
ORDER BY rendimiento.rotacion_stock DESC;

-- Explicación:
-- INNER JOIN (SELECT ...) AS rendimiento: subconsulta como tabla virtual
-- SELECT producto_id, SUM(cantidad) AS total_vendido, SUM(cantidad * precio_unitario) AS ingresos_generados, COUNT(DISTINCT pedido_id) AS pedidos_unicos, ROUND(SUM(cantidad) / (SELECT stock FROM productos WHERE id = producto_id), 2) AS rotacion_stock: estadísticas de rendimiento
-- ROUND(SUM(cantidad) / (SELECT stock FROM productos WHERE id = producto_id), 2): calcula rotación de stock
-- RANK() OVER (ORDER BY rendimiento.rotacion_stock DESC): ranking por rotación
-- WHERE rendimiento.rotacion_stock > 0: filtra productos con rotación
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de Subconsultas:
- **Subconsultas en WHERE**: Filtros dinámicos basados en otras consultas
- **Subconsultas en SELECT**: Cálculos dinámicos en columnas
- **Subconsultas en FROM**: Tablas virtuales para simplificar consultas

### Sintaxis Básica:
```sql
-- En WHERE
WHERE columna OPERADOR (SELECT columna FROM tabla WHERE condicion);

-- En SELECT
SELECT columna, (SELECT columna FROM tabla WHERE condicion) AS alias FROM tabla;

-- En FROM
SELECT columnas FROM (SELECT columnas FROM tabla WHERE condicion) AS alias;
```

### Cuándo Usar Subconsultas:
- **En WHERE**: Para filtros complejos que requieren cálculos
- **En SELECT**: Para incluir información relacionada sin JOINs
- **En FROM**: Para simplificar consultas complejas

### Ventajas vs JOINs:
- **Subconsultas**: Más legibles para lógica compleja
- **JOINs**: Mejor rendimiento para datos grandes
- **Híbrido**: Combinar ambas técnicas según necesidad

### Mejores Prácticas:
1. **Usa paréntesis** para delimitar subconsultas
2. **Nombra alias** para tablas virtuales
3. **Optimiza rendimiento** con índices apropiados
4. **Documenta consultas complejas** con comentarios
5. **Prueba subconsultas** por separado antes de anidar

### Funciones Útiles:
- **COALESCE()**: Maneja valores NULL
- **COUNT()**: Cuenta registros
- **SUM()**: Suma valores
- **AVG()**: Calcula promedios
- **MAX()/MIN()**: Valores extremos

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Subconsultas correlacionadas
- Operadores EXISTS, IN, ANY, ALL
- Subconsultas con múltiples valores
- Técnicas avanzadas de optimización

---

## 💡 Consejos para el Éxito

1. **Empieza simple**: Construye subconsultas paso a paso
2. **Prueba por separado**: Ejecuta subconsultas independientemente
3. **Usa alias descriptivos**: Hace el código más legible
4. **Considera el rendimiento**: Subconsultas pueden ser lentas
5. **Documenta la lógica**: Explica el propósito de cada subconsulta

---

## 🧭 Navegación

**← Anterior**: [Clase 2: JOINs Avanzados](clase_2_joins_avanzados.md)  
**Siguiente →**: [Clase 4: Subconsultas Avanzadas](clase_4_subconsultas_avanzadas.md)

---

*¡Excelente trabajo! Ahora dominas las subconsultas básicas en SQL. 🚀*
