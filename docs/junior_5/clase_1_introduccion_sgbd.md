# Clase 1: Introducción a los Sistemas de Gestión de Bases de Datos

## Objetivos de la Clase
- Comprender qué es un SGBD y su importancia
- Conocer la historia y evolución de los SGBD
- Identificar los principales SGBD del mercado
- Entender las categorías de SGBD
- Comparar características generales de los sistemas

## ¿Qué es un SGBD?

**SGBD (Sistema de Gestión de Bases de Datos)** es un software que permite crear, mantener y administrar bases de datos de manera eficiente y segura.

### Componentes principales:
1. **Motor de Base de Datos**: Núcleo que procesa las consultas
2. **Interfaz de Usuario**: Herramientas para interactuar con el sistema
3. **Lenguaje de Consulta**: SQL como estándar
4. **Sistema de Seguridad**: Control de acceso y permisos
5. **Sistema de Recuperación**: Backup y restore

## Historia y Evolución

### Primera Generación (1960s-1970s)
- Sistemas jerárquicos y de red
- Ejemplo: IMS de IBM

### Segunda Generación (1970s-1980s)
- Modelo relacional de Edgar Codd
- SQL como lenguaje estándar
- Ejemplos: Oracle, DB2

### Tercera Generación (1990s-2000s)
- SGBD orientados a objetos
- Sistemas distribuidos
- Ejemplos: PostgreSQL, MySQL

### Cuarta Generación (2000s-presente)
- NoSQL y Big Data
- Sistemas en la nube
- Ejemplos: MongoDB, Cassandra

## Principales SGBD del Mercado

### 1. MySQL
- **Desarrollador**: Oracle Corporation
- **Licencia**: GPL (comunidad) / Comercial
- **Características**: Open source, rápido, fácil de usar
- **Uso**: Aplicaciones web, desarrollo

### 2. PostgreSQL
- **Desarrollador**: PostgreSQL Global Development Group
- **Licencia**: PostgreSQL License (BSD-like)
- **Características**: Open source, estándares SQL, extensible
- **Uso**: Aplicaciones empresariales, análisis

### 3. SQL Server
- **Desarrollador**: Microsoft
- **Licencia**: Comercial
- **Características**: Integración con ecosistema Microsoft
- **Uso**: Aplicaciones empresariales Windows

### 4. Oracle Database
- **Desarrollador**: Oracle Corporation
- **Licencia**: Comercial
- **Características**: Robusto, escalable, enterprise
- **Uso**: Grandes corporaciones, aplicaciones críticas

## Categorías de SGBD

### Por Modelo de Datos
- **Relacionales**: MySQL, PostgreSQL, SQL Server, Oracle
- **NoSQL**: MongoDB, Cassandra, Redis
- **Orientados a Objetos**: ObjectStore, Versant

### Por Arquitectura
- **Centralizados**: Una sola instancia
- **Distribuidos**: Múltiples nodos
- **En la Nube**: Servicios gestionados

### Por Licencia
- **Open Source**: MySQL, PostgreSQL
- **Comercial**: SQL Server, Oracle
- **Híbrido**: MySQL (doble licencia)

## Comparación General

| Característica | MySQL | PostgreSQL | SQL Server | Oracle |
|----------------|-------|------------|------------|--------|
| Licencia | GPL/Comercial | BSD | Comercial | Comercial |
| Plataforma | Multi | Multi | Windows/Linux | Multi |
| Rendimiento | Alto | Alto | Alto | Muy Alto |
| Escalabilidad | Buena | Excelente | Excelente | Excelente |
| Estándares SQL | Parcial | Excelente | Bueno | Excelente |
| Comunidad | Muy Grande | Grande | Grande | Grande |

## Ejercicios Prácticos

### Ejercicio 1: Investigación de SGBD
Investiga y completa la siguiente tabla:

```sql
-- Crear tabla para comparar SGBD
CREATE TABLE comparacion_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    desarrollador VARCHAR(100),
    licencia VARCHAR(50),
    plataforma VARCHAR(100),
    año_lanzamiento YEAR,
    ultima_version VARCHAR(20)
);
```

### Ejercicio 2: Análisis de Características
```sql
-- Insertar datos de comparación
INSERT INTO comparacion_sgbd VALUES
(1, 'MySQL', 'Oracle Corporation', 'GPL/Comercial', 'Multi-plataforma', 1995, '8.0'),
(2, 'PostgreSQL', 'PostgreSQL Global Development Group', 'BSD', 'Multi-plataforma', 1996, '15.0'),
(3, 'SQL Server', 'Microsoft', 'Comercial', 'Windows/Linux', 1989, '2022'),
(4, 'Oracle Database', 'Oracle Corporation', 'Comercial', 'Multi-plataforma', 1979, '19c');
```

### Ejercicio 3: Consultas de Análisis
```sql
-- SGBD con licencia open source
SELECT nombre, desarrollador, licencia 
FROM comparacion_sgbd 
WHERE licencia IN ('GPL', 'BSD', 'Open Source');

-- SGBD más antiguos
SELECT nombre, año_lanzamiento, ultima_version
FROM comparacion_sgbd 
ORDER BY año_lanzamiento ASC;

-- SGBD por plataforma
SELECT plataforma, COUNT(*) as cantidad_sgbd
FROM comparacion_sgbd 
GROUP BY plataforma;
```

### Ejercicio 4: Casos de Uso
```sql
-- Crear tabla de casos de uso
CREATE TABLE casos_uso_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd_id INT,
    caso_uso VARCHAR(100),
    descripcion TEXT,
    FOREIGN KEY (sgbd_id) REFERENCES comparacion_sgbd(id)
);

-- Insertar casos de uso
INSERT INTO casos_uso_sgbd VALUES
(1, 1, 'Aplicaciones Web', 'Sitios web, blogs, CMS'),
(2, 1, 'Desarrollo Rápido', 'Prototipos, aplicaciones pequeñas'),
(3, 2, 'Aplicaciones Empresariales', 'Sistemas complejos, análisis'),
(4, 2, 'Data Science', 'Análisis de datos, machine learning'),
(5, 3, 'Ecosistema Microsoft', 'Aplicaciones .NET, SharePoint'),
(6, 3, 'Business Intelligence', 'Reporting, análisis empresarial'),
(7, 4, 'Aplicaciones Críticas', 'Sistemas bancarios, transaccionales'),
(8, 4, 'Grandes Corporaciones', 'ERP, sistemas legacy');
```

### Ejercicio 5: Análisis de Tendencias
```sql
-- SGBD por década de lanzamiento
SELECT 
    CASE 
        WHEN año_lanzamiento < 1990 THEN '1980s'
        WHEN año_lanzamiento < 2000 THEN '1990s'
        WHEN año_lanzamiento < 2010 THEN '2000s'
        ELSE '2010s+'
    END as decada,
    COUNT(*) as cantidad,
    GROUP_CONCAT(nombre) as sgbd
FROM comparacion_sgbd 
GROUP BY decada
ORDER BY decada;
```

### Ejercicio 6: Comparación de Versiones
```sql
-- Análisis de versiones actuales
SELECT 
    nombre,
    ultima_version,
    CASE 
        WHEN ultima_version LIKE '%.0' THEN 'Versión Mayor'
        WHEN ultima_version LIKE '%.%' THEN 'Versión Menor'
        ELSE 'Versión Especial'
    END as tipo_version
FROM comparacion_sgbd;
```

### Ejercicio 7: Análisis de Licencias
```sql
-- Distribución por tipo de licencia
SELECT 
    CASE 
        WHEN licencia LIKE '%GPL%' OR licencia LIKE '%BSD%' THEN 'Open Source'
        WHEN licencia = 'Comercial' THEN 'Comercial'
        ELSE 'Híbrido'
    END as tipo_licencia,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM comparacion_sgbd), 2) as porcentaje
FROM comparacion_sgbd 
GROUP BY tipo_licencia;
```

### Ejercicio 8: Análisis de Casos de Uso
```sql
-- Casos de uso más comunes
SELECT 
    caso_uso,
    COUNT(*) as frecuencia,
    GROUP_CONCAT(cs.nombre) as sgbd_recomendados
FROM casos_uso_sgbd cus
JOIN comparacion_sgbd cs ON cus.sgbd_id = cs.id
GROUP BY caso_uso
ORDER BY frecuencia DESC;
```

### Ejercicio 9: Recomendaciones por Escenario
```sql
-- Crear función para recomendaciones
DELIMITER //
CREATE FUNCTION recomendar_sgbd(escenario VARCHAR(100))
RETURNS VARCHAR(100)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE recomendacion VARCHAR(100);
    
    CASE escenario
        WHEN 'Aplicación Web Simple' THEN SET recomendacion = 'MySQL';
        WHEN 'Aplicación Empresarial' THEN SET recomendacion = 'PostgreSQL o SQL Server';
        WHEN 'Sistema Crítico' THEN SET recomendacion = 'Oracle Database';
        WHEN 'Desarrollo Rápido' THEN SET recomendacion = 'MySQL o PostgreSQL';
        ELSE SET recomendacion = 'Evaluar requerimientos específicos';
    END CASE;
    
    RETURN recomendacion;
END //
DELIMITER ;

-- Probar la función
SELECT 
    'Aplicación Web Simple' as escenario,
    recomendar_sgbd('Aplicación Web Simple') as recomendacion
UNION ALL
SELECT 
    'Aplicación Empresarial' as escenario,
    recomendar_sgbd('Aplicación Empresarial') as recomendacion;
```

### Ejercicio 10: Análisis Completo
```sql
-- Vista completa de análisis
CREATE VIEW analisis_completo_sgbd AS
SELECT 
    cs.nombre,
    cs.desarrollador,
    cs.licencia,
    cs.plataforma,
    cs.año_lanzamiento,
    cs.ultima_version,
    COUNT(cus.id) as casos_uso_count,
    GROUP_CONCAT(cus.caso_uso) as casos_uso
FROM comparacion_sgbd cs
LEFT JOIN casos_uso_sgbd cus ON cs.id = cus.sgbd_id
GROUP BY cs.id, cs.nombre, cs.desarrollador, cs.licencia, cs.plataforma, cs.año_lanzamiento, cs.ultima_version;

-- Consultar la vista
SELECT * FROM analisis_completo_sgbd ORDER BY casos_uso_count DESC;
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Los conceptos fundamentales de los SGBD
- La evolución histórica de los sistemas de bases de datos
- Los principales SGBD del mercado y sus características
- Cómo comparar y evaluar diferentes sistemas
- Casos de uso típicos para cada SGBD

## Próxima Clase
[Clase 2: MySQL: Instalación y Configuración](clase_2_mysql_instalacion.md)

## Recursos Adicionales
- [MySQL Official Documentation](https://dev.mysql.com/doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [Oracle Database Documentation](https://docs.oracle.com/en/database/)
