# Clase 8: Backup y Recuperación

## 📋 Descripción

En esta clase aprenderás sobre las estrategias de backup y recuperación en MySQL. La protección de datos es fundamental para cualquier sistema de base de datos. Aprenderás diferentes tipos de respaldos, herramientas de backup, estrategias de recuperación y mejores prácticas para mantener la integridad de los datos.

## 🎯 Objetivos de la Clase

- Comprender la importancia del backup y recuperación
- Aprender diferentes tipos de respaldos
- Dominar las herramientas de backup de MySQL
- Implementar estrategias de recuperación
- Configurar respaldos automáticos
- Manejar situaciones de desastre

## 📚 Conceptos Clave

### ¿Qué es un Backup?

Un **backup** (respaldo) es una copia de seguridad de los datos de la base de datos que se utiliza para restaurar la información en caso de pérdida, corrupción o fallo del sistema.

### Tipos de Backup

1. **Backup Completo**: Copia completa de toda la base de datos
2. **Backup Incremental**: Solo los cambios desde el último backup
3. **Backup Diferencial**: Cambios desde el último backup completo
4. **Backup de Transacciones**: Solo los logs de transacciones

### Estrategias de Backup

- **3-2-1 Rule**: 3 copias, 2 medios diferentes, 1 fuera del sitio
- **Backup Automático**: Respaldos programados
- **Backup en Caliente**: Sin interrumpir el servicio
- **Backup en Frío**: Con el servicio detenido

## 🔧 Sintaxis y Comandos

### mysqldump - Backup Lógico

```sql
-- Backup completo de una base de datos
mysqldump -u usuario -p base_datos > backup.sql

-- Backup de múltiples bases de datos
mysqldump -u usuario -p --all-databases > backup_completo.sql

-- Backup con opciones específicas
mysqldump -u usuario -p --single-transaction --routines --triggers base_datos > backup.sql
```

### mysql - Restauración

```sql
-- Restaurar desde backup
mysql -u usuario -p base_datos < backup.sql

-- Restaurar base de datos completa
mysql -u usuario -p < backup_completo.sql
```

### Comandos de Backup en MySQL

```sql
-- Iniciar backup en caliente
FLUSH TABLES WITH READ LOCK;
-- Realizar backup
UNLOCK TABLES;

-- Verificar estado de binlog
SHOW MASTER STATUS;
SHOW BINARY LOGS;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Backup Básico con mysqldump

```sql
-- Crear base de datos de ejemplo
CREATE DATABASE tienda_backup;
USE tienda_backup;

-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, precio, stock) VALUES 
('Laptop', 999.99, 10),
('Mouse', 25.50, 50),
('Teclado', 75.00, 30);

-- Realizar backup básico
-- Comando: mysqldump -u root -p tienda_backup > backup_tienda.sql
```

**Explicación línea por línea:**

1. `CREATE DATABASE tienda_backup;` - Crea la base de datos para el ejemplo
2. `CREATE TABLE productos (...)` - Crea tabla con estructura básica
3. `INSERT INTO productos (...)` - Inserta datos de ejemplo
4. `mysqldump -u root -p tienda_backup > backup_tienda.sql` - Comando para realizar backup

### Ejemplo 2: Backup con Opciones Avanzadas

```sql
-- Backup con opciones específicas
-- Comando: mysqldump -u root -p --single-transaction --routines --triggers --events tienda_backup > backup_avanzado.sql

-- Verificar el contenido del backup
-- Comando: head -20 backup_avanzado.sql
```

### Ejemplo 3: Backup de Solo Estructura

```sql
-- Backup solo de la estructura (sin datos)
-- Comando: mysqldump -u root -p --no-data tienda_backup > estructura_tienda.sql

-- Backup solo de los datos (sin estructura)
-- Comando: mysqldump -u root -p --no-create-info tienda_backup > datos_tienda.sql
```

### Ejemplo 4: Backup de Tablas Específicas

```sql
-- Backup de tablas específicas
-- Comando: mysqldump -u root -p tienda_backup productos > backup_productos.sql

-- Backup de múltiples tablas
-- Comando: mysqldump -u root -p tienda_backup productos categorias > backup_tablas.sql
```

### Ejemplo 5: Restauración de Backup

```sql
-- Crear nueva base de datos para restauración
CREATE DATABASE tienda_restaurada;

-- Restaurar desde backup
-- Comando: mysql -u root -p tienda_restaurada < backup_tienda.sql

-- Verificar restauración
USE tienda_restaurada;
SELECT * FROM productos;
```

### Ejemplo 6: Backup con Compresión

```sql
-- Backup con compresión
-- Comando: mysqldump -u root -p tienda_backup | gzip > backup_tienda.sql.gz

-- Restaurar desde backup comprimido
-- Comando: gunzip < backup_tienda.sql.gz | mysql -u root -p tienda_restaurada
```

### Ejemplo 7: Backup Incremental con Binlog

```sql
-- Habilitar binlog si no está habilitado
-- En my.cnf: log-bin=mysql-bin

-- Verificar estado del binlog
SHOW MASTER STATUS;

-- Realizar backup completo
-- Comando: mysqldump -u root -p --master-data=2 --single-transaction tienda_backup > backup_completo.sql

-- Realizar backup incremental
-- Comando: mysqlbinlog mysql-bin.000001 > backup_incremental.sql
```

### Ejemplo 8: Backup Automático con Script

```sql
-- Crear script de backup automático
-- Archivo: backup_automatico.sh

#!/bin/bash
# Configuración
DB_NAME="tienda_backup"
DB_USER="root"
DB_PASS="password"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Crear directorio de backup si no existe
mkdir -p $BACKUP_DIR

# Realizar backup
mysqldump -u $DB_USER -p$DB_PASS --single-transaction --routines --triggers $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Comprimir backup
gzip $BACKUP_DIR/backup_$DATE.sql

# Eliminar backups antiguos (más de 7 días)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completado: backup_$DATE.sql.gz"
```

### Ejemplo 9: Backup de Procedimientos y Funciones

```sql
-- Crear procedimiento de ejemplo
DELIMITER //
CREATE PROCEDURE ObtenerProductos()
BEGIN
    SELECT * FROM productos;
END //
DELIMITER ;

-- Crear función de ejemplo
DELIMITER //
CREATE FUNCTION CalcularTotal(cantidad INT, precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN cantidad * precio;
END //
DELIMITER ;

-- Backup incluyendo procedimientos y funciones
-- Comando: mysqldump -u root -p --routines --triggers tienda_backup > backup_con_rutinas.sql
```

### Ejemplo 10: Estrategia de Backup Completa

```sql
-- Crear tabla de control de backups
CREATE TABLE control_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup VARCHAR(50),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo_backup VARCHAR(255),
    tamaño_archivo BIGINT,
    estado VARCHAR(20) DEFAULT 'COMPLETADO'
);

-- Procedimiento para registrar backup
DELIMITER //
CREATE PROCEDURE RegistrarBackup(
    IN tipo VARCHAR(50),
    IN archivo VARCHAR(255),
    IN tamaño BIGINT
)
BEGIN
    INSERT INTO control_backups (tipo_backup, archivo_backup, tamaño_archivo)
    VALUES (tipo, archivo, tamaño);
END //
DELIMITER ;

-- Script de backup completo
-- Archivo: backup_completo.sh

#!/bin/bash
DB_NAME="tienda_backup"
DB_USER="root"
DB_PASS="password"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup completo
mysqldump -u $DB_USER -p$DB_PASS --single-transaction --routines --triggers --events $DB_NAME > $BACKUP_DIR/backup_completo_$DATE.sql

# Comprimir
gzip $BACKUP_DIR/backup_completo_$DATE.sql

# Obtener tamaño del archivo
SIZE=$(stat -c%s $BACKUP_DIR/backup_completo_$DATE.sql.gz)

# Registrar en base de datos
mysql -u $DB_USER -p$DB_PASS -e "CALL tienda_backup.RegistrarBackup('COMPLETO', 'backup_completo_$DATE.sql.gz', $SIZE);"

echo "Backup completo realizado: backup_completo_$DATE.sql.gz"
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Backup Básico
Crea un backup básico de una base de datos con datos de ejemplo.

### Ejercicio 2: Backup con Opciones
Implementa un backup con opciones avanzadas de mysqldump.

### Ejercicio 3: Restauración de Datos
Crea un backup y restaura los datos en una nueva base de datos.

### Ejercicio 4: Backup de Estructura
Implementa un backup que incluya solo la estructura de las tablas.

### Ejercicio 5: Backup Incremental
Crea un sistema de backup incremental usando binlog.

### Ejercicio 6: Backup Automático
Implementa un script de backup automático con programación.

### Ejercicio 7: Backup con Compresión
Crea un sistema de backup con compresión automática.

### Ejercicio 8: Backup de Procedimientos
Implementa un backup que incluya procedimientos y funciones.

### Ejercicio 9: Estrategia de Backup
Crea una estrategia completa de backup con múltiples tipos.

### Ejercicio 10: Recuperación de Desastre
Implementa un plan de recuperación ante desastres.

## 📝 Resumen

En esta clase has aprendido:

- **Tipos de backup**: Completo, incremental, diferencial
- **Herramientas**: mysqldump, mysql, mysqlbinlog
- **Estrategias**: 3-2-1 rule, backup automático
- **Restauración**: Diferentes métodos de recuperación
- **Automatización**: Scripts y programación de backups
- **Monitoreo**: Control y verificación de backups

## 🔗 Próximos Pasos

- [Clase 9: Monitoreo y Optimización](clase_9_monitoreo_optimizacion.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 8!** 🎉 Continúa con la siguiente clase para aprender sobre monitoreo y optimización.
