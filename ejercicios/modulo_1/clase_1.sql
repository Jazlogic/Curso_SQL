drop table if exists productos;
CREATE TABLE productos (
    id serial PRIMARY KEY ,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop HP', 899.99, 10),
('Mouse Inalámbrico', 25.50, 50),
('Teclado Mecánico', 89.99, 15);

SELECT * FROM productos;


/d productos;

-- Ejercicio 1;

create database biblioteca;


create table libros (
    id serial primary key,
    titulo varchar(200) not null,
    autor varchar(100) not null,
    anio_publicacion int,
    genero varchar(50)
);

insert into libros (titulo, autor, anio_publicacion, genero) values ('Cien años de soledad', 'Gabriel García Márquez', 1967, 'Realismo Mágico'),
('Orgullo y prejuicio', 'Jane Austen', 1813, 'Romance'),
('1984', 'George Orwell', 1949, 'Distopía'),
('Don Quijote de la Mancha', 'Miguel de Cervantes', 1605, 'Clásico'),
('El principito', 'Antoine de Saint-Exupéry', 1943, 'Fábula'),
('Crimen y castigo', 'Fiódor Dostoyevsky', 1866, 'Policial'),
('Matar a un ruiseñor', 'Harper Lee', 1960, 'Distopía');

-- select titulo from libros where genero = 'Romance';
select id from libros;