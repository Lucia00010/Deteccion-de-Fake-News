-- • Calcular la longitud media de los textos.
SELECT ROUND(AVG(CHAR_LENGTH(texto)), 2) AS longitud_media_textos -- LENGTH() cuenta bytes mientras CHAR_LENGTH() cuenta caracteres
FROM contenido;
-- RESPUESTA: La longitud media de los textos es de 4575.88 caracteres.


-- • ¿Qué día del mes se han publicado más noticias, cuántas y de qué tipo son?
-- Día del mes con más noticias publicadas:
SELECT DATE(fecha_publicacion), COUNT(noticias.id_noticia) cantidad_noticias_publicadas
FROM noticias
GROUP BY DATE(fecha_publicacion)
ORDER BY COUNT(id_noticia) DESC
LIMIT 1;
-- Tipo de noticias:
-- Por veracidad:
SELECT veracidad, COUNT(noticias.id_noticia) AS cantidad_noticias_publicadas
FROM noticias
WHERE DATE(fecha_publicacion) = (SELECT DATE(fecha_publicacion) FROM noticias GROUP BY DATE(fecha_publicacion) ORDER BY COUNT(id_noticia) DESC LIMIT 1)
GROUP BY veracidad
ORDER BY COUNT(id_noticia) DESC;
-- RESPUESTA: El día con más noticias publicadas fue el 5 de septiembre de 2022 con 322 noticias, de las cuales 172 fueron reales y 150 fake. El tipo de estas es: 
SELECT tipo, COUNT(noticias.id_noticia) cantidad_noticias_publicadas
FROM noticias
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo -- Podría usarse INNER JOIN o LEFT JOIN indistintamente
WHERE DATE(fecha_publicacion) = (SELECT DATE(fecha_publicacion) FROM noticias GROUP BY DATE(fecha_publicacion) ORDER BY COUNT(id_noticia) DESC LIMIT 1)
GROUP BY tipo
ORDER BY COUNT(id_noticia) DESC;


-- • ¿Qué días del mes se han compartido más noticias, cuántas y de qué tipo son?
-- Día del mes con más noticias compartidas:
SELECT DATE(fecha_compartido), COUNT(id_noticia) AS cantidad_noticias_compartidas
FROM noticias
GROUP BY DATE(fecha_compartido)
ORDER BY COUNT(id_noticia) DESC
LIMIT 1;
-- Tipo de noticias:
-- Por veracidad:
SELECT veracidad, COUNT(noticias.id_noticia) cantidad_noticias_compartidas
FROM noticias
WHERE DATE(fecha_compartido) = (SELECT DATE(fecha_compartido) FROM noticias GROUP BY DATE(fecha_compartido) ORDER BY COUNT(id_noticia) DESC LIMIT 1)
GROUP BY veracidad
ORDER BY COUNT(id_noticia) DESC;
-- RESPUESTA: El día con más noticias compartidas fue el 8 de octubre de 2022 con 326 noticias, de las cuales 172 son reales y 154 fake. El tipo de estas es: 
SELECT tipo, COUNT(noticias.id_noticia) cantidad_noticias_compartidas
FROM noticias
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
WHERE DATE(fecha_compartido) = (SELECT DATE(fecha_compartido) FROM noticias GROUP BY DATE(fecha_compartido) ORDER BY COUNT(id_noticia) DESC LIMIT 1)
GROUP BY tipo
ORDER BY COUNT(id_noticia) DESC;


-- • ¿A qué hora del día se han compartido más noticias?
-- Agrupando por horas de todo el período:
SELECT HOUR(fecha_compartido) hora, SUM(veces_compartido) cantidad_veces_compartido
FROM noticias
GROUP BY HOUR(fecha_compartido)
ORDER BY SUM(veces_compartido) DESC
LIMIT 1;
-- RESPUESTA: A las 19hs se han compartido más noticias.


-- • ¿Cuántas noticias publicadas han sido fake news?
-- Noticias FAKE publicadas:
SELECT veracidad, COUNT(id_noticia)
FROM noticias
GROUP BY veracidad;
-- Total noticias publicadas:
SELECT COUNT(*) FROM noticias;
-- Proporción de noticias FAKE sobre el total publicadas:
SELECT noticias_fake / noticias_total AS proporcion
FROM
	(SELECT COUNT(*) AS noticias_fake FROM noticias WHERE veracidad = "FAKE") AS f,
	(SELECT COUNT(*) AS noticias_total FROM noticias) AS t;
-- RESPUESTA: 3.164 de las 6.335 noticias publicadas han sido fake, aproximadamente el 50%.


-- • ¿Qué tipo de noticia tiene mayor porcentaje de ser fake new?
SELECT 
    tipo, noticias_fake, noticias_total, CONCAT(ROUND((noticias_fake / noticias_total)*100,2),'%') proporcion_noticias_fake
FROM
    (SELECT tipo.id_tipo, tipo, COUNT(id_noticia) AS noticias_total
     FROM noticias
     LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
     GROUP BY tipo.id_tipo, tipo
    ) AS t
LEFT JOIN
    (SELECT noticias.id_tipo, COUNT(*) AS noticias_fake 
     FROM noticias 
     WHERE veracidad = "FAKE"
     GROUP BY noticias.id_tipo
    ) AS f 
ON t.id_tipo = f.id_tipo
ORDER BY CONCAT(ROUND((noticias_fake / noticias_total)*100,2),'%') DESC;
-- RESPUESTA: El tipo de noticia con mayor proporción de FAKE news es Opinión del lector con ~56%.


-- • ¿Cuál es el porcentaje de compartición y publicación de las fake news frente al porcentaje de las noticias reales?
WITH
	total_publicado AS (SELECT COUNT(*) total_publicado FROM noticias),
    total_compartido AS (SELECT SUM(veces_compartido) total_compartido FROM noticias)
SELECT  veracidad, COUNT(*) total_publicaciones, CONCAT(ROUND((COUNT(*)/total_publicado)*100,2),'%') proporcion_publicado, SUM(veces_compartido) total_veces_compartido, CONCAT(ROUND((SUM(veces_compartido)/total_compartido)*100,1),'%') proporcion_compartido
FROM noticias JOIN total_publicado JOIN total_compartido
GROUP BY veracidad, total_publicado, total_compartido;
-- RESPUESTA: Tanto el porcentaje de compartición y de publicación de las fake news es de alrededor de 50% del total compartido y publicado.


-- • ¿Qué porcentaje de visitas recibe una fake new frente a una noticia real?
WITH
	total_visitas AS (SELECT SUM(visitas) total_visitas FROM noticias)
SELECT veracidad, SUM(visitas) total_visitas, CONCAT(ROUND((SUM(visitas)/total_visitas)*100,2),'%') proporcion_visitas
FROM noticias JOIN total_visitas
GROUP BY veracidad, total_visitas;
-- RESPUESTA: Las fake news reciben aproximadamente el 50% de las visitas.


-- • ¿Qué tipo de noticia recibe la mayor cantidad de visitas?
SELECT tipo, SUM(visitas) visitas
FROM noticias
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
GROUP BY tipo
ORDER BY SUM(visitas) DESC
LIMIT 1;
-- RESPUESTA: El tipo Noticia de última hora es el que recibe mayor cantidad de visitas.


-- • Las 5 noticias que han sido marcadas más veces como favoritas por los lectores, ¿de qué tipo son? ¿Son fake o son reales?
SELECT veces_favorito, COUNT(veces_favorito)
FROM noticias
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
GROUP BY veces_favorito
ORDER BY veces_favorito DESC
LIMIT 5;
SELECT id_noticia, veces_favorito, tipo, veracidad
FROM noticias
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
ORDER BY veces_favorito DESC
LIMIT 7;
-- RESPUESTA: Las 5 noticias marcadas más veces favoritas son: 
-- 1. Análisis-FAKE
-- 2. Noticia de última hora-FAKE
-- 3. Reportaje-REAL
-- 4. Entrevista exclusiva-REAL
-- 5. Noticia de última hora-FAKE / Reportaje-FAKE / Artículo de opinión-REAL


-- • ¿Coinciden los identificadores de las 5 noticias marcadas más veces como favoritas con las 5 más compartidas?
SELECT *
FROM
	(SELECT id_noticia AS id_noticia_fav, veces_favorito 
	FROM noticias
    ORDER BY veces_favorito DESC
	LIMIT 5
    ) AS fav
INNER JOIN 
	(SELECT id_noticia AS id_noticia_comp, veces_compartido
    FROM noticias
    ORDER BY veces_compartido
    LIMIT 5
    ) AS comp
ON id_noticia_fav = id_noticia_comp;
-- RESPUESTA: No coinciden los identificadores de noticias entre las 5 más marcadas como favoritas y las 5 más compartidas.


-- • ¿Qué países publican la mayor cantidad de fake news? ¿Y la menor?
SELECT pais, COUNT(*) cantidad_noticias_fake
FROM noticias n
LEFT JOIN pais_idioma p ON n.id_pais_idioma = p.id_pais_idioma
WHERE veracidad = "FAKE"
GROUP BY pais
ORDER BY COUNT(*) DESC;
-- RESPUESTA: El país que más noticias fake publica es South Africa y el que menos es Colombia.


-- • ¿En qué idioma se publican la mayor cantidad de fake news? ¿Y la menor?
SELECT idioma, COUNT(*) cantidad_noticias_fake
FROM noticias n
LEFT JOIN pais_idioma p ON n.id_pais_idioma = p.id_pais_idioma
WHERE veracidad = "FAKE"
GROUP BY idioma
ORDER BY COUNT(*) DESC;
-- RESPUESTA: Todas las noticias fake se publican en Inglés.


-- • Las 5 noticias que más tardan en leer los lectores, ¿son fake o son reales? ¿De qué tipo son? ¿Sobrepasan la media de longitud?
WITH
	longitud_media AS (SELECT AVG(LENGTH(texto)) AS longitud_media FROM contenido)
SELECT noticias.id_noticia, duracion_lectura, veracidad, tipo, LENGTH(texto) longitud_texto,
	CASE
		WHEN LENGTH(texto) > longitud_media THEN 'Mayor'
		WHEN LENGTH(texto) < longitud_media THEN 'Menor'
		ELSE 'Igual'
	END AS comparacion_longitud
FROM noticias JOIN longitud_media
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo
LEFT JOIN contenido ON noticias.id_noticia = contenido.id_noticia
ORDER BY duracion_lectura DESC
LIMIT 5;
-- RESPUESTA: De las 5 noticias que más tardan en leer los lectores: 2 son reales y 3 son fake, son tipo: Columna de humor, Entrevista, Artículo de investigación, Editorial, y una no tiene tipo, y 3 sobrepasan la media de longitud.


-- • ¿Coinciden los identificadores de las 5 noticias que más tardan en leer los lectores con las 5 más visitadas?
SELECT *
FROM
	(SELECT id_noticia AS id_noticia_dur, duracion_lectura
	FROM noticias
    ORDER BY duracion_lectura DESC
	LIMIT 5
    ) AS dur
INNER JOIN 
	(SELECT id_noticia AS id_noticia_vis, visitas
    FROM noticias
    ORDER BY visitas
    LIMIT 5
    ) AS vis
ON id_noticia_dur = id_noticia_vis;
-- RESPUESTA: No coinciden los identificadores de noticias entre las 5 que más tardan en leer los lectores y las 5 más visitadas.

    
-- • ¿Quién es el autor que más aparece en las fake news?
SELECT autor, COUNT(id_noticia) cantidad_fake_news
FROM noticias
LEFT JOIN autor
ON noticias.id_autor = autor.id_autor
WHERE veracidad =0
GROUP BY autor
ORDER BY COUNT(id_noticia) DESC;
-- RESPUESTA: El autor con más fake news publicadas es Owen Rodriguez.


-- • ¿Qué fuente es la que más publica fake news?
SELECT fuente, COUNT(id_noticia) cantidad_fake_news
FROM noticias
LEFT JOIN fuente
ON noticias.id_fuente = fuente.id_fuente
WHERE veracidad = 'FAKE'
GROUP BY fuente
ORDER BY COUNT(id_noticia) DESC;
-- RESPUESTA: La fuente que más publica fake news es The Insight.


-- • ¿Qué fuente es la que posee la mayor cantidad de noticias más compartidas?
SELECT fuente, SUM(veces_compartido) total_veces_compartido
FROM noticias
LEFT JOIN fuente
ON noticias.id_fuente = fuente.id_fuente
GROUP BY fuente
ORDER BY SUM(veces_compartido) DESC;
-- RESPUESTA: La fuente que posee la mayor cantidad de noticias más compartidas es The Insight.


-- • ¿Qué autor es el que recibe el mayor número de visitas y compartición en sus noticias?
-- Más visitas:
SELECT autor, SUM(visitas) total_visitas
FROM noticias
LEFT JOIN autor
ON noticias.id_autor = autor.id_autor
GROUP BY autor
ORDER BY SUM(visitas) DESC;
-- Más veces compartido:
SELECT autor, SUM(veces_compartido) total_veces_compartido
FROM noticias
LEFT JOIN autor
ON noticias.id_autor = autor.id_autor
GROUP BY autor
ORDER BY SUM(veces_compartido) DESC;
-- RESPUESTA: El autor que recibe más visitas es Alexander Lee y el autor que más se comparte es Owen Rodriguez.


-- • Para cada texto, calcular la relación entre la longitud del título y la longitud del texto. 
SELECT id_noticia, CHAR_LENGTH(titulo), CHAR_LENGTH(texto), ROUND(CHAR_LENGTH(titulo)/CHAR_LENGTH(texto),2) relacion_titulo_texto
FROM contenido
ORDER BY id_noticia;


------------------------------------------------------------
-- OTRAS PREGUNTAS/KPIS DE INTERES:

-- Evaluar duplicados:

-- Existen noticias con el mismo título? Cuántos títulos se repiten más de una vez?
SELECT COUNT(*) AS titulos_repetidos
FROM (
     SELECT titulo
     FROM contenido
     GROUP BY titulo
     HAVING COUNT(*) > 1
    ) AS titulos_repetidos;
-- Sí, hay 89 noticias cuyo título se repite más de 1 vez.

-- Existen noticias con el mismo texto? Cuántos textos se repiten más de una vez?
SELECT COUNT(*) AS textos_repetidos
FROM (
     SELECT texto
     FROM contenido
     GROUP BY texto
     HAVING COUNT(*) > 1
    ) AS textos_repetidos;
-- Sí, hay 69 noticias cuyo título se repite más de 1 vez.

-- Existen noticias duplicadas, es decir con el mismo título y texto? 
SELECT COUNT(*) AS noticias_repetidas
FROM (
     SELECT titulo, texto
     FROM contenido
     GROUP BY titulo, texto
     HAVING COUNT(*) > 1
    ) AS noticias_repetidas;
-- Sí, hay 28 noticias duplicadas.


-- Evaluar Cumplimiento de las Reglas de negocio:

-- 1. Una columna no puede tener más de 2.500 caracteres.
-- Asumimos "columna" como cualquiera del dataframe, evaluamos "texto" que es la única que podría superar los 2.500 caracteres:
SELECT 
	COUNT(CASE WHEN CHAR_LENGTH(texto) > 2500 THEN 1 END) AS "noticias>2500",
    COUNT(noticias.id_noticia) AS total_noticias_columna,
    COUNT(CASE WHEN CHAR_LENGTH(texto) > 2500 THEN 1 END)/COUNT(noticias.id_noticia) AS "porcentaje_noticias>2500"
FROM noticias
LEFT JOIN contenido ON noticias.id_noticia = contenido.id_noticia
LEFT JOIN tipo ON noticias.id_tipo = tipo.id_tipo;
-- El 63,2% de los textos de las noticias tienen más de 2.500 caracteres.

-- 2.  El tiempo de lectura no puede ser mayor a 20 minutos.
SELECT 
	COUNT(CASE WHEN (duracion_lectura/60)>20 THEN 1 END) AS "duracion>20min",
    COUNT(noticias.id_noticia) AS total_noticias,
    COUNT(CASE WHEN (duracion_lectura/60)>20 THEN 1 END)/COUNT(noticias.id_noticia) AS "porcentaje_noticias_duracion>20min"
FROM noticias;
-- Ok, se cumple regla, no hay noticias con tiempo lectura mayor a 20min.

-- 3. No se publican más de 50 noticias al día.
SELECT 
    SUM(CASE WHEN cant_noticias > 50 THEN 1 ELSE 0 END) AS fechas_mas50noticias,
     COUNT(*) AS total_fechaspublicacion, 
    (SUM(CASE WHEN cant_noticias > 50 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS porcentaje_mas50noticias
FROM (
    SELECT DATE(fecha_publicacion) AS fecha_pub, COUNT(id_noticia) AS cant_noticias
    FROM noticias
    GROUP BY DATE(fecha_publicacion)
) AS conteo_noticias;
-- De las 40 fechas de publicación analizadas, en 33 de ellas (82,5%) se publicaron más de 50 noticias.

-- 4. Una misma fuente no publica noticias más de dos idiomas distintos.
SELECT fuente, COUNT(DISTINCT idioma)
FROM noticias
JOIN fuente ON noticias.id_fuente = fuente.id_fuente
JOIN pais_idioma ON noticias.id_pais_idioma = pais_idioma.id_pais_idioma
GROUP BY fuente
ORDER BY COUNT(DISTINCT idioma) DESC;
-- Ok, ninguna fuente publica en más de 1 idioma.






