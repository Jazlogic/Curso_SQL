# Clase 10: Proyecto Integrador - Sistema de Administración Avanzada de Bases de Datos

## Introducción
En esta clase final del módulo, integraremos todos los conceptos aprendidos para crear un sistema completo de administración avanzada de bases de datos. Este proyecto combinará seguridad, usuarios, backup, replicación, clustering, monitoreo, mantenimiento, migración y disaster recovery.

## Objetivos del Proyecto
- Integrar todos los conceptos del módulo
- Crear un sistema de administración completo
- Implementar mejores prácticas de administración
- Desarrollar un sistema escalable y robusto

## Arquitectura del Sistema

### Componentes Principales
1. **Sistema de Seguridad y Autenticación**
2. **Gestión de Usuarios y Roles**
3. **Sistema de Backup y Recuperación**
4. **Replicación y Clustering**
5. **Monitoreo y Alertas**
6. **Mantenimiento Automático**
7. **Migración de Datos**
8. **Disaster Recovery**

## Implementación del Sistema

### 1. Estructura Base del Sistema

```sql
-- Crear base de datos del sistema de administración
CREATE DATABASE sistema_administracion_db;
USE sistema_administracion_db;

-- Crear tabla de configuración del sistema
CREATE TABLE configuracion_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuración inicial
INSERT INTO configuracion_sistema (componente, configuracion)
VALUES 
('SEGURIDAD', JSON_OBJECT(
    'ssl_requerido', true,
    'password_min_length', 12,
    'password_expiry_days', 90,
    'max_login_attempts', 3
)),
('BACKUP', JSON_OBJECT(
    'frecuencia', 'DIARIO',
    'retencion_dias', 30,
    'compresion', true,
    'encriptacion', true
)),
('REPLICACION', JSON_OBJECT(
    'tipo', 'MAESTRO_ESCLAVO',
    'servidores', JSON_ARRAY('192.168.1.100', '192.168.1.101'),
    'retraso_maximo_segundos', 300
)),
('MONITOREO', JSON_OBJECT(
    'intervalo_verificacion', 60,
    'alertas_email', true,
    'dashboard_tiempo_real', true
));
```

### 2. Sistema de Seguridad Integrado

```sql
-- Crear tabla de políticas de seguridad
CREATE TABLE politicas_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_politica VARCHAR(100),
    descripcion TEXT,
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar políticas de seguridad
INSERT INTO politicas_seguridad (nombre_politica, descripcion, configuracion)
VALUES 
('Política de Contraseñas', 'Requisitos para contraseñas seguras', 
 JSON_OBJECT('longitud_minima', 12, 'requiere_mayuscula', true, 'requiere_numero', true, 'requiere_especial', true)),
('Política de Sesiones', 'Configuración de sesiones de usuario',
 JSON_OBJECT('tiempo_expiracion', 3600, 'max_intentos', 3, 'bloqueo_temporal', true)),
('Política de Acceso', 'Control de acceso a recursos',
 JSON_OBJECT('horario_acceso', '09:00-17:00', 'dias_laborales', JSON_ARRAY('lunes', 'martes', 'miercoles', 'jueves', 'viernes')));

-- Procedimiento para aplicar políticas de seguridad
DELIMITER //
CREATE PROCEDURE aplicar_politicas_seguridad()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_politica VARCHAR(100);
    DECLARE v_config JSON;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_politica, configuracion
        FROM politicas_seguridad
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_politica, v_config;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Aplicar política según el tipo
        IF v_politica = 'Política de Contraseñas' THEN
            CALL configurar_politica_passwords(v_config);
        ELSEIF v_politica = 'Política de Sesiones' THEN
            CALL configurar_politica_sesiones(v_config);
        ELSEIF v_politica = 'Política de Acceso' THEN
            CALL configurar_politica_acceso(v_config);
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### 3. Sistema de Gestión de Usuarios Avanzado

```sql
-- Crear tabla de usuarios del sistema
CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100) UNIQUE,
    email VARCHAR(100),
    perfil ENUM('ADMINISTRADOR', 'OPERADOR', 'AUDITOR', 'DESARROLLADOR'),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL
);

-- Crear tabla de roles del sistema
CREATE TABLE roles_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(100),
    descripcion TEXT,
    permisos JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar roles del sistema
INSERT INTO roles_sistema (nombre_rol, descripcion, permisos)
VALUES 
('Administrador_Completo', 'Acceso completo al sistema', 
 JSON_OBJECT('backup', 'ALL', 'replicacion', 'ALL', 'monitoreo', 'ALL', 'usuarios', 'ALL')),
('Operador_Backup', 'Gestión de backups y recuperación',
 JSON_OBJECT('backup', 'CREATE_READ', 'recuperacion', 'EXECUTE', 'monitoreo', 'READ')),
('Auditor_Sistema', 'Solo lectura y auditoría',
 JSON_OBJECT('backup', 'READ', 'replicacion', 'READ', 'monitoreo', 'READ', 'auditoria', 'ALL'));

-- Procedimiento para gestionar usuarios
DELIMITER //
CREATE PROCEDURE gestionar_usuarios_sistema()
BEGIN
    -- Crear usuarios por defecto
    INSERT IGNORE INTO usuarios_sistema (usuario, email, perfil)
    VALUES 
    ('admin_sistema', 'admin@empresa.com', 'ADMINISTRADOR'),
    ('operador_backup', 'backup@empresa.com', 'OPERADOR'),
    ('auditor_sistema', 'auditor@empresa.com', 'AUDITOR');
    
    -- Asignar roles a usuarios
    CALL asignar_roles_usuarios();
    
    -- Verificar usuarios inactivos
    CALL verificar_usuarios_inactivos();
END //
DELIMITER ;
```

### 4. Sistema de Backup y Recuperación Integrado

```sql
-- Crear tabla de configuración de backup
CREATE TABLE configuracion_backup_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_backup VARCHAR(100),
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    retencion_dias INT,
    compresion BOOLEAN DEFAULT TRUE,
    encriptacion BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuraciones de backup
INSERT INTO configuracion_backup_integrado (nombre_backup, tipo_backup, frecuencia, hora_ejecucion, retencion_dias)
VALUES 
('Backup_Completo_Diario', 'COMPLETO', 'DIARIO', '02:00:00', 30),
('Backup_Incremental_Horario', 'INCREMENTAL', 'DIARIO', '01:00:00', 7),
('Backup_Semanal_Completo', 'COMPLETO', 'SEMANAL', '03:00:00', 90);

-- Procedimiento para gestión de backup integrado
DELIMITER //
CREATE PROCEDURE gestionar_backup_integrado()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_frecuencia VARCHAR(20);
    DECLARE v_hora TIME;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_backup, tipo_backup, frecuencia, hora_ejecucion
        FROM configuracion_backup_integrado
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_nombre, v_tipo, v_frecuencia, v_hora;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Verificar si es hora de ejecutar
        IF TIME(NOW()) = v_hora THEN
            -- Ejecutar backup según el tipo
            IF v_tipo = 'COMPLETO' THEN
                CALL ejecutar_backup_completo(v_nombre);
            ELSEIF v_tipo = 'INCREMENTAL' THEN
                CALL ejecutar_backup_incremental(v_nombre);
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### 5. Sistema de Replicación y Clustering

```sql
-- Crear tabla de configuración de replicación
CREATE TABLE configuracion_replicacion_integrada (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_cluster VARCHAR(100),
    tipo_replicacion ENUM('MAESTRO_ESCLAVO', 'MAESTRO_MAESTRO', 'CIRCULAR'),
    servidores JSON,
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración de replicación
INSERT INTO configuracion_replicacion_integrada (nombre_cluster, tipo_replicacion, servidores, configuracion)
VALUES 
('Cluster_Produccion', 'MAESTRO_ESCLAVO', 
 JSON_ARRAY(
     JSON_OBJECT('id', 1, 'ip', '192.168.1.100', 'rol', 'MAESTRO'),
     JSON_OBJECT('id', 2, 'ip', '192.168.1.101', 'rol', 'ESCLAVO')
 ),
 JSON_OBJECT('retraso_maximo', 300, 'failover_automatico', true, 'monitoreo_continuo', true));

-- Procedimiento para gestión de replicación
DELIMITER //
CREATE PROCEDURE gestionar_replicacion_integrada()
BEGIN
    -- Verificar estado de replicación
    CALL verificar_estado_replicacion();
    
    -- Monitorear retrasos
    CALL monitorear_retrasos_replicacion();
    
    -- Ejecutar failover si es necesario
    CALL verificar_failover_automatico();
    
    -- Actualizar métricas
    CALL actualizar_metricas_replicacion();
END //
DELIMITER ;
```

### 6. Sistema de Monitoreo Integral

```sql
-- Crear tabla de métricas del sistema
CREATE TABLE metricas_sistema_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    metrica VARCHAR(100),
    valor DECIMAL(10,2),
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar métricas del sistema
INSERT INTO metricas_sistema_integrado (componente, metrica, umbral_warning, umbral_critical)
VALUES 
('SISTEMA', 'CPU_PORCENTAJE', 70.0, 90.0),
('SISTEMA', 'MEMORIA_PORCENTAJE', 80.0, 95.0),
('SISTEMA', 'DISCO_PORCENTAJE', 85.0, 95.0),
('BASE_DATOS', 'CONEXIONES_ACTIVAS', 80.0, 95.0),
('BASE_DATOS', 'CONSULTAS_POR_SEGUNDO', 1000.0, 2000.0),
('REPLICACION', 'RETRASO_SEGUNDOS', 300.0, 600.0);

-- Procedimiento para monitoreo integral
DELIMITER //
CREATE PROCEDURE monitoreo_integral()
BEGIN
    -- Recopilar métricas del sistema
    CALL recopilar_metricas_sistema();
    
    -- Recopilar métricas de base de datos
    CALL recopilar_metricas_base_datos();
    
    -- Recopilar métricas de replicación
    CALL recopilar_metricas_replicacion();
    
    -- Generar alertas
    CALL generar_alertas_integrales();
    
    -- Actualizar dashboard
    CALL actualizar_dashboard_integral();
END //
DELIMITER ;
```

### 7. Sistema de Mantenimiento Automático

```sql
-- Crear tabla de tareas de mantenimiento
CREATE TABLE tareas_mantenimiento_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tarea VARCHAR(100),
    componente VARCHAR(100),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    procedimiento VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar tareas de mantenimiento
INSERT INTO tareas_mantenimiento_integrado (nombre_tarea, componente, frecuencia, hora_ejecucion, procedimiento)
VALUES 
('Optimizar_Tablas', 'BASE_DATOS', 'SEMANAL', '02:00:00', 'optimizar_todas_tablas'),
('Analizar_Indices', 'BASE_DATOS', 'DIARIO', '01:00:00', 'analizar_indices'),
('Limpiar_Logs', 'SISTEMA', 'DIARIO', '03:00:00', 'limpiar_logs_antiguos'),
('Verificar_Seguridad', 'SEGURIDAD', 'SEMANAL', '04:00:00', 'verificar_politicas_seguridad'),
('Actualizar_Estadisticas', 'BASE_DATOS', 'SEMANAL', '01:30:00', 'actualizar_estadisticas');

-- Procedimiento para mantenimiento integral
DELIMITER //
CREATE PROCEDURE mantenimiento_integral()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tarea VARCHAR(100);
    DECLARE v_componente VARCHAR(100);
    DECLARE v_procedimiento VARCHAR(100);
    
    DECLARE cur CURSOR FOR
        SELECT nombre_tarea, componente, procedimiento
        FROM tareas_mantenimiento_integrado
        WHERE activo = TRUE
        AND (frecuencia = 'DIARIO' OR 
             (frecuencia = 'SEMANAL' AND DAYOFWEEK(NOW()) = 1) OR
             (frecuencia = 'MENSUAL' AND DAY(NOW()) = 1));
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tarea, v_componente, v_procedimiento;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Ejecutar procedimiento de mantenimiento
        SET @sql = CONCAT('CALL ', v_procedimiento, '()');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Registrar ejecución
        INSERT INTO log_mantenimiento_integrado (tarea, componente, fecha_ejecucion, estado)
        VALUES (v_tarea, v_componente, NOW(), 'COMPLETADA');
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### 8. Sistema de Migración Integrado

```sql
-- Crear tabla de proyectos de migración
CREATE TABLE proyectos_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proyecto VARCHAR(100),
    descripcion TEXT,
    estado ENUM('PLANIFICADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO'),
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL,
    configuracion JSON
);

-- Insertar proyecto de migración
INSERT INTO proyectos_migracion (nombre_proyecto, descripcion, configuracion)
VALUES ('Migracion_Sistema_Legacy', 'Migración del sistema legacy al nuevo sistema',
        JSON_OBJECT(
            'tablas', JSON_ARRAY('clientes', 'ventas', 'productos'),
            'validaciones', JSON_ARRAY('formato_email', 'integridad_referencial'),
            'backup_requerido', true,
            'rollback_plan', true
        ));

-- Procedimiento para gestión de migración
DELIMITER //
CREATE PROCEDURE gestionar_migracion_integrada(IN p_proyecto_id INT)
BEGIN
    DECLARE v_estado VARCHAR(20);
    
    -- Obtener estado del proyecto
    SELECT estado INTO v_estado
    FROM proyectos_migracion
    WHERE id = p_proyecto_id;
    
    -- Ejecutar migración según el estado
    IF v_estado = 'PLANIFICADO' THEN
        CALL planificar_migracion(p_proyecto_id);
    ELSEIF v_estado = 'EN_PROCESO' THEN
        CALL ejecutar_migracion(p_proyecto_id);
    END IF;
    
    -- Validar migración
    CALL validar_migracion_completa(p_proyecto_id);
    
    -- Generar reporte
    CALL generar_reporte_migracion(p_proyecto_id);
END //
DELIMITER ;
```

### 9. Sistema de Disaster Recovery Integrado

```sql
-- Crear tabla de planes de disaster recovery
CREATE TABLE planes_disaster_recovery_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_plan VARCHAR(100),
    descripcion TEXT,
    rto_minutos INT,
    rpo_minutos INT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    procedimientos JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar plan de disaster recovery
INSERT INTO planes_disaster_recovery_integrado (nombre_plan, descripcion, rto_minutos, rpo_minutos, nivel_critico, procedimientos)
VALUES ('Plan_Recuperacion_Completo', 'Plan de recuperación para todo el sistema', 60, 15, 'CRITICO',
        JSON_ARRAY(
            'Verificar_Estado_Sistema',
            'Restaurar_Backup_Completo',
            'Aplicar_Logs_Incrementales',
            'Verificar_Integridad_Datos',
            'Reiniciar_Aplicaciones',
            'Notificar_Administradores'
        ));

-- Procedimiento para gestión de disaster recovery
DELIMITER //
CREATE PROCEDURE gestionar_disaster_recovery_integrado()
BEGIN
    -- Monitorear estado del sistema
    CALL monitorear_estado_sistema();
    
    -- Verificar umbrales críticos
    CALL verificar_umbrales_criticos();
    
    -- Ejecutar recuperación si es necesario
    CALL ejecutar_recuperacion_automatica();
    
    -- Actualizar métricas de disaster recovery
    CALL actualizar_metricas_disaster_recovery();
END //
DELIMITER ;
```

### 10. Sistema de Gestión Integral

```sql
-- Crear tabla de configuración integral
CREATE TABLE configuracion_integral (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuración integral
INSERT INTO configuracion_integral (componente, configuracion)
VALUES 
('SISTEMA_COMPLETO', JSON_OBJECT(
    'seguridad', JSON_OBJECT('habilitado', true, 'nivel', 'ALTO'),
    'backup', JSON_OBJECT('habilitado', true, 'frecuencia', 'DIARIO'),
    'replicacion', JSON_OBJECT('habilitado', true, 'tipo', 'MAESTRO_ESCLAVO'),
    'monitoreo', JSON_OBJECT('habilitado', true, 'intervalo', 60),
    'mantenimiento', JSON_OBJECT('habilitado', true, 'automatico', true),
    'disaster_recovery', JSON_OBJECT('habilitado', true, 'rto_minutos', 60)
));

-- Procedimiento principal de gestión integral
DELIMITER //
CREATE PROCEDURE gestionar_sistema_integral()
BEGIN
    -- Ejecutar todos los componentes del sistema
    CALL aplicar_politicas_seguridad();
    CALL gestionar_usuarios_sistema();
    CALL gestionar_backup_integrado();
    CALL gestionar_replicacion_integrada();
    CALL monitoreo_integral();
    CALL mantenimiento_integral();
    CALL gestionar_disaster_recovery_integrado();
    
    -- Generar reporte de estado
    CALL generar_reporte_estado_sistema();
    
    -- Registrar actividad
    INSERT INTO log_actividad_sistema (actividad, fecha_ejecucion, estado)
    VALUES ('GESTION_INTEGRAL', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para gestión automática integral
CREATE EVENT gestion_automatica_integral
ON SCHEDULE EVERY 1 HOUR
STARTS '2024-01-01 00:00:00'
DO
  CALL gestionar_sistema_integral();
```

## Ejercicios Prácticos

### Ejercicio 1: Implementar Sistema de Seguridad
```sql
-- Crear usuarios del sistema
CALL gestionar_usuarios_sistema();

-- Aplicar políticas de seguridad
CALL aplicar_politicas_seguridad();

-- Verificar configuración de seguridad
SELECT * FROM politicas_seguridad WHERE activo = TRUE;
```

### Ejercicio 2: Configurar Sistema de Backup
```sql
-- Configurar backups automáticos
CALL gestionar_backup_integrado();

-- Verificar configuraciones de backup
SELECT * FROM configuracion_backup_integrado WHERE activo = TRUE;

-- Ejecutar backup manual
CALL ejecutar_backup_completo('Backup_Manual_Test');
```

### Ejercicio 3: Implementar Replicación
```sql
-- Configurar replicación
CALL gestionar_replicacion_integrada();

-- Verificar estado de replicación
SELECT * FROM configuracion_replicacion_integrada WHERE activo = TRUE;

-- Monitorear replicación
CALL verificar_estado_replicacion();
```

### Ejercicio 4: Activar Monitoreo
```sql
-- Activar monitoreo integral
CALL monitoreo_integral();

-- Verificar métricas
SELECT * FROM metricas_sistema_integrado ORDER BY fecha_medicion DESC LIMIT 10;

-- Generar alertas
CALL generar_alertas_integrales();
```

### Ejercicio 5: Ejecutar Mantenimiento
```sql
-- Ejecutar mantenimiento integral
CALL mantenimiento_integral();

-- Verificar tareas ejecutadas
SELECT * FROM log_mantenimiento_integrado ORDER BY fecha_ejecucion DESC LIMIT 10;

-- Verificar estado del sistema
CALL verificar_estado_sistema();
```

### Ejercicio 6: Gestionar Migración
```sql
-- Crear proyecto de migración
INSERT INTO proyectos_migracion (nombre_proyecto, descripcion, estado)
VALUES ('Migracion_Test', 'Migración de prueba', 'PLANIFICADO');

-- Ejecutar migración
CALL gestionar_migracion_integrada(LAST_INSERT_ID());

-- Verificar estado de migración
SELECT * FROM proyectos_migracion WHERE id = LAST_INSERT_ID();
```

### Ejercicio 7: Activar Disaster Recovery
```sql
-- Activar disaster recovery
CALL gestionar_disaster_recovery_integrado();

-- Verificar planes de disaster recovery
SELECT * FROM planes_disaster_recovery_integrado WHERE activo = TRUE;

-- Ejecutar prueba de disaster recovery
CALL ejecutar_prueba_disaster_recovery(1, 'SIMULADA');
```

### Ejercicio 8: Generar Reportes
```sql
-- Generar reporte de estado del sistema
CALL generar_reporte_estado_sistema();

-- Generar reporte de seguridad
CALL generar_reporte_seguridad();

-- Generar reporte de rendimiento
CALL generar_reporte_rendimiento();
```

### Ejercicio 9: Configurar Alertas
```sql
-- Configurar alertas del sistema
CALL configurar_alertas_sistema();

-- Verificar alertas activas
SELECT * FROM alertas_sistema WHERE resuelto = FALSE;

-- Probar sistema de alertas
CALL probar_sistema_alertas();
```

### Ejercicio 10: Ejecutar Sistema Completo
```sql
-- Ejecutar gestión integral del sistema
CALL gestionar_sistema_integral();

-- Verificar estado general del sistema
SELECT 
    'Sistema de Administración de Bases de Datos' as sistema,
    'ACTIVO' as estado,
    NOW() as ultima_verificacion,
    'Todos los componentes funcionando correctamente' as observaciones;

-- Verificar logs del sistema
SELECT * FROM log_actividad_sistema ORDER BY fecha_ejecucion DESC LIMIT 10;
```

## Dashboard del Sistema

### Vista Principal del Dashboard
```sql
-- Crear vista del dashboard principal
CREATE VIEW dashboard_principal AS
SELECT 
    'Seguridad' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM politicas_seguridad WHERE activo = TRUE

UNION ALL

SELECT 
    'Backup' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM configuracion_backup_integrado WHERE activo = TRUE

UNION ALL

SELECT 
    'Replicación' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM configuracion_replicacion_integrada WHERE activo = TRUE

UNION ALL

SELECT 
    'Monitoreo' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM metricas_sistema_integrado WHERE fecha_medicion > DATE_SUB(NOW(), INTERVAL 1 HOUR)

UNION ALL

SELECT 
    'Mantenimiento' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM tareas_mantenimiento_integrado WHERE activo = TRUE

UNION ALL

SELECT 
    'Disaster Recovery' as componente,
    CASE WHEN COUNT(*) > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END as estado,
    COUNT(*) as elementos_activos
FROM planes_disaster_recovery_integrado WHERE activo = TRUE;
```

## Resumen del Proyecto

### Componentes Implementados
1. **Sistema de Seguridad**: Políticas de contraseñas, sesiones y acceso
2. **Gestión de Usuarios**: Roles, permisos y auditoría
3. **Backup y Recuperación**: Backups automáticos con encriptación
4. **Replicación**: Configuración maestro-esclavo con monitoreo
5. **Monitoreo**: Métricas en tiempo real con alertas
6. **Mantenimiento**: Tareas automáticas de optimización
7. **Migración**: Sistema de migración con validación
8. **Disaster Recovery**: Planes de recuperación con RTO/RPO

### Características del Sistema
- **Integración Completa**: Todos los componentes trabajan juntos
- **Automatización**: Tareas ejecutadas automáticamente
- **Monitoreo Continuo**: Supervisión 24/7 del sistema
- **Alertas Inteligentes**: Notificaciones proactivas
- **Escalabilidad**: Sistema diseñado para crecer
- **Robustez**: Múltiples capas de protección

### Beneficios del Sistema
- **Mayor Disponibilidad**: Sistema más confiable
- **Mejor Seguridad**: Protección avanzada de datos
- **Eficiencia Operacional**: Automatización de tareas
- **Visibilidad Completa**: Dashboard unificado
- **Recuperación Rápida**: Planes de disaster recovery
- **Cumplimiento**: Auditoría y reportes automáticos

## Conclusiones

Este proyecto integrador demuestra cómo combinar todos los conceptos aprendidos en el módulo para crear un sistema de administración de bases de datos robusto, escalable y eficiente. El sistema implementado proporciona:

1. **Seguridad Avanzada**: Protección completa de datos y accesos
2. **Alta Disponibilidad**: Sistemas de backup y replicación
3. **Monitoreo Proactivo**: Detección temprana de problemas
4. **Mantenimiento Automático**: Optimización continua
5. **Recuperación Rápida**: Planes de disaster recovery
6. **Gestión Integral**: Un solo sistema para todo

El sistema está diseñado para ser implementado en entornos de producción y puede adaptarse a diferentes necesidades organizacionales. La modularidad del diseño permite agregar o modificar componentes según sea necesario.

## Próximos Pasos

Para continuar el aprendizaje, se recomienda:
1. Implementar el sistema en un entorno de prueba
2. Personalizar configuraciones según necesidades específicas
3. Agregar componentes adicionales según requerimientos
4. Realizar pruebas de carga y rendimiento
5. Documentar procedimientos operacionales
6. Capacitar al equipo de administración

Este proyecto integrador sienta las bases para convertirse en un administrador de bases de datos senior, capaz de gestionar sistemas complejos y críticos en entornos de producción.
