# 🔰 Junior Level 4: Operaciones INSERT, UPDATE, DELETE

## 🧭 Navegación del Curso

**← Anterior**: [Junior Level 3: Filtros y Ordenamiento](../junior_3/README.md)  
**Siguiente →**: [Junior Level 5: Funciones Básicas](../junior_5/README.md)

---

## 📖 Teoría

### Operaciones CRUD
CRUD son las operaciones básicas de una base de datos:
- **C**reate (Crear): INSERT
- **R**ead (Leer): SELECT
- **U**pdate (Actualizar): UPDATE
- **D**elete (Eliminar): DELETE

### INSERT - Insertar Datos
```sql
INSERT INTO tabla (columna1, columna2, ...) 
VALUES (valor1, valor2, ...);
```

### UPDATE - Actualizar Datos
```sql
UPDATE tabla 
SET columna1 = valor1, columna2 = valor2, ... 
WHERE condicion;
```

### DELETE - Eliminar Datos
```sql
DELETE FROM tabla 
WHERE condicion;
```

### ⚠️ Importante
- **Siempre usa WHERE** en UPDATE y DELETE para evitar modificar/eliminar todos los registros
- **Haz backup** antes de operaciones destructivas
- **Prueba primero** con SELECT para ver qué se va a modificar

## 💡 Ejemplos Prácticos

### Ejemplo 1: INSERT Simple
```sql
-- Insertar un producto
INSERT INTO productos (nombre, precio, stock, categoria) 
VALUES ('Monitor 24"', 199.99, 25, 'Electrónica');
```

### Ejemplo 2: INSERT Múltiple
```sql
-- Insertar varios productos a la vez
INSERT INTO productos (nombre, precio, stock, categoria) VALUES
('Teclado RGB', 79.99, 30, 'Accesorios'),
('Mouse Gaming', 45.50, 40, 'Accesorios'),
('Webcam HD', 89.99, 15, 'Electrónica');
```

### Ejemplo 3: UPDATE Simple
```sql
-- Actualizar precio de un producto específico
UPDATE productos 
SET precio = 189.99 
WHERE nombre = 'Monitor 24"';
```

### Ejemplo 4: UPDATE Múltiple
```sql
-- Actualizar stock de productos de una categoría
UPDATE productos 
SET stock = stock + 10 
WHERE categoria = 'Accesorios';
```

### Ejemplo 5: DELETE Condicional
```sql
-- Eliminar productos sin stock
DELETE FROM productos 
WHERE stock = 0;
```

## 🎯 Ejercicios

### Ejercicio 1: Operaciones con Productos
Usando la tabla `productos` de la tienda, realiza las siguientes operaciones:

1. **Insertar** 3 nuevos productos de diferentes categorías
2. **Actualizar** el precio de todos los productos de categoría "Electrónica" aumentándolos en un 10%
3. **Actualizar** el stock de productos con precio mayor a 100, reduciéndolo en 5 unidades
4. **Eliminar** productos con stock menor a 3
5. **Insertar** un producto con nombre "Auriculares Bluetooth" y precio 59.99

**Solución:**
```sql
-- 1. Insertar 3 productos
INSERT INTO productos (nombre, precio, stock, categoria) VALUES
('Tablet Samsung', 299.99, 20, 'Electrónica'),
('Impresora HP', 149.99, 8, 'Informática'),
('Cámara Digital', 399.99, 12, 'Electrónica');

-- 2. Aumentar precio de electrónica en 10%
UPDATE productos 
SET precio = precio * 1.10 
WHERE categoria = 'Electrónica';

-- 3. Reducir stock de productos caros
UPDATE productos 
SET stock = stock - 5 
WHERE precio > 100;

-- 4. Eliminar productos con poco stock
DELETE FROM productos 
WHERE stock < 3;

-- 5. Insertar auriculares
INSERT INTO productos (nombre, precio, stock, categoria) 
VALUES ('Auriculares Bluetooth', 59.99, 35, 'Accesorios');
```

### Ejercicio 2: Operaciones con Libros
Usando la tabla `libros` de la biblioteca, realiza las siguientes operaciones:

1. **Insertar** 4 libros de diferentes géneros y años
2. **Actualizar** el género de todos los libros publicados antes de 1990 a "Clásico"
3. **Actualizar** el año de publicación de libros de "Ciencia Ficción" sumándoles 5 años
4. **Eliminar** libros sin género especificado
5. **Insertar** un libro de tu autor favorito

**Solución:**
```sql
-- 1. Insertar 4 libros
INSERT INTO libros (titulo, autor, año_publicacion, genero) VALUES
('El Señor de los Anillos', 'J.R.R. Tolkien', 1954, 'Fantasía'),
('1984', 'George Orwell', 1949, 'Ciencia Ficción'),
('Cien Años de Soledad', 'Gabriel García Márquez', 1967, 'Realismo Mágico'),
('El Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasía');

-- 2. Actualizar género de libros antiguos
UPDATE libros 
SET genero = 'Clásico' 
WHERE año_publicacion < 1990;

-- 3. Actualizar año de ciencia ficción
UPDATE libros 
SET año_publicacion = año_publicacion + 5 
WHERE genero = 'Ciencia Ficción';

-- 4. Eliminar libros sin género
DELETE FROM libros 
WHERE genero IS NULL;

-- 5. Insertar libro favorito (ejemplo)
INSERT INTO libros (titulo, autor, año_publicacion, genero) 
VALUES ('El Principito', 'Antoine de Saint-Exupéry', 1943, 'Ficción');
```

### Ejercicio 3: Operaciones con Estudiantes
Usando la tabla `estudiantes` de la escuela, realiza las siguientes operaciones:

1. **Insertar** 5 estudiantes de diferentes grados
2. **Actualizar** la edad de todos los estudiantes del grado 9 sumándoles 1 año
3. **Actualizar** el grado de estudiantes mayores de 18 años al grado 12
4. **Eliminar** estudiantes sin grado especificado
5. **Insertar** un estudiante con tu nombre

**Solución:**
```sql
-- 1. Insertar 5 estudiantes
INSERT INTO estudiantes (nombre, apellido, edad, grado) VALUES
('Ana', 'García', 15, 9),
('Carlos', 'López', 16, 10),
('María', 'Rodríguez', 17, 11),
('Juan', 'Martínez', 18, 12),
('Laura', 'Fernández', 14, 9);

-- 2. Aumentar edad de grado 9
UPDATE estudiantes 
SET edad = edad + 1 
WHERE grado = 9;

-- 3. Actualizar grado de mayores de 18
UPDATE estudiantes 
SET grado = 12 
WHERE edad > 18;

-- 4. Eliminar estudiantes sin grado
DELETE FROM estudiantes 
WHERE grado IS NULL;

-- 5. Insertar estudiante (ejemplo)
INSERT INTO estudiantes (nombre, apellido, edad, grado) 
VALUES ('TuNombre', 'TuApellido', 16, 10);
```

### Ejercicio 4: Operaciones con Platos
Usando la tabla `platos` del restaurante, realiza las siguientes operaciones:

1. **Insertar** 3 platos de diferentes categorías
2. **Actualizar** el precio de todos los platos de "Entrada" reduciéndolos en un 15%
3. **Actualizar** la descripción de platos sin descripción a "Descripción pendiente"
4. **Eliminar** platos con precio mayor a 100
5. **Insertar** tu plato favorito

**Solución:**
```sql
-- 1. Insertar 3 platos
INSERT INTO platos (nombre, descripcion, precio, categoria) VALUES
('Ensalada César', 'Lechuga romana, crutones, parmesano', 12.99, 'Entrada'),
('Pasta Carbonara', 'Espaguetis con salsa cremosa y panceta', 18.99, 'Plato Principal'),
('Tiramisú', 'Postre italiano con café y mascarpone', 8.99, 'Postre');

-- 2. Reducir precio de entradas en 15%
UPDATE platos 
SET precio = precio * 0.85 
WHERE categoria = 'Entrada';

-- 3. Actualizar descripciones vacías
UPDATE platos 
SET descripcion = 'Descripción pendiente' 
WHERE descripcion IS NULL;

-- 4. Eliminar platos caros
DELETE FROM platos 
WHERE precio > 100;

-- 5. Insertar plato favorito (ejemplo)
INSERT INTO platos (nombre, descripcion, precio, categoria) 
VALUES ('Pizza Margherita', 'Pizza tradicional con tomate y mozzarella', 16.99, 'Plato Principal');
```

### Ejercicio 5: Operaciones con Pacientes
Usando la tabla `pacientes` del hospital, realiza las siguientes operaciones:

1. **Insertar** 4 pacientes con diferentes fechas de nacimiento
2. **Actualizar** la dirección de pacientes sin dirección a "Dirección no registrada"
3. **Actualizar** el teléfono de pacientes nacidos antes de 1980 agregando prefijo "+1-"
4. **Eliminar** pacientes sin nombre o apellido
5. **Insertar** un paciente con tu información

**Solución:**
```sql
-- 1. Insertar 4 pacientes
INSERT INTO pacientes (nombre, apellido, fecha_nacimiento, telefono, direccion) VALUES
('Roberto', 'Silva', '1985-03-15', '555-0101', 'Calle Principal 123'),
('Carmen', 'Vargas', '1992-07-22', '555-0102', 'Avenida Central 456'),
('Miguel', 'Torres', '1978-11-08', '555-0103', 'Boulevard Norte 789'),
('Isabel', 'Cruz', '1995-04-30', '555-0104', 'Plaza Sur 321');

-- 2. Actualizar direcciones vacías
UPDATE pacientes 
SET direccion = 'Dirección no registrada' 
WHERE direccion IS NULL;

-- 3. Agregar prefijo a teléfonos de pacientes mayores
UPDATE pacientes 
SET telefono = CONCAT('+1-', telefono) 
WHERE fecha_nacimiento < '1980-01-01';

-- 4. Eliminar pacientes sin nombre o apellido
DELETE FROM pacientes 
WHERE nombre IS NULL OR apellido IS NULL;

-- 5. Insertar paciente (ejemplo)
INSERT INTO pacientes (nombre, apellido, fecha_nacimiento, telefono, direccion) 
VALUES ('TuNombre', 'TuApellido', '1990-01-01', '555-9999', 'Tu Dirección');
```

## 📝 Resumen de Conceptos Clave
- ✅ INSERT agrega nuevos registros a las tablas
- ✅ UPDATE modifica registros existentes
- ✅ DELETE elimina registros de las tablas
- ✅ **SIEMPRE usa WHERE** en UPDATE y DELETE
- ✅ Puedes insertar múltiples registros en una sola consulta
- ✅ Haz backup antes de operaciones destructivas
- ✅ Prueba primero con SELECT para ver qué se modificará

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/junior_5` para aprender sobre funciones básicas de SQL.

---

**💡 Consejo: Practica estas operaciones en un entorno de prueba. Las operaciones de modificación y eliminación son irreversibles, así que ten cuidado.**
