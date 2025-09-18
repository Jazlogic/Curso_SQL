-- Borrando Base de datos si existe
drop if exists database biblioteca;
-- Creando Base de datos.
create database biblioteca;


-- Creando tabla autores.

create table autores(
    id_autor serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    fecha_nacimiento date,
    nacionalidad varchar(100) default 'Desconocida',
    biografia text,
    fecha_registro date default current_date,
    fecha_modificacion date default current_date,
    estado boolean default true
);

-- Creando tabla editoriales
create table editoriales(
    id_editorial serial primary key,
    nombre varchar(100) not null,
    direccion varchar(300),
    telefono varchar(20),
    email varchar(100)
);

-- Creando tabla categorías

create table categorias(
    id_categoria serial primary key,
    nombre varchar(100) not null check (nombre in ('Ficción', 'No Ficción', 'Ciencia', 'Terror', 'Romance', 'Comedia')),
    descripcion text
);

-- Creando tabla libros (con ultiples relaciones).

create table libros(
    id_libro serial primary key,
    isbn varchar(20) not null unique,
    titulo varchar(200) not null,
    id_autor int not null,
    id_editorial int not null,
    id_categoria int not null,
    "año_publicacion" int,
    numero_paginas int,
    precio decimal(10,2) default 0.00,
    disponubilidad boolean default true,
    foreign key (id_autor) references autores(id_autor),
    foreign key (id_editorial) references editoriales(id_editorial),
    foreign key (id_categoria) references categorias(id_categoria)
 );


 -- Creando tabla Usuarios.

 create table usuarios(
    id_usuario serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    email varchar(100) not null unique,
    telefono varchar(20),
    direccion varchar(300),
    fecha_registro date default current_date
 );

 -- Creando tabla de Préstamos.

 create table prestamos(
    id_prestamo serial primary key,
    id_usuario int not null,
    id_libro int not null,
    fecha_prestamo date default current_date,
    fecha_devolucion_esperada date,
    fecha_devolucion_real date,
    devuelto boolean default false,
    foreign key (id_usuario) references usuarios(id_usuario),
    foreign key (id_libro) references libros(id_libro),
    unique (id_usuario, id_libro, fecha_prestamo)
 );

-- datos de prueba.

-- Insertar autores
INSERT INTO autores (nombres, apellidos, fecha_nacimiento, nacionalidad) VALUES
('Gabriel', 'García Márquez', '1927-03-06', 'Colombiano'),
('Miguel', 'de Cervantes', '1547-09-29', 'Español'),
('George', 'Orwell', '1903-06-25', 'Británico');
select * from autores;

-- Insertar editoriales
INSERT INTO editoriales (nombre, direccion, telefono, email) VALUES
('Cátedra', 'Calle Alcalá 95, Madrid', '915 31 22 00', 'info@catedra.com'),
('Debolsillo', 'Calle Torrelaguna 60, Madrid', '915 33 03 00', 'info@debolsillo.com'),
('Plaza & Janés', 'Calle Provenza 260, Barcelona', '934 88 00 00', 'info@plazayjanes.com');

-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Romance', 'Obras de ficción narrativa'),
('Ficción', 'Obras de ficción con elementos científicos'),
('Ficción', 'Género literario que combina realidad y fantasía');
select * from categorias;

-- Insertar libros (con referencias a las tablas relacionadas)
INSERT INTO libros (isbn, titulo, id_autor, id_editorial, id_categoria, "año_publicacion", numero_paginas, precio) VALUES
('978-84-376-0494-7', 'Cien años de soledad', 4, 2, 3, 1967, 471, 12.95),
('978-84-376-0495-4', 'El Quijote', 5, 2, 2, 1605, 863, 15.50),
('978-84-376-0496-1', '1984', 6, 3, 3, 1949, 326, 9.95);
select * from libros;

-- Insertar usuarios
INSERT INTO usuarios (nombres, apellidos, email, telefono) VALUES
('Ana', 'García', 'ana.garcia@email.com', '612345678'),
('Carlos', 'López', 'carlos.lopez@email.com', '623456789'),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '634567890');

-- Insertar préstamos (relaciones N:N)
INSERT INTO prestamos (id_usuario, id_libro, fecha_prestamo, fecha_devolucion_esperada) VALUES
(2, 19, '2024-01-15', '2024-02-15'),  -- Ana presta "Cien años de soledad"
(2, 21, '2024-01-20', '2024-02-20'),  -- Carlos presta "El Quijote"
(3, 20, '2024-01-10', '2024-02-10'),  -- María presta "1984"
(2, 21, '2024-01-25', '2024-02-25');  -- Ana también presta "1984"
select * from prestamos;

-- Consultas con joins
-- Consulta 1: Ver libros con información de autor y editorial
select 
    concat(a.nombres, ' ', a.apellidos) as "Autor",
    l.titulo as "Título del Libro",
    e.nombre as "Editorial",
    c.nombre as "Categoria",
    l."año_publicacion" as "Año de Publicación",
    l.precio as "Precio"
from libros l
join autores a on l.id_autor = a.id_autor
join editoriales e on l.id_editorial = e.id_editorial
join categorias c on l.id_categoria = c.id_categoria

-- Consulta 2: Ver préstamos con información de usuario y libro

select 
    p.id_prestamo as "ID Préstamo",
    concat(u.nombres, ' ', u.apellidos) as "Usuario",
    l.titulo as "Libro Prestado",
    p.fecha_prestamo as "Fecha Préstamo",
    p.fecha_devolucion_esperada as "Fecha Devolución Esperada",
    p.fecha_devolucion_real as "Fecha Devolución Real",
    case when p.devuelto then 'Devuelto' else 'No devuelto' end as "Devuelto"
from prestamos p
join usuarios u on p.id_usuario = u.id_usuario
join libros l on p.id_libro = l.id_libro

-- Consulta 3: Contar libros por categoría
select 
    c.nombre as "Categoria",
    count(l.id_libro) as "Cantidad de lbros"
from libros l
join categorias c on l.id_categoria = c.id_categoria
group by c.nombre;


-- 🎯 Ejercicios Prácticos
-- Ejercicio 1: Sistema de Tienda Online
-- Objetivo: Crear un sistema de tienda online con relaciones entre tablas.

-- Instrucciones: Crea las siguientes tablas con sus relaciones:

create database Sistema_de_Tienda_Online;
-- use Sistema_de_Tienda_Online;

-- clientes: id, nombre, email, telefono, direccion
create table clientes(
    id_cliente serial primary key,
    nombre varchar(100) not null,
    email varchar(200) not null unique,
    telefono varchar(20),
    direccion varchar(255)
);

-- categorias: id, nombre, descripcion
create table categorias(
    id_categoria serial primary key,
    nombre varchar(100) not null,
    descripcion text
);

-- productos: id, nombre, descripcion, precio, stock, categoria_id
create table productos(
    id_producto serial primary key,
    nombre varchar(200) not null,
    descripcion text,
    precio decimal(10,2) not null default 0.00,
    stock int default 0,
    id_categoria int,
    foreign key (id_categoria) references categorias(id_categoria)
);

-- pedidos: id, numero_pedido, cliente_id, fecha_pedido, total
create table pedidos(
    id_pedido serial primary key,
    numero_pedido varchar(50) not null unique,
    id_cliente int,
    fecha_pedido date not null default current_date,
    total decimal(10,2) not null default 0.00,
    foreign key (id_cliente) references clientes(id_cliente)
);

-- detalles_pedidos: id, pedido_id, producto_id, cantidad, precio_unitario
create table detalles_pedidos(
    id_detalles_pedido serial primary key,
    id_pedido int not null,
    id_producto int not null,
    cantidad int not null default 1,
    precio_unitario decimal(10,2) not null default 0.00,
    foreign key (id_pedido) references pedidos(id_pedido),
    foreign key (id_producto) references productos(id_producto)
);

-- Ejercicio 2: Insertar Datos con Relaciones
-- Objetivo: Practicar la inserción de datos en tablas relacionadas.

-- Instrucciones: Inserta datos de ejemplo en todas las tablas, asegurándote de que las relaciones sean correctas.
-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Ropa', 'Vestimenta y accesorios de moda'),
('Hogar', 'Artículos para el hogar y decoración');

-- Insertar clientes
INSERT INTO clientes (nombre, email, telefono, direccion) VALUES
('Juan Pérez', 'juan.perez@email.com', '612345678', 'Calle Mayor 123, Madrid'),
('María García', 'maria.garcia@email.com', '623456789', 'Avenida de la Paz 45, Barcelona'),
('Carlos López', 'carlos.lopez@email.com', '634567890', 'Plaza España 12, Valencia');

-- Insertar productos
INSERT INTO productos (nombre, descripcion, precio, stock, id_categoria) VALUES
('iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 25, 7),
('Samsung Galaxy S23', 'Smartphone Android con pantalla AMOLED', 899.99, 30, 7),
('Camiseta Algodón', 'Camiseta 100% algodón, varios colores', 19.99, 100, 8),
('Pantalón Vaquero', 'Pantalón vaquero clásico, corte regular', 49.99, 50, 8),
('Lámpara LED', 'Lámpara LED de escritorio, luz blanca', 29.99, 75, 7),
('Cafetera Eléctrica', 'Cafetera automática con molinillo', 89.99, 20, 7);

-- Insertar pedidos
INSERT INTO pedidos (numero_pedido, id_cliente, fecha_pedido, total) VALUES
('PED-001', 7, '2024-01-15', 1019.98),
('PED-002', 8, '2024-01-16', 69.98),
('PED-003', 9, '2024-01-17', 119.98);
select * from detalles_pedidos;
select * from categorias;
select * from clientes;
select * from productos;
select * from pedidos;

-- Insertar detalles de pedidos
INSERT INTO detalles_pedidos ( id_pedido, id_producto, cantidad, precio_unitario) VALUES
-- Detalles del pedido 1 (Juan Pérez)
(1, 13, 1, 999.99),  -- iPhone 14
(1, 16, 1, 19.99),   -- Camiseta Algodón

Detalles del pedido 2 (María García)
(2, 16, 2, 19.99),   -- 2 Camisetas Algodón
(2, 17, 1, 49.99),   -- 1 Pantalón Vaquero

Detalles del pedido 3 (Carlos López)
(3, 18, 2, 29.99),   -- 2 Lámparas LED
(3, 16, 18, 89.99);   -- 1 Cafetera Eléctrica

-- Ejercicio 3: Consultas con Múltiples Relaciones
-- Objetivo: Practicar consultas que combinen información de múltiples tablas.

-- Instrucciones: Crea consultas que muestren:

-- ===================================================
select * from pedidos;
select * from clientes;
-- Todos los pedidos con información del cliente
select 
    c.nombre as "Nombre del Cliente",
    p.numero_pedido as "Número de Pedido",
    p.fecha_pedido as "Fecha del Pedido",
    p.total,
    count(*) as "Cantidad de Pedidos"
from 
    pedidos p
join clientes c on p.id_cliente = c.id_cliente
group by c.nombre, p.numero_pedido, p.fecha_pedido, p.total
order by p.fecha_pedido desc;

-- ===============================================================================
select * from pedidos;
select * from detalles_pedidos;
select * from productos;
select * from clientes;
-- Detalles de cada pedido con productos
select 
    p.numero_pedido as "Numero de Pedido",
    p.fecha_pedido as "Fecha del Pedido",
    p.id_cliente as "Id del Cliente",
    p.total as "Total del pedido",
    -- pd.numero_detalles_pedido as "Numero de Detalle",
    pd.id_producto as "Id del Producto",
    pd.cantidad as "Cantidad",
    pd.precio_unitario as "Precio Unitario",
    pr.nombre as "Nombre del Producto",
    pr.precio as "Precio del Producto",
    pr.descripcion as "Descripcion del Producto",
    concat('RD$ ', p.total) as "Total de Gastos"
from 
    detalles_pedidos pd
join pedidos p on p.id_pedido = pd.id_pedido
join productos pr on pd.id_producto = pr.id_producto;

SELECT 
    p.numero_pedido,
    c.nombre AS cliente,
    pr.nombre AS producto,
    cat.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN detalles_pedidos dp ON p.id_pedido = dp.id_pedido
JOIN productos pr ON dp.id_producto = pr.id_producto
JOIN categorias cat ON pr.id_categoria = cat.id_categoria
ORDER BY p.numero_pedido, pr.nombre;
    
-- Resumen de ventas por categoría


