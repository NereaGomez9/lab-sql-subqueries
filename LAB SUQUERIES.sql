USE sakila;
-- Determinar el número de copias de la película "El jorobado imposible" que existan en el inventario.

SELECT
	film.title,
	COUNT(inventory.inventory_id) AS total_copias
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY film.title;

 -- Enumerar todas las películas cuya duración sea superior a la duración media de todas las películas de la base de datos de Sakila.
 
 SELECT 
    title,
    length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

 -- Utilice una subquerie para mostrar todos los actores que aparecen en la película "Alone trip".
 
 SELECT 
    first_name,
    last_name
FROM actor
WHERE actor_id IN (
        SELECT actor_id 
        FROM film_actor
        WHERE film_id = (
                SELECT film_id
                FROM film
                WHERE title = 'ALONE TRIP'
        )
);

-- Las ventas entre familias jóvenes han estado bajas, y usted desea enfocar su promoción en películas familiares. Identifique todas las películas categorizadas como cine familiar.

SELECT 
film.title AS family_films
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- Obtén el nombre y el correo electrónico de los clientes de Canadá utilizando subconsultas y combinaciones (joins). Para usar combinaciones, deberás identificar las tablas relevantes y sus claves primarias y foráneas.

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

-- Determina en qué películas actuó el actor más prolífico de la base de datos de Sakila. Un actor prolífico es aquel que ha participado en la mayor cantidad de películas. Primero, debes encontrar al actor más prolífico y luego usar su ID para buscar las diferentes películas en las que actuó.
-- 1. Encontrar el actor con más películas
SELECT actor_id, COUNT(film_id) AS total_films
FROM film_actor
GROUP BY actor_id
ORDER BY total_films DESC
LIMIT 1;

-- 2. Listar las películas donde actúo
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- Encuentra las películas alquiladas por el cliente más rentable en la base de datos de Sakila. Puedes usar las tablas de clientes y pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor cantidad de pagos.
-- Paso 1. Cliente que más dinero gastó.
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- Paso 2. Películas alquiladas por dicho cliente.
SELECT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- Recupera el client_id y el total_amount_spent de aquellos clientes que gastaron más que el promedio del total_amount gastado por cliente. Puedes usar subconsultas para lograrlo.

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
);
