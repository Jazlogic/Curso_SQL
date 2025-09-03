# Clase 7: Administración de Usuarios y Permisos

## 📋 Descripción

En esta clase aprenderás sobre la administración de usuarios y permisos en MySQL. La seguridad de la base de datos es fundamental para proteger los datos y controlar el acceso. Aprenderás a crear usuarios, asignar permisos, gestionar roles y implementar políticas de seguridad.

## 🎯 Objetivos de la Clase

- Comprender el sistema de usuarios y permisos de MySQL
- Aprender a crear y gestionar usuarios
- Entender los diferentes tipos de permisos
- Implementar roles y grupos de usuarios
- Configurar políticas de seguridad
- Monitorear y auditar accesos

## 📚 Conceptos Clave

### Sistema de Usuarios en MySQL

MySQL utiliza un sistema de usuarios y permisos basado en:
- **Usuarios**: Cuentas que pueden acceder a la base de datos
- **Hosts**: Direcciones desde las cuales se puede conectar
- **Permisos**: Privilegios específicos sobre objetos de la base de datos
- **Roles**: Grupos de permisos que se pueden asignar a usuarios

### Tipos de Permisos

1. **Permisos Globales**: Afectan a toda la base de datos
2. **Permisos de Base de Datos**: Afectan a una base de datos específica
3. **Permisos de Tabla**: Afectan a tablas específicas
4. **Permisos de Columna**: Afectan a columnas específicas

### Principios de Seguridad

- **Principio de menor privilegio**: Otorgar solo los permisos necesarios
- **Separación de responsabilidades**: Diferentes usuarios para diferentes tareas
- **Auditoría**: Registrar y monitorear accesos
- **Rotación de contraseñas**: Cambiar contraseñas regularmente

## 🔧 Sintaxis y Comandos

### Crear Usuario

```sql
-- Crear usuario básico
CREATE USER 'nombre_usuario'@'host' IDENTIFIED BY 'contraseña';

-- Crear usuario con opciones adicionales
CREATE USER 'nombre_usuario'@'host' 
IDENTIFIED BY 'contraseña'
PASSWORD EXPIRE INTERVAL 90 DAY
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1;
```

### Asignar Permisos

```sql
-- Asignar permisos específicos
GRANT permiso1, permiso2 ON objeto TO 'usuario'@'host';

-- Asignar todos los permisos
GRANT ALL PRIVILEGES ON base_datos.* TO 'usuario'@'host';

-- Asignar permisos con opciones
GRANT SELECT, INSERT ON tabla TO 'usuario'@'host' WITH GRANT OPTION;
```

### Revocar Permisos

```sql
-- Revocar permisos específicos
REVOKE permiso1, permiso2 ON objeto FROM 'usuario'@'host';

-- Revocar todos los permisos
REVOKE ALL PRIVILEGES ON base_datos.* FROM 'usuario'@'host';
```

### Gestionar Usuarios

```sql
-- Ver usuarios existentes
SELECT User, Host FROM mysql.user;

-- Ver permisos de un usuario
SHOW GRANTS FOR 'usuario'@'host';

-- Cambiar contraseña
ALTER USER 'usuario'@'host' IDENTIFIED BY 'nueva_contraseña';

-- Eliminar usuario
DROP USER 'usuario'@'host';
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Crear Usuario Básico

```sql
-- Crear usuario para aplicación web
CREATE USER 'app_web'@'localhost' IDENTIFIED BY 'password_seguro_123';

-- Asignar permisos básicos
GRANT SELECT, INSERT, UPDATE, DELETE ON tienda.* TO 'app_web'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'app_web'@'localhost';
```

**Explicación línea por línea:**

1. `CREATE USER 'app_web'@'localhost'` - Crea usuario que solo puede conectarse desde localhost
2. `IDENTIFIED BY 'password_seguro_123'` - Establece la contraseña
3. `GRANT SELECT, INSERT, UPDATE, DELETE ON tienda.*` - Otorga permisos CRUD en la base de datos tienda
4. `SHOW GRANTS FOR 'app_web'@'localhost'` - Muestra los permisos asignados

### Ejemplo 2: Usuario con Permisos Específicos

```sql
-- Crear usuario para reportes
CREATE USER 'reportes'@'%' IDENTIFIED BY 'reportes_2024';

-- Asignar solo permisos de lectura
GRANT SELECT ON tienda.productos TO 'reportes'@'%';
GRANT SELECT ON tienda.ventas_detalle TO 'reportes'@'%';
GRANT SELECT ON tienda.categorias TO 'reportes'@'%';

-- Verificar permisos
SHOW GRANTS FOR 'reportes'@'%';
```

### Ejemplo 3: Usuario con Permisos de Administración

```sql
-- Crear usuario administrador
CREATE USER 'admin_tienda'@'localhost' IDENTIFIED BY 'admin_super_seguro';

-- Asignar permisos de administración
GRANT ALL PRIVILEGES ON tienda.* TO 'admin_tienda'@'localhost';
GRANT CREATE USER ON *.* TO 'admin_tienda'@'localhost';
GRANT GRANT OPTION ON tienda.* TO 'admin_tienda'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'admin_tienda'@'localhost';
```

### Ejemplo 4: Usuario con Permisos de Columna

```sql
-- Crear usuario para actualizar solo precios
CREATE USER 'precios'@'localhost' IDENTIFIED BY 'precios_2024';

-- Asignar permisos solo a columna precio
GRANT SELECT, UPDATE (precio) ON tienda.productos TO 'precios'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'precios'@'localhost';
```

### Ejemplo 5: Usuario con Restricciones de Tiempo

```sql
-- Crear usuario con restricciones de seguridad
CREATE USER 'usuario_restricto'@'localhost' 
IDENTIFIED BY 'contraseña_compleja_123'
PASSWORD EXPIRE INTERVAL 30 DAY
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1;

-- Asignar permisos limitados
GRANT SELECT ON tienda.productos TO 'usuario_restricto'@'localhost';

-- Verificar configuración
SELECT User, Host, password_expired, password_lifetime, 
       failed_login_attempts, password_lock_time 
FROM mysql.user 
WHERE User = 'usuario_restricto';
```

### Ejemplo 6: Crear y Gestionar Roles

```sql
-- Crear rol para empleados
CREATE ROLE 'rol_empleado';

-- Asignar permisos al rol
GRANT SELECT, INSERT, UPDATE ON tienda.productos TO 'rol_empleado';
GRANT SELECT ON tienda.categorias TO 'rol_empleado';

-- Crear usuario y asignar rol
CREATE USER 'empleado1'@'localhost' IDENTIFIED BY 'empleado_123';
GRANT 'rol_empleado' TO 'empleado1'@'localhost';

-- Activar rol para el usuario
SET DEFAULT ROLE 'rol_empleado' FOR 'empleado1'@'localhost';

-- Verificar rol asignado
SHOW GRANTS FOR 'empleado1'@'localhost';
```

### Ejemplo 7: Usuario para Backup

```sql
-- Crear usuario para respaldos
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'backup_secure_2024';

-- Asignar permisos para respaldo
GRANT SELECT, LOCK TABLES ON tienda.* TO 'backup_user'@'localhost';
GRANT RELOAD ON *.* TO 'backup_user'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'backup_user'@'localhost';
```

### Ejemplo 8: Usuario con Permisos de Procedimientos

```sql
-- Crear usuario para ejecutar procedimientos
CREATE USER 'procedimientos'@'localhost' IDENTIFIED BY 'proc_2024';

-- Asignar permisos para procedimientos
GRANT EXECUTE ON tienda.* TO 'procedimientos'@'localhost';
GRANT SELECT ON tienda.productos TO 'procedimientos'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'procedimientos'@'localhost';
```

### Ejemplo 9: Auditoría de Usuarios

```sql
-- Crear tabla de auditoría de usuarios
CREATE TABLE auditoria_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    objeto VARCHAR(100),
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45)
);

-- Crear trigger para auditar cambios de usuarios
DELIMITER //

CREATE TRIGGER trigger_auditoria_usuarios
    AFTER INSERT ON mysql.user
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_usuarios (usuario, accion, objeto)
    VALUES (NEW.User, 'CREATE USER', CONCAT(NEW.User, '@', NEW.Host));
END //

DELIMITER ;
```

### Ejemplo 10: Política de Seguridad Completa

```sql
-- Crear usuarios para diferentes roles
CREATE USER 'desarrollador'@'localhost' IDENTIFIED BY 'dev_2024';
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'analyst_2024';
CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'audit_2024';

-- Asignar permisos específicos por rol
-- Desarrollador: permisos de desarrollo
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON tienda.* TO 'desarrollador'@'localhost';

-- Analista: solo lectura
GRANT SELECT ON tienda.* TO 'analista'@'localhost';

-- Auditor: solo lectura y permisos de auditoría
GRANT SELECT ON tienda.* TO 'auditor'@'localhost';
GRANT SELECT ON mysql.user TO 'auditor'@'localhost';

-- Verificar todos los permisos
SHOW GRANTS FOR 'desarrollador'@'localhost';
SHOW GRANTS FOR 'analista'@'localhost';
SHOW GRANTS FOR 'auditor'@'localhost';
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Usuario de Aplicación
Crea un usuario para una aplicación web con permisos específicos.

### Ejercicio 2: Usuario de Reportes
Implementa un usuario que solo pueda generar reportes de lectura.

### Ejercicio 3: Usuario de Administración
Crea un usuario administrador con permisos completos.

### Ejercicio 4: Usuario con Restricciones
Implementa un usuario con restricciones de seguridad avanzadas.

### Ejercicio 5: Sistema de Roles
Crea un sistema de roles para diferentes tipos de usuarios.

### Ejercicio 6: Usuario de Backup
Implementa un usuario específico para operaciones de respaldo.

### Ejercicio 7: Usuario de Auditoría
Crea un usuario con permisos de auditoría y monitoreo.

### Ejercicio 8: Usuario de Desarrollo
Implementa un usuario para desarrolladores con permisos de desarrollo.

### Ejercicio 9: Usuario de Producción
Crea un usuario para operaciones de producción con permisos limitados.

### Ejercicio 10: Política de Seguridad
Implementa una política de seguridad completa con múltiples usuarios y roles.

## 📝 Resumen

En esta clase has aprendido:

- **Sistema de usuarios**: Creación y gestión de usuarios en MySQL
- **Tipos de permisos**: Globales, de base de datos, de tabla y de columna
- **Asignación de permisos**: GRANT y REVOKE
- **Roles**: Creación y gestión de roles
- **Políticas de seguridad**: Implementación de mejores prácticas
- **Auditoría**: Monitoreo y registro de accesos

## 🔗 Próximos Pasos

- [Clase 8: Backup y Recuperación](clase_8_backup_recuperacion.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 7!** 🎉 Continúa con la siguiente clase para aprender sobre backup y recuperación.
