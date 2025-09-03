# Clase 2: Tipos de Datos y Restricciones - Fundamentos Avanzados

## 📚 Descripción de la Clase
En esta clase profundizaremos en los tipos de datos disponibles en SQL y las restricciones que podemos aplicar a nuestras tablas. Aprenderás a elegir el tipo de dato correcto para cada situación y cómo usar las restricciones para mantener la integridad de los datos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Conocer todos los tipos de datos básicos en SQL
- Entender cuándo usar cada tipo de dato
- Aplicar restricciones apropiadas a las columnas
- Crear tablas con integridad de datos
- Evitar errores comunes en el diseño de tablas

## ⏱️ Duración Estimada
**2-3 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### Tipos de Datos en SQL

Los tipos de datos definen qué tipo de información puede almacenar una columna. Elegir el tipo correcto es crucial para:
- **Eficiencia**: Usar el mínimo espacio necesario
- **Integridad**: Asegurar que los datos sean válidos
- **Rendimiento**: Optimizar las consultas y operaciones

### 1. Tipos de Datos Numéricos

#### **INT (Entero)**
- **Descripción**: Almacena números enteros (sin decimales)
- **Rango**: -2,147,483,648 a 2,147,483,647
- **Espacio**: 4 bytes
- **Uso**: IDs, contadores, edades, cantidades

```sql
-- Ejemplo de uso de INT
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    edad INT NOT NULL,
    años_experiencia INT DEFAULT 0
);
```

**Explicación línea por línea:**
- `id INT PRIMARY KEY AUTO_INCREMENT`: 
  - `id`: nombre de la columna
  - `INT`: tipo de dato entero
  - `PRIMARY KEY`: clave primaria (identificador único)
  - `AUTO_INCREMENT`: se incrementa automáticamente
- `edad INT NOT NULL`:
  - `edad`: nombre de la columna
  - `INT`: tipo de dato entero
  - `NOT NULL`: no puede estar vacía
- `años_experiencia INT DEFAULT 0`:
  - `años_experiencia`: nombre de la columna
  - `INT`: tipo de dato entero
  - `DEFAULT 0`: valor por defecto es 0

#### **BIGINT (Entero Grande)**
- **Descripción**: Enteros con rango más amplio
- **Rango**: -9,223,372,036,854,775,808 a 9,223,372,036,854,775,807
- **Espacio**: 8 bytes
- **Uso**: IDs de sistemas grandes, timestamps

```sql
-- Ejemplo de uso de BIGINT
CREATE TABLE transacciones (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    timestamp BIGINT NOT NULL
);
```

#### **DECIMAL(p,s) (Decimal Exacto)**
- **Descripción**: Números decimales con precisión exacta
- **Parámetros**: 
  - `p`: precisión total (número total de dígitos)
  - `s`: escala (número de dígitos después del punto decimal)
- **Uso**: Precios, cantidades monetarias, mediciones precisas

```sql
-- Ejemplo de uso de DECIMAL
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    precio DECIMAL(10,2) NOT NULL,  -- 10 dígitos totales, 2 decimales
    peso DECIMAL(8,3)               -- 8 dígitos totales, 3 decimales
);
```

**Explicación línea por línea:**
- `precio DECIMAL(10,2) NOT NULL`:
  - `precio`: nombre de la columna
  - `DECIMAL(10,2)`: puede almacenar números como 12345678.99
  - `NOT NULL`: no puede estar vacía
- `peso DECIMAL(8,3)`:
  - `peso`: nombre de la columna
  - `DECIMAL(8,3)`: puede almacenar números como 12345.678

#### **FLOAT y DOUBLE (Decimales Aproximados)**
- **Descripción**: Números decimales con aproximación
- **FLOAT**: 4 bytes, precisión simple
- **DOUBLE**: 8 bytes, precisión doble
- **Uso**: Cálculos científicos, mediciones que no requieren precisión exacta

```sql
-- Ejemplo de uso de FLOAT y DOUBLE
CREATE TABLE mediciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    temperatura FLOAT,      -- Para temperaturas (puede tener aproximación)
    coordenada_x DOUBLE     -- Para coordenadas GPS (mayor precisión)
);
```

### 2. Tipos de Datos de Texto

#### **VARCHAR(n) (Texto Variable)**
- **Descripción**: Texto de longitud variable
- **Parámetro**: `n` = longitud máxima en caracteres
- **Espacio**: 1-4 bytes + longitud real del texto
- **Uso**: Nombres, direcciones, descripciones

```sql
-- Ejemplo de uso de VARCHAR
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,        -- Nombre hasta 100 caracteres
    email VARCHAR(255) UNIQUE,           -- Email hasta 255 caracteres
    direccion VARCHAR(500)               -- Dirección hasta 500 caracteres
);
```

**Explicación línea por línea:**
- `nombre VARCHAR(100) NOT NULL`:
  - `nombre`: nombre de la columna
  - `VARCHAR(100)`: texto de máximo 100 caracteres
  - `NOT NULL`: no puede estar vacía
- `email VARCHAR(255) UNIQUE`:
  - `email`: nombre de la columna
  - `VARCHAR(255)`: texto de máximo 255 caracteres
  - `UNIQUE`: debe ser único en toda la tabla
- `direccion VARCHAR(500)`:
  - `direccion`: nombre de la columna
  - `VARCHAR(500)`: texto de máximo 500 caracteres
  - (sin restricciones adicionales)

#### **CHAR(n) (Texto Fijo)**
- **Descripción**: Texto de longitud fija
- **Parámetro**: `n` = longitud exacta en caracteres
- **Espacio**: Siempre `n` bytes
- **Uso**: Códigos, abreviaciones, campos de longitud conocida

```sql
-- Ejemplo de uso de CHAR
CREATE TABLE paises (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(2) NOT NULL,        -- Código de país (ej: "ES", "US")
    moneda CHAR(3) NOT NULL         -- Código de moneda (ej: "EUR", "USD")
);
```

**Explicación línea por línea:**
- `codigo CHAR(2) NOT NULL`:
  - `codigo`: nombre de la columna
  - `CHAR(2)`: exactamente 2 caracteres
  - `NOT NULL`: no puede estar vacía
- `moneda CHAR(3) NOT NULL`:
  - `moneda`: nombre de la columna
  - `CHAR(3)`: exactamente 3 caracteres
  - `NOT NULL`: no puede estar vacía

#### **TEXT (Texto Largo)**
- **Descripción**: Para textos muy largos
- **Espacio**: Variable, hasta 65,535 caracteres
- **Uso**: Artículos, comentarios largos, descripciones extensas

```sql
-- Ejemplo de uso de TEXT
CREATE TABLE articulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT,                 -- Contenido del artículo
    resumen TEXT                    -- Resumen del artículo
);
```

### 3. Tipos de Datos de Fecha y Hora

#### **DATE (Fecha)**
- **Descripción**: Almacena solo la fecha
- **Formato**: YYYY-MM-DD (año-mes-día)
- **Espacio**: 3 bytes
- **Uso**: Fechas de nacimiento, fechas de eventos

```sql
-- Ejemplo de uso de DATE
CREATE TABLE eventos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    fecha_evento DATE NOT NULL,     -- Solo la fecha
    fecha_creacion DATE DEFAULT (CURRENT_DATE)  -- Fecha actual por defecto
);
```

**Explicación línea por línea:**
- `fecha_evento DATE NOT NULL`:
  - `fecha_evento`: nombre de la columna
  - `DATE`: tipo de dato fecha
  - `NOT NULL`: no puede estar vacía
- `fecha_creacion DATE DEFAULT (CURRENT_DATE)`:
  - `fecha_creacion`: nombre de la columna
  - `DATE`: tipo de dato fecha
  - `DEFAULT (CURRENT_DATE)`: fecha actual por defecto

#### **TIME (Hora)**
- **Descripción**: Almacena solo la hora
- **Formato**: HH:MM:SS (hora:minuto:segundo)
- **Espacio**: 3 bytes
- **Uso**: Horarios, duraciones

```sql
-- Ejemplo de uso de TIME
CREATE TABLE horarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hora_inicio TIME NOT NULL,      -- Hora de inicio
    hora_fin TIME NOT NULL          -- Hora de fin
);
```

#### **DATETIME (Fecha y Hora)**
- **Descripción**: Almacena fecha y hora juntas
- **Formato**: YYYY-MM-DD HH:MM:SS
- **Espacio**: 8 bytes
- **Uso**: Timestamps, registros de actividad

```sql
-- Ejemplo de uso de DATETIME
CREATE TABLE logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    accion VARCHAR(100) NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP  -- Fecha y hora actual
);
```

#### **TIMESTAMP (Marca de Tiempo)**
- **Descripción**: Similar a DATETIME pero con zona horaria
- **Formato**: YYYY-MM-DD HH:MM:SS
- **Espacio**: 4 bytes
- **Uso**: Registros de auditoría, timestamps automáticos

```sql
-- Ejemplo de uso de TIMESTAMP
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Explicación línea por línea:**
- `fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP`:
  - `fecha_registro`: nombre de la columna
  - `TIMESTAMP`: tipo de dato marca de tiempo
  - `DEFAULT CURRENT_TIMESTAMP`: fecha y hora actual por defecto
- `ultimo_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`:
  - `ultimo_acceso`: nombre de la columna
  - `TIMESTAMP`: tipo de dato marca de tiempo
  - `DEFAULT CURRENT_TIMESTAMP`: fecha y hora actual por defecto
  - `ON UPDATE CURRENT_TIMESTAMP`: se actualiza automáticamente cuando se modifica el registro

### 4. Tipos de Datos Booleanos

#### **BOOLEAN o BOOL**
- **Descripción**: Almacena valores verdadero o falso
- **Valores**: TRUE, FALSE, o NULL
- **Espacio**: 1 byte
- **Uso**: Flags, estados, opciones sí/no

```sql
-- Ejemplo de uso de BOOLEAN
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,        -- Producto activo o no
    disponible BOOLEAN DEFAULT FALSE    -- Producto disponible o no
);
```

**Explicación línea por línea:**
- `activo BOOLEAN DEFAULT TRUE`:
  - `activo`: nombre de la columna
  - `BOOLEAN`: tipo de dato booleano
  - `DEFAULT TRUE`: valor por defecto es verdadero
- `disponible BOOLEAN DEFAULT FALSE`:
  - `disponible`: nombre de la columna
  - `BOOLEAN`: tipo de dato booleano
  - `DEFAULT FALSE`: valor por defecto es falso

### Restricciones (Constraints) en SQL

Las restricciones son reglas que definen qué datos pueden almacenarse en una tabla. Ayudan a mantener la integridad y consistencia de los datos.

### 1. NOT NULL
- **Descripción**: La columna no puede estar vacía
- **Uso**: Campos obligatorios como nombres, emails, etc.

```sql
-- Ejemplo de NOT NULL
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,       -- Nombre es obligatorio
    email VARCHAR(255) NOT NULL,        -- Email es obligatorio
    telefono VARCHAR(20)                -- Teléfono es opcional
);
```

### 2. UNIQUE
- **Descripción**: El valor debe ser único en toda la tabla
- **Uso**: Emails, códigos, identificadores únicos

```sql
-- Ejemplo de UNIQUE
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,  -- Username único
    email VARCHAR(255) UNIQUE NOT NULL,    -- Email único
    nombre VARCHAR(100) NOT NULL
);
```

### 3. PRIMARY KEY
- **Descripción**: Identificador único de cada fila
- **Características**: 
  - No puede ser NULL
  - Debe ser único
  - Solo puede haber una por tabla
  - Se crea automáticamente un índice

```sql
-- Ejemplo de PRIMARY KEY
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,  -- Clave primaria
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);
```

### 4. FOREIGN KEY
- **Descripción**: Referencia a una clave primaria de otra tabla
- **Uso**: Establecer relaciones entre tablas

```sql
-- Ejemplo de FOREIGN KEY
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
```

**Explicación línea por línea:**
- `categoria_id INT`: columna que almacenará el ID de la categoría
- `FOREIGN KEY (categoria_id)`: define que categoria_id es una clave foránea
- `REFERENCES categorias(id)`: referencia a la columna id de la tabla categorias

### 5. CHECK
- **Descripción**: Define una condición que debe cumplirse
- **Uso**: Validar rangos, formatos, valores específicos

```sql
-- Ejemplo de CHECK
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) CHECK (precio > 0),        -- Precio debe ser positivo
    stock INT CHECK (stock >= 0),                   -- Stock no puede ser negativo
    categoria VARCHAR(50) CHECK (categoria IN ('Electrónicos', 'Ropa', 'Libros'))
);
```

**Explicación línea por línea:**
- `precio DECIMAL(10,2) CHECK (precio > 0)`:
  - `precio`: nombre de la columna
  - `DECIMAL(10,2)`: tipo de dato decimal
  - `CHECK (precio > 0)`: restricción que el precio debe ser mayor que 0
- `stock INT CHECK (stock >= 0)`:
  - `stock`: nombre de la columna
  - `INT`: tipo de dato entero
  - `CHECK (stock >= 0)`: restricción que el stock debe ser mayor o igual a 0
- `categoria VARCHAR(50) CHECK (categoria IN ('Electrónicos', 'Ropa', 'Libros'))`:
  - `categoria`: nombre de la columna
  - `VARCHAR(50)`: tipo de dato texto
  - `CHECK (categoria IN (...))`: restricción que la categoría debe ser uno de los valores listados

### 6. DEFAULT
- **Descripción**: Valor por defecto cuando no se especifica
- **Uso**: Valores predeterminados, timestamps automáticos

```sql
-- Ejemplo de DEFAULT
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE DEFAULT (CURRENT_DATE),      -- Fecha actual por defecto
    estado VARCHAR(20) DEFAULT 'Pendiente',        -- Estado por defecto
    total DECIMAL(10,2) DEFAULT 0.00               -- Total por defecto
);
```

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Tabla de Empleados Completa

```sql
-- Crear tabla de empleados con múltiples tipos de datos y restricciones
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    fecha_contratacion DATE DEFAULT (CURRENT_DATE),
    salario DECIMAL(10,2) CHECK (salario > 0),
    activo BOOLEAN DEFAULT TRUE,
    departamento_id INT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Explicación línea por línea:**

```sql
-- Línea 1: CREATE TABLE empleados (
--   CREATE TABLE: comando para crear una nueva tabla
--   empleados: nombre de la tabla

-- Línea 2: id INT PRIMARY KEY AUTO_INCREMENT,
--   id: nombre de la columna
--   INT: tipo de dato entero
--   PRIMARY KEY: clave primaria (identificador único)
--   AUTO_INCREMENT: se incrementa automáticamente

-- Línea 3: nombre VARCHAR(100) NOT NULL,
--   nombre: nombre de la columna
--   VARCHAR(100): texto de máximo 100 caracteres
--   NOT NULL: no puede estar vacía

-- Línea 4: apellido VARCHAR(100) NOT NULL,
--   apellido: nombre de la columna
--   VARCHAR(100): texto de máximo 100 caracteres
--   NOT NULL: no puede estar vacía

-- Línea 5: email VARCHAR(255) UNIQUE NOT NULL,
--   email: nombre de la columna
--   VARCHAR(255): texto de máximo 255 caracteres
--   UNIQUE: debe ser único en toda la tabla
--   NOT NULL: no puede estar vacía

-- Línea 6: telefono VARCHAR(20),
--   telefono: nombre de la columna
--   VARCHAR(20): texto de máximo 20 caracteres
--   (sin restricciones, puede estar vacía)

-- Línea 7: fecha_nacimiento DATE NOT NULL,
--   fecha_nacimiento: nombre de la columna
--   DATE: tipo de dato fecha
--   NOT NULL: no puede estar vacía

-- Línea 8: fecha_contratacion DATE DEFAULT (CURRENT_DATE),
--   fecha_contratacion: nombre de la columna
--   DATE: tipo de dato fecha
--   DEFAULT (CURRENT_DATE): fecha actual por defecto

-- Línea 9: salario DECIMAL(10,2) CHECK (salario > 0),
--   salario: nombre de la columna
--   DECIMAL(10,2): número decimal con 10 dígitos totales y 2 decimales
--   CHECK (salario > 0): restricción que el salario debe ser positivo

-- Línea 10: activo BOOLEAN DEFAULT TRUE,
--   activo: nombre de la columna
--   BOOLEAN: tipo de dato booleano
--   DEFAULT TRUE: valor por defecto es verdadero

-- Línea 11: departamento_id INT,
--   departamento_id: nombre de la columna
--   INT: tipo de dato entero
--   (será una clave foránea, se define después)

-- Línea 12: fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--   fecha_creacion: nombre de la columna
--   TIMESTAMP: tipo de dato marca de tiempo
--   DEFAULT CURRENT_TIMESTAMP: fecha y hora actual por defecto

-- Línea 13: fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
--   fecha_modificacion: nombre de la columna
--   TIMESTAMP: tipo de dato marca de tiempo
--   DEFAULT CURRENT_TIMESTAMP: fecha y hora actual por defecto
--   ON UPDATE CURRENT_TIMESTAMP: se actualiza automáticamente cuando se modifica el registro

-- Línea 14: );
--   ): cierre de la definición de la tabla
--   ;: final de la instrucción
```

### Ejemplo 2: Insertar Datos con Diferentes Tipos

```sql
-- Insertar empleados con diferentes tipos de datos
INSERT INTO empleados (nombre, apellido, email, telefono, fecha_nacimiento, salario, departamento_id) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', '612345678', '1985-03-15', 35000.00, 1),
('María', 'García', 'maria.garcia@empresa.com', '623456789', '1990-07-22', 42000.50, 2),
('Carlos', 'López', 'carlos.lopez@empresa.com', NULL, '1988-11-08', 38000.00, 1);
```

**Explicación línea por línea:**

```sql
-- Línea 1: INSERT INTO empleados (nombre, apellido, email, telefono, fecha_nacimiento, salario, departamento_id) VALUES
--   INSERT INTO: comando para insertar datos
--   empleados: nombre de la tabla
--   (nombre, apellido, email, telefono, fecha_nacimiento, salario, departamento_id): columnas donde insertaremos
--   VALUES: palabra clave que indica que vienen los valores

-- Línea 2: ('Juan', 'Pérez', 'juan.perez@empresa.com', '612345678', '1985-03-15', 35000.00, 1),
--   'Juan': valor para nombre (VARCHAR)
--   'Pérez': valor para apellido (VARCHAR)
--   'juan.perez@empresa.com': valor para email (VARCHAR, UNIQUE)
--   '612345678': valor para telefono (VARCHAR)
--   '1985-03-15': valor para fecha_nacimiento (DATE)
--   35000.00: valor para salario (DECIMAL)
--   1: valor para departamento_id (INT)
--   ,: separador entre filas

-- Línea 3: ('María', 'García', 'maria.garcia@empresa.com', '623456789', '1990-07-22', 42000.50, 2),
--   Segunda fila con los mismos tipos de datos
--   ,: separador entre filas

-- Línea 4: ('Carlos', 'López', 'carlos.lopez@empresa.com', NULL, '1988-11-08', 38000.00, 1);
--   Tercera fila
--   NULL: valor nulo para telefono (campo opcional)
--   ;: final de la instrucción
```

### Ejemplo 3: Consultar Datos con Diferentes Tipos

```sql
-- Consultar empleados con diferentes tipos de datos
SELECT 
    id,
    CONCAT(nombre, ' ', apellido) AS nombre_completo,
    email,
    telefono,
    fecha_nacimiento,
    YEAR(CURDATE()) - YEAR(fecha_nacimiento) AS edad,
    salario,
    CASE WHEN activo THEN 'Activo' ELSE 'Inactivo' END AS estado,
    fecha_creacion
FROM empleados;
```

**Explicación línea por línea:**

```sql
-- Línea 1: SELECT
--   SELECT: comando para consultar datos

-- Línea 2: id,
--   id: columna id (INT)

-- Línea 3: CONCAT(nombre, ' ', apellido) AS nombre_completo,
--   CONCAT: función que une textos
--   nombre, ' ', apellido: textos a unir
--   AS nombre_completo: alias para el resultado

-- Línea 4: email,
--   email: columna email (VARCHAR)

-- Línea 5: telefono,
--   telefono: columna telefono (VARCHAR, puede ser NULL)

-- Línea 6: fecha_nacimiento,
--   fecha_nacimiento: columna fecha (DATE)

-- Línea 7: YEAR(CURDATE()) - YEAR(fecha_nacimiento) AS edad,
--   YEAR(CURDATE()): año actual
--   YEAR(fecha_nacimiento): año de nacimiento
--   -: resta para calcular la edad
--   AS edad: alias para el resultado

-- Línea 8: salario,
--   salario: columna salario (DECIMAL)

-- Línea 9: CASE WHEN activo THEN 'Activo' ELSE 'Inactivo' END AS estado,
--   CASE WHEN: estructura condicional
--   activo: columna booleana
--   THEN 'Activo': si es TRUE, muestra 'Activo'
--   ELSE 'Inactivo': si es FALSE, muestra 'Inactivo'
--   END: fin de la estructura CASE
--   AS estado: alias para el resultado

-- Línea 10: fecha_creacion
--   fecha_creacion: columna timestamp

-- Línea 11: FROM empleados;
--   FROM empleados: especifica la tabla
--   ;: final de la instrucción
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Crear Tabla de Productos con Múltiples Tipos
**Objetivo**: Practicar el uso de diferentes tipos de datos y restricciones.

**Instrucciones**:
Crea una tabla llamada `productos` con las siguientes columnas:
- `id`: entero, clave primaria, auto-incremento
- `nombre`: texto de máximo 200 caracteres, obligatorio
- `descripcion`: texto largo
- `precio`: decimal con 2 decimales, obligatorio, mayor que 0
- `stock`: entero, no puede ser negativo
- `categoria`: texto de máximo 50 caracteres
- `activo`: booleano, por defecto verdadero
- `fecha_creacion`: timestamp automático
- `fecha_modificacion`: timestamp que se actualiza automáticamente

**Solución paso a paso:**

```sql
-- Paso 1: Crear la tabla productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Explicación línea por línea:
-- id INT PRIMARY KEY AUTO_INCREMENT:
--   - id: nombre de la columna
--   - INT: tipo de dato entero
--   - PRIMARY KEY: clave primaria (identificador único)
--   - AUTO_INCREMENT: se incrementa automáticamente

-- nombre VARCHAR(200) NOT NULL:
--   - nombre: nombre de la columna
--   - VARCHAR(200): texto de máximo 200 caracteres
--   - NOT NULL: no puede estar vacía

-- descripcion TEXT:
--   - descripcion: nombre de la columna
--   - TEXT: tipo de dato para textos largos
--   - (sin restricciones, puede estar vacía)

-- precio DECIMAL(10,2) NOT NULL CHECK (precio > 0):
--   - precio: nombre de la columna
--   - DECIMAL(10,2): número decimal con 10 dígitos totales y 2 decimales
--   - NOT NULL: no puede estar vacía
--   - CHECK (precio > 0): restricción que el precio debe ser positivo

-- stock INT DEFAULT 0 CHECK (stock >= 0):
--   - stock: nombre de la columna
--   - INT: tipo de dato entero
--   - DEFAULT 0: valor por defecto es 0
--   - CHECK (stock >= 0): restricción que el stock no puede ser negativo

-- categoria VARCHAR(50):
--   - categoria: nombre de la columna
--   - VARCHAR(50): texto de máximo 50 caracteres
--   - (sin restricciones, puede estar vacía)

-- activo BOOLEAN DEFAULT TRUE:
--   - activo: nombre de la columna
--   - BOOLEAN: tipo de dato booleano
--   - DEFAULT TRUE: valor por defecto es verdadero

-- fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP:
--   - fecha_creacion: nombre de la columna
--   - TIMESTAMP: tipo de dato marca de tiempo
--   - DEFAULT CURRENT_TIMESTAMP: fecha y hora actual por defecto

-- fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP:
--   - fecha_modificacion: nombre de la columna
--   - TIMESTAMP: tipo de dato marca de tiempo
--   - DEFAULT CURRENT_TIMESTAMP: fecha y hora actual por defecto
--   - ON UPDATE CURRENT_TIMESTAMP: se actualiza automáticamente cuando se modifica el registro
```

### Ejercicio 2: Insertar Productos con Diferentes Tipos
**Objetivo**: Practicar la inserción de datos con diferentes tipos.

**Instrucciones**:
Inserta los siguientes productos en la tabla:
1. "Laptop HP" - "Laptop de 15 pulgadas con procesador Intel i7" - $899.99 - 10 unidades - "Electrónicos"
2. "Mouse Inalámbrico" - "Mouse óptico inalámbrico con batería de larga duración" - $25.50 - 50 unidades - "Accesorios"
3. "Teclado Mecánico" - NULL - $89.99 - 15 unidades - "Accesorios"

**Solución paso a paso:**

```sql
-- Insertar productos con diferentes tipos de datos
INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Laptop HP', 'Laptop de 15 pulgadas con procesador Intel i7', 899.99, 10, 'Electrónicos'),
('Mouse Inalámbrico', 'Mouse óptico inalámbrico con batería de larga duración', 25.50, 50, 'Accesorios'),
('Teclado Mecánico', NULL, 89.99, 15, 'Accesorios');

-- Explicación línea por línea:
-- INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES:
--   - INSERT INTO: comando para insertar datos
--   - productos: nombre de la tabla
--   - (nombre, descripcion, precio, stock, categoria): columnas donde insertaremos
--   - VALUES: palabra clave que indica que vienen los valores

-- ('Laptop HP', 'Laptop de 15 pulgadas con procesador Intel i7', 899.99, 10, 'Electrónicos'),
--   - 'Laptop HP': valor para nombre (VARCHAR)
--   - 'Laptop de 15 pulgadas con procesador Intel i7': valor para descripcion (TEXT)
--   - 899.99: valor para precio (DECIMAL)
--   - 10: valor para stock (INT)
--   - 'Electrónicos': valor para categoria (VARCHAR)
--   - ,: separador entre filas

-- ('Mouse Inalámbrico', 'Mouse óptico inalámbrico con batería de larga duración', 25.50, 50, 'Accesorios'),
--   - Segunda fila con los mismos tipos de datos
--   - ,: separador entre filas

-- ('Teclado Mecánico', NULL, 89.99, 15, 'Accesorios');
--   - 'Teclado Mecánico': valor para nombre (VARCHAR)
--   - NULL: valor nulo para descripcion (campo opcional)
--   - 89.99: valor para precio (DECIMAL)
--   - 15: valor para stock (INT)
--   - 'Accesorios': valor para categoria (VARCHAR)
--   - ;: final de la instrucción
```

### Ejercicio 3: Consultar Productos con Cálculos
**Objetivo**: Practicar consultas con diferentes tipos de datos y funciones.

**Instrucciones**:
Crea una consulta que muestre:
- ID del producto
- Nombre del producto
- Precio con formato de moneda
- Stock con indicador de disponibilidad
- Estado del producto (Activo/Inactivo)
- Días desde la creación

**Solución paso a paso:**

```sql
-- Consulta con cálculos y formateo
SELECT 
    id,
    nombre,
    CONCAT('$', FORMAT(precio, 2)) AS precio_formateado,
    stock,
    CASE 
        WHEN stock > 20 THEN 'Disponible'
        WHEN stock > 0 THEN 'Pocas unidades'
        ELSE 'Agotado'
    END AS disponibilidad,
    CASE WHEN activo THEN 'Activo' ELSE 'Inactivo' END AS estado,
    DATEDIFF(CURDATE(), DATE(fecha_creacion)) AS dias_desde_creacion
FROM productos;

-- Explicación línea por línea:
-- SELECT: comando para consultar datos

-- id,
--   - id: columna id (INT)

-- nombre,
--   - nombre: columna nombre (VARCHAR)

-- CONCAT('$', FORMAT(precio, 2)) AS precio_formateado,
--   - CONCAT: función que une textos
--   - '$': símbolo de moneda
--   - FORMAT(precio, 2): formatea el precio con 2 decimales
--   - AS precio_formateado: alias para el resultado

-- stock,
--   - stock: columna stock (INT)

-- CASE 
--     WHEN stock > 20 THEN 'Disponible'
--     WHEN stock > 0 THEN 'Pocas unidades'
--     ELSE 'Agotado'
-- END AS disponibilidad,
--   - CASE: estructura condicional
--   - WHEN stock > 20 THEN 'Disponible': si stock > 20, muestra 'Disponible'
--   - WHEN stock > 0 THEN 'Pocas unidades': si stock > 0, muestra 'Pocas unidades'
--   - ELSE 'Agotado': en cualquier otro caso, muestra 'Agotado'
--   - END: fin de la estructura CASE
--   - AS disponibilidad: alias para el resultado

-- CASE WHEN activo THEN 'Activo' ELSE 'Inactivo' END AS estado,
--   - CASE WHEN: estructura condicional simple
--   - activo: columna booleana
--   - THEN 'Activo': si es TRUE, muestra 'Activo'
--   - ELSE 'Inactivo': si es FALSE, muestra 'Inactivo'
--   - END: fin de la estructura CASE
--   - AS estado: alias para el resultado

-- DATEDIFF(CURDATE(), DATE(fecha_creacion)) AS dias_desde_creacion
--   - DATEDIFF: función que calcula la diferencia entre fechas
--   - CURDATE(): fecha actual
--   - DATE(fecha_creacion): convierte el timestamp a fecha
--   - AS dias_desde_creacion: alias para el resultado

-- FROM productos;
--   - FROM productos: especifica la tabla
--   - ;: final de la instrucción
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de Datos Aprendidos:

#### Numéricos:
- **INT**: Enteros (-2,147,483,648 a 2,147,483,647)
- **BIGINT**: Enteros grandes (rango más amplio)
- **DECIMAL(p,s)**: Decimales exactos (p=precisión, s=escala)
- **FLOAT/DOUBLE**: Decimales aproximados

#### Texto:
- **VARCHAR(n)**: Texto variable (máximo n caracteres)
- **CHAR(n)**: Texto fijo (exactamente n caracteres)
- **TEXT**: Texto largo (hasta 65,535 caracteres)

#### Fecha y Hora:
- **DATE**: Solo fecha (YYYY-MM-DD)
- **TIME**: Solo hora (HH:MM:SS)
- **DATETIME**: Fecha y hora (YYYY-MM-DD HH:MM:SS)
- **TIMESTAMP**: Marca de tiempo con zona horaria

#### Booleanos:
- **BOOLEAN/BOOL**: Verdadero o falso

### Restricciones Aprendidas:
- **NOT NULL**: Campo obligatorio
- **UNIQUE**: Valor único en la tabla
- **PRIMARY KEY**: Identificador único
- **FOREIGN KEY**: Referencia a otra tabla
- **CHECK**: Condición que debe cumplirse
- **DEFAULT**: Valor por defecto

### Funciones Útiles:
- **CONCAT()**: Unir textos
- **FORMAT()**: Formatear números
- **CASE WHEN**: Estructura condicional
- **DATEDIFF()**: Calcular diferencia entre fechas
- **CURDATE()**: Fecha actual
- **YEAR()**: Extraer año de una fecha

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Cómo crear relaciones entre tablas
- Claves primarias y foráneas
- Índices para mejorar el rendimiento
- Normalización de bases de datos

---

## 💡 Consejos para el Éxito

1. **Elige el tipo correcto**: Cada tipo de dato tiene un propósito específico
2. **Usa restricciones apropiadas**: Ayudan a mantener la integridad de los datos
3. **Planifica tu diseño**: Piensa en los tipos de datos antes de crear las tablas
4. **Documenta tus decisiones**: Comenta por qué elegiste cada tipo de dato
5. **Prueba tus restricciones**: Verifica que funcionen correctamente

---

## 🧭 Navegación

**← Anterior**: [Clase 1: Introducción a SQL](clase_1_introduccion_sql.md)  
**Siguiente →**: [Clase 3: Relaciones entre Tablas](clase_3_relaciones_tablas.md)

---

*¡Excelente progreso! Ahora dominas los tipos de datos y restricciones en SQL. 🚀*
