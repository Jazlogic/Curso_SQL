# Clase 5: Consultas Analíticas

## Objetivos de la Clase
- Dominar funciones analíticas avanzadas
- Implementar análisis de tendencias y patrones
- Crear consultas de reporting complejas
- Aplicar técnicas de análisis de datos

## 1. Introducción a Consultas Analíticas

### ¿Qué son las Consultas Analíticas?
Las consultas analíticas son operaciones SQL especializadas que permiten realizar análisis complejos de datos, identificar patrones, tendencias y generar insights para la toma de decisiones empresariales.

### Características de las Consultas Analíticas
- **Análisis Temporal**: Tendencias a lo largo del tiempo
- **Comparaciones**: Análisis comparativo entre períodos
- **Rankings**: Clasificaciones y posicionamientos
- **Agregaciones Avanzadas**: Cálculos complejos sobre grupos de datos
- **Análisis de Cohortes**: Seguimiento de grupos específicos

## 2. Funciones de Ventana Avanzadas

### ROW_NUMBER() - Numeración de Filas
```sql
-- Análisis de ranking de productos por categoría
SELECT 
    categoria,
    nombre,
    precio,
    ROW_NUMBER() OVER (
        PARTITION BY categoria 
        ORDER BY precio DESC
    ) AS ranking_precio
FROM productos
ORDER BY categoria, ranking_precio;
```

**Explicación línea por línea:**
- `PARTITION BY categoria`: Divide los datos por categoría
- `ORDER BY precio DESC`: Ordena por precio descendente dentro de cada partición
- `ROW_NUMBER()`: Asigna número secuencial a cada fila

### RANK() y DENSE_RANK() - Rankings
```sql
-- Comparación entre RANK() y DENSE_RANK()
SELECT 
    nombre,
    precio,
    RANK() OVER (ORDER BY precio DESC) AS rank_precio,
    DENSE_RANK() OVER (ORDER BY precio DESC) AS dense_rank_precio
FROM productos
ORDER BY precio DESC;
```

**Diferencias clave:**
- **RANK()**: Salta números en caso de empates (1, 2, 2, 4, 5)
- **DENSE_RANK()**: No salta números en caso de empates (1, 2, 2, 3, 4)

### LAG() y LEAD() - Acceso a Filas Adyacentes
```sql
-- Análisis de tendencias mensuales
SELECT 
    YEAR(fecha) AS año,
    MONTH(fecha) AS mes,
    SUM(monto) AS ventas_mes,
    LAG(SUM(monto), 1) OVER (ORDER BY YEAR(fecha), MONTH(fecha)) AS ventas_mes_anterior,
    LEAD(SUM(monto), 1) OVER (ORDER BY YEAR(fecha), MONTH(fecha)) AS ventas_mes_siguiente,
    SUM(monto) - LAG(SUM(monto), 1) OVER (ORDER BY YEAR(fecha), MONTH(fecha)) AS diferencia_mes_anterior
FROM ventas
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY año, mes;
```

## 3. Análisis de Tendencias

### Media Móvil
```sql
-- Cálculo de media móvil de 7 días
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
FROM ventas_diarias
ORDER BY fecha;
```

### Análisis de Crecimiento
```sql
-- Análisis de crecimiento mensual
WITH ventas_mensuales AS (
    SELECT 
        YEAR(fecha) AS año,
        MONTH(fecha) AS mes,
        SUM(monto) AS ventas_mes
    FROM ventas
    GROUP BY YEAR(fecha), MONTH(fecha)
)
SELECT 
    año,
    mes,
    ventas_mes,
    LAG(ventas_mes, 1) OVER (ORDER BY año, mes) AS ventas_mes_anterior,
    ROUND(
        (ventas_mes - LAG(ventas_mes, 1) OVER (ORDER BY año, mes)) 
        / LAG(ventas_mes, 1) OVER (ORDER BY año, mes) * 100, 2
    ) AS crecimiento_porcentual
FROM ventas_mensuales
ORDER BY año, mes;
```

## 4. Análisis de Cohortes

### Análisis de Retención de Clientes
```sql
-- Análisis de cohortes de clientes
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

## 5. Análisis de Funnel

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

## 6. Análisis de Segmentación

### Análisis RFM (Recency, Frequency, Monetary)
```sql
-- Análisis RFM de clientes
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

## 7. Análisis de Correlación

### Análisis de Productos Relacionados
```sql
-- Análisis de productos que se compran juntos
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

## 8. Análisis de Outliers

### Identificación de Valores Atípicos
```sql
-- Identificar outliers en ventas
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

## 9. Análisis de Estacionalidad

### Patrones Estacionales
```sql
-- Análisis de patrones estacionales
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

### Análisis de Días de la Semana
```sql
-- Análisis por día de la semana
SELECT 
    DAYNAME(fecha) AS dia_semana,
    DAYOFWEEK(fecha) AS numero_dia,
    AVG(monto) AS ventas_promedio,
    COUNT(*) AS total_ventas
FROM ventas
GROUP BY DAYOFWEEK(fecha), DAYNAME(fecha)
ORDER BY numero_dia;
```

## 10. Análisis de Predicción

### Análisis de Tendencias para Predicción
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

## Ejercicios Prácticos

### Ejercicio 1: Análisis de Ranking de Productos
```sql
-- Crear ranking de productos por categoría
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

### Ejercicio 2: Análisis de Tendencias Mensuales
```sql
-- Análisis de tendencias mensuales con crecimiento
WITH ventas_mensuales AS (
    SELECT 
        YEAR(fecha) AS año,
        MONTH(fecha) AS mes,
        SUM(monto) AS ventas_mes
    FROM ventas
    GROUP BY YEAR(fecha), MONTH(fecha)
)
SELECT 
    año,
    mes,
    ventas_mes,
    LAG(ventas_mes, 1) OVER (ORDER BY año, mes) AS ventas_mes_anterior,
    ROUND(
        (ventas_mes - LAG(ventas_mes, 1) OVER (ORDER BY año, mes)) 
        / LAG(ventas_mes, 1) OVER (ORDER BY año, mes) * 100, 2
    ) AS crecimiento_porcentual
FROM ventas_mensuales
ORDER BY año, mes;
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

En esta clase hemos cubierto:

1. **Funciones de Ventana Avanzadas**: ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD()
2. **Análisis de Tendencias**: Media móvil, crecimiento, patrones temporales
3. **Análisis de Cohortes**: Retención de clientes, seguimiento de grupos
4. **Análisis de Funnel**: Conversión, embudo de ventas
5. **Análisis de Segmentación**: RFM, clasificación de clientes
6. **Análisis de Correlación**: Productos relacionados, patrones de compra
7. **Análisis de Outliers**: Identificación de valores atípicos
8. **Análisis de Estacionalidad**: Patrones estacionales, días de la semana
9. **Análisis de Predicción**: Tendencias, demanda futura
10. **Técnicas Avanzadas**: Marcos de ventana, agregaciones complejas

## Próxima Clase
En la siguiente clase exploraremos técnicas de gestión de memoria y caché para optimizar el rendimiento de las consultas analíticas.

## Recursos Adicionales
- Documentación de funciones analíticas
- Guías de análisis de datos
- Casos de estudio de business intelligence
- Herramientas de reporting
