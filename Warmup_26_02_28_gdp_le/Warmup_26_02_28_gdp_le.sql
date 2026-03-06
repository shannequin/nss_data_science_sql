-- PART 1
--Why do the following queries result in different numbers?
-- ASNWER: COUNT(*) is counting all the rows in the table, whereas COUNT(colname) only counts non-null values.

-- 17,354
SELECT COUNT(*)
FROM gdp_le;

-- 5,893
SELECT COUNT(gdp_per_capita)
FROM gdp_le;


-- PART 2
-- Write a query that finds all rows where the life expectancy value is missing.
SELECT *
FROM gdp_le
WHERE life_expectancy IS NOT NULL;


-- PART 3
-- The following query attempts to find all continents where the smallest life expenctancy across all countries was at least 65 in 2012. 
-- It currently produces an error. Correct it.

SELECT continent, MIN(life_expectancy) AS min_life_expectancy
FROM gdp_le
WHERE year = 2012
GROUP BY continent
HAVING MIN(life_expectancy) > 65;

-- PART 4
-- We would like to find the country with the smallest life expectancy in 2012 for each continent.
-- Use the DISTINCT ON keywords to accomplish this. See https://www.postgresql.org/docs/current/sql-select.html#SQL-DISTINCT
SELECT DISTINCT ON (continent) continent, country, life_expectancy
FROM gdp_le
WHERE year = 2012
ORDER BY continent, life_expectancy;


-- PART 5
-- The following query displays the country with the lowest life expectancy in 2022.
-- Modify it so that it shows the country with the highest life expectancy in 2022.
-- HINT: See https://www.postgresql.org/docs/current/sql-select.html#SQL-ORDERBY
-- Bonus: Do this in two different ways.
-- ANSWER: "Macao SAR, China" 85.377
SELECT country, life_expectancy
FROM gdp_le
WHERE year = 2022 AND life_expectancy IS NOT NULL
ORDER BY life_expectancy DESC
LIMIT 1;

SELECT country, life_expectancy
FROM gdp_le
WHERE year = 2022
ORDER BY life_expectancy DESC NULLS LAST
LIMIT 1;


-- PART 6
-- Write a query to find the country with the 5th highest life expectancy in 2022.
-- HINT: See https://www.postgresql.org/docs/current/sql-select.html#SQL-LIMIT
SELECT country, life_expectancy
FROM gdp_le
WHERE year = 2022 AND life_expectancy IS NOT NULL
ORDER BY life_expectancy DESC
LIMIT 1
OFFSET 4;