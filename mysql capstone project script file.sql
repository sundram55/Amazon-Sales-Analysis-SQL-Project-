create database amazondb;
CREATE TABLE Amazon_data (
    invoice_id VARCHAR(30) NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method varchar(30) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT NOT NULL,
    gross_income DECIMAL(10, 2) NOT NULL,
    rating FLOAT NOT NULL
);
alter table amazon_data add column timeofday varchar(15);

update amazon_data
set timeofday = 
    CASE 
        WHEN HOUR(time) BETWEEN 5 AND 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;

alter table amazon_data add column dayname varchar(10);
update amazon_data
set dayname = dayname(date);

alter table amazon_data add column monthname varchar(15);
update amazon_data
set monthname = monthname(date);

select*from amazon_data;

-- 1. What is the count of distinct cities in the dataset?
SELECT 
    COUNT(DISTINCT city) city_count
FROM
    amazon_data;

-- 2. For each branch, what is the corresponding city?
SELECT DISTINCT
    branch, city
FROM
    amazon_data;

-- 3. What is the count of distinct product lines in the dataset?
SELECT 
    COUNT(DISTINCT product_line) cdpl
FROM
    amazon_data;

-- 4. Which payment method occurs most frequently?
SELECT 
    payment_method, COUNT(*) count_payment_method
FROM
    amazon_data
GROUP BY payment_method
ORDER BY count_payment_method DESC
LIMIT 1;

-- 5. Which product line has the highest sales?
SELECT 
    product_line, SUM(gross_income) highest_sales
FROM
    amazon_data
GROUP BY product_line
ORDER BY highest_sales DESC;

-- 6. How much revenue is generated each month?
SELECT 
    monthname, SUM(total) monthly_revenue
FROM
    amazon_data
GROUP BY monthname
ORDER BY monthly_revenue DESC;

-- 7. In which month did the cost of goods sold reach its peak?
SELECT 
    monthname, MAX(cogs) max_monthly_cogs
FROM
    amazon_data
GROUP BY monthname
ORDER BY max_monthly_cogs DESC;

-- 8. Which product line generated the highest revenue?
SELECT 
    product_line, SUM(total) revenue
FROM
    amazon_data
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- 9. In which city was the highest revenue recorded?
SELECT 
    city, SUM(total) highest_revenue
FROM
    amazon_data
GROUP BY city
ORDER BY highest_revenue DESC
LIMIT 1;

-- 10. Which product line incurred the highest Value Added Tax?
SELECT 
    product_line, SUM(vat) high_vat
FROM
    amazon_data
GROUP BY product_line
ORDER BY high_vat DESC
LIMIT 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line, gross_income, avg(gross_income) over() avg_gross_income ,
case
   when  gross_income > (select avg(gross_income) from amazon_data) then "Good"
        else "Bad"
        end sales_performance
from amazon_data;
   
-- 12. Identify the branch that exceeded the average number of products sold.
SELECT DISTINCT
    branch
FROM
    amazon_data
WHERE
    quantity > (SELECT 
            AVG(quantity)
        FROM
            amazon_data);

-- 13. Which product line is most frequently associated with each gender?
with cte as (
select product_line, gender, count(*) count_product_line,
rank() over( partition by  gender order by count(*) desc ) rk from amazon_data
group by product_line, gender)
select * from cte where rk=1;

-- 14. Calculate the average rating for each product line.
SELECT 
    product_line, AVG(rating) avg_rating
FROM
    amazon_data
GROUP BY product_line;

-- 15. Count the sales occurrences for each time of day on every weekday.
SELECT 
    dayname, timeofday, COUNT(*) sales_occurrence
FROM
    amazon_data
GROUP BY dayname , timeofday
ORDER BY dayname , sales_occurrence DESC;

-- 16. Identify the customer type contributing the highest revenue.
SELECT 
    customer_type, SUM(total) contribute_revenue
FROM
    amazon_data
GROUP BY customer_type;

-- 17. Determine the city with the highest VAT percentage.
SELECT 
    city,
    SUM(vat),
    SUM(total),
    (SUM(vat) / SUM(total)) * 100 vat_percentage
FROM
    amazon_data
GROUP BY city;

-- 18. Identify the customer type with the highest VAT payments.
SELECT 
    customer_type, SUM(vat) high_vat_payment
FROM
    amazon_data
GROUP BY customer_type
ORDER BY high_vat_payment DESC;

-- 19. What is the count of distinct customer types in the dataset?
SELECT 
    COUNT(DISTINCT customer_type) distinct_customer_type
FROM
    amazon_data;

-- 20. What is the count of distinct payment methods in the dataset?
SELECT 
    COUNT(DISTINCT payment_method) distinct_payment_method
FROM
    amazon_data;

-- 21. Which customer type occurs most frequently?
SELECT 
    customer_type, COUNT(*) most_frequent
FROM
    amazon_data
GROUP BY customer_type;

-- 22. Identify the customer type with the highest purchase frequency.
SELECT 
    customer_type, SUM(quantity) total_quantity
FROM
    amazon_data
GROUP BY customer_type
ORDER BY total_quantity DESC
LIMIT 1;

-- 23. Determine the predominant gender among customers.
SELECT 
    gender, COUNT(*) count_gender
FROM
    amazon_data
GROUP BY gender
ORDER BY count_gender DESC
LIMIT 1;

-- 24. Examine the distribution of genders within each branch.
SELECT 
    branch, gender, COUNT(*) gender_distribution
FROM
    amazon_data
GROUP BY branch , gender
ORDER BY branch;

-- 25. Identify the time of day when customers provide the most ratings.
SELECT 
    timeofday, COUNT(rating) most_rating
FROM
    amazon_data
GROUP BY timeofday
ORDER BY most_rating DESC;

-- 26. Determine the time of day with the highest customer ratings for each branch.
with cte as (select branch, timeofday, count(rating) highest_rating, 
rank() over(partition by timeofday order by count(rating) desc) rk from amazon_data
group by branch, timeofday)
select branch, timeofday, highest_rating from cte where rk=1;

-- 27. Identify the day of the week with the highest average ratings.
-- method :1 using cte
with ct as 
(select dayname, avg(rating) avg_rating from amazon_data
group by dayname)
select max(avg_rating) max_avg_rating from ct;

-- method :2 using group by and all
SELECT 
    dayname, AVG(rating) avg_rating
FROM
    amazon_data
GROUP BY dayname
ORDER BY avg_rating DESC
LIMIT 1;

-- 28. Determine the day of the week with the highest average ratings for each branch.
with cte as 
(select branch, dayname, avg(rating) avg_rating,
rank() over(partition by branch order by avg(rating) desc) rk from amazon_data
group by branch, dayname)
select branch, dayname, avg_rating from cte
where rk=1;

/* Product Analysis: 
--> The dataset features six distinct product lines, among which Food and Beverages stands out as the 
top performer in cumulative sales.
--> Food and Beverages not only leads in total sales but also accounts for the highest revenue, 
indicating strong consumer demand for these products.
--> This analysis suggests that prioritizing food and beverage offerings may significantly enhance overall 
sales and revenue potential.

Sales Analysis:
--> Among the three cities, Naypyitau (Branch C) leads in revenue generation, highlighting its strong market presence 
or higher purchasing power in that area.
--> The predominant payment method is Ewallet, reflecting a clear preference for digital transactions among our 
customers. This insight suggests the potential for policies that offer incentives, such as coupons, for Ewallet users.
--> Member customers are the largest contributors to revenue, underscoring the value of loyalty programs and 
incentives designed to retain these key customers.

Customer Analysis: 
--> While the gender distribution is fairly balanced, female customers generate slightly more revenue than their 
male counterparts, indicating potential for targeted marketing strategies or tailored product offerings.
--> A branch-wise analysis highlights differences in gender contributions: males are more prominent in Branches 
A and B, whereas females are the key contributors in Branch C. This insight suggests the need for branch-specific 
marketing strategies.
--> The afternoon emerges as the peak time for customer ratings across all branches, indicating heightened 
engagement with products or services during this period. 

*/

















