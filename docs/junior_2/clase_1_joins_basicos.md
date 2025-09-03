# Clase 1: JOINs Básicos - Conectando Tablas

## 📚 Descripción de la Clase
En esta clase aprenderás los fundamentos de los JOINs en SQL, que son operaciones esenciales para combinar datos de múltiples tablas. Dominarás INNER JOIN, LEFT JOIN y RIGHT JOIN, entendiendo cuándo y cómo usar cada uno para obtener los resultados deseados.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son los JOINs y por qué son importantes
- Usar INNER JOIN para combinar datos relacionados
- Aplicar LEFT JOIN para incluir todos los registros de la tabla izquierda
- Implementar RIGHT JOIN para incluir todos los registros de la tabla derecha
- Crear consultas con múltiples JOINs
- Optimizar consultas con JOINs usando índices apropiados

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son los JOINs?

Los **JOINs** son operaciones que permiten combinar filas de dos o más tablas basándose en una relación entre ellas. Son fundamentales en bases de datos relacionales porque:

- **Eliminan redundancia**: Evitan duplicar datos
- **Mantienen integridad**: Aseguran consistencia de datos
- **Facilitan consultas**: Permiten obtener información completa
- **Optimizan almacenamiento**: Reducen el espacio necesario

### Sintaxis General de JOIN

```sql
SELECT columnas
FROM tabla1
JOIN tabla2 ON tabla1.columna = tabla2.columna
WHERE condiciones;
```

**Explicación línea por línea:**
- `SELECT columnas`: especifica las columnas a mostrar
- `FROM tabla1`: tabla principal (izquierda)
- `JOIN tabla2`: tabla a unir (derecha)
- `ON tabla1.columna = tabla2.columna`: condición de unión
- `WHERE condiciones`: filtros adicionales (opcional)

### 1. INNER JOIN - Intersección de Tablas

INNER JOIN devuelve solo los registros que tienen coincidencias en ambas tablas.

#### 1.1 Sintaxis de INNER JOIN
```sql
SELECT columnas
FROM tabla1
INNER JOIN tabla2 ON tabla1.clave = tabla2.clave;
```

**Explicación línea por línea:**
- `INNER JOIN`: tipo de unión que requiere coincidencias en ambas tablas
- `ON tabla1.clave = tabla2.clave`: condición de unión basada en claves relacionadas
- Solo devuelve registros que existen en ambas tablas

#### 1.2 Ejemplo Básico de INNER JOIN
```sql
-- Obtener productos con información de categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;
```

**Explicación línea por línea:**
- `p.nombre AS producto`: nombre del producto con alias
- `c.nombre AS categoria`: nombre de la categoría con alias
- `INNER JOIN categorias c`: une con la tabla categorias
- `ON p.categoria_id = c.id`: condición de unión por claves foráneas

### 2. LEFT JOIN - Incluir Todos los Registros de la Izquierda

LEFT JOIN devuelve todos los registros de la tabla izquierda y las coincidencias de la derecha.

#### 2.1 Sintaxis de LEFT JOIN
```sql
SELECT columnas
FROM tabla1
LEFT JOIN tabla2 ON tabla1.clave = tabla2.clave;
```

**Explicación línea por línea:**
- `LEFT JOIN`: incluye todos los registros de la tabla izquierda
- Si no hay coincidencia en la tabla derecha, devuelve NULL
- Útil para encontrar registros sin relaciones

#### 2.2 Ejemplo Básico de LEFT JOIN
```sql
-- Obtener todos los productos, incluso sin categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;
```

**Explicación línea por línea:**
- `LEFT JOIN categorias c`: incluye todos los productos
- Si un producto no tiene categoría, categoria será NULL
- Útil para identificar productos sin categorizar

### 3. RIGHT JOIN - Incluir Todos los Registros de la Derecha

RIGHT JOIN devuelve todos los registros de la tabla derecha y las coincidencias de la izquierda.

#### 3.1 Sintaxis de RIGHT JOIN
```sql
SELECT columnas
FROM tabla1
RIGHT JOIN tabla2 ON tabla1.clave = tabla2.clave;
```

**Explicación línea por línea:**
- `RIGHT JOIN`: incluye todos los registros de la tabla derecha
- Si no hay coincidencia en la tabla izquierda, devuelve NULL
- Menos común que LEFT JOIN

#### 3.2 Ejemplo Básico de RIGHT JOIN
```sql
-- Obtener todas las categorías, incluso sin productos
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;
```

**Explicación línea por línea:**
- `RIGHT JOIN categorias c`: incluye todas las categorías
- Si una categoría no tiene productos, producto será NULL
- Útil para identificar categorías vacías

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Base de Datos de E-commerce

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE ecommerce_joins;
USE ecommerce_joins;

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
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
('Camiseta Nike', 29.99, 2, 100),
('Sofá 3 plazas', 599.99, 3, 5),
('Balón de fútbol', 19.99, 4, 50),
('El Quijote', 15.99, 5, 20),
('Laptop Dell', 1299.99, 1, 15),
('Jeans Levi\'s', 79.99, 2, 75);

INSERT INTO usuarios (nombre, email) VALUES
('Ana García', 'ana.garcia@email.com'),
('Carlos López', 'carlos.lopez@email.com'),
('María Rodríguez', 'maria.rodriguez@email.com'),
('José Martín', 'jose.martin@email.com'),
('Laura Sánchez', 'laura.sanchez@email.com');

INSERT INTO pedidos (usuario_id, total) VALUES
(1, 999.99),
(2, 1329.98),
(3, 45.98),
(1, 599.99),
(4, 35.98);
```

### Ejemplo 2: INNER JOIN en Acción

```sql
-- Consulta 1: Productos con información de categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    p.stock
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Explicación línea por línea:
-- p.nombre AS producto: nombre del producto con alias
-- p.precio: precio del producto
-- c.nombre AS categoria: nombre de la categoría
-- INNER JOIN categorias c: une con tabla categorias
-- ON p.categoria_id = c.id: condición de unión

-- Consulta 2: Pedidos con información de usuarios
SELECT 
    p.id AS pedido_id,
    u.nombre AS cliente,
    u.email,
    p.fecha_pedido,
    p.total
FROM pedidos p
INNER JOIN usuarios u ON p.usuario_id = u.id;

-- Explicación línea por línea:
-- p.id AS pedido_id: ID del pedido
-- u.nombre AS cliente: nombre del cliente
-- u.email: email del cliente
-- INNER JOIN usuarios u: une con tabla usuarios
-- ON p.usuario_id = u.id: condición de unión por clave foránea

-- Consulta 3: Productos de electrónicos con categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónicos';

-- Explicación línea por línea:
-- INNER JOIN categorias c: une con tabla categorias
-- WHERE c.nombre = 'Electrónicos': filtra solo electrónicos
-- Solo productos que tienen categoría y son electrónicos
```

### Ejemplo 3: LEFT JOIN en Acción

```sql
-- Consulta 1: Todos los productos, incluso sin categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    COALESCE(c.nombre, 'Sin Categoría') AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación línea por línea:
-- LEFT JOIN categorias c: incluye todos los productos
-- COALESCE(c.nombre, 'Sin Categoría'): reemplaza NULL con texto
-- Muestra todos los productos, tengan o no categoría

-- Consulta 2: Usuarios con o sin pedidos
SELECT 
    u.nombre AS usuario,
    u.email,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email;

-- Explicación línea por línea:
-- LEFT JOIN pedidos p: incluye todos los usuarios
-- COUNT(p.id): cuenta pedidos por usuario
-- COALESCE(SUM(p.total), 0): suma total gastado o 0
-- GROUP BY: agrupa por usuario para obtener totales

-- Consulta 3: Categorías con productos (incluso sin productos)
SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos,
    AVG(p.precio) AS precio_promedio
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;

-- Explicación línea por línea:
-- LEFT JOIN productos p: incluye todas las categorías
-- COUNT(p.id): cuenta productos por categoría
-- AVG(p.precio): precio promedio de productos
-- Muestra todas las categorías, tengan o no productos
```

### Ejemplo 4: RIGHT JOIN en Acción

```sql
-- Consulta 1: Todas las categorías con productos
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    c.descripcion
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación línea por línea:
-- RIGHT JOIN categorias c: incluye todas las categorías
-- Si una categoría no tiene productos, producto será NULL
-- Útil para ver categorías vacías

-- Consulta 2: Todos los usuarios con pedidos
SELECT 
    u.nombre AS usuario,
    p.id AS pedido_id,
    p.total
FROM pedidos p
RIGHT JOIN usuarios u ON p.usuario_id = u.id;

-- Explicación línea por línea:
-- RIGHT JOIN usuarios u: incluye todos los usuarios
-- Si un usuario no tiene pedidos, pedido_id será NULL
-- Muestra usuarios sin pedidos también

-- Consulta 3: Comparación LEFT vs RIGHT JOIN
-- LEFT JOIN - Todos los productos
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;

-- RIGHT JOIN - Todas las categorías
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación línea por línea:
-- LEFT JOIN: enfoque en productos (tabla izquierda)
-- RIGHT JOIN: enfoque en categorías (tabla derecha)
-- Diferentes perspectivas del mismo conjunto de datos
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: INNER JOIN Básico
**Objetivo**: Practicar INNER JOIN con dos tablas.

**Instrucciones**:
1. Mostrar productos con sus categorías
2. Mostrar pedidos con información de usuarios
3. Mostrar productos de una categoría específica
4. Mostrar usuarios que han hecho pedidos

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con sus categorías
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Explicación:
-- INNER JOIN: solo productos que tienen categoría asignada
-- ON p.categoria_id = c.id: condición de unión por clave foránea

-- Consulta 2: Pedidos con información de usuarios
SELECT 
    p.id AS pedido_id,
    u.nombre AS cliente,
    p.fecha_pedido,
    p.total
FROM pedidos p
INNER JOIN usuarios u ON p.usuario_id = u.id;

-- Explicación:
-- INNER JOIN: solo pedidos con usuario válido
-- ON p.usuario_id = u.id: unión por clave foránea

-- Consulta 3: Productos de categoría específica
SELECT 
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónicos';

-- Explicación:
-- WHERE c.nombre = 'Electrónicos': filtro después del JOIN
-- Solo productos de la categoría especificada

-- Consulta 4: Usuarios que han hecho pedidos
SELECT DISTINCT
    u.nombre AS usuario,
    u.email
FROM usuarios u
INNER JOIN pedidos p ON u.id = p.usuario_id;

-- Explicación:
-- DISTINCT: evita duplicados de usuarios con múltiples pedidos
-- INNER JOIN: solo usuarios con al menos un pedido
```

### Ejercicio 2: LEFT JOIN Básico
**Objetivo**: Practicar LEFT JOIN para incluir todos los registros de la tabla izquierda.

**Instrucciones**:
1. Mostrar todos los productos, incluso sin categoría
2. Mostrar todos los usuarios, incluso sin pedidos
3. Contar productos por categoría (incluso categorías sin productos)
4. Identificar usuarios sin pedidos

**Solución paso a paso:**

```sql
-- Consulta 1: Todos los productos, incluso sin categoría
SELECT 
    p.nombre AS producto,
    p.precio,
    COALESCE(c.nombre, 'Sin Categoría') AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación:
-- LEFT JOIN: incluye todos los productos
-- COALESCE: reemplaza NULL con 'Sin Categoría'

-- Consulta 2: Todos los usuarios, incluso sin pedidos
SELECT 
    u.nombre AS usuario,
    u.email,
    COUNT(p.id) AS total_pedidos
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email;

-- Explicación:
-- LEFT JOIN: incluye todos los usuarios
-- COUNT(p.id): cuenta pedidos (0 si no tiene pedidos)
-- GROUP BY: agrupa por usuario

-- Consulta 3: Contar productos por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;

-- Explicación:
-- LEFT JOIN: incluye todas las categorías
-- COUNT(p.id): cuenta productos por categoría
-- Muestra categorías con 0 productos también

-- Consulta 4: Identificar usuarios sin pedidos
SELECT 
    u.nombre AS usuario,
    u.email
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
WHERE p.id IS NULL;

-- Explicación:
-- LEFT JOIN: incluye todos los usuarios
-- WHERE p.id IS NULL: filtra usuarios sin pedidos
-- IS NULL: identifica registros sin coincidencia
```

### Ejercicio 3: RIGHT JOIN Básico
**Objetivo**: Practicar RIGHT JOIN para incluir todos los registros de la tabla derecha.

**Instrucciones**:
1. Mostrar todas las categorías con productos
2. Mostrar todos los usuarios con pedidos
3. Identificar categorías sin productos
4. Comparar LEFT vs RIGHT JOIN

**Solución paso a paso:**

```sql
-- Consulta 1: Todas las categorías con productos
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    c.descripcion
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación:
-- RIGHT JOIN: incluye todas las categorías
-- Si categoría no tiene productos, producto será NULL

-- Consulta 2: Todos los usuarios con pedidos
SELECT 
    u.nombre AS usuario,
    p.id AS pedido_id,
    p.total
FROM pedidos p
RIGHT JOIN usuarios u ON p.usuario_id = u.id;

-- Explicación:
-- RIGHT JOIN: incluye todos los usuarios
-- Si usuario no tiene pedidos, pedido_id será NULL

-- Consulta 3: Identificar categorías sin productos
SELECT 
    c.nombre AS categoria,
    c.descripcion
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id
WHERE p.id IS NULL;

-- Explicación:
-- RIGHT JOIN: incluye todas las categorías
-- WHERE p.id IS NULL: filtra categorías sin productos

-- Consulta 4: Comparar LEFT vs RIGHT JOIN
-- LEFT JOIN (enfoque en productos)
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id;

-- RIGHT JOIN (enfoque en categorías)
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;

-- Explicación:
-- LEFT JOIN: perspectiva desde productos
-- RIGHT JOIN: perspectiva desde categorías
-- Resultados diferentes según el enfoque
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de JOIN:
- **INNER JOIN**: Solo registros con coincidencias en ambas tablas
- **LEFT JOIN**: Todos los registros de la tabla izquierda
- **RIGHT JOIN**: Todos los registros de la tabla derecha

### Sintaxis Básica:
```sql
SELECT columnas
FROM tabla1
[INNER|LEFT|RIGHT] JOIN tabla2 ON condicion;
```

### Cuándo Usar Cada JOIN:
- **INNER JOIN**: Cuando necesitas solo datos relacionados
- **LEFT JOIN**: Cuando necesitas todos los registros de la tabla principal
- **RIGHT JOIN**: Cuando necesitas todos los registros de la tabla secundaria

### Mejores Prácticas:
1. **Usa alias** para tablas y columnas
2. **Especifica columnas** en lugar de SELECT *
3. **Usa índices** en las columnas de JOIN
4. **Filtra después del JOIN** cuando sea posible
5. **Documenta consultas complejas**

### Funciones Útiles con JOINs:
- **COALESCE()**: Reemplaza valores NULL
- **COUNT()**: Cuenta registros
- **SUM()**: Suma valores
- **AVG()**: Calcula promedios
- **IS NULL / IS NOT NULL**: Maneja valores NULL

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- FULL OUTER JOIN para combinar LEFT y RIGHT JOIN
- Self-joins para relacionar una tabla consigo misma
- JOINs múltiples con tres o más tablas
- Técnicas avanzadas de optimización

---

## 💡 Consejos para el Éxito

1. **Practica con datos reales**: Usa ejemplos que te interesen
2. **Visualiza las relaciones**: Dibuja diagramas de las tablas
3. **Experimenta con diferentes JOINs**: Ve las diferencias
4. **Usa alias descriptivos**: Hace las consultas más legibles
5. **Optimiza con índices**: Mejora el rendimiento

---

## 🧭 Navegación

**← Anterior**: [Módulo 1: Fundamentos de Bases de Datos y SQL](../junior_1/README.md)  
**Siguiente →**: [Clase 2: JOINs Avanzados](clase_2_joins_avanzados.md)

---

*¡Excelente trabajo! Ahora dominas los JOINs básicos en SQL. 🚀*
