# Clase 1: Transacciones y Control de Concurrencia

## 📋 Descripción

En esta clase aprenderás sobre las transacciones en bases de datos, sus propiedades ACID, y cómo manejar la concurrencia entre múltiples usuarios. Las transacciones son fundamentales para mantener la integridad de los datos en entornos multi-usuario.

## 🎯 Objetivos de la Clase

- Comprender qué son las transacciones y sus propiedades ACID
- Aprender a iniciar, confirmar y revertir transacciones
- Entender los niveles de aislamiento
- Manejar bloqueos y deadlocks
- Implementar transacciones en MySQL

## 📚 Conceptos Clave

### ¿Qué es una Transacción?

Una **transacción** es una secuencia de operaciones de base de datos que se ejecutan como una unidad atómica. Es decir, todas las operaciones se ejecutan correctamente o ninguna se ejecuta.

### Propiedades ACID

Las transacciones deben cumplir cuatro propiedades fundamentales:

1. **Atomicidad (Atomicity)**: La transacción se ejecuta completamente o no se ejecuta en absoluto
2. **Consistencia (Consistency)**: La transacción lleva la base de datos de un estado válido a otro estado válido
3. **Aislamiento (Isolation)**: Las transacciones concurrentes no interfieren entre sí
4. **Durabilidad (Durability)**: Los cambios se mantienen permanentemente una vez confirmados

## 🔧 Sintaxis y Comandos

### Iniciar una Transacción

```sql
-- Iniciar una transacción
START TRANSACTION;
-- o alternativamente
BEGIN;
```

### Confirmar una Transacción

```sql
-- Confirmar todos los cambios
COMMIT;
```

### Revertir una Transacción

```sql
-- Revertir todos los cambios
ROLLBACK;
```

### Puntos de Guardado (Savepoints)

```sql
-- Crear un punto de guardado
SAVEPOINT nombre_punto;

-- Revertir a un punto de guardado específico
ROLLBACK TO SAVEPOINT nombre_punto;

-- Liberar un punto de guardado
RELEASE SAVEPOINT nombre_punto;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Transacción Básica

```sql
-- Crear una tabla de ejemplo
CREATE TABLE cuentas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_cuenta VARCHAR(20) NOT NULL,
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

-- Insertar datos de ejemplo
INSERT INTO cuentas (numero_cuenta, saldo) VALUES 
('ACC001', 1000.00),
('ACC002', 500.00);

-- Transacción de transferencia entre cuentas
START TRANSACTION;

-- Verificar saldo de la cuenta origen
SELECT saldo FROM cuentas WHERE numero_cuenta = 'ACC001';

-- Debitar de la cuenta origen
UPDATE cuentas 
SET saldo = saldo - 200.00 
WHERE numero_cuenta = 'ACC001';

-- Acreditar a la cuenta destino
UPDATE cuentas 
SET saldo = saldo + 200.00 
WHERE numero_cuenta = 'ACC002';

-- Confirmar la transacción
COMMIT;
```

**Explicación línea por línea:**

1. `START TRANSACTION;` - Inicia una nueva transacción
2. `SELECT saldo FROM cuentas WHERE numero_cuenta = 'ACC001';` - Verifica el saldo actual
3. `UPDATE cuentas SET saldo = saldo - 200.00 WHERE numero_cuenta = 'ACC001';` - Reduce el saldo de la cuenta origen
4. `UPDATE cuentas SET saldo = saldo + 200.00 WHERE numero_cuenta = 'ACC002';` - Aumenta el saldo de la cuenta destino
5. `COMMIT;` - Confirma todos los cambios

### Ejemplo 2: Transacción con Rollback

```sql
-- Transacción que falla y se revierte
START TRANSACTION;

-- Insertar un nuevo registro
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC003', 750.00);

-- Simular una condición de error
-- (En un caso real, esto podría ser una validación de negocio)
SELECT COUNT(*) FROM cuentas WHERE saldo < 0;

-- Si hay algún problema, revertir la transacción
ROLLBACK;

-- Verificar que el registro no se insertó
SELECT * FROM cuentas WHERE numero_cuenta = 'ACC003';
```

### Ejemplo 3: Transacción con Savepoints

```sql
-- Transacción con múltiples puntos de guardado
START TRANSACTION;

-- Insertar primera cuenta
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC004', 1000.00);
SAVEPOINT punto1;

-- Insertar segunda cuenta
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC005', 2000.00);
SAVEPOINT punto2;

-- Insertar tercera cuenta
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC006', 3000.00);

-- Revertir solo la última inserción
ROLLBACK TO SAVEPOINT punto2;

-- Confirmar las dos primeras inserciones
COMMIT;
```

## 🔒 Niveles de Aislamiento

### Configurar Nivel de Aislamiento

```sql
-- Ver el nivel de aislamiento actual
SELECT @@transaction_isolation;

-- Configurar nivel de aislamiento para la sesión
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Configurar nivel de aislamiento para la próxima transacción
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

### Niveles Disponibles

1. **READ UNCOMMITTED**: Permite leer datos no confirmados
2. **READ COMMITTED**: Solo lee datos confirmados
3. **REPEATABLE READ**: Lecturas consistentes durante la transacción
4. **SERIALIZABLE**: Aislamiento completo

## 🚫 Manejo de Bloqueos

### Ver Bloqueos Activos

```sql
-- Ver procesos bloqueados
SHOW PROCESSLIST;

-- Ver información detallada de bloqueos
SELECT * FROM information_schema.INNODB_LOCKS;
SELECT * FROM information_schema.INNODB_LOCK_WAITS;
```

### Ejemplo de Bloqueo

```sql
-- Sesión 1: Iniciar transacción y bloquear registro
START TRANSACTION;
UPDATE cuentas SET saldo = saldo + 100 WHERE id = 1;
-- No hacer COMMIT todavía

-- Sesión 2: Intentar actualizar el mismo registro
START TRANSACTION;
UPDATE cuentas SET saldo = saldo - 50 WHERE id = 1;
-- Esta operación se bloqueará hasta que la sesión 1 haga COMMIT
```

## ⚠️ Manejo de Deadlocks

### Ejemplo de Deadlock

```sql
-- Sesión 1
START TRANSACTION;
UPDATE cuentas SET saldo = saldo + 100 WHERE id = 1;
-- Esperar un momento
UPDATE cuentas SET saldo = saldo - 50 WHERE id = 2;

-- Sesión 2 (ejecutar simultáneamente)
START TRANSACTION;
UPDATE cuentas SET saldo = saldo + 100 WHERE id = 2;
-- Esperar un momento
UPDATE cuentas SET saldo = saldo - 50 WHERE id = 1;
```

### Detectar y Manejar Deadlocks

```sql
-- Ver información de deadlocks
SHOW ENGINE INNODB STATUS;

-- Configurar timeout para deadlocks
SET innodb_lock_wait_timeout = 50;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Transacción de Transferencia
Crea una transacción que transfiera $150 de la cuenta 'ACC001' a 'ACC002', incluyendo validación de saldo suficiente.

### Ejercicio 2: Transacción con Validación
Implementa una transacción que inserte una nueva cuenta solo si el número de cuenta no existe.

### Ejercicio 3: Transacción con Savepoints
Crea una transacción que inserte 3 cuentas, pero permite revertir solo las dos últimas usando savepoints.

### Ejercicio 4: Manejo de Errores
Implementa una transacción que maneje errores y haga rollback automático en caso de fallo.

### Ejercicio 5: Transacción de Actualización Masiva
Crea una transacción que actualice el saldo de múltiples cuentas y confirme todos los cambios.

### Ejercicio 6: Transacción con Consultas
Implementa una transacción que consulte el saldo total antes y después de una operación.

### Ejercicio 7: Transacción Anidada
Crea una transacción que contenga operaciones de inserción, actualización y eliminación.

### Ejercicio 8: Transacción con Bloqueos
Implementa una transacción que demuestre el comportamiento de bloqueos entre sesiones.

### Ejercicio 9: Transacción de Auditoría
Crea una transacción que registre cambios en una tabla de auditoría.

### Ejercicio 10: Transacción Compleja
Implementa una transacción compleja que combine múltiples operaciones con validaciones.

## 📝 Resumen

En esta clase has aprendido:

- **Transacciones**: Operaciones atómicas que mantienen la integridad de los datos
- **Propiedades ACID**: Atomicidad, Consistencia, Aislamiento y Durabilidad
- **Comandos básicos**: START TRANSACTION, COMMIT, ROLLBACK
- **Savepoints**: Puntos de guardado para control granular
- **Niveles de aislamiento**: Control de concurrencia
- **Bloqueos y deadlocks**: Manejo de conflictos entre transacciones

## 🔗 Próximos Pasos

- [Clase 2: Procedimientos Almacenados Básicos](clase_2_procedimientos_basicos.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 1!** 🎉 Continúa con la siguiente clase para profundizar en procedimientos almacenados.
