# Clase 8: Consultas Complejas - Combinando Técnicas

## 📚 Descripción de la Clase
En esta clase aprenderás a combinar todas las técnicas avanzadas de SQL para crear consultas complejas y sofisticadas. Dominarás la integración de JOINs, subconsultas, funciones de ventana, CTEs y vistas para resolver problemas de análisis de datos del mundo real.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Combinar múltiples técnicas SQL en una sola consulta
- Crear consultas complejas para análisis de negocio
- Integrar JOINs, subconsultas, funciones de ventana y CTEs
- Resolver problemas complejos de análisis de datos
- Optimizar consultas que combinan múltiples técnicas
- Aplicar mejores prácticas para consultas complejas

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### Combinando Técnicas SQL

Las consultas complejas combinan múltiples técnicas SQL para resolver problemas sofisticados de análisis de datos.

#### Técnicas a Combinar:
- **JOINs**: Para combinar datos de múltiples tablas
- **Subconsultas**: Para lógica condicional compleja
- **Funciones de ventana**: Para análisis de tendencias
- **CTEs**: Para modularizar consultas complejas
- **Vistas**: Para simplificar acceso a datos
- **Agregaciones**: Para resúmenes y estadísticas

#### Estrategias para Consultas Complejas:
- **Modularización**: Dividir en partes manejables
- **CTEs**: Para pasos intermedios
- **Funciones de ventana**: Para análisis de tendencias
- **Subconsultas**: Para lógica condicional
- **JOINs**: Para combinar datos relacionados

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Análisis Completo de Ventas

```sql
-- Análisis completo de ventas con múltiples técnicas
WITH ventas_mensuales AS (
    SELECT 
        YEAR(p.fecha_pedido) AS año,
        MONTH(p.fecha_pedido) AS mes,
        SUM(p.total) AS ventas_totales,
        COUNT(DISTINCT p.usuario_id) AS usuarios_unicos,
        COUNT(p.id) AS total_pedidos
    FROM pedidos p
    GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
),
tendencias_ventas AS (
    SELECT 
        *,
        LAG(ventas_totales, 1) OVER (ORDER BY año, mes) AS ventas_mes_anterior,
        ROUND(((ventas_totales - LAG(ventas_totales, 1) OVER (ORDER BY año, mes)) / LAG(ventas_totales, 1) OVER (ORDER BY año, mes)) * 100, 2) AS porcentaje_cambio,
        RANK() OVER (ORDER BY ventas_totales DESC) AS ranking_ventas
    FROM ventas_mensuales
)
SELECT 
    año,
    mes,
    ventas_totales,
    usuarios_unicos,
    total_pedidos,
    ventas_mes_anterior,
    porcentaje_cambio,
    ranking_ventas,
    CASE 
        WHEN porcentaje_cambio > 10 THEN 'Crecimiento Alto'
        WHEN porcentaje_cambio > 0 THEN 'Crecimiento'
        WHEN porcentaje_cambio > -10 THEN 'Estable'
        ELSE 'Declive'
    END AS tendencia
FROM tendencias_ventas
ORDER BY año, mes;
```

### Ejemplo 2: Análisis de Productos con Múltiples Dimensiones

```sql
-- Análisis completo de productos
WITH productos_ventas AS (
    SELECT 
        p.id,
        p.nombre,
        p.precio,
        c.nombre AS categoria,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_generados,
        COUNT(DISTINCT dp.pedido_id) AS pedidos_unicos
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, p.precio, c.nombre
),
analisis_categoria AS (
    SELECT 
        categoria,
        COUNT(*) AS total_productos,
        AVG(precio) AS precio_promedio,
        SUM(total_vendido) AS ventas_totales_categoria,
        SUM(ingresos_generados) AS ingresos_totales_categoria
    FROM productos_ventas
    GROUP BY categoria
),
productos_ranking AS (
    SELECT 
        pv.*,
        ac.precio_promedio,
        ac.ventas_totales_categoria,
        ac.ingresos_totales_categoria,
        RANK() OVER (PARTITION BY pv.categoria ORDER BY pv.total_vendido DESC) AS ranking_ventas_categoria,
        RANK() OVER (PARTITION BY pv.categoria ORDER BY pv.ingresos_generados DESC) AS ranking_ingresos_categoria,
        ROUND((pv.precio / ac.precio_promedio) * 100, 2) AS porcentaje_precio_promedio
    FROM productos_ventas pv
    INNER JOIN analisis_categoria ac ON pv.categoria = ac.categoria
)
SELECT 
    nombre,
    categoria,
    precio,
    total_vendido,
    ingresos_generados,
    pedidos_unicos,
    ranking_ventas_categoria,
    ranking_ingresos_categoria,
    porcentaje_precio_promedio,
    CASE 
        WHEN ranking_ventas_categoria <= 3 THEN 'Top Vendedor'
        WHEN ranking_ingresos_categoria <= 3 THEN 'Top Ingresos'
        WHEN porcentaje_precio_promedio < 80 THEN 'Precio Bajo'
        WHEN porcentaje_precio_promedio > 120 THEN 'Precio Alto'
        ELSE 'Precio Medio'
    END AS categoria_producto
FROM productos_ranking
ORDER BY categoria, ranking_ventas_categoria;
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Análisis Completo de Negocio
**Objetivo**: Crear consultas complejas que combinen múltiples técnicas.

**Instrucciones**:
1. Crear análisis completo de ventas mensuales
2. Crear análisis de productos con múltiples dimensiones
3. Crear análisis de usuarios con patrones de compra
4. Crear dashboard ejecutivo con métricas clave

**Solución paso a paso:**

```sql
-- Consulta 1: Análisis completo de ventas mensuales
WITH ventas_mensuales AS (
    SELECT 
        YEAR(p.fecha_pedido) AS año,
        MONTH(p.fecha_pedido) AS mes,
        SUM(p.total) AS ventas_totales,
        COUNT(DISTINCT p.usuario_id) AS usuarios_unicos,
        COUNT(p.id) AS total_pedidos,
        AVG(p.total) AS promedio_por_pedido
    FROM pedidos p
    GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
),
tendencias_ventas AS (
    SELECT 
        *,
        LAG(ventas_totales, 1) OVER (ORDER BY año, mes) AS ventas_mes_anterior,
        ROUND(((ventas_totales - LAG(ventas_totales, 1) OVER (ORDER BY año, mes)) / LAG(ventas_totales, 1) OVER (ORDER BY año, mes)) * 100, 2) AS porcentaje_cambio,
        RANK() OVER (ORDER BY ventas_totales DESC) AS ranking_ventas,
        SUM(ventas_totales) OVER (ORDER BY año, mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ventas_acumulativas
    FROM ventas_mensuales
)
SELECT 
    año,
    mes,
    ventas_totales,
    usuarios_unicos,
    total_pedidos,
    promedio_por_pedido,
    ventas_mes_anterior,
    porcentaje_cambio,
    ranking_ventas,
    ventas_acumulativas,
    CASE 
        WHEN porcentaje_cambio > 10 THEN 'Crecimiento Alto'
        WHEN porcentaje_cambio > 0 THEN 'Crecimiento'
        WHEN porcentaje_cambio > -10 THEN 'Estable'
        ELSE 'Declive'
    END AS tendencia
FROM tendencias_ventas
ORDER BY año, mes;

-- Consulta 2: Análisis de productos con múltiples dimensiones
WITH productos_ventas AS (
    SELECT 
        p.id,
        p.nombre,
        p.precio,
        c.nombre AS categoria,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_generados,
        COUNT(DISTINCT dp.pedido_id) AS pedidos_unicos
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, p.precio, c.nombre
),
analisis_categoria AS (
    SELECT 
        categoria,
        COUNT(*) AS total_productos,
        AVG(precio) AS precio_promedio,
        SUM(total_vendido) AS ventas_totales_categoria,
        SUM(ingresos_generados) AS ingresos_totales_categoria
    FROM productos_ventas
    GROUP BY categoria
),
productos_ranking AS (
    SELECT 
        pv.*,
        ac.precio_promedio,
        ac.ventas_totales_categoria,
        ac.ingresos_totales_categoria,
        RANK() OVER (PARTITION BY pv.categoria ORDER BY pv.total_vendido DESC) AS ranking_ventas_categoria,
        RANK() OVER (PARTITION BY pv.categoria ORDER BY pv.ingresos_generados DESC) AS ranking_ingresos_categoria,
        ROUND((pv.precio / ac.precio_promedio) * 100, 2) AS porcentaje_precio_promedio
    FROM productos_ventas pv
    INNER JOIN analisis_categoria ac ON pv.categoria = ac.categoria
)
SELECT 
    nombre,
    categoria,
    precio,
    total_vendido,
    ingresos_generados,
    pedidos_unicos,
    ranking_ventas_categoria,
    ranking_ingresos_categoria,
    porcentaje_precio_promedio,
    CASE 
        WHEN ranking_ventas_categoria <= 3 THEN 'Top Vendedor'
        WHEN ranking_ingresos_categoria <= 3 THEN 'Top Ingresos'
        WHEN porcentaje_precio_promedio < 80 THEN 'Precio Bajo'
        WHEN porcentaje_precio_promedio > 120 THEN 'Precio Alto'
        ELSE 'Precio Medio'
    END AS categoria_producto
FROM productos_ranking
ORDER BY categoria, ranking_ventas_categoria;
```

### Ejercicio 2: Dashboard Ejecutivo
**Objetivo**: Crear consultas complejas para métricas de negocio.

**Instrucciones**:
1. Crear métricas de ventas por categoría
2. Crear análisis de usuarios por segmento
3. Crear tendencias de productos
4. Crear resumen ejecutivo

**Solución paso a paso:**

```sql
-- Consulta 1: Métricas de ventas por categoría
WITH ventas_categoria AS (
    SELECT 
        c.nombre AS categoria,
        COUNT(DISTINCT p.id) AS total_productos,
        COUNT(DISTINCT dp.pedido_id) AS total_pedidos,
        SUM(dp.cantidad) AS total_vendido,
        SUM(dp.cantidad * dp.precio_unitario) AS ingresos_totales,
        AVG(dp.precio_unitario) AS precio_promedio
    FROM categorias c
    INNER JOIN productos p ON c.id = p.categoria_id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY c.id, c.nombre
),
ranking_categorias AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY ingresos_totales DESC) AS ranking_ingresos,
        RANK() OVER (ORDER BY total_vendido DESC) AS ranking_ventas,
        ROUND((ingresos_totales / SUM(ingresos_totales) OVER ()) * 100, 2) AS porcentaje_ingresos
    FROM ventas_categoria
)
SELECT 
    categoria,
    total_productos,
    total_pedidos,
    total_vendido,
    ingresos_totales,
    precio_promedio,
    ranking_ingresos,
    ranking_ventas,
    porcentaje_ingresos,
    CASE 
        WHEN ranking_ingresos <= 2 THEN 'Categoría Estrella'
        WHEN ranking_ingresos <= 4 THEN 'Categoría Estable'
        ELSE 'Categoría Emergente'
    END AS tipo_categoria
FROM ranking_categorias
ORDER BY ranking_ingresos;

-- Consulta 2: Análisis de usuarios por segmento
WITH usuarios_analisis AS (
    SELECT 
        u.id,
        u.nombre,
        u.email,
        COUNT(p.id) AS total_pedidos,
        COALESCE(SUM(p.total), 0) AS total_gastado,
        COALESCE(AVG(p.total), 0) AS promedio_por_pedido,
        MAX(p.fecha_pedido) AS ultima_compra,
        MIN(p.fecha_pedido) AS primera_compra,
        DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_ultima_compra
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.usuario_id
    GROUP BY u.id, u.nombre, u.email
),
segmentacion_usuarios AS (
    SELECT 
        *,
        CASE 
            WHEN total_gastado >= 1000 THEN 'Alto Valor'
            WHEN total_gastado >= 500 THEN 'Medio Valor'
            WHEN total_gastado > 0 THEN 'Bajo Valor'
            ELSE 'Sin Compras'
        END AS segmento_valor,
        CASE 
            WHEN dias_ultima_compra <= 30 THEN 'Activo'
            WHEN dias_ultima_compra <= 90 THEN 'Moderado'
            WHEN dias_ultima_compra <= 180 THEN 'Inactivo'
            ELSE 'Muy Inactivo'
        END AS segmento_actividad,
        RANK() OVER (ORDER BY total_gastado DESC) AS ranking_gasto
    FROM usuarios_analisis
)
SELECT 
    segmento_valor,
    segmento_actividad,
    COUNT(*) AS total_usuarios,
    AVG(total_gastado) AS gasto_promedio,
    AVG(total_pedidos) AS pedidos_promedio,
    SUM(total_gastado) AS gasto_total_segmento
FROM segmentacion_usuarios
GROUP BY segmento_valor, segmento_actividad
ORDER BY gasto_total_segmento DESC;
```

---

## 📝 Resumen de Conceptos Clave

### Técnicas Combinadas:
- **JOINs + Subconsultas**: Para lógica condicional compleja
- **CTEs + Funciones de ventana**: Para análisis de tendencias
- **Vistas + CTEs**: Para modularización avanzada
- **Agregaciones + Funciones de ventana**: Para análisis multidimensional

### Estrategias para Consultas Complejas:
- **Modularización**: Dividir en pasos manejables
- **CTEs**: Para pasos intermedios
- **Funciones de ventana**: Para análisis de tendencias
- **Subconsultas**: Para lógica condicional
- **JOINs**: Para combinar datos relacionados

### Mejores Prácticas:
1. **Planifica la consulta**: Piensa en los pasos necesarios
2. **Usa CTEs**: Para modularizar consultas complejas
3. **Optimiza el rendimiento**: Considera el orden de ejecución
4. **Documenta la lógica**: Explica el propósito de cada parte
5. **Prueba incrementalmente**: Construye paso a paso

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Optimización avanzada de consultas
- Técnicas de indexación
- Análisis de planes de ejecución
- Mejores prácticas de rendimiento

---

## 💡 Consejos para el Éxito

1. **Planifica antes de escribir**: Piensa en la estructura de la consulta
2. **Usa CTEs para modularizar**: Divide consultas complejas en pasos
3. **Combina técnicas apropiadamente**: Cada técnica tiene su propósito
4. **Optimiza el rendimiento**: Considera el impacto en la base de datos
5. **Documenta la lógica**: Explica el propósito de cada parte

---

## 🧭 Navegación

**← Anterior**: [Clase 7: CTEs](clase_7_ctes.md)  
**Siguiente →**: [Clase 9: Optimización Avanzada](clase_9_optimizacion_avanzada.md)

---

*¡Excelente trabajo! Ahora dominas las consultas complejas en SQL. 🚀*
