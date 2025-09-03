# Clase 6: Integridad Referencial

## Objetivos de la Clase
- Comprender la integridad referencial en bases de datos
- Implementar restricciones de integridad
- Manejar violaciones de integridad
- Crear triggers para mantener consistencia

## Contenido Teórico

### 1. ¿Qué es la Integridad Referencial?

**Integridad Referencial** es un mecanismo que garantiza que las relaciones entre tablas se mantengan consistentes, asegurando que las referencias entre claves foráneas y claves primarias sean válidas.

#### Objetivos de la Integridad Referencial:
- **Consistencia de datos**: Evitar referencias inválidas
- **Prevención de orfandad**: Evitar registros huérfanos
- **Mantenimiento automático**: Actualizaciones en cascada
- **Validación de operaciones**: Verificar antes de ejecutar

### 2. Tipos de Integridad Referencial

#### Integridad de Entidad
```sql
-- Garantiza que cada entidad tenga una clave primaria única
CREATE TABLE empleados (
    id INT PRIMARY KEY,  -- Clave primaria única
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE  -- Restricción de unicidad
);
```

#### Integridad de Dominio
```sql
-- Garantiza que los valores estén dentro del dominio permitido
CREATE TABLE productos (
    id INT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) CHECK (precio > 0),  -- Restricción de dominio
    stock INT CHECK (stock >= 0),             -- Restricción de dominio
    categoria ENUM('electrónico', 'hogar', 'deportes')  -- Dominio restringido
);
```

#### Integridad Referencial
```sql
-- Garantiza que las referencias entre tablas sean válidas
CREATE TABLE ventas (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_venta DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)  -- Integridad referencial
);
```

### 3. Restricciones de Integridad Referencial

#### RESTRICT (Restricción)
```sql
-- No permite la operación si existen referencias
CREATE TABLE pedidos_restrict (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

-- Ejemplo de uso:
-- DELETE FROM clientes WHERE id = 1; -- ERROR si hay pedidos
-- UPDATE clientes SET id = 100 WHERE id = 1; -- ERROR si hay pedidos
```

#### CASCADE (Cascada)
```sql
-- Propaga la operación a los registros relacionados
CREATE TABLE pedidos_cascade (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Ejemplo de uso:
-- DELETE FROM clientes WHERE id = 1; -- Elimina cliente y todos sus pedidos
-- UPDATE clientes SET id = 100 WHERE id = 1; -- Actualiza ID en cliente y pedidos
```

#### SET NULL
```sql
-- Establece NULL en la clave foránea
CREATE TABLE pedidos_set_null (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
);

-- Ejemplo de uso:
-- DELETE FROM clientes WHERE id = 1; -- Establece cliente_id = NULL en pedidos
-- UPDATE clientes SET id = 100 WHERE id = 1; -- Actualiza ID en pedidos
```

#### NO ACTION
```sql
-- No hace nada (comportamiento por defecto)
CREATE TABLE pedidos_no_action (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE NO ACTION
);
```

### 4. Violaciones de Integridad Referencial

#### Tipos de Violaciones:

##### Referencias Huérfanas
```sql
-- Registros que referencian claves primarias inexistentes
-- Ejemplo: pedido con cliente_id = 999, pero no existe cliente con id = 999
```

##### Referencias Circulares
```sql
-- Referencias que forman ciclos
-- Ejemplo: A → B → C → A
```

##### Referencias Inconsistentes
```sql
-- Referencias que no siguen las reglas de negocio
-- Ejemplo: empleado con departamento_id = NULL cuando debería ser obligatorio
```

### 5. Triggers para Integridad Referencial

#### Triggers de Validación
```sql
-- Validar antes de insertar
DELIMITER //
CREATE TRIGGER validar_cliente_antes_insertar
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
    IF NEW.cliente_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = NEW.cliente_id) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cliente no existe';
        END IF;
    END IF;
END//
DELIMITER ;
```

#### Triggers de Mantenimiento
```sql
-- Mantener consistencia después de operaciones
DELIMITER //
CREATE TRIGGER actualizar_total_despues_insertar
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total = (
        SELECT SUM(subtotal)
        FROM detalle_pedidos
        WHERE pedido_id = NEW.pedido_id
    )
    WHERE id = NEW.pedido_id;
END//
DELIMITER ;
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca

#### Estructura con Integridad Referencial:
```sql
-- Crear base de datos
CREATE DATABASE biblioteca_integridad;
USE biblioteca_integridad;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    autor VARCHAR(200),
    año_publicacion YEAR,
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla de préstamos con integridad referencial
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    
    -- Restricciones de integridad referencial
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE RESTRICT,
    
    -- Restricciones de dominio
    CONSTRAINT chk_fecha_devolucion CHECK (fecha_devolucion_esperada > fecha_prestamo),
    CONSTRAINT chk_fecha_devolucion_real CHECK (fecha_devolucion_real IS NULL OR fecha_devolucion_real >= fecha_prestamo)
);
```

### Ejemplo 2: Sistema de Ventas

#### Integridad Referencial Compleja:
```sql
-- Crear base de datos
CREATE DATABASE ventas_integridad;
USE ventas_integridad;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria_id INT,
    activo BOOLEAN DEFAULT TRUE,
    
    -- Restricciones de integridad
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    CONSTRAINT chk_precio_positivo CHECK (precio > 0),
    CONSTRAINT chk_stock_no_negativo CHECK (stock >= 0)
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    
    -- Restricciones de integridad
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    CONSTRAINT chk_total_positivo CHECK (total >= 0)
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (venta_id, producto_id),
    
    -- Restricciones de integridad referencial
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    
    -- Restricciones de dominio
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unitario_positivo CHECK (precio_unitario > 0),
    CONSTRAINT chk_subtotal_positivo CHECK (subtotal > 0)
);
```

## Ejercicios Prácticos

### Ejercicio 1: Implementar Integridad Referencial Básica
**Objetivo**: Crear sistema con restricciones básicas de integridad.

```sql
-- Crear sistema con integridad referencial básica
CREATE DATABASE sistema_integridad_basica;
USE sistema_integridad_basica;

-- Tabla de departamentos
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    presupuesto DECIMAL(12,2),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salario DECIMAL(10,2),
    departamento_id INT,
    activo BOOLEAN DEFAULT TRUE,
    
    -- Restricciones de integridad referencial
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL,
    
    -- Restricciones de dominio
    CONSTRAINT chk_salario_positivo CHECK (salario > 0),
    CONSTRAINT chk_email_valido CHECK (email LIKE '%@%.%')
);

-- Tabla de proyectos
CREATE TABLE proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    presupuesto DECIMAL(12,2),
    departamento_id INT,
    estado ENUM('planificado', 'en_progreso', 'completado', 'cancelado') DEFAULT 'planificado',
    
    -- Restricciones de integridad
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE RESTRICT,
    
    -- Restricciones de dominio
    CONSTRAINT chk_fecha_fin_posterior CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT chk_presupuesto_positivo CHECK (presupuesto > 0)
);

-- Insertar datos de ejemplo
INSERT INTO departamentos (nombre, presupuesto) VALUES
('Ventas', 100000.00),
('Marketing', 75000.00),
('IT', 150000.00);

INSERT INTO empleados (nombre, apellido, email, salario, departamento_id) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', 45000.00, 1),
('María', 'García', 'maria.garcia@empresa.com', 50000.00, 1),
('Carlos', 'López', 'carlos.lopez@empresa.com', 60000.00, 3);

INSERT INTO proyectos (nombre, descripcion, fecha_inicio, fecha_fin, presupuesto, departamento_id) VALUES
('Proyecto Web', 'Desarrollo de sitio web corporativo', '2024-01-01', '2024-06-30', 50000.00, 3),
('Campaña Digital', 'Campaña de marketing digital', '2024-02-01', '2024-05-31', 25000.00, 2);
```

### Ejercicio 2: Crear Triggers de Validación
**Objetivo**: Implementar triggers para validar integridad.

```sql
-- Trigger para validar empleado antes de insertar proyecto
DELIMITER //
CREATE TRIGGER validar_departamento_antes_insertar_proyecto
BEFORE INSERT ON proyectos
FOR EACH ROW
BEGIN
    IF NEW.departamento_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM departamentos WHERE id = NEW.departamento_id AND activo = TRUE) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Departamento no existe o está inactivo';
        END IF;
    END IF;
END//
DELIMITER ;

-- Trigger para validar empleado antes de insertar
DELIMITER //
CREATE TRIGGER validar_departamento_antes_insertar_empleado
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
    IF NEW.departamento_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM departamentos WHERE id = NEW.departamento_id AND activo = TRUE) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Departamento no existe o está inactivo';
        END IF;
    END IF;
END//
DELIMITER ;

-- Trigger para validar antes de actualizar
DELIMITER //
CREATE TRIGGER validar_departamento_antes_actualizar_empleado
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN
    IF NEW.departamento_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM departamentos WHERE id = NEW.departamento_id AND activo = TRUE) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Departamento no existe o está inactivo';
        END IF;
    END IF;
END//
DELIMITER ;
```

### Ejercicio 3: Implementar Restricciones de Cascada
**Objetivo**: Crear sistema con diferentes tipos de cascada.

```sql
-- Crear sistema con cascada
CREATE DATABASE sistema_cascada;
USE sistema_cascada;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de pedidos con CASCADE
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado') DEFAULT 'pendiente',
    
    -- CASCADE: Al eliminar cliente, se eliminan pedidos
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de detalle de pedidos con CASCADE
CREATE TABLE detalle_pedidos (
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (pedido_id, producto_id),
    
    -- CASCADE: Al eliminar pedido, se eliminan detalles
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    -- RESTRICT: No permite eliminar producto si está en pedidos
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de productos con SET NULL
CREATE TABLE productos_categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    categoria_id INT,
    precio DECIMAL(10,2) NOT NULL,
    
    -- SET NULL: Al eliminar categoría, se establece NULL
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL
);
```

### Ejercicio 4: Validar Integridad Referencial
**Objetivo**: Crear procedimiento para validar integridad.

```sql
-- Procedimiento para validar integridad referencial
DELIMITER //
CREATE PROCEDURE validar_integridad_referencial()
BEGIN
    DECLARE violaciones INT DEFAULT 0;
    
    -- Verificar pedidos sin cliente válido
    SELECT COUNT(*) INTO @pedidos_sin_cliente
    FROM pedidos p
    LEFT JOIN clientes c ON p.cliente_id = c.id
    WHERE c.id IS NULL;
    
    IF @pedidos_sin_cliente > 0 THEN
        SELECT CONCAT('Violación: ', @pedidos_sin_cliente, ' pedidos sin cliente válido') AS error;
        SET violaciones = violaciones + 1;
    END IF;
    
    -- Verificar detalles sin pedido válido
    SELECT COUNT(*) INTO @detalles_sin_pedido
    FROM detalle_pedidos dp
    LEFT JOIN pedidos p ON dp.pedido_id = p.id
    WHERE p.id IS NULL;
    
    IF @detalles_sin_pedido > 0 THEN
        SELECT CONCAT('Violación: ', @detalles_sin_pedido, ' detalles sin pedido válido') AS error;
        SET violaciones = violaciones + 1;
    END IF;
    
    -- Verificar detalles sin producto válido
    SELECT COUNT(*) INTO @detalles_sin_producto
    FROM detalle_pedidos dp
    LEFT JOIN productos p ON dp.producto_id = p.id
    WHERE p.id IS NULL;
    
    IF @detalles_sin_producto > 0 THEN
        SELECT CONCAT('Violación: ', @detalles_sin_producto, ' detalles sin producto válido') AS error;
        SET violaciones = violaciones + 1;
    END IF;
    
    -- Verificar productos con categoría inválida
    SELECT COUNT(*) INTO @productos_categoria_invalida
    FROM productos_categorias pc
    LEFT JOIN categorias c ON pc.categoria_id = c.id
    WHERE pc.categoria_id IS NOT NULL AND c.id IS NULL;
    
    IF @productos_categoria_invalida > 0 THEN
        SELECT CONCAT('Violación: ', @productos_categoria_invalida, ' productos con categoría inválida') AS error;
        SET violaciones = violaciones + 1;
    END IF;
    
    -- Resumen
    IF violaciones = 0 THEN
        SELECT 'Integridad referencial: OK' AS resultado;
    ELSE
        SELECT CONCAT('Integridad referencial: ', violaciones, ' violaciones encontradas') AS resultado;
    END IF;
END//
DELIMITER ;

-- Ejecutar validación
CALL validar_integridad_referencial();
```

### Ejercicio 5: Manejar Violaciones de Integridad
**Objetivo**: Crear sistema para manejar violaciones.

```sql
-- Crear tabla de auditoría para violaciones
CREATE TABLE auditoria_integridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_origen VARCHAR(100),
    operacion ENUM('INSERT', 'UPDATE', 'DELETE'),
    registro_id INT,
    mensaje_error TEXT,
    fecha_violacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100)
);

-- Trigger para registrar violaciones
DELIMITER //
CREATE TRIGGER registrar_violacion_integridad
AFTER INSERT ON auditoria_integridad
FOR EACH ROW
BEGIN
    -- Log de violación (implementación simplificada)
    INSERT INTO auditoria_integridad (tabla_origen, operacion, mensaje_error)
    VALUES ('sistema', 'AUDIT', 'Violación de integridad detectada');
END//
DELIMITER ;

-- Procedimiento para limpiar violaciones
DELIMITER //
CREATE PROCEDURE limpiar_violaciones_integridad()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE pedido_id INT;
    DECLARE cur CURSOR FOR 
        SELECT p.id
        FROM pedidos p
        LEFT JOIN clientes c ON p.cliente_id = c.id
        WHERE c.id IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Limpiar pedidos huérfanos
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO pedido_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Eliminar pedido huérfano
        DELETE FROM pedidos WHERE id = pedido_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria_integridad (tabla_origen, operacion, registro_id, mensaje_error)
        VALUES ('pedidos', 'DELETE', pedido_id, 'Pedido huérfano eliminado');
        
    END LOOP;
    CLOSE cur;
    
    SELECT 'Limpieza de violaciones completada' AS resultado;
END//
DELIMITER ;
```

### Ejercicio 6: Sistema de Reservas con Integridad
**Objetivo**: Crear sistema de reservas con integridad referencial.

```sql
-- Crear sistema de reservas
CREATE DATABASE sistema_reservas;
USE sistema_reservas;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de servicios
CREATE TABLE servicios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    duracion_minutos INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    servicio_id INT NOT NULL,
    empleado_id INT,
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    duracion_minutos INT NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    notas TEXT,
    
    -- Restricciones de integridad referencial
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id) ON DELETE RESTRICT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE SET NULL,
    
    -- Restricciones de dominio
    CONSTRAINT chk_fecha_futura CHECK (fecha_reserva >= CURDATE()),
    CONSTRAINT chk_precio_positivo CHECK (precio_total > 0),
    CONSTRAINT chk_duracion_positiva CHECK (duracion_minutos > 0)
);

-- Trigger para validar disponibilidad
DELIMITER //
CREATE TRIGGER validar_disponibilidad_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE conflicto INT DEFAULT 0;
    
    -- Verificar si hay conflicto de horario
    SELECT COUNT(*) INTO conflicto
    FROM reservas
    WHERE empleado_id = NEW.empleado_id
    AND fecha_reserva = NEW.fecha_reserva
    AND estado = 'confirmada'
    AND (
        (NEW.hora_reserva BETWEEN hora_reserva AND ADDTIME(hora_reserva, SEC_TO_TIME(duracion_minutos * 60)))
        OR
        (ADDTIME(NEW.hora_reserva, SEC_TO_TIME(NEW.duracion_minutos * 60)) BETWEEN hora_reserva AND ADDTIME(hora_reserva, SEC_TO_TIME(duracion_minutos * 60)))
    );
    
    IF conflicto > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Conflicto de horario con otra reserva';
    END IF;
END//
DELIMITER ;
```

### Ejercicio 7: Integridad Referencial Avanzada
**Objetivo**: Implementar integridad referencial compleja.

```sql
-- Crear sistema con integridad referencial avanzada
CREATE DATABASE sistema_avanzado;
USE sistema_avanzado;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de roles
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de permisos
CREATE TABLE permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    modulo VARCHAR(50) NOT NULL
);

-- Tabla de usuarios_roles (N:N)
CREATE TABLE usuarios_roles (
    usuario_id INT,
    rol_id INT,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    
    PRIMARY KEY (usuario_id, rol_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Tabla de roles_permisos (N:N)
CREATE TABLE roles_permisos (
    rol_id INT,
    permiso_id INT,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE
);

-- Tabla de sesiones
CREATE TABLE sesiones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Trigger para limpiar sesiones expiradas
DELIMITER //
CREATE TRIGGER limpiar_sesiones_expiradas
BEFORE INSERT ON sesiones
FOR EACH ROW
BEGIN
    -- Eliminar sesiones expiradas del mismo usuario
    DELETE FROM sesiones 
    WHERE usuario_id = NEW.usuario_id 
    AND fecha_expiracion < NOW();
END//
DELIMITER ;
```

### Ejercicio 8: Caso de Estudio Completo
**Objetivo**: Crear sistema completo de gestión de inventario.

```sql
-- Crear sistema completo de inventario
CREATE DATABASE inventario_completo;
USE inventario_completo;

-- Tabla de proveedores
CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT,
    proveedor_id INT,
    precio_compra DECIMAL(10,2),
    precio_venta DECIMAL(10,2),
    stock_minimo INT DEFAULT 0,
    stock_actual INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE SET NULL,
    
    CONSTRAINT chk_precio_compra_positivo CHECK (precio_compra > 0),
    CONSTRAINT chk_precio_venta_positivo CHECK (precio_venta > 0),
    CONSTRAINT chk_stock_minimo_no_negativo CHECK (stock_minimo >= 0),
    CONSTRAINT chk_stock_actual_no_negativo CHECK (stock_actual >= 0)
);

-- Tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste', 'transferencia') NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2),
    motivo VARCHAR(200),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable VARCHAR(100),
    
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    
    CONSTRAINT chk_cantidad_no_cero CHECK (cantidad != 0),
    CONSTRAINT chk_precio_unitario_positivo CHECK (precio_unitario > 0)
);

-- Trigger para actualizar stock
DELIMITER //
CREATE TRIGGER actualizar_stock_despues_movimiento
AFTER INSERT ON movimientos_inventario
FOR EACH ROW
BEGIN
    DECLARE nuevo_stock INT;
    
    -- Calcular nuevo stock
    IF NEW.tipo_movimiento IN ('entrada', 'ajuste') THEN
        SET nuevo_stock = (SELECT stock_actual FROM productos WHERE id = NEW.producto_id) + NEW.cantidad;
    ELSE
        SET nuevo_stock = (SELECT stock_actual FROM productos WHERE id = NEW.producto_id) - NEW.cantidad;
    END IF;
    
    -- Actualizar stock
    UPDATE productos 
    SET stock_actual = nuevo_stock 
    WHERE id = NEW.producto_id;
    
    -- Verificar stock mínimo
    IF nuevo_stock <= (SELECT stock_minimo FROM productos WHERE id = NEW.producto_id) THEN
        INSERT INTO alertas_stock (producto_id, mensaje, fecha_alerta)
        VALUES (NEW.producto_id, 'Stock por debajo del mínimo', NOW());
    END IF;
END//
DELIMITER ;

-- Tabla de alertas de stock
CREATE TABLE alertas_stock (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    mensaje TEXT,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
);
```

### Ejercicio 9: Validación de Integridad Completa
**Objetivo**: Crear sistema de validación completo.

```sql
-- Procedimiento para validación completa de integridad
DELIMITER //
CREATE PROCEDURE validacion_completa_integridad()
BEGIN
    DECLARE total_violaciones INT DEFAULT 0;
    
    -- Crear tabla temporal para resultados
    CREATE TEMPORARY TABLE IF NOT EXISTS resultados_validacion (
        tipo_violacion VARCHAR(100),
        cantidad INT,
        detalles TEXT
    );
    
    -- 1. Verificar productos con categoría inválida
    INSERT INTO resultados_validacion
    SELECT 
        'Categoría inválida',
        COUNT(*),
        GROUP_CONCAT(p.id SEPARATOR ', ')
    FROM productos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE p.categoria_id IS NOT NULL AND c.id IS NULL;
    
    -- 2. Verificar productos con proveedor inválido
    INSERT INTO resultados_validacion
    SELECT 
        'Proveedor inválido',
        COUNT(*),
        GROUP_CONCAT(p.id SEPARATOR ', ')
    FROM productos p
    LEFT JOIN proveedores pr ON p.proveedor_id = pr.id
    WHERE p.proveedor_id IS NOT NULL AND pr.id IS NULL;
    
    -- 3. Verificar movimientos con producto inválido
    INSERT INTO resultados_validacion
    SELECT 
        'Movimiento con producto inválido',
        COUNT(*),
        GROUP_CONCAT(m.id SEPARATOR ', ')
    FROM movimientos_inventario m
    LEFT JOIN productos p ON m.producto_id = p.id
    WHERE p.id IS NULL;
    
    -- 4. Verificar stock negativo
    INSERT INTO resultados_validacion
    SELECT 
        'Stock negativo',
        COUNT(*),
        GROUP_CONCAT(id SEPARATOR ', ')
    FROM productos
    WHERE stock_actual < 0;
    
    -- 5. Verificar precios inconsistentes
    INSERT INTO resultados_validacion
    SELECT 
        'Precio de venta menor que compra',
        COUNT(*),
        GROUP_CONCAT(id SEPARATOR ', ')
    FROM productos
    WHERE precio_venta < precio_compra;
    
    -- Mostrar resultados
    SELECT * FROM resultados_validacion;
    
    -- Contar total de violaciones
    SELECT SUM(cantidad) INTO total_violaciones FROM resultados_validacion;
    
    -- Resumen
    IF total_violaciones = 0 THEN
        SELECT '✅ Integridad referencial: PERFECTA' AS resultado;
    ELSE
        SELECT CONCAT('❌ Integridad referencial: ', total_violaciones, ' violaciones encontradas') AS resultado;
    END IF;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE resultados_validacion;
END//
DELIMITER ;

-- Ejecutar validación
CALL validacion_completa_integridad();
```

### Ejercicio 10: Sistema de Monitoreo de Integridad
**Objetivo**: Crear sistema de monitoreo automático.

```sql
-- Crear sistema de monitoreo
CREATE TABLE monitoreo_integridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_verificacion VARCHAR(100),
    resultado ENUM('OK', 'ERROR', 'ADVERTENCIA'),
    mensaje TEXT,
    detalles JSON
);

-- Procedimiento para monitoreo automático
DELIMITER //
CREATE PROCEDURE monitoreo_automatico_integridad()
BEGIN
    DECLARE violaciones_categoria INT DEFAULT 0;
    DECLARE violaciones_proveedor INT DEFAULT 0;
    DECLARE stock_negativo INT DEFAULT 0;
    DECLARE precios_inconsistentes INT DEFAULT 0;
    
    -- Verificar categorías inválidas
    SELECT COUNT(*) INTO violaciones_categoria
    FROM productos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE p.categoria_id IS NOT NULL AND c.id IS NULL;
    
    -- Verificar proveedores inválidos
    SELECT COUNT(*) INTO violaciones_proveedor
    FROM productos p
    LEFT JOIN proveedores pr ON p.proveedor_id = pr.id
    WHERE p.proveedor_id IS NOT NULL AND pr.id IS NULL;
    
    -- Verificar stock negativo
    SELECT COUNT(*) INTO stock_negativo
    FROM productos
    WHERE stock_actual < 0;
    
    -- Verificar precios inconsistentes
    SELECT COUNT(*) INTO precios_inconsistentes
    FROM productos
    WHERE precio_venta < precio_compra;
    
    -- Registrar resultados
    INSERT INTO monitoreo_integridad (tipo_verificacion, resultado, mensaje, detalles)
    VALUES (
        'Verificación completa',
        CASE 
            WHEN (violaciones_categoria + violaciones_proveedor + stock_negativo + precios_inconsistentes) = 0 
            THEN 'OK' 
            ELSE 'ERROR' 
        END,
        CONCAT('Violaciones: Categorías=', violaciones_categoria, 
               ', Proveedores=', violaciones_proveedor,
               ', Stock negativo=', stock_negativo,
               ', Precios inconsistentes=', precios_inconsistentes),
        JSON_OBJECT(
            'categorias_invalidas', violaciones_categoria,
            'proveedores_invalidos', violaciones_proveedor,
            'stock_negativo', stock_negativo,
            'precios_inconsistentes', precios_inconsistentes
        )
    );
    
    -- Mostrar resumen
    SELECT 
        fecha_verificacion,
        resultado,
        mensaje
    FROM monitoreo_integridad
    ORDER BY fecha_verificacion DESC
    LIMIT 1;
END//
DELIMITER ;

-- Crear evento para monitoreo automático (ejecutar cada hora)
CREATE EVENT monitoreo_horario_integridad
ON SCHEDULE EVERY 1 HOUR
DO
  CALL monitoreo_automatico_integridad();

-- Habilitar el scheduler de eventos
SET GLOBAL event_scheduler = ON;
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Integridad Referencial**: Consistencia entre tablas relacionadas
2. **Restricciones**: RESTRICT, CASCADE, SET NULL, NO ACTION
3. **Violaciones**: Referencias huérfanas, circulares, inconsistentes
4. **Triggers**: Validación y mantenimiento automático
5. **Monitoreo**: Verificación continua de integridad

### Próximos Pasos:
- Aprender índices y rendimiento
- Estudiar diseño de esquemas escalables
- Practicar con casos complejos de integridad

### Recursos Adicionales:
- Documentación sobre integridad referencial
- Herramientas de validación de integridad
- Casos de estudio de empresas reales
