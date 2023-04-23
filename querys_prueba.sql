CREATE DATABASE prueba_alex_fernandez;

\c prueba_alex_fernandez;

-- Primer modelo de datos

CREATE TABLE IF NOT EXISTS peliculas (
  id INT PRIMARY KEY,
  nombre VARCHAR(255),
  anno INT
); 

CREATE TABLE IF NOT EXISTS tags (
  id INT PRIMARY KEY,
  tag VARCHAR(32)
);

-- La relación es del tipo muchos a muchos, puesto que una película puede tener 1 o más tags, y además un tag puede estar
-- asociado a 1 o más películas. Por tanto, es útil crear una tabla intermedia:

CREATE TABLE IF NOT EXISTS peliculas_tags(
  pelicula_id INT REFERENCES peliculas (id),
  tag_id INT REFERENCES tags(id)
);

--Insertar datos

INSERT INTO peliculas 
VALUES  (1,'Akira',1988),
        (2,'Your Name',2016),
        (3,'El Padrino',1972),
        (4,'Forrest Gump',1994),
        (5,'El señor de los anillos: La comunidad del anillo',2001);

INSERT INTO tags
VALUES  (1,'Ciencia ficción'),
        (2,'Anime'),
        (3,'Acción'),
        (4,'Romance'),
        (5,'Drama');

-- La primera película debe tener 3 tags asociados y la segunda pelicula debe tener dos tags asociados

INSERT INTO peliculas_tags
VALUES  (1,1),
        (1,2),
        (1,3),
        (2,2),
        (2,4);

-- Cuenta la cantidad de tags que tiene cada película

SELECT peliculas.id,peliculas.nombre,COUNT(peliculas_tags.tag_id) 
FROM peliculas  
LEFT JOIN peliculas_tags 
ON peliculas.id=peliculas_tags.pelicula_id 
GROUP BY peliculas.id,peliculas.nombre
ORDER BY peliculas.id ASC;

-- -----------------------------------------------------------------------
-- Segundo Modelo de datos

CREATE TABLE IF NOT EXISTS preguntas(
  id INT PRIMARY KEY,
  pregunta VARCHAR(255),
  respuesta_correcta VARCHAR
)

CREATE TABLE IF NOT EXISTS usuarios(
  id INT PRIMARY KEY,
  nombre VARCHAR(255),
  edad INT
)

CREATE TABLE IF NOT EXISTS respuestas(
  id INT PRIMARY KEY,
  respuesta VARCHAR(255),
  usuario_id INT,
  pregunta_id INT,
  FOREIGN KEY(usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY(pregunta_id) REFERENCES preguntas(id)
)

-- AGREGA 5 usuarios y 5 preguntas

INSERT INTO usuarios
VALUES  (1,'LunaAzul93',25),
        (2,'LechuzaNocturna',35),
        (3,'ViajeroSinFronteras',48),
        (4,'ElectroByte',21),
        (5,'ElTrovadorLoco',62)

INSERT INTO preguntas
VALUES  (1,'¿Cómo se llama el satélite natural de la Tierra?','Luna'),
        (2,'¿Quién escribió la novela "Don Quijote de la Mancha"?','Cervantes'),
        (3,'¿Qué animal es el símbolo del zodiaco chino para el año 2023?','Conejo'),
        (4,'¿Cómo se llama el elemento químico cuyo símbolo es Fe','Hierro'),
        (5,'¿Qué planeta del sistema solar es conocido como el "planeta rojo"?','Marte');

-- la primera pregunta debe estar contestada dos veces correctamente por distintos usuarios
-- la segunda pregunta debe estar contestada correctamente por sólo un usuario
-- y las otras dos respuestas deben estar incorrectas
-- NOTA:Contestada correctamente significa que la respuesta indicada en la tabla respuestas es exactamente igual al texto indicado en la tabla de preguntas

--Llenar respuestas

INSERT INTO respuestas
VALUES  (1,'Luna',1,1),
        (2,'Luna',3,1),
        (3,'Cervantes',5,2),
        (4,'Tigre',2,3),
        (5,'Fierro',4,4)

-- Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta)

SELECT usuarios.nombre, 
    COUNT(CASE WHEN respuestas.respuesta = preguntas.respuesta_correcta THEN 1 ELSE NULL END) AS respuestas_correctas
FROM usuarios 
LEFT JOIN respuestas ON usuarios.id=respuestas.usuario_id
LEFT JOIN preguntas ON preguntas.id=respuestas.pregunta_id
GROUP BY usuarios.nombre;

-- Por cada pregunta en la tabla preguntas, cuenta cuantos usuarios tuvieron la respuesta correcta
SELECT preguntas.pregunta, COUNT(usuarios.id) 
FILTER(WHERE respuestas.respuesta=preguntas.respuesta_correcta)
FROM preguntas LEFT JOIN respuestas
ON preguntas.id=respuestas.pregunta_id
LEFT JOIN usuarios 
ON usuarios.id=respuestas.usuario_id
GROUP BY preguntas.pregunta;

-- buscar nombre de la constraint inicial de la foreign key

-- Implementa borrado en cascada de las respuestas al borrar un usuario y borrar el primer usuario para probar la implementación.

ALTER TABLE respuestas 
DROP CONSTRAINT respuestas_usuario_id_fkey,
ADD FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE;

DELETE FROM usuarios WHERE id = 1;

-- Crea una restricción que impida insertar usuarios menores de 18 años en la base de datos.

ALTER TABLE usuarios
ADD CONSTRAINT mayoria_edad CHECK (edad>18);

INSERT INTO usuarios
VALUES  (6,'UnderageUser',7);

--  Altera la tabla existente de usuarios agregando el campo email con la restricción de único.

ALTER TABLE usuarios
ADD COLUMN email VARCHAR UNIQUE;

INSERT INTO usuarios VALUES  (7,'DarthStar',25,'darthstar@gmail.com');
INSERT INTO usuarios VALUES  (8,'DarthStar3',30,'darthstar@gmail.com');

