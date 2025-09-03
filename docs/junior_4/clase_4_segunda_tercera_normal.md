# Clase 4: Normalización - Segunda y Tercera Forma Normal

## Objetivos de la Clase
- Comprender la Segunda Forma Normal (2FN)
- Aplicar la Tercera Forma Normal (3FN)
- Identificar dependencias funcionales
- Resolver anomalías de actualización

## Contenido Teórico

### 1. Dependencias Funcionales

#### Definición
Una **dependencia funcional** es una relación entre atributos donde el valor de un atributo (o conjunto de atributos) determina únicamente el valor de otro atributo.

#### Notación:
```
A → B
```
Se lee: "A determina funcionalmente a B" o "B depende funcionalmente de A"

#### Ejemplos:
```sql
-- En tabla EMPLEADOS:
-- id_empleado → nombre, salario, departamento
-- departamento → jefe_departamento, presupuesto

-- En tabla VENTAS:
-- id_venta → fecha, total, cliente_id
-- cliente_id → nombre_cliente, direccion_cliente
```

### 2. Segunda Forma Normal (2FN)

#### Definición
Una tabla está en **Segunda Forma Normal** cuando:
- Está en Primera Forma Normal (1FN)
- Todos los atributos no clave dependen completamente de la clave primaria
- No hay dependencias parciales

#### Dependencia Parcial
Una dependencia parcial ocurre cuando un atributo no clave depende solo de parte de la clave primaria compuesta.

#### Ejemplo de Violación de 2FN:
```sql
-- ❌ VIOLACIÓN: Dependencia parcial
CREATE TABLE ventas_productos_violacion (
    venta_id INT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    nombre_producto VARCHAR(200),  -- Depende solo de producto_id
    categoria_producto VARCHAR(100), -- Depende solo de producto_id
    fecha_venta DATE,              -- Depende solo de venta_id
    cliente_id INT,                -- Depende solo de venta_id
    PRIMARY KEY (venta_id, producto_id)
);

-- Dependencias identificadas:
-- (venta_id, producto_id) → cantidad, precio_unitario
-- producto_id → nombre_producto, categoria_producto  (DEPENDENCIA PARCIAL)
-- venta_id → fecha_venta, cliente_id  (DEPENDENCIA PARCIAL)
```

#### Solución Aplicando 2FN:
```sql
-- ✅ SOLUCIÓN: Separar en tablas
CREATE TABLE ventas_2fn (
    venta_id INT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    cliente_id INT NOT NULL,
    total DECIMAL(10,2)
);

CREATE TABLE productos_2fn (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(200) NOT NULL,
    categoria_producto VARCHAR(100),
    precio_base DECIMAL(10,2)
);

CREATE TABLE detalle_ventas_2fn (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas_2fn(venta_id),
    FOREIGN KEY (producto_id) REFERENCES productos_2fn(producto_id)
);
```

### 3. Tercera Forma Normal (3FN)

#### Definición
Una tabla está en **Tercera Forma Normal** cuando:
- Está en Segunda Forma Normal (2FN)
- No hay dependencias transitivas
- Todos los atributos no clave dependen directamente de la clave primaria

#### Dependencia Transitiva
Una dependencia transitiva ocurre cuando:
```
A → B y B → C, entonces A → C (transitivamente)
```

#### Ejemplo de Violación de 3FN:
```sql
-- ❌ VIOLACIÓN: Dependencia transitiva
CREATE TABLE empleados_violacion (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento_id INT,
    nombre_departamento VARCHAR(100),  -- Depende de departamento_id
    jefe_departamento VARCHAR(100),    -- Depende de departamento_id
    presupuesto_departamento DECIMAL(12,2) -- Depende de departamento_id
);

-- Dependencias identificadas:
-- id_empleado → nombre, salario, departamento_id
-- departamento_id → nombre_departamento, jefe_departamento, presupuesto_departamento
-- Por transitividad: id_empleado → nombre_departamento, jefe_departamento, presupuesto_departamento
```

#### Solución Aplicando 3FN:
```sql
-- ✅ SOLUCIÓN: Separar dependencias transitivas
CREATE TABLE departamentos_3fn (
    departamento_id INT PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL,
    jefe_departamento VARCHAR(100),
    presupuesto_departamento DECIMAL(12,2)
);

CREATE TABLE empleados_3fn (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos_3fn(departamento_id)
);
```

### 4. Proceso de Aplicación de 2FN y 3FN

#### Paso 1: Identificar Dependencias Funcionales
```sql
-- Analizar cada atributo no clave:
-- 1. ¿De qué depende completamente?
-- 2. ¿Hay dependencias parciales?
-- 3. ¿Hay dependencias transitivas?
```

#### Paso 2: Aplicar 2FN
```sql
-- Separar dependencias parciales en tablas independientes
-- Mover atributos que dependen solo de parte de la clave compuesta
```

#### Paso 3: Aplicar 3FN
```sql
-- Separar dependencias transitivas
-- Mover atributos que dependen de otros atributos no clave
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca

#### Tabla Antes de 2FN y 3FN:
```sql
-- ❌ Tabla con violaciones de 2FN y 3FN
CREATE TABLE prestamos_violacion (
    prestamo_id INT,
    libro_id INT,
    usuario_id INT,
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    titulo_libro VARCHAR(200),      -- Depende solo de libro_id (2FN)
    autor_libro VARCHAR(200),       -- Depende solo de libro_id (2FN)
    categoria_libro VARCHAR(100),   -- Depende solo de libro_id (2FN)
    nombre_usuario VARCHAR(100),    -- Depende solo de usuario_id (2FN)
    telefono_usuario VARCHAR(20),   -- Depende solo de usuario_id (2FN)
    direccion_usuario TEXT,         -- Depende solo de usuario_id (2FN)
    tipo_usuario VARCHAR(50),       -- Depende solo de usuario_id (2FN)
    limite_prestamos INT,           -- Depende de tipo_usuario (3FN)
    PRIMARY KEY (prestamo_id, libro_id)
);
```

#### Solución Aplicando 2FN y 3FN:
```sql
-- ✅ Tablas normalizadas
CREATE TABLE usuarios_3fn (
    usuario_id INT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    telefono_usuario VARCHAR(20),
    direccion_usuario TEXT,
    tipo_usuario_id INT
);

CREATE TABLE tipos_usuario (
    tipo_usuario_id INT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    limite_prestamos INT NOT NULL,
    dias_prestamo INT NOT NULL
);

CREATE TABLE libros_3fn (
    libro_id INT PRIMARY KEY,
    titulo_libro VARCHAR(200) NOT NULL,
    autor_libro VARCHAR(200),
    categoria_id INT
);

CREATE TABLE categorias_libros (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE prestamos_3fn (
    prestamo_id INT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    FOREIGN KEY (usuario_id) REFERENCES usuarios_3fn(usuario_id)
);

CREATE TABLE detalle_prestamos (
    prestamo_id INT,
    libro_id INT,
    PRIMARY KEY (prestamo_id, libro_id),
    FOREIGN KEY (prestamo_id) REFERENCES prestamos_3fn(prestamo_id),
    FOREIGN KEY (libro_id) REFERENCES libros_3fn(libro_id)
);

-- Agregar relaciones faltantes
ALTER TABLE usuarios_3fn 
ADD FOREIGN KEY (tipo_usuario_id) REFERENCES tipos_usuario(tipo_usuario_id);

ALTER TABLE libros_3fn 
ADD FOREIGN KEY (categoria_id) REFERENCES categorias_libros(categoria_id);
```

### Ejemplo 2: Sistema de Ventas

#### Análisis de Dependencias:
```sql
-- Tabla original con violaciones
CREATE TABLE ventas_completa_violacion (
    venta_id INT,
    producto_id INT,
    cliente_id INT,
    vendedor_id INT,
    fecha_venta DATE,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    nombre_producto VARCHAR(200),   -- producto_id → nombre_producto
    categoria_producto VARCHAR(100), -- producto_id → categoria_producto
    precio_base_producto DECIMAL(10,2), -- producto_id → precio_base_producto
    nombre_cliente VARCHAR(100),    -- cliente_id → nombre_cliente
    direccion_cliente TEXT,         -- cliente_id → direccion_cliente
    telefono_cliente VARCHAR(20),   -- cliente_id → telefono_cliente
    nombre_vendedor VARCHAR(100),   -- vendedor_id → nombre_vendedor
    comision_vendedor DECIMAL(5,2), -- vendedor_id → comision_vendedor
    departamento_vendedor VARCHAR(50), -- vendedor_id → departamento_vendedor
    PRIMARY KEY (venta_id, producto_id)
);
```

#### Solución Normalizada:
```sql
-- ✅ Tablas en 3FN
CREATE TABLE clientes_3fn (
    cliente_id INT PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    direccion_cliente TEXT,
    telefono_cliente VARCHAR(20),
    email_cliente VARCHAR(100)
);

CREATE TABLE vendedores_3fn (
    vendedor_id INT PRIMARY KEY,
    nombre_vendedor VARCHAR(100) NOT NULL,
    comision_vendedor DECIMAL(5,2),
    departamento_id INT
);

CREATE TABLE departamentos_3fn (
    departamento_id INT PRIMARY KEY,
    nombre_departamento VARCHAR(50) NOT NULL,
    presupuesto DECIMAL(12,2)
);

CREATE TABLE categorias_productos_3fn (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE productos_3fn (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(200) NOT NULL,
    categoria_id INT,
    precio_base DECIMAL(10,2),
    stock_actual INT DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias_productos_3fn(categoria_id)
);

CREATE TABLE ventas_3fn (
    venta_id INT PRIMARY KEY,
    cliente_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes_3fn(cliente_id),
    FOREIGN KEY (vendedor_id) REFERENCES vendedores_3fn(vendedor_id)
);

CREATE TABLE detalle_ventas_3fn (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas_3fn(venta_id),
    FOREIGN KEY (producto_id) REFERENCES productos_3fn(producto_id)
);

-- Agregar relación faltante
ALTER TABLE vendedores_3fn 
ADD FOREIGN KEY (departamento_id) REFERENCES departamentos_3fn(departamento_id);
```

## Ejercicios Prácticos

### Ejercicio 1: Identificar Dependencias Funcionales
**Objetivo**: Identificar dependencias en tabla de empleados.

```sql
-- Tabla con dependencias
CREATE TABLE empleados_dependencias (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento_id INT,
    nombre_departamento VARCHAR(100),
    jefe_departamento VARCHAR(100),
    presupuesto DECIMAL(12,2),
    proyecto_id INT,
    nombre_proyecto VARCHAR(200),
    fecha_inicio_proyecto DATE,
    fecha_fin_proyecto DATE
);

-- Dependencias identificadas:
-- id_empleado → nombre, salario, departamento_id, proyecto_id
-- departamento_id → nombre_departamento, jefe_departamento, presupuesto
-- proyecto_id → nombre_proyecto, fecha_inicio_proyecto, fecha_fin_proyecto
```

### Ejercicio 2: Aplicar 2FN a Sistema de Inventario
**Objetivo**: Normalizar tabla de movimientos de inventario.

```sql
-- ❌ Tabla con violaciones de 2FN
CREATE TABLE movimientos_inventario_violacion (
    movimiento_id INT,
    producto_id INT,
    almacen_id INT,
    fecha_movimiento DATE,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste'),
    cantidad INT,
    nombre_producto VARCHAR(200),    -- Depende solo de producto_id
    categoria_producto VARCHAR(100), -- Depende solo de producto_id
    nombre_almacen VARCHAR(100),     -- Depende solo de almacen_id
    ubicacion_almacen VARCHAR(200),  -- Depende solo de almacen_id
    responsable VARCHAR(100),
    PRIMARY KEY (movimiento_id, producto_id, almacen_id)
);
```

**Solución normalizada**:
```sql
-- ✅ Tablas en 2FN
CREATE TABLE productos_inventario_2fn (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(200) NOT NULL,
    categoria_producto VARCHAR(100),
    precio_unitario DECIMAL(10,2)
);

CREATE TABLE almacenes_2fn (
    almacen_id INT PRIMARY KEY,
    nombre_almacen VARCHAR(100) NOT NULL,
    ubicacion_almacen VARCHAR(200),
    capacidad_maxima INT
);

CREATE TABLE movimientos_inventario_2fn (
    movimiento_id INT PRIMARY KEY,
    fecha_movimiento DATE NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    responsable VARCHAR(100)
);

CREATE TABLE detalle_movimientos (
    movimiento_id INT,
    producto_id INT,
    almacen_id INT,
    cantidad INT NOT NULL,
    PRIMARY KEY (movimiento_id, producto_id, almacen_id),
    FOREIGN KEY (movimiento_id) REFERENCES movimientos_inventario_2fn(movimiento_id),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_2fn(producto_id),
    FOREIGN KEY (almacen_id) REFERENCES almacenes_2fn(almacen_id)
);
```

### Ejercicio 3: Aplicar 3FN a Sistema de Recursos Humanos
**Objetivo**: Normalizar tabla de empleados con dependencias transitivas.

```sql
-- ❌ Tabla con violaciones de 3FN
CREATE TABLE empleados_rh_violacion (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),
    departamento_id INT,
    nombre_departamento VARCHAR(100),  -- Depende de departamento_id
    jefe_departamento VARCHAR(100),    -- Depende de departamento_id
    presupuesto_departamento DECIMAL(12,2), -- Depende de departamento_id
    ubicacion_departamento VARCHAR(100),    -- Depende de departamento_id
    cargo_id INT,
    nombre_cargo VARCHAR(100),         -- Depende de cargo_id
    nivel_cargo VARCHAR(50),           -- Depende de cargo_id
    salario_minimo_cargo DECIMAL(10,2), -- Depende de cargo_id
    salario_maximo_cargo DECIMAL(10,2)   -- Depende de cargo_id
);
```

**Solución normalizada**:
```sql
-- ✅ Tablas en 3FN
CREATE TABLE departamentos_rh_3fn (
    departamento_id INT PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL,
    jefe_departamento VARCHAR(100),
    presupuesto_departamento DECIMAL(12,2),
    ubicacion_departamento VARCHAR(100)
);

CREATE TABLE cargos_3fn (
    cargo_id INT PRIMARY KEY,
    nombre_cargo VARCHAR(100) NOT NULL,
    nivel_cargo VARCHAR(50),
    salario_minimo DECIMAL(10,2),
    salario_maximo DECIMAL(10,2),
    descripcion TEXT
);

CREATE TABLE empleados_rh_3fn (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    departamento_id INT,
    cargo_id INT,
    fecha_contratacion DATE,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (departamento_id) REFERENCES departamentos_rh_3fn(departamento_id),
    FOREIGN KEY (cargo_id) REFERENCES cargos_3fn(cargo_id)
);
```

### Ejercicio 4: Sistema de Reservas de Hotel
**Objetivo**: Aplicar 2FN y 3FN a sistema de reservas.

```sql
-- ❌ Tabla con violaciones
CREATE TABLE reservas_hotel_violacion (
    reserva_id INT,
    habitacion_id INT,
    cliente_id INT,
    fecha_reserva DATE,
    fecha_entrada DATE,
    fecha_salida DATE,
    numero_habitacion VARCHAR(10),    -- Depende solo de habitacion_id
    tipo_habitacion VARCHAR(50),      -- Depende solo de habitacion_id
    precio_noche DECIMAL(10,2),       -- Depende solo de habitacion_id
    capacidad_habitacion INT,         -- Depende solo de habitacion_id
    nombre_cliente VARCHAR(100),      -- Depende solo de cliente_id
    telefono_cliente VARCHAR(20),     -- Depende solo de cliente_id
    email_cliente VARCHAR(100),       -- Depende solo de cliente_id
    tipo_cliente VARCHAR(50),         -- Depende solo de cliente_id
    descuento_cliente DECIMAL(5,2),   -- Depende de tipo_cliente
    PRIMARY KEY (reserva_id, habitacion_id)
);
```

**Solución normalizada**:
```sql
-- ✅ Tablas normalizadas
CREATE TABLE tipos_habitacion (
    tipo_id INT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10,2) NOT NULL,
    capacidad_maxima INT NOT NULL
);

CREATE TABLE habitaciones_hotel (
    habitacion_id INT PRIMARY KEY,
    numero_habitacion VARCHAR(10) NOT NULL UNIQUE,
    tipo_id INT,
    piso INT,
    estado ENUM('disponible', 'ocupada', 'mantenimiento') DEFAULT 'disponible',
    FOREIGN KEY (tipo_id) REFERENCES tipos_habitacion(tipo_id)
);

CREATE TABLE tipos_cliente (
    tipo_id INT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    descuento DECIMAL(5,2) DEFAULT 0.00,
    beneficios TEXT
);

CREATE TABLE clientes_hotel (
    cliente_id INT PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20),
    email_cliente VARCHAR(100),
    tipo_cliente_id INT,
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (tipo_cliente_id) REFERENCES tipos_cliente(tipo_id)
);

CREATE TABLE reservas_hotel_3fn (
    reserva_id INT PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    FOREIGN KEY (cliente_id) REFERENCES clientes_hotel(cliente_id)
);

CREATE TABLE detalle_reservas (
    reserva_id INT,
    habitacion_id INT,
    precio_noche DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (reserva_id, habitacion_id),
    FOREIGN KEY (reserva_id) REFERENCES reservas_hotel_3fn(reserva_id),
    FOREIGN KEY (habitacion_id) REFERENCES habitaciones_hotel(habitacion_id)
);
```

### Ejercicio 5: Análisis de Dependencias Complejas
**Objetivo**: Analizar dependencias en sistema de educación.

```sql
-- Tabla compleja con múltiples dependencias
CREATE TABLE inscripciones_educacion (
    inscripcion_id INT,
    estudiante_id INT,
    curso_id INT,
    profesor_id INT,
    semestre_id INT,
    fecha_inscripcion DATE,
    calificacion_final DECIMAL(3,2),
    nombre_estudiante VARCHAR(100),      -- estudiante_id → nombre_estudiante
    carrera_estudiante VARCHAR(100),     -- estudiante_id → carrera_estudiante
    semestre_estudiante INT,             -- estudiante_id → semestre_estudiante
    nombre_curso VARCHAR(200),           -- curso_id → nombre_curso
    creditos_curso INT,                  -- curso_id → creditos_curso
    nombre_profesor VARCHAR(100),        -- profesor_id → nombre_profesor
    departamento_profesor VARCHAR(100),  -- profesor_id → departamento_profesor
    nombre_semestre VARCHAR(50),         -- semestre_id → nombre_semestre
    fecha_inicio_semestre DATE,          -- semestre_id → fecha_inicio_semestre
    fecha_fin_semestre DATE,             -- semestre_id → fecha_fin_semestre
    PRIMARY KEY (inscripcion_id, estudiante_id, curso_id)
);
```

### Ejercicio 6: Caso de Estudio Completo
**Objetivo**: Normalizar sistema de gestión de restaurante.

```sql
-- ❌ Tabla con múltiples violaciones
CREATE TABLE restaurante_completo_violacion (
    orden_id INT,
    mesa_id INT,
    plato_id INT,
    cliente_id INT,
    mesero_id INT,
    fecha_orden DATE,
    hora_orden TIME,
    cantidad INT,
    precio_unitario DECIMAL(8,2),
    subtotal DECIMAL(10,2),
    numero_mesa INT,                    -- Depende solo de mesa_id
    capacidad_mesa INT,                 -- Depende solo de mesa_id
    ubicacion_mesa VARCHAR(50),         -- Depende solo de mesa_id
    nombre_plato VARCHAR(200),          -- Depende solo de plato_id
    categoria_plato VARCHAR(100),       -- Depende solo de plato_id
    tiempo_preparacion INT,             -- Depende solo de plato_id
    nombre_cliente VARCHAR(100),        -- Depende solo de cliente_id
    telefono_cliente VARCHAR(20),       -- Depende solo de cliente_id
    nombre_mesero VARCHAR(100),         -- Depende solo de mesero_id
    turno_mesero ENUM('mañana', 'tarde', 'noche'), -- Depende solo de mesero_id
    comision_mesero DECIMAL(5,2),       -- Depende solo de mesero_id
    PRIMARY KEY (orden_id, mesa_id, plato_id)
);
```

**Solución completamente normalizada**:
```sql
-- ✅ Sistema completamente normalizado
CREATE DATABASE restaurante_3fn;
USE restaurante_3fn;

-- Tabla de ubicaciones de mesas
CREATE TABLE ubicaciones_mesa (
    ubicacion_id INT PRIMARY KEY,
    nombre_ubicacion VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de mesas
CREATE TABLE mesas_3fn (
    mesa_id INT PRIMARY KEY,
    numero_mesa INT NOT NULL UNIQUE,
    capacidad_mesa INT NOT NULL,
    ubicacion_id INT,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones_mesa(ubicacion_id)
);

-- Tabla de categorías de platos
CREATE TABLE categorias_platos_3fn (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de platos
CREATE TABLE platos_3fn (
    plato_id INT PRIMARY KEY,
    nombre_plato VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT,
    precio_base DECIMAL(8,2) NOT NULL,
    tiempo_preparacion INT, -- en minutos
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_platos_3fn(categoria_id)
);

-- Tabla de turnos
CREATE TABLE turnos (
    turno_id INT PRIMARY KEY,
    nombre_turno ENUM('mañana', 'tarde', 'noche') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    comision_base DECIMAL(5,2) NOT NULL
);

-- Tabla de meseros
CREATE TABLE meseros_3fn (
    mesero_id INT PRIMARY KEY,
    nombre_mesero VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    turno_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (turno_id) REFERENCES turnos(turno_id)
);

-- Tabla de clientes
CREATE TABLE clientes_3fn (
    cliente_id INT PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20),
    email_cliente VARCHAR(100),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de órdenes
CREATE TABLE ordenes_3fn (
    orden_id INT PRIMARY KEY,
    mesa_id INT NOT NULL,
    cliente_id INT,
    mesero_id INT NOT NULL,
    fecha_orden DATE NOT NULL,
    hora_orden TIME NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'preparando', 'lista', 'servida', 'pagada') DEFAULT 'pendiente',
    FOREIGN KEY (mesa_id) REFERENCES mesas_3fn(mesa_id),
    FOREIGN KEY (cliente_id) REFERENCES clientes_3fn(cliente_id),
    FOREIGN KEY (mesero_id) REFERENCES meseros_3fn(mesero_id)
);

-- Tabla de detalle de órdenes
CREATE TABLE detalle_ordenes_3fn (
    orden_id INT,
    plato_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notas TEXT,
    PRIMARY KEY (orden_id, plato_id),
    FOREIGN KEY (orden_id) REFERENCES ordenes_3fn(orden_id),
    FOREIGN KEY (plato_id) REFERENCES platos_3fn(plato_id)
);
```

### Ejercicio 7: Beneficios de 2FN y 3FN
**Objetivo**: Demostrar beneficios de la normalización avanzada.

```sql
-- BENEFICIOS DEMOSTRADOS:

-- 1. ELIMINACIÓN DE REDUNDANCIA AVANZADA
-- Antes: Información de departamento repetida en cada empleado
-- Después: Una sola tabla de departamentos

-- 2. PREVENCIÓN DE ANOMALÍAS DE ACTUALIZACIÓN
-- Antes: Cambiar nombre de departamento requería actualizar múltiples filas
-- Después: Cambiar en tabla departamentos se refleja automáticamente

-- 3. INTEGRIDAD REFERENCIAL
-- Antes: Sin restricciones entre tablas relacionadas
-- Después: FOREIGN KEY constraints garantizan integridad

-- 4. FACILITAR CONSULTAS COMPLEJAS
-- Antes: JOINs complejos en tablas desnormalizadas
-- Después: JOINs claros entre tablas normalizadas

-- 5. ESCALABILIDAD MEJORADA
-- Antes: Agregar nuevo departamento requería modificar estructura
-- Después: Solo insertar en tabla departamentos
```

### Ejercicio 8: Casos Especiales de Normalización
**Objetivo**: Manejar casos especiales en la normalización.

```sql
-- Caso especial: Desnormalización controlada
-- A veces es aceptable desnormalizar para mejorar rendimiento
CREATE TABLE reportes_ventas_desnormalizado (
    reporte_id INT PRIMARY KEY,
    fecha_reporte DATE,
    total_ventas DECIMAL(12,2),
    numero_ventas INT,
    cliente_mas_frecuente VARCHAR(100),  -- Desnormalizado para reportes rápidos
    producto_mas_vendido VARCHAR(200),   -- Desnormalizado para reportes rápidos
    vendedor_top VARCHAR(100)            -- Desnormalizado para reportes rápidos
);

-- Esta tabla se actualiza mediante triggers o procesos ETL
-- para mantener consistencia con las tablas normalizadas
```

### Ejercicio 9: Validación de Normalización
**Objetivo**: Crear procedimiento para validar normalización.

```sql
-- Procedimiento para validar 2FN y 3FN
DELIMITER //
CREATE PROCEDURE validar_normalizacion(
    IN nombre_tabla VARCHAR(100)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE columna_nombre VARCHAR(100);
    DECLARE columna_tipo VARCHAR(100);
    DECLARE cur CURSOR FOR 
        SELECT COLUMN_NAME, DATA_TYPE 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = nombre_tabla;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Análisis conceptual de dependencias
    -- (Implementación simplificada)
    
    SELECT CONCAT('Análisis de normalización para tabla: ', nombre_tabla) AS resultado;
    SELECT 'Verificar dependencias funcionales' AS paso_1;
    SELECT 'Verificar dependencias parciales (2FN)' AS paso_2;
    SELECT 'Verificar dependencias transitivas (3FN)' AS paso_3;
END//
DELIMITER ;

-- Ejemplo de uso
CALL validar_normalizacion('empleados_3fn');
```

### Ejercicio 10: Migración Completa
**Objetivo**: Migrar sistema completo a 3FN.

```sql
-- Script de migración completo
DELIMITER //
CREATE PROCEDURE migrar_a_3fn()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 1. Crear tablas normalizadas
    -- 2. Migrar datos existentes
    -- 3. Crear índices
    -- 4. Crear restricciones
    -- 5. Validar integridad
    
    COMMIT;
    
    SELECT 'Migración a 3FN completada exitosamente' AS resultado;
END//
DELIMITER ;

-- Ejecutar migración
CALL migrar_a_3fn();
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Dependencias Funcionales**: Relaciones entre atributos
2. **Segunda Forma Normal**: Eliminación de dependencias parciales
3. **Tercera Forma Normal**: Eliminación de dependencias transitivas
4. **Proceso de Normalización**: Identificar, separar, validar
5. **Beneficios**: Integridad, rendimiento, mantenibilidad

### Próximos Pasos:
- Aprender Forma Normal de Boyce-Codd
- Estudiar cuarta y quinta forma normal
- Practicar con casos complejos de normalización

### Recursos Adicionales:
- Documentación sobre dependencias funcionales
- Herramientas de análisis de normalización
- Casos de estudio de empresas reales
