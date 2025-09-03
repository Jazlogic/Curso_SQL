# Clase 2: Modelado Entidad-Relación

## Objetivos de la Clase
- Comprender el modelo entidad-relación (ER)
- Identificar entidades, atributos y relaciones
- Crear diagramas ER profesionales
- Convertir modelos ER a esquemas relacionales

## Contenido Teórico

### 1. ¿Qué es el Modelo Entidad-Relación?

**Modelo Entidad-Relación (ER)** es una técnica de modelado conceptual que representa la estructura de datos de un sistema mediante entidades, atributos y relaciones.

#### Componentes del Modelo ER:
- **Entidades**: Objetos del mundo real
- **Atributos**: Características de las entidades
- **Relaciones**: Conexiones entre entidades
- **Restricciones**: Reglas que limitan los datos

### 2. Entidades

#### Definición
Una **entidad** es un objeto del mundo real que puede identificarse de manera única y que tiene existencia independiente.

#### Tipos de Entidades:
```sql
-- ENTIDAD FUERTE: Puede existir independientemente
-- Ejemplo: CLIENTE, PRODUCTO, EMPLEADO

-- ENTIDAD DÉBIL: Depende de otra entidad para existir
-- Ejemplo: TELEFONO (depende de CLIENTE)
-- Ejemplo: DEPENDIENTE (depende de EMPLEADO)
```

#### Ejemplo de Entidades:
```sql
-- Entidad CLIENTE
CLIENTE {
    id_cliente: INT (PK)
    nombre: VARCHAR(100)
    email: VARCHAR(100)
    telefono: VARCHAR(20)
    fecha_registro: DATE
}

-- Entidad PRODUCTO
PRODUCTO {
    id_producto: INT (PK)
    nombre: VARCHAR(200)
    precio: DECIMAL(10,2)
    stock: INT
    categoria: VARCHAR(50)
}
```

### 3. Atributos

#### Tipos de Atributos:

##### Atributos Simples vs Compuestos
```sql
-- ATRIBUTO SIMPLE: No se puede dividir
-- Ejemplo: edad, precio, fecha_nacimiento

-- ATRIBUTO COMPUESTO: Se puede dividir en sub-atributos
-- Ejemplo: direccion → {calle, numero, ciudad, codigo_postal}
```

##### Atributos Únicos vs Múltiples
```sql
-- ATRIBUTO ÚNICO: Un solo valor por entidad
-- Ejemplo: id_cliente, email

-- ATRIBUTO MÚLTIPLE: Varios valores por entidad
-- Ejemplo: telefonos (un cliente puede tener varios)
```

##### Atributos Derivados
```sql
-- ATRIBUTO DERIVADO: Se calcula a partir de otros
-- Ejemplo: edad (calculada desde fecha_nacimiento)
-- Ejemplo: total_ventas (suma de todas las ventas)
```

### 4. Claves

#### Clave Primaria (Primary Key)
```sql
-- Identifica de manera única cada instancia de entidad
-- Ejemplo: id_cliente, id_producto

-- Características:
-- 1. Única: No se repite
-- 2. No nula: Siempre tiene valor
-- 3. Inmutable: No cambia en el tiempo
```

#### Clave Foránea (Foreign Key)
```sql
-- Referencia a la clave primaria de otra entidad
-- Ejemplo: cliente_id en tabla VENTAS

-- Propósito:
-- 1. Establecer relaciones entre entidades
-- 2. Mantener integridad referencial
-- 3. Evitar redundancia de datos
```

### 5. Relaciones

#### Cardinalidad de Relaciones:

##### Relación 1:1 (Uno a Uno)
```sql
-- Un registro de A se relaciona con máximo un registro de B
-- Ejemplo: EMPLEADO ↔ CUENTA_USUARIO
-- Cada empleado tiene una cuenta de usuario
-- Cada cuenta pertenece a un empleado

CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE cuentas_usuario (
    id INT PRIMARY KEY,
    empleado_id INT UNIQUE,  -- UNIQUE para relación 1:1
    username VARCHAR(50),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);
```

##### Relación 1:N (Uno a Muchos)
```sql
-- Un registro de A se relaciona con varios registros de B
-- Ejemplo: CLIENTE → VENTAS
-- Un cliente puede tener múltiples ventas
-- Cada venta pertenece a un cliente

CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE ventas (
    id INT PRIMARY KEY,
    cliente_id INT,  -- Sin UNIQUE para permitir múltiples
    fecha_venta DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

##### Relación N:N (Muchos a Muchos)
```sql
-- Varios registros de A se relacionan con varios registros de B
-- Ejemplo: ESTUDIANTES ↔ CURSOS
-- Un estudiante puede tomar múltiples cursos
-- Un curso puede tener múltiples estudiantes

-- Requiere tabla intermedia
CREATE TABLE estudiantes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE cursos (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE inscripciones (
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE,
    calificacion DECIMAL(3,2),
    PRIMARY KEY (estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);
```

### 6. Restricciones

#### Restricciones de Integridad:
```sql
-- RESTRICCIÓN DE ENTIDAD: Clave primaria no nula
-- RESTRICCIÓN DE DOMINIO: Valores válidos para atributos
-- RESTRICCIÓN DE REFERENCIA: Integridad referencial
-- RESTRICCIÓN DE USUARIO: Reglas de negocio específicas
```

#### Ejemplos de Restricciones:
```sql
-- Restricción de dominio
ALTER TABLE productos 
ADD CONSTRAINT chk_precio_positivo 
CHECK (precio > 0);

-- Restricción de referencia
ALTER TABLE ventas 
ADD CONSTRAINT fk_cliente 
FOREIGN KEY (cliente_id) REFERENCES clientes(id);

-- Restricción de usuario
ALTER TABLE empleados 
ADD CONSTRAINT chk_edad_valida 
CHECK (edad >= 18 AND edad <= 65);
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca

#### Identificación de Entidades:
```sql
-- Entidades principales:
-- 1. LIBRO (título, ISBN, año, páginas)
-- 2. AUTOR (nombre, nacionalidad, biografía)
-- 3. USUARIO (nombre, email, teléfono)
-- 4. PRÉSTAMO (fecha_préstamo, fecha_devolución)
-- 5. CATEGORÍA (nombre, descripción)
```

#### Relaciones Identificadas:
```sql
-- Relaciones:
-- 1. LIBRO → AUTOR (N:N) - Un libro puede tener varios autores
-- 2. LIBRO → CATEGORÍA (N:1) - Un libro pertenece a una categoría
-- 3. USUARIO → PRÉSTAMO (1:N) - Un usuario puede tener múltiples préstamos
-- 4. LIBRO → PRÉSTAMO (1:N) - Un libro puede ser prestado múltiples veces
```

### Ejemplo 2: Sistema de Ventas

#### Modelo ER Completo:
```sql
-- Entidades y sus atributos:

-- CLIENTE
CLIENTE {
    id_cliente: INT (PK)
    nombre: VARCHAR(100)
    email: VARCHAR(100)
    telefono: VARCHAR(20)
    direccion: TEXT
    fecha_registro: DATE
}

-- PRODUCTO
PRODUCTO {
    id_producto: INT (PK)
    nombre: VARCHAR(200)
    descripcion: TEXT
    precio: DECIMAL(10,2)
    stock: INT
    categoria_id: INT (FK)
}

-- CATEGORIA
CATEGORIA {
    id_categoria: INT (PK)
    nombre: VARCHAR(100)
    descripcion: TEXT
}

-- VENTA
VENTA {
    id_venta: INT (PK)
    cliente_id: INT (FK)
    fecha_venta: DATE
    total: DECIMAL(10,2)
    estado: ENUM('pendiente', 'completada', 'cancelada')
}

-- DETALLE_VENTA
DETALLE_VENTA {
    venta_id: INT (FK)
    producto_id: INT (FK)
    cantidad: INT
    precio_unitario: DECIMAL(10,2)
    subtotal: DECIMAL(10,2)
}
```

## Ejercicios Prácticos

### Ejercicio 1: Identificación de Entidades
**Objetivo**: Identificar entidades para un sistema de hospital.

```sql
-- Entidades identificadas:
-- 1. PACIENTE (id, nombre, fecha_nacimiento, telefono, direccion)
-- 2. DOCTOR (id, nombre, especialidad, consultorio, telefono)
-- 3. CITA (id, fecha, hora, estado, motivo)
-- 4. ESPECIALIDAD (id, nombre, descripcion)
-- 5. HISTORIAL_MEDICO (id, diagnostico, tratamiento, fecha)
-- 6. MEDICAMENTO (id, nombre, dosis, precio)
```

### Ejercicio 2: Definición de Atributos
**Objetivo**: Definir atributos para la entidad EMPLEADO.

```sql
-- Atributos de EMPLEADO:
-- SIMPLES: id, nombre, apellido, fecha_nacimiento, salario
-- COMPUESTOS: direccion (calle, numero, ciudad, codigo_postal)
-- MÚLTIPLES: telefonos (puede tener varios)
-- DERIVADOS: edad (calculada desde fecha_nacimiento)
-- ÚNICOS: id, email, numero_empleado
```

### Ejercicio 3: Relaciones 1:1
**Objetivo**: Crear relación uno a uno entre EMPLEADO y CUENTA_USUARIO.

```sql
-- Crear tablas con relación 1:1
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_contratacion DATE
);

CREATE TABLE cuentas_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT UNIQUE,  -- UNIQUE para relación 1:1
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

-- Insertar datos de ejemplo
INSERT INTO empleados (nombre, apellido, email, fecha_contratacion) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', '2023-01-15'),
('María', 'García', 'maria.garcia@empresa.com', '2023-02-20');

INSERT INTO cuentas_usuario (empleado_id, username, password_hash) VALUES
(1, 'jperez', 'hash_password_1'),
(2, 'mgarcia', 'hash_password_2');
```

### Ejercicio 4: Relaciones 1:N
**Objetivo**: Crear relación uno a muchos entre CLIENTE y PEDIDO.

```sql
-- Crear tablas con relación 1:N
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado'),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Insertar datos de ejemplo
INSERT INTO clientes (nombre, email, telefono) VALUES
('Ana López', 'ana.lopez@email.com', '555-0101'),
('Carlos Ruiz', 'carlos.ruiz@email.com', '555-0102');

INSERT INTO pedidos (cliente_id, fecha_pedido, total, estado) VALUES
(1, '2024-01-15', 150.00, 'entregado'),
(1, '2024-01-20', 75.50, 'enviado'),
(2, '2024-01-18', 200.00, 'procesando');
```

### Ejercicio 5: Relaciones N:N
**Objetivo**: Crear relación muchos a muchos entre ESTUDIANTE y CURSO.

```sql
-- Crear tablas con relación N:N
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_nacimiento DATE
);

CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INT,
    profesor VARCHAR(100)
);

CREATE TABLE inscripciones (
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE,
    calificacion DECIMAL(3,2),
    estado ENUM('activo', 'completado', 'cancelado'),
    PRIMARY KEY (estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

-- Insertar datos de ejemplo
INSERT INTO estudiantes (nombre, apellido, email) VALUES
('Laura', 'Martínez', 'laura.martinez@universidad.edu'),
('Pedro', 'Sánchez', 'pedro.sanchez@universidad.edu');

INSERT INTO cursos (nombre, descripcion, creditos, profesor) VALUES
('Base de Datos', 'Fundamentos de bases de datos relacionales', 4, 'Dr. García'),
('Programación', 'Programación orientada a objetos', 3, 'Dra. López');

INSERT INTO inscripciones (estudiante_id, curso_id, fecha_inscripcion, calificacion, estado) VALUES
(1, 1, '2024-01-10', 8.5, 'completado'),
(1, 2, '2024-01-10', 9.0, 'completado'),
(2, 1, '2024-01-12', 7.8, 'activo');
```

### Ejercicio 6: Entidades Débiles
**Objetivo**: Crear entidad débil DEPENDIENTE que depende de EMPLEADO.

```sql
-- Entidad fuerte EMPLEADO
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    departamento VARCHAR(50)
);

-- Entidad débil DEPENDIENTE
CREATE TABLE dependientes (
    empleado_id INT,
    nombre_dependiente VARCHAR(100),
    relacion ENUM('esposo', 'esposa', 'hijo', 'hija', 'padre', 'madre'),
    fecha_nacimiento DATE,
    PRIMARY KEY (empleado_id, nombre_dependiente),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
);

-- Insertar datos de ejemplo
INSERT INTO empleados (nombre, apellido, salario, departamento) VALUES
('Roberto', 'Jiménez', 50000.00, 'Ventas'),
('Elena', 'Vega', 45000.00, 'Marketing');

INSERT INTO dependientes (empleado_id, nombre_dependiente, relacion, fecha_nacimiento) VALUES
(1, 'María Jiménez', 'esposa', '1985-03-15'),
(1, 'Carlos Jiménez', 'hijo', '2010-07-22'),
(2, 'Ana Vega', 'hija', '2012-11-08');
```

### Ejercicio 7: Atributos Compuestos
**Objetivo**: Modelar atributo compuesto DIRECCION.

```sql
-- Tabla con atributo compuesto
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    -- Atributo compuesto DIRECCION
    calle VARCHAR(100),
    numero VARCHAR(10),
    ciudad VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50) DEFAULT 'México'
);

-- Insertar datos con atributo compuesto
INSERT INTO clientes (nombre, email, calle, numero, ciudad, codigo_postal) VALUES
('Miguel Torres', 'miguel.torres@email.com', 'Av. Reforma', '123', 'Ciudad de México', '06000'),
('Sofia Herrera', 'sofia.herrera@email.com', 'Calle Morelos', '456', 'Guadalajara', '44100');
```

### Ejercicio 8: Restricciones de Integridad
**Objetivo**: Implementar restricciones en el modelo ER.

```sql
-- Tabla con múltiples restricciones
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    categoria VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Restricciones de integridad
    CONSTRAINT chk_precio_positivo CHECK (precio > 0),
    CONSTRAINT chk_stock_no_negativo CHECK (stock >= 0),
    CONSTRAINT chk_nombre_no_vacio CHECK (LENGTH(TRIM(nombre)) > 0)
);

-- Tabla con restricciones de referencia
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unitario_positivo CHECK (precio_unitario > 0)
);
```

### Ejercicio 9: Conversión a Esquema Relacional
**Objetivo**: Convertir modelo ER a esquema relacional para sistema de biblioteca.

```sql
-- Crear base de datos
CREATE DATABASE biblioteca_er;
USE biblioteca_er;

-- Tabla AUTORES
CREATE TABLE autores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50),
    fecha_nacimiento DATE,
    biografia TEXT
);

-- Tabla CATEGORIAS
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla LIBROS
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    año_publicacion YEAR,
    paginas INT,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabla intermedia LIBROS_AUTORES (relación N:N)
CREATE TABLE libros_autores (
    libro_id INT,
    autor_id INT,
    PRIMARY KEY (libro_id, autor_id),
    FOREIGN KEY (libro_id) REFERENCES libros(id),
    FOREIGN KEY (autor_id) REFERENCES autores(id)
);

-- Tabla USUARIOS
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla PRESTAMOS
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (libro_id) REFERENCES libros(id)
);
```

### Ejercicio 10: Caso de Estudio Completo
**Objetivo**: Diseñar modelo ER completo para sistema de gestión de restaurante.

```sql
-- Base de datos del restaurante
CREATE DATABASE restaurante_er;
USE restaurante_er;

-- Tabla MESAS
CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    ubicacion ENUM('interior', 'exterior', 'terraza'),
    activa BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_capacidad_positiva CHECK (capacidad > 0)
);

-- Tabla CLIENTES
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla CATEGORIAS_PLATOS
CREATE TABLE categorias_platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla PLATOS
CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(8,2) NOT NULL,
    categoria_id INT,
    disponible BOOLEAN DEFAULT TRUE,
    tiempo_preparacion INT, -- en minutos
    FOREIGN KEY (categoria_id) REFERENCES categorias_platos(id),
    CONSTRAINT chk_precio_positivo CHECK (precio > 0)
);

-- Tabla RESERVAS
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    mesa_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    numero_personas INT NOT NULL,
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    notas TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (mesa_id) REFERENCES mesas(id),
    CONSTRAINT chk_personas_positivas CHECK (numero_personas > 0)
);

-- Tabla ORDENES
CREATE TABLE ordenes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reserva_id INT,
    mesa_id INT NOT NULL,
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'preparando', 'lista', 'servida', 'pagada') DEFAULT 'pendiente',
    FOREIGN KEY (reserva_id) REFERENCES reservas(id),
    FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);

-- Tabla DETALLE_ORDENES
CREATE TABLE detalle_ordenes (
    orden_id INT,
    plato_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notas TEXT,
    PRIMARY KEY (orden_id, plato_id),
    FOREIGN KEY (orden_id) REFERENCES ordenes(id),
    FOREIGN KEY (plato_id) REFERENCES platos(id),
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0)
);

-- Índices para optimización
CREATE INDEX idx_reservas_fecha ON reservas(fecha_reserva);
CREATE INDEX idx_reservas_cliente ON reservas(cliente_id);
CREATE INDEX idx_ordenes_fecha ON ordenes(fecha_orden);
CREATE INDEX idx_ordenes_mesa ON ordenes(mesa_id);
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Modelo ER**: Representación conceptual de datos
2. **Entidades**: Objetos del mundo real
3. **Atributos**: Características de las entidades
4. **Relaciones**: Conexiones entre entidades
5. **Cardinalidad**: 1:1, 1:N, N:N
6. **Restricciones**: Reglas de integridad
7. **Conversión**: De modelo ER a esquema relacional

### Próximos Pasos:
- Aprender normalización de bases de datos
- Estudiar primera forma normal
- Practicar con casos complejos de modelado

### Recursos Adicionales:
- Herramientas de diagramación ER
- Casos de estudio de modelado
- Documentación de metodologías de diseño
