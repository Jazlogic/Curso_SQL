# Clase 2: Administración de Usuarios y Roles - Nivel Mid-Level

## Introducción
La administración efectiva de usuarios y roles es fundamental para mantener la seguridad y organización en sistemas de bases de datos. En esta clase aprenderemos sobre gestión avanzada de usuarios, roles, permisos y políticas de acceso.

## Conceptos Clave

### Gestión de Usuarios
**Definición**: Proceso de crear, modificar y eliminar cuentas de usuario en el sistema de base de datos.
**Componentes**:
- Creación de usuarios
- Configuración de autenticación
- Gestión de contraseñas
- Políticas de expiración

### Sistema de Roles
**Definición**: Mecanismo para agrupar permisos y asignarlos a usuarios de manera eficiente.
**Beneficios**:
- Simplificación de gestión
- Consistencia en permisos
- Facilidad de mantenimiento
- Seguridad mejorada

### Permisos Granulares
**Definición**: Sistema de permisos que permite control detallado sobre qué acciones puede realizar cada usuario.
**Niveles**:
- Permisos de sistema
- Permisos de base de datos
- Permisos de tabla
- Permisos de columna

## Ejemplos Prácticos

### 1. Creación de Usuarios con Diferentes Configuraciones

```sql
-- Usuario con acceso local únicamente
CREATE USER 'admin_local'@'localhost' 
IDENTIFIED BY 'AdminPass123!'
PASSWORD EXPIRE INTERVAL 90 DAY
ACCOUNT LOCK;

-- Usuario con acceso desde red específica
CREATE USER 'desarrollador'@'192.168.1.%' 
IDENTIFIED BY 'DevPass123!'
PASSWORD EXPIRE INTERVAL 60 DAY;

-- Usuario con acceso desde cualquier IP
CREATE USER 'consultor'@'%' 
IDENTIFIED BY 'ConsultorPass123!'
PASSWORD EXPIRE INTERVAL 30 DAY
REQUIRE SSL;

-- Usuario con autenticación por plugin
CREATE USER 'usuario_plugin'@'localhost' 
IDENTIFIED WITH mysql_native_password BY 'PluginPass123!';
```

**Explicación línea por línea**:
- `CREATE USER`: Comando para crear nuevos usuarios
- `@'localhost'`: Restringe acceso solo desde localhost
- `@'192.168.1.%'`: Permite acceso desde subred específica
- `@'%'`: Permite acceso desde cualquier IP
- `PASSWORD EXPIRE`: Configura expiración de contraseña
- `ACCOUNT LOCK`: Bloquea la cuenta inicialmente
- `REQUIRE SSL`: Requiere conexión SSL
- `IDENTIFIED WITH`: Especifica método de autenticación

### 2. Sistema de Roles Jerárquico

```sql
-- Crear roles base
CREATE ROLE 'lector_basico';
CREATE ROLE 'editor_basico';
CREATE ROLE 'administrador_basico';

-- Crear roles especializados
CREATE ROLE 'lector_ventas';
CREATE ROLE 'editor_ventas';
CREATE ROLE 'administrador_ventas';

-- Crear roles compuestos
CREATE ROLE 'supervisor_ventas';
CREATE ROLE 'gerente_ventas';

-- Asignar permisos a roles base
GRANT SELECT ON empresa.* TO 'lector_basico';
GRANT SELECT, INSERT, UPDATE ON empresa.* TO 'editor_basico';
GRANT ALL PRIVILEGES ON empresa.* TO 'administrador_basico';

-- Asignar permisos específicos a roles especializados
GRANT SELECT ON empresa.ventas.* TO 'lector_ventas';
GRANT SELECT, INSERT, UPDATE ON empresa.ventas.* TO 'editor_ventas';
GRANT ALL PRIVILEGES ON empresa.ventas.* TO 'administrador_ventas';

-- Crear jerarquía de roles
GRANT 'lector_ventas' TO 'supervisor_ventas';
GRANT 'editor_ventas' TO 'supervisor_ventas';
GRANT 'supervisor_ventas' TO 'gerente_ventas';
GRANT 'administrador_ventas' TO 'gerente_ventas';
```

**Explicación línea por línea**:
- `CREATE ROLE`: Crea un nuevo rol
- `GRANT SELECT`: Otorga permisos de lectura
- `GRANT ALL PRIVILEGES`: Otorga todos los permisos
- `GRANT 'rol' TO 'rol'`: Crea jerarquía de roles
- `empresa.ventas.*`: Permisos específicos en esquema y tabla

### 3. Permisos Granulares por Columna

```sql
-- Crear usuario para análisis de datos
CREATE USER 'analista_datos'@'localhost' 
IDENTIFIED BY 'AnalistaPass123!';

-- Otorgar permisos específicos por columna
GRANT SELECT (id, nombre, fecha_creacion) ON empresa.clientes TO 'analista_datos'@'localhost';
GRANT SELECT (id, monto, fecha) ON empresa.ventas TO 'analista_datos'@'localhost';

-- Denegar acceso a columnas sensibles
REVOKE SELECT ON empresa.clientes FROM 'analista_datos'@'localhost';
GRANT SELECT (id, nombre, email, telefono) ON empresa.clientes TO 'analista_datos'@'localhost';

-- Crear vista con datos permitidos
CREATE VIEW vista_analista AS
SELECT 
    c.id,
    c.nombre,
    c.email,
    v.monto,
    v.fecha
FROM empresa.clientes c
JOIN empresa.ventas v ON c.id = v.cliente_id;

-- Otorgar acceso a la vista
GRANT SELECT ON empresa.vista_analista TO 'analista_datos'@'localhost';
```

**Explicación línea por línea**:
- `GRANT SELECT (columna)`: Permisos específicos por columna
- `REVOKE SELECT`: Revoca permisos
- `CREATE VIEW`: Crea vista personalizada
- `vista_analista`: Vista que filtra datos sensibles

### 4. Gestión de Contraseñas y Políticas

```sql
-- Crear función para validar contraseñas
DELIMITER //
CREATE FUNCTION validar_politica_password(password VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    
    -- Verificar longitud mínima
    IF LENGTH(password) >= 12 THEN
        -- Verificar complejidad
        IF password REGEXP '[A-Z]' AND 
           password REGEXP '[a-z]' AND 
           password REGEXP '[0-9]' AND 
           password REGEXP '[!@#$%^&*(),.?":{}|<>]' THEN
            SET resultado = TRUE;
        END IF;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Crear trigger para validar contraseñas
DELIMITER //
CREATE TRIGGER validar_password_usuario
BEFORE INSERT ON mysql.user
FOR EACH ROW
BEGIN
    IF NOT validar_politica_password(NEW.authentication_string) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La contraseña no cumple con la política de seguridad';
    END IF;
END //
DELIMITER ;

-- Configurar políticas de contraseña
ALTER USER 'admin_local'@'localhost' 
PASSWORD EXPIRE INTERVAL 90 DAY
PASSWORD HISTORY 5
PASSWORD REUSE INTERVAL 365 DAY;
```

**Explicación línea por línea**:
- `validar_politica_password()`: Función personalizada para validar contraseñas
- `REGEXP`: Expresión regular para validar patrones
- `PASSWORD HISTORY`: Mantiene historial de contraseñas
- `PASSWORD REUSE INTERVAL`: Previene reutilización de contraseñas

### 5. Sistema de Auditoría de Usuarios

```sql
-- Crear tabla de auditoría de usuarios
CREATE TABLE auditoria_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    detalles JSON,
    resultado ENUM('exitoso', 'fallido') DEFAULT 'exitoso'
);

-- Crear tabla de sesiones activas
CREATE TABLE sesiones_activas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    user_agent TEXT,
    estado ENUM('activa', 'inactiva') DEFAULT 'activa'
);

-- Trigger para auditoría de login
DELIMITER //
CREATE TRIGGER auditoria_login
AFTER INSERT ON sesiones_activas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_usuarios (usuario, accion, ip_origen, detalles)
    VALUES (
        NEW.usuario, 
        'LOGIN', 
        NEW.ip_origen,
        JSON_OBJECT('user_agent', NEW.user_agent, 'fecha_inicio', NEW.fecha_inicio)
    );
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `auditoria_usuarios`: Tabla para registrar eventos de usuarios
- `sesiones_activas`: Tabla para rastrear sesiones
- `JSON_OBJECT()`: Crea objeto JSON con detalles
- `ENUM`: Tipo de dato con valores predefinidos

## Ejercicios Prácticos

### Ejercicio 1: Crear Sistema de Usuarios por Departamento
```sql
-- Crear usuarios para diferentes departamentos
CREATE USER 'hr_manager'@'localhost' IDENTIFIED BY 'HRManager123!';
CREATE USER 'hr_employee'@'localhost' IDENTIFIED BY 'HREmployee123!';
CREATE USER 'finance_manager'@'localhost' IDENTIFIED BY 'FinanceManager123!';
CREATE USER 'finance_employee'@'localhost' IDENTIFIED BY 'FinanceEmployee123!';

-- Crear roles por departamento
CREATE ROLE 'hr_role';
CREATE ROLE 'finance_role';

-- Asignar permisos específicos
GRANT SELECT, INSERT, UPDATE ON empresa.empleados TO 'hr_role';
GRANT SELECT, INSERT, UPDATE ON empresa.nominas TO 'finance_role';

-- Asignar roles a usuarios
GRANT 'hr_role' TO 'hr_manager'@'localhost';
GRANT 'hr_role' TO 'hr_employee'@'localhost';
GRANT 'finance_role' TO 'finance_manager'@'localhost';
GRANT 'finance_role' TO 'finance_employee'@'localhost';
```

### Ejercicio 2: Implementar Roles con Herencia
```sql
-- Crear roles base
CREATE ROLE 'usuario_base';
CREATE ROLE 'usuario_avanzado';
CREATE ROLE 'usuario_experto';

-- Asignar permisos base
GRANT SELECT ON empresa.* TO 'usuario_base';

-- Crear herencia de roles
GRANT 'usuario_base' TO 'usuario_avanzado';
GRANT SELECT, INSERT, UPDATE ON empresa.* TO 'usuario_avanzado';

GRANT 'usuario_avanzado' TO 'usuario_experto';
GRANT ALL PRIVILEGES ON empresa.* TO 'usuario_experto';

-- Crear usuarios con diferentes niveles
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'User1Pass123!';
CREATE USER 'user2'@'localhost' IDENTIFIED BY 'User2Pass123!';
CREATE USER 'user3'@'localhost' IDENTIFIED BY 'User3Pass123!';

-- Asignar roles
GRANT 'usuario_base' TO 'user1'@'localhost';
GRANT 'usuario_avanzado' TO 'user2'@'localhost';
GRANT 'usuario_experto' TO 'user3'@'localhost';
```

### Ejercicio 3: Sistema de Permisos Temporales
```sql
-- Crear tabla de permisos temporales
CREATE TABLE permisos_temporales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    permiso VARCHAR(100),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Crear procedimiento para otorgar permisos temporales
DELIMITER //
CREATE PROCEDURE otorgar_permiso_temporal(
    IN p_usuario VARCHAR(100),
    IN p_permiso VARCHAR(100),
    IN p_dias INT
)
BEGIN
    DECLARE fecha_fin TIMESTAMP;
    SET fecha_fin = DATE_ADD(NOW(), INTERVAL p_dias DAY);
    
    INSERT INTO permisos_temporales (usuario, permiso, fecha_inicio, fecha_fin)
    VALUES (p_usuario, p_permiso, NOW(), fecha_fin);
    
    -- Otorgar permiso real
    SET @sql = CONCAT('GRANT ', p_permiso, ' ON empresa.* TO ''', p_usuario, '''@''localhost''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Usar el procedimiento
CALL otorgar_permiso_temporal('user1', 'INSERT', 7);
```

### Ejercicio 4: Gestión de Contraseñas con Historial
```sql
-- Crear tabla de historial de contraseñas
CREATE TABLE historial_passwords (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    password_hash VARCHAR(255),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función para verificar contraseñas anteriores
DELIMITER //
CREATE FUNCTION verificar_password_anterior(
    p_usuario VARCHAR(100),
    p_password VARCHAR(255)
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE resultado BOOLEAN DEFAULT TRUE;
    DECLARE contador INT DEFAULT 0;
    
    -- Verificar si la contraseña ya fue usada
    SELECT COUNT(*) INTO contador
    FROM historial_passwords
    WHERE usuario = p_usuario 
    AND password_hash = SHA2(p_password, 256)
    AND fecha_cambio > DATE_SUB(NOW(), INTERVAL 365 DAY);
    
    IF contador > 0 THEN
        SET resultado = FALSE;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Trigger para registrar cambios de contraseña
DELIMITER //
CREATE TRIGGER registrar_cambio_password
AFTER UPDATE ON mysql.user
FOR EACH ROW
BEGIN
    IF OLD.authentication_string != NEW.authentication_string THEN
        INSERT INTO historial_passwords (usuario, password_hash)
        VALUES (NEW.user, SHA2(NEW.authentication_string, 256));
    END IF;
END //
DELIMITER ;
```

### Ejercicio 5: Sistema de Bloqueo de Cuentas
```sql
-- Crear tabla de intentos de login
CREATE TABLE intentos_login (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    ip_origen VARCHAR(45),
    fecha_intento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exitoso BOOLEAN DEFAULT FALSE
);

-- Función para verificar bloqueo de cuenta
DELIMITER //
CREATE FUNCTION verificar_bloqueo_cuenta(p_usuario VARCHAR(100))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    DECLARE intentos_fallidos INT DEFAULT 0;
    
    -- Contar intentos fallidos en los últimos 15 minutos
    SELECT COUNT(*) INTO intentos_fallidos
    FROM intentos_login
    WHERE usuario = p_usuario 
    AND exitoso = FALSE
    AND fecha_intento > DATE_SUB(NOW(), INTERVAL 15 MINUTE);
    
    -- Bloquear si hay más de 3 intentos fallidos
    IF intentos_fallidos >= 3 THEN
        SET resultado = TRUE;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Procedimiento para registrar intento de login
DELIMITER //
CREATE PROCEDURE registrar_intento_login(
    IN p_usuario VARCHAR(100),
    IN p_ip VARCHAR(45),
    IN p_exitoso BOOLEAN
)
BEGIN
    INSERT INTO intentos_login (usuario, ip_origen, exitoso)
    VALUES (p_usuario, p_ip, p_exitoso);
    
    -- Bloquear cuenta si es necesario
    IF verificar_bloqueo_cuenta(p_usuario) THEN
        ALTER USER p_usuario@'localhost' ACCOUNT LOCK;
    END IF;
END //
DELIMITER ;
```

### Ejercicio 6: Permisos por Horario
```sql
-- Crear tabla de horarios de acceso
CREATE TABLE horarios_acceso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    dia_semana ENUM('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'),
    hora_inicio TIME,
    hora_fin TIME,
    activo BOOLEAN DEFAULT TRUE
);

-- Función para verificar horario de acceso
DELIMITER //
CREATE FUNCTION verificar_horario_acceso(p_usuario VARCHAR(100))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    DECLARE dia_actual VARCHAR(20);
    DECLARE hora_actual TIME;
    
    SET dia_actual = DAYNAME(NOW());
    SET hora_actual = TIME(NOW());
    
    -- Verificar si el usuario tiene acceso en este horario
    SELECT COUNT(*) INTO @contador
    FROM horarios_acceso
    WHERE usuario = p_usuario
    AND dia_semana = LOWER(dia_actual)
    AND hora_actual BETWEEN hora_inicio AND hora_fin
    AND activo = TRUE;
    
    IF @contador > 0 THEN
        SET resultado = TRUE;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Configurar horarios de acceso
INSERT INTO horarios_acceso (usuario, dia_semana, hora_inicio, hora_fin)
VALUES 
('user1', 'lunes', '09:00:00', '17:00:00'),
('user1', 'martes', '09:00:00', '17:00:00'),
('user1', 'miercoles', '09:00:00', '17:00:00'),
('user1', 'jueves', '09:00:00', '17:00:00'),
('user1', 'viernes', '09:00:00', '17:00:00');
```

### Ejercicio 7: Sistema de Delegación de Permisos
```sql
-- Crear tabla de delegación
CREATE TABLE delegacion_permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_delegador VARCHAR(100),
    usuario_delegado VARCHAR(100),
    permiso VARCHAR(100),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Procedimiento para delegar permisos
DELIMITER //
CREATE PROCEDURE delegar_permiso(
    IN p_delegador VARCHAR(100),
    IN p_delegado VARCHAR(100),
    IN p_permiso VARCHAR(100),
    IN p_dias INT
)
BEGIN
    DECLARE fecha_fin TIMESTAMP;
    SET fecha_fin = DATE_ADD(NOW(), INTERVAL p_dias DAY);
    
    -- Registrar delegación
    INSERT INTO delegacion_permisos (usuario_delegador, usuario_delegado, permiso, fecha_inicio, fecha_fin)
    VALUES (p_delegador, p_delegado, p_permiso, NOW(), fecha_fin);
    
    -- Otorgar permiso temporal
    SET @sql = CONCAT('GRANT ', p_permiso, ' ON empresa.* TO ''', p_delegado, '''@''localhost''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Usar delegación
CALL delegar_permiso('admin_local', 'user1', 'SELECT', 5);
```

### Ejercicio 8: Auditoría de Cambios de Permisos
```sql
-- Crear tabla de auditoría de permisos
CREATE TABLE auditoria_permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    permiso VARCHAR(100),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    detalles JSON
);

-- Trigger para auditoría de GRANT
DELIMITER //
CREATE TRIGGER auditoria_grant
AFTER INSERT ON mysql.user
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, fecha_hora, detalles)
    VALUES (
        NEW.user, 
        'GRANT', 
        NOW(),
        JSON_OBJECT('host', NEW.host, 'privileges', 'ALL PRIVILEGES')
    );
END //
DELIMITER ;

-- Función para generar reporte de auditoría
DELIMITER //
CREATE PROCEDURE generar_reporte_auditoria(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        usuario,
        accion,
        COUNT(*) as total_eventos,
        MIN(fecha_hora) as primer_evento,
        MAX(fecha_hora) as ultimo_evento
    FROM auditoria_permisos
    WHERE DATE(fecha_hora) BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY usuario, accion
    ORDER BY total_eventos DESC;
END //
DELIMITER ;
```

### Ejercicio 9: Sistema de Roles Dinámicos
```sql
-- Crear tabla de roles dinámicos
CREATE TABLE roles_dinamicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(100),
    condiciones JSON,
    permisos JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Función para evaluar condiciones de rol
DELIMITER //
CREATE FUNCTION evaluar_condiciones_rol(
    p_usuario VARCHAR(100),
    p_condiciones JSON
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE resultado BOOLEAN DEFAULT TRUE;
    DECLARE condicion VARCHAR(100);
    DECLARE valor_condicion VARCHAR(100);
    
    -- Evaluar condiciones (ejemplo simplificado)
    SET condicion = JSON_UNQUOTE(JSON_EXTRACT(p_condiciones, '$.departamento'));
    SET valor_condicion = 'IT'; -- Valor obtenido de otra tabla
    
    IF condicion != valor_condicion THEN
        SET resultado = FALSE;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Procedimiento para asignar roles dinámicos
DELIMITER //
CREATE PROCEDURE asignar_roles_dinamicos(p_usuario VARCHAR(100))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE rol_nombre VARCHAR(100);
    DECLARE rol_condiciones JSON;
    DECLARE rol_permisos JSON;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_rol, condiciones, permisos
        FROM roles_dinamicos
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO rol_nombre, rol_condiciones, rol_permisos;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF evaluar_condiciones_rol(p_usuario, rol_condiciones) THEN
            -- Asignar permisos del rol
            SET @sql = CONCAT('GRANT ', JSON_UNQUOTE(JSON_EXTRACT(rol_permisos, '$.permisos')), ' ON empresa.* TO ''', p_usuario, '''@''localhost''');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Gestión de Usuarios
```sql
-- Crear tabla de perfiles de usuario
CREATE TABLE perfiles_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    perfil ENUM('basico', 'intermedio', 'avanzado', 'administrador'),
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Crear tabla de políticas de acceso
CREATE TABLE politicas_acceso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    perfil VARCHAR(50),
    recurso VARCHAR(100),
    accion VARCHAR(50),
    permitido BOOLEAN DEFAULT TRUE
);

-- Insertar políticas
INSERT INTO politicas_acceso (perfil, recurso, accion, permitido)
VALUES 
('basico', 'empresa.clientes', 'SELECT', TRUE),
('basico', 'empresa.ventas', 'SELECT', TRUE),
('intermedio', 'empresa.clientes', 'INSERT', TRUE),
('intermedio', 'empresa.ventas', 'INSERT', TRUE),
('avanzado', 'empresa.*', 'UPDATE', TRUE),
('administrador', 'empresa.*', 'ALL', TRUE);

-- Procedimiento para aplicar políticas
DELIMITER //
CREATE PROCEDURE aplicar_politicas_usuario(p_usuario VARCHAR(100))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_perfil VARCHAR(50);
    DECLARE v_recurso VARCHAR(100);
    DECLARE v_accion VARCHAR(50);
    DECLARE v_permitido BOOLEAN;
    
    -- Obtener perfil del usuario
    SELECT perfil INTO v_perfil
    FROM perfiles_usuario
    WHERE usuario = p_usuario AND activo = TRUE;
    
    -- Aplicar políticas
    DECLARE cur CURSOR FOR
        SELECT recurso, accion, permitido
        FROM politicas_acceso
        WHERE perfil = v_perfil;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_recurso, v_accion, v_permitido;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF v_permitido THEN
            SET @sql = CONCAT('GRANT ', v_accion, ' ON ', v_recurso, ' TO ''', p_usuario, '''@''localhost''');
        ELSE
            SET @sql = CONCAT('REVOKE ', v_accion, ' ON ', v_recurso, ' FROM ''', p_usuario, '''@''localhost''');
        END IF;
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;

-- Asignar perfil y aplicar políticas
INSERT INTO perfiles_usuario (usuario, perfil)
VALUES ('user1', 'intermedio');

CALL aplicar_politicas_usuario('user1');
```

## Resumen
En esta clase hemos aprendido sobre:
- Creación y gestión avanzada de usuarios
- Sistemas de roles jerárquicos
- Permisos granulares por columna
- Políticas de contraseñas y seguridad
- Sistemas de auditoría de usuarios
- Gestión de sesiones y acceso
- Delegación de permisos
- Roles dinámicos y políticas de acceso

## Próxima Clase
En la siguiente clase aprenderemos sobre estrategias de backup y recuperación, incluyendo diferentes tipos de backup, planes de recuperación y herramientas de respaldo.
