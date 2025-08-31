# 🔰 Junior Level 3: Filtros y Ordenamiento

## 🧭 Navegación del Curso

**← Anterior**: [Junior Level 2: Consultas SELECT](../junior_2/README.md)  
**Siguiente →**: [Junior Level 4: Operaciones CRUD](../junior_4/README.md)

---

## 📖 Teoría

### Operadores Lógicos
- **AND**: Ambas condiciones deben ser verdaderas
- **OR**: Al menos una condición debe ser verdadera
- **NOT**: Niega la condición
- **IN**: Verifica si un valor está en una lista
- **BETWEEN**: Verifica si un valor está en un rango
- **LIKE**: Busca patrones en texto
- **IS NULL/IS NOT NULL**: Verifica valores nulos

### Ordenamiento
- **ORDER BY**: Ordena los resultados
- **ASC**: Orden ascendente (por defecto)
- **DESC**: Orden descendente

### Limitación de Resultados
- **LIMIT**: Limita el número de filas retornadas
- **OFFSET**: Salta un número específico de filas

## 💡 Ejemplos Prácticos

### Ejemplo 1: Operadores AND y OR
```sql
-- Productos con precio entre 50 y 100 Y stock mayor a 10
SELECT * FROM productos 
WHERE precio BETWEEN 50 AND 100 
AND stock > 10;

-- Productos de categoría "Electrónica" O precio mayor a 500
SELECT * FROM productos 
WHERE categoria = 'Electrónica' 
OR precio > 500;
```

### Ejemplo 2: Operador IN
```sql
-- Productos de categorías específicas
SELECT * FROM productos 
WHERE categoria IN ('Electrónica', 'Informática', 'Gaming');
```

### Ejemplo 3: Operador LIKE
```sql
-- Productos que contengan "Laptop" en el nombre
SELECT * FROM productos 
WHERE nombre LIKE '%Laptop%';

-- Productos que empiecen con "M"
SELECT * FROM productos 
WHERE nombre LIKE 'M%';
```

### Ejemplo 4: Ordenamiento
```sql
-- Productos ordenados por precio (más barato primero)
SELECT * FROM productos 
ORDER BY precio ASC;

-- Productos ordenados por nombre (A-Z)
SELECT * FROM productos 
ORDER BY nombre ASC;
```

### Ejemplo 5: LIMIT y OFFSET
```sql
-- Primeros 5 productos más caros
SELECT * FROM productos 
ORDER BY precio DESC 
LIMIT 5;

-- Productos del 6 al 10 más caros
SELECT * FROM productos 
ORDER BY precio DESC 
LIMIT 5 OFFSET 5;
```

## 🎯 Ejercicios

### Ejercicio 1: Filtros Complejos de Productos
Usando la tabla `productos` de la tienda, escribe consultas para:
1. Productos con precio entre 100 y 500 que tengan stock mayor a 5
2. Productos de categoría "Electrónica" o "Informática" con precio menor a 1000
3. Productos que NO sean de categoría "Accesorios"
4. Productos con nombre que contenga "Pro" o "Max"
5. Los 3 productos más caros

**Solución:**
```sql
-- 1. Productos en rango de precio con stock
SELECT * FROM productos 
WHERE precio BETWEEN 100 AND 500 
AND stock > 5;

-- 2. Categorías específicas con límite de precio
SELECT * FROM productos 
WHERE categoria IN ('Electrónica', 'Informática') 
AND precio < 1000;

-- 3. Excluir categoría específica
SELECT * FROM productos 
WHERE categoria != 'Accesorios';

-- 4. Nombres con patrones específicos
SELECT * FROM productos 
WHERE nombre LIKE '%Pro%' OR nombre LIKE '%Max%';

-- 5. Top 3 más caros
SELECT * FROM productos 
ORDER BY precio DESC 
LIMIT 3;
```

### Ejercicio 2: Filtros de Libros
Usando la tabla `libros` de la biblioteca, escribe consultas para:
1. Libros de género "Ficción" o "Ciencia Ficción" publicados después de 1990
2. Libros que NO sean del género "Romance"
3. Libros con título que empiece con "El" o "La"
4. Libros publicados entre 1980 y 2000
5. Los 5 libros más recientes

**Solución:**
```sql
-- 1. Géneros específicos con año
SELECT * FROM libros 
WHERE genero IN ('Ficción', 'Ciencia Ficción') 
AND año_publicacion > 1990;

-- 2. Excluir género específico
SELECT * FROM libros 
WHERE genero != 'Romance';

-- 3. Títulos que empiecen con artículos
SELECT * FROM libros 
WHERE titulo LIKE 'El %' OR titulo LIKE 'La %';

-- 4. Rango de años
SELECT * FROM libros 
WHERE año_publicacion BETWEEN 1980 AND 2000;

-- 5. Top 5 más recientes
SELECT * FROM libros 
ORDER BY año_publicacion DESC 
LIMIT 5;
```

### Ejercicio 3: Filtros de Estudiantes
Usando la tabla `estudiantes` de la escuela, escribe consultas para:
1. Estudiantes de grado 9 o 10 con edad entre 14 y 16 años
2. Estudiantes que NO sean del grado 12
3. Estudiantes con nombre que termine en "a" o "o"
4. Estudiantes de grado 11 o 12 mayores de 16 años
5. Los 10 estudiantes más jóvenes

**Solución:**
```sql
-- 1. Grados y edad específicos
SELECT * FROM estudiantes 
WHERE grado IN (9, 10) 
AND edad BETWEEN 14 AND 16;

-- 2. Excluir grado específico
SELECT * FROM estudiantes 
WHERE grado != 12;

-- 3. Nombres que terminen en vocales
SELECT * FROM estudiantes 
WHERE nombre LIKE '%a' OR nombre LIKE '%o';

-- 4. Grados superiores con edad
SELECT * FROM estudiantes 
WHERE grado IN (11, 12) 
AND edad > 16;

-- 5. Top 10 más jóvenes
SELECT * FROM estudiantes 
ORDER BY edad ASC 
LIMIT 10;
```

### Ejercicio 4: Filtros de Platos
Usando la tabla `platos` del restaurante, escribe consultas para:
1. Platos de categoría "Entrada" o "Postre" con precio menor a 25
2. Platos que NO sean de categoría "Bebida"
3. Platos con nombre que contenga "Especial" o "Casero"
4. Platos con precio entre 15 y 40 que tengan descripción
5. Los 5 platos más baratos de cada categoría

**Solución:**
```sql
-- 1. Categorías específicas con precio
SELECT * FROM platos 
WHERE categoria IN ('Entrada', 'Postre') 
AND precio < 25;

-- 2. Excluir categoría específica
SELECT * FROM platos 
WHERE categoria != 'Bebida';

-- 3. Nombres con palabras específicas
SELECT * FROM platos 
WHERE nombre LIKE '%Especial%' OR nombre LIKE '%Casero%';

-- 4. Rango de precio con descripción
SELECT * FROM platos 
WHERE precio BETWEEN 15 AND 40 
AND descripcion IS NOT NULL;

-- 5. Top 5 más baratos por categoría
SELECT * FROM platos 
ORDER BY categoria, precio ASC 
LIMIT 5;
```

### Ejercicio 5: Filtros de Pacientes
Usando la tabla `pacientes` del hospital, escribe consultas para:
1. Pacientes nacidos entre 1980 y 1995 que tengan teléfono
2. Pacientes que NO tengan dirección registrada
3. Pacientes con nombre que empiece con "Mar" o "Jos"
4. Pacientes nacidos antes de 1980 o después de 2000
5. Los 8 pacientes más jóvenes con teléfono

**Solución:**
```sql
-- 1. Rango de años con teléfono
SELECT * FROM pacientes 
WHERE fecha_nacimiento BETWEEN '1980-01-01' AND '1995-12-31' 
AND telefono IS NOT NULL;

-- 2. Sin dirección
SELECT * FROM pacientes 
WHERE direccion IS NULL;

-- 3. Nombres que empiecen con prefijos
SELECT * FROM pacientes 
WHERE nombre LIKE 'Mar%' OR nombre LIKE 'Jos%';

-- 4. Años específicos
SELECT * FROM pacientes 
WHERE fecha_nacimiento < '1980-01-01' 
OR fecha_nacimiento > '2000-12-31';

-- 5. Top 8 más jóvenes con teléfono
SELECT * FROM pacientes 
WHERE telefono IS NOT NULL 
ORDER BY fecha_nacimiento DESC 
LIMIT 8;
```

## 📝 Resumen de Conceptos Clave
- ✅ AND requiere que ambas condiciones sean verdaderas
- ✅ OR requiere que al menos una condición sea verdadera
- ✅ IN verifica si un valor está en una lista
- ✅ BETWEEN verifica si un valor está en un rango
- ✅ LIKE busca patrones en texto (% = cualquier carácter, _ = un carácter)
- ✅ ORDER BY ordena resultados (ASC ascendente, DESC descendente)
- ✅ LIMIT limita el número de filas retornadas
- ✅ OFFSET salta filas antes de retornar resultados

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/junior_4` para aprender sobre operaciones INSERT, UPDATE y DELETE.

---

**💡 Consejo: Practica combinando diferentes operadores lógicos. Los filtros complejos son muy útiles en consultas reales.**
