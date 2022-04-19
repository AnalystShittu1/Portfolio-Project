--DATA EXPLORATION SQL
--Preview each tables in sql
SELECT *
FROM [P & P Data Analysis ].dbo.accounts

SELECT *
FROM [P & P Data Analysis ].dbo.orders

SELECT *
FROM [P & P Data Analysis ].dbo.region

SELECT *
FROM [P & P Data Analysis ].dbo.sales_reps

SELECT *
FROM [P & P Data Analysis ].dbo.web_events

--Calculating the total sales in usd for each account
SELECT a.name, SUM(total_amt_usd) total_sales 
FROM [P & P Data Analysis ].dbo.orders o
JOIN [P & P Data Analysis ].dbo.accounts a
ON a.id = o.account_id GROUP BY a.name;


-- Calculating the average number of each type of product purchased by each account accross orders
SELECT a.name, AVG(o.standard_qty) avg_stand, AVG(o.gloss_qty) avg_gloss, AVG(o.poster_qty) avg_post
FROM [P & P Data Analysis ].dbo.accounts a
JOIN [P & P Data Analysis ].dbo.orders o
	ON a.id = o.account_id
GROUP BY a.name

--Calculating the average amount spent per order on each paper type
SELECT a.name, AVG(o.standard_amt_usd) avg_stand_amt, AVG(o.gloss_amt_usd) avg_gloss_amt, AVG(o.poster_amt_usd) avg_post_amt 
FROM [P & P Data Analysis ].dbo.accounts a
JOIN [P & P Data Analysis ].dbo.orders o 
	ON a.id = o.account_id 
GROUP BY a.name


--Number of orders with total amount occuring in particular year (2016) ..You can also use innequality signs > < at the WHERE clause

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd 
FROM [P & P Data Analysis ].dbo.accounts a
JOIN [P & P Data Analysis ].dbo.orders o
ON  o.account_id = a.id 
WHERE o.occurred_at BETWEEN '01-01-2016' AND '01-01-2017' 
ORDER BY o.occurred_at DESC;

--Customers Orders Segmentation into 'top', middle' and 'low'by purchase amt
SELECT a.name, SUM(total_amt_usd) total_spent, 
	CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top' 
	WHEN SUM(total_amt_usd) > 100000 THEN 'middle' 
	ELSE 'low' END AS customer_level 
FROM [P & P Data Analysis ].dbo.orders o 
JOIN [P & P Data Analysis ].dbo.accounts a 
ON o.account_id = a.id 
GROUP BY a.name 
ORDER BY 2 DESC;

--Determine the total number of times each type of channel from the web_events was used
SELECT w.channel, COUNT(*) channel_usage
FROM [P & P Data Analysis ].dbo.web_events w 
GROUP BY w.channel

--Determine the number of sales reps in each region
SELECT r.name region, COUNT(*) num_reps 
FROM [P & P Data Analysis ].dbo.region r 
JOIN [P & P Data Analysis ].dbo.sales_reps s 
ON r.id = s.region_id 
GROUP BY r.name 
ORDER BY num_reps;

--Show sales rep with associated account in each region (You can add WHERE clause to drilldown)
SELECT r.name region, s.name rep, a.name account
FROM [P & P Data Analysis ].dbo.sales_reps s  
JOIN [P & P Data Analysis ].dbo.region r
ON r.id = s.region_id 
JOIN [P & P Data Analysis ].dbo.accounts a
ON a.sales_rep_id = s.id
--WHERE r.name = 'Midwest'AND s.name LIKE 'S%'
ORDER BY account;

-- Which channel in web events was most used by most accounts
SELECT a.id, a.name,  w.channel, COUNT(*) use_of_channel 
FROM [P & P Data Analysis ].dbo.accounts a 
JOIN [P & P Data Analysis ].dbo.web_events w 
ON a.id = w.account_id 
--WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel 
ORDER BY use_of_channel DESC 
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;

--Determine the number of times a particular channel was used in the web_events table for each sales rep
SELECT s.name, w.channel, COUNT(*) num_events 
FROM [P & P Data Analysis ].dbo.accounts a
JOIN [P & P Data Analysis ].dbo.web_events w  
ON a.id = w.account_id 
JOIN [P & P Data Analysis ].dbo.sales_reps s
ON s.id = a.sales_rep_id 
GROUP BY s.name, w.channel 
ORDER BY num_events DESC;

--Sales rep in each region with the largest amount of sales using CTE
WITH rep_region_sales AS (
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt 
FROM [P & P Data Analysis ].dbo.sales_reps s 
JOIN [P & P Data Analysis ].dbo.accounts a 
ON a.sales_rep_id = s.id 
JOIN [P & P Data Analysis ].dbo.orders o 
ON o.account_id = a.id 
JOIN [P & P Data Analysis ].dbo.region r 
ON r.id = s.region_id 
GROUP BY s.name,r.name),
max_sales AS (
SELECT region_name, MAX(total_amt) total_amt 
FROM rep_region_sales
GROUP BY region_name)
SELECT rep_region_sales.rep_name, rep_region_sales.region_name, rep_region_sales.total_amt
FROM rep_region_sales
JOIN max_sales
ON rep_region_sales.region_name = max_sales.region_name AND rep_region_sales.total_amt = max_sales.total_amt;