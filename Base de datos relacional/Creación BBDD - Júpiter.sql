-- Crear la base de datos:

CREATE DATABASE IF NOT EXISTS bd_deteccion_fakenews;
USE bd_deteccion_fakenews;

------------------------------------------------------------

-- Crear las tablas:
DROP TABLE IF EXISTS noticias;
DROP TABLE IF EXISTS contenido;
DROP TABLE IF EXISTS tipo;
DROP TABLE IF EXISTS pais_idioma;
DROP TABLE IF EXISTS fuente;
DROP TABLE IF EXISTS autor;

CREATE TABLE contenido (
id_noticia SMALLINT(5) PRIMARY KEY,
titulo VARCHAR(300),
texto LONGTEXT
);

CREATE TABLE tipo (
id_tipo SMALLINT(2) PRIMARY KEY,
tipo VARCHAR(30)
);

CREATE TABLE pais_idioma (
id_pais_idioma SMALLINT(2) PRIMARY KEY,
pais VARCHAR(15),
idioma VARCHAR (10)
);

CREATE TABLE fuente (
id_fuente SMALLINT(2) PRIMARY KEY,
fuente VARCHAR(20)
);

CREATE TABLE autor (
id_autor SMALLINT(2) PRIMARY KEY,
autor VARCHAR(15)
);

CREATE TABLE noticias (
id_noticia SMALLINT(5) PRIMARY KEY,
id_tipo SMALLINT(2),
id_pais_idioma SMALLINT(2),
id_fuente SMALLINT(2),
id_autor SMALLINT(2),
veracidad BOOLEAN,
fecha_publicacion DATETIME,
fecha_compartido DATETIME,
veces_compartido MEDIUMINT(5),
visitas MEDIUMINT(6),
duracion_lectura SMALLINT(3),
veces_favorito SMALLINT(4),
FOREIGN KEY (id_noticia) REFERENCES contenido(id_noticia),
FOREIGN KEY (id_tipo) REFERENCES tipo(id_tipo),
FOREIGN KEY (id_pais_idioma) REFERENCES pais_idioma(id_pais_idioma),
FOREIGN KEY (id_fuente) REFERENCES fuente(id_fuente),
FOREIGN KEY (id_autor) REFERENCES autor (id_autor)
);

------------------------------------------------------------

-- Importar documentos CSV:

LOAD DATA INFILE "./Contenido.csv"
INTO TABLE contenido
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "./Tipo.csv"
INTO TABLE tipo
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "./Pais_Idioma.csv"
INTO TABLE pais_idioma
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "./Fuente.csv"
INTO TABLE fuente
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "./Autor.csv"
INTO TABLE autor
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "./Noticias.csv"
INTO TABLE noticias
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

------------------------------------------------------------

-- Confirmar importación de datos correcta:

SELECT * FROM autor;
SELECT COUNT(*) FROM autor;

SELECT * FROM contenido;
SELECT COUNT(*) FROM contenido;

SELECT * FROM fuente;
SELECT COUNT(*) FROM fuente;

SELECT * FROM noticias;
SELECT COUNT(*) FROM noticias;

SELECT * FROM pais_idioma;
SELECT COUNT(*) FROM pais_idioma;

SELECT * FROM tipo;
SELECT COUNT(*) FROM tipo;

------------------------------------------------------------

-- Reemplazar columna veracidad booleana por REAL/FAKE en la tabla "noticias" para facilitar interpretación:

-- Desactivar el modo seguro temporalmente (Necesario para evitar error 1175, medida de seguridad que evita cambios masivos en tablas):
SET SQL_SAFE_UPDATES = 0;

-- Cambiar el tipo de datos de la columna veracidad a VARCHAR:
ALTER TABLE noticias
MODIFY COLUMN veracidad VARCHAR(4);

-- Reemplazar columna:
UPDATE noticias
SET veracidad = CASE
    WHEN veracidad = 0 THEN 'FAKE'
    WHEN veracidad = 1 THEN 'REAL'
END;

-- Volver a activar el modo seguro:
SET SQL_SAFE_UPDATES = 1;

-- Confirmar cambio:
SELECT * FROM noticias;