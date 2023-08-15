--1- Create a CTE named top_customers that lists the top 10 customers based on the total number of distinct films they've rented.

WITH Top_Customers AS
(
SELECT
	se_customer.customer_id,
	COUNT(DISTINCT se_inventory.film_id) AS rented_films
FROM public.customer AS se_customer
INNER JOIN public.rental AS se_rental
ON se_customer.customer_id=se_rental.customer_id
INNER JOIN public.inventory AS se_inventory
ON se_rental.rental_id=se_inventory.inventory_id
GROUP BY se_customer.customer_id
ORDER BY COUNT(DISTINCT se_inventory.film_id) DESC
LIMIT 10
),

--2- For each customer from top_customers, retrieve their average payment amount and the count of rentals they've made.
Payment_Avg_Rentals AS
(
SELECT
	se_customer.customer_id,
	AVG(se_payment.amount) as Average_Amount,
	COUNT(se_rental.rental_id) as Total_rentals
FROM public.customer AS se_customer
INNER JOIN public.rental AS se_rental
ON se_customer.customer_id=se_rental.customer_id
INNER JOIN public.payment AS se_payment
ON se_rental.rental_id=se_payment.rental_id
GROUP BY se_customer.customer_id
)

SELECT
Top_Customers.customer_id,
Payment_Avg_Rentals.Average_Amount,
Payment_Avg_Rentals.Total_rentals
FROM Top_Customers
INNER JOIN Payment_Avg_Rentals
ON Top_Customers.customer_id=Payment_Avg_Rentals.customer_id

--3- Create a Temporary Table named film_inventory that stores film titles and their corresponding available inventory count.
CREATE TEMPORARY TABLE film_inventory AS
(
SELECT
	se_film.title,
	COUNT(se_inventory.inventory_id) as Total_inventory
FROM public.film as se_film
INNER JOIN public.inventory as se_inventory
ON se_film.film_id=se_inventory.film_id
GROUP BY se_film.title
)

--4- Populate the film_inventory table with data from the DVD rental database, considering both rentals and returns.
SELECT
	film_inventory.title,
	film_inventory.Total_inventory,
	se_rental.rental_id,
	se_rental.return_date
FROM film_inventory
INNER JOIN public.film AS se_film
ON film_inventory.title=se_film.title
INNER JOIN public.inventory AS se_inventory
ON se_film.film_id=se_inventory.film_id
INNER JOIN public.rental AS se_rental
ON se_inventory.inventory_id=se_rental.inventory_id

--5 Retrieve the film title with the lowest available inventory count from the film_inventory table.

SELECT film_inventory.title
FROM film_inventory 
WHERE 
film_inventory.Total_inventory=
(SELECT 
 MIN(film_inventory.Total_inventory) 
 FROM film_inventory)

 --6 Create a Temporary Table named store_performance that stores store IDs, revenue, and the average payment amount per rental.

 CREATE TEMPORARY TABLE store_performance AS
(
SELECT se_store.store_id,
	   COALESCE(SUM(se_payment.amount),0) AS Revenue,
	   ROUND(COALESCE(SUM(se_payment.amount),0)/COUNT(se_rental.rental_id),1) AS Payment_per_rental  
FROM public.store AS se_store
INNER JOIN public.inventory AS se_inventory
ON se_store.store_id=se_inventory.store_id
INNER JOIN public.rental AS se_rental
ON se_inventory.inventory_id=se_rental.inventory_id
INNER JOIN public.payment AS se_payment
ON se_rental.rental_id=se_payment.rental_id
GROUP BY se_store.store_id
);
