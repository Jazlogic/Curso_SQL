# Clase 6: Vistas - Simplificando Consultas

## 📚 Descripción de la Clase
En esta clase aprenderás a crear y gestionar vistas en SQL, una herramienta fundamental para simplificar consultas complejas, mejorar la seguridad y organizar el acceso a los datos. Dominarás vistas simples, complejas, y técnicas de optimización.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las vistas y por qué son útiles
- Crear vistas simples y complejas
- Gestionar vistas (crear, modificar, eliminar)
- Usar vistas para simplificar consultas
- Aplicar vistas para mejorar la seguridad
- Optimizar el rendimiento de vistas

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Vistas?

Las **vistas** son consultas SQL almacenadas que actúan como tablas virtuales. Permiten acceder a datos de múltiples tablas de manera simplificada.

#### Características de las Vistas:
- **Tablas virtuales**: No almacenan datos físicamente
- **Consultas almacenadas**: Se ejecutan cuando se accede a ellas
- **Simplificación**: Ocultar complejidad de consultas
- **Seguridad**: Controlar acceso a datos sensibles
- **Mantenibilidad**: Centralizar lógica de negocio

#### Ventajas de las Vistas:
- **Simplicidad**: Consultas más fáciles de escribir
- **Seguridad**: Control granular de acceso
- **Mantenibilidad**: Cambios centralizados
- **Reutilización**: Lógica compartida
- **Abstracción**: Ocultar estructura interna

### Sintaxis de Vistas

#### Crear Vista
```sql
CREATE VIEW nombre_vista AS
SELECT columnas
FROM tabla
WHERE condicion;
```

**Explicación línea por línea:**
- `CREATE VIEW nombre_vista AS`: crea una nueva vista
- `SELECT columnas FROM tabla WHERE condicion`: consulta que define la vista
- La vista se comporta como una tabla virtual

#### Modificar Vista
```sql
ALTER VIEW nombre_vista AS
SELECT columnas
FROM tabla
WHERE condicion;
```

#### Eliminar Vista
```sql
DROP VIEW nombre_vista;
```

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Vistas Simples

```sql
-- Vista 1: Productos con información de categoría
CREATE VIEW vista_productos_categoria AS
SELECT 
    p.id,
    p.nombre AS producto,
    p.precio,
    p.stock,
    c.nombre AS categoria,
    c.descripcion AS descripcion_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Usar la vista
SELECT * FROM vista_productos_categoria WHERE precio > 100;

-- Vista 2: Usuarios con estadísticas de pedidos
CREATE VIEW vista_usuarios_estadisticas AS
SELECT 
    u.id,
    u.nombre AS usuario,
    u.email,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado,
    COALESCE(AVG(p.total), 0) AS promedio_por_pedido
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email;

-- Usar la vista
SELECT * FROM vista_usuarios_estadisticas WHERE total_gastado > 500;
```

### Ejemplo 2: Vistas Complejas

```sql
-- Vista 3: Análisis completo de ventas
CREATE VIEW vista_analisis_ventas AS
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    u.nombre AS usuario,
    pr.nombre AS producto,
    c.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal,
    p.total AS total_pedido
FROM pedidos p
INNER JOIN usuarios u ON p.usuario_id = u.id
INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
INNER JOIN productos pr ON dp.producto_id = pr.id
INNER JOIN categorias c ON pr.categoria_id = c.id;

-- Usar la vista
SELECT 
    categoria,
    SUM(subtotal) AS ventas_totales,
    COUNT(DISTINCT usuario) AS usuarios_unicos
FROM vista_analisis_ventas
GROUP BY categoria
ORDER BY ventas_totales DESC;
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Crear Vistas Básicas
**Objetivo**: Practicar la creación de vistas simples.

**Instrucciones**:
1. Crear vista de productos con categoría
2. Crear vista de usuarios con estadísticas
3. Crear vista de pedidos con información completa
4. Usar las vistas para consultas simples

**Solución paso a paso:**

```sql
-- Consulta 1: Vista de productos con categoría
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id,
    p.nombre AS producto,
    p.precio,
    p.stock,
    c.nombre AS categoria,
    c.descripcion AS descripcion_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Usar la vista
SELECT * FROM vista_productos_completa WHERE precio > 100;

-- Consulta 2: Vista de usuarios con estadísticas
CREATE VIEW vista_usuarios_completa AS
SELECT 
    u.id,
    u.nombre AS usuario,
    u.email,
    u.fecha_registro,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado,
    COALESCE(AVG(p.total), 0) AS promedio_por_pedido,
    MAX(p.fecha_pedido) AS ultima_compra
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email, u.fecha_registro;

-- Usar la vista
SELECT * FROM vista_usuarios_completa WHERE total_gastado > 500;
```

### Ejercicio 2: Vistas Complejas
**Objetivo**: Crear vistas complejas para análisis avanzados.

**Instrucciones**:
1. Crear vista de análisis de ventas
2. Crear vista de productos más vendidos
3. Crear vista de categorías con estadísticas
4. Usar las vistas para análisis complejos

**Solución paso a paso:**

```sql
-- Consulta 1: Vista de análisis de ventas
CREATE VIEW vista_ventas_analisis AS
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    u.nombre AS usuario,
    pr.nombre AS producto,
    c.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal,
    p.total AS total_pedido
FROM pedidos p
INNER JOIN usuarios u ON p.usuario_id = u.id
INNER JOIN detalle_pedidos dp ON p.id = dp.pedido_id
INNER JOIN productos pr ON dp.producto_id = pr.id
INNER JOIN categorias c ON pr.categoria_id = c.id;

-- Usar la vista
SELECT 
    categoria,
    SUM(subtotal) AS ventas_totales,
    COUNT(DISTINCT usuario) AS usuarios_unicos
FROM vista_ventas_analisis
GROUP BY categoria
ORDER BY ventas_totales DESC;

-- Consulta 2: Vista de productos más vendidos
CREATE VIEW vista_productos_vendidos AS
SELECT 
    p.id,
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS ingresos_generados,
    COUNT(DISTINCT dp.pedido_id) AS pedidos_unicos
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
GROUP BY p.id, p.nombre, p.precio, c.nombre;

-- Usar la vista
SELECT * FROM vista_productos_vendidos 
WHERE total_vendido > 0 
ORDER BY total_vendido DESC;
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de Vistas:
- **Vistas simples**: Consultas básicas sobre una o pocas tablas
- **Vistas complejas**: Consultas con JOINs, agregaciones y subconsultas
- **Vistas materializadas**: Vistas que almacenan datos físicamente

### Ventajas de las Vistas:
- **Simplicidad**: Consultas más fáciles de escribir
- **Seguridad**: Control granular de acceso
- **Mantenibilidad**: Cambios centralizados
- **Reutilización**: Lógica compartida

### Mejores Prácticas:
1. **Nombra descriptivamente** las vistas
2. **Documenta el propósito** de cada vista
3. **Optimiza las consultas** subyacentes
4. **Usa vistas para seguridad** de datos
5. **Mantén las vistas actualizadas**

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Common Table Expressions (CTEs)
- CTEs recursivos
- CTEs vs subconsultas
- Técnicas avanzadas con CTEs

---

## 💡 Consejos para el Éxito

1. **Planifica las vistas**: Piensa en los casos de uso
2. **Usa nombres descriptivos**: Hace el código más legible
3. **Optimiza las consultas**: Las vistas pueden ser lentas
4. **Documenta el propósito**: Explica para qué sirve cada vista
5. **Mantén la consistencia**: Usa convenciones de nomenclatura

---

## 🧭 Navegación

**← Anterior**: [Clase 5: Funciones de Ventana](clase_5_funciones_ventana.md)  
**Siguiente →**: [Clase 7: CTEs](clase_7_ctes.md)

---

*¡Excelente trabajo! Ahora dominas las vistas en SQL. 🚀*
