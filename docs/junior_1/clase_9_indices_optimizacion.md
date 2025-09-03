# Clase 9: Índices y Optimización Básica - Mejorando el Rendimiento

## 📚 Descripción de la Clase
En esta clase aprenderás sobre índices y optimización básica en SQL. Los índices son estructuras de datos que mejoran significativamente el rendimiento de las consultas, y la optimización es crucial para mantener bases de datos eficientes. Dominarás CREATE INDEX, EXPLAIN, y las mejores prácticas para optimizar consultas.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son los índices y por qué son importantes
- Crear índices simples y compuestos
- Usar EXPLAIN para analizar consultas
- Identificar consultas lentas y optimizarlas
- Aplicar mejores prácticas de optimización
- Entender el impacto de los índices en el rendimiento
- Crear índices apropiados para diferentes tipos de consultas

## ⏱️ Duración Estimada
**2-3 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son los Índices?

Los **índices** son estructuras de datos especiales que mejoran la velocidad de las consultas en bases de datos. Son como un índice de un libro que te permite encontrar información rápidamente sin leer todo el contenido.

### Beneficios de los Índices:
- **Velocidad**: Consultas más rápidas
- **Eficiencia**: Menos recursos del sistema
- **Escalabilidad**: Mejor rendimiento con grandes volúmenes de datos
- **Optimización**: Mejora automática de consultas

### Tipos de Índices:
- **Índice Simple**: Una sola columna
- **Índice Compuesto**: Múltiples columnas
- **Índice Único**: Valores únicos
- **Índice de Texto Completo**: Para búsquedas de texto

### Sintaxis General de Índices

```sql
-- Crear índice simple
CREATE INDEX nombre_indice ON tabla (columna);

-- Crear índice compuesto
CREATE INDEX nombre_indice ON tabla (columna1, columna2);

-- Crear índice único
CREATE UNIQUE INDEX nombre_indice ON tabla (columna);

-- Eliminar índice
DROP INDEX nombre_indice ON tabla;
```

**Explicación línea por línea:**
- `CREATE INDEX`: comando para crear índice
- `nombre_indice`: nombre único para el índice
- `ON tabla`: tabla donde crear el índice
- `(columna)`: columna(s) a indexar
- `UNIQUE`: especifica que los valores deben ser únicos
- `DROP INDEX`: comando para eliminar índice

### 1. Índices Simples

Los índices simples se crean sobre una sola columna.

#### 1.1 Crear Índice Simple
```sql
-- Crear índice en columna nombre
CREATE INDEX idx_nombre ON productos (nombre);

-- Crear índice en columna precio
CREATE INDEX idx_precio ON productos (precio);

-- Crear índice en columna categoria
CREATE INDEX idx_categoria ON productos (categoria);

-- Crear índice en columna fecha_creacion
CREATE INDEX idx_fecha_creacion ON productos (fecha_creacion);
```

**Explicación línea por línea:**
- `CREATE INDEX idx_nombre`: crea índice llamado idx_nombre
- `ON productos (nombre)`: en la tabla productos, columna nombre
- `CREATE INDEX idx_precio`: crea índice llamado idx_precio
- `ON productos (precio)`: en la tabla productos, columna precio

#### 1.2 Índices Únicos
```sql
-- Crear índice único en columna id
CREATE UNIQUE INDEX idx_id ON productos (id);

-- Crear índice único en columna nombre
CREATE UNIQUE INDEX idx_nombre_unico ON productos (nombre);

-- Crear índice único en columna email (si existiera)
CREATE UNIQUE INDEX idx_email ON usuarios (email);
```

**Explicación línea por línea:**
- `CREATE UNIQUE INDEX`: crea índice único
- `idx_id`: nombre del índice
- `ON productos (id)`: en la tabla productos, columna id
- `UNIQUE`: asegura que no haya valores duplicados

### 2. Índices Compuestos

Los índices compuestos se crean sobre múltiples columnas.

#### 2.1 Crear Índice Compuesto
```sql
-- Crear índice compuesto en categoria y precio
CREATE INDEX idx_categoria_precio ON productos (categoria, precio);

-- Crear índice compuesto en marca y categoria
CREATE INDEX idx_marca_categoria ON productos (marca, categoria);

-- Crear índice compuesto en categoria, marca y precio
CREATE INDEX idx_categoria_marca_precio ON productos (categoria, marca, precio);
```

**Explicación línea por línea:**
- `CREATE INDEX idx_categoria_precio`: crea índice compuesto
- `ON productos (categoria, precio)`: en la tabla productos, columnas categoria y precio
- `idx_marca_categoria`: índice en marca y categoria
- `idx_categoria_marca_precio`: índice en tres columnas

#### 2.2 Orden de Columnas en Índices Compuestos
```sql
-- Índice compuesto: categoria primero, precio segundo
CREATE INDEX idx_categoria_precio ON productos (categoria, precio);

-- Este índice es útil para:
-- WHERE categoria = 'Electrónicos'
-- WHERE categoria = 'Electrónicos' AND precio > 100
-- WHERE categoria = 'Electrónicos' AND precio BETWEEN 50 AND 200

-- Pero NO es útil para:
-- WHERE precio > 100 (sin especificar categoria)
```

**Explicación línea por línea:**
- `(categoria, precio)`: orden de columnas en el índice
- `categoria primero`: columna más selectiva primero
- `precio segundo`: columna menos selectiva segundo
- **Regla**: Columna más selectiva primero

### 3. Análisis de Consultas con EXPLAIN

EXPLAIN muestra cómo MySQL ejecuta una consulta.

#### 3.1 Uso Básico de EXPLAIN
```sql
-- Analizar consulta simple
EXPLAIN SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion';

-- Analizar consulta con JOIN
EXPLAIN SELECT p.nombre, c.nombre FROM productos p JOIN categorias c ON p.categoria_id = c.id;

-- Analizar consulta con ORDER BY
EXPLAIN SELECT * FROM productos ORDER BY precio DESC;

-- Analizar consulta con GROUP BY
EXPLAIN SELECT categoria, COUNT(*) FROM productos GROUP BY categoria;
```

**Explicación línea por línea:**
- `EXPLAIN`: comando para analizar consulta
- `SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion'`: consulta a analizar
- `EXPLAIN`: muestra el plan de ejecución
- **Resultado**: Información sobre cómo se ejecuta la consulta

#### 3.2 Interpretar Resultados de EXPLAIN
```sql
-- Ejemplo de resultado de EXPLAIN
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Columnas importantes del resultado:
-- id: Número de secuencia
-- select_type: Tipo de consulta
-- table: Tabla involucrada
-- type: Tipo de acceso (ALL, index, range, ref, const)
-- possible_keys: Índices que podrían usarse
-- key: Índice realmente usado
-- key_len: Longitud del índice usado
-- ref: Columnas comparadas con el índice
-- rows: Número de filas examinadas
-- Extra: Información adicional
```

**Explicación línea por línea:**
- `id`: número de secuencia de la consulta
- `select_type`: tipo de consulta (SIMPLE, PRIMARY, SUBQUERY, etc.)
- `table`: tabla involucrada en la consulta
- `type`: tipo de acceso a los datos
- `possible_keys`: índices que podrían usarse
- `key`: índice realmente usado
- `rows`: número de filas examinadas

### 4. Tipos de Acceso en EXPLAIN

Los tipos de acceso indican cómo MySQL accede a los datos.

#### 4.1 Tipos de Acceso Comunes
```sql
-- ALL: Escaneo completo de tabla (lento)
EXPLAIN SELECT * FROM productos WHERE descripcion LIKE '%gaming%';

-- index: Escaneo completo del índice (más rápido que ALL)
EXPLAIN SELECT categoria FROM productos;

-- range: Acceso por rango usando índice
EXPLAIN SELECT * FROM productos WHERE precio BETWEEN 100 AND 500;

-- ref: Acceso por valor único usando índice
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- const: Acceso por valor constante (más rápido)
EXPLAIN SELECT * FROM productos WHERE id = 1;
```

**Explicación línea por línea:**
- `ALL`: escaneo completo de tabla (más lento)
- `index`: escaneo completo del índice (más rápido)
- `range`: acceso por rango usando índice
- `ref`: acceso por valor único usando índice
- `const`: acceso por valor constante (más rápido)

#### 4.2 Optimizar Consultas Lentas
```sql
-- Consulta lenta (sin índice)
EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%HP%';

-- Crear índice para mejorar rendimiento
CREATE INDEX idx_nombre ON productos (nombre);

-- Consulta optimizada (con índice)
EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%HP%';

-- Consulta con índice en columna específica
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100;
```

**Explicación línea por línea:**
- `EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%HP%'`: consulta a analizar
- `CREATE INDEX idx_nombre ON productos (nombre)`: crea índice para mejorar rendimiento
- `EXPLAIN`: analiza la consulta después de crear el índice
- **Resultado**: Mejor rendimiento con índice

### 5. Mejores Prácticas de Optimización

Las mejores prácticas ayudan a mantener bases de datos eficientes.

#### 5.1 Cuándo Crear Índices
```sql
-- Crear índices en columnas frecuentemente consultadas
CREATE INDEX idx_categoria ON productos (categoria);

-- Crear índices en columnas usadas en WHERE
CREATE INDEX idx_precio ON productos (precio);

-- Crear índices en columnas usadas en ORDER BY
CREATE INDEX idx_fecha_creacion ON productos (fecha_creacion);

-- Crear índices en columnas usadas en JOIN
CREATE INDEX idx_categoria_id ON productos (categoria_id);
```

**Explicación línea por línea:**
- `CREATE INDEX idx_categoria`: crea índice en columna frecuentemente consultada
- `CREATE INDEX idx_precio`: crea índice en columna usada en WHERE
- `CREATE INDEX idx_fecha_creacion`: crea índice en columna usada en ORDER BY
- `CREATE INDEX idx_categoria_id`: crea índice en columna usada en JOIN

#### 5.2 Cuándo NO Crear Índices
```sql
-- NO crear índices en tablas pequeñas
-- NO crear índices en columnas raramente consultadas
-- NO crear índices en columnas que cambian frecuentemente
-- NO crear demasiados índices (afecta rendimiento de INSERT/UPDATE/DELETE)

-- Ejemplo de tabla pequeña (no necesita índice)
CREATE TABLE configuracion (
    id INT PRIMARY KEY,
    nombre VARCHAR(50),
    valor VARCHAR(100)
);
-- Solo 10 registros, no necesita índices adicionales
```

**Explicación línea por línea:**
- **NO crear índices en tablas pequeñas**: el costo supera el beneficio
- **NO crear índices en columnas raramente consultadas**: desperdicio de recursos
- **NO crear índices en columnas que cambian frecuentemente**: afecta rendimiento
- **NO crear demasiados índices**: afecta rendimiento de operaciones de escritura

#### 5.3 Optimizar Consultas Específicas
```sql
-- Consulta lenta: buscar productos por descripción
SELECT * FROM productos WHERE descripcion LIKE '%gaming%';

-- Optimización 1: Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion ON productos (descripcion);

-- Consulta optimizada: usar MATCH AGAINST
SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('gaming');

-- Optimización 2: Limitar resultados
SELECT * FROM productos WHERE descripcion LIKE '%gaming%' LIMIT 10;

-- Optimización 3: Seleccionar solo columnas necesarias
SELECT nombre, precio FROM productos WHERE descripcion LIKE '%gaming%';
```

**Explicación línea por línea:**
- `CREATE FULLTEXT INDEX idx_descripcion ON productos (descripcion)`: crea índice de texto completo
- `MATCH(descripcion) AGAINST('gaming')`: usa búsqueda de texto completo
- `LIMIT 10`: limita resultados a 10 registros
- `SELECT nombre, precio`: selecciona solo columnas necesarias

### 6. Monitoreo y Mantenimiento

El monitoreo y mantenimiento son cruciales para el rendimiento.

#### 6.1 Verificar Índices Existentes
```sql
-- Ver todos los índices de una tabla
SHOW INDEX FROM productos;

-- Ver índices de todas las tablas
SHOW INDEX FROM productos;
SHOW INDEX FROM categorias;
SHOW INDEX FROM marcas;

-- Ver información detallada de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'tu_base_datos' 
  AND TABLE_NAME = 'productos';
```

**Explicación línea por línea:**
- `SHOW INDEX FROM productos`: muestra todos los índices de la tabla productos
- `SHOW INDEX FROM categorias`: muestra índices de la tabla categorias
- `SELECT ... FROM information_schema.STATISTICS`: consulta detallada de índices
- `TABLE_SCHEMA = 'tu_base_datos'`: filtra por base de datos específica

#### 6.2 Eliminar Índices Innecesarios
```sql
-- Eliminar índice simple
DROP INDEX idx_nombre ON productos;

-- Eliminar índice compuesto
DROP INDEX idx_categoria_precio ON productos;

-- Eliminar índice único
DROP INDEX idx_nombre_unico ON productos;

-- Verificar que el índice fue eliminado
SHOW INDEX FROM productos;
```

**Explicación línea por línea:**
- `DROP INDEX idx_nombre ON productos`: elimina índice llamado idx_nombre
- `DROP INDEX idx_categoria_precio ON productos`: elimina índice compuesto
- `DROP INDEX idx_nombre_unico ON productos`: elimina índice único
- `SHOW INDEX FROM productos`: verifica que el índice fue eliminado

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Optimización de Productos

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE indices_optimizacion;
USE indices_optimizacion;

-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria VARCHAR(50),
    marca VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, stock, categoria, marca) VALUES
('Laptop HP Pavilion', 'Laptop de 15 pulgadas con procesador Intel i5', 899.99, 10, 'Electrónicos', 'HP'),
('Mouse Logitech', 'Mouse óptico inalámbrico', 25.50, 50, 'Accesorios', 'Logitech'),
('Teclado Mecánico RGB', 'Teclado mecánico con iluminación RGB', 89.99, 15, 'Accesorios', 'Corsair'),
('Monitor Samsung 24"', 'Monitor LED de 24 pulgadas Full HD', 199.99, 8, 'Electrónicos', 'Samsung'),
('Auriculares Sony WH-1000XM4', 'Auriculares inalámbricos con cancelación de ruido', 349.99, 20, 'Accesorios', 'Sony'),
('Tablet iPad Air', 'Tablet Apple de 10.9 pulgadas', 599.99, 12, 'Electrónicos', 'Apple'),
('Cargador USB-C 65W', 'Cargador rápido de 65W para laptop', 29.99, 30, 'Accesorios', 'Anker'),
('Smartphone iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 5, 'Electrónicos', 'Apple'),
('Laptop Dell XPS 13', 'Laptop ultrabook de 13 pulgadas', 1299.99, 3, 'Electrónicos', 'Dell'),
('Mousepad Gaming', 'Mousepad para gaming con superficie optimizada', 19.99, 25, 'Accesorios', 'SteelSeries'),
('Laptop Lenovo ThinkPad', 'Laptop empresarial de 14 pulgadas', 799.99, 7, 'Electrónicos', 'Lenovo'),
('Teclado Inalámbrico Logitech', 'Teclado inalámbrico compacto', 45.99, 18, 'Accesorios', 'Logitech');
```

### Ejemplo 2: Crear Índices Básicos

```sql
-- Consulta 1: Crear índice en columna nombre
CREATE INDEX idx_nombre ON productos (nombre);

-- Explicación línea por línea:
-- CREATE INDEX idx_nombre: crea índice llamado idx_nombre
-- ON productos (nombre): en la tabla productos, columna nombre
-- Mejora consultas que buscan por nombre

-- Consulta 2: Crear índice en columna precio
CREATE INDEX idx_precio ON productos (precio);

-- Explicación línea por línea:
-- CREATE INDEX idx_precio: crea índice llamado idx_precio
-- ON productos (precio): en la tabla productos, columna precio
-- Mejora consultas que filtran por precio

-- Consulta 3: Crear índice en columna categoria
CREATE INDEX idx_categoria ON productos (categoria);

-- Explicación línea por línea:
-- CREATE INDEX idx_categoria: crea índice llamado idx_categoria
-- ON productos (categoria): en la tabla productos, columna categoria
-- Mejora consultas que filtran por categoría

-- Consulta 4: Crear índice en columna fecha_creacion
CREATE INDEX idx_fecha_creacion ON productos (fecha_creacion);

-- Explicación línea por línea:
-- CREATE INDEX idx_fecha_creacion: crea índice llamado idx_fecha_creacion
-- ON productos (fecha_creacion): en la tabla productos, columna fecha_creacion
-- Mejora consultas que ordenan por fecha

-- Consulta 5: Verificar índices creados
SHOW INDEX FROM productos;

-- Explicación línea por línea:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices con información detallada
```

### Ejemplo 3: Crear Índices Compuestos

```sql
-- Consulta 1: Crear índice compuesto en categoria y precio
CREATE INDEX idx_categoria_precio ON productos (categoria, precio);

-- Explicación línea por línea:
-- CREATE INDEX idx_categoria_precio: crea índice compuesto
-- ON productos (categoria, precio): en la tabla productos, columnas categoria y precio
-- Mejora consultas que filtran por categoría y precio

-- Consulta 2: Crear índice compuesto en marca y categoria
CREATE INDEX idx_marca_categoria ON productos (marca, categoria);

-- Explicación línea por línea:
-- CREATE INDEX idx_marca_categoria: crea índice compuesto
-- ON productos (marca, categoria): en la tabla productos, columnas marca y categoria
-- Mejora consultas que filtran por marca y categoría

-- Consulta 3: Crear índice compuesto en categoria, marca y precio
CREATE INDEX idx_categoria_marca_precio ON productos (categoria, marca, precio);

-- Explicación línea por línea:
-- CREATE INDEX idx_categoria_marca_precio: crea índice compuesto
-- ON productos (categoria, marca, precio): en la tabla productos, tres columnas
-- Mejora consultas que filtran por categoría, marca y precio

-- Consulta 4: Verificar índices compuestos
SHOW INDEX FROM productos;

-- Explicación línea por línea:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices incluyendo los compuestos
```

### Ejemplo 4: Análisis con EXPLAIN

```sql
-- Consulta 1: Analizar consulta simple
EXPLAIN SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion';

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion': consulta a analizar
-- Resultado: Información sobre cómo se ejecuta la consulta

-- Consulta 2: Analizar consulta con filtro por categoría
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE categoria = 'Electrónicos': consulta a analizar
-- Resultado: Información sobre el uso del índice idx_categoria

-- Consulta 3: Analizar consulta con filtro por precio
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE precio > 100: consulta a analizar
-- Resultado: Información sobre el uso del índice idx_precio

-- Consulta 4: Analizar consulta con filtro compuesto
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100;

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100: consulta a analizar
-- Resultado: Información sobre el uso del índice idx_categoria_precio

-- Consulta 5: Analizar consulta con ORDER BY
EXPLAIN SELECT * FROM productos ORDER BY precio DESC;

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos ORDER BY precio DESC: consulta a analizar
-- Resultado: Información sobre el uso del índice idx_precio para ordenamiento
```

### Ejemplo 5: Optimización de Consultas

```sql
-- Consulta 1: Consulta lenta (sin índice en descripción)
EXPLAIN SELECT * FROM productos WHERE descripcion LIKE '%gaming%';

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE descripcion LIKE '%gaming%': consulta a analizar
-- Resultado: Probablemente muestra type = ALL (escaneo completo)

-- Consulta 2: Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion ON productos (descripcion);

-- Explicación línea por línea:
-- CREATE FULLTEXT INDEX idx_descripcion: crea índice de texto completo
-- ON productos (descripcion): en la tabla productos, columna descripcion
-- Mejora búsquedas de texto completo

-- Consulta 3: Consulta optimizada con MATCH AGAINST
EXPLAIN SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('gaming');

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('gaming'): consulta optimizada
-- Resultado: Mejor rendimiento con índice de texto completo

-- Consulta 4: Consulta optimizada con LIMIT
EXPLAIN SELECT * FROM productos WHERE descripcion LIKE '%gaming%' LIMIT 10;

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE descripcion LIKE '%gaming%' LIMIT 10: consulta con límite
-- Resultado: Mejor rendimiento al limitar resultados

-- Consulta 5: Consulta optimizada seleccionando solo columnas necesarias
EXPLAIN SELECT nombre, precio FROM productos WHERE descripcion LIKE '%gaming%';

-- Explicación línea por línea:
-- EXPLAIN: comando para analizar consulta
-- SELECT nombre, precio FROM productos WHERE descripcion LIKE '%gaming%': consulta optimizada
-- Resultado: Mejor rendimiento al seleccionar solo columnas necesarias
```

### Ejemplo 6: Monitoreo y Mantenimiento

```sql
-- Consulta 1: Ver todos los índices de la tabla
SHOW INDEX FROM productos;

-- Explicación línea por línea:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices con información detallada

-- Consulta 2: Ver información detallada de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'indices_optimizacion' 
  AND TABLE_NAME = 'productos';

-- Explicación línea por línea:
-- SELECT ... FROM information_schema.STATISTICS: consulta detallada de índices
-- WHERE TABLE_SCHEMA = 'indices_optimizacion': filtra por base de datos específica
-- AND TABLE_NAME = 'productos': filtra por tabla específica
-- Resultado: Información detallada de índices

-- Consulta 3: Eliminar índice innecesario
DROP INDEX idx_nombre ON productos;

-- Explicación línea por línea:
-- DROP INDEX idx_nombre ON productos: elimina índice llamado idx_nombre
-- Resultado: Índice eliminado de la tabla

-- Consulta 4: Verificar que el índice fue eliminado
SHOW INDEX FROM productos;

-- Explicación línea por línea:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices sin el índice eliminado

-- Consulta 5: Eliminar índice compuesto
DROP INDEX idx_categoria_precio ON productos;

-- Explicación línea por línea:
-- DROP INDEX idx_categoria_precio ON productos: elimina índice compuesto
-- Resultado: Índice compuesto eliminado de la tabla
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Crear Índices Básicos
**Objetivo**: Practicar creación de índices simples.

**Instrucciones**:
1. Crear índice en columna nombre
2. Crear índice en columna precio
3. Crear índice en columna categoria
4. Crear índice en columna fecha_creacion

**Solución paso a paso:**

```sql
-- Consulta 1: Crear índice en columna nombre
CREATE INDEX idx_nombre ON productos (nombre);

-- Explicación:
-- CREATE INDEX idx_nombre: crea índice llamado idx_nombre
-- ON productos (nombre): en la tabla productos, columna nombre
-- Mejora consultas que buscan por nombre

-- Consulta 2: Crear índice en columna precio
CREATE INDEX idx_precio ON productos (precio);

-- Explicación:
-- CREATE INDEX idx_precio: crea índice llamado idx_precio
-- ON productos (precio): en la tabla productos, columna precio
-- Mejora consultas que filtran por precio

-- Consulta 3: Crear índice en columna categoria
CREATE INDEX idx_categoria ON productos (categoria);

-- Explicación:
-- CREATE INDEX idx_categoria: crea índice llamado idx_categoria
-- ON productos (categoria): en la tabla productos, columna categoria
-- Mejora consultas que filtran por categoría

-- Consulta 4: Crear índice en columna fecha_creacion
CREATE INDEX idx_fecha_creacion ON productos (fecha_creacion);

-- Explicación:
-- CREATE INDEX idx_fecha_creacion: crea índice llamado idx_fecha_creacion
-- ON productos (fecha_creacion): en la tabla productos, columna fecha_creacion
-- Mejora consultas que ordenan por fecha
```

### Ejercicio 2: Crear Índices Compuestos
**Objetivo**: Practicar creación de índices compuestos.

**Instrucciones**:
1. Crear índice compuesto en categoria y precio
2. Crear índice compuesto en marca y categoria
3. Crear índice compuesto en categoria, marca y precio
4. Verificar índices creados

**Solución paso a paso:**

```sql
-- Consulta 1: Crear índice compuesto en categoria y precio
CREATE INDEX idx_categoria_precio ON productos (categoria, precio);

-- Explicación:
-- CREATE INDEX idx_categoria_precio: crea índice compuesto
-- ON productos (categoria, precio): en la tabla productos, columnas categoria y precio
-- Mejora consultas que filtran por categoría y precio

-- Consulta 2: Crear índice compuesto en marca y categoria
CREATE INDEX idx_marca_categoria ON productos (marca, categoria);

-- Explicación:
-- CREATE INDEX idx_marca_categoria: crea índice compuesto
-- ON productos (marca, categoria): en la tabla productos, columnas marca y categoria
-- Mejora consultas que filtran por marca y categoría

-- Consulta 3: Crear índice compuesto en categoria, marca y precio
CREATE INDEX idx_categoria_marca_precio ON productos (categoria, marca, precio);

-- Explicación:
-- CREATE INDEX idx_categoria_marca_precio: crea índice compuesto
-- ON productos (categoria, marca, precio): en la tabla productos, tres columnas
-- Mejora consultas que filtran por categoría, marca y precio

-- Consulta 4: Verificar índices creados
SHOW INDEX FROM productos;

-- Explicación:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices incluyendo los compuestos
```

### Ejercicio 3: Análisis con EXPLAIN
**Objetivo**: Practicar análisis de consultas con EXPLAIN.

**Instrucciones**:
1. Analizar consulta simple
2. Analizar consulta con filtro por categoría
3. Analizar consulta con filtro por precio
4. Analizar consulta con filtro compuesto

**Solución paso a paso:**

```sql
-- Consulta 1: Analizar consulta simple
EXPLAIN SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion';

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE nombre = 'Laptop HP Pavilion': consulta a analizar
-- Resultado: Información sobre cómo se ejecuta la consulta

-- Consulta 2: Analizar consulta con filtro por categoría
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE categoria = 'Electrónicos': consulta a analizar
-- Resultado: Información sobre el uso del índice idx_categoria

-- Consulta 3: Analizar consulta con filtro por precio
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE precio > 100: consulta a analizar
-- Resultado: Información sobre el uso del índice idx_precio

-- Consulta 4: Analizar consulta con filtro compuesto
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100;

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100: consulta a analizar
-- Resultado: Información sobre el uso del índice idx_categoria_precio
```

### Ejercicio 4: Optimización de Consultas
**Objetivo**: Practicar optimización de consultas lentas.

**Instrucciones**:
1. Analizar consulta lenta
2. Crear índice para mejorar rendimiento
3. Analizar consulta optimizada
4. Comparar resultados

**Solución paso a paso:**

```sql
-- Consulta 1: Analizar consulta lenta
EXPLAIN SELECT * FROM productos WHERE descripcion LIKE '%gaming%';

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE descripcion LIKE '%gaming%': consulta a analizar
-- Resultado: Probablemente muestra type = ALL (escaneo completo)

-- Consulta 2: Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion ON productos (descripcion);

-- Explicación:
-- CREATE FULLTEXT INDEX idx_descripcion: crea índice de texto completo
-- ON productos (descripcion): en la tabla productos, columna descripcion
-- Mejora búsquedas de texto completo

-- Consulta 3: Analizar consulta optimizada
EXPLAIN SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('gaming');

-- Explicación:
-- EXPLAIN: comando para analizar consulta
-- SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('gaming'): consulta optimizada
-- Resultado: Mejor rendimiento con índice de texto completo

-- Consulta 4: Comparar resultados
-- Antes: type = ALL, rows = 12 (escaneo completo)
-- Después: type = fulltext, rows = 1 (búsqueda optimizada)
-- Mejora significativa en rendimiento
```

### Ejercicio 5: Monitoreo y Mantenimiento
**Objetivo**: Practicar monitoreo y mantenimiento de índices.

**Instrucciones**:
1. Ver todos los índices de la tabla
2. Ver información detallada de índices
3. Eliminar índice innecesario
4. Verificar que el índice fue eliminado

**Solución paso a paso:**

```sql
-- Consulta 1: Ver todos los índices de la tabla
SHOW INDEX FROM productos;

-- Explicación:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices con información detallada

-- Consulta 2: Ver información detallada de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'indices_optimizacion' 
  AND TABLE_NAME = 'productos';

-- Explicación:
-- SELECT ... FROM information_schema.STATISTICS: consulta detallada de índices
-- WHERE TABLE_SCHEMA = 'indices_optimizacion': filtra por base de datos específica
-- AND TABLE_NAME = 'productos': filtra por tabla específica
-- Resultado: Información detallada de índices

-- Consulta 3: Eliminar índice innecesario
DROP INDEX idx_nombre ON productos;

-- Explicación:
-- DROP INDEX idx_nombre ON productos: elimina índice llamado idx_nombre
-- Resultado: Índice eliminado de la tabla

-- Consulta 4: Verificar que el índice fue eliminado
SHOW INDEX FROM productos;

-- Explicación:
-- SHOW INDEX FROM productos: muestra todos los índices de la tabla productos
-- Resultado: Lista de índices sin el índice eliminado
```

---

## 📝 Resumen de Conceptos Clave

### Índices:
- **Índice Simple**: Una sola columna
- **Índice Compuesto**: Múltiples columnas
- **Índice Único**: Valores únicos
- **Índice de Texto Completo**: Para búsquedas de texto

### Comandos de Índices:
- **CREATE INDEX**: Crear índice
- **CREATE UNIQUE INDEX**: Crear índice único
- **DROP INDEX**: Eliminar índice
- **SHOW INDEX**: Ver índices existentes

### Análisis con EXPLAIN:
- **ALL**: Escaneo completo de tabla (lento)
- **index**: Escaneo completo del índice (más rápido)
- **range**: Acceso por rango usando índice
- **ref**: Acceso por valor único usando índice
- **const**: Acceso por valor constante (más rápido)

### Mejores Prácticas:
1. **Crear índices** en columnas frecuentemente consultadas
2. **Usar índices compuestos** para consultas complejas
3. **Analizar consultas** con EXPLAIN
4. **Optimizar consultas** lentas
5. **Monitorear índices** regularmente
6. **Eliminar índices** innecesarios

### Cuándo Crear Índices:
- **Columnas en WHERE**: Filtros frecuentes
- **Columnas en ORDER BY**: Ordenamiento frecuente
- **Columnas en JOIN**: Relaciones entre tablas
- **Columnas en GROUP BY**: Agrupación frecuente

### Cuándo NO Crear Índices:
- **Tablas pequeñas**: El costo supera el beneficio
- **Columnas raramente consultadas**: Desperdicio de recursos
- **Columnas que cambian frecuentemente**: Afecta rendimiento
- **Demasiados índices**: Afecta rendimiento de escritura

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Proyecto integrador completo
- Sistema de gestión de biblioteca
- Aplicación de todos los conceptos aprendidos
- Creación de base de datos completa

---

## 💡 Consejos para el Éxito

1. **Practica con datos reales**: Usa ejemplos que te interesen
2. **Analiza consultas**: Usa EXPLAIN para entender el rendimiento
3. **Crea índices apropiados**: Basándote en patrones de consulta
4. **Monitorea regularmente**: Verifica el rendimiento de los índices
5. **Documenta cambios**: Mantén registro de optimizaciones

---

## 🧭 Navegación

**← Anterior**: [Clase 8: Ordenamiento y Agrupación](clase_8_ordenamiento_agrupacion.md)  
**Siguiente →**: [Clase 10: Proyecto Integrador](clase_10_proyecto_integrador.md)

---

*¡Excelente trabajo! Ahora dominas los índices y optimización básica en SQL. 🚀*
