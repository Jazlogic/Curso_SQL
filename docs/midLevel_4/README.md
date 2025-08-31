# 🔶 Mid Level 4: Consultas Complejas y Optimización Básica

## 🧭 Navegación del Curso

**← Anterior**: [Mid Level 3: Funciones Agregadas](../midLevel_3/README.md)  
**Siguiente →**: [Mid Level 5: Vistas e Índices](../midLevel_5/README.md)

---

## 📖 Teoría

### ¿Qué son las Consultas Complejas?
Las consultas complejas combinan múltiples conceptos SQL en una sola instrucción: JOINs, subconsultas, funciones agregadas, CASE statements, y más. Son fundamentales para reportes empresariales y análisis avanzados.

### Conceptos de Optimización
1. **EXPLAIN**: Analiza el plan de ejecución de una consulta
2. **Índices**: Mejoran la velocidad de búsqueda
3. **Estructura de Consultas**: Orden y lógica de operaciones
4. **Tipos de Datos**: Elección correcta para mejor rendimiento

### Técnicas de Consultas Complejas
- **CASE Statements**: Lógica condicional en consultas
- **Window Functions**: Análisis de datos por ventanas
- **CTEs (Common Table Expressions)**: Tablas temporales reutilizables
- **UNION/UNION ALL**: Combinar resultados de múltiples consultas

### Mejores Prácticas
- **Filtros tempranos**: Usar WHERE antes de JOINs
- **Índices apropiados**: En columnas de JOIN y WHERE
- **Evitar SELECT ***: Seleccionar solo columnas necesarias
- **Limitar resultados**: Usar LIMIT cuando sea apropiado

## 💡 Ejemplos Prácticos

### Ejemplo 1: Consulta Compleja con CASE
```sql
-- Análisis de productos por categoría y stock
SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    SUM(CASE 
        WHEN p.stock > 50 THEN 1 
        ELSE 0 
    END) AS productos_stock_alto,
    SUM(CASE 
        WHEN p.stock BETWEEN 20 AND 50 THEN 1 
        ELSE 0 
    END) AS productos_stock_medio,
    SUM(CASE 
        WHEN p.stock < 20 THEN 1 
        ELSE 0 
    END) AS productos_stock_bajo
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;
```

### Ejemplo 2: Window Functions
```sql
-- Ranking de productos por categoría
SELECT 
    p.nombre,
    p.precio,
    c.nombre AS categoria,
    ROW_NUMBER() OVER (PARTITION BY p.categoria_id ORDER BY p.precio DESC) AS ranking_precio,
    RANK() OVER (PARTITION BY p.categoria_id ORDER BY p.stock DESC) AS ranking_stock
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;
```

### Ejemplo 3: CTE (Common Table Expression)
```sql
-- Análisis de ventas por período
WITH ventas_periodo AS (
    SELECT 
        cliente_id,
        SUM(total) AS total_ventas,
        COUNT(*) AS total_pedidos
    FROM pedidos 
    WHERE fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY cliente_id
),
ranking_clientes AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_ventas DESC) AS ranking
    FROM ventas_periodo
)
SELECT * FROM ranking_clientes WHERE ranking <= 10;
```

### Ejemplo 4: UNION para Reportes Combinados
```sql
-- Resumen de productos por estado de stock
SELECT 'Stock Alto' AS estado, COUNT(*) AS cantidad
FROM productos WHERE stock > 50
UNION ALL
SELECT 'Stock Medio' AS estado, COUNT(*) AS cantidad
FROM productos WHERE stock BETWEEN 20 AND 50
UNION ALL
SELECT 'Stock Bajo' AS estado, COUNT(*) AS cantidad
FROM productos WHERE stock < 20;
```

### Ejemplo 5: EXPLAIN para Análisis de Rendimiento
```sql
-- Analizar el plan de ejecución
EXPLAIN SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    AVG(p.precio) AS precio_promedio
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
WHERE p.stock > 0
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 5;
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Tienda Online
Usando la base de datos `tienda_online`, escribe consultas complejas para:

1. Crear un reporte ejecutivo con métricas clave por categoría
2. Analizar el comportamiento de clientes por segmento de gasto
3. Generar un ranking de productos más rentables por categoría
4. Crear un análisis de tendencias de ventas por mes
5. Generar un reporte de productos con análisis de stock y ventas

**Solución:**
```sql
-- 1. Reporte ejecutivo por categoría
WITH metricas_categoria AS (
    SELECT 
        c.id,
        c.nombre AS categoria,
        COUNT(DISTINCT p.id) AS total_productos,
        SUM(pp.cantidad * pp.precio_unitario) AS total_ventas,
        COUNT(DISTINCT ped.cliente_id) AS clientes_unicos,
        AVG(pp.precio_unitario) AS precio_promedio
    FROM categorias c
    INNER JOIN productos p ON c.id = p.categoria_id
    LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
    LEFT JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
    GROUP BY c.id, c.nombre
)
SELECT 
    categoria,
    total_productos,
    total_ventas,
    clientes_unicos,
    precio_promedio,
    ROUND(total_ventas / total_productos, 2) AS rentabilidad_por_producto,
    CASE 
        WHEN total_ventas > 1000 THEN 'Alto Rendimiento'
        WHEN total_ventas > 500 THEN 'Medio Rendimiento'
        ELSE 'Bajo Rendimiento'
    END AS nivel_rendimiento
FROM metricas_categoria
ORDER BY total_ventas DESC;

-- 2. Análisis de clientes por segmento
SELECT 
    c.nombre,
    c.apellido,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado,
    AVG(p.total) AS promedio_por_pedido,
    CASE 
        WHEN SUM(p.total) > 1000 THEN 'Cliente Premium'
        WHEN SUM(p.total) > 500 THEN 'Cliente Regular'
        WHEN SUM(p.total) > 100 THEN 'Cliente Ocasional'
        ELSE 'Cliente Nuevo'
    END AS segmento_cliente,
    ROW_NUMBER() OVER (ORDER BY SUM(p.total) DESC) AS ranking_gasto
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido
HAVING total_gastado > 0;

-- 3. Ranking de productos rentables por categoría
SELECT 
    categoria,
    producto,
    precio,
    total_vendido,
    ingresos_totales,
    rentabilidad,
    ranking_categoria
FROM (
    SELECT 
        c.nombre AS categoria,
        p.nombre AS producto,
        p.precio,
        SUM(pp.cantidad) AS total_vendido,
        SUM(pp.cantidad * pp.precio_unitario) AS ingresos_totales,
        ROUND(SUM(pp.cantidad * pp.precio_unitario) / SUM(pp.cantidad), 2) AS rentabilidad,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY SUM(pp.cantidad * pp.precio_unitario) DESC) AS ranking_categoria
    FROM categorias c
    INNER JOIN productos p ON c.id = p.categoria_id
    INNER JOIN productos_pedido pp ON p.id = pp.producto_id
    INNER JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
    GROUP BY c.id, c.nombre, p.id, p.nombre, p.precio
) ranked
WHERE ranking_categoria <= 3;

-- 4. Análisis de tendencias por mes
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    COUNT(DISTINCT p.id) AS total_pedidos,
    COUNT(DISTINCT p.cliente_id) AS clientes_activos,
    SUM(p.total) AS total_ingresos,
    AVG(p.total) AS promedio_por_pedido,
    LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) AS ingresos_mes_anterior,
    ROUND(
        ((SUM(p.total) - LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) / 
         LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) * 100, 2
    ) AS crecimiento_porcentual
FROM pedidos p
WHERE p.estado = 'Completado'
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año, mes;

-- 5. Análisis de stock y ventas
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    p.stock,
    COALESCE(SUM(pp.cantidad), 0) AS total_vendido,
    p.precio,
    ROUND(COALESCE(SUM(pp.cantidad * pp.precio_unitario), 0), 2) AS ingresos_totales,
    CASE 
        WHEN p.stock = 0 THEN 'Sin Stock'
        WHEN p.stock < 10 THEN 'Stock Crítico'
        WHEN p.stock < 30 THEN 'Stock Bajo'
        WHEN p.stock < 50 THEN 'Stock Medio'
        ELSE 'Stock Alto'
    END AS estado_stock,
    CASE 
        WHEN COALESCE(SUM(pp.cantidad), 0) = 0 THEN 'Sin Ventas'
        WHEN COALESCE(SUM(pp.cantidad), 0) < 10 THEN 'Baja Demanda'
        WHEN COALESCE(SUM(pp.cantidad), 0) < 30 THEN 'Demanda Media'
        ELSE 'Alta Demanda'
    END AS nivel_demanda
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
LEFT JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
GROUP BY p.id, p.nombre, c.nombre, p.stock, p.precio
ORDER BY estado_stock, nivel_demanda;
```

### Ejercicio 2: Sistema de Biblioteca
Usando la base de datos `biblioteca_completa`, escribe consultas complejas para:

1. Crear un reporte de actividad de usuarios por nivel de actividad
2. Analizar patrones de préstamos por género y período
3. Generar un ranking de libros más populares por categoría
4. Crear un análisis de retrasos en devoluciones
5. Generar un reporte de autores con análisis de popularidad

**Solución:**
```sql
-- 1. Reporte de actividad de usuarios
SELECT 
    u.nombre,
    u.apellido,
    COUNT(p.id) AS total_prestamos,
    COUNT(DISTINCT p.libro_id) AS libros_diferentes,
    MAX(p.fecha_prestamo) AS ultimo_prestamo,
    CASE 
        WHEN COUNT(p.id) > 20 THEN 'Usuario Muy Activo'
        WHEN COUNT(p.id) > 10 THEN 'Usuario Activo'
        WHEN COUNT(p.id) > 5 THEN 'Usuario Regular'
        WHEN COUNT(p.id) > 0 THEN 'Usuario Ocasional'
        ELSE 'Usuario Inactivo'
    END AS nivel_actividad,
    ROW_NUMBER() OVER (ORDER BY COUNT(p.id) DESC) AS ranking_actividad
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.apellido;

-- 2. Análisis de patrones por género y período
SELECT 
    l.genero,
    MONTH(p.fecha_prestamo) AS mes,
    COUNT(*) AS total_prestamos,
    COUNT(DISTINCT p.usuario_id) AS usuarios_unicos,
    COUNT(DISTINCT p.libro_id) AS libros_prestados,
    AVG(DATEDIFF(COALESCE(p.fecha_devolucion, CURDATE()), p.fecha_prestamo)) AS promedio_dias_prestamo,
    ROUND(COUNT(*) / COUNT(DISTINCT p.usuario_id), 2) AS prestamos_por_usuario
FROM libros l
INNER JOIN prestamos p ON l.id = p.libro_id
WHERE YEAR(p.fecha_prestamo) = YEAR(CURDATE())
GROUP BY l.genero, MONTH(p.fecha_prestamo)
ORDER BY l.genero, mes;

-- 3. Ranking de libros populares por género
SELECT 
    genero,
    titulo,
    autor,
    veces_prestado,
    ranking_genero
FROM (
    SELECT 
        l.genero,
        l.titulo,
        CONCAT(a.nombre, ' ', a.apellido) AS autor,
        COUNT(p.id) AS veces_prestado,
        ROW_NUMBER() OVER (PARTITION BY l.genero ORDER BY COUNT(p.id) DESC) AS ranking_genero
    FROM libros l
    INNER JOIN autores a ON l.autor_id = a.id
    LEFT JOIN prestamos p ON l.id = p.libro_id
    GROUP BY l.id, l.genero, l.titulo, a.nombre, a.apellido
) ranked
WHERE ranking_genero <= 5;

-- 4. Análisis de retrasos en devoluciones
SELECT 
    u.nombre,
    u.apellido,
    l.titulo,
    p.fecha_prestamo,
    p.fecha_devolucion,
    DATEDIFF(CURDATE(), p.fecha_prestamo) AS dias_prestado,
    CASE 
        WHEN DATEDIFF(CURDATE(), p.fecha_prestamo) > 30 THEN 'Retraso Crítico'
        WHEN DATEDIFF(CURDATE(), p.fecha_prestamo) > 20 THEN 'Retraso Moderado'
        WHEN DATEDIFF(CURDATE(), p.fecha_prestamo) > 15 THEN 'Retraso Leve'
        ELSE 'En Tiempo'
    END AS estado_devolucion,
    ROUND(DATEDIFF(CURDATE(), p.fecha_prestamo) / 30, 1) AS meses_prestado
FROM prestamos p
INNER JOIN usuarios u ON p.usuario_id = u.id
INNER JOIN libros l ON p.libro_id = l.id
WHERE p.fecha_devolucion IS NULL
AND DATEDIFF(CURDATE(), p.fecha_prestamo) > 15
ORDER BY dias_prestado DESC;

-- 5. Análisis de popularidad de autores
WITH estadisticas_autor AS (
    SELECT 
        a.id,
        a.nombre,
        a.apellido,
        COUNT(DISTINCT l.id) AS total_libros,
        COUNT(p.id) AS total_prestamos,
        ROUND(COUNT(p.id) / COUNT(DISTINCT l.id), 2) AS prestamos_por_libro,
        AVG(DATEDIFF(COALESCE(p.fecha_devolucion, CURDATE()), p.fecha_prestamo)) AS promedio_dias_prestamo
    FROM autores a
    INNER JOIN libros l ON a.id = l.autor_id
    LEFT JOIN prestamos p ON l.id = p.libro_id
    GROUP BY a.id, a.nombre, a.apellido
)
SELECT 
    CONCAT(nombre, ' ', apellido) AS autor,
    total_libros,
    total_prestamos,
    prestamos_por_libro,
    promedio_dias_prestamo,
    CASE 
        WHEN total_prestamos > 50 THEN 'Autor Muy Popular'
        WHEN total_prestamos > 25 THEN 'Autor Popular'
        WHEN total_prestamos > 10 THEN 'Autor Moderado'
        ELSE 'Autor Poco Conocido'
    END AS nivel_popularidad,
    ROW_NUMBER() OVER (ORDER BY total_prestamos DESC) AS ranking_popularidad
FROM estadisticas_autor
ORDER BY total_prestamos DESC;
```

### Ejercicio 3: Sistema de Escuela
Usando la base de datos `escuela_completa`, escribe consultas complejas para:

1. Crear un reporte de rendimiento académico por estudiante
2. Analizar la distribución de calificaciones por curso y profesor
3. Generar un ranking de cursos por dificultad
4. Crear un análisis de progreso estudiantil por grado
5. Generar un reporte de profesores con métricas de enseñanza

**Solución:**
```sql
-- 1. Reporte de rendimiento académico
SELECT 
    e.nombre,
    e.apellido,
    e.grado,
    COUNT(i.curso_id) AS total_cursos,
    ROUND(AVG(i.calificacion), 2) AS promedio_general,
    MIN(i.calificacion) AS calificacion_minima,
    MAX(i.calificacion) AS calificacion_maxima,
    COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) AS cursos_aprobados,
    COUNT(CASE WHEN i.calificacion < 3.0 THEN 1 END) AS cursos_reprobados,
    ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS porcentaje_aprobacion,
    CASE 
        WHEN AVG(i.calificacion) >= 4.5 THEN 'Excelente'
        WHEN AVG(i.calificacion) >= 4.0 THEN 'Muy Bueno'
        WHEN AVG(i.calificacion) >= 3.5 THEN 'Bueno'
        WHEN AVG(i.calificacion) >= 3.0 THEN 'Aceptable'
        ELSE 'Necesita Mejorar'
    END AS nivel_rendimiento
FROM estudiantes e
LEFT JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.id, e.nombre, e.apellido, e.grado
ORDER BY promedio_general DESC;

-- 2. Distribución de calificaciones por curso y profesor
SELECT 
    c.nombre AS curso,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    p.especialidad,
    COUNT(i.estudiante_id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_curso,
    COUNT(CASE WHEN i.calificacion >= 4.5 THEN 1 END) AS excelentes,
    COUNT(CASE WHEN i.calificacion >= 4.0 AND i.calificacion < 4.5 THEN 1 END) AS muy_buenos,
    COUNT(CASE WHEN i.calificacion >= 3.5 AND i.calificacion < 4.0 THEN 1 END) AS buenos,
    COUNT(CASE WHEN i.calificacion >= 3.0 AND i.calificacion < 3.5 THEN 1 END) AS aceptables,
    COUNT(CASE WHEN i.calificacion < 3.0 THEN 1 END) AS reprobados,
    ROUND(STDDEV(i.calificacion), 2) AS desviacion_estandar
FROM cursos c
INNER JOIN profesores p ON c.profesor_id = p.id
INNER JOIN inscripciones i ON c.id = i.curso_id
GROUP BY c.id, c.nombre, p.id, p.nombre, p.apellido, p.especialidad
ORDER BY promedio_curso DESC;

-- 3. Ranking de cursos por dificultad
SELECT 
    curso,
    profesor,
    especialidad,
    total_estudiantes,
    promedio_calificaciones,
    tasa_aprobacion,
    ranking_dificultad
FROM (
    SELECT 
        c.nombre AS curso,
        CONCAT(p.nombre, ' ', p.apellido) AS profesor,
        p.especialidad,
        COUNT(i.estudiante_id) AS total_estudiantes,
        ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
        ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS tasa_aprobacion,
        ROW_NUMBER() OVER (ORDER BY AVG(i.calificacion)) AS ranking_dificultad
    FROM cursos c
    INNER JOIN profesores p ON c.profesor_id = p.id
    INNER JOIN inscripciones i ON c.id = i.curso_id
    GROUP BY c.id, c.nombre, p.id, p.nombre, p.apellido, p.especialidad
) ranked
ORDER BY ranking_dificultad;

-- 4. Análisis de progreso por grado
SELECT 
    grado,
    total_estudiantes,
    promedio_general_grado,
    cursos_promedio,
    tasa_aprobacion_grado,
    ranking_grado
FROM (
    SELECT 
        e.grado,
        COUNT(DISTINCT e.id) AS total_estudiantes,
        ROUND(AVG(i.calificacion), 2) AS promedio_general_grado,
        ROUND(AVG(cursos_por_estudiante), 1) AS cursos_promedio,
        ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS tasa_aprobacion_grado,
        ROW_NUMBER() OVER (ORDER BY AVG(i.calificacion) DESC) AS ranking_grado
    FROM estudiantes e
    INNER JOIN inscripciones i ON e.id = i.estudiante_id
    INNER JOIN (
        SELECT estudiante_id, COUNT(*) AS cursos_por_estudiante
        FROM inscripciones
        GROUP BY estudiante_id
    ) cursos_est ON e.id = cursos_est.estudiante_id
    GROUP BY e.grado
) ranked
ORDER BY ranking_grado;

-- 5. Métricas de enseñanza por profesor
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    p.especialidad,
    COUNT(DISTINCT c.id) AS total_cursos,
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS tasa_aprobacion,
    ROUND(STDDEV(i.calificacion), 2) AS desviacion_estandar,
    CASE 
        WHEN AVG(i.calificacion) >= 4.0 THEN 'Excelente Docente'
        WHEN AVG(i.calificacion) >= 3.5 THEN 'Buen Docente'
        WHEN AVG(i.calificacion) >= 3.0 THEN 'Docente Aceptable'
        ELSE 'Necesita Mejorar'
    END AS evaluacion_docente,
    ROW_NUMBER() OVER (ORDER BY AVG(i.calificacion) DESC) AS ranking_docente
FROM profesores p
INNER JOIN cursos c ON p.id = c.profesor_id
INNER JOIN inscripciones i ON c.id = i.curso_id
GROUP BY p.id, p.nombre, p.apellido, p.especialidad
ORDER BY promedio_calificaciones DESC;
```

### Ejercicio 4: Sistema de Restaurante
Usando la base de datos `restaurante_completo`, escribe consultas complejas para:

1. Crear un reporte de rendimiento por mesa y período
2. Analizar patrones de consumo por categoría y hora
3. Generar un ranking de platos más rentables
4. Crear un análisis de ocupación de mesas por día
5. Generar un reporte de tendencias de ventas por temporada

**Solución:**
```sql
-- 1. Reporte de rendimiento por mesa
SELECT 
    m.numero AS mesa,
    m.capacidad,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    ROUND(SUM(p.total) / COUNT(p.id), 2) AS rentabilidad_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido,
    CASE 
        WHEN SUM(p.total) > 1000 THEN 'Mesa Muy Rentable'
        WHEN SUM(p.total) > 500 THEN 'Mesa Rentable'
        WHEN SUM(p.total) > 200 THEN 'Mesa Regular'
        ELSE 'Mesa Poco Rentable'
    END AS nivel_rentabilidad,
    ROW_NUMBER() OVER (ORDER BY SUM(p.total) DESC) AS ranking_rentabilidad
FROM mesas m
LEFT JOIN pedidos p ON m.id = p.mesa_id AND p.estado = 'Completado'
GROUP BY m.id, m.numero, m.capacidad
ORDER BY total_ingresos DESC;

-- 2. Patrones de consumo por categoría y hora
SELECT 
    c.nombre AS categoria,
    HOUR(p.fecha_pedido) AS hora,
    COUNT(*) AS total_pedidos,
    COUNT(DISTINCT p.mesa_id) AS mesas_activas,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    ROUND(SUM(p.total) / COUNT(*), 2) AS ingresos_por_pedido
FROM categorias_platos c
INNER JOIN platos pl ON c.id = pl.categoria_id
INNER JOIN platos_pedido pp ON pl.id = pp.plato_id
INNER JOIN pedidos p ON pp.pedido_id = p.id
WHERE p.estado = 'Completado'
GROUP BY c.id, c.nombre, HOUR(p.fecha_pedido)
ORDER BY c.nombre, hora;

-- 3. Ranking de platos más rentables
SELECT 
    plato,
    categoria,
    precio,
    total_vendido,
    ingresos_totales,
    margen_rentabilidad,
    ranking_rentabilidad
FROM (
    SELECT 
        p.nombre AS plato,
        c.nombre AS categoria,
        p.precio,
        SUM(pp.cantidad) AS total_vendido,
        SUM(pp.cantidad * pp.precio_unitario) AS ingresos_totales,
        ROUND(((SUM(pp.cantidad * pp.precio_unitario) - (SUM(pp.cantidad) * p.precio)) / SUM(pp.cantidad * pp.precio_unitario)) * 100, 2) AS margen_rentabilidad,
        ROW_NUMBER() OVER (ORDER BY SUM(pp.cantidad * pp.precio_unitario) DESC) AS ranking_rentabilidad
    FROM platos p
    INNER JOIN categorias_platos c ON p.categoria_id = c.id
    INNER JOIN platos_pedido pp ON p.id = pp.plato_id
    INNER JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
    GROUP BY p.id, p.nombre, c.nombre, p.precio
) ranked
WHERE ranking_rentabilidad <= 10;

-- 4. Análisis de ocupación por día
SELECT 
    DAYNAME(p.fecha_pedido) AS dia_semana,
    COUNT(DISTINCT p.mesa_id) AS mesas_ocupadas,
    COUNT(DISTINCT m.id) AS total_mesas,
    ROUND((COUNT(DISTINCT p.mesa_id) / COUNT(DISTINCT m.id)) * 100, 1) AS porcentaje_ocupacion,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    CASE 
        WHEN (COUNT(DISTINCT p.mesa_id) / COUNT(DISTINCT m.id)) > 0.8 THEN 'Alta Ocupación'
        WHEN (COUNT(DISTINCT p.mesa_id) / COUNT(DISTINCT m.id)) > 0.5 THEN 'Media Ocupación'
        ELSE 'Baja Ocupación'
    END AS nivel_ocupacion
FROM pedidos p
CROSS JOIN mesas m
WHERE p.estado = 'Completado'
GROUP BY DAYNAME(p.fecha_pedido)
ORDER BY porcentaje_ocupacion DESC;

-- 5. Análisis de tendencias por temporada
SELECT 
    CASE 
        WHEN MONTH(p.fecha_pedido) IN (12, 1, 2) THEN 'Invierno'
        WHEN MONTH(p.fecha_pedido) IN (3, 4, 5) THEN 'Primavera'
        WHEN MONTH(p.fecha_pedido) IN (6, 7, 8) THEN 'Verano'
        ELSE 'Otoño'
    END AS temporada,
    COUNT(DISTINCT p.id) AS total_pedidos,
    COUNT(DISTINCT p.mesa_id) AS mesas_activas,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    COUNT(DISTINCT pp.plato_id) AS platos_diferentes,
    ROUND(SUM(p.total) / COUNT(DISTINCT p.mesa_id), 2) AS ingresos_por_mesa
FROM pedidos p
INNER JOIN platos_pedido pp ON p.id = pp.pedido_id
WHERE p.estado = 'Completado'
GROUP BY 
    CASE 
        WHEN MONTH(p.fecha_pedido) IN (12, 1, 2) THEN 'Invierno'
        WHEN MONTH(p.fecha_pedido) IN (3, 4, 5) THEN 'Primavera'
        WHEN MONTH(p.fecha_pedido) IN (6, 7, 8) THEN 'Verano'
        ELSE 'Otoño'
    END
ORDER BY total_ingresos DESC;
```

### Ejercicio 5: Sistema de Hospital
Usando la base de datos `hospital_completo`, escribe consultas complejas para:

1. Crear un reporte de actividad médica por especialidad
2. Analizar patrones de citas por día y hora
3. Generar un ranking de doctores por eficiencia
4. Crear un análisis de costos por paciente y tratamiento
5. Generar un reporte de ocupación de consultorios

**Solución:**
```sql
-- 1. Reporte de actividad por especialidad
SELECT 
    d.especialidad,
    COUNT(DISTINCT d.id) AS total_doctores,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.paciente_id) AS pacientes_unicos,
    ROUND(COUNT(c.id) / COUNT(DISTINCT d.id), 1) AS citas_por_doctor,
    ROUND(COUNT(c.id) / COUNT(DISTINCT c.paciente_id), 1) AS citas_por_paciente,
    SUM(t.costo) AS total_ingresos,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    CASE 
        WHEN COUNT(c.id) > 100 THEN 'Especialidad Muy Activa'
        WHEN COUNT(c.id) > 50 THEN 'Especialidad Activa'
        WHEN COUNT(c.id) > 20 THEN 'Especialidad Moderada'
        ELSE 'Especialidad Poco Activa'
    END AS nivel_actividad
FROM doctores d
LEFT JOIN citas c ON d.id = c.doctor_id
LEFT JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
LEFT JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY d.especialidad
ORDER BY total_citas DESC;

-- 2. Patrones de citas por día y hora
SELECT 
    DAYNAME(c.fecha_cita) AS dia_semana,
    HOUR(c.fecha_cita) AS hora,
    COUNT(*) AS total_citas,
    COUNT(DISTINCT c.doctor_id) AS doctores_activos,
    COUNT(DISTINCT c.paciente_id) AS pacientes_atendidos,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    SUM(t.costo) AS total_ingresos_hora
FROM citas c
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY DAYNAME(c.fecha_cita), HOUR(c.fecha_cita)
ORDER BY dia_semana, hora;

-- 3. Ranking de doctores por eficiencia
SELECT 
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,
    d.especialidad,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.paciente_id) AS pacientes_unicos,
    ROUND(COUNT(c.id) / COUNT(DISTINCT c.paciente_id), 1) AS citas_por_paciente,
    SUM(t.costo) AS total_ingresos,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    ROUND(SUM(t.costo) / COUNT(c.id), 2) AS ingresos_por_cita,
    CASE 
        WHEN COUNT(c.id) > 50 THEN 'Doctor Muy Eficiente'
        WHEN COUNT(c.id) > 30 THEN 'Doctor Eficiente'
        WHEN COUNT(c.id) > 15 THEN 'Doctor Moderado'
        ELSE 'Doctor Poco Eficiente'
    END AS nivel_eficiencia,
    ROW_NUMBER() OVER (ORDER BY COUNT(c.id) DESC) AS ranking_eficiencia
FROM doctores d
INNER JOIN citas c ON d.id = c.doctor_id
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY d.id, d.nombre, d.apellido, d.especialidad
ORDER BY total_citas DESC;

-- 4. Análisis de costos por paciente
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS paciente,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.doctor_id) AS doctores_consultados,
    COUNT(DISTINCT t.id) AS tratamientos_diferentes,
    SUM(t.costo) AS total_gastado,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    ROUND(SUM(t.costo) / COUNT(c.id), 2) AS costo_promedio_por_cita,
    CASE 
        WHEN SUM(t.costo) > 1000 THEN 'Paciente de Alto Costo'
        WHEN SUM(t.costo) > 500 THEN 'Paciente de Costo Medio'
        WHEN SUM(t.costo) > 200 THEN 'Paciente de Costo Bajo'
        ELSE 'Paciente de Muy Bajo Costo'
    END AS categoria_costo,
    ROW_NUMBER() OVER (ORDER BY SUM(t.costo) DESC) AS ranking_costo
FROM pacientes p
INNER JOIN citas c ON p.id = c.paciente_id
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY p.id, p.nombre, p.apellido
ORDER BY total_gastado DESC;

-- 5. Reporte de ocupación de consultorios
WITH ocupacion_consultorio AS (
    SELECT 
        d.id AS doctor_id,
        d.nombre,
        d.apellido,
        d.especialidad,
        COUNT(c.id) AS total_citas,
        COUNT(DISTINCT DATE(c.fecha_cita)) AS dias_trabajados,
        ROUND(COUNT(c.id) / COUNT(DISTINCT DATE(c.fecha_cita)), 1) AS citas_por_dia,
        SUM(t.costo) AS total_ingresos,
        ROUND(SUM(t.costo) / COUNT(DISTINCT DATE(c.fecha_cita)), 2) AS ingresos_por_dia
    FROM doctores d
    LEFT JOIN citas c ON d.id = c.doctor_id
    LEFT JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
    LEFT JOIN tratamientos t ON ta.tratamiento_id = t.id
    GROUP BY d.id, d.nombre, d.apellido, d.especialidad
)
SELECT 
    CONCAT(nombre, ' ', apellido) AS doctor,
    especialidad,
    total_citas,
    dias_trabajados,
    citas_por_dia,
    total_ingresos,
    ingresos_por_dia,
    CASE 
        WHEN citas_por_dia > 8 THEN 'Consultorio Muy Ocupado'
        WHEN citas_por_dia > 5 THEN 'Consultorio Ocupado'
        WHEN citas_por_dia > 3 THEN 'Consultorio Moderado'
        ELSE 'Consultorio Poco Ocupado'
    END AS nivel_ocupacion,
    ROW_NUMBER() OVER (ORDER BY citas_por_dia DESC) AS ranking_ocupacion
FROM ocupacion_consultorio
ORDER BY citas_por_dia DESC;
```

## 📝 Resumen de Conceptos Clave
- ✅ Las consultas complejas combinan múltiples conceptos SQL
- ✅ CASE statements permiten lógica condicional en consultas
- ✅ Window functions analizan datos por ventanas
- ✅ CTEs crean tablas temporales reutilizables
- ✅ EXPLAIN analiza el plan de ejecución de consultas
- ✅ La optimización mejora el rendimiento de las consultas
- ✅ Las consultas complejas son esenciales para reportes empresariales

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/midLevel_5` para aprender sobre vistas e índices.

---

**💡 Consejo: Practica creando consultas complejas que combinen múltiples conceptos. Son la base para reportes empresariales avanzados y análisis de datos complejos.**
