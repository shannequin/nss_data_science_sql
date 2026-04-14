/*
## SQL Assessment

**Academic Integrity Notice**

> Your submission must be your own work. You should be prepared to explain any code or answers you submit if asked.  
> Use of generative AI tools (such as ChatGPT, Copilot, Gemini, etc.) to create or modify code or text for this assessment is not permitted.  
> If you consulted any external resources (such as documentation or tutorials), you must include the full URL of each site you used with your answer.

The Olympics database includes information for selected events during the 2016 Summer Olympic and the 2014 Winter Olympic games.

You have been provided this database as a backup file. In pgAdmin, create a new database named olympics and restore the backup file into this database.

You have also been provided with an ERD for this database.

Each row of the summer_games and winter_games table corresponds to an athlete who participated in a given event, with an indicator if that athlete won a medal. This means that each event will appear in the table multiple times. 

**Caution:** Pay careful attention to the columns that you use to join. For example, the id column in the athletes table corresponds to the athlete_id column of the summer_games table.
*/
-- Question 1:  
-- Using the athletes table write a query that returns the minimum, average, and maximum age based on gender.
-- Your results should have 2 rows (M and F) and 4 columns (gender, min_age, avg_age, max_age).
SELECT
	gender,
	MIN(age) AS min_age,
	AVG(age) AS avg_age,
	MAX(age) AS max_age
FROM athletes
GROUP BY gender;

/*
ANSWER:
gender	min_age	avg_age				max_age
"M"		14		25.6740872662511131	55
"F"		13		24.9050761421319797	44
*/

-- Question 2:
-- Write a query which finds all events in the summer_games which have an average age of participants of at least 30.
-- Report the event name and the average age of participants.
SELECT
	s.event,
	AVG(a.age) AS avg_age
FROM summer_games s
	INNER JOIN athletes a ON s.athlete_id = a.id
GROUP BY s.event
HAVING AVG(a.age) >= 30;

/*
ANSWER:
event						avg_age
"Men's 50 kilometres Walk"	30.0125000000000000
"Women's Marathon"			31.4012738853503185
*/

-- Question 3:  
-- Find all events in the summer_games and winter_games table that include the word "Relay" in their event name.
-- Warning - the same event can appear in multiple rows, so your query should account for this and only display each event name once.
-- Answer this question using a single query.
(
	SELECT DISTINCT event
	FROM summer_games
	WHERE event ILIKE '%relay%'
)
UNION
(
	SELECT DISTINCT event
	FROM winter_games
	WHERE event ILIKE '%relay%'
)
ORDER BY event;

/*
ANSWER: 14 events
*/

-- Question 4:  
-- a. Create a query which shows, for each Track and Field event in the Summer Olympics, the event name and the name of the athlete who won the gold medal.
-- Note that the gold medal winner is indicated by a 1 in the gold column.  
SELECT
	s.event,
	a.name
FROM summer_games s
	INNER JOIN athletes a ON s.athlete_id = a.id
WHERE s.sport = 'Track and Field'
	AND s.gold = 1
ORDER BY s.event;

/*
ANSWER: 66 events with gold athletes
*/

-- b. Build off of your query from part a to find the number of Track and Field gold medals won for each athlete who won at least one.
-- Which athlete won the most Track and Field gold medals?
SELECT
	a.name,
	COUNT(s.event) AS tf_gold_medals
FROM summer_games s
	INNER JOIN athletes a ON s.athlete_id = a.id
WHERE s.sport = 'Track and Field'
	AND s.gold = 1
GROUP BY a.name
HAVING COUNT(s.event) > 0
ORDER BY tf_gold_medals DESC, a.name;

/*
ANSWER: Usain Bolt with 3
*/

-- Question 5:  
-- a. Find the unique athlete_id values from the summer_games table for athletes that competed in the sport of Gymnastics.
-- Warning: an athlete can compete in more than one event, so your query should handle this.  
SELECT DISTINCT athlete_id
FROM summer_games
WHERE sport = 'Gymnastics';

/*
ANSWER: 196 athlete ids
*/

-- b. Build off of your query from part a to find the average age of athletes that competed in Gymnastics.
SELECT
	AVG(age) AS avg_age
FROM athletes
WHERE id IN (
	SELECT DISTINCT athlete_id
	FROM summer_games
	WHERE sport = 'Gymnastics'
);

/*
ANSWER: average age 22.4744897959183673
*/

-- Question 6:  
-- Provide a list of athletes who won a gold medal and are shorter than the average Olympic athlete.
WITH gold_athletes AS (
	(
		SELECT DISTINCT athlete_id
		FROM summer_games
		WHERE gold = 1
	)
	UNION
	(
		SELECT DISTINCT athlete_id
		FROM winter_games
		WHERE gold = 1
	)
)
SELECT
	name,
	height
FROM athletes a
	INNER JOIN gold_athletes g ON a.id = g.athlete_id
WHERE height < (
	SELECT AVG(height)
	FROM athletes
)
ORDER BY height;

/*
ANSWER: 63 athletes
*/

-- Question 7:
-- a. Write a query which returns each country in the countries table and the number of (distinct) events that country participated in from the winter_games table.
-- This should include all countries, even those that participated in zero games.
SELECT
	c.country,
	COUNT(DISTINCT w.event) AS event_count
FROM countries c
	LEFT JOIN winter_games w ON c.id = w.country_id
GROUP BY c.country
ORDER BY event_count DESC;

/*
ANSWER: 203 countries with event count
*/

-- b.  Write a query which returns each country in the countries table and the number of (distinct) events that country won a gold medal in from the winter_games table.
-- Make sure that your query is only counting each event once.
-- For example, Sweden (country_id = 178) is listed 4 times in the winter_games table for a gold medal in the Cross Country Skiing Men's 4 x 10 kilometres Relay event,
-- but this should only count one time in your results table.
-- You do not need to include all countries in this query, only the ones that won gold medals.
SELECT
	c.id,
	COUNT(DISTINCT w.event) AS gold_count
FROM countries c
	LEFT JOIN winter_games w ON c.id = w.country_id
WHERE w.gold = 1
GROUP BY c.id
ORDER BY gold_count DESC;

/*
ANSWER: 14 countries with total 33 gold
*/

-- c. Combine your results for parts a and b into a table that gives, for each country in the countries table,
-- the total number of winter olympic events that country participated in and the number of winter olypmic events where that country won a gold medal.
-- This table should include all countries.
WITH
	winter_countries_events AS (
		SELECT
			c.id,
			COUNT(DISTINCT w.event) AS event_count
		FROM countries c
			LEFT JOIN winter_games w ON c.id = w.country_id
		GROUP BY c.id
	),
	winter_countries_golds AS (
		SELECT
			c.id,
			COUNT(DISTINCT w.event) AS gold_count
		FROM countries c
			LEFT JOIN winter_games w ON c.id = w.country_id
		WHERE w.gold = 1
		GROUP BY c.id
)
SELECT
	c.country,
	e.event_count,
	COALESCE(g.gold_count, 0) AS gold_count
FROM countries c
	LEFT JOIN winter_countries_events e USING(id)
	LEFT JOIN winter_countries_golds g USING(id)
ORDER BY gold_count DESC, event_count DESC;

/*
ANSWER: 203 countries with event and gold counts
*/

-- Question 8:
-- a. Create a list of countries that competed across all 3 sports during the summer games.
SELECT c.country
FROM summer_games s
	INNER JOIN countries c ON s.country_id = c.id
GROUP BY c.country
HAVING COUNT(DISTINCT s.sport) = 3
ORDER BY c.country;

/*
ANSWER: 58 countries
*/

-- b. Create a list of all countries that competed in the sport of Swimming but not the sport of Gymnastics during the summer games.
SELECT DISTINCT c.country
FROM summer_games s
	INNER JOIN countries c ON s.country_id = c.id
WHERE s.sport = 'Swimming'
	AND c.id NOT IN (
		SELECT DISTINCT country_id
		FROM summer_games
		WHERE sport = 'Gymnastics'
	)
ORDER BY c.country;

/*
ANSWER: 115 countries
*/

-- Question 9:
-- Find the tallest athlete per country.
-- Report that athlete's name, height, and country name.
-- Warning: some countries have athletes tied for the tallest, so make sure that your query accounts for this.
-- The results table should have 238 rows.
SELECT
	name,
	height,
	country
FROM (
	SELECT
		a.name,
		a.height,
		c.country,
		RANK() OVER(PARTITION BY c.country ORDER BY a.height DESC) AS height_rank
	FROM athletes a
		INNER JOIN (
			SELECT DISTINCT
				athlete_id,
				country_id
			FROM summer_games
			UNION
			SELECT DISTINCT
				athlete_id,
				country_id
			FROM winter_games
		) g ON a.id = g.athlete_id
		INNER JOIN countries c ON g.country_id = c.id
)
WHERE height_rank = 1
ORDER BY country, name;

/*
ANSWER: 203 countries with 238 tallest athletes
*/