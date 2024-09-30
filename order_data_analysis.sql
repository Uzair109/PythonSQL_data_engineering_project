SELECT * FROM df_orders;

CREATE TABLE df_orders(
order_id int primary key,
order_date date, 
ship_mode varchar(20), 
segment varchar(20), 
country varchar(20), 
city varchar(20), 
state varchar(20), 
postal_code varchar(20), 
region varchar(20), 
category varchar(20),
sub_category varchar(20), 
product_id varchar(50), 
quantity int, 
discount decimal(7,2), 
sale_price decimal(7,2), 
profit decimal(7,2)
);

-- find top 10 highest revenue generating products
Select sub_category As product, Sum(sale_price) As revenue 
From df_orders
Group by sub_category
Order by revenue desc 
Limit 10;

-- find top 5 highest selling products in each region
With cte As(
Select region, sub_category As product, Sum(sale_price) As revenue,
Row_Number() over (partition by region order by Sum(sale_price)) As no_of_products 
From df_orders
Group by region, product
)
Select * From cte                                               
Where no_of_products <= 5;

-- find month over month growth comparison for 2022 and 2023 sales
With cte As(
Select Year(order_date) As odr_year, Month(order_date) As odr_month, Sum(sale_price) As revenue
From df_orders
Group by odr_year,odr_month
Order by odr_month
)
Select odr_month,
Sum(case when odr_year=2022 then revenue else 0 end) As sales_of_2022,
Sum(case when odr_year=2023 then revenue else 0 end) As sales_of_2023
From cte
Group by odr_month;

-- for each category which month had highest sales
With cte2 As(
Select  category, order_date As order_date_and_month, Sum(sale_price) As revenue,
Row_Number() over (partition by category order by Sum(sale_price) desc) as row_no 
From df_orders
Group by category, order_date_and_month
Order by category,revenue desc
)
Select *
From cte2 
Where row_no = 1;

-- which sub_category had highest growth by profit in 2023 compare to 2022
With cte As (
Select sub_category As product, Year(order_date) As odr_year, Sum(sale_price) As sales
From df_orders
Group by product, odr_year
Order by product, odr_year
),
cte2 As(
Select product, 
Sum(case when odr_year=2022 then sales else 0 end) As sales_of_2022,
Sum(case when odr_year=2023 then sales else 0 end) As sales_of_2023
From cte
Group by product
)
Select *, (sales_of_2023-sales_of_2022)*100/sales_of_2022 As highest_sales  
From cte2
Order by highest_sales desc
Limit 2; 









