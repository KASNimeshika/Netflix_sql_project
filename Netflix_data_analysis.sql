--Netflix project
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);



SELECT * FROM netflix;

SELECT 
    COUNT(*) as total_content
FROM netflix;	



SELECT           --show unoque types
    Distinct type
FROM netflix;	

SELECT * FROM netflix;


--Count the number of Movies vs TV Shows

SELECT 
    type, 
    COUNT(*) as total_content
FROM netflix
GROUP BY type;


--the most common rating for movies and TV shows
SELECT 
    type, 
    MAX(rating)
FROM netflix
GROUP BY 1             ---- maximum rating for each type of content


SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;


---List all movies released in a specific year ( 2020)



SELECT * FROM netflix
WHERE 
     type = 'Movie'
	 And
     release_year = 2020



------top 5 countries with the most content on Netflix



SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,--splitting commas
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC ---descending order.
LIMIT 5;




-------Identify the longest movie

SELECT * 
FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);




----all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'-- ILIKE is case-insensitive version of the LIKE




-----List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::numeric > 5;




---------Count the number of content items in each genre
SELECT 
       UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
       COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;




---each year and the average numbers of content release in India on netflix. 
----return top 5 year with highest avg content release!

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5



---- List all movies that are documentaries

SELECT * FROM netflix
WHERE
    listed_in LIKE '%Documentaries'




-----all content without a director

SELECT * FROM netflix
WHERE
    director IS NULL





------how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10





----- the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10





----Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
----the description field. Label content containing these keywords as 'Bad' and all other 
----content as 'Good'. Count how many items fall into each category.


WITH new_table AS (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM netflix
)
SELECT category,
    COUNT(*) AS total_content
FROM new_table
GROUP BY category;


