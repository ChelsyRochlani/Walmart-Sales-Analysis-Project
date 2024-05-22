Create Table if not exists sales (
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price Decimal(10,2) not null,
quantity int not null,
VAT float(6,4) not null,
total decimal(12,4),
Date datetime not null,
time time not null,
payment_method varchar(35) not null,
cogs decimal(10,2) not null,
gross_margin_precentage float(11,9),
gross_income decimal(10,2) not null,
rating float(2,1)
);





-- --------------------------------------------------------------------------------------------
-- ------------------------------------ Feature engineering -----------------------------------

-- time_of_day
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;
     
 Alter table sales add column time_of_day VARCHAR(20);
 
 UPDATE sales
 set time_of_day = (
 CASE 
       WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
      END
 ) ;
 
 -- day_name
 SELECT 
    date,
    DAYNAME(date) As day_name
 from sales;
 
Alter table sales add column day_name VARCHAR(20);

UPDATE sales
 set day_name = dayname(date) ;
 
 -- month_name
 
 select 
     date, 
       monthname(date) as Month_name
	from sales;
    
alter table sales add column month_name varchar(10);

Update sales
  set month_name = monthname(date);    
 
 -- ---------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------
-- --------------------------Generic ------------------------------------------------------------

-- How many unique cities does the data have?
Select 
  distinct city 
from sales;

-- Which city has which branch?
Select 
  distinct city, branch 
from sales; 

-- -----------------------------------------------------------------------------------------------
-- ---------------------------- Product ----------------------------------------------------------

-- How many unique product lines does the data have?
select
    count(distinct product_line)
from sales;

-- What is the most common payment method?
SELECT 
   payment_method,
   count(payment_method) AS TOTAL
from sales
group by payment_method
order by TOTAL desc;

-- What is the most selling product line?
select
    distinct product_line,
    sum(quantity) as total_sales
    from sales
     GROUP BY product_line
	order by total_sales desc ;
    
-- What is the total revenue by month?
select
    distinct month_name as month,
    sum(total - VAT) as total_revenue
    from sales
     GROUP BY month_name
	order by total_revenue desc ;

-- What month had the largest COGS?
SELECT 
   distinct month_name as month,
   sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- What product line had largest revenue?
select
    distinct product_line,
    sum(total - VAT) as total_revenue
    from sales
     GROUP BY product_line
	order by total_revenue desc;
    
-- Which is the city with the largest revenue?
select
    distinct city, branch,
    sum(total - VAT) as total_revenue
    from sales
     GROUP BY city, branch
	order by total_revenue desc;
    
-- What product line had the largest VAT?
select
    distinct product_line,
    AVG(VAT) as Avg_tax
    from sales
     GROUP BY product_line
	order by Avg_tax ;
    
-- Fatch each product line and add a column to those product lines showing "Good","Bad". Good if its greater then average sales.
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;
select 
      product_line,
   CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more product than average product sold?
select 
branch,
   avg(quantity),
   sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);
   
-- What is the most common product line by gender?
Select 
   distinct gender,
   product_line,
   count(gender) as total_count
from sales
group by gender, product_line
order by total_count desc;

-- what is the average rating of each product line?
select
    distinct product_line,
   round( AVG(rating), 2) as avg_rating
    from sales
     GROUP BY product_line
	order by avg_rating ;
-- -----------------------------------------------------------------------------------------------
-- ---------------------------- Customers ----------------------------------------------------------    
-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;


-- What is the most common customer type?
SELECT
	 customer_type,
	count(customer_type) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;


-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
   gender,
   count(*) as total
from sales
group by gender
order by total;

-- What is the gender distribution per branch?
select 
     branch,
     gender,
     count(gender) 
from sales 
group by branch, gender ;

-- Which time of the day do customers give most ratings?
select
	time_of_day,
    count(rating)
    from sales
    group by time_of_day;
    
-- Which time of the day do customers give most ratings per branch?
select
	time_of_day,
    branch,
    count(rating) as rating
    from sales
    group by time_of_day, branch
    order by rating desc;
    
-- Which day fo the week has the best avg ratings?
select
	day_name,
    avg(rating) as avg_rating
    from sales
    group by day_name
    order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?
select
	day_name,
    branch,
    avg(rating) as avg_rating
    from sales
    group by day_name, branch
    order by avg_rating desc;
-- -----------------------------------------------------------------------------------------------
-- ---------------------------- Sales ----------------------------------------------------------    
-- Number of sales made in each time of the day per weekday    
select
     time_of_day, 
     day_name,
     count(*) as Sales
from sales
      where day_name NOT IN ('Sunday', 'Saturday')
group by time_of_day, day_name
order by Sales;

-- Which of the customer types brings the most revenue?
select 
	distinct customer_type,
	sum(gross_income) as revenue
from sales
group by customer_type;


-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select
   city,
    ROUND(AVG(VAT)) AS VAT
from sales
group by city;
     
     
-- Which customer type pays the most in VAT?  
select
   customer_type,
    sum(VAT) AS VAT
from sales
group by customer_type;



-- ---------------------------------------------------------------------------------------------------------------