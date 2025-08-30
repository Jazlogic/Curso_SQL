# 🔶 Mid-Level 5: Vistas e Índices

## 📖 Teoría

### ¿Qué son las Vistas?
Las vistas son consultas SQL almacenadas que se comportan como tablas virtuales. Permiten simplificar consultas complejas, mejorar la seguridad y proporcionar una capa de abstracción sobre los datos.

### Tipos de Vistas
1. **Vistas Simples**: Basadas en una sola tabla
2. **Vistas Complejas**: Basadas en múltiples tablas con JOINs
3. **Vistas Materializadas**: Almacenan físicamente los resultados
4. **Vistas Actualizables**: Permiten INSERT, UPDATE, DELETE

### ¿Qué son los Índices?
Los índices son estructuras de datos que mejoran la velocidad de búsqueda en las bases de datos. Son fundamentales para optimizar el rendimiento de consultas.

### Tipos de Índices
1. **Índices Simples**: En una sola columna
2. **Índices Compuestos**: En múltiples columnas
3. **Índices Únicos**: Garantizan valores únicos
4. **Índices de Texto**: Para búsquedas de texto completo

### Beneficios de Vistas e Índices
- **Vistas**: Simplificación, seguridad, mantenibilidad
- **Índices**: Rendimiento, velocidad de búsqueda, optimización

## 💡 Ejemplos Prácticos

### Ejemplo 1: Crear Vista Simple
```sql
-- Vista de productos con información de categoría
CREATE VIEW vista_productos_categoria AS
SELECT 
    p.id,
    p.nombre,
    p.precio,
    p.stock,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Usar la vista
SELECT * FROM vista_productos_categoria WHERE stock > 10;
```

### Ejemplo 2: Crear Vista Compleja
```sql
-- Vista de resumen de ventas por cliente
CREATE VIEW vista_resumen_ventas_cliente AS
SELECT 
    c.id,
    c.nombre,
    c.apellido,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado,
    AVG(p.total) AS promedio_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido;

-- Usar la vista
SELECT * FROM vista_resumen_ventas_cliente WHERE total_gastado > 500;
```

### Ejemplo 3: Crear Índices
```sql
-- Índice simple en columna de búsqueda frecuente
CREATE INDEX idx_productos_nombre ON productos(nombre);

-- Índice compuesto en múltiples columnas
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);

-- Índice único en email
CREATE UNIQUE INDEX idx_clientes_email ON clientes(email);
```

### Ejemplo 4: Vista con Funciones Agregadas
```sql
-- Vista de estadísticas por categoría
CREATE VIEW vista_estadisticas_categoria AS
SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    AVG(p.precio) AS precio_promedio,
    SUM(p.stock) AS stock_total,
    MIN(p.precio) AS precio_minimo,
    MAX(p.precio) AS precio_maximo
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;

-- Usar la vista
SELECT * FROM vista_estadisticas_categoria ORDER BY total_productos DESC;
```

### Ejemplo 5: Vista Actualizable
```sql
-- Vista actualizable de productos básicos
CREATE VIEW vista_productos_basicos AS
SELECT id, nombre, precio, stock
FROM productos
WHERE stock > 0;

-- Insertar a través de la vista
INSERT INTO vista_productos_basicos (nombre, precio, stock) 
VALUES ('Nuevo Producto', 99.99, 50);
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Tienda Online
Usando la base de datos `tienda_online`, crea vistas e índices para:

1. Crear una vista de productos con información completa
2. Crear una vista de resumen de ventas por período
3. Crear una vista de clientes con análisis de comportamiento
4. Crear índices para optimizar consultas frecuentes
5. Crear una vista de inventario con alertas de stock

**Solución:**
```sql
-- 1. Vista de productos con información completa
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id,
    p.nombre,
    p.precio,
    p.stock,
    c.nombre AS categoria,
    c.descripcion AS descripcion_categoria,
    COALESCE(SUM(pp.cantidad), 0) AS total_vendido,
    COALESCE(SUM(pp.cantidad * pp.precio_unitario), 0) AS ingresos_totales,
    CASE 
        WHEN p.stock = 0 THEN 'Sin Stock'
        WHEN p.stock < 10 THEN 'Stock Crítico'
        WHEN p.stock < 30 THEN 'Stock Bajo'
        WHEN p.stock < 50 THEN 'Stock Medio'
        ELSE 'Stock Alto'
    END AS estado_stock
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
LEFT JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
GROUP BY p.id, p.nombre, p.precio, p.stock, c.nombre, c.descripcion;

-- 2. Vista de resumen de ventas por período
CREATE VIEW vista_ventas_periodo AS
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    MONTHNAME(p.fecha_pedido) AS nombre_mes,
    COUNT(DISTINCT p.id) AS total_pedidos,
    COUNT(DISTINCT p.cliente_id) AS clientes_activos,
    SUM(p.total) AS total_ingresos,
    AVG(p.total) AS promedio_por_pedido,
    COUNT(DISTINCT pp.producto_id) AS productos_vendidos
FROM pedidos p
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
WHERE p.estado = 'Completado'
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido), MONTHNAME(p.fecha_pedido);

-- 3. Vista de clientes con análisis de comportamiento
CREATE VIEW vista_analisis_clientes AS
SELECT 
    c.id,
    c.nombre,
    c.apellido,
    c.email,
    c.fecha_registro,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado,
    AVG(p.total) AS promedio_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido,
    DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_desde_ultimo_pedido,
    CASE 
        WHEN SUM(p.total) > 1000 THEN 'Cliente Premium'
        WHEN SUM(p.total) > 500 THEN 'Cliente Regular'
        WHEN SUM(p.total) > 100 THEN 'Cliente Ocasional'
        ELSE 'Cliente Nuevo'
    END AS segmento_cliente
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido, c.email, c.fecha_registro;

-- 4. Índices para optimizar consultas
-- Índice en productos por nombre (búsquedas frecuentes)
CREATE INDEX idx_productos_nombre ON productos(nombre);

-- Índice compuesto en pedidos por cliente y fecha
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);

-- Índice en productos por categoría y precio
CREATE INDEX idx_productos_categoria_precio ON productos(categoria_id, precio);

-- Índice en productos_pedido por producto y pedido
CREATE INDEX idx_productos_pedido_producto_pedido ON productos_pedido(producto_id, pedido_id);

-- 5. Vista de inventario con alertas
CREATE VIEW vista_inventario_alertas AS
SELECT 
    p.id,
    p.nombre,
    p.precio,
    p.stock,
    c.nombre AS categoria,
    COALESCE(SUM(pp.cantidad), 0) AS ventas_mes_actual,
    CASE 
        WHEN p.stock = 0 THEN 'URGENTE: Sin Stock'
        WHEN p.stock < 10 AND COALESCE(SUM(pp.cantidad), 0) > 5 THEN 'ALERTA: Stock Bajo + Alta Demanda'
        WHEN p.stock < 20 THEN 'ADVERTENCIA: Stock Bajo'
        WHEN p.stock > 100 AND COALESCE(SUM(pp.cantidad), 0) < 2 THEN 'INFO: Stock Alto + Baja Demanda'
        ELSE 'NORMAL'
    END AS alerta_stock,
    ROUND(p.stock / NULLIF(COALESCE(SUM(pp.cantidad), 1), 0), 1) AS meses_stock_disponible
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
LEFT JOIN pedidos ped ON pp.pedido_id = ped.id 
    AND ped.estado = 'Completado' 
    AND ped.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.id, p.nombre, p.precio, p.stock, c.nombre;
```

### Ejercicio 2: Sistema de Biblioteca
Usando la base de datos `biblioteca_completa`, crea vistas e índices para:

1. Crear una vista de libros con información de autor y popularidad
2. Crear una vista de usuarios con análisis de actividad
3. Crear una vista de préstamos con información completa
4. Crear índices para optimizar consultas de préstamos
5. Crear una vista de estadísticas de la biblioteca

**Solución:**
```sql
-- 1. Vista de libros con información completa
CREATE VIEW vista_libros_completa AS
SELECT 
    l.id,
    l.titulo,
    l.isbn,
    l.genero,
    l.año_publicacion,
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    a.pais AS pais_autor,
    COUNT(p.id) AS veces_prestado,
    AVG(DATEDIFF(COALESCE(p.fecha_devolucion, CURDATE()), p.fecha_prestamo)) AS promedio_dias_prestamo,
    CASE 
        WHEN COUNT(p.id) > 20 THEN 'Muy Popular'
        WHEN COUNT(p.id) > 10 THEN 'Popular'
        WHEN COUNT(p.id) > 5 THEN 'Moderado'
        WHEN COUNT(p.id) > 0 THEN 'Poco Popular'
        ELSE 'Sin Préstamos'
    END AS nivel_popularidad
FROM libros l
INNER JOIN autores a ON l.autor_id = a.id
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY l.id, l.titulo, l.isbn, l.genero, l.año_publicacion, a.nombre, a.apellido, a.pais;

-- 2. Vista de usuarios con análisis de actividad
CREATE VIEW vista_analisis_usuarios AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.fecha_registro,
    COUNT(p.id) AS total_prestamos,
    COUNT(DISTINCT p.libro_id) AS libros_diferentes,
    COUNT(DISTINCT l.genero) AS generos_explorados,
    MAX(p.fecha_prestamo) AS ultimo_prestamo,
    DATEDIFF(CURDATE(), MAX(p.fecha_prestamo)) AS dias_desde_ultimo_prestamo,
    CASE 
        WHEN COUNT(p.id) > 30 THEN 'Usuario Muy Activo'
        WHEN COUNT(p.id) > 15 THEN 'Usuario Activo'
        WHEN COUNT(p.id) > 5 THEN 'Usuario Regular'
        WHEN COUNT(p.id) > 0 THEN 'Usuario Ocasional'
        ELSE 'Usuario Inactivo'
    END AS nivel_actividad
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
LEFT JOIN libros l ON p.libro_id = l.id
GROUP BY u.id, u.nombre, u.apellido, u.email, u.fecha_registro;

-- 3. Vista de préstamos con información completa
CREATE VIEW vista_prestamos_completa AS
SELECT 
    p.id,
    u.nombre AS nombre_usuario,
    u.apellido AS apellido_usuario,
    l.titulo AS titulo_libro,
    l.genero AS genero_libro,
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    p.fecha_prestamo,
    p.fecha_devolucion,
    p.estado,
    DATEDIFF(COALESCE(p.fecha_devolucion, CURDATE()), p.fecha_prestamo) AS dias_prestado,
    CASE 
        WHEN p.fecha_devolucion IS NULL AND DATEDIFF(CURDATE(), p.fecha_prestamo) > 30 THEN 'Retraso Crítico'
        WHEN p.fecha_devolucion IS NULL AND DATEDIFF(CURDATE(), p.fecha_prestamo) > 20 THEN 'Retraso Moderado'
        WHEN p.fecha_devolucion IS NULL AND DATEDIFF(CURDATE(), p.fecha_prestamo) > 15 THEN 'Retraso Leve'
        WHEN p.fecha_devolucion IS NULL THEN 'En Préstamo'
        ELSE 'Devuelto'
    END AS estado_prestamo
FROM prestamos p
INNER JOIN usuarios u ON p.usuario_id = u.id
INNER JOIN libros l ON p.libro_id = l.id
INNER JOIN autores a ON l.autor_id = a.id;

-- 4. Índices para optimizar consultas
-- Índice en libros por título (búsquedas frecuentes)
CREATE INDEX idx_libros_titulo ON libros(titulo);

-- Índice en libros por género y año
CREATE INDEX idx_libros_genero_año ON libros(genero, año_publicacion);

-- Índice en préstamos por usuario y fecha
CREATE INDEX idx_prestamos_usuario_fecha ON prestamos(usuario_id, fecha_prestamo);

-- Índice en préstamos por libro y estado
CREATE INDEX idx_prestamos_libro_estado ON prestamos(libro_id, estado);

-- Índice en usuarios por email (búsquedas de login)
CREATE UNIQUE INDEX idx_usuarios_email ON usuarios(email);

-- 5. Vista de estadísticas de la biblioteca
CREATE VIEW vista_estadisticas_biblioteca AS
SELECT 
    'Total Libros' AS metric,
    COUNT(*) AS valor
FROM libros
UNION ALL
SELECT 
    'Total Usuarios' AS metric,
    COUNT(*) AS valor
FROM usuarios
UNION ALL
SELECT 
    'Total Préstamos Activos' AS metric,
    COUNT(*) AS valor
FROM prestamos
WHERE estado = 'Prestado'
UNION ALL
SELECT 
    'Total Autores' AS metric,
    COUNT(*) AS valor
FROM autores
UNION ALL
SELECT 
    'Libros Más Prestados' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT libro_id
    FROM prestamos
    GROUP BY libro_id
    HAVING COUNT(*) > 10
) libros_populares
UNION ALL
SELECT 
    'Usuarios Más Activos' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT usuario_id
    FROM prestamos
    GROUP BY usuario_id
    HAVING COUNT(*) > 20
) usuarios_activos;
```

### Ejercicio 3: Sistema de Escuela
Usando la base de datos `escuela_completa`, crea vistas e índices para:

1. Crear una vista de estudiantes con rendimiento académico
2. Crear una vista de cursos con estadísticas de calificaciones
3. Crear una vista de profesores con métricas de enseñanza
4. Crear índices para optimizar consultas académicas
5. Crear una vista de reporte académico general

**Solución:**
```sql
-- 1. Vista de estudiantes con rendimiento académico
CREATE VIEW vista_rendimiento_estudiantes AS
SELECT 
    e.id,
    e.nombre,
    e.apellido,
    e.grado,
    e.email,
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
GROUP BY e.id, e.nombre, e.apellido, e.grado, e.email;

-- 2. Vista de cursos con estadísticas
CREATE VIEW vista_estadisticas_cursos AS
SELECT 
    c.id,
    c.nombre AS curso,
    c.creditos,
    c.horario,
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    p.especialidad,
    COUNT(i.estudiante_id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    MIN(i.calificacion) AS calificacion_minima,
    MAX(i.calificacion) AS calificacion_maxima,
    COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) AS estudiantes_aprobados,
    COUNT(CASE WHEN i.calificacion < 3.0 THEN 1 END) AS estudiantes_reprobados,
    ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS tasa_aprobacion,
    ROUND(STDDEV(i.calificacion), 2) AS desviacion_estandar,
    CASE 
        WHEN AVG(i.calificacion) >= 4.0 THEN 'Curso Fácil'
        WHEN AVG(i.calificacion) >= 3.5 THEN 'Curso Moderado'
        WHEN AVG(i.calificacion) >= 3.0 THEN 'Curso Difícil'
        ELSE 'Curso Muy Difícil'
    END AS nivel_dificultad
FROM cursos c
INNER JOIN profesores p ON c.profesor_id = p.id
LEFT JOIN inscripciones i ON c.id = i.curso_id
GROUP BY c.id, c.nombre, c.creditos, c.horario, p.nombre, p.apellido, p.especialidad;

-- 3. Vista de profesores con métricas
CREATE VIEW vista_metricas_profesores AS
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    p.especialidad,
    p.email,
    COUNT(DISTINCT c.id) AS total_cursos,
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    ROUND((COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS tasa_aprobacion,
    ROUND(STDDEV(i.calificacion), 2) AS desviacion_estandar,
    COUNT(CASE WHEN i.calificacion >= 4.5 THEN 1 END) AS calificaciones_excelentes,
    COUNT(CASE WHEN i.calificacion < 3.0 THEN 1 END) AS calificaciones_reprobadas,
    CASE 
        WHEN AVG(i.calificacion) >= 4.0 THEN 'Excelente Docente'
        WHEN AVG(i.calificacion) >= 3.5 THEN 'Buen Docente'
        WHEN AVG(i.calificacion) >= 3.0 THEN 'Docente Aceptable'
        ELSE 'Necesita Mejorar'
    END AS evaluacion_docente
FROM profesores p
LEFT JOIN cursos c ON p.id = c.profesor_id
LEFT JOIN inscripciones i ON c.id = i.curso_id
GROUP BY p.id, p.nombre, p.apellido, p.especialidad, p.email;

-- 4. Índices para optimizar consultas académicas
-- Índice en estudiantes por grado
CREATE INDEX idx_estudiantes_grado ON estudiantes(grado);

-- Índice en inscripciones por estudiante y curso
CREATE INDEX idx_inscripciones_estudiante_curso ON inscripciones(estudiante_id, curso_id);

-- Índice en inscripciones por calificación
CREATE INDEX idx_inscripciones_calificacion ON inscripciones(calificacion);

-- Índice en cursos por profesor
CREATE INDEX idx_cursos_profesor ON cursos(profesor_id);

-- Índice en profesores por especialidad
CREATE INDEX idx_profesores_especialidad ON profesores(especialidad);

-- 5. Vista de reporte académico general
CREATE VIEW vista_reporte_academico_general AS
SELECT 
    'Total Estudiantes' AS metric,
    COUNT(*) AS valor
FROM estudiantes
UNION ALL
SELECT 
    'Total Profesores' AS metric,
    COUNT(*) AS valor
FROM profesores
UNION ALL
SELECT 
    'Total Cursos' AS metric,
    COUNT(*) AS valor
FROM cursos
UNION ALL
SELECT 
    'Total Inscripciones' AS metric,
    COUNT(*) AS valor
FROM inscripciones
UNION ALL
SELECT 
    'Promedio General' AS metric,
    ROUND(AVG(calificacion), 2) AS valor
FROM inscripciones
UNION ALL
SELECT 
    'Tasa de Aprobación' AS metric,
    ROUND((COUNT(CASE WHEN calificacion >= 3.0 THEN 1 END) / COUNT(*)) * 100, 1) AS valor
FROM inscripciones
UNION ALL
SELECT 
    'Estudiantes con Promedio Alto' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT estudiante_id
    FROM inscripciones
    GROUP BY estudiante_id
    HAVING AVG(calificacion) >= 4.0
) estudiantes_alto_rendimiento
UNION ALL
SELECT 
    'Cursos con Mayor Aprobación' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT curso_id
    FROM inscripciones
    GROUP BY curso_id
    HAVING (COUNT(CASE WHEN calificacion >= 3.0 THEN 1 END) / COUNT(*)) > 0.8
) cursos_alta_aprobacion;
```

### Ejercicio 4: Sistema de Restaurante
Usando la base de datos `restaurante_completo`, crea vistas e índices para:

1. Crear una vista de platos con información de ventas
2. Crear una vista de mesas con análisis de rendimiento
3. Crear una vista de pedidos con información completa
4. Crear índices para optimizar consultas de pedidos
5. Crear una vista de reporte de ventas

**Solución:**
```sql
-- 1. Vista de platos con información de ventas
CREATE VIEW vista_platos_ventas AS
SELECT 
    p.id,
    p.nombre AS plato,
    p.precio,
    p.descripcion,
    c.nombre AS categoria,
    c.descripcion AS descripcion_categoria,
    p.disponible,
    COALESCE(SUM(pp.cantidad), 0) AS total_vendido,
    COALESCE(SUM(pp.cantidad * pp.precio_unitario), 0) AS ingresos_totales,
    ROUND(COALESCE(AVG(pp.precio_unitario), p.precio), 2) AS precio_promedio_vendido,
    CASE 
        WHEN COALESCE(SUM(pp.cantidad), 0) > 50 THEN 'Muy Popular'
        WHEN COALESCE(SUM(pp.cantidad), 0) > 25 THEN 'Popular'
        WHEN COALESCE(SUM(pp.cantidad), 0) > 10 THEN 'Moderado'
        WHEN COALESCE(SUM(pp.cantidad), 0) > 0 THEN 'Poco Popular'
        ELSE 'Sin Ventas'
    END AS nivel_popularidad
FROM platos p
INNER JOIN categorias_platos c ON p.categoria_id = c.id
LEFT JOIN platos_pedido pp ON p.id = pp.plato_id
LEFT JOIN pedidos ped ON pp.pedido_id = ped.id AND ped.estado = 'Completado'
GROUP BY p.id, p.nombre, p.precio, p.descripcion, c.nombre, c.descripcion, p.disponible;

-- 2. Vista de mesas con análisis de rendimiento
CREATE VIEW vista_rendimiento_mesas AS
SELECT 
    m.id,
    m.numero AS mesa,
    m.capacidad,
    m.estado AS estado_actual,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    ROUND(SUM(p.total) / COUNT(p.id), 2) AS rentabilidad_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido,
    DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_desde_ultimo_pedido,
    CASE 
        WHEN SUM(p.total) > 1000 THEN 'Mesa Muy Rentable'
        WHEN SUM(p.total) > 500 THEN 'Mesa Rentable'
        WHEN SUM(p.total) > 200 THEN 'Mesa Regular'
        WHEN SUM(p.total) > 0 THEN 'Mesa Poco Rentable'
        ELSE 'Mesa Sin Uso'
    END AS nivel_rentabilidad
FROM mesas m
LEFT JOIN pedidos p ON m.id = p.mesa_id AND p.estado = 'Completado'
GROUP BY m.id, m.numero, m.capacidad, m.estado;

-- 3. Vista de pedidos con información completa
CREATE VIEW vista_pedidos_completa AS
SELECT 
    p.id,
    m.numero AS mesa,
    m.capacidad,
    p.fecha_pedido,
    p.total,
    p.estado,
    COUNT(pp.plato_id) AS total_platos,
    COUNT(DISTINCT pp.plato_id) AS platos_diferentes,
    GROUP_CONCAT(pl.nombre SEPARATOR ', ') AS platos_ordenados,
    ROUND(p.total / COUNT(pp.plato_id), 2) AS promedio_por_plato,
    CASE 
        WHEN p.total > 100 THEN 'Pedido Grande'
        WHEN p.total > 50 THEN 'Pedido Mediano'
        WHEN p.total > 20 THEN 'Pedido Pequeño'
        ELSE 'Pedido Mínimo'
    END AS tipo_pedido
FROM pedidos p
INNER JOIN mesas m ON p.mesa_id = m.id
INNER JOIN platos_pedido pp ON p.id = pp.pedido_id
INNER JOIN platos pl ON pp.plato_id = pl.id
GROUP BY p.id, m.numero, m.capacidad, p.fecha_pedido, p.total, p.estado;

-- 4. Índices para optimizar consultas
-- Índice en platos por nombre
CREATE INDEX idx_platos_nombre ON platos(nombre);

-- Índice en platos por categoría y precio
CREATE INDEX idx_platos_categoria_precio ON platos(categoria_id, precio);

-- Índice en pedidos por mesa y fecha
CREATE INDEX idx_pedidos_mesa_fecha ON pedidos(mesa_id, fecha_pedido);

-- Índice en pedidos por estado y fecha
CREATE INDEX idx_pedidos_estado_fecha ON pedidos(estado, fecha_pedido);

-- Índice en platos_pedido por pedido y plato
CREATE INDEX idx_platos_pedido_pedido_plato ON platos_pedido(pedido_id, plato_id);

-- Índice en mesas por número
CREATE UNIQUE INDEX idx_mesas_numero ON mesas(numero);

-- 5. Vista de reporte de ventas
CREATE VIEW vista_reporte_ventas AS
SELECT 
    'Total Pedidos' AS metric,
    COUNT(*) AS valor
FROM pedidos
WHERE estado = 'Completado'
UNION ALL
SELECT 
    'Total Ingresos' AS metric,
    ROUND(SUM(total), 2) AS valor
FROM pedidos
WHERE estado = 'Completado'
UNION ALL
SELECT 
    'Promedio por Pedido' AS metric,
    ROUND(AVG(total), 2) AS valor
FROM pedidos
WHERE estado = 'Completado'
UNION ALL
SELECT 
    'Total Platos Vendidos' AS metric,
    SUM(cantidad) AS valor
FROM platos_pedido pp
INNER JOIN pedidos p ON pp.pedido_id = p.id
WHERE p.estado = 'Completado'
UNION ALL
SELECT 
    'Platos Más Vendidos' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT plato_id
    FROM platos_pedido pp
    INNER JOIN pedidos p ON pp.pedido_id = p.id
    WHERE p.estado = 'Completado'
    GROUP BY plato_id
    HAVING SUM(cantidad) > 20
) platos_populares
UNION ALL
SELECT 
    'Mesas Más Rentables' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT mesa_id
    FROM pedidos
    WHERE estado = 'Completado'
    GROUP BY mesa_id
    HAVING SUM(total) > 500
) mesas_rentables;
```

### Ejercicio 5: Sistema de Hospital
Usando la base de datos `hospital_completo`, crea vistas e índices para:

1. Crear una vista de doctores con análisis de actividad
2. Crear una vista de pacientes con historial médico
3. Crear una vista de citas con información completa
4. Crear índices para optimizar consultas médicas
5. Crear una vista de reporte médico general

**Solución:**
```sql
-- 1. Vista de doctores con análisis de actividad
CREATE VIEW vista_analisis_doctores AS
SELECT 
    d.id,
    d.nombre,
    d.apellido,
    d.especialidad,
    d.licencia,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.paciente_id) AS pacientes_unicos,
    ROUND(COUNT(c.id) / COUNT(DISTINCT c.paciente_id), 1) AS citas_por_paciente,
    COUNT(DISTINCT DATE(c.fecha_cita)) AS dias_trabajados,
    ROUND(COUNT(c.id) / COUNT(DISTINCT DATE(c.fecha_cita)), 1) AS citas_por_dia,
    SUM(t.costo) AS total_ingresos,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    MAX(c.fecha_cita) AS ultima_cita,
    CASE 
        WHEN COUNT(c.id) > 50 THEN 'Doctor Muy Activo'
        WHEN COUNT(c.id) > 25 THEN 'Doctor Activo'
        WHEN COUNT(c.id) > 10 THEN 'Doctor Moderado'
        WHEN COUNT(c.id) > 0 THEN 'Doctor Poco Activo'
        ELSE 'Doctor Inactivo'
    END AS nivel_actividad
FROM doctores d
LEFT JOIN citas c ON d.id = c.doctor_id
LEFT JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
LEFT JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY d.id, d.nombre, d.apellido, d.especialidad, d.licencia;

-- 2. Vista de pacientes con historial médico
CREATE VIEW vista_historial_pacientes AS
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    p.fecha_nacimiento,
    p.telefono,
    p.direccion,
    YEAR(CURDATE()) - YEAR(p.fecha_nacimiento) AS edad,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.doctor_id) AS doctores_consultados,
    COUNT(DISTINCT t.id) AS tratamientos_diferentes,
    SUM(t.costo) AS total_gastado,
    ROUND(AVG(t.costo), 2) AS costo_promedio_tratamiento,
    MAX(c.fecha_cita) AS ultima_cita,
    DATEDIFF(CURDATE(), MAX(c.fecha_cita)) AS dias_desde_ultima_cita,
    CASE 
        WHEN SUM(t.costo) > 1000 THEN 'Paciente de Alto Costo'
        WHEN SUM(t.costo) > 500 THEN 'Paciente de Costo Medio'
        WHEN SUM(t.costo) > 200 THEN 'Paciente de Costo Bajo'
        WHEN SUM(t.costo) > 0 THEN 'Paciente de Muy Bajo Costo'
        ELSE 'Paciente Sin Tratamientos'
    END AS categoria_costo
FROM pacientes p
LEFT JOIN citas c ON p.id = c.paciente_id
LEFT JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
LEFT JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY p.id, p.nombre, p.apellido, p.fecha_nacimiento, p.telefono, p.direccion;

-- 3. Vista de citas con información completa
CREATE VIEW vista_citas_completa AS
SELECT 
    c.id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente,
    YEAR(CURDATE()) - YEAR(p.fecha_nacimiento) AS edad_paciente,
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,
    d.especialidad,
    c.fecha_cita,
    c.motivo,
    c.estado,
    GROUP_CONCAT(t.nombre SEPARATOR ', ') AS tratamientos_aplicados,
    SUM(t.costo) AS costo_total_tratamientos,
    COUNT(t.id) AS total_tratamientos,
    CASE 
        WHEN c.estado = 'Completada' THEN 'Finalizada'
        WHEN c.estado = 'Programada' AND c.fecha_cita > NOW() THEN 'Futura'
        WHEN c.estado = 'Programada' AND c.fecha_cita <= NOW() THEN 'Vencida'
        ELSE c.estado
    END AS estado_cita
FROM citas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN doctores d ON c.doctor_id = d.id
LEFT JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
LEFT JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY c.id, p.nombre, p.apellido, p.fecha_nacimiento, d.nombre, d.apellido, d.especialidad, c.fecha_cita, c.motivo, c.estado;

-- 4. Índices para optimizar consultas médicas
-- Índice en doctores por especialidad
CREATE INDEX idx_doctores_especialidad ON doctores(especialidad);

-- Índice en citas por doctor y fecha
CREATE INDEX idx_citas_doctor_fecha ON citas(doctor_id, fecha_cita);

-- Índice en citas por paciente y fecha
CREATE INDEX idx_citas_paciente_fecha ON citas(paciente_id, fecha_cita);

-- Índice en citas por estado y fecha
CREATE INDEX idx_citas_estado_fecha ON citas(estado, fecha_cita);

-- Índice en tratamientos_aplicados por cita
CREATE INDEX idx_tratamientos_aplicados_cita ON tratamientos_aplicados(cita_id);

-- Índice en pacientes por fecha de nacimiento
CREATE INDEX idx_pacientes_fecha_nacimiento ON pacientes(fecha_nacimiento);

-- 5. Vista de reporte médico general
CREATE VIEW vista_reporte_medico_general AS
SELECT 
    'Total Doctores' AS metric,
    COUNT(*) AS valor
FROM doctores
UNION ALL
SELECT 
    'Total Pacientes' AS metric,
    COUNT(*) AS valor
FROM pacientes
UNION ALL
SELECT 
    'Total Citas' AS metric,
    COUNT(*) AS valor
FROM citas
UNION ALL
SELECT 
    'Citas Completadas' AS metric,
    COUNT(*) AS valor
FROM citas
WHERE estado = 'Completada'
UNION ALL
SELECT 
    'Citas Programadas' AS metric,
    COUNT(*) AS valor
FROM citas
WHERE estado = 'Programada'
UNION ALL
SELECT 
    'Total Tratamientos Aplicados' AS metric,
    COUNT(*) AS valor
FROM tratamientos_aplicados
UNION ALL
SELECT 
    'Ingresos Totales' AS metric,
    ROUND(SUM(t.costo), 2) AS valor
FROM tratamientos_aplicados ta
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
UNION ALL
SELECT 
    'Doctores Más Activos' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT doctor_id
    FROM citas
    GROUP BY doctor_id
    HAVING COUNT(*) > 30
) doctores_activos
UNION ALL
SELECT 
    'Pacientes con Más Citas' AS metric,
    COUNT(*) AS valor
FROM (
    SELECT paciente_id
    FROM citas
    GROUP BY paciente_id
    HAVING COUNT(*) > 5
) pacientes_frecuentes;
```

## 📝 Resumen de Conceptos Clave
- ✅ Las vistas simplifican consultas complejas y mejoran la seguridad
- ✅ Los índices optimizan el rendimiento de las consultas
- ✅ Las vistas pueden ser simples, complejas o actualizables
- ✅ Los índices pueden ser simples, compuestos o únicos
- ✅ Las vistas proporcionan una capa de abstracción sobre los datos
- ✅ Los índices son fundamentales para bases de datos de alto rendimiento
- ✅ Las vistas e índices mejoran la mantenibilidad y escalabilidad

## 🔗 Próximo Nivel
¡Felicidades! Has completado el nivel Mid-Level. Ahora continúa con `docs/senior_1` para aprender sobre transacciones y control de concurrencia.

---

**💡 Consejo: Practica creando vistas para consultas complejas frecuentes e índices para columnas de búsqueda. Son herramientas esenciales para bases de datos profesionales.**
