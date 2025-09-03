# Clase 8: Mejores Prácticas de Administración

## Objetivos de la Clase
- Aprender las mejores prácticas de administración de bases de datos
- Entender la importancia de la seguridad en bases de datos
- Conocer estrategias de backup y recuperación
- Aprender técnicas de monitoreo y optimización
- Implementar políticas de mantenimiento preventivo

## Introducción a las Mejores Prácticas

Las **mejores prácticas de administración** son un conjunto de procedimientos, políticas y técnicas que garantizan el funcionamiento óptimo, seguro y confiable de los sistemas de bases de datos.

### Áreas principales:
- **Seguridad**: Protección de datos y acceso
- **Backup y Recuperación**: Estrategias de respaldo
- **Monitoreo**: Supervisión del rendimiento
- **Mantenimiento**: Tareas preventivas
- **Documentación**: Registro de configuraciones

## Seguridad de Bases de Datos

### 1. Gestión de Usuarios y Permisos

#### Principio de Menor Privilegio
```sql
-- ❌ MAL: Otorgar permisos excesivos
GRANT ALL PRIVILEGES ON *.* TO 'usuario'@'%';

-- ✅ BIEN: Otorgar solo permisos necesarios
CREATE USER 'desarrollador'@'localhost' IDENTIFIED BY 'password_seguro';
GRANT SELECT, INSERT, UPDATE ON base_datos.tabla TO 'desarrollador'@'localhost';
GRANT CREATE TEMPORARY TABLES ON base_datos.* TO 'desarrollador'@'localhost';
```

#### Roles y Grupos
```sql
-- Crear roles específicos
CREATE ROLE 'lectura_datos';
CREATE ROLE 'escritura_datos';
CREATE ROLE 'administracion_esquema';

-- Asignar permisos a roles
GRANT SELECT ON base_datos.* TO 'lectura_datos';
GRANT INSERT, UPDATE, DELETE ON base_datos.* TO 'escritura_datos';
GRANT CREATE, DROP, ALTER ON base_datos.* TO 'administracion_esquema';

-- Asignar roles a usuarios
GRANT 'lectura_datos' TO 'usuario_consulta';
GRANT 'escritura_datos' TO 'usuario_aplicacion';
```

### 2. Encriptación de Datos

#### Encriptación en Tránsito
```sql
-- Configurar SSL/TLS
-- MySQL
[mysqld]
ssl-ca=/path/to/ca-cert.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem

-- PostgreSQL
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

#### Encriptación en Reposo
```sql
-- MySQL: Encriptación de tablas
CREATE TABLE datos_sensibles (
    id INT PRIMARY KEY,
    datos_encriptados VARBINARY(255)
) ENGINE=InnoDB ENCRYPTION='Y';

-- PostgreSQL: Encriptación de columnas
CREATE EXTENSION pgcrypto;
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    password_hash TEXT,
    datos_sensibles BYTEA
);

-- Encriptar datos al insertar
INSERT INTO usuarios (password_hash, datos_sensibles) 
VALUES (crypt('password', gen_salt('bf')), pgp_sym_encrypt('datos', 'clave'));
```

### 3. Auditoría y Logging

#### Configuración de Logs de Auditoría
```sql
-- MySQL: Habilitar audit log
[mysqld]
audit_log = ON
audit_log_file = /var/log/mysql/audit.log
audit_log_policy = ALL

-- PostgreSQL: Configurar logging
log_statement = 'all'
log_min_duration_statement = 0
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

## Backup y Recuperación

### 1. Estrategias de Backup

#### Backup Completo
```bash
# MySQL
mysqldump --single-transaction --routines --triggers --all-databases > backup_completo.sql

# PostgreSQL
pg_dumpall -h localhost -U postgres > backup_completo.sql

# SQL Server
sqlcmd -S localhost -Q "BACKUP DATABASE [base_datos] TO DISK = 'C:\backup\backup_completo.bak'"

# Oracle
expdp system/password@ORCL full=y directory=backup_dir dumpfile=backup_completo.dmp
```

#### Backup Incremental
```bash
# MySQL: Binary Log Backup
mysqlbinlog --start-datetime="2024-01-01 00:00:00" mysql-bin.000001 > incremental_backup.sql

# PostgreSQL: WAL Archiving
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
```

### 2. Automatización de Backups

#### Script de Backup Automatizado
```bash
#!/bin/bash
# backup_automatizado.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/mysql"
DB_NAME="base_datos"
USER="backup_user"
PASSWORD="backup_password"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Backup completo
mysqldump --single-transaction --routines --triggers \
    -u $USER -p$PASSWORD $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Comprimir backup
gzip $BACKUP_DIR/backup_$DATE.sql

# Eliminar backups antiguos (más de 30 días)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete

# Log del proceso
echo "$(date): Backup completado - backup_$DATE.sql.gz" >> /var/log/backup.log
```

### 3. Pruebas de Recuperación

#### Procedimiento de Recuperación
```sql
-- Crear procedimiento de prueba de recuperación
DELIMITER //
CREATE PROCEDURE prueba_recuperacion()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Crear base de datos de prueba
    CREATE DATABASE IF NOT EXISTS prueba_recuperacion;
    USE prueba_recuperacion;
    
    -- Crear tabla de prueba
    CREATE TABLE datos_prueba (
        id INT PRIMARY KEY,
        datos TEXT,
        fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Insertar datos de prueba
    INSERT INTO datos_prueba (id, datos) VALUES 
    (1, 'Datos de prueba 1'),
    (2, 'Datos de prueba 2');
    
    -- Verificar datos
    SELECT COUNT(*) as total_registros FROM datos_prueba;
    
    -- Limpiar
    DROP DATABASE prueba_recuperacion;
    
    COMMIT;
    
    SELECT 'Prueba de recuperación exitosa' as resultado;
END //
DELIMITER ;
```

## Monitoreo y Rendimiento

### 1. Métricas Clave a Monitorear

#### Métricas de Sistema
```sql
-- Crear tabla de métricas
CREATE TABLE metricas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(15,2),
    unidad VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE recopilar_metricas()
BEGIN
    -- Conexiones activas
    INSERT INTO metricas_sistema (metrica, valor, unidad)
    SELECT 'conexiones_activas', COUNT(*), 'conexiones'
    FROM information_schema.PROCESSLIST;
    
    -- Consultas por segundo
    INSERT INTO metricas_sistema (metrica, valor, unidad)
    SELECT 'consultas_por_segundo', VARIABLE_VALUE, 'qps'
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Queries';
    
    -- Uso de memoria
    INSERT INTO metricas_sistema (metrica, valor, unidad)
    SELECT 'memoria_innodb', VARIABLE_VALUE, 'bytes'
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data';
END //
DELIMITER ;
```

### 2. Alertas Automáticas

#### Sistema de Alertas
```sql
-- Crear tabla de alertas
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(50) NOT NULL,
    descripcion TEXT,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE
);

-- Procedimiento para verificar alertas
DELIMITER //
CREATE PROCEDURE verificar_alertas()
BEGIN
    DECLARE v_conexiones INT;
    DECLARE v_consultas_lentas INT;
    
    -- Verificar conexiones excesivas
    SELECT COUNT(*) INTO v_conexiones FROM information_schema.PROCESSLIST;
    IF v_conexiones > 80 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, severidad)
        VALUES ('CONEXIONES_ALTAS', CONCAT('Número de conexiones: ', v_conexiones), 'ALTA');
    END IF;
    
    -- Verificar consultas lentas
    SELECT COUNT(*) INTO v_consultas_lentas 
    FROM information_schema.PROCESSLIST 
    WHERE TIME > 30;
    
    IF v_consultas_lentas > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, severidad)
        VALUES ('CONSULTAS_LENTAS', CONCAT('Consultas lentas: ', v_consultas_lentas), 'MEDIA');
    END IF;
END //
DELIMITER ;
```

## Mantenimiento Preventivo

### 1. Tareas de Mantenimiento Regular

#### Script de Mantenimiento
```sql
-- Procedimiento de mantenimiento semanal
DELIMITER //
CREATE PROCEDURE mantenimiento_semanal()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Optimizar tablas
    OPTIMIZE TABLE tabla1, tabla2, tabla3;
    
    -- Analizar tablas
    ANALYZE TABLE tabla1, tabla2, tabla3;
    
    -- Verificar tablas
    CHECK TABLE tabla1, tabla2, tabla3;
    
    -- Limpiar logs antiguos
    DELETE FROM metricas_sistema 
    WHERE fecha_registro < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Limpiar alertas resueltas antiguas
    DELETE FROM alertas_sistema 
    WHERE resuelta = TRUE 
    AND fecha_alerta < DATE_SUB(NOW(), INTERVAL 7 DAY);
    
    COMMIT;
    
    SELECT 'Mantenimiento semanal completado' as resultado;
END //
DELIMITER ;
```

### 2. Actualizaciones y Parches

#### Política de Actualizaciones
```sql
-- Crear tabla de versiones
CREATE TABLE versiones_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    componente VARCHAR(100) NOT NULL,
    version_actual VARCHAR(50),
    version_disponible VARCHAR(50),
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    requiere_actualizacion BOOLEAN DEFAULT FALSE
);

-- Procedimiento para verificar actualizaciones
DELIMITER //
CREATE PROCEDURE verificar_actualizaciones()
BEGIN
    -- Verificar versión de MySQL
    INSERT INTO versiones_sistema (componente, version_actual, version_disponible)
    VALUES ('MySQL', VERSION(), '8.0.35')
    ON DUPLICATE KEY UPDATE 
        version_actual = VERSION(),
        fecha_verificacion = CURRENT_TIMESTAMP,
        requiere_actualizacion = (VERSION() < '8.0.35');
END //
DELIMITER ;
```

## Documentación y Procedimientos

### 1. Documentación de Configuración

#### Tabla de Configuraciones
```sql
-- Crear tabla de documentación
CREATE TABLE documentacion_configuracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    componente VARCHAR(100) NOT NULL,
    parametro VARCHAR(100) NOT NULL,
    valor_actual TEXT,
    valor_recomendado TEXT,
    descripcion TEXT,
    fecha_documentacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsable VARCHAR(100)
);

-- Insertar configuraciones importantes
INSERT INTO documentacion_configuracion (componente, parametro, valor_actual, valor_recomendado, descripcion, responsable) VALUES
('MySQL', 'max_connections', '100', '200-500', 'Número máximo de conexiones simultáneas', 'DBA Team'),
('MySQL', 'innodb_buffer_pool_size', '128M', '70% de RAM', 'Tamaño del buffer pool de InnoDB', 'DBA Team'),
('MySQL', 'slow_query_log', 'ON', 'ON', 'Habilitar log de consultas lentas', 'DBA Team');
```

### 2. Procedimientos de Emergencia

#### Procedimiento de Emergencia
```sql
-- Crear tabla de procedimientos
CREATE TABLE procedimientos_emergencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_emergencia VARCHAR(100) NOT NULL,
    pasos TEXT,
    contactos TEXT,
    tiempo_estimado VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar procedimientos
INSERT INTO procedimientos_emergencia (tipo_emergencia, pasos, contactos, tiempo_estimado) VALUES
('CAIDA_SERVIDOR', 
 '1. Verificar estado del servidor\n2. Revisar logs de error\n3. Iniciar procedimiento de recuperación\n4. Notificar a usuarios', 
 'DBA: +1234567890\nSistemas: +0987654321', 
 '30 minutos'),
('PERDIDA_DATOS', 
 '1. Detener aplicaciones\n2. Evaluar daños\n3. Restaurar desde backup\n4. Verificar integridad\n5. Reanudar servicios', 
 'DBA: +1234567890\nDesarrollo: +1122334455', 
 '2-4 horas');
```

## Ejercicios Prácticos

### Ejercicio 1: Implementación de Seguridad
```sql
-- Crear estructura de seguridad
CREATE DATABASE seguridad_db;
USE seguridad_db;

-- Crear tabla de usuarios
CREATE TABLE usuarios_seguridad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL
);

-- Crear tabla de roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Crear tabla de permisos
CREATE TABLE permisos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Crear tabla de asignación de roles
CREATE TABLE usuario_roles (
    usuario_id INT,
    rol_id INT,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios_seguridad(id),
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);
```

### Ejercicio 2: Sistema de Backup
```sql
-- Crear tabla de backups
CREATE TABLE registro_backups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL') NOT NULL,
    base_datos VARCHAR(100) NOT NULL,
    archivo_backup VARCHAR(255) NOT NULL,
    tamaño_bytes BIGINT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    estado ENUM('EN_PROGRESO', 'COMPLETADO', 'FALLIDO') DEFAULT 'EN_PROGRESO',
    ubicacion VARCHAR(255)
);

-- Procedimiento para registrar backup
DELIMITER //
CREATE PROCEDURE registrar_backup(
    IN p_tipo ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    IN p_base_datos VARCHAR(100),
    IN p_archivo VARCHAR(255),
    IN p_ubicacion VARCHAR(255)
)
BEGIN
    INSERT INTO registro_backups (tipo_backup, base_datos, archivo_backup, ubicacion, fecha_inicio)
    VALUES (p_tipo, p_base_datos, p_archivo, p_ubicacion, NOW());
    
    SELECT LAST_INSERT_ID() as backup_id;
END //
DELIMITER ;
```

### Ejercicio 3: Monitoreo de Rendimiento
```sql
-- Crear tabla de métricas de rendimiento
CREATE TABLE metricas_rendimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(15,4),
    unidad VARCHAR(20),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidor VARCHAR(100) DEFAULT 'localhost'
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE recopilar_metricas_rendimiento()
BEGIN
    -- Conexiones activas
    INSERT INTO metricas_rendimiento (metrica, valor, unidad)
    SELECT 'conexiones_activas', COUNT(*), 'conexiones'
    FROM information_schema.PROCESSLIST;
    
    -- Consultas por segundo
    INSERT INTO metricas_rendimiento (metrica, valor, unidad)
    SELECT 'consultas_por_segundo', VARIABLE_VALUE, 'qps'
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Queries';
    
    -- Tiempo de respuesta promedio
    INSERT INTO metricas_rendimiento (metrica, valor, unidad)
    SELECT 'tiempo_respuesta_promedio', 
           AVG(TIME), 'segundos'
    FROM information_schema.PROCESSLIST 
    WHERE COMMAND = 'Query';
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Alertas
```sql
-- Crear tabla de alertas
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP NULL,
    resuelta_por VARCHAR(100)
);

-- Procedimiento para crear alertas
DELIMITER //
CREATE PROCEDURE crear_alerta(
    IN p_tipo VARCHAR(50),
    IN p_severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA'),
    IN p_mensaje TEXT
)
BEGIN
    INSERT INTO alertas_sistema (tipo_alerta, severidad, mensaje)
    VALUES (p_tipo, p_severidad, p_mensaje);
    
    SELECT LAST_INSERT_ID() as alerta_id;
END //
DELIMITER ;
```

### Ejercicio 5: Mantenimiento Automatizado
```sql
-- Crear tabla de tareas de mantenimiento
CREATE TABLE tareas_mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tarea VARCHAR(100) NOT NULL,
    descripcion TEXT,
    frecuencia ENUM('DIARIA', 'SEMANAL', 'MENSUAL') NOT NULL,
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP NULL,
    activa BOOLEAN DEFAULT TRUE
);

-- Insertar tareas de mantenimiento
INSERT INTO tareas_mantenimiento (nombre_tarea, descripcion, frecuencia, proxima_ejecucion) VALUES
('Optimización de Tablas', 'Optimizar tablas principales', 'SEMANAL', DATE_ADD(NOW(), INTERVAL 1 WEEK)),
('Limpieza de Logs', 'Eliminar logs antiguos', 'DIARIA', DATE_ADD(NOW(), INTERVAL 1 DAY)),
('Verificación de Integridad', 'Verificar integridad de datos', 'MENSUAL', DATE_ADD(NOW(), INTERVAL 1 MONTH));

-- Procedimiento para ejecutar mantenimiento
DELIMITER //
CREATE PROCEDURE ejecutar_mantenimiento()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion TEXT;
    
    DECLARE cur CURSOR FOR 
        SELECT id, nombre_tarea, descripcion 
        FROM tareas_mantenimiento 
        WHERE activa = TRUE 
        AND proxima_ejecucion <= NOW();
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_id, v_nombre, v_descripcion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Ejecutar tarea específica
        CASE v_nombre
            WHEN 'Optimización de Tablas' THEN
                OPTIMIZE TABLE tabla1, tabla2;
            WHEN 'Limpieza de Logs' THEN
                DELETE FROM metricas_rendimiento 
                WHERE fecha_medicion < DATE_SUB(NOW(), INTERVAL 30 DAY);
        END CASE;
        
        -- Actualizar próxima ejecución
        UPDATE tareas_mantenimiento 
        SET ultima_ejecucion = NOW(),
            proxima_ejecucion = CASE frecuencia
                WHEN 'DIARIA' THEN DATE_ADD(NOW(), INTERVAL 1 DAY)
                WHEN 'SEMANAL' THEN DATE_ADD(NOW(), INTERVAL 1 WEEK)
                WHEN 'MENSUAL' THEN DATE_ADD(NOW(), INTERVAL 1 MONTH)
            END
        WHERE id = v_id;
        
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 6: Auditoría de Accesos
```sql
-- Crear tabla de auditoría
CREATE TABLE auditoria_accesos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    accion VARCHAR(100),
    tabla_afectada VARCHAR(100),
    registro_id INT,
    datos_anteriores JSON,
    datos_nuevos JSON,
    ip_address VARCHAR(45),
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para auditoría de usuarios
DELIMITER //
CREATE TRIGGER audit_usuarios_seguridad
AFTER UPDATE ON usuarios_seguridad
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_accesos (usuario, accion, tabla_afectada, registro_id, datos_anteriores, datos_nuevos)
    VALUES (
        USER(),
        'UPDATE',
        'usuarios_seguridad',
        NEW.id,
        JSON_OBJECT('username', OLD.username, 'email', OLD.email, 'activo', OLD.activo),
        JSON_OBJECT('username', NEW.username, 'email', NEW.email, 'activo', NEW.activo)
    );
END //
DELIMITER ;
```

### Ejercicio 7: Análisis de Rendimiento
```sql
-- Crear vista de análisis de rendimiento
CREATE VIEW analisis_rendimiento AS
SELECT 
    DATE(fecha_medicion) as fecha,
    metrica,
    AVG(valor) as valor_promedio,
    MIN(valor) as valor_minimo,
    MAX(valor) as valor_maximo,
    COUNT(*) as mediciones
FROM metricas_rendimiento
WHERE fecha_medicion >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(fecha_medicion), metrica
ORDER BY fecha DESC, metrica;

-- Consultar análisis
SELECT * FROM analisis_rendimiento;
```

### Ejercicio 8: Reporte de Estado del Sistema
```sql
-- Procedimiento para reporte de estado
DELIMITER //
CREATE PROCEDURE reporte_estado_sistema()
BEGIN
    SELECT '=== REPORTE DE ESTADO DEL SISTEMA ===' as titulo;
    
    -- Estado de conexiones
    SELECT 'Conexiones Activas' as seccion;
    SELECT 
        COUNT(*) as total_conexiones,
        COUNT(CASE WHEN COMMAND = 'Query' THEN 1 END) as consultas_activas,
        COUNT(CASE WHEN TIME > 30 THEN 1 END) as consultas_lentas
    FROM information_schema.PROCESSLIST;
    
    -- Estado de alertas
    SELECT 'Alertas Pendientes' as seccion;
    SELECT 
        severidad,
        COUNT(*) as cantidad
    FROM alertas_sistema 
    WHERE resuelta = FALSE
    GROUP BY severidad;
    
    -- Estado de backups
    SELECT 'Últimos Backups' as seccion;
    SELECT 
        tipo_backup,
        base_datos,
        fecha_fin,
        estado
    FROM registro_backups 
    ORDER BY fecha_fin DESC 
    LIMIT 5;
END //
DELIMITER ;
```

### Ejercicio 9: Política de Retención de Datos
```sql
-- Crear tabla de políticas de retención
CREATE TABLE politicas_retencion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_dato VARCHAR(100) NOT NULL,
    periodo_retencion_dias INT NOT NULL,
    accion ENUM('ELIMINAR', 'ARCHIVAR', 'COMPRIMIR') NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar políticas
INSERT INTO politicas_retencion (tipo_dato, periodo_retencion_dias, accion) VALUES
('logs_auditoria', 90, 'ELIMINAR'),
('metricas_rendimiento', 30, 'ARCHIVAR'),
('backups', 365, 'COMPRIMIR'),
('alertas_resueltas', 30, 'ELIMINAR');

-- Procedimiento para aplicar políticas
DELIMITER //
CREATE PROCEDURE aplicar_politicas_retencion()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tipo VARCHAR(100);
    DECLARE v_periodo INT;
    DECLARE v_accion ENUM('ELIMINAR', 'ARCHIVAR', 'COMPRIMIR');
    
    DECLARE cur CURSOR FOR 
        SELECT tipo_dato, periodo_retencion_dias, accion 
        FROM politicas_retencion 
        WHERE activa = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tipo, v_periodo, v_accion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        CASE v_tipo
            WHEN 'logs_auditoria' THEN
                IF v_accion = 'ELIMINAR' THEN
                    DELETE FROM auditoria_accesos 
                    WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL v_periodo DAY);
                END IF;
            WHEN 'metricas_rendimiento' THEN
                IF v_accion = 'ARCHIVAR' THEN
                    -- Crear tabla de archivo si no existe
                    CREATE TABLE IF NOT EXISTS metricas_rendimiento_archivo 
                    LIKE metricas_rendimiento;
                    
                    -- Mover datos antiguos
                    INSERT INTO metricas_rendimiento_archivo 
                    SELECT * FROM metricas_rendimiento 
                    WHERE fecha_medicion < DATE_SUB(NOW(), INTERVAL v_periodo DAY);
                    
                    DELETE FROM metricas_rendimiento 
                    WHERE fecha_medicion < DATE_SUB(NOW(), INTERVAL v_periodo DAY);
                END IF;
        END CASE;
        
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 10: Dashboard de Administración
```sql
-- Crear vista de dashboard
CREATE VIEW dashboard_administracion AS
SELECT 
    'Conexiones' as categoria,
    COUNT(*) as valor_actual,
    'conexiones' as unidad,
    CASE 
        WHEN COUNT(*) > 80 THEN 'ALTA'
        WHEN COUNT(*) > 50 THEN 'MEDIA'
        ELSE 'BAJA'
    END as estado
FROM information_schema.PROCESSLIST
UNION ALL
SELECT 
    'Alertas Pendientes',
    COUNT(*),
    'alertas',
    CASE 
        WHEN COUNT(*) > 10 THEN 'ALTA'
        WHEN COUNT(*) > 5 THEN 'MEDIA'
        ELSE 'BAJA'
    END
FROM alertas_sistema 
WHERE resuelta = FALSE
UNION ALL
SELECT 
    'Backups Exitosos (7 días)',
    COUNT(*),
    'backups',
    CASE 
        WHEN COUNT(*) >= 7 THEN 'ALTA'
        WHEN COUNT(*) >= 3 THEN 'MEDIA'
        ELSE 'BAJA'
    END
FROM registro_backups 
WHERE estado = 'COMPLETADO' 
AND fecha_fin >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Consultar dashboard
SELECT * FROM dashboard_administracion;
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Mejores prácticas de seguridad en bases de datos
- Estrategias de backup y recuperación
- Técnicas de monitoreo y alertas
- Mantenimiento preventivo automatizado
- Documentación y procedimientos de emergencia
- Implementación de políticas de retención
- Creación de dashboards de administración

## Próxima Clase
[Clase 9: Migración entre SGBD](clase_9_migracion_sgbd.md)

## Recursos Adicionales
- [MySQL Security Best Practices](https://dev.mysql.com/doc/refman/8.0/en/security.html)
- [PostgreSQL Security](https://www.postgresql.org/docs/current/security.html)
- [SQL Server Security](https://docs.microsoft.com/en-us/sql/relational-databases/security/)
- [Oracle Database Security](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/)
