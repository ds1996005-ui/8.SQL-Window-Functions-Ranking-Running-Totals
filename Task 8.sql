-- 1. Inspect table
SELECT * FROM retail.test_csvfile LIMIT 10;
-- 2. Total sales per neighborhood
SELECT Neighborhood, SUM(SalePrice) AS total_sales
FROM retail.test_csvfile
GROUP BY Neighborhood
ORDER BY total_sales DESC;

-- 3. Rank neighborhoods by sales per year
SELECT YrSold, Neighborhood, SUM(SalePrice) AS total_sales,
       ROW_NUMBER() OVER (PARTITION BY YrSold ORDER BY SUM(SalePrice) DESC) AS row_num
FROM retail.test_csvfile
GROUP BY YrSold, Neighborhood;

-- 4. Compare RANK vs DENSE_RANK
SELECT YrSold, Neighborhood, SUM(SalePrice) AS total_sales,
       RANK() OVER (PARTITION BY YrSold ORDER BY SUM(SalePrice) DESC) AS rank_pos,
       DENSE_RANK() OVER (PARTITION BY YrSold ORDER BY SUM(SalePrice) DESC) AS dense_rank_pos
FROM retail.test_csvfile
GROUP BY YrSold, Neighborhood;

-- 5. Running total sales by month/year
USE retail;
SELECT STR_TO_DATE(CONCAT(YrSold,'-',MoSold,'-01'), '%Y-%m-%d') AS order_date,
       SUM(SalePrice) AS monthly_sales,
       SUM(SUM(SalePrice)) OVER (ORDER BY STR_TO_DATE(CONCAT(YrSold,'-',MoSold,'-01'), '%Y-%m-%d')) AS running_total
FROM test_csvfile
GROUP BY STR_TO_DATE(CONCAT(YrSold,'-',MoSold,'-01'), '%Y-%m-%d')
ORDER BY order_date;


-- 6. Month-over-Month growth
USE retail;
WITH monthly_sales AS (
    SELECT STR_TO_DATE(CONCAT(YrSold,'-',MoSold,'-01'), '%Y-%m-%d') AS month,
           SUM(SalePrice) AS monthly_total
    FROM test_csvfile
    GROUP BY STR_TO_DATE(CONCAT(YrSold,'-',MoSold,'-01'), '%Y-%m-%d')
)
SELECT month, monthly_total,
       LAG(monthly_total) OVER (ORDER BY month) AS prev_month,
       (monthly_total - LAG(monthly_total) OVER (ORDER BY month)) / 
       NULLIF(LAG(monthly_total) OVER (ORDER BY month),0) AS mom_growth
FROM monthly_sales;


-- 7. Top 3 houses per neighborhood
WITH ranked_houses AS (
    SELECT Neighborhood, Id, SalePrice,
           DENSE_RANK() OVER (PARTITION BY Neighborhood ORDER BY SalePrice DESC) AS rank_pos
    FROM retail.test_csvfile
)
SELECT *
FROM ranked_houses
WHERE rank_pos <= 3;
