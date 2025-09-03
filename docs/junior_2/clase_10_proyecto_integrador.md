# Clase 10: Proyecto Integrador - Sistema de E-commerce Completo

## 📚 Descripción de la Clase
En esta clase final del módulo, aplicarás todas las técnicas avanzadas de SQL aprendidas para crear un sistema completo de análisis de e-commerce. Integrarás JOINs, subconsultas, funciones de ventana, CTEs, vistas y optimización para resolver problemas complejos del mundo real.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Aplicar todas las técnicas SQL avanzadas en un proyecto real
- Crear un sistema completo de análisis de e-commerce
- Integrar múltiples técnicas SQL en consultas complejas
- Resolver problemas de negocio con SQL avanzado
- Optimizar consultas para mejor rendimiento
- Crear reportes ejecutivos y dashboards

## ⏱️ Duración Estimada
**5-6 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### Proyecto Integrador: Sistema de E-commerce

Este proyecto integra todas las técnicas aprendidas en el módulo para crear un sistema completo de análisis de e-commerce.

#### Componentes del Proyecto:
- **Análisis de ventas**: Tendencias, estacionalidad, crecimiento
- **Análisis de productos**: Rendimiento, categorías, inventario
- **Análisis de usuarios**: Segmentación, comportamiento, valor
- **Análisis de categorías**: Comparación, tendencias, oportunidades
- **Dashboard ejecutivo**: Métricas clave, KPIs, reportes

#### Técnicas Integradas:
- **JOINs**: Para combinar datos de múltiples tablas
- **Subconsultas**: Para lógica condicional compleja
- **Funciones de ventana**: Para análisis de tendencias
- **CTEs**: Para modularizar consultas complejas
- **Vistas**: Para simplificar acceso a datos
- **Optimización**: Para mejor rendimiento

---

## 💻 Proyecto Práctico

### Sistema de E-commerce Completo

```sql
-- Crear base de datos del proyecto
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- Tablas del sistema
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_nacimiento DATE,
    ciudad VARCHAR(100)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE detalle_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y gadgets'),
('Ropa', 'Vestimenta y accesorios'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipamiento deportivo'),
('Libros', 'Literatura y material educativo');

INSERT INTO productos (nombre, precio, categoria_id, stock) VALUES
('iPhone 14', 999.99, 1, 25),
('Samsung Galaxy S23', 899.99, 1, 30),
('MacBook Air', 1299.99, 1, 15),
('iPad Pro', 1099.99, 1, 20),
('Camiseta Nike', 29.99, 2, 100),
('Jeans Levi\'s', 79.99, 2, 75),
('Zapatillas Adidas', 89.99, 2, 50),
('Sofá 3 plazas', 599.99, 3, 5),
('Mesa de escritorio', 299.99, 3, 10),
('Balón de fútbol', 19.99, 4, 50),
('Raqueta de tenis', 149.99, 4, 20),
('El Quijote', 15.99, 5, 30),
('Diccionario Oxford', 25.99, 5, 25);

INSERT INTO usuarios (nombre, email, fecha_nacimiento, ciudad) VALUES
('Ana García', 'ana.garcia@email.com', '1990-05-15', 'Madrid'),
('Carlos López', 'carlos.lopez@email.com', '1985-08-22', 'Barcelona'),
('María Rodríguez', 'maria.rodriguez@email.com', '1992-12-03', 'Valencia'),
('José Martín', 'jose.martin@email.com', '1988-03-18', 'Sevilla'),
('Laura Sánchez', 'laura.sanchez@email.com', '1995-07-25', 'Bilbao'),
('Pedro González', 'pedro.gonzalez@email.com', '1987-11-10', 'Madrid'),
('Carmen Ruiz', 'carmen.ruiz@email.com', '1993-04-28', 'Barcelona'),
('Antonio Díaz', 'antonio.diaz@email.com', '1989-09-14', 'Valencia');

INSERT INTO pedidos (usuario_id, total, estado) VALUES
(1, 999.99, 'entregado'),
(2, 1329.98, 'entregado'),
(3, 45.98, 'entregado'),
(1, 599.99, 'enviado'),
(4, 35.98, 'entregado'),
(5, 1299.99, 'procesando'),
(6, 89.98, 'entregado'),
(7, 199.98, 'entregado'),
(8, 149.99, 'pendiente'),
(2, 79.99, 'entregado');

INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 999.99),
(2, 1, 1, 999.99),
(2, 3, 1, 1299.99),
(3, 5, 1, 29.99),
(3, 10, 1, 19.99),
(4, 8, 1, 599.99),
(5, 10, 1, 19.99),
(5, 12, 1, 15.99),
(6, 3, 1, 1299.99),
(7, 5, 1, 29.99),
(7, 6, 1, 79.99),
(8, 6, 1, 79.99),
(8, 7, 1, 89.99),
(9, 11, 1, 149.99),
(10, 6, 1, 79.99);
```

---

## 🎯 Ejercicios del Proyecto

### Ejercicio 1: Análisis de Ventas
**Objetivo**: Crear análisis completo de ventas con múltiples técnicas.

**Instrucciones**:
1. Crear análisis de ventas mensuales con tendencias
2. Crear análisis de ventas por categoría
3. Crear análisis de crecimiento de ventas
4. Crear ranking de productos más vendidos

**Solución paso a paso:**

```sql
-- Análisis de ventas mensuales con tendencias
WITH ventas_mensuales AS (
    SELECT 
        YEAR(p.fecha_pedido) AS año,
        MONTH(p.fecha_pedido) AS mes,
        SUM(p.total) AS ventas_totales,
        COUNT(DISTINCT p.usuario_id) AS usuarios_unicos,
        COUNT(p.id) AS total_pedidos,
        AVG(p.total) AS promedio_por_pedido
    FROM pedidos p
    WHERE p.estado != 'cancelado'
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

-- Análisis de ventas por categoría
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
    LEFT JOIN pedidos ped ON dp.pedido_id = ped.id AND ped.estado != 'cancelado'
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
```

### Ejercicio 2: Análisis de Usuarios
**Objetivo**: Crear análisis completo de usuarios con segmentación.

**Instrucciones**:
1. Crear análisis de usuarios por segmento de valor
2. Crear análisis de usuarios por actividad
3. Crear análisis de usuarios por ubicación
4. Crear análisis de comportamiento de compra

**Solución paso a paso:**

```sql
-- Análisis de usuarios por segmento de valor
WITH usuarios_analisis AS (
    SELECT 
        u.id,
        u.nombre,
        u.email,
        u.ciudad,
        COUNT(p.id) AS total_pedidos,
        COALESCE(SUM(p.total), 0) AS total_gastado,
        COALESCE(AVG(p.total), 0) AS promedio_por_pedido,
        MAX(p.fecha_pedido) AS ultima_compra,
        MIN(p.fecha_pedido) AS primera_compra,
        DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_ultima_compra
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.usuario_id AND p.estado != 'cancelado'
    GROUP BY u.id, u.nombre, u.email, u.ciudad
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

-- Análisis de usuarios por ubicación
WITH usuarios_ubicacion AS (
    SELECT 
        u.ciudad,
        COUNT(DISTINCT u.id) AS total_usuarios,
        COUNT(DISTINCT p.id) AS total_pedidos,
        COALESCE(SUM(p.total), 0) AS ventas_totales,
        COALESCE(AVG(p.total), 0) AS promedio_por_pedido
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.usuario_id AND p.estado != 'cancelado'
    GROUP BY u.ciudad
)
SELECT 
    ciudad,
    total_usuarios,
    total_pedidos,
    ventas_totales,
    promedio_por_pedido,
    ROUND((ventas_totales / total_usuarios), 2) AS ventas_por_usuario,
    RANK() OVER (ORDER BY ventas_totales DESC) AS ranking_ciudad
FROM usuarios_ubicacion
ORDER BY ventas_totales DESC;
```

### Ejercicio 3: Dashboard Ejecutivo
**Objetivo**: Crear dashboard ejecutivo con métricas clave.

**Instrucciones**:
1. Crear métricas de ventas generales
2. Crear métricas de productos
3. Crear métricas de usuarios
4. Crear métricas de categorías

**Solución paso a paso:**

```sql
-- Dashboard ejecutivo - Métricas generales
WITH metricas_generales AS (
    SELECT 
        'Total Ventas' AS metric,
        CONCAT('$', FORMAT(SUM(p.total), 2)) AS valor
    FROM pedidos p
    WHERE p.estado != 'cancelado'
    
    UNION ALL
    
    SELECT 
        'Total Pedidos' AS metric,
        COUNT(*) AS valor
    FROM pedidos p
    WHERE p.estado != 'cancelado'
    
    UNION ALL
    
    SELECT 
        'Usuarios Únicos' AS metric,
        COUNT(DISTINCT u.id) AS valor
    FROM usuarios u
    INNER JOIN pedidos p ON u.id = p.usuario_id
    WHERE p.estado != 'cancelado'
    
    UNION ALL
    
    SELECT 
        'Productos Vendidos' AS metric,
        COUNT(DISTINCT p.id) AS valor
    FROM productos p
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
    INNER JOIN pedidos ped ON dp.pedido_id = ped.id
    WHERE ped.estado != 'cancelado'
    
    UNION ALL
    
    SELECT 
        'Promedio por Pedido' AS metric,
        CONCAT('$', FORMAT(AVG(p.total), 2)) AS valor
    FROM pedidos p
    WHERE p.estado != 'cancelado'
)
SELECT * FROM metricas_generales;

-- Dashboard ejecutivo - Top productos
WITH top_productos AS (
    SELECT 
        p.nombre AS producto,
        c.nombre AS categoria,
        SUM(dp.cantidad) AS total_vendido,
        SUM(dp.cantidad * dp.precio_unitario) AS ingresos_generados,
        COUNT(DISTINCT dp.pedido_id) AS pedidos_unicos,
        RANK() OVER (ORDER BY SUM(dp.cantidad) DESC) AS ranking_ventas,
        RANK() OVER (ORDER BY SUM(dp.cantidad * dp.precio_unitario) DESC) AS ranking_ingresos
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    INNER JOIN detalle_pedidos dp ON p.id = dp.producto_id
    INNER JOIN pedidos ped ON dp.pedido_id = ped.id
    WHERE ped.estado != 'cancelado'
    GROUP BY p.id, p.nombre, c.nombre
)
SELECT 
    producto,
    categoria,
    total_vendido,
    ingresos_generados,
    pedidos_unicos,
    ranking_ventas,
    ranking_ingresos
FROM top_productos
WHERE ranking_ventas <= 5 OR ranking_ingresos <= 5
ORDER BY ranking_ventas;
```

---

## 📝 Resumen del Proyecto

### Técnicas Aplicadas:
- **JOINs**: Para combinar datos de múltiples tablas
- **Subconsultas**: Para lógica condicional compleja
- **Funciones de ventana**: Para análisis de tendencias
- **CTEs**: Para modularizar consultas complejas
- **Agregaciones**: Para resúmenes y estadísticas
- **Optimización**: Para mejor rendimiento

### Componentes del Sistema:
- **Análisis de ventas**: Tendencias, estacionalidad, crecimiento
- **Análisis de productos**: Rendimiento, categorías, inventario
- **Análisis de usuarios**: Segmentación, comportamiento, valor
- **Análisis de categorías**: Comparación, tendencias, oportunidades
- **Dashboard ejecutivo**: Métricas clave, KPIs, reportes

### Resultados del Aprendizaje:
- **Integración de técnicas**: Combinación de múltiples técnicas SQL
- **Resolución de problemas**: Aplicación a casos reales
- **Análisis de datos**: Creación de insights de negocio
- **Optimización**: Mejora del rendimiento
- **Documentación**: Explicación de la lógica

---

## 🚀 Próximos Pasos

Con la finalización de este módulo, has dominado:
- **JOINs básicos y avanzados**
- **Subconsultas simples y complejas**
- **Funciones de ventana**
- **Vistas y CTEs**
- **Consultas complejas**
- **Optimización avanzada**

Estás listo para continuar con el **Módulo 3: Bases de Datos Avanzadas** donde aprenderás:
- Diseño de bases de datos
- Normalización
- Transacciones
- Procedimientos almacenados
- Triggers y eventos

---

## 💡 Consejos para el Éxito

1. **Practica regularmente**: La práctica constante es clave
2. **Aplica a casos reales**: Usa ejemplos del mundo real
3. **Optimiza siempre**: Considera el rendimiento
4. **Documenta tu código**: Explica la lógica
5. **Mantente actualizado**: SQL evoluciona constantemente

---

## 🧭 Navegación

**← Anterior**: [Clase 9: Optimización Avanzada](clase_9_optimizacion_avanzada.md)  
**Siguiente →**: [Módulo 3: Bases de Datos Avanzadas](../junior_3/README.md)

---

*¡Felicitaciones! Has completado exitosamente el Módulo 2: Consultas Avanzadas. 🎉*
