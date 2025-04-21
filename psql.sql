select * from walmart

select distinct payment_method from walmart

/* Q1 Find different payment method and number of transactions, number of qty sold*/
select payment_method, count(*), sum(quantity) from walmart group by payment_method



/* Q2 Identify the highest-rated category in each branch, displaying the branch, category*/

with cte as (select branch, category, avg(rating) as avg, rank() over(partition by branch order by avg(rating) desc) as r from walmart 
group by 1 , 2)

select branch, category,avg, r from cte where r=1



/* Q3 Identify the busiest day for each branch based on the number of transactions*/

with cte as(select branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') as dayname,
count(invoice_id) as transactions, rank() over (partition by branch order by count(invoice_id) desc) as r from walmart group by branch, dayname order by 1,3 desc)

select branch, dayname, transactions, r from cte where r=1



/*Q4*Calculate the total quantity of items sold per payment method. List payment_method and total_quantity*/
select sum(quantity), payment_method from walmart group by payment_method

/*Q5 Determine the average, minimum, and maximum rating of category for each city. 
List the city, average_rating, min_rating, and max_rating.*/

select max(rating),min(rating), avg(rating), city, category from walmart group by city, category


/*Q6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.*/

select category, sum(unit_price*quantity*profit_margin) as p from walmart group by category order by sum(unit_price*quantity*profit_margin)


/*Q7*  most common method of payment for each branch */


with cte as (select branch, payment_method, count(*), rank() over(partition by branch order by count(*) desc) as r   from walmart group by branch, payment_method)

select branch, payment_method from cte where r=1

/*Q8  categorize sales in 3 groups morning, afternoon, evening
Find out each of the shift and number of invoices*/

select time::time from walmart

select branch,
case
when extract(hour from (time::time))<12 then 'morning'
when extract(hour from (time::time)) between 12 and 17 then ' afternoon'
else 'evening' 
end  day_time, count(*) from walmart group by branch, day_time order by branch, count(*)



-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 

	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5





