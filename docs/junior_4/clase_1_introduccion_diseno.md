# Clase 1: Introducción al Diseño de Bases de Datos

## Objetivos de la Clase
- Comprender los principios fundamentales del diseño de bases de datos
- Identificar los problemas de un mal diseño
- Aprender las fases del proceso de diseño
- Conocer las herramientas y metodologías de diseño

## Contenido Teórico

### 1. ¿Qué es el Diseño de Bases de Datos?

**Diseño de Bases de Datos** es el proceso de crear un esquema de base de datos que satisfaga los requisitos de una aplicación específica, optimizando el rendimiento, la integridad de los datos y la facilidad de mantenimiento.

#### Características de un Buen Diseño:
- **Eficiencia**: Consultas rápidas y uso óptimo de recursos
- **Integridad**: Datos consistentes y válidos
- **Escalabilidad**: Capacidad de crecer con la aplicación
- **Mantenibilidad**: Fácil de modificar y actualizar
- **Flexibilidad**: Adaptable a cambios futuros

### 2. Problemas de un Mal Diseño

#### Redundancia de Datos
```sql
-- MAL DISEÑO: Información duplicada
CREATE TABLE empleados_mal (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    departamento VARCHAR(50),
    jefe_departamento VARCHAR(100),  -- Redundante
    telefono_jefe VARCHAR(20),       -- Redundante
    email_jefe VARCHAR(100)          -- Redundante
);
```

**Problemas:**
- **Inconsistencia**: Si cambia el jefe, hay que actualizar múltiples registros
- **Espacio desperdiciado**: Almacenamiento innecesario
- **Errores de integridad**: Datos desactualizados

#### Anomalías de Actualización
```sql
-- Ejemplo de anomalía
UPDATE empleados_mal 
SET jefe_departamento = 'María García' 
WHERE departamento = 'Ventas';
-- Solo actualiza algunos registros, otros quedan desactualizados
```

### 3. Fases del Proceso de Diseño

#### Fase 1: Análisis de Requisitos
- Identificar entidades del negocio
- Definir atributos y relaciones
- Determinar restricciones y reglas

#### Fase 2: Diseño Conceptual
- Crear modelo entidad-relación (ER)
- Identificar claves primarias y foráneas
- Definir restricciones de integridad

#### Fase 3: Diseño Lógico
- Convertir modelo ER a esquema relacional
- Aplicar normalización
- Optimizar para el SGBD específico

#### Fase 4: Diseño Físico
- Crear índices para optimizar consultas
- Definir particionamiento
- Configurar parámetros de rendimiento

### 4. Herramientas de Diseño

#### MySQL Workbench
```sql
-- Herramienta visual para:
-- 1. Crear diagramas ER
-- 2. Generar código SQL automáticamente
-- 3. Sincronizar modelo con base de datos
-- 4. Administrar esquemas
```

#### DBeaver
```sql
-- Características:
-- 1. Editor visual de esquemas
-- 2. Generación de diagramas
-- 3. Comparación de esquemas
-- 4. Migración de datos
```

### 5. Metodologías de Diseño

#### Metodología Top-Down
1. **Análisis del negocio** → Entidades principales
2. **Descomposición** → Sub-entidades y atributos
3. **Normalización** → Eliminación de redundancias
4. **Optimización** → Mejora del rendimiento

#### Metodología Bottom-Up
1. **Análisis de datos existentes** → Identificar patrones
2. **Agrupación** → Crear entidades lógicas
3. **Integración** → Combinar esquemas
4. **Validación** → Verificar requisitos

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca

#### Requisitos Identificados:
- Gestión de libros, autores, usuarios
- Préstamos y devoluciones
- Categorías y ubicaciones

#### Entidades Principales:
```sql
-- Entidades identificadas:
-- 1. LIBROS (título, ISBN, año, categoría)
-- 2. AUTORES (nombre, nacionalidad, biografía)
-- 3. USUARIOS (nombre, email, teléfono)
-- 4. PRÉSTAMOS (fecha_préstamo, fecha_devolución)
-- 5. CATEGORÍAS (nombre, descripción)
```

### Ejemplo 2: Sistema de Ventas

#### Análisis de Requisitos:
```sql
-- Entidades del negocio:
-- 1. CLIENTES (información personal y de contacto)
-- 2. PRODUCTOS (catálogo de productos)
-- 3. VENTAS (transacciones de compra)
-- 4. EMPLEADOS (personal de ventas)
-- 5. CATEGORÍAS (clasificación de productos)
```

## Ejercicios Prácticos

### Ejercicio 1: Identificación de Entidades
**Objetivo**: Identificar entidades principales de un sistema de hospital.

**Solución**:
```sql
-- Entidades identificadas:
-- 1. PACIENTES (id, nombre, fecha_nacimiento, telefono)
-- 2. DOCTORES (id, nombre, especialidad, consultorio)
-- 3. CITAS (id, fecha, hora, estado)
-- 4. HISTORIALES (id, diagnostico, tratamiento, fecha)
-- 5. ESPECIALIDADES (id, nombre, descripcion)
```

### Ejercicio 2: Análisis de Redundancia
**Objetivo**: Identificar redundancias en el siguiente esquema.

```sql
CREATE TABLE ventas_redundante (
    id INT PRIMARY KEY,
    cliente_nombre VARCHAR(100),
    cliente_telefono VARCHAR(20),
    producto_nombre VARCHAR(100),
    producto_precio DECIMAL(10,2),
    vendedor_nombre VARCHAR(100),
    vendedor_departamento VARCHAR(50)
);
```

**Problemas identificados**:
- Información del cliente repetida
- Información del producto repetida
- Información del vendedor repetida

### Ejercicio 3: Diseño de Esquema Básico
**Objetivo**: Crear esquema inicial para sistema de restaurante.

```sql
-- Crear base de datos
CREATE DATABASE restaurante_db;
USE restaurante_db;

-- Tabla de mesas
CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    ubicacion VARCHAR(50)
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    mesa_id INT,
    fecha_reserva DATE,
    hora_reserva TIME,
    numero_personas INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);
```

### Ejercicio 4: Identificación de Relaciones
**Objetivo**: Identificar tipos de relaciones entre entidades.

```sql
-- Relaciones identificadas:
-- 1. CLIENTE → RESERVA (1:N) - Un cliente puede tener múltiples reservas
-- 2. MESA → RESERVA (1:N) - Una mesa puede tener múltiples reservas
-- 3. RESERVA → CLIENTE (N:1) - Una reserva pertenece a un cliente
-- 4. RESERVA → MESA (N:1) - Una reserva se asigna a una mesa
```

### Ejercicio 5: Definición de Restricciones
**Objetivo**: Agregar restricciones de integridad al esquema.

```sql
-- Agregar restricciones
ALTER TABLE mesas 
ADD CONSTRAINT chk_capacidad 
CHECK (capacidad > 0 AND capacidad <= 12);

ALTER TABLE reservas 
ADD CONSTRAINT chk_fecha_futura 
CHECK (fecha_reserva >= CURDATE());

ALTER TABLE reservas 
ADD CONSTRAINT chk_personas 
CHECK (numero_personas > 0);
```

### Ejercicio 6: Optimización de Consultas
**Objetivo**: Crear índices para optimizar consultas frecuentes.

```sql
-- Índices para optimización
CREATE INDEX idx_reservas_fecha ON reservas(fecha_reserva);
CREATE INDEX idx_reservas_cliente ON reservas(cliente_id);
CREATE INDEX idx_reservas_mesa ON reservas(mesa_id);
CREATE INDEX idx_clientes_telefono ON clientes(telefono);
```

### Ejercicio 7: Análisis de Rendimiento
**Objetivo**: Analizar consultas y proponer mejoras.

```sql
-- Consulta a optimizar
EXPLAIN SELECT c.nombre, r.fecha_reserva, m.numero
FROM clientes c
JOIN reservas r ON c.id = r.cliente_id
JOIN mesas m ON r.mesa_id = m.id
WHERE r.fecha_reserva = '2024-01-15';

-- Mejoras propuestas:
-- 1. Índice en fecha_reserva
-- 2. Índice compuesto en (cliente_id, fecha_reserva)
-- 3. Índice en mesa_id
```

### Ejercicio 8: Documentación del Esquema
**Objetivo**: Documentar el diseño de la base de datos.

```sql
-- Comentarios en tablas
ALTER TABLE mesas COMMENT = 'Tabla que almacena información de las mesas del restaurante';
ALTER TABLE clientes COMMENT = 'Información de clientes que realizan reservas';
ALTER TABLE reservas COMMENT = 'Registro de reservas realizadas por clientes';

-- Comentarios en columnas
ALTER TABLE mesas MODIFY COLUMN capacidad INT NOT NULL COMMENT 'Número máximo de personas que puede acomodar la mesa';
ALTER TABLE reservas MODIFY COLUMN numero_personas INT COMMENT 'Cantidad de personas para la reserva';
```

### Ejercicio 9: Validación de Integridad
**Objetivo**: Crear triggers para validar reglas de negocio.

```sql
-- Trigger para validar capacidad de mesa
DELIMITER //
CREATE TRIGGER validar_capacidad_mesa
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE capacidad_mesa INT;
    
    SELECT capacidad INTO capacidad_mesa
    FROM mesas
    WHERE id = NEW.mesa_id;
    
    IF NEW.numero_personas > capacidad_mesa THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El número de personas excede la capacidad de la mesa';
    END IF;
END//
DELIMITER ;
```

### Ejercicio 10: Caso de Estudio Completo
**Objetivo**: Diseñar esquema completo para sistema de gestión de inventario.

```sql
-- Base de datos de inventario
CREATE DATABASE inventario_db;
USE inventario_db;

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT,
    proveedor_id INT,
    precio_compra DECIMAL(10,2),
    precio_venta DECIMAL(10,2),
    stock_minimo INT DEFAULT 0,
    stock_actual INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

-- Tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    cantidad INT NOT NULL,
    motivo VARCHAR(200),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable VARCHAR(100),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Índices para optimización
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_proveedor ON productos(proveedor_id);
CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento);
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Diseño de Bases de Datos**: Proceso de crear esquemas eficientes
2. **Redundancia**: Problema de datos duplicados
3. **Anomalías**: Inconsistencias por mal diseño
4. **Fases del Diseño**: Análisis, conceptual, lógico, físico
5. **Herramientas**: MySQL Workbench, DBeaver
6. **Metodologías**: Top-down y Bottom-up

### Próximos Pasos:
- Aprender modelado entidad-relación
- Estudiar normalización de bases de datos
- Practicar con casos reales de diseño

### Recursos Adicionales:
- Documentación MySQL sobre diseño
- Herramientas de modelado visual
- Casos de estudio de empresas reales
