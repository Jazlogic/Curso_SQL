# 🔶 Mid Level 2: Subconsultas y Consultas Anidadas

## 🧭 Navegación del Curso

**← Anterior**: [Mid Level 1: JOINs y Relaciones](../midLevel_1/README.md)  
**Siguiente →**: [Mid Level 3: Funciones Agregadas](../midLevel_3/README.md)

---

## 📖 Teoría

### ¿Qué son las Subconsultas?
Las subconsultas son consultas SQL que se ejecutan dentro de otra consulta principal. Permiten crear consultas más complejas y potentes al combinar múltiples operaciones en una sola instrucción.

### Tipos de Subconsultas
1. **Subconsultas Escalares**: Retornan un solo valor
2. **Subconsultas de Columna**: Retornan una columna de valores
3. **Subconsultas de Tabla**: Retornan múltiples filas y columnas
4. **Subconsultas Correlacionadas**: Se ejecutan para cada fila de la consulta principal

### Ubicaciones de Subconsultas
- **SELECT**: En la lista de columnas
- **FROM**: Como tabla derivada
- **WHERE**: En condiciones de filtrado
- **HAVING**: En filtros de grupos
- **INSERT/UPDATE**: En operaciones de modificación

### Operadores para Subconsultas
- **IN**: Verifica si un valor está en una lista
- **EXISTS**: Verifica si existe al menos una fila
- **NOT EXISTS**: Verifica si no existe ninguna fila
- **ANY/ALL**: Compara con todos o algunos valores

## 💡 Ejemplos Prácticos

### Ejemplo 1: Subconsulta Escalar en SELECT
```sql
-- Mostrar productos con precio mayor al promedio
SELECT 
    nombre, 
    precio,
    (SELECT AVG(precio) FROM productos) AS precio_promedio
FROM productos 
WHERE precio > (SELECT AVG(precio) FROM productos);
```

### Ejemplo 2: Subconsulta en WHERE con IN
```sql
-- Productos de categorías con más de 5 productos
SELECT nombre, precio, categoria_id
FROM productos 
WHERE categoria_id IN (
    SELECT id 
    FROM categorias 
    WHERE (SELECT COUNT(*) FROM productos p WHERE p.categoria_id = categorias.id) > 5
);
```

### Ejemplo 3: Subconsulta Correlacionada
```sql
-- Productos con precio mayor al promedio de su categoría
SELECT p.nombre, p.precio, p.categoria_id
FROM productos p
WHERE p.precio > (
    SELECT AVG(precio) 
    FROM productos 
    WHERE categoria_id = p.categoria_id
);
```

### Ejemplo 4: Subconsulta en FROM
```sql
-- Top 3 categorías por número de productos
SELECT 
    c.nombre,
    COUNT(p.id) AS total_productos
FROM categorias c
INNER JOIN (
    SELECT categoria_id, COUNT(*) as total
    FROM productos 
    GROUP BY categoria_id
    ORDER BY total DESC
    LIMIT 3
) top_cat ON c.id = top_cat.categoria_id
INNER JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;
```

### Ejemplo 5: Subconsulta con EXISTS
```sql
-- Clientes que han realizado pedidos en el último mes
SELECT nombre, apellido, email
FROM clientes c
WHERE EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE p.cliente_id = c.id 
    AND p.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
);
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Tienda Online
Usando la base de datos `tienda_online`, escribe consultas con subconsultas para:

1. Mostrar productos con precio mayor al promedio de su categoría
2. Encontrar clientes que han comprado productos de todas las categorías disponibles
3. Mostrar categorías que tienen al menos un producto con stock mayor a 50
4. Encontrar el producto más vendido de cada categoría
5. Mostrar clientes que han gastado más que el promedio de todos los clientes

**Solución:**
```sql
-- 1. Productos con precio mayor al promedio de su categoría
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio) 
    FROM productos 
    WHERE categoria_id = p.categoria_id
);

-- 2. Clientes que han comprado de todas las categorías
SELECT c.nombre, c.apellido
FROM clientes c
WHERE (
    SELECT COUNT(DISTINCT pr.categoria_id)
    FROM pedidos p
    INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
    INNER JOIN productos pr ON pp.producto_id = pr.id
    WHERE p.cliente_id = c.id
) = (SELECT COUNT(*) FROM categorias);

-- 3. Categorías con productos de stock alto
SELECT DISTINCT c.nombre
FROM categorias c
WHERE EXISTS (
    SELECT 1 
    FROM productos p 
    WHERE p.categoria_id = c.id 
    AND p.stock > 50
);

-- 4. Producto más vendido por categoría
SELECT 
    c.nombre AS categoria,
    p.nombre AS producto_mas_vendido,
    total_vendido
FROM categorias c
INNER JOIN (
    SELECT 
        p.categoria_id,
        p.nombre,
        SUM(pp.cantidad) AS total_vendido,
        ROW_NUMBER() OVER (PARTITION BY p.categoria_id ORDER BY SUM(pp.cantidad) DESC) AS rn
    FROM productos p
    LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
    GROUP BY p.id, p.categoria_id, p.nombre
) ranked ON c.id = ranked.categoria_id
WHERE ranked.rn = 1;

-- 5. Clientes que gastan más que el promedio
SELECT c.nombre, c.apellido, SUM(p.total) AS total_gastado
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado = 'Completado'
GROUP BY c.id, c.nombre, c.apellido
HAVING SUM(p.total) > (
    SELECT AVG(total_cliente)
    FROM (
        SELECT SUM(total) AS total_cliente
        FROM pedidos 
        WHERE estado = 'Completado'
        GROUP BY cliente_id
    ) promedios
);
```

### Ejercicio 2: Sistema de Biblioteca
Usando la base de datos `biblioteca_completa`, escribe consultas con subconsultas para:

1. Mostrar libros que han sido prestados más veces que el promedio
2. Encontrar usuarios que han prestado libros de todos los géneros disponibles
3. Mostrar autores que tienen libros con más de 3 préstamos
4. Encontrar el libro más popular de cada género
5. Mostrar usuarios que han prestado más libros que el promedio

**Solución:**
```sql
-- 1. Libros prestados más que el promedio
SELECT l.titulo, COUNT(p.id) AS veces_prestado
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY l.id, l.titulo
HAVING COUNT(p.id) > (
    SELECT AVG(veces_prestado)
    FROM (
        SELECT COUNT(*) AS veces_prestado
        FROM prestamos
        GROUP BY libro_id
    ) promedios
);

-- 2. Usuarios que han prestado de todos los géneros
SELECT u.nombre, u.apellido
FROM usuarios u
WHERE (
    SELECT COUNT(DISTINCT l.genero)
    FROM prestamos p
    INNER JOIN libros l ON p.libro_id = l.id
    WHERE p.usuario_id = u.id
) = (SELECT COUNT(DISTINCT genero) FROM libros);

-- 3. Autores con libros muy prestados
SELECT DISTINCT CONCAT(a.nombre, ' ', a.apellido) AS autor
FROM autores a
WHERE EXISTS (
    SELECT 1 
    FROM libros l 
    WHERE l.autor_id = a.id 
    AND (SELECT COUNT(*) FROM prestamos WHERE libro_id = l.id) > 3
);

-- 4. Libro más popular por género
SELECT 
    genero,
    titulo AS libro_mas_popular,
    veces_prestado
FROM (
    SELECT 
        l.genero,
        l.titulo,
        COUNT(p.id) AS veces_prestado,
        ROW_NUMBER() OVER (PARTITION BY l.genero ORDER BY COUNT(p.id) DESC) AS rn
    FROM libros l
    LEFT JOIN prestamos p ON l.id = p.libro_id
    GROUP BY l.id, l.genero, l.titulo
) ranked
WHERE rn = 1;

-- 5. Usuarios que prestan más que el promedio
SELECT u.nombre, u.apellido, COUNT(p.id) AS total_prestamos
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.apellido
HAVING COUNT(p.id) > (
    SELECT AVG(total_usuario)
    FROM (
        SELECT COUNT(*) AS total_usuario
        FROM prestamos
        GROUP BY usuario_id
    ) promedios
);
```

### Ejercicio 3: Sistema de Escuela
Usando la base de datos `escuela_completa`, escribe consultas con subconsultas para:

1. Mostrar cursos con calificación promedio mayor al promedio general
2. Encontrar estudiantes que están inscritos en más cursos que el promedio
3. Mostrar profesores que enseñan cursos con calificación promedio alta
4. Encontrar el curso más difícil (menor calificación promedio) de cada profesor
5. Mostrar estudiantes que tienen calificaciones superiores al promedio de su grado

**Solución:**
```sql
-- 1. Cursos con calificación alta
SELECT c.nombre, AVG(i.calificacion) AS promedio_curso
FROM cursos c
INNER JOIN inscripciones i ON c.id = i.curso_id
GROUP BY c.id, c.nombre
HAVING AVG(i.calificacion) > (
    SELECT AVG(calificacion) FROM inscripciones
);

-- 2. Estudiantes con muchos cursos
SELECT e.nombre, e.apellido, COUNT(i.curso_id) AS total_cursos
FROM estudiantes e
LEFT JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.id, e.nombre, e.apellido
HAVING COUNT(i.curso_id) > (
    SELECT AVG(total_estudiante)
    FROM (
        SELECT COUNT(*) AS total_estudiante
        FROM inscripciones
        GROUP BY estudiante_id
    ) promedios
);

-- 3. Profesores con cursos de alta calificación
SELECT DISTINCT CONCAT(p.nombre, ' ', p.apellido) AS profesor
FROM profesores p
WHERE EXISTS (
    SELECT 1 
    FROM cursos c 
    WHERE c.profesor_id = p.id 
    AND (
        SELECT AVG(calificacion) 
        FROM inscripciones 
        WHERE curso_id = c.id
    ) > (SELECT AVG(calificacion) FROM inscripciones)
);

-- 4. Curso más difícil por profesor
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS profesor,
    c.nombre AS curso_mas_dificil,
    promedio_curso
FROM profesores p
INNER JOIN (
    SELECT 
        c.profesor_id,
        c.nombre,
        AVG(i.calificacion) AS promedio_curso,
        ROW_NUMBER() OVER (PARTITION BY c.profesor_id ORDER BY AVG(i.calificacion)) AS rn
    FROM cursos c
    INNER JOIN inscripciones i ON c.id = i.curso_id
    GROUP BY c.id, c.profesor_id, c.nombre
) ranked ON p.id = ranked.profesor_id
WHERE ranked.rn = 1;

-- 5. Estudiantes con calificaciones superiores al promedio de su grado
SELECT e.nombre, e.apellido, e.grado, AVG(i.calificacion) AS promedio_estudiante
FROM estudiantes e
INNER JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.id, e.nombre, e.apellido, e.grado
HAVING AVG(i.calificacion) > (
    SELECT AVG(calificacion)
    FROM inscripciones i2
    INNER JOIN estudiantes e2 ON i2.estudiante_id = e2.id
    WHERE e2.grado = e.grado
);
```

### Ejercicio 4: Sistema de Restaurante
Usando la base de datos `restaurante_completo`, escribe consultas con subconsultas para:

1. Mostrar platos con precio mayor al promedio de su categoría
2. Encontrar mesas que han generado más pedidos que el promedio
3. Mostrar categorías que tienen platos con descripción muy larga
4. Encontrar el plato más caro de cada categoría
5. Mostrar mesas que han tenido pedidos con total superior al promedio

**Solución:**
```sql
-- 1. Platos con precio alto por categoría
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM platos p
INNER JOIN categorias_platos c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio) 
    FROM platos 
    WHERE categoria_id = p.categoria_id
);

-- 2. Mesas con muchos pedidos
SELECT m.numero, COUNT(p.id) AS total_pedidos
FROM mesas m
LEFT JOIN pedidos p ON m.id = p.mesa_id
GROUP BY m.id, m.numero
HAVING COUNT(p.id) > (
    SELECT AVG(total_mesa)
    FROM (
        SELECT COUNT(*) AS total_mesa
        FROM pedidos
        GROUP BY mesa_id
    ) promedios
);

-- 3. Categorías con platos de descripción larga
SELECT DISTINCT c.nombre
FROM categorias_platos c
WHERE EXISTS (
    SELECT 1 
    FROM platos p 
    WHERE p.categoria_id = c.id 
    AND LENGTH(p.descripcion) > 100
);

-- 4. Plato más caro por categoría
SELECT 
    c.nombre AS categoria,
    p.nombre AS plato_mas_caro,
    p.precio
FROM categorias_platos c
INNER JOIN (
    SELECT 
        categoria_id,
        nombre,
        precio,
        ROW_NUMBER() OVER (PARTITION BY categoria_id ORDER BY precio DESC) AS rn
    FROM platos
) ranked ON c.id = ranked.categoria_id
WHERE ranked.rn = 1;

-- 5. Mesas con pedidos de alto valor
SELECT DISTINCT m.numero
FROM mesas m
WHERE EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE p.mesa_id = m.id 
    AND p.total > (SELECT AVG(total) FROM pedidos)
);
```

### Ejercicio 5: Sistema de Hospital
Usando la base de datos `hospital_completo`, escribe consultas con subconsultas para:

1. Mostrar doctores que tienen más citas que el promedio
2. Encontrar pacientes que han tenido citas con todos los doctores
3. Mostrar especialidades que tienen doctores con muchas citas
4. Encontrar el tratamiento más costoso aplicado por cada doctor
5. Mostrar pacientes que han gastado más en tratamientos que el promedio

**Solución:**
```sql
-- 1. Doctores con muchas citas
SELECT d.nombre, d.apellido, COUNT(c.id) AS total_citas
FROM doctores d
LEFT JOIN citas c ON d.id = c.doctor_id
GROUP BY d.id, d.nombre, d.apellido
HAVING COUNT(c.id) > (
    SELECT AVG(total_doctor)
    FROM (
        SELECT COUNT(*) AS total_doctor
        FROM citas
        GROUP BY doctor_id
    ) promedios
);

-- 2. Pacientes con citas de todos los doctores
SELECT p.nombre, p.apellido
FROM pacientes p
WHERE (
    SELECT COUNT(DISTINCT c.doctor_id)
    FROM citas c
    WHERE c.paciente_id = p.id
) = (SELECT COUNT(*) FROM doctores);

-- 3. Especialidades con doctores ocupados
SELECT DISTINCT d.especialidad
FROM doctores d
WHERE EXISTS (
    SELECT 1 
    FROM citas c 
    WHERE c.doctor_id = d.id 
    AND (SELECT COUNT(*) FROM citas WHERE doctor_id = d.id) > 5
);

-- 4. Tratamiento más costoso por doctor
SELECT 
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,
    t.nombre AS tratamiento_mas_caro,
    t.costo
FROM doctores d
INNER JOIN (
    SELECT 
        c.doctor_id,
        t.nombre,
        t.costo,
        ROW_NUMBER() OVER (PARTITION BY c.doctor_id ORDER BY t.costo DESC) AS rn
    FROM citas c
    INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
    INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
) ranked ON d.id = ranked.doctor_id
WHERE ranked.rn = 1;

-- 5. Pacientes con gastos altos
SELECT p.nombre, p.apellido, SUM(t.costo) AS total_gastado
FROM pacientes p
INNER JOIN citas c ON p.id = c.paciente_id
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY p.id, p.nombre, p.apellido
HAVING SUM(t.costo) > (
    SELECT AVG(total_paciente)
    FROM (
        SELECT SUM(t2.costo) AS total_paciente
        FROM citas c2
        INNER JOIN tratamientos_aplicados ta2 ON c2.id = ta2.cita_id
        INNER JOIN tratamientos t2 ON ta2.tratamiento_id = t2.id
        GROUP BY c2.paciente_id
    ) promedios
);
```

## 📝 Resumen de Conceptos Clave
- ✅ Las subconsultas permiten crear consultas complejas y anidadas
- ✅ Las subconsultas escalares retornan un solo valor
- ✅ Las subconsultas correlacionadas se ejecutan para cada fila
- ✅ EXISTS verifica la existencia de filas
- ✅ IN verifica si un valor está en una lista
- ✅ Las subconsultas se pueden usar en SELECT, FROM, WHERE, HAVING
- ✅ Las subconsultas son fundamentales para consultas avanzadas

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/midLevel_3` para aprender sobre funciones agregadas y GROUP BY.

---

**💡 Consejo: Practica creando subconsultas complejas. Son la base para consultas empresariales avanzadas y reportes complejos.**
