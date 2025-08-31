# 🔰 Junior Level 2: Consultas SELECT Básicas

## 🧭 Navegación del Curso

**← Anterior**: [Junior Level 1: Introducción a SQL](../junior_1/README.md)  
**Siguiente →**: [Junior Level 3: Filtros y Ordenamiento](../junior_3/README.md)

---

## 📖 Teoría

### ¿Qué es SELECT?
La instrucción SELECT es el comando más importante en SQL. Se utiliza para consultar y recuperar datos de las tablas de la base de datos.

### Sintaxis Básica de SELECT
```sql
SELECT columna1, columna2, ...
FROM nombre_tabla;
```

### Tipos de SELECT
1. **SELECT ***: Selecciona todas las columnas
2. **SELECT específico**: Selecciona solo columnas específicas
3. **SELECT con alias**: Usa nombres alternativos para columnas
4. **SELECT DISTINCT**: Elimina duplicados

### Operadores de Comparación
- `=` : Igual a
- `!=` o `<>` : Diferente de
- `>` : Mayor que
- `<` : Menor que
- `>=` : Mayor o igual que
- `<=` : Menor o igual que

## 💡 Ejemplos Prácticos

### Ejemplo 1: Seleccionar Todas las Columnas
```sql
-- Seleccionar todos los productos
SELECT * FROM productos;
```

### Ejemplo 2: Seleccionar Columnas Específicas
```sql
-- Seleccionar solo nombre y precio
SELECT nombre, precio FROM productos;
```

### Ejemplo 3: Usar Alias para Columnas
```sql
-- Cambiar nombres de columnas en el resultado
SELECT 
    nombre AS 'Nombre del Producto',
    precio AS 'Precio en USD'
FROM productos;
```

### Ejemplo 4: SELECT DISTINCT
```sql
-- Ver categorías únicas de productos
SELECT DISTINCT categoria FROM productos;
```

### Ejemplo 5: Combinar Múltiples Operaciones
```sql
-- Seleccionar productos con precio mayor a 50
SELECT nombre, precio, stock
FROM productos
WHERE precio > 50;
```

## 🎯 Ejercicios

### Ejercicio 1: Consulta Básica de Productos
Usando la tabla `productos` de la tienda, escribe consultas para:
1. Ver todos los productos
2. Ver solo el nombre y precio de todos los productos
3. Ver solo el nombre de los productos con stock mayor a 20

**Solución:**
```sql
-- 1. Ver todos los productos
SELECT * FROM productos;

-- 2. Ver solo nombre y precio
SELECT nombre, precio FROM productos;

-- 3. Ver nombre de productos con stock > 20
SELECT nombre FROM productos WHERE stock > 20;
```

### Ejercicio 2: Consulta de Libros
Usando la tabla `libros` de la biblioteca, escribe consultas para:
1. Ver todos los libros
2. Ver solo título y autor de todos los libros
3. Ver libros publicados después del año 2000
4. Ver solo los géneros disponibles (sin duplicados)

**Solución:**
```sql
-- 1. Ver todos los libros
SELECT * FROM libros;

-- 2. Ver solo título y autor
SELECT titulo, autor FROM libros;

-- 3. Ver libros después del 2000
SELECT * FROM libros WHERE año_publicacion > 2000;

-- 4. Ver géneros únicos
SELECT DISTINCT genero FROM libros;
```

### Ejercicio 3: Consulta de Estudiantes
Usando la tabla `estudiantes` de la escuela, escribe consultas para:
1. Ver todos los estudiantes
2. Ver solo nombre y apellido de estudiantes mayores de 15 años
3. Ver estudiantes del grado 10
4. Ver solo las edades disponibles (sin duplicados)

**Solución:**
```sql
-- 1. Ver todos los estudiantes
SELECT * FROM estudiantes;

-- 2. Ver nombre y apellido de mayores de 15
SELECT nombre, apellido FROM estudiantes WHERE edad > 15;

-- 3. Ver estudiantes del grado 10
SELECT * FROM estudiantes WHERE grado = 10;

-- 4. Ver edades únicas
SELECT DISTINCT edad FROM estudiantes;
```

### Ejercicio 4: Consulta de Platos
Usando la tabla `platos` del restaurante, escribe consultas para:
1. Ver todos los platos
2. Ver solo nombre y precio de platos de la categoría "Entrada"
3. Ver platos con precio menor a 30
4. Ver solo las categorías disponibles (sin duplicados)
5. Ver nombre y descripción de platos con precio entre 20 y 50

**Solución:**
```sql
-- 1. Ver todos los platos
SELECT * FROM platos;

-- 2. Ver nombre y precio de entradas
SELECT nombre, precio FROM platos WHERE categoria = 'Entrada';

-- 3. Ver platos baratos
SELECT * FROM platos WHERE precio < 30;

-- 4. Ver categorías únicas
SELECT DISTINCT categoria FROM platos;

-- 5. Ver platos en rango de precio
SELECT nombre, descripcion FROM platos WHERE precio BETWEEN 20 AND 50;
```

### Ejercicio 5: Consulta de Pacientes
Usando la tabla `pacientes` del hospital, escribe consultas para:
1. Ver todos los pacientes
2. Ver solo nombre y apellido de pacientes con teléfono
3. Ver pacientes nacidos antes del año 1990
4. Ver solo los nombres únicos (sin duplicados)
5. Ver nombre, apellido y dirección de pacientes sin teléfono

**Solución:**
```sql
-- 1. Ver todos los pacientes
SELECT * FROM pacientes;

-- 2. Ver nombre y apellido con teléfono
SELECT nombre, apellido FROM pacientes WHERE telefono IS NOT NULL;

-- 3. Ver pacientes nacidos antes de 1990
SELECT * FROM pacientes WHERE fecha_nacimiento < '1990-01-01';

-- 4. Ver nombres únicos
SELECT DISTINCT nombre FROM pacientes;

-- 5. Ver pacientes sin teléfono
SELECT nombre, apellido, direccion FROM pacientes WHERE telefono IS NULL;
```

## 📝 Resumen de Conceptos Clave
- ✅ SELECT es el comando principal para consultar datos
- ✅ SELECT * selecciona todas las columnas
- ✅ SELECT específico selecciona solo columnas deseadas
- ✅ WHERE filtra resultados según condiciones
- ✅ DISTINCT elimina duplicados
- ✅ AS crea alias para nombres de columnas
- ✅ Los operadores de comparación permiten filtrar datos

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/junior_3` para aprender sobre filtros avanzados y ordenamiento.

---

**💡 Consejo: Practica escribiendo diferentes consultas SELECT. Experimenta con diferentes columnas y condiciones para familiarizarte con la sintaxis.**
