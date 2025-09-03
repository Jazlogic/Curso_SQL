# Clase 1: Consultas Avanzadas y Análisis

## Objetivos de la Clase
- Dominar técnicas avanzadas de consultas SQL
- Implementar análisis complejos de datos
- Utilizar funciones analíticas avanzadas
- Optimizar consultas para grandes volúmenes de datos

## 1. Introducción a Consultas Avanzadas

### ¿Qué son las Consultas Avanzadas?
Las consultas avanzadas son operaciones SQL complejas que van más allá de las operaciones básicas CRUD (Create, Read, Update, Delete). Estas consultas permiten realizar análisis sofisticados, transformaciones de datos y operaciones que requieren múltiples pasos lógicos.

### Características de las Consultas Avanzadas
- **Complejidad**: Involucran múltiples tablas y operaciones
- **Análisis**: Proporcionan insights profundos sobre los datos
- **Rendimiento**: Requieren optimización cuidadosa
- **Flexibilidad**: Se adaptan a diferentes escenarios de negocio

## 2. Funciones Analíticas Avanzadas

### ROW_NUMBER() - Numeración de Filas
```sql
-- Ejemplo básico de ROW_NUMBER()
SELECT 
    nombre,
    salario,
    ROW_NUMBER() OVER (ORDER BY salario DESC) AS ranking_salario
FROM empleados;
```

**Explicación línea por línea:**
- `SELECT nombre, salario`: Selecciona las columnas nombre y salario de la tabla empleados
- `ROW_NUMBER() OVER (ORDER BY salario DESC)`: La función ROW_NUMBER() asigna un número secuencial a cada fila
- `OVER (ORDER BY salario DESC)`: La cláusula OVER define la ventana de datos, ordenando por salario de mayor a menor
- `AS ranking_salario`: Alias para la columna calculada que muestra el ranking

### RANK() y DENSE_RANK() - Rankings
```sql
-- Comparación entre RANK() y DENSE_RANK()
SELECT 
    nombre,
    salario,
    RANK() OVER (ORDER BY salario DESC) AS rank_salario,
    DENSE_RANK() OVER (ORDER BY salario DESC) AS dense_rank_salario
FROM empleados;
```

**Diferencias clave:**
- **RANK()**: Si hay empates, salta números (1, 2, 2, 4, 5)
- **DENSE_RANK()**: Si hay empates, no salta números (1, 2, 2, 3, 4)

### LAG() y LEAD() - Acceso a Filas Adyacentes
```sql
-- Análisis de tendencias con LAG() y LEAD()
SELECT 
    fecha,
    ventas,
    LAG(ventas, 1) OVER (ORDER BY fecha) AS ventas_anterior,
    LEAD(ventas, 1) OVER (ORDER BY fecha) AS ventas_siguiente,
    ventas - LAG(ventas, 1) OVER (ORDER BY fecha) AS diferencia_dia_anterior
FROM ventas_diarias
ORDER BY fecha;
```

**Explicación:**
- `LAG(ventas, 1)`: Obtiene el valor de ventas de la fila anterior
- `LEAD(ventas, 1)`: Obtiene el valor de ventas de la fila siguiente
- `ventas - LAG(...)`: Calcula la diferencia con el día anterior

## 3. Consultas con Múltiples CTEs

### Common Table Expressions Anidadas
```sql
-- Análisis complejo con múltiples CTEs
WITH ventas_por_mes AS (
    SELECT 
        YEAR(fecha) AS año,
        MONTH(fecha) AS mes,
        SUM(monto) AS total_ventas
    FROM ventas
    GROUP BY YEAR(fecha), MONTH(fecha)
),
promedio_mensual AS (
    SELECT 
        año,
        AVG(total_ventas) AS promedio_ventas
    FROM ventas_por_mes
    GROUP BY año
),
tendencia_crecimiento AS (
    SELECT 
        vpm.año,
        vpm.mes,
        vpm.total_ventas,
        pm.promedio_ventas,
        CASE 
            WHEN vpm.total_ventas > pm.promedio_ventas THEN 'Arriba del promedio'
            ELSE 'Abajo del promedio'
        END AS tendencia
    FROM ventas_por_mes vpm
    JOIN promedio_mensual pm ON vpm.año = pm.año
)
SELECT * FROM tendencia_crecimiento
ORDER BY año, mes;
```

**Explicación de cada CTE:**
1. **ventas_por_mes**: Agrupa ventas por año y mes
2. **promedio_mensual**: Calcula el promedio de ventas por año
3. **tendencia_crecimiento**: Compara cada mes con el promedio anual

## 4. Consultas Recursivas Avanzadas

### Jerarquías Organizacionales
```sql
-- Estructura jerárquica de empleados
WITH RECURSIVE jerarquia_empleados AS (
    -- Caso base: empleados sin supervisor
    SELECT 
        id,
        nombre,
        supervisor_id,
        0 AS nivel,
        CAST(nombre AS CHAR(1000)) AS ruta_jerarquica
    FROM empleados
    WHERE supervisor_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo: empleados con supervisor
    SELECT 
        e.id,
        e.nombre,
        e.supervisor_id,
        je.nivel + 1,
        CONCAT(je.ruta_jerarquica, ' -> ', e.nombre)
    FROM empleados e
    INNER JOIN jerarquia_empleados je ON e.supervisor_id = je.id
)
SELECT 
    id,
    nombre,
    nivel,
    ruta_jerarquica
FROM jerarquia_empleados
ORDER BY nivel, nombre;
```

**Conceptos clave:**
- **Caso base**: Define el punto de inicio de la recursión
- **Caso recursivo**: Define cómo se construye la siguiente iteración
- **UNION ALL**: Combina los resultados de ambos casos

## 5. Análisis de Ventanas Avanzadas

### Marcos de Ventana Personalizados
```sql
-- Análisis de ventas con marcos personalizados
SELECT 
    producto,
    fecha,
    ventas,
    SUM(ventas) OVER (
        PARTITION BY producto 
        ORDER BY fecha 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS ventas_3_dias,
    AVG(ventas) OVER (
        PARTITION BY producto 
        ORDER BY fecha 
        RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW
    ) AS promedio_7_dias
FROM ventas_productos
ORDER BY producto, fecha;
```

**Tipos de marcos:**
- **ROWS**: Basado en número de filas
- **RANGE**: Basado en valores de la columna de ordenamiento
- **PRECEDING**: Filas anteriores
- **FOLLOWING**: Filas siguientes

## 6. Consultas de Análisis Temporal

### Análisis de Tendencias
```sql
-- Análisis de tendencias mensuales
SELECT 
    YEAR(fecha) AS año,
    MONTH(fecha) AS mes,
    SUM(ventas) AS ventas_mes,
    LAG(SUM(ventas)) OVER (ORDER BY YEAR(fecha), MONTH(fecha)) AS ventas_mes_anterior,
    ROUND(
        (SUM(ventas) - LAG(SUM(ventas)) OVER (ORDER BY YEAR(fecha), MONTH(fecha))) 
        / LAG(SUM(ventas)) OVER (ORDER BY YEAR(fecha), MONTH(fecha)) * 100, 2
    ) AS crecimiento_porcentual
FROM ventas
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY año, mes;
```

## 7. Consultas de Análisis Estadístico

### Estadísticas Descriptivas
```sql
-- Análisis estadístico completo
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo,
    STDDEV(precio) AS desviacion_estandar,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY precio) AS mediana,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY precio) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY precio) AS q3
FROM productos
GROUP BY categoria;
```

## 8. Consultas de Análisis de Cohortes

### Análisis de Retención
```sql
-- Análisis de cohortes de usuarios
WITH primera_compra AS (
    SELECT 
        cliente_id,
        MIN(fecha_compra) AS primera_fecha
    FROM compras
    GROUP BY cliente_id
),
cohortes AS (
    SELECT 
        cliente_id,
        primera_fecha,
        YEAR(primera_fecha) AS año_cohorte,
        MONTH(primera_fecha) AS mes_cohorte
    FROM primera_compra
),
compras_cohorte AS (
    SELECT 
        c.cliente_id,
        c.año_cohorte,
        c.mes_cohorte,
        YEAR(co.fecha_compra) AS año_compra,
        MONTH(co.fecha_compra) AS mes_compra,
        (YEAR(co.fecha_compra) - c.año_cohorte) * 12 + 
        (MONTH(co.fecha_compra) - c.mes_cohorte) AS periodo_desde_cohorte
    FROM cohortes c
    JOIN compras co ON c.cliente_id = co.cliente_id
)
SELECT 
    año_cohorte,
    mes_cohorte,
    periodo_desde_cohorte,
    COUNT(DISTINCT cliente_id) AS clientes_activos
FROM compras_cohorte
GROUP BY año_cohorte, mes_cohorte, periodo_desde_cohorte
ORDER BY año_cohorte, mes_cohorte, periodo_desde_cohorte;
```

## 9. Consultas de Análisis de Funnel

### Análisis de Conversión
```sql
-- Análisis de funnel de conversión
WITH eventos_usuario AS (
    SELECT 
        usuario_id,
        evento,
        fecha_evento,
        ROW_NUMBER() OVER (PARTITION BY usuario_id ORDER BY fecha_evento) AS orden_evento
    FROM eventos_usuario
),
funnel_analysis AS (
    SELECT 
        usuario_id,
        MAX(CASE WHEN evento = 'visita' THEN orden_evento END) AS paso_visita,
        MAX(CASE WHEN evento = 'registro' THEN orden_evento END) AS paso_registro,
        MAX(CASE WHEN evento = 'compra' THEN orden_evento END) AS paso_compra
    FROM eventos_usuario
    GROUP BY usuario_id
)
SELECT 
    COUNT(*) AS total_usuarios,
    COUNT(paso_visita) AS usuarios_visita,
    COUNT(paso_registro) AS usuarios_registro,
    COUNT(paso_compra) AS usuarios_compra,
    ROUND(COUNT(paso_registro) * 100.0 / COUNT(paso_visita), 2) AS conversion_visita_registro,
    ROUND(COUNT(paso_compra) * 100.0 / COUNT(paso_registro), 2) AS conversion_registro_compra
FROM funnel_analysis;
```

## 10. Optimización de Consultas Avanzadas

### Técnicas de Optimización
```sql
-- Consulta optimizada con hints y técnicas avanzadas
SELECT /*+ USE_INDEX(ventas, idx_fecha_producto) */
    p.nombre,
    v.fecha,
    SUM(v.cantidad) AS total_vendido,
    AVG(v.precio) AS precio_promedio
FROM ventas v
INNER JOIN productos p ON v.producto_id = p.id
WHERE v.fecha >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
    AND v.fecha < CURRENT_DATE
    AND p.categoria = 'Electrónicos'
GROUP BY p.nombre, v.fecha
HAVING SUM(v.cantidad) > 10
ORDER BY total_vendido DESC
LIMIT 100;
```

**Técnicas aplicadas:**
- **Hint de índice**: `USE_INDEX` para forzar el uso de un índice específico
- **Filtros tempranos**: WHERE antes de JOIN para reducir datos
- **Agrupación eficiente**: GROUP BY en columnas indexadas
- **HAVING**: Filtro post-agregación
- **LIMIT**: Limita resultados para mejorar rendimiento

## Ejercicios Prácticos

### Ejercicio 1: Análisis de Ventas por Trimestre
```sql
-- Crear una consulta que muestre las ventas por trimestre con comparación año anterior
WITH ventas_trimestrales AS (
    SELECT 
        YEAR(fecha) AS año,
        QUARTER(fecha) AS trimestre,
        SUM(monto) AS ventas_trimestre
    FROM ventas
    GROUP BY YEAR(fecha), QUARTER(fecha)
)
SELECT 
    año,
    trimestre,
    ventas_trimestre,
    LAG(ventas_trimestre, 4) OVER (ORDER BY año, trimestre) AS ventas_trimestre_anterior,
    ROUND(
        (ventas_trimestre - LAG(ventas_trimestre, 4) OVER (ORDER BY año, trimestre)) 
        / LAG(ventas_trimestre, 4) OVER (ORDER BY año, trimestre) * 100, 2
    ) AS crecimiento_anual
FROM ventas_trimestrales
ORDER BY año, trimestre;
```

### Ejercicio 2: Ranking de Productos por Categoría
```sql
-- Crear un ranking de productos por categoría basado en ventas
SELECT 
    p.categoria,
    p.nombre,
    SUM(v.cantidad * v.precio) AS ventas_totales,
    RANK() OVER (PARTITION BY p.categoria ORDER BY SUM(v.cantidad * v.precio) DESC) AS ranking_categoria,
    DENSE_RANK() OVER (ORDER BY SUM(v.cantidad * v.precio) DESC) AS ranking_general
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.categoria, p.nombre
ORDER BY p.categoria, ranking_categoria;
```

### Ejercicio 3: Análisis de Clientes VIP
```sql
-- Identificar clientes VIP basado en múltiples criterios
WITH metricas_cliente AS (
    SELECT 
        c.id,
        c.nombre,
        COUNT(DISTINCT v.id) AS total_compras,
        SUM(v.monto) AS monto_total,
        AVG(v.monto) AS ticket_promedio,
        DATEDIFF(CURRENT_DATE, MAX(v.fecha)) AS dias_ultima_compra
    FROM clientes c
    LEFT JOIN ventas v ON c.id = v.cliente_id
    GROUP BY c.id, c.nombre
),
puntuacion_cliente AS (
    SELECT 
        *,
        (total_compras * 0.3 + monto_total * 0.0001 + ticket_promedio * 0.01 - dias_ultima_compra * 0.1) AS puntuacion_vip
    FROM metricas_cliente
)
SELECT 
    nombre,
    total_compras,
    monto_total,
    ticket_promedio,
    dias_ultima_compra,
    puntuacion_vip,
    CASE 
        WHEN puntuacion_vip >= 100 THEN 'VIP Oro'
        WHEN puntuacion_vip >= 50 THEN 'VIP Plata'
        WHEN puntuacion_vip >= 20 THEN 'VIP Bronce'
        ELSE 'Cliente Regular'
    END AS categoria_vip
FROM puntuacion_cliente
ORDER BY puntuacion_vip DESC;
```

### Ejercicio 4: Análisis de Estacionalidad
```sql
-- Analizar patrones estacionales en las ventas
SELECT 
    MONTH(fecha) AS mes,
    MONTHNAME(fecha) AS nombre_mes,
    AVG(monto) AS ventas_promedio,
    STDDEV(monto) AS variabilidad,
    MIN(monto) AS ventas_minimas,
    MAX(monto) AS ventas_maximas,
    COUNT(*) AS dias_con_ventas
FROM ventas
GROUP BY MONTH(fecha), MONTHNAME(fecha)
ORDER BY mes;
```

### Ejercicio 5: Análisis de Correlación entre Productos
```sql
-- Analizar qué productos se compran juntos frecuentemente
WITH compras_productos AS (
    SELECT 
        v.cliente_id,
        v.fecha,
        GROUP_CONCAT(p.nombre ORDER BY p.nombre) AS productos_comprados
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    GROUP BY v.cliente_id, v.fecha
    HAVING COUNT(DISTINCT p.id) > 1
),
combinaciones AS (
    SELECT 
        productos_comprados,
        COUNT(*) AS frecuencia
    FROM compras_productos
    GROUP BY productos_comprados
)
SELECT 
    productos_comprados,
    frecuencia,
    ROUND(frecuencia * 100.0 / (SELECT COUNT(*) FROM compras_productos), 2) AS porcentaje
FROM combinaciones
ORDER BY frecuencia DESC
LIMIT 20;
```

### Ejercicio 6: Análisis de Tendencias con Media Móvil
```sql
-- Calcular media móvil de ventas
SELECT 
    fecha,
    monto,
    AVG(monto) OVER (
        ORDER BY fecha 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS media_movil_7_dias,
    AVG(monto) OVER (
        ORDER BY fecha 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS media_movil_30_dias
FROM ventas
ORDER BY fecha;
```

### Ejercicio 7: Análisis de Outliers
```sql
-- Identificar valores atípicos en las ventas
WITH estadisticas_ventas AS (
    SELECT 
        AVG(monto) AS media,
        STDDEV(monto) AS desviacion_estandar
    FROM ventas
),
ventas_con_zscore AS (
    SELECT 
        v.*,
        (v.monto - s.media) / s.desviacion_estandar AS z_score
    FROM ventas v
    CROSS JOIN estadisticas_ventas s
)
SELECT 
    fecha,
    monto,
    z_score,
    CASE 
        WHEN ABS(z_score) > 3 THEN 'Outlier Extremo'
        WHEN ABS(z_score) > 2 THEN 'Outlier Moderado'
        ELSE 'Normal'
    END AS tipo_valor
FROM ventas_con_zscore
WHERE ABS(z_score) > 2
ORDER BY ABS(z_score) DESC;
```

### Ejercicio 8: Análisis de Cohortes de Retención
```sql
-- Análisis de retención de clientes por cohorte
WITH primera_compra AS (
    SELECT 
        cliente_id,
        MIN(fecha) AS primera_fecha
    FROM ventas
    GROUP BY cliente_id
),
cohortes AS (
    SELECT 
        cliente_id,
        primera_fecha,
        DATE_FORMAT(primera_fecha, '%Y-%m') AS cohorte
    FROM primera_compra
),
compras_cohorte AS (
    SELECT 
        c.cohorte,
        v.fecha,
        c.cliente_id,
        TIMESTAMPDIFF(MONTH, c.primera_fecha, v.fecha) AS mes_desde_primera_compra
    FROM cohortes c
    JOIN ventas v ON c.cliente_id = v.cliente_id
)
SELECT 
    cohorte,
    mes_desde_primera_compra,
    COUNT(DISTINCT cliente_id) AS clientes_activos,
    ROUND(
        COUNT(DISTINCT cliente_id) * 100.0 / 
        (SELECT COUNT(DISTINCT cliente_id) FROM cohortes WHERE cohorte = cc.cohorte), 2
    ) AS tasa_retencion
FROM compras_cohorte cc
GROUP BY cohorte, mes_desde_primera_compra
ORDER BY cohorte, mes_desde_primera_compra;
```

### Ejercicio 9: Análisis de Segmentación RFM
```sql
-- Análisis RFM (Recency, Frequency, Monetary)
WITH metricas_rfm AS (
    SELECT 
        cliente_id,
        DATEDIFF(CURRENT_DATE, MAX(fecha)) AS recency,
        COUNT(*) AS frequency,
        SUM(monto) AS monetary
    FROM ventas
    GROUP BY cliente_id
),
percentiles_rfm AS (
    SELECT 
        cliente_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM metricas_rfm
)
SELECT 
    cliente_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Campeones'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Leales'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Nuevos'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'En Riesgo'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Perdidos'
        ELSE 'Otros'
    END AS segmento_cliente
FROM percentiles_rfm
ORDER BY monetary DESC;
```

### Ejercicio 10: Análisis de Predicción de Demanda
```sql
-- Análisis de tendencias para predicción de demanda
WITH ventas_mensuales AS (
    SELECT 
        producto_id,
        YEAR(fecha) AS año,
        MONTH(fecha) AS mes,
        SUM(cantidad) AS cantidad_vendida
    FROM ventas
    GROUP BY producto_id, YEAR(fecha), MONTH(fecha)
),
tendencias AS (
    SELECT 
        producto_id,
        año,
        mes,
        cantidad_vendida,
        LAG(cantidad_vendida, 1) OVER (PARTITION BY producto_id ORDER BY año, mes) AS mes_anterior,
        LAG(cantidad_vendida, 12) OVER (PARTITION BY producto_id ORDER BY año, mes) AS mismo_mes_año_anterior,
        AVG(cantidad_vendida) OVER (
            PARTITION BY producto_id 
            ORDER BY año, mes 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_movil_3_meses
    FROM ventas_mensuales
)
SELECT 
    p.nombre,
    t.año,
    t.mes,
    t.cantidad_vendida,
    t.mes_anterior,
    t.mismo_mes_año_anterior,
    t.media_movil_3_meses,
    ROUND(
        (t.cantidad_vendida - t.media_movil_3_meses) / t.media_movil_3_meses * 100, 2
    ) AS variacion_media_movil,
    CASE 
        WHEN t.cantidad_vendida > t.media_movil_3_meses * 1.2 THEN 'Demanda Alta'
        WHEN t.cantidad_vendida < t.media_movil_3_meses * 0.8 THEN 'Demanda Baja'
        ELSE 'Demanda Normal'
    END AS nivel_demanda
FROM tendencias t
JOIN productos p ON t.producto_id = p.id
ORDER BY p.nombre, t.año, t.mes;
```

## Resumen de la Clase

En esta clase hemos explorado:

1. **Funciones Analíticas Avanzadas**: ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD()
2. **Consultas con Múltiples CTEs**: Organización y reutilización de consultas complejas
3. **Consultas Recursivas**: Manejo de estructuras jerárquicas
4. **Análisis de Ventanas**: Marcos personalizados y análisis temporal
5. **Análisis Estadístico**: Estadísticas descriptivas y percentiles
6. **Análisis de Cohortes**: Seguimiento de grupos de usuarios
7. **Análisis de Funnel**: Conversión y embudo de ventas
8. **Optimización**: Técnicas para mejorar rendimiento

## Próxima Clase
En la siguiente clase exploraremos técnicas avanzadas de optimización de rendimiento, incluyendo análisis de planes de ejecución, índices avanzados y estrategias de tuning.

## Recursos Adicionales
- Documentación de funciones analíticas
- Guías de optimización de consultas
- Casos de estudio de análisis de datos
- Herramientas de profiling de consultas
