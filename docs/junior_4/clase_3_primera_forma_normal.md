# Clase 3: Normalización - Primera Forma Normal

## Objetivos de la Clase
- Comprender qué es la normalización de bases de datos
- Aplicar la Primera Forma Normal (1FN)
- Identificar y corregir violaciones de 1FN
- Entender los beneficios de la normalización

## Contenido Teórico

### 1. ¿Qué es la Normalización?

**Normalización** es el proceso de organizar los datos en una base de datos para eliminar redundancias, inconsistencias y anomalías, dividiendo las tablas en estructuras más pequeñas y manejables.

#### Objetivos de la Normalización:
- **Eliminar redundancia**: Evitar datos duplicados
- **Prevenir anomalías**: Evitar inconsistencias
- **Simplificar estructura**: Hacer el diseño más claro
- **Facilitar mantenimiento**: Hacer cambios más fáciles
- **Optimizar rendimiento**: Mejorar consultas

#### Formas Normales:
1. **Primera Forma Normal (1FN)**
2. **Segunda Forma Normal (2FN)**
3. **Tercera Forma Normal (3FN)**
4. **Forma Normal de Boyce-Codd (FNBC)**
5. **Cuarta Forma Normal (4FN)**
6. **Quinta Forma Normal (5FN)**

### 2. Primera Forma Normal (1FN)

#### Definición
Una tabla está en **Primera Forma Normal** cuando:
- Todos los atributos contienen valores atómicos (indivisibles)
- No hay grupos repetitivos
- Cada celda contiene un solo valor
- No hay filas duplicadas

#### Características de 1FN:
```sql
-- ✅ CORRECTO: Valores atómicos
CREATE TABLE empleados_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),        -- Valor atómico
    apellido VARCHAR(100),      -- Valor atómico
    salario DECIMAL(10,2),      -- Valor atómico
    fecha_contratacion DATE     -- Valor atómico
);

-- ❌ INCORRECTO: Valores no atómicos
CREATE TABLE empleados_no_1fn (
    id INT PRIMARY KEY,
    nombre_completo VARCHAR(200),  -- "Juan Pérez" no es atómico
    telefonos VARCHAR(200),        -- "555-1234, 555-5678" no es atómico
    direccion TEXT                 -- "Calle 123, Col. Centro, CDMX" no es atómico
);
```

### 3. Violaciones de la Primera Forma Normal

#### Violación 1: Valores Múltiples en una Celda
```sql
-- ❌ VIOLACIÓN: Múltiples valores en una celda
CREATE TABLE productos_violacion (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    categorias VARCHAR(200)  -- "Electrónicos, Hogar, Oficina"
);

-- ✅ SOLUCIÓN: Separar en tabla relacionada
CREATE TABLE productos_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE categorias (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE productos_categorias (
    producto_id INT,
    categoria_id INT,
    PRIMARY KEY (producto_id, categoria_id),
    FOREIGN KEY (producto_id) REFERENCES productos_1fn(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
```

#### Violación 2: Grupos Repetitivos
```sql
-- ❌ VIOLACIÓN: Grupos repetitivos
CREATE TABLE estudiantes_violacion (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    telefono1 VARCHAR(20),
    telefono2 VARCHAR(20),
    telefono3 VARCHAR(20),
    email1 VARCHAR(100),
    email2 VARCHAR(100)
);

-- ✅ SOLUCIÓN: Tabla separada para contactos
CREATE TABLE estudiantes_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE contactos_estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT,
    tipo_contacto ENUM('telefono', 'email'),
    valor VARCHAR(100),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes_1fn(id)
);
```

#### Violación 3: Atributos Compuestos
```sql
-- ❌ VIOLACIÓN: Atributo compuesto
CREATE TABLE clientes_violacion (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    direccion_completa TEXT  -- "Calle 123, Col. Centro, CDMX, 06000"
);

-- ✅ SOLUCIÓN: Separar en atributos atómicos
CREATE TABLE clientes_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    calle VARCHAR(100),
    numero VARCHAR(10),
    colonia VARCHAR(100),
    ciudad VARCHAR(50),
    codigo_postal VARCHAR(10)
);
```

### 4. Proceso de Aplicación de 1FN

#### Paso 1: Identificar Violaciones
```sql
-- Analizar cada columna para identificar:
-- 1. Valores múltiples separados por comas
-- 2. Grupos repetitivos
-- 3. Atributos compuestos
-- 4. Filas duplicadas
```

#### Paso 2: Separar Valores Múltiples
```sql
-- Antes (violación):
-- categorias: "Electrónicos, Hogar, Oficina"

-- Después (1FN):
-- Tabla productos_categorias con filas separadas
```

#### Paso 3: Eliminar Grupos Repetitivos
```sql
-- Antes (violación):
-- telefono1, telefono2, telefono3

-- Después (1FN):
-- Tabla contactos con tipo_contacto y valor
```

#### Paso 4: Descomponer Atributos Compuestos
```sql
-- Antes (violación):
-- direccion_completa: "Calle 123, Col. Centro, CDMX, 06000"

-- Después (1FN):
-- calle, numero, colonia, ciudad, codigo_postal
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Ventas

#### Tabla Antes de 1FN:
```sql
-- ❌ Tabla con violaciones de 1FN
CREATE TABLE ventas_no_1fn (
    id INT PRIMARY KEY,
    cliente VARCHAR(100),
    productos VARCHAR(500),  -- "Laptop, Mouse, Teclado"
    cantidades VARCHAR(50),  -- "1, 2, 1"
    precios VARCHAR(100),    -- "1000, 25, 50"
    fecha_venta DATE
);

-- Datos de ejemplo (problemáticos):
INSERT INTO ventas_no_1fn VALUES
(1, 'Juan Pérez', 'Laptop, Mouse, Teclado', '1, 2, 1', '1000, 25, 50', '2024-01-15'),
(2, 'María García', 'Monitor, Cable', '1, 3', '300, 15', '2024-01-16');
```

#### Tabla Después de 1FN:
```sql
-- ✅ Aplicando 1FN
CREATE TABLE clientes_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE productos_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE ventas_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes_1fn(id)
);

CREATE TABLE detalle_ventas_1fn (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas_1fn(id),
    FOREIGN KEY (producto_id) REFERENCES productos_1fn(id)
);

-- Datos normalizados:
INSERT INTO clientes_1fn (nombre) VALUES
('Juan Pérez'),
('María García');

INSERT INTO productos_1fn (nombre, precio) VALUES
('Laptop', 1000.00),
('Mouse', 25.00),
('Teclado', 50.00),
('Monitor', 300.00),
('Cable', 15.00);

INSERT INTO ventas_1fn (cliente_id, fecha_venta) VALUES
(1, '2024-01-15'),
(2, '2024-01-16');

INSERT INTO detalle_ventas_1fn VALUES
(1, 1, 1, 1000.00, 1000.00),  -- Laptop
(1, 2, 2, 25.00, 50.00),      -- Mouse
(1, 3, 1, 50.00, 50.00),      -- Teclado
(2, 4, 1, 300.00, 300.00),    -- Monitor
(2, 5, 3, 15.00, 45.00);      -- Cable
```

### Ejemplo 2: Sistema de Biblioteca

#### Problema: Información de Contacto Múltiple
```sql
-- ❌ Violación: Múltiples teléfonos en una celda
CREATE TABLE usuarios_biblioteca_no_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    telefonos VARCHAR(200),  -- "555-1234, 555-5678, 555-9999"
    emails VARCHAR(300)      -- "personal@email.com, trabajo@empresa.com"
);
```

#### Solución Aplicando 1FN:
```sql
-- ✅ Solución normalizada
CREATE TABLE usuarios_biblioteca_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE contactos_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    tipo_contacto ENUM('telefono', 'email') NOT NULL,
    valor VARCHAR(100) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios_biblioteca_1fn(id)
);

-- Datos normalizados:
INSERT INTO usuarios_biblioteca_1fn (nombre) VALUES
('Ana López'),
('Carlos Ruiz');

INSERT INTO contactos_usuarios (usuario_id, tipo_contacto, valor, es_principal) VALUES
(1, 'telefono', '555-1234', TRUE),
(1, 'telefono', '555-5678', FALSE),
(1, 'email', 'ana.lopez@email.com', TRUE),
(2, 'telefono', '555-9999', TRUE),
(2, 'email', 'carlos.ruiz@email.com', TRUE),
(2, 'email', 'carlos.ruiz@trabajo.com', FALSE);
```

## Ejercicios Prácticos

### Ejercicio 1: Identificar Violaciones de 1FN
**Objetivo**: Identificar violaciones en la siguiente tabla.

```sql
-- Tabla con violaciones
CREATE TABLE empleados_violacion (
    id INT PRIMARY KEY,
    nombre_completo VARCHAR(200),  -- "Juan Carlos Pérez García"
    telefonos VARCHAR(200),        -- "555-1234, 555-5678"
    direccion TEXT,                -- "Calle 123, Col. Centro, CDMX, 06000"
    habilidades VARCHAR(300),      -- "SQL, Python, Java, JavaScript"
    salarios_historial VARCHAR(200) -- "30000, 35000, 40000"
);
```

**Violaciones identificadas**:
1. `nombre_completo`: Atributo compuesto (nombre + apellidos)
2. `telefonos`: Múltiples valores en una celda
3. `direccion`: Atributo compuesto
4. `habilidades`: Múltiples valores en una celda
5. `salarios_historial`: Múltiples valores en una celda

### Ejercicio 2: Aplicar 1FN a Empleados
**Objetivo**: Normalizar la tabla de empleados.

```sql
-- ✅ Solución normalizada
CREATE TABLE empleados_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    fecha_contratacion DATE,
    salario_actual DECIMAL(10,2)
);

CREATE TABLE telefonos_empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('personal', 'trabajo', 'emergencia') DEFAULT 'personal',
    es_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (empleado_id) REFERENCES empleados_1fn(id)
);

CREATE TABLE direcciones_empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    calle VARCHAR(100) NOT NULL,
    numero VARCHAR(10),
    colonia VARCHAR(100),
    ciudad VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50) DEFAULT 'México',
    tipo ENUM('domicilio', 'trabajo') DEFAULT 'domicilio',
    FOREIGN KEY (empleado_id) REFERENCES empleados_1fn(id)
);

CREATE TABLE habilidades_empleados (
    empleado_id INT,
    habilidad VARCHAR(100),
    nivel ENUM('básico', 'intermedio', 'avanzado', 'experto') DEFAULT 'básico',
    fecha_certificacion DATE,
    PRIMARY KEY (empleado_id, habilidad),
    FOREIGN KEY (empleado_id) REFERENCES empleados_1fn(id)
);

CREATE TABLE historial_salarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    motivo VARCHAR(200),
    FOREIGN KEY (empleado_id) REFERENCES empleados_1fn(id)
);
```

### Ejercicio 3: Normalizar Sistema de Inventario
**Objetivo**: Aplicar 1FN a sistema de inventario.

```sql
-- ❌ Tabla con violaciones
CREATE TABLE productos_inventario_no_1fn (
    id INT PRIMARY KEY,
    nombre VARCHAR(200),
    categorias VARCHAR(200),     -- "Electrónicos, Hogar, Oficina"
    proveedores VARCHAR(300),    -- "Proveedor A, Proveedor B"
    precios_historial VARCHAR(200), -- "100, 110, 120"
    ubicaciones VARCHAR(200)     -- "Almacén A, Estante 1, Almacén B, Estante 3"
);
```

**Solución normalizada**:
```sql
-- ✅ Tablas normalizadas
CREATE TABLE productos_inventario_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio_actual DECIMAL(10,2) NOT NULL,
    stock_actual INT DEFAULT 0
);

CREATE TABLE categorias_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE productos_categorias (
    producto_id INT,
    categoria_id INT,
    PRIMARY KEY (producto_id, categoria_id),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_1fn(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias_productos(id)
);

CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE productos_proveedores (
    producto_id INT,
    proveedor_id INT,
    precio_proveedor DECIMAL(10,2),
    tiempo_entrega_dias INT,
    PRIMARY KEY (producto_id, proveedor_id),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_1fn(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE historial_precios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    motivo VARCHAR(200),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_1fn(id)
);

CREATE TABLE ubicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('almacen', 'estante', 'seccion') NOT NULL,
    ubicacion_padre_id INT,
    FOREIGN KEY (ubicacion_padre_id) REFERENCES ubicaciones(id)
);

CREATE TABLE productos_ubicaciones (
    producto_id INT,
    ubicacion_id INT,
    cantidad INT NOT NULL DEFAULT 0,
    PRIMARY KEY (producto_id, ubicacion_id),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_1fn(id),
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id)
);
```

### Ejercicio 4: Sistema de Reservas de Hotel
**Objetivo**: Normalizar sistema de reservas.

```sql
-- ❌ Tabla con violaciones
CREATE TABLE reservas_hotel_no_1fn (
    id INT PRIMARY KEY,
    cliente VARCHAR(200),        -- "Juan Pérez García"
    habitaciones VARCHAR(200),   -- "101, 102, 103"
    fechas VARCHAR(100),         -- "2024-01-15, 2024-01-16, 2024-01-17"
    servicios VARCHAR(300),      -- "WiFi, Desayuno, Spa, Gimnasio"
    total DECIMAL(10,2)
);
```

**Solución normalizada**:
```sql
-- ✅ Tablas normalizadas
CREATE TABLE clientes_hotel (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20)
);

CREATE TABLE habitaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(10) NOT NULL UNIQUE,
    tipo ENUM('individual', 'doble', 'suite', 'presidencial') NOT NULL,
    capacidad INT NOT NULL,
    precio_noche DECIMAL(10,2) NOT NULL
);

CREATE TABLE reservas_hotel (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    FOREIGN KEY (cliente_id) REFERENCES clientes_hotel(id)
);

CREATE TABLE detalle_reservas (
    reserva_id INT,
    habitacion_id INT,
    fecha_ocupacion DATE NOT NULL,
    precio_noche DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (reserva_id, habitacion_id, fecha_ocupacion),
    FOREIGN KEY (reserva_id) REFERENCES reservas_hotel(id),
    FOREIGN KEY (habitacion_id) REFERENCES habitaciones(id)
);

CREATE TABLE servicios_hotel (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    tipo ENUM('gratuito', 'pago') DEFAULT 'pago'
);

CREATE TABLE reservas_servicios (
    reserva_id INT,
    servicio_id INT,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (reserva_id, servicio_id),
    FOREIGN KEY (reserva_id) REFERENCES reservas_hotel(id),
    FOREIGN KEY (servicio_id) REFERENCES servicios_hotel(id)
);
```

### Ejercicio 5: Validar 1FN
**Objetivo**: Crear función para validar si una tabla cumple 1FN.

```sql
-- Función para validar 1FN (conceptual)
DELIMITER //
CREATE PROCEDURE validar_primera_forma_normal(
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
    
    -- Verificar si existen columnas con valores múltiples
    -- (Esta es una implementación conceptual)
    
    SELECT 'Validación de 1FN completada' AS resultado;
END//
DELIMITER ;

-- Ejemplo de uso
CALL validar_primera_forma_normal('empleados_1fn');
```

### Ejercicio 6: Migración de Datos
**Objetivo**: Migrar datos de tabla no normalizada a normalizada.

```sql
-- Datos originales (no normalizados)
CREATE TABLE datos_originales (
    id INT PRIMARY KEY,
    informacion TEXT  -- "Juan Pérez, 555-1234, 555-5678, juan@email.com, Calle 123, Col. Centro"
);

INSERT INTO datos_originales VALUES
(1, 'Juan Pérez, 555-1234, 555-5678, juan@email.com, Calle 123, Col. Centro'),
(2, 'María García, 555-9999, maria@email.com, maria@trabajo.com, Av. Reforma 456, Col. Roma');

-- Procedimiento para migrar datos
DELIMITER //
CREATE PROCEDURE migrar_datos_a_1fn()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE registro_id INT;
    DECLARE informacion_completa TEXT;
    DECLARE cur CURSOR FOR SELECT id, informacion FROM datos_originales;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO registro_id, informacion_completa;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Aquí se implementaría la lógica de separación
        -- de datos según las reglas de negocio específicas
        
    END LOOP;
    
    CLOSE cur;
END//
DELIMITER ;
```

### Ejercicio 7: Análisis de Rendimiento
**Objetivo**: Comparar rendimiento antes y después de 1FN.

```sql
-- Consulta en tabla no normalizada (problemática)
-- SELECT * FROM ventas_no_1fn WHERE productos LIKE '%Laptop%';

-- Consulta en tabla normalizada (eficiente)
SELECT v.id, c.nombre, p.nombre as producto, dv.cantidad, dv.precio_unitario
FROM ventas_1fn v
JOIN clientes_1fn c ON v.cliente_id = c.id
JOIN detalle_ventas_1fn dv ON v.id = dv.venta_id
JOIN productos_1fn p ON dv.producto_id = p.id
WHERE p.nombre = 'Laptop';

-- Índices para optimizar consultas normalizadas
CREATE INDEX idx_detalle_ventas_producto ON detalle_ventas_1fn(producto_id);
CREATE INDEX idx_ventas_cliente ON ventas_1fn(cliente_id);
CREATE INDEX idx_productos_nombre ON productos_1fn(nombre);
```

### Ejercicio 8: Caso de Estudio Completo
**Objetivo**: Aplicar 1FN a sistema de gestión de restaurante.

```sql
-- ❌ Tabla con múltiples violaciones
CREATE TABLE restaurante_no_1fn (
    id INT PRIMARY KEY,
    informacion_completa TEXT  -- "Mesa 5, Juan Pérez, 555-1234, Pizza, Pasta, Bebida, 2024-01-15, 18:30, 4 personas"
);

-- ✅ Solución completamente normalizada
CREATE DATABASE restaurante_1fn;
USE restaurante_1fn;

-- Tabla de mesas
CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    ubicacion ENUM('interior', 'exterior', 'terraza') DEFAULT 'interior'
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla de platos
CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(8,2) NOT NULL,
    categoria ENUM('entrada', 'plato_principal', 'postre', 'bebida') NOT NULL
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    mesa_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    numero_personas INT NOT NULL,
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);

-- Tabla de órdenes
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

-- Tabla de detalle de órdenes
CREATE TABLE detalle_ordenes (
    orden_id INT,
    plato_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notas TEXT,
    PRIMARY KEY (orden_id, plato_id),
    FOREIGN KEY (orden_id) REFERENCES ordenes(id),
    FOREIGN KEY (plato_id) REFERENCES platos(id)
);

-- Insertar datos de ejemplo
INSERT INTO mesas (numero, capacidad, ubicacion) VALUES
(1, 4, 'interior'),
(2, 2, 'exterior'),
(3, 6, 'interior'),
(4, 4, 'terraza'),
(5, 8, 'interior');

INSERT INTO clientes (nombre, apellido, telefono, email) VALUES
('Juan', 'Pérez', '555-1234', 'juan.perez@email.com'),
('María', 'García', '555-5678', 'maria.garcia@email.com'),
('Carlos', 'López', '555-9999', 'carlos.lopez@email.com');

INSERT INTO platos (nombre, descripcion, precio, categoria) VALUES
('Pizza Margherita', 'Pizza con tomate, mozzarella y albahaca', 180.00, 'plato_principal'),
('Pasta Carbonara', 'Pasta con crema, huevo y panceta', 160.00, 'plato_principal'),
('Ensalada César', 'Lechuga, crutones, parmesano y aderezo césar', 120.00, 'entrada'),
('Tiramisú', 'Postre italiano con café y mascarpone', 90.00, 'postre'),
('Coca Cola', 'Bebida gaseosa', 25.00, 'bebida');

INSERT INTO reservas (cliente_id, mesa_id, fecha_reserva, hora_reserva, numero_personas) VALUES
(1, 1, '2024-01-15', '18:30:00', 4),
(2, 2, '2024-01-15', '19:00:00', 2),
(3, 3, '2024-01-16', '20:00:00', 6);

INSERT INTO ordenes (reserva_id, mesa_id, total, estado) VALUES
(1, 1, 485.00, 'pagada'),
(2, 2, 205.00, 'servida'),
(3, 3, 720.00, 'preparando');

INSERT INTO detalle_ordenes VALUES
(1, 1, 1, 180.00, 180.00, NULL),  -- Pizza
(1, 2, 1, 160.00, 160.00, NULL),  -- Pasta
(1, 5, 4, 25.00, 100.00, NULL),   -- Bebidas
(1, 4, 1, 90.00, 90.00, NULL),    -- Postre
(2, 3, 1, 120.00, 120.00, NULL),  -- Ensalada
(2, 5, 2, 25.00, 50.00, NULL),    -- Bebidas
(2, 4, 1, 90.00, 90.00, NULL),    -- Postre
(3, 1, 2, 180.00, 360.00, NULL),  -- Pizzas
(3, 2, 2, 160.00, 320.00, NULL),  -- Pastas
(3, 5, 6, 25.00, 150.00, NULL);   -- Bebidas
```

### Ejercicio 9: Beneficios de 1FN
**Objetivo**: Demostrar beneficios de la normalización.

```sql
-- Beneficios demostrados:

-- 1. ELIMINACIÓN DE REDUNDANCIA
-- Antes: Datos duplicados en cada fila
-- Después: Datos únicos en tablas separadas

-- 2. PREVENCIÓN DE ANOMALÍAS
-- Antes: Cambiar "Laptop" requería actualizar múltiples filas
-- Después: Cambiar en tabla productos se refleja automáticamente

-- 3. FACILITAR CONSULTAS
-- Antes: LIKE '%Laptop%' en campo concatenado
-- Después: JOIN directo con tabla productos

-- 4. MEJOR INTEGRIDAD
-- Antes: Sin restricciones de integridad referencial
-- Después: FOREIGN KEY constraints

-- 5. ESCALABILIDAD
-- Antes: Agregar nuevo producto requería modificar estructura
-- Después: Solo insertar en tabla productos
```

### Ejercicio 10: Casos Especiales de 1FN
**Objetivo**: Manejar casos especiales en la normalización.

```sql
-- Caso especial: Datos JSON (MySQL 5.7+)
-- A veces es aceptable usar JSON para datos semi-estructurados
CREATE TABLE productos_json (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    especificaciones JSON,  -- {"color": "rojo", "tamaño": "M", "material": "algodón"}
    tags JSON,              -- ["nuevo", "oferta", "popular"]
    precio DECIMAL(10,2) NOT NULL
);

-- Insertar datos JSON
INSERT INTO productos_json (nombre, especificaciones, tags, precio) VALUES
('Camiseta', '{"color": "rojo", "tamaño": "M", "material": "algodón"}', '["nuevo", "popular"]', 299.00),
('Pantalón', '{"color": "azul", "tamaño": "L", "material": "mezclilla"}', '["oferta"]', 599.00);

-- Consultar datos JSON
SELECT nombre, 
       JSON_EXTRACT(especificaciones, '$.color') as color,
       JSON_EXTRACT(especificaciones, '$.tamaño') as tamaño,
       precio
FROM productos_json
WHERE JSON_CONTAINS(tags, '"nuevo"');
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Normalización**: Proceso de organizar datos para eliminar redundancias
2. **Primera Forma Normal**: Valores atómicos, sin grupos repetitivos
3. **Violaciones de 1FN**: Valores múltiples, atributos compuestos, grupos repetitivos
4. **Proceso de Aplicación**: Identificar, separar, descomponer, eliminar
5. **Beneficios**: Eliminación de redundancia, prevención de anomalías, mejor rendimiento

### Próximos Pasos:
- Aprender Segunda Forma Normal (2FN)
- Estudiar dependencias funcionales
- Practicar con casos más complejos

### Recursos Adicionales:
- Documentación sobre normalización
- Herramientas de análisis de dependencias
- Casos de estudio de normalización
