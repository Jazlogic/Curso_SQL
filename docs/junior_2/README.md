# Módulo 2: Consultas SELECT Básicas - Nivel Junior

## Descripción
Módulo que cubre las consultas SELECT básicas en SQL, incluyendo la sintaxis fundamental, tipos de SELECT, operadores de comparación, alias, y filtros básicos con WHERE.

## Objetivos del Módulo
- Dominar la sintaxis básica de SELECT
- Comprender los diferentes tipos de consultas SELECT
- Aplicar operadores de comparación en filtros
- Usar alias para mejorar la legibilidad
- Implementar filtros básicos con WHERE
- Eliminar duplicados con DISTINCT
- Crear consultas eficientes y legibles

## Prerrequisitos
- Completar Módulo 1: Introducción a SQL y Bases de Datos
- Conocimiento básico de tablas y columnas
- Acceso a una base de datos con datos de ejemplo

## Tecnologías y Herramientas
- **SQL**: Lenguaje de consulta estructurado
- **MySQL/PostgreSQL**: Sistema de gestión de bases de datos
- **Cliente de base de datos**: Para ejecutar consultas
- **Datos de ejemplo**: Tablas pobladas para práctica

## Estructura del Módulo

### 📚 Contenido Teórico

#### **¿Qué es SELECT?**
La instrucción SELECT es el comando más importante en SQL. Se utiliza para consultar y recuperar datos de las tablas de la base de datos.

#### **Sintaxis Básica de SELECT**
```sql
SELECT columna1, columna2, ...
FROM nombre_tabla;
```

#### **Tipos de SELECT**
1. **SELECT ***: Selecciona todas las columnas
2. **SELECT específico**: Selecciona solo columnas específicas
3. **SELECT con alias**: Usa nombres alternativos para columnas
4. **SELECT DISTINCT**: Elimina duplicados

#### **Operadores de Comparación**
- `=` : Igual a
- `!=` o `<>` : Diferente de
- `>` : Mayor que
- `<` : Menor que
- `>=` : Mayor o igual que
- `<=` : Menor o igual que

#### **Filtros Básicos con WHERE**
- Filtrar por valores exactos
- Filtrar por rangos
- Filtrar por valores nulos
- Combinar múltiples condiciones

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

## 🎯 Ejercicios Prácticos (10 Ejercicios)

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

### Ejercicio 6: Consulta de Miembros del Gimnasio
Usando la tabla `miembros` del gimnasio, escribe consultas para:
1. Ver todos los miembros
2. Ver solo nombre y email de miembros con plan Premium
3. Ver miembros inscritos en 2024
4. Ver solo los planes de membresía disponibles (sin duplicados)
5. Ver nombre completo y fecha de inscripción de miembros VIP

**Solución:**
```sql
-- 1. Ver todos los miembros
SELECT * FROM miembros;

-- 2. Ver nombre y email de Premium
SELECT nombre, email FROM miembros WHERE plan_membresia = 'Premium';

-- 3. Ver miembros de 2024
SELECT * FROM miembros WHERE YEAR(fecha_inscripcion) = 2024;

-- 4. Ver planes únicos
SELECT DISTINCT plan_membresia FROM miembros;

-- 5. Ver miembros VIP
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo, fecha_inscripcion 
FROM miembros WHERE plan_membresia = 'VIP';
```

### Ejercicio 7: Consulta de Cuentas Bancarias
Usando la tabla `cuentas` del banco, escribe consultas para:
1. Ver todas las cuentas
2. Ver solo número de cuenta y saldo de cuentas corrientes
3. Ver cuentas con saldo mayor a 1000
4. Ver solo los tipos de cuenta disponibles (sin duplicados)
5. Ver cuentas abiertas en 2024 con saldo mayor a 5000

**Solución:**
```sql
-- 1. Ver todas las cuentas
SELECT * FROM cuentas;

-- 2. Ver cuentas corrientes
SELECT numero_cuenta, saldo FROM cuentas WHERE tipo_cuenta = 'Corriente';

-- 3. Ver cuentas con saldo alto
SELECT * FROM cuentas WHERE saldo > 1000;

-- 4. Ver tipos únicos
SELECT DISTINCT tipo_cuenta FROM cuentas;

-- 5. Ver cuentas nuevas con saldo alto
SELECT * FROM cuentas 
WHERE YEAR(fecha_apertura) = 2024 AND saldo > 5000;
```

### Ejercicio 8: Consulta de Destinos de Viaje
Usando la tabla `destinos` de la agencia de viajes, escribe consultas para:
1. Ver todos los destinos
2. Ver solo nombre y precio de destinos en Europa
3. Ver destinos con duración mayor a 7 días
4. Ver solo los países disponibles (sin duplicados)
5. Ver destinos con precio entre 1000 y 2000 euros

**Solución:**
```sql
-- 1. Ver todos los destinos
SELECT * FROM destinos;

-- 2. Ver destinos europeos (asumiendo algunos países)
SELECT nombre, precio_persona FROM destinos 
WHERE pais IN ('Francia', 'Italia', 'España', 'Reino Unido');

-- 3. Ver destinos largos
SELECT * FROM destinos WHERE duracion_dias > 7;

-- 4. Ver países únicos
SELECT DISTINCT pais FROM destinos;

-- 5. Ver destinos en rango de precio
SELECT * FROM destinos WHERE precio_persona BETWEEN 1000 AND 2000;
```

### Ejercicio 9: Consulta de Películas
Usando la tabla `peliculas` del cine, escribe consultas para:
1. Ver todas las películas
2. Ver solo título y director de películas de drama
3. Ver películas estrenadas después de 2010
4. Ver solo los géneros disponibles (sin duplicados)
5. Ver películas con calificación mayor a 8.5

**Solución:**
```sql
-- 1. Ver todas las películas
SELECT * FROM peliculas;

-- 2. Ver películas de drama
SELECT titulo, director FROM peliculas WHERE genero = 'Drama';

-- 3. Ver películas recientes
SELECT * FROM peliculas WHERE año_estreno > 2010;

-- 4. Ver géneros únicos
SELECT DISTINCT genero FROM peliculas;

-- 5. Ver películas con alta calificación
SELECT * FROM peliculas WHERE calificacion > 8.5;
```

### Ejercicio 10: Consulta de Usuarios de Red Social
Usando la tabla `usuarios` de la red social, escribe consultas para:
1. Ver todos los usuarios
2. Ver solo username y email de usuarios activos
3. Ver usuarios registrados en 2024
4. Ver solo los usernames únicos (sin duplicados)
5. Ver usuarios nacidos en los años 90

**Solución:**
```sql
-- 1. Ver todos los usuarios
SELECT * FROM usuarios;

-- 2. Ver usuarios activos
SELECT username, email FROM usuarios WHERE activo = TRUE;

-- 3. Ver usuarios de 2024
SELECT * FROM usuarios WHERE YEAR(fecha_registro) = 2024;

-- 4. Ver usernames únicos
SELECT DISTINCT username FROM usuarios;

-- 5. Ver usuarios de los 90
SELECT * FROM usuarios 
WHERE fecha_nacimiento BETWEEN '1990-01-01' AND '1999-12-31';
```

## 🏆 Proyecto Integrador: Sistema de Consultas de Empleados

Crea un sistema completo de consultas para una empresa que incluya:

1. **Base de datos**: `empresa_consultas`
2. **Tabla de empleados** con información completa
3. **Tabla de departamentos** para organizar empleados
4. **Tabla de proyectos** para asignar trabajo
5. **Consultas básicas** para diferentes necesidades de información

**Estructura sugerida:**
```sql
-- Base de datos
CREATE DATABASE empresa_consultas;
USE empresa_consultas;

-- Tabla de departamentos
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    presupuesto DECIMAL(12,2),
    director VARCHAR(100)
);

-- Tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    salario DECIMAL(10,2),
    fecha_contratacion DATE,
    departamento_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

-- Tabla de proyectos
CREATE TABLE proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion VARCHAR(500),
    fecha_inicio DATE,
    fecha_fin DATE,
    presupuesto DECIMAL(12,2),
    estado VARCHAR(50) DEFAULT 'Activo'
);

-- Consultas básicas del sistema
-- 1. Ver todos los empleados
SELECT * FROM empleados;

-- 2. Ver empleados con salario mayor a 50000
SELECT nombre, apellido, salario FROM empleados WHERE salario > 50000;

-- 3. Ver departamentos únicos
SELECT DISTINCT d.nombre FROM departamentos d
JOIN empleados e ON d.id = e.departamento_id;

-- 4. Ver empleados activos del departamento de IT
SELECT e.nombre, e.apellido, e.email 
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
WHERE e.activo = TRUE AND d.nombre = 'IT';

-- 5. Ver proyectos activos
SELECT nombre, fecha_inicio, presupuesto FROM proyectos WHERE estado = 'Activo';
```

## 📝 Resumen de Conceptos Clave
- ✅ SELECT es el comando principal para consultar datos
- ✅ SELECT * selecciona todas las columnas
- ✅ SELECT específico selecciona solo columnas deseadas
- ✅ WHERE filtra resultados según condiciones
- ✅ DISTINCT elimina duplicados
- ✅ AS crea alias para nombres de columnas
- ✅ Los operadores de comparación permiten filtrar datos
- ✅ BETWEEN permite filtrar por rangos
- ✅ IS NULL e IS NOT NULL filtran valores nulos
- ✅ Los alias mejoran la legibilidad de las consultas

## 🎯 Resultados del Aprendizaje

Al completar este módulo, serás capaz de:

✅ **Escribir consultas SELECT** básicas y avanzadas  
✅ **Filtrar datos** con operadores de comparación  
✅ **Usar alias** para mejorar la legibilidad  
✅ **Eliminar duplicados** con DISTINCT  
✅ **Filtrar valores nulos** correctamente  
✅ **Combinar múltiples condiciones** en WHERE  
✅ **Crear consultas eficientes** y legibles  

## 🛠️ Herramientas y Recursos

### **Entorno de Desarrollo**
- [MySQL Workbench](https://www.mysql.com/products/workbench/) - Cliente visual para MySQL
- [pgAdmin](https://www.pgadmin.org/) - Cliente para PostgreSQL
- [DBeaver](https://dbeaver.io/) - Cliente universal de bases de datos
- [phpMyAdmin](https://www.phpmyadmin.net/) - Interfaz web para MySQL

### **Recursos de Aprendizaje**
- [W3Schools SQL SELECT](https://www.w3schools.com/sql/sql_select.asp)
- [SQLBolt - SELECT Queries](https://sqlbolt.com/lesson/select_queries_introduction)
- [MySQL SELECT Documentation](https://dev.mysql.com/doc/refman/8.0/en/select.html)
- [PostgreSQL SELECT Documentation](https://www.postgresql.org/docs/current/sql-select.html)

### **Comunidad y Soporte**
- [Stack Overflow - SQL SELECT](https://stackoverflow.com/questions/tagged/sql+select)
- [Reddit - r/SQL](https://www.reddit.com/r/SQL/)
- [MySQL Community Forums](https://forums.mysql.com/)

## 📝 Evaluación y Práctica

### **Ejercicios por Módulo**
Cada ejercicio incluye:
- Enunciado claro del problema
- Múltiples consultas por ejercicio
- Solución completa con código SQL
- Explicación de conceptos aplicados
- Variaciones para práctica adicional

### **Proyecto Final del Módulo**
El proyecto integrador combina todos los conceptos aprendidos en un sistema real de consultas empresariales.

## 🚀 Próximos Pasos

Después de completar este módulo, estarás listo para continuar con:

- **Módulo 3**: Filtros Avanzados y Ordenamiento
- **Módulo 4**: Operaciones CRUD
- **Módulo 5**: Funciones Básicas de SQL

## 💡 Consejos para el Éxito

1. **Practica regularmente** - Dedica tiempo diario a escribir consultas SELECT
2. **Completa todos los ejercicios** - Refuerza tu comprensión con práctica
3. **Experimenta** - Modifica las consultas y crea nuevas
4. **Usa datos reales** - Crea tus propias bases de datos de práctica
5. **Documenta tu aprendizaje** - Toma notas de conceptos clave

---

## 🧭 Navegación del Curso

**← Anterior**: [Módulo 1: Introducción a SQL y Bases de Datos](../junior_1/README.md)  
**Siguiente →**: [Módulo 3: Filtros Avanzados y Ordenamiento](../junior_3/README.md)

---

## 🎉 ¡Continúa tu viaje en SQL!

**Módulo actual**: Módulo 2 - Consultas SELECT Básicas

**Duración total del módulo**: 12-15 horas (dependiendo de tu ritmo de aprendizaje)

**Nivel de dificultad**: Principiante

**Requisitos previos**: Módulo 1 completado

---

*¡Excelente trabajo! Ahora dominas las consultas SELECT básicas. 🚀*

