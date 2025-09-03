# Clase 5: Funciones de Ventana - Análisis Avanzado

## 📚 Descripción de la Clase
En esta clase aprenderás las funciones de ventana (window functions) en SQL, una herramienta poderosa para realizar análisis avanzados de datos. Dominarás ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, y técnicas de particionamiento que te permitirán crear consultas sofisticadas para análisis de tendencias, rankings y comparaciones.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las funciones de ventana y por qué son útiles
- Usar ROW_NUMBER, RANK y DENSE_RANK para crear rankings
- Implementar LAG y LEAD para análisis temporal
- Aplicar particionamiento y ordenamiento en ventanas
- Crear consultas complejas con múltiples funciones de ventana
- Optimizar consultas con funciones de ventana

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Funciones de Ventana?

Las **funciones de ventana** (window functions) son funciones que realizan cálculos sobre un conjunto de filas relacionadas sin agrupar los resultados. Permiten realizar análisis avanzados manteniendo el detalle de cada fila.

#### Características de las Funciones de Ventana:
- **Preservan filas**: No agrupan los resultados como GROUP BY
- **Contexto de ventana**: Operan sobre un conjunto de filas relacionadas
- **Particionamiento**: Dividen los datos en grupos lógicos
- **Ordenamiento**: Definen el orden dentro de cada partición
- **Marco de ventana**: Especifican el rango de filas a considerar

#### Ventajas de las Funciones de Ventana:
- **Análisis detallado**: Mantienen el detalle de cada fila
- **Flexibilidad**: Permiten múltiples perspectivas de los datos
- **Eficiencia**: Evitan subconsultas complejas
- **Legibilidad**: Código más claro y comprensible

### Sintaxis General de Funciones de Ventana

```sql
SELECT 
    columna1,
    columna2,
    FUNCION_VENTANA() OVER (
        PARTITION BY columna
        ORDER BY columna
        ROWS/RANGE BETWEEN inicio AND fin
    ) AS alias
FROM tabla;
```

**Explicación línea por línea:**
- `FUNCION_VENTANA() OVER`: función de ventana con cláusula OVER
- `PARTITION BY columna`: divide los datos en grupos
- `ORDER BY columna`: ordena las filas dentro de cada partición
- `ROWS/RANGE BETWEEN inicio AND fin`: define el marco de ventana
- `AS alias`: nombre para la columna calculada

### 1. Funciones de Ranking

#### ROW_NUMBER()
Asigna un número secuencial a cada fila dentro de la partición.

```sql
SELECT 
    columna1,
    columna2,
    ROW_NUMBER() OVER (ORDER BY columna) AS numero_fila
FROM tabla;
```

**Explicación línea por línea:**
- `ROW_NUMBER() OVER`: función de numeración de filas
- `ORDER BY columna`: ordena las filas
- `AS numero_fila`: alias para la columna de numeración
- Asigna números únicos: 1, 2, 3, 4, 5...

#### RANK()
Asigna un rango a cada fila, con empates que reciben el mismo rango.

```sql
SELECT 
    columna1,
    columna2,
    RANK() OVER (ORDER BY columna) AS ranking
FROM tabla;
```

**Explicación línea por línea:**
- `RANK() OVER`: función de ranking
- `ORDER BY columna`: ordena las filas
- `AS ranking`: alias para la columna de ranking
- Maneja empates: 1, 2, 2, 4, 5... (salta el 3)

#### DENSE_RANK()
Asigna un rango a cada fila, con empates que reciben el mismo rango sin saltos.

```sql
SELECT 
    columna1,
    columna2,
    DENSE_RANK() OVER (ORDER BY columna) AS ranking_denso
FROM tabla;
```

**Explicación línea por línea:**
- `DENSE_RANK() OVER`: función de ranking denso
- `ORDER BY columna`: ordena las filas
- `AS ranking_denso`: alias para la columna de ranking
- Maneja empates sin saltos: 1, 2, 2, 3, 4...

### 2. Funciones de Desplazamiento

#### LAG()
Obtiene el valor de una fila anterior dentro de la partición.

```sql
SELECT 
    columna1,
    columna2,
    LAG(columna, 1) OVER (ORDER BY columna) AS valor_anterior
FROM tabla;
```

**Explicación línea por línea:**
- `LAG(columna, 1) OVER`: función de desplazamiento hacia atrás
- `columna`: columna de la que obtener el valor
- `1`: número de filas hacia atrás
- `ORDER BY columna`: ordena las filas
- `AS valor_anterior`: alias para la columna de valor anterior

#### LEAD()
Obtiene el valor de una fila posterior dentro de la partición.

```sql
SELECT 
    columna1,
    columna2,
    LEAD(columna, 1) OVER (ORDER BY columna) AS valor_siguiente
FROM tabla;
```

**Explicación línea por línea:**
- `LEAD(columna, 1) OVER`: función de desplazamiento hacia adelante
- `columna`: columna de la que obtener el valor
- `1`: número de filas hacia adelante
- `ORDER BY columna`: ordena las filas
- `AS valor_siguiente`: alias para la columna de valor siguiente

### 3. Particionamiento y Ordenamiento

#### PARTITION BY
Divide los datos en grupos lógicos para aplicar funciones de ventana.

```sql
SELECT 
    columna1,
    columna2,
    ROW_NUMBER() OVER (PARTITION BY columna ORDER BY columna) AS numero_fila
FROM tabla;
```

**Explicación línea por línea:**
- `PARTITION BY columna`: divide los datos en grupos
- `ORDER BY columna`: ordena las filas dentro de cada partición
- `ROW_NUMBER() OVER`: aplica la función a cada partición
- Resultado: numeración independiente por grupo

#### Marcos de Ventana
Definen el rango de filas a considerar para el cálculo.

```sql
SELECT 
    columna1,
    columna2,
    SUM(columna) OVER (
        PARTITION BY columna
        ORDER BY columna
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS suma_deslizante
FROM tabla;
```

**Explicación línea por línea:**
- `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`: marco de ventana
- `2 PRECEDING`: incluye 2 filas anteriores
- `CURRENT ROW`: incluye la fila actual
- `SUM(columna) OVER`: suma sobre el marco de ventana
- Resultado: suma deslizante de 3 filas

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Funciones de Ranking

```sql
-- Consulta 1: Ranking de productos por precio
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (ORDER BY p.precio DESC) AS numero_fila,
    RANK() OVER (ORDER BY p.precio DESC) AS ranking,
    DENSE_RANK() OVER (ORDER BY p.precio DESC) AS ranking_denso
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.precio DESC;

-- Explicación línea por línea:
-- ROW_NUMBER() OVER (ORDER BY p.precio DESC): numeración secuencial por precio
-- RANK() OVER (ORDER BY p.precio DESC): ranking con empates
-- DENSE_RANK() OVER (ORDER BY p.precio DESC): ranking denso sin saltos
-- ORDER BY p.precio DESC: ordena por precio descendente
-- Resultado: diferentes tipos de ranking para comparar

-- Consulta 2: Ranking de productos por categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS numero_fila_categoria,
    RANK() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_categoria,
    DENSE_RANK() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_denso_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio DESC;

-- Explicación línea por línea:
-- PARTITION BY c.id: divide por categoría
-- ORDER BY p.precio DESC: ordena por precio dentro de cada categoría
-- ROW_NUMBER() OVER: numeración independiente por categoría
-- RANK() OVER: ranking independiente por categoría
-- DENSE_RANK() OVER: ranking denso independiente por categoría
-- Resultado: ranking de productos dentro de cada categoría

-- Consulta 3: Top 3 productos por categoría
SELECT 
    producto,
    precio,
    categoria,
    ranking_categoria
FROM (
    SELECT 
        p.nombre AS producto,
        p.precio,
        c.nombre AS categoria,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_categoria
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
) AS ranked_products
WHERE ranking_categoria <= 3
ORDER BY categoria, ranking_categoria;

-- Explicación línea por línea:
-- Subconsulta: crea ranking de productos por categoría
-- ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC): numeración por categoría
-- WHERE ranking_categoria <= 3: filtra solo los top 3
-- ORDER BY categoria, ranking_categoria: ordena por categoría y ranking
-- Resultado: top 3 productos más caros por categoría
```

### Ejemplo 2: Funciones de Desplazamiento

```sql
-- Consulta 1: Análisis de tendencias de precios por categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    LAG(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS precio_anterior,
    LEAD(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS precio_siguiente,
    p.precio - LAG(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS diferencia_precio_anterior,
    LEAD(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) - p.precio AS diferencia_precio_siguiente
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio;

-- Explicación línea por línea:
-- LAG(p.precio, 1) OVER: precio de la fila anterior
-- LEAD(p.precio, 1) OVER: precio de la fila siguiente
-- PARTITION BY c.id: divide por categoría
-- ORDER BY p.precio: ordena por precio dentro de cada categoría
-- p.precio - LAG(...): diferencia con precio anterior
-- LEAD(...) - p.precio: diferencia con precio siguiente
-- Resultado: análisis de tendencias de precios

-- Consulta 2: Análisis de ventas mensuales
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(p.total) AS ventas_mes,
    LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS ventas_mes_anterior,
    SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS diferencia_ventas,
    ROUND(((SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) / LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) * 100, 2) AS porcentaje_cambio
FROM pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- Explicación línea por línea:
-- GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): agrupa por mes
-- SUM(p.total): ventas del mes
-- LAG(SUM(p.total), 1) OVER: ventas del mes anterior
-- ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): ordena por tiempo
-- diferencia_ventas: diferencia absoluta
-- porcentaje_cambio: diferencia porcentual
-- Resultado: análisis de tendencias de ventas mensuales

-- Consulta 3: Análisis de usuarios por fecha de registro
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro) AS fecha_registro_anterior,
    DATEDIFF(u.fecha_registro, LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro)) AS dias_diferencia,
    ROW_NUMBER() OVER (ORDER BY u.fecha_registro) AS numero_registro
FROM usuarios u
ORDER BY u.fecha_registro;

-- Explicación línea por línea:
-- LAG(u.fecha_registro, 1) OVER: fecha de registro anterior
-- ORDER BY u.fecha_registro: ordena por fecha de registro
-- DATEDIFF(...): diferencia en días
-- ROW_NUMBER() OVER: numeración por orden de registro
-- Resultado: análisis de patrones de registro de usuarios
```

### Ejemplo 3: Marcos de Ventana y Agregaciones

```sql
-- Consulta 1: Suma deslizante de ventas por mes
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(p.total) AS ventas_mes,
    SUM(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS suma_deslizante_3_meses,
    AVG(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_deslizante_3_meses
FROM pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- Explicación línea por línea:
-- GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): agrupa por mes
-- SUM(p.total): ventas del mes
-- SUM(SUM(p.total)) OVER: suma deslizante
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW: marco de 3 meses
-- AVG(SUM(p.total)) OVER: promedio deslizante
-- Resultado: análisis de tendencias con suma y promedio deslizante

-- Consulta 2: Análisis de productos por categoría con marcos de ventana
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    COUNT(*) OVER (PARTITION BY c.id) AS total_productos_categoria,
    AVG(p.precio) OVER (PARTITION BY c.id) AS precio_promedio_categoria,
    p.precio - AVG(p.precio) OVER (PARTITION BY c.id) AS diferencia_precio_promedio,
    ROUND((p.precio / AVG(p.precio) OVER (PARTITION BY c.id)) * 100, 2) AS porcentaje_precio_promedio
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio DESC;

-- Explicación línea por línea:
-- COUNT(*) OVER (PARTITION BY c.id): cuenta productos por categoría
-- AVG(p.precio) OVER (PARTITION BY c.id): precio promedio por categoría
-- p.precio - AVG(...): diferencia con el promedio
-- ROUND((p.precio / AVG(...)) * 100, 2): porcentaje del promedio
-- PARTITION BY c.id: divide por categoría
-- Resultado: análisis de productos respecto al promedio de su categoría

-- Consulta 3: Análisis de usuarios con marcos de ventana
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS usuarios_registrados_hasta_fecha,
    COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS usuarios_registrados_ultimos_5,
    ROW_NUMBER() OVER (ORDER BY u.fecha_registro) AS numero_registro
FROM usuarios u
ORDER BY u.fecha_registro;

-- Explicación línea por línea:
-- COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW): cuenta acumulativa
-- UNBOUNDED PRECEDING: desde el inicio
-- CURRENT ROW: hasta la fila actual
-- COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN 4 PRECEDING AND CURRENT ROW): cuenta deslizante
-- 4 PRECEDING: 4 filas anteriores
-- Resultado: análisis de patrones de registro de usuarios
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Funciones de Ranking
**Objetivo**: Practicar funciones de ranking para crear clasificaciones.

**Instrucciones**:
1. Crear ranking de productos por precio
2. Crear ranking de productos por categoría
3. Identificar top 3 productos por categoría
4. Crear ranking de usuarios por gasto total

**Solución paso a paso:**

```sql
-- Consulta 1: Ranking de productos por precio
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (ORDER BY p.precio DESC) AS numero_fila,
    RANK() OVER (ORDER BY p.precio DESC) AS ranking,
    DENSE_RANK() OVER (ORDER BY p.precio DESC) AS ranking_denso
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.precio DESC;

-- Explicación:
-- ROW_NUMBER() OVER (ORDER BY p.precio DESC): numeración secuencial
-- RANK() OVER (ORDER BY p.precio DESC): ranking con empates
-- DENSE_RANK() OVER (ORDER BY p.precio DESC): ranking denso
-- ORDER BY p.precio DESC: ordena por precio descendente

-- Consulta 2: Ranking de productos por categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS numero_fila_categoria,
    RANK() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_categoria,
    DENSE_RANK() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_denso_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio DESC;

-- Explicación:
-- PARTITION BY c.id: divide por categoría
-- ORDER BY p.precio DESC: ordena por precio dentro de cada categoría
-- ROW_NUMBER() OVER: numeración independiente por categoría
-- RANK() OVER: ranking independiente por categoría
-- DENSE_RANK() OVER: ranking denso independiente por categoría

-- Consulta 3: Top 3 productos por categoría
SELECT 
    producto,
    precio,
    categoria,
    ranking_categoria
FROM (
    SELECT 
        p.nombre AS producto,
        p.precio,
        c.nombre AS categoria,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC) AS ranking_categoria
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
) AS ranked_products
WHERE ranking_categoria <= 3
ORDER BY categoria, ranking_categoria;

-- Explicación:
-- Subconsulta: crea ranking de productos por categoría
-- ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.precio DESC): numeración por categoría
-- WHERE ranking_categoria <= 3: filtra solo los top 3
-- ORDER BY categoria, ranking_categoria: ordena por categoría y ranking

-- Consulta 4: Ranking de usuarios por gasto total
SELECT 
    u.nombre AS usuario,
    u.email,
    COALESCE(SUM(p.total), 0) AS total_gastado,
    ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(p.total), 0) DESC) AS numero_fila,
    RANK() OVER (ORDER BY COALESCE(SUM(p.total), 0) DESC) AS ranking,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(p.total), 0) DESC) AS ranking_denso
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email
ORDER BY total_gastado DESC;

-- Explicación:
-- LEFT JOIN pedidos p ON u.id = p.usuario_id: incluye usuarios sin pedidos
-- GROUP BY u.id, u.nombre, u.email: agrupa por usuario
-- COALESCE(SUM(p.total), 0): maneja usuarios sin pedidos
-- ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(p.total), 0) DESC): numeración por gasto
-- RANK() OVER: ranking por gasto
-- DENSE_RANK() OVER: ranking denso por gasto
```

### Ejercicio 2: Funciones de Desplazamiento
**Objetivo**: Practicar funciones LAG y LEAD para análisis temporal.

**Instrucciones**:
1. Analizar tendencias de precios por categoría
2. Analizar tendencias de ventas mensuales
3. Analizar patrones de registro de usuarios
4. Crear análisis de diferencias entre filas consecutivas

**Solución paso a paso:**

```sql
-- Consulta 1: Análisis de tendencias de precios por categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    LAG(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS precio_anterior,
    LEAD(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS precio_siguiente,
    p.precio - LAG(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) AS diferencia_precio_anterior,
    LEAD(p.precio, 1) OVER (PARTITION BY c.id ORDER BY p.precio) - p.precio AS diferencia_precio_siguiente
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio;

-- Explicación:
-- LAG(p.precio, 1) OVER: precio de la fila anterior
-- LEAD(p.precio, 1) OVER: precio de la fila siguiente
-- PARTITION BY c.id: divide por categoría
-- ORDER BY p.precio: ordena por precio dentro de cada categoría
-- diferencia_precio_anterior: diferencia con precio anterior
-- diferencia_precio_siguiente: diferencia con precio siguiente

-- Consulta 2: Análisis de tendencias de ventas mensuales
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(p.total) AS ventas_mes,
    LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS ventas_mes_anterior,
    SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS diferencia_ventas,
    ROUND(((SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) / LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) * 100, 2) AS porcentaje_cambio
FROM pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- Explicación:
-- GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): agrupa por mes
-- SUM(p.total): ventas del mes
-- LAG(SUM(p.total), 1) OVER: ventas del mes anterior
-- ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): ordena por tiempo
-- diferencia_ventas: diferencia absoluta
-- porcentaje_cambio: diferencia porcentual

-- Consulta 3: Análisis de patrones de registro de usuarios
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro) AS fecha_registro_anterior,
    DATEDIFF(u.fecha_registro, LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro)) AS dias_diferencia,
    ROW_NUMBER() OVER (ORDER BY u.fecha_registro) AS numero_registro
FROM usuarios u
ORDER BY u.fecha_registro;

-- Explicación:
-- LAG(u.fecha_registro, 1) OVER: fecha de registro anterior
-- ORDER BY u.fecha_registro: ordena por fecha de registro
-- DATEDIFF(...): diferencia en días
-- ROW_NUMBER() OVER: numeración por orden de registro

-- Consulta 4: Análisis de diferencias entre filas consecutivas
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    LAG(p.precio, 1) OVER (ORDER BY p.precio) AS precio_anterior,
    p.precio - LAG(p.precio, 1) OVER (ORDER BY p.precio) AS diferencia_precio,
    ROUND(((p.precio - LAG(p.precio, 1) OVER (ORDER BY p.precio)) / LAG(p.precio, 1) OVER (ORDER BY p.precio)) * 100, 2) AS porcentaje_cambio,
    CASE 
        WHEN p.precio > LAG(p.precio, 1) OVER (ORDER BY p.precio) THEN 'Aumento'
        WHEN p.precio < LAG(p.precio, 1) OVER (ORDER BY p.precio) THEN 'Disminución'
        ELSE 'Sin cambio'
    END AS tendencia_precio
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.precio;

-- Explicación:
-- LAG(p.precio, 1) OVER (ORDER BY p.precio): precio anterior
-- diferencia_precio: diferencia absoluta
-- porcentaje_cambio: diferencia porcentual
-- CASE: categoriza la tendencia del precio
-- Resultado: análisis de tendencias de precios
```

### Ejercicio 3: Marcos de Ventana y Agregaciones
**Objetivo**: Practicar marcos de ventana para análisis avanzados.

**Instrucciones**:
1. Crear suma deslizante de ventas por mes
2. Analizar productos por categoría con marcos de ventana
3. Crear análisis de usuarios con marcos de ventana
4. Implementar análisis de tendencias con múltiples marcos

**Solución paso a paso:**

```sql
-- Consulta 1: Suma deslizante de ventas por mes
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(p.total) AS ventas_mes,
    SUM(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS suma_deslizante_3_meses,
    AVG(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_deslizante_3_meses,
    SUM(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS suma_acumulativa
FROM pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- Explicación:
-- GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido): agrupa por mes
-- SUM(p.total): ventas del mes
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW: marco de 3 meses
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW: marco acumulativo
-- Resultado: análisis de tendencias con múltiples marcos

-- Consulta 2: Análisis de productos por categoría con marcos de ventana
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    COUNT(*) OVER (PARTITION BY c.id) AS total_productos_categoria,
    AVG(p.precio) OVER (PARTITION BY c.id) AS precio_promedio_categoria,
    MIN(p.precio) OVER (PARTITION BY c.id) AS precio_minimo_categoria,
    MAX(p.precio) OVER (PARTITION BY c.id) AS precio_maximo_categoria,
    p.precio - AVG(p.precio) OVER (PARTITION BY c.id) AS diferencia_precio_promedio,
    ROUND((p.precio / AVG(p.precio) OVER (PARTITION BY c.id)) * 100, 2) AS porcentaje_precio_promedio
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.precio DESC;

-- Explicación:
-- COUNT(*) OVER (PARTITION BY c.id): cuenta productos por categoría
-- AVG(p.precio) OVER (PARTITION BY c.id): precio promedio por categoría
-- MIN(p.precio) OVER (PARTITION BY c.id): precio mínimo por categoría
-- MAX(p.precio) OVER (PARTITION BY c.id): precio máximo por categoría
-- PARTITION BY c.id: divide por categoría
-- Resultado: análisis completo de productos por categoría

-- Consulta 3: Análisis de usuarios con marcos de ventana
SELECT 
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS usuarios_registrados_hasta_fecha,
    COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS usuarios_registrados_ultimos_5,
    ROW_NUMBER() OVER (ORDER BY u.fecha_registro) AS numero_registro,
    LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro) AS fecha_registro_anterior,
    DATEDIFF(u.fecha_registro, LAG(u.fecha_registro, 1) OVER (ORDER BY u.fecha_registro)) AS dias_diferencia
FROM usuarios u
ORDER BY u.fecha_registro;

-- Explicación:
-- COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW): cuenta acumulativa
-- UNBOUNDED PRECEDING: desde el inicio
-- CURRENT ROW: hasta la fila actual
-- COUNT(*) OVER (ORDER BY u.fecha_registro ROWS BETWEEN 4 PRECEDING AND CURRENT ROW): cuenta deslizante
-- 4 PRECEDING: 4 filas anteriores
-- Resultado: análisis de patrones de registro de usuarios

-- Consulta 4: Análisis de tendencias con múltiples marcos
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(p.total) AS ventas_mes,
    SUM(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS suma_deslizante_3_meses,
    AVG(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_deslizante_3_meses,
    SUM(SUM(p.total)) OVER (
        ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS suma_acumulativa,
    LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS ventas_mes_anterior,
    SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS diferencia_ventas,
    ROUND(((SUM(p.total) - LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) / LAG(SUM(p.total), 1) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) * 100, 2) AS porcentaje_cambio
FROM pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- Explicación:
-- Múltiples marcos de ventana: deslizante, acumulativo, y análisis temporal
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW: marco de 3 meses
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW: marco acumulativo
-- LAG(SUM(p.total), 1) OVER: análisis temporal
-- Resultado: análisis completo de tendencias de ventas
```

---

## 📝 Resumen de Conceptos Clave

### Funciones de Ventana:
- **ROW_NUMBER()**: Numeración secuencial única
- **RANK()**: Ranking con empates y saltos
- **DENSE_RANK()**: Ranking denso sin saltos
- **LAG()**: Valor de fila anterior
- **LEAD()**: Valor de fila siguiente

### Particionamiento y Ordenamiento:
- **PARTITION BY**: Divide datos en grupos lógicos
- **ORDER BY**: Ordena filas dentro de cada partición
- **Marcos de ventana**: Define rango de filas a considerar

### Marcos de Ventana:
- **ROWS BETWEEN**: Especifica filas por posición
- **RANGE BETWEEN**: Especifica filas por valor
- **UNBOUNDED PRECEDING**: Desde el inicio
- **CURRENT ROW**: Hasta la fila actual
- **UNBOUNDED FOLLOWING**: Hasta el final

### Ventajas de las Funciones de Ventana:
- **Preservan filas**: No agrupan como GROUP BY
- **Análisis detallado**: Mantienen el detalle de cada fila
- **Flexibilidad**: Permiten múltiples perspectivas
- **Eficiencia**: Evitan subconsultas complejas

### Mejores Prácticas:
1. **Usa PARTITION BY** para análisis por grupos
2. **Ordena correctamente** con ORDER BY
3. **Define marcos apropiados** para el análisis
4. **Combina funciones** para análisis complejos
5. **Optimiza el rendimiento** con índices apropiados

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Crear y gestionar vistas
- Vistas simples y complejas
- Vistas materializadas
- Optimización de vistas

---

## 💡 Consejos para el Éxito

1. **Entiende el contexto**: Las funciones de ventana operan sobre conjuntos de filas
2. **Usa particionamiento**: PARTITION BY es clave para análisis por grupos
3. **Define marcos apropiados**: Los marcos de ventana afectan los resultados
4. **Combina funciones**: Puedes usar múltiples funciones de ventana
5. **Optimiza el rendimiento**: Las funciones de ventana pueden ser costosas

---

## 🧭 Navegación

**← Anterior**: [Clase 4: Subconsultas Avanzadas](clase_4_subconsultas_avanzadas.md)  
**Siguiente →**: [Clase 6: Vistas](clase_6_vistas.md)

---

*¡Excelente trabajo! Ahora dominas las funciones de ventana en SQL. 🚀*
