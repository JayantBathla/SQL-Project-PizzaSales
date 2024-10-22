Create Database if not exists Pizza_Sales;
use pizza_sales;
Create Table orders (
       order_id int not null,
       order_date date not null,
       order_time time not null,
       primary key(order_id));
       
Create Table order_details (
       order_details_id int not null,
       order_id int not null,
       pizza_id text not null,
	   quantity int not null,
       primary key(order_details_id));
       
       
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- Retrieve the total number of orders placed.
select count(order_id) from orders; 

-- Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity*pizzas.price),2) as total_sales
        from order_details
		Join pizzas
		on order_details.pizza_id = pizzas.pizza_id;
        
-- Identify the highest-priced pizza.

select pizza_types.name, max(pizzas.price) 
     from pizza_types
     join pizzas
	 on pizzas.pizza_type_id = pizza_types.pizza_type_id
     group by pizza_types.name
     order by max(pizzas.price) 
     desc limit 1;
     
-- Identify the most common pizza size ordered.
select size ,count(order_details.quantity) from pizzas
      join order_details
      on pizzas.pizza_id = order_details.pizza_id
      group by size 
      order by count(order_details.quantity) DESC;
      
      
-- List the top 5 most ordered pizza types along with their quantities.

  select pizza_types.name ,sum(order_details.quantity) as qty_ordered from pizza_types
      join pizzas
      on pizzas.pizza_type_id = pizza_types.pizza_type_id
      join order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.name
      order by sum(order_details.quantity)
      DESC limit 5;
      
-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category ,sum(order_details.quantity) as qty_ordered from pizza_types
      join pizzas
      on pizzas.pizza_type_id = pizza_types.pizza_type_id
      join order_details
      on order_details.pizza_id = pizzas.pizza_id
      group by pizza_types.category
      order by sum(order_details.quantity)
      DESC;
      
      
-- Determine the distribution of orders by hour of the day.

select hour(orders.order_time) as hour_of_the_day, sum(order_details.quantity)
       from orders
       join order_details
       on orders.order_id = order_details.order_id
       group by hour_of_the_day
       order by sum(order_details.quantity)
       DESC ;
       
       
-- Join relevant tables to find the category-wise distribution of pizzas.
select pizza_types.*, pizzas.size , pizzas.price from pizza_types
      join pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id;
      
      
-- Group the orders by date and calculate the average number of pizzas ordered per day.

select orders.order_date , avg(order_details.quantity) as avg_qty from orders
      join order_details
      on orders.order_id = order_details.order_id
      group by ORDERS.order_date
      order by avg_qty;
      
-- Determine the top 3 most ordered pizza types based on revenue.

select * from 
              ( select pizza_types.name, pizzas.size , sum(pizzas.price*order_details.quantity) as revenue
                          from pizza_types
                           join pizzas
                           on pizzas.pizza_type_id = pizza_types.pizza_type_id
                           join order_details
                           on order_details.pizza_id = pizzas.pizza_id
                           group by pizza_types.name, pizzas.size
                           order by sum(pizzas.price*order_details.quantity) DESC LIMIT 3) as pizza_revenue;
                           

-- Calculate the percentage contribution of each pizza type to total revenue.

WITH total_revenue AS (
		SELECT SUM(order_details.quantity * pizzas.price) AS total_rev
		FROM order_details
        JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
                      ),
Individual_revenue AS (
                 SELECT pizza_types.name AS p_names, pizzas.size, 
				 SUM(pizzas.price * order_details.quantity) AS revenue
				 FROM pizza_types
                 JOIN pizzas
                 ON pizzas.pizza_type_id = pizza_types.pizza_type_id
                 JOIN order_details
                 ON order_details.pizza_id = pizzas.pizza_id
                 GROUP BY pizza_types.name, pizzas.size
					 )
SELECT 
    Individual_revenue.p_names, 
    round((Individual_revenue.revenue / total_revenue.total_rev) * 100, 2)AS perct_contribution
FROM 
    Individual_revenue, total_revenue;
              
 -- Analyze the cumulative revenue generated over time.

WITH sum_rev AS ( 
    SELECT  
        orders.order_date, 
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY dayname(orders.order_date), orders.order_date 
    ORDER BY SUM(order_details.quantity * pizzas.price)
)
SELECT 
    sum_rev.order_date, 
    dayname(sum_rev.order_date) AS day_name, 
    SUM(sum_rev.revenue) 
    OVER (ORDER BY sum_rev.order_date) AS cumulative_rev
FROM sum_rev;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.



select * from (
  select pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue,
  row_number() over(partition by pizza_types.category order by sum(order_details.quantity*pizzas.price)DESC ) as pizza_rank 
	    from pizza_types
        JOIN pizzas
	    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
		JOIN order_details
		ON order_details.pizza_id = pizzas.pizza_id
        Group by pizza_types.category, pizza_types.name
              ) t1 
              Where t1.pizza_rank<=3



                      
	
	
	

  
  
  
                  
       
     



