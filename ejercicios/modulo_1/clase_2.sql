-- Tipos de datos
-- Ejercicio 1
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
        case when estado then 
            'Bloqueado'
        else
            'Activo'
        end as "Estado del empleado"
    from empleados;


     

