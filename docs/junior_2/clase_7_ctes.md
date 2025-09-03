# Clase 7: CTEs - Common Table Expressions

## 📚 Descripción de la Clase
En esta clase aprenderás las Common Table Expressions (CTEs) en SQL, una herramienta poderosa para crear consultas más legibles y mantenibles. Dominarás CTEs simples, recursivos, y técnicas avanzadas para resolver problemas complejos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las CTEs y por qué son útiles
- Crear CTEs simples para simplificar consultas
- Implementar CTEs recursivos para datos jerárquicos
- Comparar CTEs con subconsultas y vistas
- Aplicar CTEs para resolver problemas complejos
- Optimizar consultas con CTEs

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las CTEs?

Las **Common Table Expressions (CTEs)** son consultas temporales que existen solo durante la ejecución de una consulta principal. Permiten crear consultas más legibles y mantenibles.

#### Características de las CTEs:
- **Temporales**: Existen solo durante la ejecución
- **Legibles**: Mejoran la claridad del código
- **Reutilizables**: Se pueden referenciar múltiples veces
- **Recursivos**: Permiten consultas recursivas
- **Modulares**: Dividen consultas complejas en partes

#### Ventajas de las CTEs:
- **Legibilidad**: Código más claro y comprensible
- **Mantenibilidad**: Fácil de modificar y depurar
- **Reutilización**: Referencias múltiples en la misma consulta
- **Recursión**: Manejo de datos jerárquicos
- **Modularidad**: Divide problemas complejos

### Sintaxis de CTEs

#### CTE Simple
```sql
WITH nombre_cte AS (
    SELECT columnas
    FROM tabla
    WHERE condicion
)
SELECT columnas
FROM nombre_cte;
```

**Explicación línea por línea:**
- `WITH nombre_cte AS`: define una CTE
- `(SELECT columnas FROM tabla WHERE condicion)`: consulta que define la CTE
- `SELECT columnas FROM nombre_cte`: consulta principal que usa la CTE

#### CTE Recursivo
```sql
WITH RECURSIVE nombre_cte AS (
    -- Consulta base
    SELECT columnas FROM tabla WHERE condicion_base
    UNION ALL
    -- Consulta recursiva
    SELECT columnas FROM tabla t
    INNER JOIN nombre_cte cte ON t.columna = cte.columna
)
SELECT * FROM nombre_cte;
```

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: CTEs Simples

```sql
-- CTE 1: Productos con estadísticas de ventas
WITH productos_ventas AS (
    SELECT 
        p.id,
        p.nombre,
        p.precio,
        c.nombre AS categoria,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, p.precio, c.nombre
)
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    SUM(total_vendido) AS total_vendido_categoria,
    SUM(ingresos) AS ingresos_totales
FROM productos_ventas
GROUP BY categoria
ORDER BY ingresos_totales DESC;

-- CTE 2: Usuarios con análisis de gastos
WITH usuarios_gastos AS (
    SELECT 
        u.id,
        u.nombre,
        u.email,
        COUNT(p.id) AS total_pedidos,
        COALESCE(SUM(p.total), 0) AS total_gastado,
        COALESCE(AVG(p.total), 0) AS promedio_por_pedido
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.usuario_id
    GROUP BY u.id, u.nombre, u.email
)
SELECT 
    nombre,
    email,
    total_pedidos,
    total_gastado,
    promedio_por_pedido,
    CASE 
        WHEN total_gastado >= 1000 THEN 'Alto'
        WHEN total_gastado >= 500 THEN 'Medio'
        WHEN total_gastado > 0 THEN 'Bajo'
        ELSE 'Sin compras'
    END AS nivel_gasto
FROM usuarios_gastos
ORDER BY total_gastado DESC;
```

### Ejemplo 2: CTEs Recursivos

```sql
-- CTE Recursivo: Jerarquía de empleados
WITH RECURSIVE jerarquia_empleados AS (
    -- Consulta base: empleados sin supervisor
    SELECT 
        id,
        nombre,
        puesto,
        supervisor_id,
        0 AS nivel,
        CAST(nombre AS CHAR(1000)) AS ruta_jerarquica
    FROM empleados
    WHERE supervisor_id IS NULL
    
    UNION ALL
    
    -- Consulta recursiva: empleados con supervisor
    SELECT 
        e.id,
        e.nombre,
        e.puesto,
        e.supervisor_id,
        je.nivel + 1,
        CONCAT(je.ruta_jerarquica, ' -> ', e.nombre)
    FROM empleados e
    INNER JOIN jerarquia_empleados je ON e.supervisor_id = je.id
)
SELECT 
    nombre,
    puesto,
    nivel,
    ruta_jerarquica
FROM jerarquia_empleados
ORDER BY nivel, nombre;
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: CTEs Simples
**Objetivo**: Practicar la creación de CTEs simples.

**Instrucciones**:
1. Crear CTE para productos con estadísticas
2. Crear CTE para usuarios con análisis
3. Crear CTE para análisis de ventas
4. Usar las CTEs para consultas complejas

**Solución paso a paso:**

```sql
-- Consulta 1: CTE para productos con estadísticas
WITH productos_stats AS (
    SELECT 
        p.id,
        p.nombre,
        p.precio,
        c.nombre AS categoria,
        COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
    GROUP BY p.id, p.nombre, p.precio, c.nombre
)
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    SUM(total_vendido) AS total_vendido_categoria,
    SUM(ingresos) AS ingresos_totales
FROM productos_stats
GROUP BY categoria
ORDER BY ingresos_totales DESC;

-- Consulta 2: CTE para usuarios con análisis
WITH usuarios_analisis AS (
    SELECT 
        u.id,
        u.nombre,
        u.email,
        COUNT(p.id) AS total_pedidos,
        COALESCE(SUM(p.total), 0) AS total_gastado,
        COALESCE(AVG(p.total), 0) AS promedio_por_pedido
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.usuario_id
    GROUP BY u.id, u.nombre, u.email
)
SELECT 
    nombre,
    email,
    total_pedidos,
    total_gastado,
    promedio_por_pedido,
    CASE 
        WHEN total_gastado >= 1000 THEN 'Alto'
        WHEN total_gastado >= 500 THEN 'Medio'
        WHEN total_gastado > 0 THEN 'Bajo'
        ELSE 'Sin compras'
    END AS nivel_gasto
FROM usuarios_analisis
ORDER BY total_gastado DESC;
```

### Ejercicio 2: CTEs Recursivos
**Objetivo**: Practicar CTEs recursivos para datos jerárquicos.

**Instrucciones**:
1. Crear CTE recursivo para jerarquía de empleados
2. Crear CTE recursivo para categorías anidadas
3. Crear CTE recursivo para análisis de dependencias
4. Usar las CTEs para análisis jerárquicos

**Solución paso a paso:**

```sql
-- Consulta 1: CTE recursivo para jerarquía de empleados
WITH RECURSIVE jerarquia_empleados AS (
    -- Consulta base: empleados sin supervisor
    SELECT 
        id,
        nombre,
        puesto,
        supervisor_id,
        0 AS nivel,
        CAST(nombre AS CHAR(1000)) AS ruta_jerarquica
    FROM empleados
    WHERE supervisor_id IS NULL
    
    UNION ALL
    
    -- Consulta recursiva: empleados con supervisor
    SELECT 
        e.id,
        e.nombre,
        e.puesto,
        e.supervisor_id,
        je.nivel + 1,
        CONCAT(je.ruta_jerarquica, ' -> ', e.nombre)
    FROM empleados e
    INNER JOIN jerarquia_empleados je ON e.supervisor_id = je.id
)
SELECT 
    nombre,
    puesto,
    nivel,
    ruta_jerarquica
FROM jerarquia_empleados
ORDER BY nivel, nombre;

-- Consulta 2: CTE recursivo para análisis de dependencias
WITH RECURSIVE dependencias AS (
    -- Consulta base: productos sin dependencias
    SELECT 
        id,
        nombre,
        categoria_id,
        0 AS nivel_dependencia,
        CAST(nombre AS CHAR(1000)) AS ruta_dependencia
    FROM productos
    WHERE categoria_id IS NULL
    
    UNION ALL
    
    -- Consulta recursiva: productos con dependencias
    SELECT 
        p.id,
        p.nombre,
        p.categoria_id,
        d.nivel_dependencia + 1,
        CONCAT(d.ruta_dependencia, ' -> ', p.nombre)
    FROM productos p
    INNER JOIN dependencias d ON p.categoria_id = d.id
)
SELECT 
    nombre,
    nivel_dependencia,
    ruta_dependencia
FROM dependencias
ORDER BY nivel_dependencia, nombre;
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de CTEs:
- **CTEs simples**: Consultas temporales básicas
- **CTEs recursivos**: Para datos jerárquicos
- **CTEs múltiples**: Varias CTEs en una consulta

### Ventajas de las CTEs:
- **Legibilidad**: Código más claro
- **Mantenibilidad**: Fácil de modificar
- **Reutilización**: Referencias múltiples
- **Recursión**: Manejo de jerarquías

### Cuándo Usar CTEs:
- **Consultas complejas**: Para simplificar lógica
- **Datos jerárquicos**: Para estructuras recursivas
- **Reutilización**: Cuando necesitas referenciar múltiples veces
- **Legibilidad**: Para hacer código más claro

### Mejores Prácticas:
1. **Nombra descriptivamente** las CTEs
2. **Usa CTEs para legibilidad** en consultas complejas
3. **Aplica CTEs recursivos** para datos jerárquicos
4. **Optimiza el rendimiento** de las CTEs
5. **Documenta el propósito** de cada CTE

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Consultas complejas avanzadas
- Combinación de técnicas
- Optimización de consultas
- Mejores prácticas

---

## 💡 Consejos para el Éxito

1. **Planifica las CTEs**: Piensa en la estructura antes de escribir
2. **Usa nombres descriptivos**: Hace el código más legible
3. **Prueba CTEs recursivos**: Pueden ser complejos de depurar
4. **Optimiza el rendimiento**: Las CTEs pueden ser costosas
5. **Documenta la lógica**: Explica el propósito de cada CTE

---

## 🧭 Navegación

**← Anterior**: [Clase 6: Vistas](clase_6_vistas.md)  
**Siguiente →**: [Clase 8: Consultas Complejas](clase_8_consultas_complejas.md)

---

*¡Excelente trabajo! Ahora dominas las CTEs en SQL. 🚀*
