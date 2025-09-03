# Clase 4: Subconsultas Avanzadas - Lógica Compleja

## 📚 Descripción de la Clase
En esta clase profundizarás en las subconsultas avanzadas de SQL, aprendiendo técnicas más sofisticadas como subconsultas correlacionadas, operadores EXISTS, IN, ANY, ALL, y subconsultas con múltiples valores. Dominarás estas herramientas para resolver problemas complejos de análisis de datos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Usar subconsultas correlacionadas para análisis complejos
- Aplicar el operador EXISTS para verificar existencia
- Implementar operadores IN, ANY, ALL para comparaciones múltiples
- Crear subconsultas con múltiples valores y columnas
- Optimizar subconsultas avanzadas para mejor rendimiento
- Resolver problemas complejos usando combinaciones de técnicas

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### Subconsultas Correlacionadas

Las **subconsultas correlacionadas** son subconsultas que hacen referencia a columnas de la consulta externa. Se ejecutan una vez por cada fila de la consulta externa.

#### Características de Subconsultas Correlacionadas:
- **Referencia externa**: Acceden a columnas de la consulta principal
- **Ejecución múltiple**: Se ejecutan para cada fila externa
- **Dependencia**: Su resultado depende del contexto externo
- **Rendimiento**: Pueden ser más lentas que subconsultas independientes

#### Sintaxis de Subconsultas Correlacionadas
```sql
SELECT columnas
FROM tabla1 t1
WHERE condicion (
    SELECT columna
    FROM tabla2 t2
    WHERE t2.columna = t1.columna
);
```

**Explicación línea por línea:**
- `FROM tabla1 t1`: tabla principal con alias
- `WHERE condicion`: condición que usa la subconsulta
- `(SELECT columna FROM tabla2 t2 WHERE t2.columna = t1.columna)`: subconsulta correlacionada
- `WHERE t2.columna = t1.columna`: correlación entre tablas

### Operador EXISTS

EXISTS verifica si una subconsulta devuelve al menos una fila. Es muy útil para verificar existencia de registros relacionados.

#### Sintaxis de EXISTS
```sql
SELECT columnas
FROM tabla1
WHERE EXISTS (
    SELECT 1
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `WHERE EXISTS`: verifica existencia de resultados
- `(SELECT 1 FROM tabla2 WHERE condicion)`: subconsulta de existencia
- `SELECT 1`: no importa qué se seleccione, solo la existencia
- Devuelve TRUE si hay al menos una fila, FALSE si no hay ninguna

#### Ventajas de EXISTS:
- **Rendimiento**: Se detiene en la primera coincidencia
- **Legibilidad**: Código más claro que COUNT() > 0
- **Eficiencia**: No necesita procesar todas las filas

### Operadores IN, ANY, ALL

Estos operadores permiten comparar un valor con múltiples valores de una subconsulta.

#### Operador IN
```sql
SELECT columnas
FROM tabla1
WHERE columna IN (
    SELECT columna
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `WHERE columna IN`: compara con lista de valores
- `(SELECT columna FROM tabla2 WHERE condicion)`: subconsulta que devuelve múltiples valores
- Devuelve TRUE si el valor está en la lista

#### Operador ANY
```sql
SELECT columnas
FROM tabla1
WHERE columna OPERADOR ANY (
    SELECT columna
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `WHERE columna OPERADOR ANY`: compara con cualquier valor de la lista
- `OPERADOR`: puede ser =, >, <, >=, <=, !=
- Devuelve TRUE si la condición se cumple para al menos un valor

#### Operador ALL
```sql
SELECT columnas
FROM tabla1
WHERE columna OPERADOR ALL (
    SELECT columna
    FROM tabla2
    WHERE condicion
);
```

**Explicación línea por línea:**
- `WHERE columna OPERADOR ALL`: compara con todos los valores de la lista
- `OPERADOR`: puede ser =, >, <, >=, <=, !=
- Devuelve TRUE si la condición se cumple para todos los valores

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Subconsultas Correlacionadas

```sql
-- Consulta 1: Productos con precio superior al promedio de su categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id) AS precio_promedio_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);

-- Explicación línea por línea:
-- WHERE p.precio >: compara precio del producto
-- (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id): subconsulta correlacionada
-- p2.categoria_id = p.categoria_id: correlación por categoría
-- AVG(precio): calcula promedio por categoría
-- Resultado: productos más caros que el promedio de su categoría

-- Consulta 2: Usuarios que han gastado más que el promedio de su grupo de edad
SELECT 
    u.nombre AS usuario,
    u.email,
    SUM(p.total) AS total_gastado,
    (SELECT AVG(total_gastado) FROM (
        SELECT SUM(total) AS total_gastado
        FROM pedidos p2
        INNER JOIN usuarios u2 ON p2.usuario_id = u2.id
        WHERE YEAR(CURDATE()) - YEAR(u2.fecha_nacimiento) BETWEEN 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) - 5 AND 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) + 5
        GROUP BY u2.id
    ) AS gastos_por_edad) AS promedio_grupo_edad
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email, u.fecha_nacimiento
HAVING SUM(p.total) > (
    SELECT AVG(total_gastado)
    FROM (
        SELECT SUM(total) AS total_gastado
        FROM pedidos p2
        INNER JOIN usuarios u2 ON p2.usuario_id = u2.id
        WHERE YEAR(CURDATE()) - YEAR(u2.fecha_nacimiento) BETWEEN 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) - 5 AND 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) + 5
        GROUP BY u2.id
    ) AS gastos_por_edad
);

-- Explicación línea por línea:
-- HAVING SUM(p.total) >: filtra después de agregación
-- Subconsulta correlacionada anidada: compara con promedio del grupo de edad
-- YEAR(CURDATE()) - YEAR(u.fecha_nacimiento): calcula edad
-- BETWEEN ... AND ...: define rango de edad (±5 años)
-- Resultado: usuarios que gastan más que su grupo de edad

-- Consulta 3: Productos con mejor rendimiento que el promedio de su categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    (SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) AS total_vendido,
    (SELECT AVG(total_vendido) FROM (
        SELECT SUM(dp2.cantidad) AS total_vendido
        FROM detalle_pedidos dp2
        INNER JOIN productos p2 ON dp2.producto_id = p2.id
        WHERE p2.categoria_id = p.categoria_id
        GROUP BY p2.id
    ) AS ventas_por_categoria) AS promedio_ventas_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE (SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) > (
    SELECT AVG(total_vendido)
    FROM (
        SELECT SUM(dp2.cantidad) AS total_vendido
        FROM detalle_pedidos dp2
        INNER JOIN productos p2 ON dp2.producto_id = p2.id
        WHERE p2.categoria_id = p.categoria_id
        GROUP BY p2.id
    ) AS ventas_por_categoria
);

-- Explicación línea por línea:
-- WHERE (SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id) >: compara ventas del producto
-- Subconsulta correlacionada: calcula promedio de ventas por categoría
-- p2.categoria_id = p.categoria_id: correlación por categoría
-- Resultado: productos con ventas superiores al promedio de su categoría
```

### Ejemplo 2: Operador EXISTS

```sql
-- Consulta 1: Usuarios que han hecho pedidos
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro
FROM usuarios u
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.usuario_id = u.id
);

-- Explicación línea por línea:
-- WHERE EXISTS: verifica existencia de pedidos
-- (SELECT 1 FROM pedidos p WHERE p.usuario_id = u.id): subconsulta de existencia
-- SELECT 1: no importa qué se seleccione, solo la existencia
-- WHERE p.usuario_id = u.id: condición de correlación
-- Resultado: usuarios que tienen al menos un pedido

-- Consulta 2: Productos que nunca se han vendido
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_pedidos dp
    WHERE dp.producto_id = p.id
);

-- Explicación línea por línea:
-- WHERE NOT EXISTS: verifica que NO existan ventas
-- (SELECT 1 FROM detalle_pedidos dp WHERE dp.producto_id = p.id): subconsulta de existencia
-- NOT EXISTS: niega la existencia
-- Resultado: productos que nunca se han vendido

-- Consulta 3: Categorías que tienen productos vendidos
SELECT 
    c.nombre AS categoria,
    c.descripcion
FROM categorias c
WHERE EXISTS (
    SELECT 1
    FROM productos p
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
    WHERE p.categoria_id = c.id
);

-- Explicación línea por línea:
-- WHERE EXISTS: verifica existencia de productos vendidos
-- Subconsulta: busca productos de la categoría que tengan ventas
-- INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id: une con ventas
-- WHERE p.categoria_id = c.id: correlación por categoría
-- Resultado: categorías que tienen al menos un producto vendido
```

### Ejemplo 3: Operadores IN, ANY, ALL

```sql
-- Consulta 1: Productos de categorías populares (más de 3 productos)
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
    HAVING COUNT(*) > 3
);

-- Explicación línea por línea:
-- WHERE p.categoria_id IN: compara con lista de categorías
-- (SELECT categoria_id FROM productos GROUP BY categoria_id HAVING COUNT(*) > 3): subconsulta
-- GROUP BY categoria_id: agrupa por categoría
-- HAVING COUNT(*) > 3: filtra categorías con más de 3 productos
-- Resultado: productos de categorías populares

-- Consulta 2: Productos con precio superior a cualquier producto de ropa
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > ANY (
    SELECT precio
    FROM productos p2
    INNER JOIN categorias c2 ON p2.categoria_id = c2.id
    WHERE c2.nombre = 'Ropa'
);

-- Explicación línea por línea:
-- WHERE p.precio > ANY: compara con cualquier precio de ropa
-- (SELECT precio FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Ropa'): subconsulta
-- WHERE c2.nombre = 'Ropa': filtra solo productos de ropa
-- > ANY: mayor que cualquier precio de ropa
-- Resultado: productos más caros que el producto de ropa más barato

-- Consulta 3: Productos con precio superior a todos los productos de electrónicos
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > ALL (
    SELECT precio
    FROM productos p2
    INNER JOIN categorias c2 ON p2.categoria_id = c2.id
    WHERE c2.nombre = 'Electrónicos'
);

-- Explicación línea por línea:
-- WHERE p.precio > ALL: compara con todos los precios de electrónicos
-- (SELECT precio FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Electrónicos'): subconsulta
-- WHERE c2.nombre = 'Electrónicos': filtra solo productos de electrónicos
-- > ALL: mayor que todos los precios de electrónicos
-- Resultado: productos más caros que el producto de electrónicos más caro

-- Consulta 4: Usuarios que han comprado productos de todas las categorías
SELECT 
    u.nombre AS usuario,
    u.email
FROM usuarios u
WHERE NOT EXISTS (
    SELECT 1
    FROM categorias c
    WHERE NOT EXISTS (
        SELECT 1
        FROM pedidos p
        INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
        INNER JOIN productos pr ON dp.producto_id = pr.id
        WHERE p.usuario_id = u.id
        AND pr.categoria_id = c.id
    )
);

-- Explicación línea por línea:
-- WHERE NOT EXISTS: verifica que NO exista categoría sin compra
-- Subconsulta externa: busca categorías
-- WHERE NOT EXISTS: verifica que NO exista compra de esa categoría
-- Subconsulta interna: busca compras del usuario en esa categoría
-- Resultado: usuarios que han comprado de todas las categorías
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Subconsultas Correlacionadas
**Objetivo**: Practicar subconsultas correlacionadas para análisis complejos.

**Instrucciones**:
1. Encontrar productos con precio superior al promedio de su categoría
2. Mostrar usuarios que gastan más que el promedio de su grupo de edad
3. Identificar productos con mejor rendimiento que el promedio de su categoría
4. Crear ranking de productos dentro de cada categoría

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con precio superior al promedio de su categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROUND((SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id), 2) AS precio_promedio_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
)
ORDER BY c.nombre, p.precio DESC;

-- Explicación:
-- WHERE p.precio >: compara precio del producto
-- (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id): subconsulta correlacionada
-- p2.categoria_id = p.categoria_id: correlación por categoría
-- ROUND: redondea el promedio para mostrar
-- ORDER BY: ordena por categoría y precio

-- Consulta 2: Usuarios que gastan más que el promedio de su grupo de edad
SELECT 
    u.nombre AS usuario,
    u.email,
    YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) AS edad,
    SUM(p.total) AS total_gastado,
    ROUND((SELECT AVG(total_gastado) FROM (
        SELECT SUM(total) AS total_gastado
        FROM pedidos p2
        INNER JOIN usuarios u2 ON p2.usuario_id = u2.id
        WHERE YEAR(CURDATE()) - YEAR(u2.fecha_nacimiento) BETWEEN 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) - 5 AND 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) + 5
        GROUP BY u2.id
    ) AS gastos_por_edad), 2) AS promedio_grupo_edad
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email, u.fecha_nacimiento
HAVING SUM(p.total) > (
    SELECT AVG(total_gastado)
    FROM (
        SELECT SUM(total) AS total_gastado
        FROM pedidos p2
        INNER JOIN usuarios u2 ON p2.usuario_id = u2.id
        WHERE YEAR(CURDATE()) - YEAR(u2.fecha_nacimiento) BETWEEN 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) - 5 AND 
              YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) + 5
        GROUP BY u2.id
    ) AS gastos_por_edad
)
ORDER BY total_gastado DESC;

-- Explicación:
-- YEAR(CURDATE()) - YEAR(u.fecha_nacimiento) AS edad: calcula edad
-- HAVING SUM(p.total) >: filtra después de agregación
-- Subconsulta correlacionada: compara con promedio del grupo de edad
-- BETWEEN ... AND ...: define rango de edad (±5 años)
-- Resultado: usuarios que gastan más que su grupo de edad

-- Consulta 3: Productos con mejor rendimiento que el promedio de su categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    COALESCE((SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id), 0) AS total_vendido,
    ROUND((SELECT AVG(total_vendido) FROM (
        SELECT COALESCE(SUM(dp2.cantidad), 0) AS total_vendido
        FROM detalle_pedidos dp2
        INNER JOIN productos p2 ON dp2.producto_id = p2.id
        WHERE p2.categoria_id = p.categoria_id
        GROUP BY p2.id
    ) AS ventas_por_categoria), 2) AS promedio_ventas_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE COALESCE((SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id), 0) > (
    SELECT AVG(total_vendido)
    FROM (
        SELECT COALESCE(SUM(dp2.cantidad), 0) AS total_vendido
        FROM detalle_pedidos dp2
        INNER JOIN productos p2 ON dp2.producto_id = p2.id
        WHERE p2.categoria_id = p.categoria_id
        GROUP BY p2.id
    ) AS ventas_por_categoria
)
ORDER BY c.nombre, total_vendido DESC;

-- Explicación:
-- COALESCE: maneja productos sin ventas
-- WHERE COALESCE(...) >: compara ventas del producto
-- Subconsulta correlacionada: calcula promedio de ventas por categoría
-- p2.categoria_id = p.categoria_id: correlación por categoría
-- Resultado: productos con ventas superiores al promedio de su categoría

-- Consulta 4: Ranking de productos dentro de cada categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    COALESCE((SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id), 0) AS total_vendido,
    RANK() OVER (PARTITION BY c.id ORDER BY COALESCE((SELECT SUM(dp.cantidad) FROM detalle_pedidos dp WHERE dp.producto_id = p.id), 0) DESC) AS ranking_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, ranking_categoria;

-- Explicación:
-- RANK() OVER (PARTITION BY c.id ORDER BY ...): ranking por categoría
-- PARTITION BY c.id: separa ranking por categoría
-- ORDER BY COALESCE(...) DESC: ordena por ventas descendente
-- COALESCE: maneja productos sin ventas
-- Resultado: ranking de productos dentro de cada categoría
```

### Ejercicio 2: Operador EXISTS
**Objetivo**: Practicar el operador EXISTS para verificar existencia.

**Instrucciones**:
1. Mostrar usuarios que han hecho pedidos
2. Identificar productos que nunca se han vendido
3. Encontrar categorías que tienen productos vendidos
4. Mostrar usuarios que han comprado productos de electrónicos

**Solución paso a paso:**

```sql
-- Consulta 1: Usuarios que han hecho pedidos
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id) AS total_pedidos
FROM usuarios u
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.usuario_id = u.id
)
ORDER BY total_pedidos DESC;

-- Explicación:
-- WHERE EXISTS: verifica existencia de pedidos
-- (SELECT 1 FROM pedidos p WHERE p.usuario_id = u.id): subconsulta de existencia
-- SELECT 1: no importa qué se seleccione, solo la existencia
-- WHERE p.usuario_id = u.id: condición de correlación
-- (SELECT COUNT(*) FROM pedidos p WHERE p.usuario_id = u.id): cuenta pedidos para mostrar

-- Consulta 2: Productos que nunca se han vendido
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    p.stock
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_pedidos dp
    WHERE dp.producto_id = p.id
)
ORDER BY p.precio DESC;

-- Explicación:
-- WHERE NOT EXISTS: verifica que NO existan ventas
-- (SELECT 1 FROM detalle_pedidos dp WHERE dp.producto_id = p.id): subconsulta de existencia
-- NOT EXISTS: niega la existencia
-- Resultado: productos que nunca se han vendido

-- Consulta 3: Categorías que tienen productos vendidos
SELECT 
    c.nombre AS categoria,
    c.descripcion,
    (SELECT COUNT(DISTINCT p.id) FROM productos p INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id WHERE p.categoria_id = c.id) AS productos_vendidos
FROM categorias c
WHERE EXISTS (
    SELECT 1
    FROM productos p
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
    WHERE p.categoria_id = c.id
)
ORDER BY productos_vendidos DESC;

-- Explicación:
-- WHERE EXISTS: verifica existencia de productos vendidos
-- Subconsulta: busca productos de la categoría que tengan ventas
-- INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id: une con ventas
-- WHERE p.categoria_id = c.id: correlación por categoría
-- (SELECT COUNT(DISTINCT p.id) ...): cuenta productos vendidos para mostrar

-- Consulta 4: Usuarios que han comprado productos de electrónicos
SELECT 
    u.nombre AS usuario,
    u.email,
    (SELECT COUNT(DISTINCT p.id) FROM pedidos p INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id INNER JOIN productos pr ON dp.producto_id = pr.id INNER JOIN categorias c ON pr.categoria_id = c.id WHERE p.usuario_id = u.id AND c.nombre = 'Electrónicos') AS productos_electronicos_comprados
FROM usuarios u
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
    INNER JOIN productos pr ON dp.producto_id = pr.id
    INNER JOIN categorias c ON pr.categoria_id = c.id
    WHERE p.usuario_id = u.id
    AND c.nombre = 'Electrónicos'
)
ORDER BY productos_electronicos_comprados DESC;

-- Explicación:
-- WHERE EXISTS: verifica existencia de compras de electrónicos
-- Subconsulta: busca pedidos del usuario con productos de electrónicos
-- Múltiples INNER JOINs: une pedidos, detalles, productos y categorías
-- WHERE p.usuario_id = u.id AND c.nombre = 'Electrónicos': condiciones de correlación
-- (SELECT COUNT(DISTINCT p.id) ...): cuenta productos de electrónicos comprados
```

### Ejercicio 3: Operadores IN, ANY, ALL
**Objetivo**: Practicar operadores IN, ANY, ALL para comparaciones múltiples.

**Instrucciones**:
1. Mostrar productos de categorías populares
2. Encontrar productos más caros que cualquier producto de ropa
3. Identificar productos más caros que todos los productos de electrónicos
4. Mostrar usuarios que han comprado productos de todas las categorías

**Solución paso a paso:**

```sql
-- Consulta 1: Productos de categorías populares (más de 2 productos)
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    (SELECT COUNT(*) FROM productos p2 WHERE p2.categoria_id = p.categoria_id) AS productos_en_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.categoria_id IN (
    SELECT categoria_id
    FROM productos
    GROUP BY categoria_id
    HAVING COUNT(*) > 2
)
ORDER BY c.nombre, p.precio DESC;

-- Explicación:
-- WHERE p.categoria_id IN: compara con lista de categorías
-- (SELECT categoria_id FROM productos GROUP BY categoria_id HAVING COUNT(*) > 2): subconsulta
-- GROUP BY categoria_id: agrupa por categoría
-- HAVING COUNT(*) > 2: filtra categorías con más de 2 productos
-- (SELECT COUNT(*) FROM productos p2 WHERE p2.categoria_id = p.categoria_id): cuenta productos para mostrar

-- Consulta 2: Productos con precio superior a cualquier producto de ropa
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    (SELECT MIN(precio) FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Ropa') AS precio_minimo_ropa
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > ANY (
    SELECT precio
    FROM productos p2
    INNER JOIN categorias c2 ON p2.categoria_id = c2.id
    WHERE c2.nombre = 'Ropa'
)
ORDER BY p.precio DESC;

-- Explicación:
-- WHERE p.precio > ANY: compara con cualquier precio de ropa
-- (SELECT precio FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Ropa'): subconsulta
-- WHERE c2.nombre = 'Ropa': filtra solo productos de ropa
-- > ANY: mayor que cualquier precio de ropa
-- (SELECT MIN(precio) ...): muestra el precio mínimo de ropa para referencia

-- Consulta 3: Productos con precio superior a todos los productos de electrónicos
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    (SELECT MAX(precio) FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Electrónicos') AS precio_maximo_electronicos
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > ALL (
    SELECT precio
    FROM productos p2
    INNER JOIN categorias c2 ON p2.categoria_id = c2.id
    WHERE c2.nombre = 'Electrónicos'
)
ORDER BY p.precio DESC;

-- Explicación:
-- WHERE p.precio > ALL: compara con todos los precios de electrónicos
-- (SELECT precio FROM productos p2 INNER JOIN categorias c2 ON p2.categoria_id = c2.id WHERE c2.nombre = 'Electrónicos'): subconsulta
-- WHERE c2.nombre = 'Electrónicos': filtra solo productos de electrónicos
-- > ALL: mayor que todos los precios de electrónicos
-- (SELECT MAX(precio) ...): muestra el precio máximo de electrónicos para referencia

-- Consulta 4: Usuarios que han comprado productos de todas las categorías
SELECT 
    u.nombre AS usuario,
    u.email,
    (SELECT COUNT(DISTINCT c.id) FROM pedidos p INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id INNER JOIN productos pr ON dp.producto_id = pr.id INNER JOIN categorias c ON pr.categoria_id = c.id WHERE p.usuario_id = u.id) AS categorias_compradas,
    (SELECT COUNT(*) FROM categorias) AS total_categorias
FROM usuarios u
WHERE NOT EXISTS (
    SELECT 1
    FROM categorias c
    WHERE NOT EXISTS (
        SELECT 1
        FROM pedidos p
        INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
        INNER JOIN productos pr ON dp.producto_id = pr.id
        WHERE p.usuario_id = u.id
        AND pr.categoria_id = c.id
    )
)
ORDER BY categorias_compradas DESC;

-- Explicación:
-- WHERE NOT EXISTS: verifica que NO exista categoría sin compra
-- Subconsulta externa: busca categorías
-- WHERE NOT EXISTS: verifica que NO exista compra de esa categoría
-- Subconsulta interna: busca compras del usuario en esa categoría
-- (SELECT COUNT(DISTINCT c.id) ...): cuenta categorías compradas para mostrar
-- (SELECT COUNT(*) FROM categorias): cuenta total de categorías para referencia
-- Resultado: usuarios que han comprado de todas las categorías
```

---

## 📝 Resumen de Conceptos Clave

### Subconsultas Correlacionadas:
- **Referencia externa**: Acceden a columnas de la consulta principal
- **Ejecución múltiple**: Se ejecutan para cada fila externa
- **Dependencia**: Su resultado depende del contexto externo
- **Rendimiento**: Pueden ser más lentas que subconsultas independientes

### Operador EXISTS:
- **Verificación de existencia**: Comprueba si hay al menos una fila
- **Rendimiento**: Se detiene en la primera coincidencia
- **Legibilidad**: Código más claro que COUNT() > 0
- **Eficiencia**: No necesita procesar todas las filas

### Operadores IN, ANY, ALL:
- **IN**: Compara con lista de valores (igual a alguno)
- **ANY**: Compara con cualquier valor de la lista
- **ALL**: Compara con todos los valores de la lista
- **Flexibilidad**: Permiten comparaciones complejas

### Cuándo Usar Cada Técnica:
- **Subconsultas correlacionadas**: Para análisis por grupos
- **EXISTS**: Para verificar existencia de relaciones
- **IN**: Para filtrar por lista de valores
- **ANY/ALL**: Para comparaciones con múltiples valores

### Mejores Prácticas:
1. **Optimiza subconsultas correlacionadas** con índices apropiados
2. **Usa EXISTS** en lugar de COUNT() > 0 para mejor rendimiento
3. **Considera el rendimiento** de subconsultas complejas
4. **Documenta la lógica** de subconsultas anidadas
5. **Prueba con datos pequeños** antes de ejecutar en producción

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Funciones de ventana (ROW_NUMBER, RANK, DENSE_RANK)
- Funciones LAG y LEAD para análisis temporal
- Particionamiento y ordenamiento en ventanas
- Técnicas avanzadas de análisis de datos

---

## 💡 Consejos para el Éxito

1. **Entiende la correlación**: Las subconsultas correlacionadas dependen del contexto externo
2. **Usa EXISTS eficientemente**: Es más rápido que COUNT() > 0
3. **Prueba operadores**: IN, ANY, ALL tienen comportamientos diferentes
4. **Optimiza el rendimiento**: Las subconsultas complejas pueden ser lentas
5. **Documenta la lógica**: Las subconsultas anidadas pueden ser confusas

---

## 🧭 Navegación

**← Anterior**: [Clase 3: Subconsultas Básicas](clase_3_subconsultas_basicas.md)  
**Siguiente →**: [Clase 5: Funciones de Ventana](clase_5_funciones_ventana.md)

---

*¡Excelente trabajo! Ahora dominas las subconsultas avanzadas en SQL. 🚀*
