----- SETUP -----

-- Ensuring that the 'bikestores' table imported successfully
SELECT *
FROM portfolioproject.bikestores;

----- DATA MINING -----

-- 1.) Total Orders, Revenue, and Average Revenue per Order --

	-- Overall --
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / COUNT(DISTINCT order_id) AS average_revenue_per_order
FROM portfolioproject.bikestores;
ORDER BY total_orders DESC;

	-- By Product Category --
SELECT
	category_name AS product_category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / COUNT(DISTINCT order_id) AS average_revenue_per_order
FROM portfolioproject.bikestores
GROUP BY category_name
ORDER BY total_orders DESC;
    
    -- By Brand Name --
SELECT
	brand_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / COUNT(DISTINCT order_id) AS average_revenue_per_order
FROM portfolioproject.bikestores
GROUP BY brand_name
ORDER BY total_orders DESC;

-- 2.) Montly Sales Trend --

	-- Monthly sales and total revenue with year --
SELECT 
	year, 
	month, 
    SUM(revenue) AS total_revenue
FROM
	(
	SELECT 
		order_date,
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
		MONTH(STR_TO_DATE(order_date, '%m/%d/%Y')) AS month,
		revenue
	FROM portfolioproject.bikestores
	) AS subquery
GROUP BY year, month
ORDER BY year, month;

	-- Month and Year with the Highest Sales --
SELECT 
	year, 
	month, 
    SUM(revenue) AS total_revenue
FROM
	(
	SELECT 
		order_date,
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
		MONTH(STR_TO_DATE(order_date, '%m/%d/%Y')) AS month,
		revenue
	FROM portfolioproject.bikestores
	) AS subquery
GROUP BY year, month
ORDER BY SUM(revenue) DESC
LIMIT 1;

	-- Month and Year with the Lowest Sales --
SELECT 
	year, 
	month, 
    SUM(revenue) AS total_revenue
FROM
	(
	SELECT 
		order_date,
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
		MONTH(STR_TO_DATE(order_date, '%m/%d/%Y')) AS month,
		revenue
	FROM portfolioproject.bikestores
	) AS subquery
GROUP BY year, month
ORDER BY SUM(revenue) ASC
LIMIT 1;

-- 3.) Top Selling Products --

	-- Top 5 best-selling products drill down based units sold per year --
SELECT
	year,
    product_type,
    total_units_sold
FROM (
	SELECT
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
		category_name AS product_type,
		SUM(total_units) AS total_units_sold,
		ROW_NUMBER() OVER (
			PARTITION BY YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) 
            ORDER BY SUM(total_units) DESC) AS rn 
	FROM portfolioproject.bikestores
	GROUP BY 
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')),
		category_name
) AS subquery
WHERE rn <= 5;

    -- Revenue generated from top-selling products by year --
SELECT
	year,
    product_type,
    total_revenue_generated
FROM (
	SELECT
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) AS year,
		category_name AS product_type,
		SUM(revenue) AS total_revenue_generated,
		ROW_NUMBER() OVER (
			PARTITION BY YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')) 
            ORDER BY SUM(revenue) DESC) AS rn 
	FROM portfolioproject.bikestores
	GROUP BY 
		YEAR(STR_TO_DATE(order_date, '%m/%d/%Y')),
		category_name
) AS subquery
WHERE rn <= 5;

-- 4.) Sales Representative Performance --

	-- Top 5 sales rep with highest sales  --
WITH SalesData AS (
    SELECT
        sales_rep_id,
        SUM(revenue) AS total_sales
    FROM portfolioproject.bikestores
    GROUP BY sales_rep_id
)
SELECT
    s.sales_rep_id,
    e.first_name,
    e.last_name,
    s.total_sales
FROM SalesData s
JOIN employees e ON s.sales_rep_id = e.employee_id
ORDER BY s.total_sales DESC
LIMIT 5;

    -- Average revenue generated by each sales rep
SELECT
    sales_rep_id,
    AVG(revenue) AS average_revenue
FROM portfolioproject.bikestores
GROUP BY sales_rep_id;

-- 5.) Customer Analysis

	-- Top 5 customers with the highest number of orders
    -- Total revenue generated from each of the top customers
    
 WITH TopCustomers AS (
    SELECT
        customers,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(revenue) AS total_revenue
    FROM portfolioproject.bikestores
    GROUP BY customers
    ORDER BY total_orders DESC
    LIMIT 5
)
SELECT
    customers,
    total_orders,
    total_revenue
FROM TopCustomers;
   
    
    
    