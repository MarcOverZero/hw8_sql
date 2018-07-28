# Homework Assignment

## Installation Instructions

-- Refer to the [installation guide](Installation.md) to install the necessary files.

## Instructions

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
  FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT UPPER(CONCAT(first_name, ' ', last_name)) as `Actor Name`
  FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
	FROM actor
  WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT  last_name
	FROM actor
  WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name
  FROM actor
  WHERE last_name LIKE "%LI%"
  ORDER BY 3, 2;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
	FROM country
  WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.

ALTER TABLE actor
	ADD middle_name VARCHAR(40)
  AFTER first_name;

SELECT first_name, middle_name, last_name
	FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.

ALTER TABLE actor
  MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the `middle_name` column.

ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) AS name_count
	FROM actor
	GROUP BY 1
	ORDER BY 2 DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*

SELECT last_name, COUNT(*)
	FROM actor
    GROUP BY 1
    HAVING COUNT(*)>= 2

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
  SET first_name = "HARPO"
  WHERE first_name = "GROUCHO"
  AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
	SET first_name = "MUCHO GROUCHO"
  WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  -- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

  SHOW CREATE TABLE address

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
	FROM staff
  JOIN address ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
	FROM payment
    JOIN staff ON payment.staff_id = staff.staff_id
    WHERE EXTRACT(YEAR_MONTH FROM payment.payment_date) = '200508'
    GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT film.film_id, film.title, COUNT(film_actor.actor_id) `Number of Actors`
	FROM film
	INNER JOIN film_actor ON film.film_id = film_actor.film_id
	GROUP BY 1;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
-- ans : 6

SELECT COUNT(inventory.inventory_id)
	FROM inventory
  JOIN film ON film.film_id = inventory.film_id
  WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

  ```
  	![Total amount paid](Images/total_payment.png)
  ```
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount)
	FROM customer c
    JOIN payment p on p.customer_id = c.customer_id
    GROUP BY 1,2,3
    ORDER BY 3;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM (SELECT title, language_id
	    FROM film
      WHERE title LIKE "K%" OR title LIKE "Q%") t
WHERE language_id =
(SELECT language_id
 FROM language
 WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT actor_id, first_name, last_name
FROM actor
  WHERE actor_id IN
	(SELECT actor_id
    FROM film_actor
    WHERE film_id =
	    (SELECT film_id
       FROM film
       WHERE title = 'Alone Trip')
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT c.email, c.address_id, ad.city_id, ci.country_id, co.country
	FROM customer c
    JOIN address ad ON ad.address_id = c.address_id
	JOIN city ci ON ci.city_id = ad.city_id
    JOIN country co ON co.country_id = ci.country_id
    WHERE co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.film_id, fc.category_id, cat.name
	FROM film f
    JOIN film_category fc ON fc.film_id = f.film_id
    JOIN category cat ON cat.category_id = fc.category_id
    WHERE cat.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT film.film_id, film.title, COUNT(rental.rental_id) `Rental Frequency`
FROM film
  JOIN inventory on film.film_id = inventory.film_id
  JOIN rental on inventory.inventory_id = rental.inventory_id
  GROUP BY film.film_id
  ORDER BY `Rental Frequency` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT concat('$', format(sum(p.amount),2)) AS total, a.address
FROM payment AS p
JOIN staff AS s ON p.staff_id = s.staff_id
JOIN store AS st on s.store_id = st.store_id
JOIN address as a on a.address_id = st.address_id
GROUP BY address
ORDER by total

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
 FROM store
   JOIN address ON store.address_id = address.address_id
   JOIN city ON address.city_id = city.city_id
   JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT cat.name, SUM(p.amount) AS gross_revenue
	FROM payment p
    JOIN rental r ON r.rental_id = p.rental_id
    JOIN inventory i ON i.inventory_id = r.inventory_id
    JOIN film_category fc ON fc.film_id = i.film_id
    JOIN category cat ON cat.category_id = fc.category_id
    GROUP BY 1 DESC
    ORDER BY 2 LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
	SELECT category.category_id, category.name, CONCAT('$', FORMAT(SUM(payment.amount), 2)) `Gross Revenue`
	FROM category
    JOIN film_category fc ON fc.category_id = category.category_id
    JOIN film ON film.film_id = fc.film_id
    JOIN inventory ON inventory.film_id = film.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON payment.rental_id = rental.rental_id
    GROUP BY 1
    ORDER BY `Gross Revenue` DESC
    LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_five_genres;

## Appendix: List of Tables in the Sakila DB

-- A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

```sql
	'actor'
	'actor_info'
	'address'
	'category'
	'city'
	'country'
	'customer'
	'customer_list'
	'film'
	'film_actor'
	'film_category'
	'film_list'
	'film_text'
	'inventory'
	'language'
	'nicer_but_slower_film_list'
	'payment'
	'rental'
	'sales_by_film_category'
	'sales_by_store'
	'staff'
	'staff_list'
	'store'
```

## Uploading Homework

-- To submit this homework using BootCampSpot:

  -- Create a GitHub repository.
  -- Upload your .sql file with the completed queries.
  -- Submit a link to your GitHub repo through BootCampSpot.
