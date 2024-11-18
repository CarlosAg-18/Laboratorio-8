create database if not exists Libreria;
use Libreria;

-- PASO 1: Crear las tablas
-- Crear tabla de dimensión de tiempo
CREATE TABLE dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    año INT,
    mes INT,
    dia INT,
    trimestre INT
);

-- Crear tabla de dimensión de libros
CREATE TABLE dim_libro (
    id_libro INT PRIMARY KEY,
    titulo VARCHAR(100),
    autor VARCHAR(100),
    genero VARCHAR(50),
    precio_unitario DECIMAL(10, 2)
);

-- Crear tabla de dimensión de clientes
CREATE TABLE dim_cliente (
    id_cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(100),
    edad INT,
    genero VARCHAR(10),
    ciudad VARCHAR(100)
);

-- Crear tabla de dimensión de tiendas
CREATE TABLE dim_tienda (
    id_tienda INT PRIMARY KEY,
    nombre_tienda VARCHAR(100),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

-- Crear tabla de hechos para las ventas de libros
CREATE TABLE hechos_ventas_libros (
    id_venta INT PRIMARY KEY,
    id_tiempo INT,
    id_libro INT,
    id_cliente INT,
    id_tienda INT,
    cantidad INT,
    precio_total DECIMAL(10, 2),
    FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo),
    FOREIGN KEY (id_libro) REFERENCES dim_libro(id_libro),
    FOREIGN KEY (id_cliente) REFERENCES dim_cliente(id_cliente),
    FOREIGN KEY (id_tienda) REFERENCES dim_tienda(id_tienda)
);

-- PASO 2: Insertar datos
-- Insertar datos en dim_tiempo
INSERT INTO dim_tiempo VALUES
(1, 2024, 11, 18, 4),
(2, 2024, 10, 5, 4),
(3, 2024, 9, 15, 3);

-- Insertar datos en dim_libro
INSERT INTO dim_libro VALUES
(1, 'El Principito', 'Antoine de Saint-Exupéry', 'Ficción', 150.00),
(2, '1984', 'George Orwell', 'Distopía', 200.00),
(3, 'Cien Años de Soledad', 'Gabriel García Márquez', 'Realismo Mágico', 180.00),
(4, 'Sapiens', 'Yuval Noah Harari', 'Historia', 250.00),
(5, 'El Arte de la Guerra', 'Sun Tzu', 'Filosofía', 120.00);

-- Insertar datos en dim_cliente
INSERT INTO dim_cliente VALUES
(1, 'Carlos Pérez', 30, 'Masculino', 'Ciudad de México'),
(2, 'Ana López', 25, 'Femenino', 'Guadalajara'),
(3, 'Luis Hernández', 35, 'Masculino', 'Monterrey'),
(4, 'María Gómez', 28, 'Femenino', 'Puebla'),
(5, 'Jorge Díaz', 40, 'Masculino', 'Tijuana');

-- Insertar datos en dim_tienda
INSERT INTO dim_tienda VALUES
(1, 'Librería Centro', 'Ciudad de México', 'México'),
(2, 'Librería Chapultepec', 'Guadalajara', 'México'),
(3, 'Librería Norte', 'Monterrey', 'México');

-- Insertar datos en hechos_ventas_libros
INSERT INTO hechos_ventas_libros VALUES
(1, 1, 1, 1, 1, 2, 300.00),
(2, 1, 2, 2, 2, 1, 200.00),
(3, 2, 3, 3, 3, 3, 540.00),
(4, 2, 4, 4, 1, 1, 250.00),
(5, 3, 5, 5, 2, 5, 600.00),
(6, 3, 1, 1, 3, 1, 150.00),
(7, 1, 3, 2, 1, 2, 360.00),
(8, 2, 2, 3, 2, 1, 200.00),
(9, 3, 5, 4, 3, 1, 120.00),
(10, 1, 4, 5, 1, 3, 750.00);

-- PASO 3: Realizar Consultas de Análisis
-- Consulta 1: Total de ventas (precio_total) por género de libro y mes
SELECT 
    dl.genero,
    dt.mes,
    SUM(hvl.precio_total) AS total_ventas
FROM hechos_ventas_libros hvl
JOIN dim_libro dl ON hvl.id_libro = dl.id_libro
JOIN dim_tiempo dt ON hvl.id_tiempo = dt.id_tiempo
GROUP BY dl.genero, dt.mes
ORDER BY dl.genero, dt.mes;

-- Consulta 2: Cantidad total de libros vendidos por tienda y autor
SELECT 
    dt.nombre_tienda,
    dl.autor,
    SUM(hvl.cantidad) AS total_libros_vendidos
FROM hechos_ventas_libros hvl
JOIN dim_tienda dt ON hvl.id_tienda = dt.id_tienda
JOIN dim_libro dl ON hvl.id_libro = dl.id_libro
GROUP BY dt.nombre_tienda, dl.autor
ORDER BY dt.nombre_tienda, dl.autor;

-- Consulta 3: Ingresos totales por ciudad de cliente y trimestre
SELECT 
    dc.ciudad AS ciudad_cliente,
    dt.trimestre,
    SUM(hvl.precio_total) AS ingresos_totales
FROM hechos_ventas_libros hvl
JOIN dim_cliente dc ON hvl.id_cliente = dc.id_cliente
JOIN dim_tiempo dt ON hvl.id_tiempo = dt.id_tiempo
GROUP BY dc.ciudad, dt.trimestre
ORDER BY dc.ciudad, dt.trimestre;


-- Consulta 4: Total de ventas de cada cliente y número de libros comprados
SELECT 
    dc.nombre_cliente,
    SUM(hvl.precio_total) AS total_ventas,
    SUM(hvl.cantidad) AS total_libros_comprados
FROM hechos_ventas_libros hvl
JOIN dim_cliente dc ON hvl.id_cliente = dc.id_cliente
GROUP BY dc.nombre_cliente
ORDER BY total_ventas DESC;