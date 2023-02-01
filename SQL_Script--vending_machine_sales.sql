USE vending_machine;

SELECT * FROM vm_sales;

SELECT DISTINCT(Status)
FROM vm_sales;

# amount of sales -- 6445
SELECT COUNT(*) FROM vm_sales;

# unique transactions -- 6110
SELECT COUNT(DISTINCT(Transaction))
FROM vm_sales;

# CLEANING DATA ------------------------------------------------

# DUPLICATE DATA 

# checking duplicate transactions

# count -- 280 
WITH dups AS (
	SELECT Transaction
	FROM vm_sales
	GROUP BY Transaction
	HAVING COUNT(*) >1) 

SELECT COUNT(*)
FROM dups;

# looking at a few duplicate transactions
SELECT *
FROM vm_sales
WHERE Transaction IN (
	SELECT Transaction
	FROM vm_sales
	GROUP BY Transaction
	HAVING COUNT(*) >1);

# examining why a transaction occurs more than once     
SELECT COUNT(DISTINCT(Transaction))
FROM vm_sales
WHERE Transaction IN (
	SELECT Transaction
	FROM vm_sales
	GROUP BY Transaction
	HAVING COUNT(*) >1) AND TransTotal > LineTotal;
# the transaction numbers that occur more than once are ones that have more than one item per transaction
# each item in the transaction gets its own row, that is why the transaction number appears more than once 
# count -- 280

# DATES

# using str_to_date for Transdate
SELECT Transdate, STR_TO_DATE(Transdate, "%W, %M %d, %Y")
FROM vm_sales;

# adding new column for Transdate in date format

ALTER TABLE vm_sales
ADD Transdate_conv DATE;

# adding dates into the Transdate_conv
UPDATE vm_sales
SET Transdate_conv = STR_TO_DATE(Transdate, "%W, %M %d, %Y");

# using str_to_date for PrcdDate
SELECT PrcdDate, STR_TO_DATE(PrcdDate, "%c/%d/%Y")
FROM vm_sales;

# adding new column for PrcdDate in date format

ALTER TABLE vm_sales
ADD PrcdDate_conv Date;

UPDATE vm_sales
SET PrcdDate_conv = STR_TO_DATE(PrcdDate, "%c/%d/%Y");

# adding new column for month

SELECT Transdate_conv, MONTH(Transdate_conv) AS Month
FROM vm_sales;

ALTER TABLE vm_sales
ADD Month INT;

UPDATE vm_sales
SET Month = MONTH(Transdate_conv);

# adding new column for day of the week
SELECT Transdate_conv, DAYOFWEEK(Transdate_conv) AS weekday
FROM vm_sales;

ALTER TABLE vm_sales
ADD Weekday INT;

UPDATE vm_sales
SET Weekday = DAYOFWEEK(Transdate_conv);
# 1= sunday, 7= saturday 

# MISSING CATEGORY

# checking blanks- Product
SELECT COUNT(*)
FROM vm_sales
WHERE Product = "";

SELECT *
FROM vm_sales
WHERE Product = "";

SELECT DISTINCT(Product), RCoil, MCoil
FROM vm_sales
WHERE RCoil = 120 AND Machine= "EB Public Library x1380";
# 2 products have 120 AS the RCoil, we can't use the RCoil to fill in the missing information

# checking blanks- Category
SELECT COUNT(*)
FROM vm_sales
WHERE Category = "";

SELECT COUNT(DISTINCT(Product))   
FROM vm_sales
WHERE Category = "";

SELECT DISTINCT(Product)   
FROM vm_sales
WHERE Category = "";

SELECT product, COUNT(*)
FROM vm_sales
WHERE Category = ""
GROUP BY product;

# looked up the products, but use exisiting data just to make sure
# finding doritos
SELECT DISTINCT(Product), category
FROM vm_sales
WHERE product LIKE "%Doritos%" AND Category != "";
#food

# finding go paks
SELECT DISTINCT(Product), Category
FROM vm_sales
WHERE product LIKE "%go Paks%" AND Category != "";
#food

# looking for starbucks with a blank
SELECT DISTINCT(Product), Category
FROM vm_sales
WHERE product LIKE "%Starbucks Doubleshot Energy%" AND category != "";
# Non Carbonated

# finding canada dry - ginger ale
SELECT DISTINCT(Product), Category
FROM vm_sales
WHERE product LIKE "%Canada Dry%" AND Category != "";

# finding ginger ale
SELECT DISTINCT(Product), Category
FROM vm_sales
WHERE product LIKE "%Ginger Ale%" AND Category != "";

# checking carbonated
SELECT DISTINCT(Product)
FROM vm_sales
WHERE Category = "Carbonated";

# updating missing categories

UPDATE vm_sales
SET Category = "Food"
WHERE Product = "Doritos Dinamita Chile Lemon" AND Category = "";

UPDATE vm_sales
SET Category = "Food"
WHERE Product = "Doritos Spicy Nacho" AND Category = "";

UPDATE vm_sales
SET Category = "Food"
WHERE Product = "Mini Chips Ahoy - Go Paks" AND Category = "";

UPDATE vm_sales
SET Category = "Food"
WHERE Product = "Oreo Mini - Go Paks" AND Category = "";

UPDATE vm_sales
SET Category = "Food"
WHERE Product = "Teddy Grahams - Go Paks" AND Category = "";

UPDATE vm_sales
SET Category = "Non Carbonated"
WHERE Product = "Starbucks Doubleshot Energy - Coffee" AND Category = "";

UPDATE vm_sales
SET Category = "Carbonated"
WHERE Product = "Canada Dry - Ginger Ale & Lemonde" AND Category = "";

UPDATE vm_sales
SET Category = "Carbonated"
WHERE Product = "Canada Dry - Ginger Ale" AND Category = "";

# checking to make sure everything was updated
SELECT *
FROM vm_sales
WHERE Category = "";

# EXPLORING DATA ------------------------------------------------

# count of all transactions - 6107
SELECT COUNT(DISTINCT(Transaction)) AS Sales
FROM vm_sales
WHERE Status != "Unlinked" AND Product != "";

# average amount of products per transction -- 1.05
SELECT ROUND(AVG(Count), 2)
FROM (
	SELECT Transaction, COUNT(Product) AS Count
    FROM vm_sales
    WHERE Status != "Unlinked" AND Category != ""
    GROUP BY Transaction) AS PCount;

# date range of transactions
SELECT MIN(Transdate_conv) AS StartDate, MAX(Transdate_conv) AS EndDate
FROM vm_sales;
# 1/1/2022 - 8/31/2022

# price of products
SELECT
	MIN(Rprice) AS LowestPrice,
    MAX(Rprice) AS HighestPrice,
    ROUND(AVG(Rprice), 2) AS AveragePrice
FROM vm_sales
WHERE Status != "Unlinked" AND Category != "";

# price of transactions
SELECT
	MIN(TransTotal) AS SmallestTransaction,
	MAX(TransTotal) AS LargestTransaction,
    ROUND(AVG(TransTotal), 2) AS AverageTransaction
FROM vm_sales
WHERE Status != "Unlinked" AND Category != "";

# payment type -- EXPORTED
SELECT Type, ROUND(COUNT(Type) / SUM(COUNT(Type)) OVER() *100, 2) AS PaymentType
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Type;

# products per category- percentage -- EXPORTED
SELECT Category, ROUND(COUNT(DISTINCT(Product))/ SUM(COUNT(DISTINCT(Product))) OVER() *100, 2) AS Makeup
FROM vm_sales
WHERE Status != "Unlinked" AND Product != ""
GROUP BY Category;

# categories- percentage -- EXPORTED
SELECT 
	Category,
    ROUND(COUNT(Category)/SUM(COUNT(Category)) OVER() * 100 ,2) AS SalesPrecentage
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Category;

# categories by location - count -- EXPORTED
SELECT 
	Location, 
    Category,
    COUNT(*) AS AmountSold
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Location, Category
ORDER BY Location, Category;

# amount of money made by location -- EXPORTED
SELECT Location, SUM(TransTotal) AS AmountMade
FROM vm_sales
WHERE Status != "Unlinked" and Category != ""
GROUP BY Location
ORDER BY AmountMade desc;

# amount made by month -- EXPORTED
SELECT Month, SUM(TransTotal) AS AmountMade
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Month
ORDER BY Month;
# maybe do a join of sales and money for a line chart

# amount made by month by location -- EXPORTED
SELECT Location, Month, SUM(TransTotal) AS AmountMade
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Location, Month
ORDER BY Location, Month;

# amount made by day of week -- EXPORTED
SELECT Weekday, SUM(TransTotal) AS AmountMade
FROM vm_sales
WHERE Status != "Unlinked" AND Category != ""
GROUP BY Weekday
ORDER BY Weekday;

# amount made by day of week at each location
SELECT Location, Weekday, SUM(TransTotal) AS AmountMade
FROM vm_sales
WHERE Status != "Unlinked" AND Category != "" 
GROUP BY Location, Weekday
ORDER BY Location, Weekday;