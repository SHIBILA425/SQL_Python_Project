create DATABASE walmart_db;
USE walmart_db;
SELECT * FROM walmart limit 10;
SELECT payment_method, COUNT(*) FROM walmart GROUP BY payment_method;
SELECT COUNT(DISTINCT Branch) from walmart;

-- Business Problems

-- Q1. What are the different payment methods, and how many transactions and
-- items were sold with each method?
SELECT payment_method,COUNT(*) as no_payment,SUM(quantity) as no_qty_sold
FROM walmart GROUP BY payment_method;

-- Q2. Identify the Highest-Rated Category in Each Branch
-- Which category received the highest average rating in each branch?
SELECT * FROM
(SELECT Branch , category , AVG(rating) as avg_rating,
DENSE_RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) as rank_order
from walmart
group by 1,2) as r1
where rank_order=1;

-- Q3.Determine the Busiest Day for Each Branch based on no.of transaction
DESCRIBE walmart;

UPDATE walmart
SET date = STR_TO_DATE(date, '%d/%m/%y');

SELECT date, dayname(date) as Day FROM walmart;

SELECT Branch, dayname(date) as Day, COUNT(*) as no_transaction,
DENSE_RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank_order
FROM walmart
GROUP BY 1,2;

SELECT * FROM
(SELECT Branch, dayname(date) as Day, COUNT(*) as no_transaction,
DENSE_RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank_order
FROM walmart
GROUP BY 1,2) as r1
WHERE rank_order=1;

-- Q4.Calculate Total Quantity Sold by Payment Method
SELECT payment_method , SUM(quantity) as total_qty 
FROM walmart 
GROUP BY 1;

-- Q5. What are the average, minimum, and maximum ratings for each category in each city?
SELECT category, City, AVG(rating), MIN(rating), MAX(rating) 
FROM walmart 
GROUP BY 1,2;

-- Q6. What is the total profit for each category, ranked from highest to lowest?
select category, SUM(total) as total_revenue,
SUM(total * profit_margin) as profit 
FROM walmart GROUP BY category
ORDER BY 2 DESC;

-- Q7. Determine the Most Common Payment Method per Branch
SELECT * FROM
(SELECT Branch, payment_method , count(*),
RANK() OVER(PARTITION BY Branch ORDER BY count(*) DESC) as r1
FROM walmart GROUP BY 1,2 ORDER BY 1) as s1
WHERE r1=1;

-- Q8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
 SELECT Branch,
CASE
 WHEN HOUR(time) < 12 THEN 'Morning'
 WHEN HOUR(time) >= 12 AND HOUR(time) < 17 THEN 'Afternoon'
 ELSE 'Evening'
END AS shift,
COUNT(*)
FROM walmart
GROUP BY 1,2 ORDER BY 1,3 DESC;

-- Q9. Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2022 
AS
( SELECT Branch ,
  SUM(total) as revenue
  FROM walmart
  WHERE year(date) = 2022
  GROUP BY 1
  ),
revenue_2023 AS
( SELECT Branch ,
  SUM(total) as revenue
  FROM walmart
  WHERE year(date) = 2023
  GROUP BY 1
  )
SELECT ls.Branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round(
	 (ls.revenue - cs.revenue) / ls.revenue * 100
     , 2
     ) as ratio
from revenue_2022 as ls
join revenue_2023 as cs 
on ls.Branch = cs.Branch
WHERE 
   ls.revenue > cs.revenue
ORDER BY 4 DESC;