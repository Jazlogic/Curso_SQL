# 🔶 Mid Level 3: Funciones Agregadas y GROUP BY

## 🧭 Navegación del Curso

**← Anterior**: [Mid Level 2: Subconsultas](../midLevel_2/README.md)  
**Siguiente →**: [Mid Level 4: Consultas Complejas](../midLevel_4/README.md)

---

## 📖 Teoría

### ¿Qué son las Funciones Agregadas?
Las funciones agregadas procesan múltiples filas y retornan un solo valor. Son fundamentales para análisis de datos, reportes y estadísticas.

### Funciones Agregadas Principales
1. **COUNT()**: Cuenta filas o valores no nulos
2. **SUM()**: Suma valores numéricos
3. **AVG()**: Calcula el promedio
4. **MAX()**: Encuentra el valor máximo
5. **MIN()**: Encuentra el valor mínimo
6. **GROUP_CONCAT()**: Concatena valores en una cadena

### GROUP BY
- **Agrupa** filas por valores de columnas específicas
- **Permite** aplicar funciones agregadas a cada grupo
- **Esencial** para análisis por categorías o dimensiones

### HAVING
- **Filtra** grupos después de aplicar funciones agregadas
- **Similar** a WHERE pero para grupos
- **Se ejecuta** después de GROUP BY

### Orden de Ejecución
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
7. LIMIT

## 💡 Ejemplos Prácticos

### Ejemplo 1: GROUP BY Básico
```sql
-- Total de productos por categoría
SELECT 
    categoria_id,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos 
GROUP BY categoria_id;
```

### Ejemplo 2: GROUP BY con Múltiples Columnas
```sql
-- Ventas por cliente y mes
SELECT 
    cliente_id,
    MONTH(fecha_pedido) AS mes,
    COUNT(*) AS total_pedidos,
    SUM(total) AS total_ventas
FROM pedidos 
GROUP BY cliente_id, MONTH(fecha_pedido);
```

### Ejemplo 3: HAVING para Filtrar Grupos
```sql
-- Categorías con más de 5 productos
SELECT 
    categoria_id,
    COUNT(*) AS total_productos
FROM productos 
GROUP BY categoria_id
HAVING COUNT(*) > 5;
```

### Ejemplo 4: Funciones Agregadas Anidadas
```sql
-- Promedio del total de ventas por cliente
SELECT AVG(total_ventas) AS promedio_ventas_cliente
FROM (
    SELECT cliente_id, SUM(total) AS total_ventas
    FROM pedidos 
    GROUP BY cliente_id
) resumen_clientes;
```

### Ejemplo 5: GROUP_CONCAT
```sql
-- Lista de productos por categoría
SELECT 
    c.nombre AS categoria,
    GROUP_CONCAT(p.nombre SEPARATOR ', ') AS productos
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Tienda Online
Usando la base de datos `tienda_online`, escribe consultas con funciones agregadas para:

1. Calcular el total de ventas por categoría de producto
2. Encontrar el cliente que más ha gastado y cuánto ha gastado
3. Mostrar el promedio de productos por pedido
4. Calcular el total de ingresos por mes del año actual
5. Mostrar las 3 categorías más rentables

**Solución:**
```sql
-- 1. Total de ventas por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT p.id) AS total_productos,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ventas,
    AVG(pp.precio_unitario) AS precio_promedio
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
INNER JOIN productos_pedido pp ON p.id = pp.producto_id
INNER JOIN pedidos ped ON pp.pedido_id = ped.id
WHERE ped.estado = 'Completado'
GROUP BY c.id, c.nombre
ORDER BY total_ventas DESC;

-- 2. Cliente que más ha gastado
SELECT 
    c.nombre, 
    c.apellido,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_gastado,
    AVG(p.total) AS promedio_por_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido
ORDER BY total_gastado DESC
LIMIT 1;

-- 3. Promedio de productos por pedido
SELECT 
    AVG(productos_por_pedido) AS promedio_productos_por_pedido
FROM (
    SELECT 
        pedido_id,
        COUNT(*) AS productos_por_pedido
    FROM productos_pedido
    GROUP BY pedido_id
) resumen_pedidos;

-- 4. Ingresos por mes del año actual
SELECT 
    MONTH(p.fecha_pedido) AS mes,
    COUNT(DISTINCT p.id) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    AVG(p.total) AS promedio_por_pedido
FROM pedidos p
WHERE YEAR(p.fecha_pedido) = YEAR(CURDATE())
AND p.estado = 'Completado'
GROUP BY MONTH(p.fecha_pedido)
ORDER BY mes;

-- 5. Top 3 categorías más rentables
SELECT 
    c.nombre AS categoria,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ventas,
    COUNT(DISTINCT p.id) AS total_productos,
    ROUND(SUM(pp.cantidad * pp.precio_unitario) / COUNT(DISTINCT p.id), 2) AS rentabilidad_por_producto
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
INNER JOIN productos_pedido pp ON p.id = pp.producto_id
INNER JOIN pedidos ped ON pp.pedido_id = ped.id
WHERE ped.estado = 'Completado'
GROUP BY c.id, c.nombre
ORDER BY total_ventas DESC
LIMIT 3;
```

### Ejercicio 2: Sistema de Biblioteca
Usando la base de datos `biblioteca_completa`, escribe consultas con funciones agregadas para:

1. Calcular estadísticas de préstamos por género de libro
2. Encontrar el usuario más activo de la biblioteca
3. Mostrar el promedio de días de préstamo por libro
4. Calcular el total de préstamos por mes del año actual
5. Mostrar los 5 autores más populares

**Solución:**
```sql
-- 1. Estadísticas por género
SELECT 
    l.genero,
    COUNT(DISTINCT l.id) AS total_libros,
    COUNT(p.id) AS total_prestamos,
    ROUND(COUNT(p.id) / COUNT(DISTINCT l.id), 2) AS prestamos_por_libro,
    AVG(DATEDIFF(p.fecha_devolucion, p.fecha_prestamo)) AS promedio_dias_prestamo
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY l.genero
ORDER BY total_prestamos DESC;

-- 2. Usuario más activo
SELECT 
    u.nombre,
    u.apellido,
    COUNT(p.id) AS total_prestamos,
    COUNT(DISTINCT p.libro_id) AS libros_diferentes,
    MAX(p.fecha_prestamo) AS ultimo_prestamo
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.apellido
ORDER BY total_prestamos DESC
LIMIT 1;

-- 3. Promedio de días de préstamo por libro
SELECT 
    l.titulo,
    l.genero,
    COUNT(p.id) AS veces_prestado,
    ROUND(AVG(DATEDIFF(p.fecha_devolucion, p.fecha_prestamo)), 1) AS promedio_dias
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
WHERE p.fecha_devolucion IS NOT NULL
GROUP BY l.id, l.titulo, l.genero
ORDER BY promedio_dias DESC;

-- 4. Préstamos por mes del año actual
SELECT 
    MONTH(p.fecha_prestamo) AS mes,
    COUNT(*) AS total_prestamos,
    COUNT(DISTINCT p.usuario_id) AS usuarios_activos,
    COUNT(DISTINCT p.libro_id) AS libros_prestados
FROM prestamos p
WHERE YEAR(p.fecha_prestamo) = YEAR(CURDATE())
GROUP BY MONTH(p.fecha_prestamo)
ORDER BY mes;

-- 5. Top 5 autores más populares
SELECT 
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    COUNT(DISTINCT l.id) AS total_libros,
    COUNT(p.id) AS total_prestamos,
    ROUND(COUNT(p.id) / COUNT(DISTINCT l.id), 2) AS prestamos_por_libro
FROM autores a
INNER JOIN libros l ON a.id = l.autor_id
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY total_prestamos DESC
LIMIT 5;
```

### Ejercicio 3: Sistema de Escuela
Usando la base de datos `escuela_completa`, escribe consultas con funciones agregadas para:

1. Calcular estadísticas de calificaciones por curso
2. Encontrar el estudiante con mejor promedio general
3. Mostrar el promedio de calificaciones por grado
4. Calcular el total de inscripciones por mes del año actual
5. Mostrar los 3 profesores con mejores calificaciones promedio

**Solución:**
```sql
-- 1. Estadísticas por curso
SELECT 
    c.nombre AS curso,
    COUNT(i.estudiante_id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    MIN(i.calificacion) AS calificacion_minima,
    MAX(i.calificacion) AS calificacion_maxima,
    COUNT(CASE WHEN i.calificacion >= 3.0 THEN 1 END) AS aprobados,
    COUNT(CASE WHEN i.calificacion < 3.0 THEN 1 END) AS reprobados
FROM cursos c
LEFT JOIN inscripciones i ON c.id = i.curso_id
GROUP BY c.id, c.nombre
ORDER BY promedio_calificaciones DESC;

-- 2. Estudiante con mejor promedio
SELECT 
    e.nombre,
    e.apellido,
    e.grado,
    COUNT(i.curso_id) AS total_cursos,
    ROUND(AVG(i.calificacion), 2) AS promedio_general
FROM estudiantes e
INNER JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.id, e.nombre, e.apellido, e.grado
ORDER BY promedio_general DESC
LIMIT 1;

-- 3. Promedio por grado
SELECT 
    e.grado,
    COUNT(DISTINCT e.id) AS total_estudiantes,
    ROUND(AVG(i.calificacion), 2) AS promedio_grado,
    COUNT(DISTINCT i.curso_id) AS total_cursos_inscritos
FROM estudiantes e
INNER JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.grado
ORDER BY e.grado;

-- 4. Inscripciones por mes del año actual
SELECT 
    MONTH(i.fecha_inscripcion) AS mes,
    COUNT(*) AS total_inscripciones,
    COUNT(DISTINCT i.estudiante_id) AS estudiantes_inscritos,
    COUNT(DISTINCT i.curso_id) AS cursos_inscritos
FROM inscripciones i
WHERE YEAR(i.fecha_inscripcion) = YEAR(CURDATE())
GROUP BY MONTH(i.fecha_inscripcion)
ORDER BY mes;

-- 5. Top 3 profesores con mejores calificaciones
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    p.especialidad,
    COUNT(DISTINCT c.id) AS total_cursos,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    COUNT(DISTINCT i.estudiante_id) AS total_estudiantes
FROM profesores p
INNER JOIN cursos c ON p.id = c.profesor_id
INNER JOIN inscripciones i ON c.id = i.curso_id
GROUP BY p.id, p.nombre, p.apellido, p.especialidad
ORDER BY promedio_calificaciones DESC
LIMIT 3;
```

### Ejercicio 4: Sistema de Restaurante
Usando la base de datos `restaurante_completo`, escribe consultas con funciones agregadas para:

1. Calcular estadísticas de ventas por categoría de plato
2. Encontrar la mesa que más ingresos ha generado
3. Mostrar el promedio de productos por pedido
4. Calcular el total de ventas por día de la semana
5. Mostrar los 5 platos más vendidos

**Solución:**
```sql
-- 1. Estadísticas por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(DISTINCT p.id) AS total_platos,
    SUM(pp.cantidad) AS total_vendido,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ingresos,
    ROUND(AVG(pp.precio_unitario), 2) AS precio_promedio
FROM categorias_platos c
INNER JOIN platos p ON c.id = p.categoria_id
INNER JOIN platos_pedido pp ON p.id = pp.plato_id
INNER JOIN pedidos ped ON pp.pedido_id = ped.id
WHERE ped.estado = 'Completado'
GROUP BY c.id, c.nombre
ORDER BY total_ingresos DESC;

-- 2. Mesa más rentable
SELECT 
    m.numero AS mesa,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido,
    MAX(p.fecha_pedido) AS ultimo_pedido
FROM mesas m
INNER JOIN pedidos p ON m.id = p.mesa_id
WHERE p.estado = 'Completado'
GROUP BY m.id, m.numero
ORDER BY total_ingresos DESC
LIMIT 1;

-- 3. Promedio de productos por pedido
SELECT 
    ROUND(AVG(productos_por_pedido), 2) AS promedio_productos_por_pedido
FROM (
    SELECT 
        pedido_id,
        COUNT(*) AS productos_por_pedido
    FROM platos_pedido
    GROUP BY pedido_id
) resumen_pedidos;

-- 4. Ventas por día de la semana
SELECT 
    DAYNAME(p.fecha_pedido) AS dia_semana,
    COUNT(*) AS total_pedidos,
    SUM(p.total) AS total_ingresos,
    ROUND(AVG(p.total), 2) AS promedio_por_pedido
FROM pedidos p
WHERE p.estado = 'Completado'
GROUP BY DAYNAME(p.fecha_pedido)
ORDER BY total_ingresos DESC;

-- 5. Top 5 platos más vendidos
SELECT 
    p.nombre AS plato,
    c.nombre AS categoria,
    SUM(pp.cantidad) AS total_vendido,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ingresos,
    ROUND(AVG(pp.precio_unitario), 2) AS precio_promedio
FROM platos p
INNER JOIN categorias_platos c ON p.categoria_id = c.id
INNER JOIN platos_pedido pp ON p.id = pp.plato_id
INNER JOIN pedidos ped ON pp.pedido_id = ped.id
WHERE ped.estado = 'Completado'
GROUP BY p.id, p.nombre, c.nombre
ORDER BY total_vendido DESC
LIMIT 5;
```

### Ejercicio 5: Sistema de Hospital
Usando la base de datos `hospital_completo`, escribe consultas con funciones agregadas para:

1. Calcular estadísticas de citas por especialidad médica
2. Encontrar el doctor más ocupado
3. Mostrar el promedio de costos por tratamiento
4. Calcular el total de ingresos por mes del año actual
5. Mostrar los 5 tratamientos más aplicados

**Solución:**
```sql
-- 1. Estadísticas por especialidad
SELECT 
    d.especialidad,
    COUNT(DISTINCT d.id) AS total_doctores,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.paciente_id) AS pacientes_atendidos,
    ROUND(COUNT(c.id) / COUNT(DISTINCT d.id), 2) AS citas_por_doctor
FROM doctores d
LEFT JOIN citas c ON d.id = c.doctor_id
GROUP BY d.especialidad
ORDER BY total_citas DESC;

-- 2. Doctor más ocupado
SELECT 
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,
    d.especialidad,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.paciente_id) AS pacientes_unicos,
    MAX(c.fecha_cita) AS ultima_cita
FROM doctores d
INNER JOIN citas c ON d.id = c.doctor_id
GROUP BY d.id, d.nombre, d.apellido, d.especialidad
ORDER BY total_citas DESC
LIMIT 1;

-- 3. Promedio de costos por tratamiento
SELECT 
    t.nombre AS tratamiento,
    COUNT(ta.id) AS veces_aplicado,
    ROUND(AVG(t.costo), 2) AS costo_promedio,
    SUM(t.costo) AS total_ingresos
FROM tratamientos t
LEFT JOIN tratamientos_aplicados ta ON t.id = ta.tratamiento_id
GROUP BY t.id, t.nombre
ORDER BY veces_aplicado DESC;

-- 4. Ingresos por mes del año actual
SELECT 
    MONTH(c.fecha_cita) AS mes,
    COUNT(c.id) AS total_citas,
    COUNT(DISTINCT c.doctor_id) AS doctores_activos,
    COUNT(DISTINCT c.paciente_id) AS pacientes_atendidos,
    SUM(t.costo) AS total_ingresos
FROM citas c
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
WHERE YEAR(c.fecha_cita) = YEAR(CURDATE())
GROUP BY MONTH(c.fecha_cita)
ORDER BY mes;

-- 5. Top 5 tratamientos más aplicados
SELECT 
    t.nombre AS tratamiento,
    t.descripcion,
    COUNT(ta.id) AS veces_aplicado,
    SUM(t.costo) AS total_ingresos,
    ROUND(AVG(t.costo), 2) AS costo_promedio
FROM tratamientos t
INNER JOIN tratamientos_aplicados ta ON t.id = ta.tratamiento_id
GROUP BY t.id, t.nombre, t.descripcion
ORDER BY veces_aplicado DESC
LIMIT 5;
```

## 📝 Resumen de Conceptos Clave
- ✅ Las funciones agregadas procesan múltiples filas y retornan un valor
- ✅ COUNT, SUM, AVG, MAX, MIN son las funciones más comunes
- ✅ GROUP BY agrupa filas por valores de columnas específicas
- ✅ HAVING filtra grupos después de aplicar funciones agregadas
- ✅ El orden de ejecución es importante: FROM → WHERE → GROUP BY → HAVING → SELECT
- ✅ Las funciones agregadas son esenciales para análisis de datos y reportes

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/midLevel_4` para aprender sobre consultas complejas y optimización básica.

---

**💡 Consejo: Practica creando reportes agregados complejos. Las funciones agregadas son la base para análisis empresarial y toma de decisiones.**
