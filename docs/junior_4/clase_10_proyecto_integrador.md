# Clase 10: Proyecto Integrador - Sistema de Gestión Empresarial

## Objetivos del Proyecto
- Aplicar todos los conceptos de diseño de bases de datos
- Crear un sistema completo y escalable
- Implementar mejores prácticas de diseño
- Demostrar competencias adquiridas

## Descripción del Proyecto

### Sistema de Gestión Empresarial
Diseñar y implementar una base de datos completa para una empresa que incluye:
- Gestión de empleados y departamentos
- Sistema de inventario y productos
- Módulo de ventas y clientes
- Sistema de recursos humanos
- Reportes y análisis

## Estructura del Proyecto

### 1. Análisis de Requisitos

#### Entidades Principales:
- **EMPLEADOS**: Información del personal
- **DEPARTAMENTOS**: Organización de la empresa
- **PRODUCTOS**: Catálogo de productos
- **CLIENTES**: Base de clientes
- **VENTAS**: Transacciones comerciales
- **INVENTARIO**: Control de stock
- **NÓMINAS**: Sistema de pagos

#### Relaciones Identificadas:
- Empleado → Departamento (N:1)
- Empleado → Nómina (1:N)
- Cliente → Venta (1:N)
- Producto → Venta (N:N)
- Producto → Inventario (1:1)

### 2. Diseño del Esquema

#### Aplicando Normalización:
```sql
-- Crear base de datos del proyecto
CREATE DATABASE gestion_empresarial;
USE gestion_empresarial;

-- Tabla de departamentos (3FN)
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    presupuesto DECIMAL(12,2),
    jefe_departamento_id INT,
    fecha_creacion DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de empleados (3FN)
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_contratacion DATE NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    departamento_id INT,
    cargo VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL,
    
    CONSTRAINT chk_salario_positivo CHECK (salario_base > 0)
);

-- Tabla de categorías de productos
CREATE TABLE categorias_productos (
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
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock_minimo INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias_productos(id) ON DELETE SET NULL,
    
    CONSTRAINT chk_precio_positivo CHECK (precio > 0),
    CONSTRAINT chk_stock_minimo_no_negativo CHECK (stock_minimo >= 0)
);

-- Tabla de inventario
CREATE TABLE inventario (
    producto_id INT PRIMARY KEY,
    stock_actual INT DEFAULT 0,
    ubicacion VARCHAR(100),
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    
    CONSTRAINT chk_stock_actual_no_negativo CHECK (stock_actual >= 0)
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    metodo_pago VARCHAR(50),
    
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE RESTRICT,
    
    CONSTRAINT chk_total_positivo CHECK (total > 0)
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unitario_positivo CHECK (precio_unitario > 0),
    CONSTRAINT chk_subtotal_positivo CHECK (subtotal > 0)
);

-- Tabla de nóminas
CREATE TABLE nominas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    periodo_inicio DATE NOT NULL,
    periodo_fin DATE NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    horas_extras DECIMAL(5,2) DEFAULT 0,
    bonificaciones DECIMAL(10,2) DEFAULT 0,
    deducciones DECIMAL(10,2) DEFAULT 0,
    salario_neto DECIMAL(10,2) NOT NULL,
    fecha_pago DATE,
    estado ENUM('pendiente', 'pagada', 'cancelada') DEFAULT 'pendiente',
    
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE,
    
    CONSTRAINT chk_periodo_valido CHECK (periodo_fin > periodo_inicio),
    CONSTRAINT chk_salario_neto_positivo CHECK (salario_neto > 0)
);
```

### 3. Índices para Optimización

```sql
-- Índices para empleados
CREATE INDEX idx_empleados_departamento ON empleados(departamento_id);
CREATE INDEX idx_empleados_email ON empleados(email);
CREATE INDEX idx_empleados_activo ON empleados(activo);

-- Índices para productos
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_productos_activo ON productos(activo);

-- Índices para ventas
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_empleado ON ventas(empleado_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);

-- Índices compuestos
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);
CREATE INDEX idx_ventas_empleado_fecha ON ventas(empleado_id, fecha_venta);
CREATE INDEX idx_ventas_estado_fecha ON ventas(estado, fecha_venta);
```

### 4. Triggers para Integridad

```sql
-- Trigger para actualizar stock después de venta
DELIMITER //
CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE inventario
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
END//
DELIMITER ;

-- Trigger para validar stock antes de venta
DELIMITER //
CREATE TRIGGER validar_stock_antes_venta
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE stock_disponible INT;
    
    SELECT stock_actual INTO stock_disponible
    FROM inventario
    WHERE producto_id = NEW.producto_id;
    
    IF stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para el producto';
    END IF;
END//
DELIMITER ;

-- Trigger para calcular salario neto
DELIMITER //
CREATE TRIGGER calcular_salario_neto
BEFORE INSERT ON nominas
FOR EACH ROW
BEGIN
    SET NEW.salario_neto = NEW.salario_base + NEW.bonificaciones - NEW.deducciones;
END//
DELIMITER ;
```

### 5. Datos de Ejemplo

```sql
-- Insertar departamentos
INSERT INTO departamentos (nombre, descripcion, presupuesto) VALUES
('Ventas', 'Departamento de ventas y atención al cliente', 100000.00),
('Marketing', 'Departamento de marketing y publicidad', 75000.00),
('IT', 'Departamento de tecnología e informática', 150000.00),
('Recursos Humanos', 'Gestión de personal y nóminas', 50000.00);

-- Insertar empleados
INSERT INTO empleados (nombre, apellido, email, telefono, fecha_contratacion, salario_base, departamento_id, cargo) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', '555-0101', '2023-01-15', 45000.00, 1, 'Vendedor'),
('María', 'García', 'maria.garcia@empresa.com', '555-0102', '2023-02-20', 50000.00, 1, 'Supervisor de Ventas'),
('Carlos', 'López', 'carlos.lopez@empresa.com', '555-0103', '2023-03-10', 60000.00, 3, 'Desarrollador'),
('Ana', 'Martínez', 'ana.martinez@empresa.com', '555-0104', '2023-04-05', 55000.00, 2, 'Especialista en Marketing'),
('Pedro', 'Sánchez', 'pedro.sanchez@empresa.com', '555-0105', '2023-05-12', 48000.00, 4, 'Especialista en RRHH');

-- Insertar categorías de productos
INSERT INTO categorias_productos (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Hogar', 'Artículos para el hogar y decoración'),
('Deportes', 'Equipos y accesorios deportivos'),
('Oficina', 'Artículos de oficina y papelería');

-- Insertar productos
INSERT INTO productos (codigo, nombre, descripcion, precio, categoria_id, stock_minimo) VALUES
('LAP001', 'Laptop Dell Inspiron', 'Computadora portátil Dell Inspiron 15', 15000.00, 1, 5),
('MOU001', 'Mouse Logitech', 'Mouse inalámbrico Logitech MX Master', 800.00, 1, 20),
('SOF001', 'Sofá 3 Plazas', 'Sofá de 3 plazas color gris', 12000.00, 2, 2),
('PEL001', 'Pelota de Fútbol', 'Pelota de fútbol oficial', 300.00, 3, 15),
('ESC001', 'Escritorio Ejecutivo', 'Escritorio de madera para oficina', 5000.00, 4, 3);

-- Insertar inventario
INSERT INTO inventario (producto_id, stock_actual, ubicacion) VALUES
(1, 10, 'Almacén A - Estante 1'),
(2, 50, 'Almacén A - Estante 2'),
(3, 5, 'Almacén B - Sección Muebles'),
(4, 25, 'Almacén C - Sección Deportes'),
(5, 8, 'Almacén B - Sección Oficina');

-- Insertar clientes
INSERT INTO clientes (nombre, apellido, email, telefono, ciudad, estado) VALUES
('Roberto', 'Jiménez', 'roberto.jimenez@email.com', '555-0201', 'Ciudad de México', 'CDMX'),
('Laura', 'Vega', 'laura.vega@email.com', '555-0202', 'Guadalajara', 'Jalisco'),
('Miguel', 'Torres', 'miguel.torres@email.com', '555-0203', 'Monterrey', 'Nuevo León'),
('Sofia', 'Herrera', 'sofia.herrera@email.com', '555-0204', 'Puebla', 'Puebla');

-- Insertar ventas
INSERT INTO ventas (cliente_id, empleado_id, fecha_venta, total, estado, metodo_pago) VALUES
(1, 1, '2024-01-15', 15800.00, 'completada', 'Tarjeta de Crédito'),
(2, 2, '2024-01-16', 12000.00, 'completada', 'Efectivo'),
(3, 1, '2024-01-17', 300.00, 'completada', 'Transferencia'),
(4, 2, '2024-01-18', 5000.00, 'pendiente', 'Tarjeta de Débito');

-- Insertar detalle de ventas
INSERT INTO detalle_ventas VALUES
(1, 1, 1, 15000.00, 15000.00),  -- Laptop
(1, 2, 1, 800.00, 800.00),      -- Mouse
(2, 3, 1, 12000.00, 12000.00),  -- Sofá
(3, 4, 1, 300.00, 300.00),      -- Pelota
(4, 5, 1, 5000.00, 5000.00);    -- Escritorio
```

### 6. Consultas del Sistema

```sql
-- Consulta 1: Empleados por departamento
SELECT 
    d.nombre as departamento,
    COUNT(e.id) as total_empleados,
    AVG(e.salario_base) as salario_promedio,
    SUM(e.salario_base) as presupuesto_total
FROM departamentos d
LEFT JOIN empleados e ON d.id = e.departamento_id
WHERE d.activo = TRUE AND (e.activo = TRUE OR e.activo IS NULL)
GROUP BY d.id, d.nombre
ORDER BY total_empleados DESC;

-- Consulta 2: Productos con stock bajo
SELECT 
    p.codigo,
    p.nombre,
    p.precio,
    cp.nombre as categoria,
    i.stock_actual,
    p.stock_minimo,
    (i.stock_actual - p.stock_minimo) as diferencia
FROM productos p
JOIN categorias_productos cp ON p.categoria_id = cp.id
JOIN inventario i ON p.id = i.producto_id
WHERE i.stock_actual <= p.stock_minimo
AND p.activo = TRUE
ORDER BY diferencia ASC;

-- Consulta 3: Ventas por empleado
SELECT 
    e.nombre,
    e.apellido,
    d.nombre as departamento,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as ingresos_totales,
    AVG(v.total) as promedio_venta
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
LEFT JOIN ventas v ON e.id = v.empleado_id
WHERE e.activo = TRUE
GROUP BY e.id, e.nombre, e.apellido, d.nombre
ORDER BY ingresos_totales DESC;

-- Consulta 4: Clientes más activos
SELECT 
    c.nombre,
    c.apellido,
    c.email,
    c.ciudad,
    COUNT(v.id) as total_compras,
    SUM(v.total) as total_gastado,
    AVG(v.total) as promedio_compra,
    MAX(v.fecha_venta) as ultima_compra
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE c.activo = TRUE
GROUP BY c.id, c.nombre, c.apellido, c.email, c.ciudad
HAVING total_compras > 0
ORDER BY total_gastado DESC
LIMIT 10;

-- Consulta 5: Análisis de ventas por mes
SELECT 
    YEAR(v.fecha_venta) as año,
    MONTH(v.fecha_venta) as mes,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as ingresos_totales,
    AVG(v.total) as promedio_venta,
    COUNT(DISTINCT v.cliente_id) as clientes_unicos,
    COUNT(DISTINCT v.empleado_id) as empleados_activos
FROM ventas v
WHERE v.estado = 'completada'
GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)
ORDER BY año DESC, mes DESC;
```

### 7. Reportes del Sistema

```sql
-- Reporte 1: Resumen ejecutivo
SELECT 
    'Total Empleados' as metric,
    COUNT(*) as valor
FROM empleados WHERE activo = TRUE
UNION ALL
SELECT 
    'Total Clientes',
    COUNT(*)
FROM clientes WHERE activo = TRUE
UNION ALL
SELECT 
    'Total Productos',
    COUNT(*)
FROM productos WHERE activo = TRUE
UNION ALL
SELECT 
    'Ventas del Mes',
    COUNT(*)
FROM ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE())
UNION ALL
SELECT 
    'Ingresos del Mes',
    COALESCE(SUM(total), 0)
FROM ventas WHERE MONTH(fecha_venta) = MONTH(CURDATE()) AND estado = 'completada';

-- Reporte 2: Análisis de inventario
SELECT 
    cp.nombre as categoria,
    COUNT(p.id) as total_productos,
    SUM(i.stock_actual) as stock_total,
    AVG(i.stock_actual) as stock_promedio,
    SUM(p.precio * i.stock_actual) as valor_inventario
FROM productos p
JOIN categorias_productos cp ON p.categoria_id = cp.id
JOIN inventario i ON p.id = i.producto_id
WHERE p.activo = TRUE
GROUP BY cp.id, cp.nombre
ORDER BY valor_inventario DESC;

-- Reporte 3: Nóminas del período
SELECT 
    e.nombre,
    e.apellido,
    d.nombre as departamento,
    n.salario_base,
    n.bonificaciones,
    n.deducciones,
    n.salario_neto,
    n.periodo_inicio,
    n.periodo_fin,
    n.estado
FROM nominas n
JOIN empleados e ON n.empleado_id = e.id
JOIN departamentos d ON e.departamento_id = d.id
WHERE n.periodo_inicio >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY n.salario_neto DESC;
```

## Evaluación del Proyecto

### Criterios de Evaluación:
1. **Diseño de Esquema** (25%)
   - Normalización correcta
   - Relaciones apropiadas
   - Restricciones de integridad

2. **Optimización** (25%)
   - Índices estratégicos
   - Consultas eficientes
   - Triggers apropiados

3. **Funcionalidad** (25%)
   - Consultas completas
   - Reportes útiles
   - Datos de ejemplo

4. **Documentación** (25%)
   - Comentarios claros
   - Estructura organizada
   - Explicaciones detalladas

### Entregables:
1. Script SQL completo
2. Documentación del diseño
3. Consultas de ejemplo
4. Reportes implementados
5. Presentación del proyecto

## Conclusiones

Este proyecto integrador demuestra la aplicación de todos los conceptos aprendidos en el módulo de diseño de bases de datos, incluyendo:

- **Normalización**: Esquema en 3FN
- **Relaciones**: Claves foráneas apropiadas
- **Integridad**: Restricciones y triggers
- **Optimización**: Índices estratégicos
- **Escalabilidad**: Diseño para crecimiento
- **Rendimiento**: Consultas optimizadas

El sistema resultante es robusto, escalable y sigue las mejores prácticas de diseño de bases de datos.
