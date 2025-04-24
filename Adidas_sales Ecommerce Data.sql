create database if not exists ecommerce ;

use ecommerce;

CREATE TABLE adidas_sales
(
Retailer VARCHAR(255),
RetailerID INT,
InvoiceDate DATE,
Region Varchar(255),
State VARCHAR(255),
City VARCHAR(255),
Product VARCHAR(255),
Price_per_Unit DOUBLE,
Units_Sold INT,
Total_Sales DOUBLE,
Operating_Profit DOUBLE,
Sales_Method VARCHAR(255)
);

CREATE INDEX idx_invoice_date ON adidas_sales(InvoiceDate);
CREATE INDEX idx_product ON adidas_sales(Product);
CREATE INDEX idx_retailer ON adidas_sales(Retailer);

-- Query 1: Use SELECT, WHERE, ORDER BY, GROUP BY
-- Total sales and units sold by product in 2020, sorted by total sales
SELECT Product, 
       SUM(Total_Sales) as Total_Sales, 
       SUM(Units_Sold) as Total_Units_Sold
FROM adidas_sales
WHERE YEAR(InvoiceDate) = 2020
GROUP BY Product
ORDER BY Total_Sales DESC;

-- Query 2: Use INNER JOIN
-- Compare sales between regions for the same retailer and date
SELECT a.Region, a.Retailer, SUM(a.Total_Sales) as Region_Sales
FROM adidas_sales a
INNER JOIN adidas_sales b ON a.Retailer = b.Retailer AND a.InvoiceDate = b.InvoiceDate
WHERE a.InvoiceDate BETWEEN '2020-01-01' AND '2021-12-31'
GROUP BY a.Region, a.Retailer
ORDER BY Region_Sales DESC;


-- Query 3: Use LEFT JOIN
-- Sales by retailer, including those with no 2021 sales
SELECT a.Retailer, 
       COALESCE(SUM(a.Total_Sales), 0) as Sales_2020,
       COALESCE(SUM(b.Total_Sales), 0) as Sales_2021
FROM adidas_sales a
LEFT JOIN adidas_sales b ON a.Retailer = b.Retailer 
    AND YEAR(b.InvoiceDate) = 2021
WHERE YEAR(a.InvoiceDate) = 2020
GROUP BY a.Retailer
ORDER BY Sales_2020 DESC;

-- Query 4: Use RIGHT JOIN
-- Sales by city, including cities with only 2021 data
SELECT b.City, 
       COALESCE(SUM(a.Total_Sales), 0) as Sales_2020,
       COALESCE(SUM(b.Total_Sales), 0) as Sales_2021
FROM adidas_sales a
RIGHT JOIN adidas_sales b ON a.City = b.City 
    AND YEAR(a.InvoiceDate) = 2020
WHERE YEAR(b.InvoiceDate) = 2021
GROUP BY b.City
ORDER BY Sales_2021 DESC;

-- Query 5: Use Subquery
-- Top 3 states by average operating profit per sale
SELECT State, Avg_Profit
FROM (
    SELECT State, AVG(Operating_Profit) as Avg_Profit
    FROM adidas_sales
    WHERE Total_Sales > 0
    GROUP BY State
) sub
ORDER BY Avg_Profit DESC
LIMIT 3;

-- Query 6: Use Aggregate Functions (SUM, AVG)
-- Average price and total profit by sales method
SELECT Sales_Method, 
       AVG(Price_per_Unit) as Avg_Price,
       SUM(Operating_Profit) as Total_Profit
FROM adidas_sales
GROUP BY Sales_Method
HAVING Total_Profit > 10000
ORDER BY Total_Profit DESC;

-- Query 7: Create View for Analysis
-- View for product performance by region
CREATE VIEW Product_Performance AS
SELECT Region, Product, 
       SUM(Total_Sales) as Total_Sales,
       AVG(Units_Sold) as Avg_Units_Sold,
       SUM(Operating_Profit) / SUM(Total_Sales) * 100 as Profit_Margin
FROM adidas_sales
GROUP BY Region, Product;

-- Query 8: Use View for Analysis
-- Top products by profit margin in the Northeast region
SELECT Product, Total_Sales, Profit_Margin
FROM Product_Performance
WHERE Region = 'Northeast' AND Total_Sales > 50000
ORDER BY Profit_Margin DESC;

-- Query 9: Combine Subquery and Aggregate Functions
-- Cities with above-average total sales
SELECT City, SUM(Total_Sales) as Total_Sales
FROM adidas_sales
GROUP BY City
HAVING SUM(Total_Sales) > (
    SELECT AVG(Total_Sales)
    FROM (
        SELECT SUM(Total_Sales) as Total_Sales
        FROM adidas_sales
        GROUP BY City
    ) avg_sales
)
ORDER BY Total_Sales DESC;

-- Query 10: Use GROUP BY and ORDER BY for Trend Analysis
-- Monthly sales for Women's Apparel in 2021
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') as Month, 
       SUM(Total_Sales) as Total_Sales,
       AVG(Price_per_Unit) as Avg_Price
FROM adidas_sales
WHERE Product = 'Women''s Apparel' AND YEAR(InvoiceDate) = 2021
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Month;