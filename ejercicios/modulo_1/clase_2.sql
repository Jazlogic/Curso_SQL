-- Tipos de datos
-- Ejemplo prctico.
-- Crear una tabla de empleados

create table users (
    id serial primary key,
    name varchar(50) not null,
    "Last Name" varchar(50) not null,
    email varchar(100) not null unique,
    phone varchar(20) not null unique,
    "Birth Date" date
)

insert into users (name, "Last Name", email, phone, "Birth Date") values
('Michelle', 'Duarte Serrano', 'mds.michelleduarteserrano@gmail.com.com', '8099758881', '2005-11-28'),
('Jefry Agustin', 'Astacio Sanchez', 'jefry.astacio@corripio.com.do', '8294419998', '1999-06-04'),
('Michelle', 'Gonzalez', 'michelle.gonzalez@corripio.com.do', '8294419999', '2000-01-01'),
('Luis', 'Perez', 'luis.perez@corripio.com.do', '8294420000', '2001-05-10');

drop table if exists empleados;
create table empleados(
    id_empleado serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    email varchar(100) not null unique,
    telefono varchar(20) not null unique,
    fecha_nacimiento date not null,
    fecha_contratacion date not null,
    salario decimal(10,2) DEFAULT 0.00 check (salario >= 0.00),
    estado boolean default true,
    departamento_id int,
    fecha_creacion timestamp default current_timestamp,
    fecha_modificacion timestamp default current_timestamp
);

-- Insertar empleados con diferentes tipos de datos

insert into empleados (nombres, apellidos, email, telefono, fecha_nacimiento, fecha_contratacion, salario, estado, departamento_id, fecha_creacion, fecha_modificacion ) values 
('Michelle', 'Duarte Serrano', 'mds.michelleduarteserrano@gmail.com.com', '8099758881', '2005-11-28', '2024-12-03', 30800.00 ,true,1,current_timestamp, current_timestamp),
('Jefry Agustin', 'Astacio Sanchez', 'jefry.astacio@corripio.com.do', '8294419998', '1999-06-04', '2024-12-03', 28200.00 ,false,2,current_timestamp, current_timestamp),
('Michelle', 'Gonzalez', 'michelle.gonzalez@corripio.com.do', '8294419999', '2000-01-01', '2024-12-03', 28200.00 ,true,2,current_timestamp, current_timestamp),
('Luis', 'Perez', 'luis.perez@corripio.com.do', '8294420000', '2001-05-10', '2024-12-03', 28200.00 ,false,2,current_timestamp, current_timestamp);

select * from empleados;

select 
    id_empleado,
    concat(nombres, ' ', apellidos) as nombre_completo,
    email as "Correo Electrónico",
    telefono as "Teléfono",
    fecha_nacimiento as "Fecha de Nacimiento",
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM fecha_nacimiento) -1 as "Edad",
    salario,
    case when estado then 
        'Activo'
    else 
    
        'Inactivo' end as "Estado Empleado"
    from empleados;


select 
    nombres as "Nombre",
    apellidos as "Apellidos",
    extract(year from CURRENT_DATE) - extract(year from fecha_nacimiento) as "Edad",
    extract(year from CURRENT_DATE) - extract(year from fecha_contratacion) as "Tiempo en la Empresa"
from empleados;



select 
    Lower(concat(replace(nombres, ' ',''),'.',replace(apellidos, ' ',''),'@corripio.com.do')) as "Correo Electrónico",
    extract(year from CURRENT_DATE) - extract(year from fecha_nacimiento) as "La Prueba"
from empleados;

-- 🎯 Ejercicios Prácticos
-- Ejercicio 1: Crear Tabla de Productos con Múltiples Tipos

-- Objetivo: Practicar el uso de diferentes tipos de datos y restricciones.

-- Instrucciones: Crea una tabla llamada productos con las siguientes columnas:

-- id: entero, clave primaria, auto-incremento
-- nombre: texto de máximo 200 caracteres, obligatorio
-- descripcion: texto largo
-- precio: decimal con 2 decimales, obligatorio, mayor que 0
-- stock: entero, no puede ser negativo
-- categoria: texto de máximo 50 caracteres
-- activo: booleano, por defecto verdadero
-- fecha_creacion: timestamp automático
-- fecha_modificacion: timestamp que se actualiza automáticamente
select * from productos;
drop table if exists productos;

create table Productos(
    id_productos serial primary key,
    nombre varchar(200) not null,
    descripcion text,
    precio decimal(10,2) not null check (precio > 0.00),
    stock int not null check (stock >= 0),
    categoria varchar(100) not null check (categoria in ('Electrónico', 'Ropa', 'Hogar', 'Deportes', 'Juguetes')),
    estado boolean default true,
    fecha_creacion timestamp default current_timestamp,
    fecha_modificacion timestamp default current_timestamp
);

INSERT INTO Productos (nombre, descripcion, precio, stock, categoria,estado,fecha_creacion) VALUES
('Lenovo Legion', 'PC de escritorio de alto rendimiento con procesador Intel i7 y 64GB de RAM', 1299.99, 9, 'Electrónico',true,'2025-5-01'),
('Laptop Lenovo', 'Laptop de 15 pulgadas con procesador Intel i7 y 64GB de RAM', 1299.99, 0, 'Electrónico',true,'2024-12-03'),
('Laptop HP', 'Laptop de 15 pulgadas con procesador Intel i7', 899.99, 0, 'Electrónico',false),
('Mouse Inalámbrico', 'Mouse óptico inalámbrico con batería de larga duración', 25.50, 50, 'Electrónico',true),
('Teclado Mecánico', 'Teclado mecánico con switches Cherry MX', 89.99, 15, 'Electrónico',true);



-- Ejercicio 3: Consultar Productos con Cálculos
-- Objetivo: Practicar consultas con diferentes tipos de datos y funciones.

-- Instrucciones: Crea una consulta que muestre:

-- ID del producto
-- Nombre del producto
-- Precio con formato de moneda
-- Stock con indicador de disponibilidad
-- Estado del producto (Activo/Inactivo)
-- Días desde la creación

select * from Productos where id_productos = 2;
select 
    id_productos as "ID",
    nombre as "Nombre",
    concat('DOP$ ',precio) as "Precio",
    case 
        when stock > 10 then
            'Disponible'
        when stock > 0 then
            'Pocas Unidades'
    else 
        'Agotados'
        end as "Disponibilidad",
    case when estado then
        'Activo'
    else 
        'Inactivo'
    end as "Estado",
    -- concat((extract(month from CURRENT_DATE) - extract(month from fecha_creacion)), " meses y ", extract(days from CURRENT_DATE) - extract(days from fecha_creacion), " días"  ) as "Días desde la creación"
    concat('',
        case 
            when (extract(month from CURRENT_DATE) - extract(month from fecha_creacion)) < 0 and (extract(year from CURRENT_DATE) - extract(year from fecha_creacion)) > 0 then
                12 - (extract(month from fecha_creacion) - extract(month from CURRENT_DATE)) 
            else
                extract(month from CURRENT_DATE) - extract(month from fecha_creacion)
        end,
        ' meses y ',
        extract(days from CURRENT_DATE) - extract(days from fecha_creacion),
        ' días'
        ) as "Tiempo de Creacion"
   
from Productos;


-- =========================== 20 🔹 Ejercicios de Consultas Complejas (solo descripción) ===========================


-- 1. Productos disponibles

-- Lista todos los productos mostrando su nombre y un campo calculado que diga “Disponible” si el stock es mayor que 0 y “Agotado” si es igual a 0.
-- (Usar CASE con condición en stock.)
select 
    nombre as "Nombre",
    case
        when stock > 0 then
            'Disponible'
        else    
            'Agotado'
        end as "Disponibilidad"
from Productos;


-- 2. Precio formateado

-- Muestra el nombre del producto y su precio anteponiendo “DOP$” como texto.
-- (Usar CONCAT para unir texto y número.)

select 
    nombre as "Nombre",
    concat('DOP$ ', precio) as "Precio"
from Productos;


-- 3. Nombre con inicial mayúscula

-- Muestra los nombres de los productos con la primera letra de cada palabra en mayúscula.
-- (Usar INITCAP para formatear el texto.)

select 
    initcap(nombre) as "Nombre"
from Productos;


-- 4. Productos caros

-- Lista todos los productos cuyo precio sea mayor a 1,000.
-- (Usar WHERE con condición de precio.)

select 
    nombre as "Nombre",
    concat('DOP$ ',precio) as "Precio"
from Productos
where precio > 1000;


-- 5. Conteo por categoría

-- Muestra cuántos productos hay en cada categoría.
-- (Usar GROUP BY y COUNT.)
select * from Productos;

SELECT 
    categoria as "Categoría",
    count(*) as "Cantidad"
FROM Productos
GROUP BY categoria;

select 
    estado as "Estado",
    count(*) as "Cantidad"
from Productos
group by estado;

select 
    count(*) 
from Productos;

SELECT categoria, AVG(precio)
FROM Productos
GROUP BY categoria;

SELECT categoria, sum(precio)
FROM Productos
GROUP BY categoria;

SELECT categoria, max(precio)
FROM Productos
GROUP BY categoria;

SELECT categoria, min(precio)
FROM Productos
GROUP BY categoria;

-- 6. Categoría con más productos

-- Obtén la categoría que tenga más productos registrados.
-- (Usar GROUP BY, COUNT, ORDER BY DESC y LIMIT.)

select 
    categoria as "Categorias",
    count(*) as "Cantidad"
from Productos
group by categoria;

SELECT categoria, COUNT(*) 
FROM productos
GROUP BY categoria
ORDER BY COUNT(*) DESC
limit 2;







-- 7. Productos sin stock

-- Lista los nombres y el stock de los productos que estén agotados (stock = 0).
-- (Usar WHERE con condición de stock.)

select 
    nombre as "Producto",
    stock as "Disponibilidad"
from Productos
where stock = 0;

   

-- 8. Clasificación por rango de precios

-- Clasifica los productos como “Barato”, “Medio” o “Caro” según su precio.
-- (Usar CASE con varias condiciones y rangos de precios.)
select
    nombre as "Nombre del producto",
    concat('RD$ ',(case when precio > 100 and precio < 500 then
            'Regular'
        when precio > 501 then
            'Original'
        else 
            'Barato'
    end), ' ', precio) as "Precio"
from Productos;

-- 9. Nombre sin espacios

-- Muestra los nombres de los productos eliminando espacios al inicio y al final.
-- (Usar TRIM para limpiar el texto.)

select 
    nombre as "Producto",
    trim(nombre) as "Nombre"
from Productos;



-- 10. Productos creados este mes

-- Muestra los productos creados en el mes actual.
-- (Usar EXTRACT(MONTH) para comparar mes actual con fecha_creación.)
select *
from Productos
where extract(month from fecha_creacion) = extract(month from current_date) and extract(year from fecha_creacion) = extract(year from current_date);


-- 11. Meses desde la creación

-- Muestra el nombre del producto y los meses transcurridos desde su fecha de creación hasta hoy.
-- (Usar AGE para diferencia de fechas y EXTRACT para obtener meses.)


-- 12. Stock total por categoría

-- Muestra la suma total del stock de productos por categoría.
-- (Usar SUM y GROUP BY.)


-- 13. Precio promedio por categoría

-- Muestra el precio promedio de los productos en cada categoría redondeado a dos decimales.
-- (Usar AVG y ROUND con GROUP BY.)


-- 14. Productos más caros que el promedio

-- Lista todos los productos cuyo precio sea mayor que el precio promedio de todos los productos.
-- (Usar subconsulta para calcular el promedio y compararlo.)



-- 15. Productos de categorías específicas

-- Lista los productos que sean de las categorías “Electrónico” y “Deportes”.
-- (Usar IN para filtrar varias categorías.)



-- 16. Estado del producto en texto

-- Muestra los productos indicando “Activo” si estado = TRUE o “Inactivo” si estado = FALSE.
-- (Usar CASE para convertir booleano en texto.)


-- 17. Productos por fecha de modificación

-- Lista los productos ordenados por fecha de modificación del más reciente al más antiguo.
-- (Usar ORDER BY fecha_modificacion DESC.)



-- 18. Valor total del inventario

-- Calcula el valor total del inventario multiplicando precio * stock de todos los productos.
-- (Usar SUM de la multiplicación.)




-- 19. Productos que contengan “Cámara”

-- Lista los productos cuyo nombre contenga la palabra “Cámara” sin importar mayúsculas o minúsculas.
-- (Usar ILIKE con comodines %.)



-- 20. Productos creados en los últimos 30 días

-- Lista los productos creados en los últimos 30 días a partir de hoy.
-- (Usar CURRENT_DATE con INTERVAL para filtrar por fecha.)




-- Ejercicio 3: Consultar Productos con Cálculos
-- Objetivo: Practicar consultas con diferentes tipos de datos y funciones.

-- Instrucciones: Crea una consulta que muestre:

-- ID del producto
-- Nombre del producto
-- Precio con formato de moneda
-- Stock con indicador de disponibilidad
-- Estado del producto (Activo/Inactivo)
-- Días desde la creación

select 
    id_productos,
    nombre,
    descripcion,
    concat('DOP$', precio) as "Precio",
    case when stock <= 0 then concat('Agotado ',stock)
    when stock <= 20 then concat('Escasos ',stock)
    else concat('Disponible ',stock) end as "Cantidades",
    case when estado = true then 'Activo' else 'Inactivo' end as "Estado",
    current_date - fecha_creacion::date as "Días desde la creación"
from Productos;

