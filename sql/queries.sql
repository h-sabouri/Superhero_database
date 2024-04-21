--Selection and Filtering


--Show the first superhero

select superhero_name, full_name
from superhero
where id = (SELECT MIN(id) from superhero);


--Show the last superhero
select superhero_name, full_name
from superhero
where id = (SELECT MAX(id) from superhero);


--Show the superhero name of all superheroes with the same colour eyes and hair
select superhero_name, full_name
from superhero
where eye_colour_id = hair_colour_id limit 10


--Show the superhero name and full name of all superheroes with a superhero name that ends in Man or Woman

select superhero_name
from superhero
where superhero_name LIKE '%Man' or superhero_name LIKE '%Woman';


--Show the superhero name of the 5 tallest superheroes in descending order
select superhero_name, height_cm
from superhero
WHERE height_cm IS not NULL
ORDER BY height_cm Desc;


--Show the superhero name of the 5 lightest superheroes with weight greater than 0kg in ascending order

select superhero_name, weight_kg
from superhero
WHERE weight_kg > 0
ORDER BY weight_kg ASC LIMIT 5;

--Show the first 5 superheroes who do not use an alias in ascending order of id

select superhero_name
from superhero
WHERE superhero_name = full_name
ORDER BY superhero_name ASC LIMIT 5;


--Show the first 5 superheroes who do not have a full name in ascending order of id
select superhero_name
from superhero
WHERE full_name IS null
ORDER BY superhero_name ASC LIMIT 5;


--Show the superhero name of all superheroes who are neither `Male` or `Female`

select superhero_name, gender_id
from superhero
where gender_id = 1 or gender_id = 2 ;


--Show the superhero names of all superheroes who are `Female` and `Neutral` in alignment
select superhero_name, gender_id, alignment_id
from superhero
where gender_id = 2 and alignment_id = 3;



--Aggregation

--Show the number of superheroes who have superhero names that start with the letter A

SELECT COUNT(*)  FROM superhero
WHERE superhero_name LIKE 'A%'
LIMIT 10;


--Show the superhero name of the tallest superheroes for each gender

SELECT superhero.gender_id, superhero.height_cm, gender.gender, superhero.superhero_name
FROM superhero
JOIN gender
ON superhero.gender_id = gender.id
WHERE (superhero.gender_id, superhero.height_cm) IN
(SELECT superhero.gender_id, max(height_cm)
FROM superhero
INNER JOIN gender
ON superhero.gender_id = gender.id
WHERE height_cm IS NOT NULL AND height_cm != 0
GROUP BY superhero.gender_id );

--Show the distribution of superheroes by publisher. Exclude superheroes who do not belong to any publishers (publisher is )

SELECT pbr.publisher_name, count(sph.superhero_name) as hero_number
FROM superhero sph
JOIN publisher pbr
ON sph.publisher_id = pbr.id
WHERE pbr.publisher_name != ' '
GROUP BY pbr.publisher_name
ORDER BY hero_number DESC;

--Show the superhero names of all superheroes who take on multiple forms (their name appears multiple times in the database)

SELECT superhero_name, COUNT(*) from superhero
GROUP BY superhero_name
HAVING COUNT (superhero_name)>1;

--Show the distribution of superheroes by eye colour and hair colour. Order your result, showing the 10 most common combinations

SELECT superhero.superhero_name, col.colour as eye_colour, colour.colour as hair_colour

FROM superhero

INNER JOIN colour
ON superhero.hair_colour_id = colour.id


INNER JOIN colour col
ON superhero.eye_colour_id = col.id

GROUP BY superhero.superhero_name, eye_colour, hair_colour
ORDER BY COUNT(*) ASC
;



--Show the number of superheroes who have the exact same eye and hair colour.
--Exclude superheroes who do not have any colour in their eyes or hair (colour is No Colour).


SELECT COUNT(*) FROM(
SELECT superhero.superhero_name, col.colour AS eye_colour, colour.colour AS hair_colour

FROM superhero

INNER JOIN colour
ON superhero.hair_colour_id = colour.id

INNER JOIN colour col
ON superhero.eye_colour_id = col.id

WHERE
col.colour != 'No Colour'
AND colour.colour != 'No Colour'
AND col.colour = colour.colour


GROUP BY superhero.superhero_name, eye_colour, hair_colour) AS result_table
;


--Show the average height and average weight of all superheroes whose name ends in Man.

SELECT AVG(height_cm) AS avg_height , AVG(weight_kg) AS avg_weight FROM superhero
WHERE superhero_name LIKE '%Man'
;



--Show the top 10 races by average height having average height less than 200cm. Display your results in descending order

SELECT AVG(superhero.height_cm) as height_avg,  race.id, race.race
FROM superhero
INNER JOIN race
ON superhero.race_id = race.id
WHERE
superhero.height_cm != 0
AND
race.race != '-'
GROUP BY race.race, race.id
HAVING AVG(superhero.height_cm) > 200
ORDER BY height_avg DESC
LIMIT 10
;

--Show the gender distribution by count, average height, and average weight of all superheroes without a publisher (publisher name is )


SELECT gender_id, AVG(height_cm), avg(weight_kg)
FROM superhero
WHERE publisher_id =
(SELECT id FROM publisher
WHERE publisher_name = '')
GROUP BY gender_id
;

--Show the 5 most common races of superheroes who are not Good. Display your results in descending order and exclude superheroes without a race (race is -)

SELECT race.race

FROM
superhero
inner join race
ON race.id = superhero.race_id

WHERE alignment_id =
(SELECT id
FROM alignment
WHERE alignment = 'Good')
AND
race_id IS NOT NULL

GROUP BY race.race
HAVING race.race != '-'
ORDER BY COUNT(race.race) desc
LIMIT 5
;


--Subqueries, String Manipulation


--Show the names of all superheroes as their first name, superhero name in quotes, last name. For example, Charles Chandler is known as 3-D Man so he will be displayed as Charles 3-D Man Chandler. Display only superheroes from Marvel Comics whose full names consist of only their first and last name (exclude superheroes such as Bob and Angel Salvadore Bohusk)

SELECT
superhero.superhero_name,
SUBSTRING(full_name,1,strpos(full_name, ' '))
|| ' "" ' ||
superhero.superhero_name
|| ' "" ' ||
SUBSTRING(full_name, strpos(full_name, ' ')+1, LENGTH(full_name)) AS Names,
publisher.publisher_name as publisher_name

FROM
	superhero

JOIN
	publisher
ON
    superhero.publisher_id = publisher.id

WHERE
	full_name IS NOT NULL
AND
	full_name NOT LIKE '-'
AND
	publisher.publisher_name = 'Marvel Comics'
AND
    full_name LIKE '% %'

LIMIT 20;


--Show the superhero name, eye colour, hair colour, and skin colour of all superheroes with either Blue, Brown, or Green eyes. Display the first 20 results.

SELECT

superhero.superhero_name,
eye_colour.colour as Eye_colour,
hair_colour.colour as Hair_color,
skin_colour.colour as Skin_colour

FROM
superhero

JOIN
colour as eye_colour
ON eye_colour.id = superhero.eye_colour_id

JOIN
colour as hair_colour
ON hair_colour.id = superhero.hair_colour_id

JOIN
colour as skin_colour
ON skin_colour.id = superhero.skin_colour_id


WHERE

    eye_colour.colour = 'Blue'
    OR
    eye_colour.colour LIKE 'Brown'
    OR
    eye_colour.colour LIKE 'Green'


LIMIT 20

;