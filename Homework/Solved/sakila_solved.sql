# 1a. Display the first and last names of all actors from the table `actor`.
SELECT a.first_name, a.last_name FROM sakila.actor a;
#---------------------------------------------------------------------------
# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(a.first_name, ' ' , a.last_name) AS full_name FROM sakila.actor a;
#---------------------------------------------------------------------------
# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id, a.first_name, a.last_name FROM sakila.actor a WHERE (a.first_name IS NOT NULL AND a.first_name = "Joe");
#---------------------------------------------------------------------------
# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT CONCAT(a.first_name, ' ' , a.last_name) AS full_name FROM sakila.actor a WHERE (a.last_name IS NOT NULL AND a.last_name LIKE "%GEN%");
#---------------------------------------------------------------------------
# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT CONCAT(a.last_name, ', ' , a.first_name) AS full_name FROM sakila.actor a WHERE (a.last_name IS NOT NULL AND a.last_name LIKE "%LI%") ORDER BY full_name ASC;
#---------------------------------------------------------------------------
# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id, c.country FROM sakila.country c WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');
#---------------------------------------------------------------------------
# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE sakila.actor 
ADD COLUMN description BLOB NOT NULL AFTER `last_update`;
#---------------------------------------------------------------------------
# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE sakila.actor
DROP COLUMN description;
#---------------------------------------------------------------------------
# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name, COUNT(*) AS count FROM sakila.actor a GROUP BY (a.last_name) ORDER BY a.last_name ASC;
#---------------------------------------------------------------------------
# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT a.last_name, COUNT(*) AS count FROM sakila.actor a GROUP BY (a.last_name) HAVING (count > 1) ORDER BY a.last_name ASC;
#---------------------------------------------------------------------------
# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE sakila.actor a SET a.first_name = "HARPO" WHERE a.first_name = "GROUCHO" AND a.last_name = "WILLIAMS";
SELECT CONCAT(a.first_name, ' ',  a.last_name) as full_name FROM sakila.actor a WHERE a.last_name = "WILLIAMS";
#---------------------------------------------------------------------------
# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE sakila.actor a SET a.first_name = "GROUCHO" WHERE a.first_name = "HARPO";
#---------------------------------------------------------------------------
# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
USE sakila;
DROP TABLE IF EXISTS address;
CREATE TABLE address (
	address_id	SMALLINT(5) UNSIGNED AUTO_INCREMENT,
    address		VARCHAR(50) DEFAULT NULL,
    address2	VARCHAR(50) DEFAULT NULL,
    district	VARCHAR(20) NOT NULL,
    city_id		SMALLINT(5) UNSIGNED NOT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    phone		VARCHAR(20) NOT NULL,
    location	GEOMETRY NOT NULL,
	last_update	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (address_id),
	SPATIAL KEY idx_location (location)) ENGINE=INNODB DEFAULT CHARSET=utf8;
#---------------------------------------------------------------------------
# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, ad.address 
FROM sakila.staff s
INNER JOIN sakila.address ad USING (address_id)
ORDER BY s.first_name ASC
LIMIT 100;
#---------------------------------------------------------------------------
#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT CONCAT(s.first_name, ' ', s.last_name) AS full_name,
SUM(p.amount) AS amount_rung
FROM sakila.payment p
JOIN sakila.staff s USING (staff_id)
WHERE MONTH(p.payment_date) = '08' && YEAR(p.payment_date) = '2005'
GROUP BY (p.staff_id)
ORDER BY (full_name) ASC
LIMIT 5;
#---------------------------------------------------------------------------
# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, count(*) AS num_actors
FROM film_actor fa 
INNER JOIN film f USING (film_id)
GROUP BY (fa.actor_id)
ORDER BY (f.title) ASC
LIMIT 100;
#---------------------------------------------------------------------------
# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(*) AS total_num_of_copies_of_Hunchback_Impossible_in_the_inventory
FROM sakila.inventory i
INNER JOIN sakila.film f USING (film_id)
WHERE (f.title= "Hunchback Impossible");
#---------------------------------------------------------------------------
# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_amount_paid
FROM sakila.customer c
INNER JOIN sakila.payment p USING(customer_id)
GROUP BY (p.customer_id)
ORDER BY (c.last_name) ASC
LIMIT 18;
#---------------------------------------------------------------------------
# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films
# starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies
# starting with the letters `K` and `Q` whose language is English.
SELECT f.title 
FROM sakila.film f
WHERE f.title IN (SELECT title 
					FROM sakila.film 
					INNER JOIN sakila.language l USING (language_id)
					WHERE l.name = "English")
AND LEFT(f.title, 1) IN ('K','Q')
LIMIT 100;
# Same result can also be achieved without a subquery...
SELECT f.title
FROM sakila.film f
INNER JOIN sakila.language l USING (language_id)
WHERE l.name = "English" AND 
LEFT(f.title, 1) IN ('K','Q')
LIMIT 100;
#------------------------------------------------------------------------------------------------
# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT DISTINCT CONCAT(a.first_name, ' ', a.last_name) AS actor_name
FROM sakila.actor a
INNER JOIN sakila.film_actor fa2 USING (actor_id)
WHERE a.actor_id IN (SELECT fa.actor_id
						FROM sakila.film_actor fa
						INNER JOIN sakila.film f USING(film_id)
						INNER JOIN sakila.film_actor fa2 ON f.film_id = fa2.film_id
						WHERE f.title = "Alone Trip")
ORDER BY actor_name ASC
LIMIT 100;
#------------------------------------------------------------------------------------------------
# 7c. You want to run an email marketing campaign in Canada, for which you will need 
# the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.email
FROM sakila.customer c
INNER JOIN sakila.address ad USING (address_id)
INNER JOIN sakila.city ct ON ad.city_id = ct.city_id
INNER JOIN sakila.country cy ON cy.country_id = ct.country_id
WHERE c.active = 1 AND
cy.country = 'Canada'
ORDER BY (customer_name) ASC
LIMIT 100;
#------------------------------------------------------------------------------------------------
# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as _family_ films.
SELECT f.title AS family_movies
FROM sakila.film f
INNER JOIN sakila.film_category fc USING (film_id)
INNER JOIN sakila.category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Family'
ORDER BY f.title ASC
LIMIT 100;
#------------------------------------------------------------------------------------------------
# * 7e. Display the most frequently rented movies in descending order.
SELECT f.title AS frequently_rented_movies
FROM sakila.rental r
LEFT JOIN sakila.inventory i USING (inventory_id)
LEFT JOIN sakila.film f ON f.film_id = i.film_id
GROUP BY (f.film_id)
ORDER BY frequently_rented_movies
LIMIT 100;
#------------------------------------------------------------------------------------------------
# * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, sum(p.amount) AS dollars
FROM sakila.payment p
LEFT JOIN sakila.staff sf USING (staff_id)
LEFT JOIN sakila.store st ON st.store_id = sf.store_id
GROUP BY (st.store_id)
ORDER BY dollars DESC
LIMIT 10;
#------------------------------------------------------------------------------------------------
# * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, cy.city, co.country
FROM sakila.store s
LEFT JOIN sakila.address ad USING (address_id)
LEFT JOIN sakila.city cy ON cy.city_id = ad.city_id
LEFT JOIN sakila.country co ON cy.country_id = co.country_id
LIMIT 10;
#------------------------------------------------------------------------------------------------
# * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name, SUM(p.amount) AS revenue
FROM sakila.category cat
LEFT JOIN sakila.film_category fc USING (category_id)
LEFT JOIN sakila.inventory i ON i.film_id = fc.film_id
LEFT JOIN sakila.rental r ON r.inventory_id = i.inventory_id
LEFT JOIN sakila.payment p ON p.rental_id = r.rental_id
GROUP BY cat.name
ORDER BY revenue DESC
LIMIT 10;
#------------------------------------------------------------------------------------------------
# * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
USE sakila;
DROP VIEW IF EXISTS top_five_genres;
CREATE VIEW top_five_genres AS
SELECT cat.name, sum(amount) AS revenue
FROM sakila.category cat
LEFT JOIN sakila.film_category fc USING(category_id)
LEFT JOIN sakila.inventory i ON i.film_id = fc.film_id
LEFT JOIN sakila.rental r ON r.inventory_id = i.inventory_id
LEFT JOIN sakila.payment p ON p.rental_id = r.rental_id
GROUP BY cat.name
ORDER BY revenue DESC
LIMIT 10;
#------------------------------------------------------------------------------------------------
# * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres
LIMIT 5;
#------------------------------------------------------------------------------------------------
# * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres;
#------------------------------------------------------------------------------------------------