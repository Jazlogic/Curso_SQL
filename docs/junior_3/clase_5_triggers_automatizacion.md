# Clase 5: Triggers y Automatización

## 📋 Descripción

En esta clase aprenderás sobre triggers (disparadores) en MySQL. Los triggers son procedimientos automáticos que se ejecutan cuando ocurren eventos específicos en la base de datos, como INSERT, UPDATE o DELETE. Son fundamentales para automatizar tareas, mantener la integridad de los datos y implementar lógica de negocio.

## 🎯 Objetivos de la Clase

- Comprender qué son los triggers y cuándo usarlos
- Aprender a crear triggers para diferentes eventos
- Entender los tipos de triggers (BEFORE, AFTER)
- Implementar triggers para auditoría y logging
- Crear triggers para validación de datos
- Manejar triggers complejos y anidados

## 📚 Conceptos Clave

### ¿Qué es un Trigger?

Un **trigger** es un procedimiento automático que se ejecuta cuando ocurre un evento específico en una tabla. Los triggers se ejecutan automáticamente sin intervención del usuario.

### Tipos de Triggers

1. **BEFORE**: Se ejecuta antes de la operación
2. **AFTER**: Se ejecuta después de la operación

### Eventos que Activan Triggers

- **INSERT**: Al insertar nuevos registros
- **UPDATE**: Al actualizar registros existentes
- **DELETE**: Al eliminar registros

### Usos Comunes de Triggers

- **Auditoría**: Registrar cambios en los datos
- **Validación**: Verificar datos antes de insertar/actualizar
- **Cálculos automáticos**: Actualizar campos calculados
- **Integridad referencial**: Mantener consistencia entre tablas
- **Logging**: Registrar actividades del sistema

## 🔧 Sintaxis y Comandos

### Crear Trigger

```sql
DELIMITER //

CREATE TRIGGER nombre_trigger
    {BEFORE | AFTER} {INSERT | UPDATE | DELETE}
    ON nombre_tabla
    FOR EACH ROW
BEGIN
    -- código del trigger
END //

DELIMITER ;
```

### Gestionar Triggers

```sql
-- Ver triggers existentes
SHOW TRIGGERS;

-- Ver código de un trigger
SHOW CREATE TRIGGER nombre_trigger;

-- Eliminar un trigger
DROP TRIGGER nombre_trigger;
```

### Variables Especiales en Triggers

- **NEW**: Contiene los nuevos valores (INSERT, UPDATE)
- **OLD**: Contiene los valores antiguos (UPDATE, DELETE)

## 📖 Ejemplos Prácticos

### Ejemplo 1: Trigger de Auditoría

```sql
-- Crear tabla de auditoría
CREATE TABLE auditoria_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    accion VARCHAR(10),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario VARCHAR(100),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para auditar cambios en productos
DELIMITER //

CREATE TRIGGER trigger_auditoria_productos
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id, 
        accion, 
        valor_anterior, 
        valor_nuevo, 
        usuario
    ) VALUES (
        NEW.id,
        'UPDATE',
        CONCAT('Nombre: ', OLD.nombre, ', Precio: ', OLD.precio, ', Stock: ', OLD.stock),
        CONCAT('Nombre: ', NEW.nombre, ', Precio: ', NEW.precio, ', Stock: ', NEW.stock),
        USER()
    );
END //

DELIMITER ;

-- Probar el trigger
UPDATE productos SET precio = 1099.99 WHERE id = 1;
SELECT * FROM auditoria_productos;
```

**Explicación línea por línea:**

1. `CREATE TRIGGER trigger_auditoria_productos` - Crea el trigger con nombre
2. `AFTER UPDATE ON productos` - Se ejecuta después de actualizar la tabla productos
3. `FOR EACH ROW` - Se ejecuta para cada fila afectada
4. `NEW.id` - Accede al nuevo valor del campo id
5. `OLD.nombre` - Accede al valor anterior del campo nombre
6. `USER()` - Función que devuelve el usuario actual

### Ejemplo 2: Trigger de Validación

```sql
-- Trigger para validar datos antes de insertar
DELIMITER //

CREATE TRIGGER trigger_validar_producto
    BEFORE INSERT ON productos
    FOR EACH ROW
BEGIN
    -- Validar que el nombre no esté vacío
    IF NEW.nombre IS NULL OR NEW.nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del producto es requerido';
    END IF;
    
    -- Validar que el precio sea positivo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
    
    -- Validar que el stock no sea negativo
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Convertir nombre a mayúsculas
    SET NEW.nombre = UPPER(NEW.nombre);
END //

DELIMITER ;

-- Probar el trigger
INSERT INTO productos (nombre, precio, stock) VALUES ('nuevo producto', 99.99, 10);
SELECT * FROM productos WHERE nombre = 'NUEVO PRODUCTO';
```

### Ejemplo 3: Trigger de Cálculo Automático

```sql
-- Crear tabla de ventas con total calculado
CREATE TABLE ventas_detalle (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    total DECIMAL(10,2),
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para calcular total automáticamente
DELIMITER //

CREATE TRIGGER trigger_calcular_total
    BEFORE INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    SET NEW.total = NEW.cantidad * NEW.precio_unitario;
END //

DELIMITER ;

-- Probar el trigger
INSERT INTO ventas_detalle (producto_id, cantidad, precio_unitario) 
VALUES (1, 2, 999.99);
SELECT * FROM ventas_detalle;
```

### Ejemplo 4: Trigger de Actualización de Stock

```sql
-- Trigger para actualizar stock automáticamente
DELIMITER //

CREATE TRIGGER trigger_actualizar_stock
    AFTER INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    UPDATE productos 
    SET stock = stock - NEW.cantidad 
    WHERE id = NEW.producto_id;
END //

DELIMITER ;

-- Probar el trigger
INSERT INTO ventas_detalle (producto_id, cantidad, precio_unitario) 
VALUES (1, 1, 999.99);
SELECT id, nombre, stock FROM productos WHERE id = 1;
```

### Ejemplo 5: Trigger de Logging de Eliminaciones

```sql
-- Crear tabla de log de eliminaciones
CREATE TABLE log_eliminaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(50),
    registro_eliminado TEXT,
    usuario VARCHAR(100),
    fecha_eliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para registrar eliminaciones
DELIMITER //

CREATE TRIGGER trigger_log_eliminacion_productos
    AFTER DELETE ON productos
    FOR EACH ROW
BEGIN
    INSERT INTO log_eliminaciones (
        tabla_afectada, 
        registro_eliminado, 
        usuario
    ) VALUES (
        'productos',
        CONCAT('ID: ', OLD.id, ', Nombre: ', OLD.nombre, ', Precio: ', OLD.precio),
        USER()
    );
END //

DELIMITER ;

-- Probar el trigger
DELETE FROM productos WHERE id = 3;
SELECT * FROM log_eliminaciones;
```

### Ejemplo 6: Trigger de Actualización de Timestamps

```sql
-- Agregar campos de timestamp a productos
ALTER TABLE productos 
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Trigger para actualizar fecha de modificación
DELIMITER //

CREATE TRIGGER trigger_actualizar_fecha_modificacion
    BEFORE UPDATE ON productos
    FOR EACH ROW
BEGIN
    SET NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- Probar el trigger
UPDATE productos SET precio = 1199.99 WHERE id = 1;
SELECT id, nombre, precio, fecha_creacion, fecha_actualizacion FROM productos WHERE id = 1;
```

### Ejemplo 7: Trigger de Validación de Integridad

```sql
-- Crear tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES 
('Electrónicos', 'Dispositivos electrónicos'),
('Accesorios', 'Accesorios para computadora');

-- Agregar campo categoría a productos
ALTER TABLE productos ADD COLUMN categoria_id INT;

-- Trigger para validar categoría existente
DELIMITER //

CREATE TRIGGER trigger_validar_categoria
    BEFORE INSERT ON productos
    FOR EACH ROW
BEGIN
    IF NEW.categoria_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM categorias WHERE id = NEW.categoria_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría especificada no existe';
        END IF;
    END IF;
END //

DELIMITER ;

-- Probar el trigger
INSERT INTO productos (nombre, precio, stock, categoria_id) 
VALUES ('Nuevo Producto', 199.99, 5, 1);
```

### Ejemplo 8: Trigger de Actualización de Estadísticas

```sql
-- Crear tabla de estadísticas
CREATE TABLE estadisticas_productos (
    producto_id INT PRIMARY KEY,
    total_ventas INT DEFAULT 0,
    ultima_venta TIMESTAMP NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Trigger para actualizar estadísticas
DELIMITER //

CREATE TRIGGER trigger_actualizar_estadisticas
    AFTER INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    INSERT INTO estadisticas_productos (producto_id, total_ventas, ultima_venta)
    VALUES (NEW.producto_id, NEW.cantidad, NEW.fecha_venta)
    ON DUPLICATE KEY UPDATE
        total_ventas = total_ventas + NEW.cantidad,
        ultima_venta = NEW.fecha_venta;
END //

DELIMITER ;

-- Probar el trigger
INSERT INTO ventas_detalle (producto_id, cantidad, precio_unitario) 
VALUES (1, 3, 999.99);
SELECT * FROM estadisticas_productos;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Trigger de Auditoría Completa
Crea un trigger que registre todos los cambios en la tabla productos con detalles completos.

### Ejercicio 2: Trigger de Validación de Datos
Implementa un trigger que valide múltiples campos antes de insertar o actualizar.

### Ejercicio 3: Trigger de Cálculo de Totales
Crea un trigger que calcule automáticamente totales en una tabla de facturas.

### Ejercicio 4: Trigger de Actualización de Contadores
Implementa un trigger que mantenga contadores de registros en tablas relacionadas.

### Ejercicio 5: Trigger de Validación de Negocio
Crea un trigger que implemente reglas de negocio específicas.

### Ejercicio 6: Trigger de Logging de Accesos
Implementa un trigger que registre todos los accesos a una tabla sensible.

### Ejercicio 7: Trigger de Actualización de Timestamps
Crea un trigger que maneje timestamps de creación y modificación.

### Ejercicio 8: Trigger de Validación de Integridad
Implementa un trigger que valide relaciones entre tablas.

### Ejercicio 9: Trigger de Cálculo de Promedios
Crea un trigger que calcule promedios automáticamente.

### Ejercicio 10: Trigger Complejo
Implementa un trigger que combine múltiples funcionalidades.

## 📝 Resumen

En esta clase has aprendido:

- **Triggers**: Procedimientos automáticos que se ejecutan en eventos
- **Tipos de triggers**: BEFORE y AFTER
- **Eventos**: INSERT, UPDATE, DELETE
- **Variables especiales**: NEW y OLD
- **Usos comunes**: Auditoría, validación, cálculos automáticos
- **Mejores prácticas**: Validación, logging, integridad

## 🔗 Próximos Pasos

- [Clase 6: Eventos Programados](clase_6_eventos_programados.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 5!** 🎉 Continúa con la siguiente clase para aprender sobre eventos programados.
