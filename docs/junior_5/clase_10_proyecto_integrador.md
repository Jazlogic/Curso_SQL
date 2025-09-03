# Clase 10: Proyecto Integrador - Sistema Multi-SGBD

## Objetivos de la Clase
- Integrar todos los conocimientos del módulo en un proyecto práctico
- Implementar un sistema que funcione con múltiples SGBD
- Aplicar mejores prácticas de administración
- Realizar migración entre diferentes sistemas
- Crear un sistema de monitoreo y administración

## Descripción del Proyecto

**Sistema Multi-SGBD de Gestión Empresarial** es un proyecto integral que demuestra la capacidad de trabajar con múltiples sistemas de gestión de bases de datos, implementando un sistema de gestión empresarial que puede funcionar con MySQL, PostgreSQL, SQL Server y Oracle Database.

### Características del Sistema:
- **Multiplataforma**: Compatible con 4 SGBD principales
- **Gestión Empresarial**: Módulos de usuarios, productos, ventas, inventario
- **Migración**: Capacidad de migrar entre SGBD
- **Monitoreo**: Sistema de monitoreo y alertas
- **Administración**: Herramientas de administración integradas

## Arquitectura del Sistema

### 1. Estructura de Módulos

```sql
-- Crear base de datos principal del proyecto
CREATE DATABASE sistema_multi_sgbd;
USE sistema_multi_sgbd;

-- Tabla de configuración del sistema
CREATE TABLE configuracion_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sgbd_activo ENUM('MySQL', 'PostgreSQL', 'SQL Server', 'Oracle') NOT NULL,
    version_sgbd VARCHAR(50),
    configuracion JSON,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración inicial
INSERT INTO configuracion_sistema (sgbd_activo, version_sgbd, configuracion) VALUES
('MySQL', '8.0.35', '{"host": "localhost", "port": 3306, "charset": "utf8mb4"}');
```

### 2. Módulo de Usuarios

```sql
-- Crear tabla de usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol ENUM('ADMIN', 'GERENTE', 'EMPLEADO', 'CLIENTE') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_rol (rol)
);

-- Crear tabla de sesiones
CREATE TABLE sesiones_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    token_sesion VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_token (token_sesion),
    INDEX idx_usuario (usuario_id)
);
```

### 3. Módulo de Productos

```sql
-- Crear tabla de categorías
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_padre_id INT NULL,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_padre_id) REFERENCES categorias(id),
    INDEX idx_nombre (nombre),
    INDEX idx_categoria_padre (categoria_padre_id)
);

-- Crear tabla de productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    INDEX idx_codigo (codigo),
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria_id),
    INDEX idx_precio (precio),
    CONSTRAINT chk_precio_positivo CHECK (precio > 0),
    CONSTRAINT chk_costo_positivo CHECK (costo > 0)
);
```

### 4. Módulo de Ventas

```sql
-- Crear tabla de clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cliente VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_codigo (codigo_cliente),
    INDEX idx_nombre (nombre, apellido),
    INDEX idx_email (email)
);

-- Crear tabla de ventas
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_venta VARCHAR(50) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    impuestos DECIMAL(10,2) DEFAULT 0,
    descuento DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'ENVIADA', 'ENTREGADA', 'CANCELADA') DEFAULT 'PENDIENTE',
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES usuarios(id),
    INDEX idx_numero_venta (numero_venta),
    INDEX idx_cliente (cliente_id),
    INDEX idx_vendedor (vendedor_id),
    INDEX idx_fecha (fecha_venta),
    INDEX idx_estado (estado),
    CONSTRAINT chk_total_positivo CHECK (total >= 0)
);

-- Crear tabla de detalles de venta
CREATE TABLE detalles_venta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    INDEX idx_venta (venta_id),
    INDEX idx_producto (producto_id),
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unitario_positivo CHECK (precio_unitario > 0)
);
```

### 5. Módulo de Inventario

```sql
-- Crear tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE') NOT NULL,
    cantidad INT NOT NULL,
    motivo VARCHAR(200),
    referencia VARCHAR(100),
    usuario_id INT NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_producto (producto_id),
    INDEX idx_tipo (tipo_movimiento),
    INDEX idx_fecha (fecha_movimiento),
    INDEX idx_usuario (usuario_id)
);

-- Crear tabla de stock histórico
CREATE TABLE stock_historico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    diferencia INT NOT NULL,
    tipo_operacion VARCHAR(100),
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    INDEX idx_producto (producto_id),
    INDEX idx_fecha (fecha_operacion)
);
```

## Sistema de Monitoreo

### 1. Métricas del Sistema

```sql
-- Crear tabla de métricas
CREATE TABLE metricas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(15,4),
    unidad VARCHAR(20),
    categoria VARCHAR(50),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_metrica (metrica),
    INDEX idx_categoria (categoria),
    INDEX idx_fecha (fecha_medicion)
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE recopilar_metricas_sistema()
BEGIN
    -- Métricas de usuarios
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'usuarios_activos', COUNT(*), 'usuarios', 'USUARIOS'
    FROM usuarios WHERE activo = TRUE;
    
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'sesiones_activas', COUNT(*), 'sesiones', 'USUARIOS'
    FROM sesiones_usuario WHERE activa = TRUE;
    
    -- Métricas de productos
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'productos_activos', COUNT(*), 'productos', 'PRODUCTOS'
    FROM productos WHERE activo = TRUE;
    
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'productos_bajo_stock', COUNT(*), 'productos', 'INVENTARIO'
    FROM productos WHERE stock_actual <= stock_minimo;
    
    -- Métricas de ventas
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'ventas_hoy', COUNT(*), 'ventas', 'VENTAS'
    FROM ventas WHERE DATE(fecha_venta) = CURDATE();
    
    INSERT INTO metricas_sistema (metrica, valor, unidad, categoria)
    SELECT 'total_ventas_hoy', COALESCE(SUM(total), 0), 'moneda', 'VENTAS'
    FROM ventas WHERE DATE(fecha_venta) = CURDATE();
END //
DELIMITER ;
```

### 2. Sistema de Alertas

```sql
-- Crear tabla de alertas
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    datos_adicionales JSON,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP NULL,
    resuelta_por VARCHAR(100),
    INDEX idx_tipo (tipo_alerta),
    INDEX idx_severidad (severidad),
    INDEX idx_fecha (fecha_alerta),
    INDEX idx_resuelta (resuelta)
);

-- Procedimiento para verificar alertas
DELIMITER //
CREATE PROCEDURE verificar_alertas_sistema()
BEGIN
    DECLARE v_productos_bajo_stock INT;
    DECLARE v_ventas_pendientes INT;
    DECLARE v_usuarios_inactivos INT;
    
    -- Verificar productos bajo stock
    SELECT COUNT(*) INTO v_productos_bajo_stock
    FROM productos 
    WHERE stock_actual <= stock_minimo AND activo = TRUE;
    
    IF v_productos_bajo_stock > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, severidad, titulo, mensaje, datos_adicionales)
        VALUES ('STOCK_BAJO', 'ALTA', 'Productos con stock bajo', 
                CONCAT('Hay ', v_productos_bajo_stock, ' productos con stock por debajo del mínimo'),
                JSON_OBJECT('cantidad', v_productos_bajo_stock));
    END IF;
    
    -- Verificar ventas pendientes por más de 24 horas
    SELECT COUNT(*) INTO v_ventas_pendientes
    FROM ventas 
    WHERE estado = 'PENDIENTE' AND fecha_venta < DATE_SUB(NOW(), INTERVAL 24 HOUR);
    
    IF v_ventas_pendientes > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, severidad, titulo, mensaje, datos_adicionales)
        VALUES ('VENTAS_PENDIENTES', 'MEDIA', 'Ventas pendientes por más de 24 horas',
                CONCAT('Hay ', v_ventas_pendientes, ' ventas pendientes por más de 24 horas'),
                JSON_OBJECT('cantidad', v_ventas_pendientes));
    END IF;
    
    -- Verificar usuarios inactivos por más de 30 días
    SELECT COUNT(*) INTO v_usuarios_inactivos
    FROM usuarios 
    WHERE activo = TRUE AND ultimo_acceso < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    IF v_usuarios_inactivos > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, severidad, titulo, mensaje, datos_adicionales)
        VALUES ('USUARIOS_INACTIVOS', 'BAJA', 'Usuarios inactivos',
                CONCAT('Hay ', v_usuarios_inactivos, ' usuarios inactivos por más de 30 días'),
                JSON_OBJECT('cantidad', v_usuarios_inactivos));
    END IF;
END //
DELIMITER ;
```

## Sistema de Migración

### 1. Configuración Multi-SGBD

```sql
-- Crear tabla de configuraciones por SGBD
CREATE TABLE configuraciones_sgbd (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sgbd VARCHAR(50) NOT NULL,
    version VARCHAR(50),
    host VARCHAR(100),
    puerto INT,
    base_datos VARCHAR(100),
    usuario VARCHAR(100),
    configuracion_especial JSON,
    activo BOOLEAN DEFAULT FALSE,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sgbd (sgbd),
    INDEX idx_activo (activo)
);

-- Insertar configuraciones
INSERT INTO configuraciones_sgbd (sgbd, version, host, puerto, base_datos, usuario, activo) VALUES
('MySQL', '8.0.35', 'localhost', 3306, 'sistema_multi_sgbd', 'root', TRUE),
('PostgreSQL', '15.0', 'localhost', 5432, 'sistema_multi_sgbd', 'postgres', FALSE),
('SQL Server', '2022', 'localhost', 1433, 'sistema_multi_sgbd', 'sa', FALSE),
('Oracle', '19c', 'localhost', 1521, 'ORCL', 'system', FALSE);
```

### 2. Scripts de Migración

```sql
-- Crear tabla de scripts de migración
CREATE TABLE scripts_migracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sgbd_origen VARCHAR(50) NOT NULL,
    sgbd_destino VARCHAR(50) NOT NULL,
    tipo_script ENUM('SCHEMA', 'DATA', 'INDEXES', 'CONSTRAINTS', 'FUNCTIONS') NOT NULL,
    nombre_script VARCHAR(200) NOT NULL,
    contenido_script TEXT NOT NULL,
    orden_ejecucion INT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sgbd (sgbd_origen, sgbd_destino),
    INDEX idx_tipo (tipo_script)
);

-- Procedimiento para generar scripts de migración
DELIMITER //
CREATE PROCEDURE generar_script_migracion(
    IN p_sgbd_origen VARCHAR(50),
    IN p_sgbd_destino VARCHAR(50),
    IN p_tipo_script ENUM('SCHEMA', 'DATA', 'INDEXES', 'CONSTRAINTS', 'FUNCTIONS')
)
BEGIN
    DECLARE v_script TEXT DEFAULT '';
    
    CASE p_tipo_script
        WHEN 'SCHEMA' THEN
            -- Generar script de esquema
            SET v_script = CONCAT(
                '-- Script de migración de esquema de ', p_sgbd_origen, ' a ', p_sgbd_destino, '\n',
                '-- Generado automáticamente el ', NOW(), '\n\n'
            );
            
            -- Agregar conversiones específicas según SGBD destino
            CASE p_sgbd_destino
                WHEN 'PostgreSQL' THEN
                    SET v_script = CONCAT(v_script, 
                        '-- Conversiones específicas para PostgreSQL\n',
                        '-- AUTO_INCREMENT -> SERIAL\n',
                        '-- DATETIME -> TIMESTAMP\n',
                        '-- ENUM -> CHECK constraints\n\n'
                    );
                WHEN 'SQL Server' THEN
                    SET v_script = CONCAT(v_script,
                        '-- Conversiones específicas para SQL Server\n',
                        '-- AUTO_INCREMENT -> IDENTITY(1,1)\n',
                        '-- DATETIME -> DATETIME2\n',
                        '-- ENUM -> CHECK constraints\n\n'
                    );
            END CASE;
            
        WHEN 'DATA' THEN
            SET v_script = CONCAT(
                '-- Script de migración de datos de ', p_sgbd_origen, ' a ', p_sgbd_destino, '\n',
                '-- Generado automáticamente el ', NOW(), '\n\n'
            );
    END CASE;
    
    -- Insertar script generado
    INSERT INTO scripts_migracion (sgbd_origen, sgbd_destino, tipo_script, nombre_script, contenido_script)
    VALUES (p_sgbd_origen, p_sgbd_destino, p_tipo_script, 
            CONCAT('migracion_', p_tipo_script, '_', p_sgbd_origen, '_to_', p_sgbd_destino), 
            v_script);
    
    SELECT LAST_INSERT_ID() as script_id;
END //
DELIMITER ;
```

## Dashboard de Administración

### 1. Vista de Dashboard

```sql
-- Crear vista de dashboard
CREATE VIEW dashboard_administracion AS
SELECT 
    'Usuarios Activos' as metrica,
    (SELECT COUNT(*) FROM usuarios WHERE activo = TRUE) as valor_actual,
    'usuarios' as unidad,
    CASE 
        WHEN (SELECT COUNT(*) FROM usuarios WHERE activo = TRUE) > 100 THEN 'ALTO'
        WHEN (SELECT COUNT(*) FROM usuarios WHERE activo = TRUE) > 50 THEN 'MEDIO'
        ELSE 'BAJO'
    END as estado
UNION ALL
SELECT 
    'Productos Activos',
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE),
    'productos',
    CASE 
        WHEN (SELECT COUNT(*) FROM productos WHERE activo = TRUE) > 1000 THEN 'ALTO'
        WHEN (SELECT COUNT(*) FROM productos WHERE activo = TRUE) > 500 THEN 'MEDIO'
        ELSE 'BAJO'
    END
UNION ALL
SELECT 
    'Ventas Hoy',
    (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()),
    'ventas',
    CASE 
        WHEN (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) > 50 THEN 'ALTO'
        WHEN (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) > 20 THEN 'MEDIO'
        ELSE 'BAJO'
    END
UNION ALL
SELECT 
    'Productos Bajo Stock',
    (SELECT COUNT(*) FROM productos WHERE stock_actual <= stock_minimo AND activo = TRUE),
    'productos',
    CASE 
        WHEN (SELECT COUNT(*) FROM productos WHERE stock_actual <= stock_minimo AND activo = TRUE) > 10 THEN 'ALTO'
        WHEN (SELECT COUNT(*) FROM productos WHERE stock_actual <= stock_minimo AND activo = TRUE) > 5 THEN 'MEDIO'
        ELSE 'BAJO'
    END
UNION ALL
SELECT 
    'Alertas Pendientes',
    (SELECT COUNT(*) FROM alertas_sistema WHERE resuelta = FALSE),
    'alertas',
    CASE 
        WHEN (SELECT COUNT(*) FROM alertas_sistema WHERE resuelta = FALSE) > 5 THEN 'ALTO'
        WHEN (SELECT COUNT(*) FROM alertas_sistema WHERE resuelta = FALSE) > 2 THEN 'MEDIO'
        ELSE 'BAJO'
    END;
```

### 2. Procedimiento de Reporte Completo

```sql
-- Procedimiento para reporte completo del sistema
DELIMITER //
CREATE PROCEDURE reporte_completo_sistema()
BEGIN
    SELECT '=== REPORTE COMPLETO DEL SISTEMA MULTI-SGBD ===' as titulo;
    
    -- Información del sistema
    SELECT 'Información del Sistema' as seccion;
    SELECT 
        'SGBD Activo' as parametro,
        sgbd_activo as valor
    FROM configuracion_sistema 
    WHERE activo = TRUE
    UNION ALL
    SELECT 
        'Versión',
        version_sgbd
    FROM configuracion_sistema 
    WHERE activo = TRUE;
    
    -- Estadísticas de usuarios
    SELECT 'Estadísticas de Usuarios' as seccion;
    SELECT 
        'Total Usuarios' as metrica,
        COUNT(*) as valor
    FROM usuarios
    UNION ALL
    SELECT 
        'Usuarios Activos',
        COUNT(*)
    FROM usuarios WHERE activo = TRUE
    UNION ALL
    SELECT 
        'Sesiones Activas',
        COUNT(*)
    FROM sesiones_usuario WHERE activa = TRUE;
    
    -- Estadísticas de productos
    SELECT 'Estadísticas de Productos' as seccion;
    SELECT 
        'Total Productos' as metrica,
        COUNT(*) as valor
    FROM productos
    UNION ALL
    SELECT 
        'Productos Activos',
        COUNT(*)
    FROM productos WHERE activo = TRUE
    UNION ALL
    SELECT 
        'Productos Bajo Stock',
        COUNT(*)
    FROM productos WHERE stock_actual <= stock_minimo AND activo = TRUE;
    
    -- Estadísticas de ventas
    SELECT 'Estadísticas de Ventas' as seccion;
    SELECT 
        'Ventas Hoy' as metrica,
        COUNT(*) as valor
    FROM ventas WHERE DATE(fecha_venta) = CURDATE()
    UNION ALL
    SELECT 
        'Total Ventas Hoy',
        COALESCE(SUM(total), 0)
    FROM ventas WHERE DATE(fecha_venta) = CURDATE()
    UNION ALL
    SELECT 
        'Ventas del Mes',
        COUNT(*)
    FROM ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE()) AND YEAR(fecha_venta) = YEAR(CURDATE());
    
    -- Alertas del sistema
    SELECT 'Alertas del Sistema' as seccion;
    SELECT 
        severidad,
        COUNT(*) as cantidad,
        GROUP_CONCAT(titulo) as alertas
    FROM alertas_sistema 
    WHERE resuelta = FALSE
    GROUP BY severidad;
END //
DELIMITER ;
```

## Ejercicios Prácticos del Proyecto

### Ejercicio 1: Implementación del Sistema Base
```sql
-- Ejecutar todos los scripts de creación de tablas
-- Insertar datos de prueba

-- Insertar categorías de prueba
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Ropa', 'Vestimenta y accesorios'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipos y accesorios deportivos');

-- Insertar productos de prueba
INSERT INTO productos (codigo, nombre, descripcion, categoria_id, precio, costo, stock_actual, stock_minimo) VALUES
('ELEC001', 'Smartphone Samsung Galaxy', 'Teléfono inteligente de última generación', 1, 599.99, 400.00, 50, 10),
('ELEC002', 'Laptop Dell Inspiron', 'Computadora portátil para trabajo y estudio', 1, 899.99, 650.00, 25, 5),
('ROPA001', 'Camiseta Nike', 'Camiseta deportiva de algodón', 2, 29.99, 15.00, 100, 20),
('HOGAR001', 'Sofá 3 plazas', 'Sofá cómodo para sala de estar', 3, 799.99, 500.00, 10, 2);

-- Insertar usuarios de prueba
INSERT INTO usuarios (username, email, password_hash, nombre, apellido, rol) VALUES
('admin', 'admin@empresa.com', SHA2('admin123', 256), 'Administrador', 'Sistema', 'ADMIN'),
('gerente', 'gerente@empresa.com', SHA2('gerente123', 256), 'Juan', 'Pérez', 'GERENTE'),
('vendedor1', 'vendedor1@empresa.com', SHA2('vendedor123', 256), 'María', 'González', 'EMPLEADO');

-- Insertar clientes de prueba
INSERT INTO clientes (codigo_cliente, nombre, apellido, email, telefono) VALUES
('CLI001', 'Carlos', 'Rodríguez', 'carlos@email.com', '555-0101'),
('CLI002', 'Ana', 'Martínez', 'ana@email.com', '555-0102'),
('CLI003', 'Luis', 'Fernández', 'luis@email.com', '555-0103');
```

### Ejercicio 2: Sistema de Ventas
```sql
-- Crear una venta de prueba
INSERT INTO ventas (numero_venta, cliente_id, vendedor_id, subtotal, impuestos, total) VALUES
('VTA-2024-001', 1, 3, 629.98, 63.00, 692.98);

-- Insertar detalles de la venta
INSERT INTO detalles_venta (venta_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 599.99, 599.99),
(1, 3, 1, 29.99, 29.99);

-- Actualizar stock de productos
UPDATE productos SET stock_actual = stock_actual - 1 WHERE id IN (1, 3);

-- Registrar movimiento de inventario
INSERT INTO movimientos_inventario (producto_id, tipo_movimiento, cantidad, motivo, usuario_id) VALUES
(1, 'SALIDA', 1, 'Venta VTA-2024-001', 3),
(3, 'SALIDA', 1, 'Venta VTA-2024-001', 3);
```

### Ejercicio 3: Monitoreo y Alertas
```sql
-- Ejecutar recopilación de métricas
CALL recopilar_metricas_sistema();

-- Verificar alertas del sistema
CALL verificar_alertas_sistema();

-- Consultar métricas recopiladas
SELECT 
    metrica,
    valor,
    unidad,
    categoria,
    fecha_medicion
FROM metricas_sistema 
ORDER BY fecha_medicion DESC, categoria, metrica;

-- Consultar alertas activas
SELECT 
    tipo_alerta,
    severidad,
    titulo,
    mensaje,
    fecha_alerta
FROM alertas_sistema 
WHERE resuelta = FALSE
ORDER BY severidad DESC, fecha_alerta DESC;
```

### Ejercicio 4: Dashboard de Administración
```sql
-- Consultar dashboard
SELECT * FROM dashboard_administracion;

-- Ejecutar reporte completo
CALL reporte_completo_sistema();

-- Consultar ventas por vendedor
SELECT 
    u.nombre,
    u.apellido,
    COUNT(v.id) as total_ventas,
    COALESCE(SUM(v.total), 0) as total_monto
FROM usuarios u
LEFT JOIN ventas v ON u.id = v.vendedor_id
WHERE u.rol = 'EMPLEADO'
GROUP BY u.id, u.nombre, u.apellido
ORDER BY total_monto DESC;
```

### Ejercicio 5: Análisis de Inventario
```sql
-- Consultar productos bajo stock
SELECT 
    p.codigo,
    p.nombre,
    p.stock_actual,
    p.stock_minimo,
    (p.stock_actual - p.stock_minimo) as diferencia,
    c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock_actual <= p.stock_minimo AND p.activo = TRUE
ORDER BY diferencia ASC;

-- Consultar movimientos de inventario recientes
SELECT 
    p.nombre as producto,
    mi.tipo_movimiento,
    mi.cantidad,
    mi.motivo,
    u.nombre as usuario,
    mi.fecha_movimiento
FROM movimientos_inventario mi
JOIN productos p ON mi.producto_id = p.id
JOIN usuarios u ON mi.usuario_id = u.id
ORDER BY mi.fecha_movimiento DESC
LIMIT 20;
```

### Ejercicio 6: Sistema de Migración
```sql
-- Generar scripts de migración
CALL generar_script_migracion('MySQL', 'PostgreSQL', 'SCHEMA');
CALL generar_script_migracion('MySQL', 'PostgreSQL', 'DATA');
CALL generar_script_migracion('MySQL', 'SQL Server', 'SCHEMA');

-- Consultar scripts generados
SELECT 
    sgbd_origen,
    sgbd_destino,
    tipo_script,
    nombre_script,
    fecha_creacion
FROM scripts_migracion
ORDER BY fecha_creacion DESC;

-- Consultar configuración de SGBD
SELECT 
    sgbd,
    version,
    host,
    puerto,
    base_datos,
    activo
FROM configuraciones_sgbd
ORDER BY activo DESC, sgbd;
```

### Ejercicio 7: Análisis de Rendimiento
```sql
-- Consultar productos más vendidos
SELECT 
    p.nombre,
    p.codigo,
    SUM(dv.cantidad) as total_vendido,
    COUNT(DISTINCT dv.venta_id) as veces_vendido,
    SUM(dv.subtotal) as total_ingresos
FROM productos p
JOIN detalles_venta dv ON p.id = dv.producto_id
JOIN ventas v ON dv.venta_id = v.id
GROUP BY p.id, p.nombre, p.codigo
ORDER BY total_vendido DESC;

-- Consultar clientes más activos
SELECT 
    c.nombre,
    c.apellido,
    c.codigo_cliente,
    COUNT(v.id) as total_compras,
    COALESCE(SUM(v.total), 0) as total_gastado,
    MAX(v.fecha_venta) as ultima_compra
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre, c.apellido, c.codigo_cliente
ORDER BY total_gastado DESC;
```

### Ejercicio 8: Reportes Avanzados
```sql
-- Crear vista de reporte de ventas por mes
CREATE VIEW reporte_ventas_mensual AS
SELECT 
    YEAR(fecha_venta) as año,
    MONTH(fecha_venta) as mes,
    COUNT(*) as total_ventas,
    COALESCE(SUM(total), 0) as total_monto,
    AVG(total) as promedio_venta,
    COUNT(DISTINCT cliente_id) as clientes_unicos
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY año DESC, mes DESC;

-- Consultar reporte mensual
SELECT * FROM reporte_ventas_mensual;

-- Crear vista de análisis de inventario
CREATE VIEW analisis_inventario AS
SELECT 
    c.nombre as categoria,
    COUNT(p.id) as total_productos,
    SUM(p.stock_actual) as stock_total,
    SUM(p.stock_actual * p.precio) as valor_inventario,
    COUNT(CASE WHEN p.stock_actual <= p.stock_minimo THEN 1 END) as productos_bajo_stock
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id AND p.activo = TRUE
GROUP BY c.id, c.nombre
ORDER BY valor_inventario DESC;

-- Consultar análisis de inventario
SELECT * FROM analisis_inventario;
```

### Ejercicio 9: Mantenimiento del Sistema
```sql
-- Crear procedimiento de mantenimiento
DELIMITER //
CREATE PROCEDURE mantenimiento_sistema()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Limpiar sesiones expiradas
    DELETE FROM sesiones_usuario 
    WHERE fecha_expiracion < NOW() OR activa = FALSE;
    
    -- Limpiar métricas antiguas (más de 30 días)
    DELETE FROM metricas_sistema 
    WHERE fecha_medicion < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Limpiar alertas resueltas antiguas (más de 7 días)
    DELETE FROM alertas_sistema 
    WHERE resuelta = TRUE AND fecha_resolucion < DATE_SUB(NOW(), INTERVAL 7 DAY);
    
    -- Optimizar tablas principales
    OPTIMIZE TABLE usuarios, productos, ventas, detalles_venta;
    
    -- Actualizar estadísticas
    ANALYZE TABLE usuarios, productos, ventas, detalles_venta;
    
    COMMIT;
    
    SELECT 'Mantenimiento del sistema completado exitosamente' as resultado;
END //
DELIMITER ;

-- Ejecutar mantenimiento
CALL mantenimiento_sistema();
```

### Ejercicio 10: Validación del Sistema
```sql
-- Crear procedimiento de validación
DELIMITER //
CREATE PROCEDURE validar_sistema()
BEGIN
    DECLARE v_errores INT DEFAULT 0;
    DECLARE v_advertencias INT DEFAULT 0;
    
    -- Validar integridad referencial
    IF EXISTS (SELECT 1 FROM detalles_venta dv LEFT JOIN ventas v ON dv.venta_id = v.id WHERE v.id IS NULL) THEN
        SET v_errores = v_errores + 1;
        SELECT 'ERROR: Detalles de venta sin venta válida' as validacion;
    END IF;
    
    IF EXISTS (SELECT 1 FROM ventas v LEFT JOIN clientes c ON v.cliente_id = c.id WHERE c.id IS NULL) THEN
        SET v_errores = v_errores + 1;
        SELECT 'ERROR: Ventas sin cliente válido' as validacion;
    END IF;
    
    -- Validar consistencia de datos
    IF EXISTS (SELECT 1 FROM productos WHERE precio <= 0 OR costo <= 0) THEN
        SET v_advertencias = v_advertencias + 1;
        SELECT 'ADVERTENCIA: Productos con precios o costos inválidos' as validacion;
    END IF;
    
    IF EXISTS (SELECT 1 FROM ventas WHERE total < 0) THEN
        SET v_errores = v_errores + 1;
        SELECT 'ERROR: Ventas con total negativo' as validacion;
    END IF;
    
    -- Validar stock negativo
    IF EXISTS (SELECT 1 FROM productos WHERE stock_actual < 0) THEN
        SET v_errores = v_errores + 1;
        SELECT 'ERROR: Productos con stock negativo' as validacion;
    END IF;
    
    -- Mostrar resumen
    SELECT 
        'RESUMEN DE VALIDACIÓN' as titulo,
        v_errores as errores_encontrados,
        v_advertencias as advertencias_encontradas,
        CASE 
            WHEN v_errores = 0 AND v_advertencias = 0 THEN 'SISTEMA VÁLIDO'
            WHEN v_errores = 0 THEN 'SISTEMA VÁLIDO CON ADVERTENCIAS'
            ELSE 'SISTEMA CON ERRORES'
        END as estado_validacion;
END //
DELIMITER ;

-- Ejecutar validación
CALL validar_sistema();
```

## Resumen del Proyecto

Este proyecto integrador demuestra:

1. **Diseño Multi-SGBD**: Sistema compatible con MySQL, PostgreSQL, SQL Server y Oracle
2. **Arquitectura Modular**: Módulos independientes pero integrados
3. **Gestión Empresarial Completa**: Usuarios, productos, ventas, inventario
4. **Sistema de Monitoreo**: Métricas, alertas y dashboards
5. **Capacidad de Migración**: Herramientas para migrar entre SGBD
6. **Mejores Prácticas**: Seguridad, validación, mantenimiento
7. **Administración Avanzada**: Reportes, análisis y validaciones

## Conclusión del Módulo

Al completar este módulo, los estudiantes han adquirido:

- Conocimiento profundo de los principales SGBD del mercado
- Habilidades de instalación y configuración
- Experiencia con herramientas de administración
- Comprensión de características específicas de cada sistema
- Aplicación de mejores prácticas de administración
- Capacidad de planificar y ejecutar migraciones
- Experiencia en proyectos integrales multi-SGBD

## Próximo Módulo
[Módulo 1: Fundamentos Avanzados - Nivel Mid-Level](../midLevel_1/README.md)

## Recursos Adicionales
- [MySQL Best Practices](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [SQL Server Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/performance/)
- [Oracle Best Practices](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/)
