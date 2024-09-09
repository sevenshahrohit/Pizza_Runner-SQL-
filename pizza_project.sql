CREATE SCHEMA pizza_runner;
# SET search_path = pizza_runner;

use pizza_runner;

DROP TABLE IF EXISTS runner;
CREATE TABLE runner (
  runner_id INTEGER,
  registration_date DATE
);
show tables;

INSERT INTO runner
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  
  CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('6', '3', 'null', 'null', NULL, 'Restaurant Cancellation'),
  ('9', '2', 'null', 'null', NULL, 'Customer Cancellation');

  
  CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
  
  CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  select * from customer_orders;
  
  # Data Cleaning: make NULL if entries in extras is 'null' or blank
  update customer_orders set extras = NULL where extras ='null' or extras = '';
  update runner_orders set cancellation = NULL where cancellation ='null' or cancellation = '';
  
  # km and minutes: remove the strings and just keep the number
  select * from runner_orders;
  update runner_orders set distance=trim(replace(distance,'km',''));
  delete from runner_orders where order_id IS NULL and duration IS NULL;
  
  # CHANGE DATA TYPE FROM VARCHAR TO FLOAT of distance column
  alter table runner_orders modify column distance FLOAT;
  
  #PART 1: PIZZA METRICS
  #	Q1. How many pizzas were ordered?
  
  select count(*) as pizza_order from customer_orders;
  
  # Q2. How many unique customer orders were made?
  
  select count(distinct(order_id)) as uniqie_customer_order_count from customer_orders;
  
  # Q3. How many successfull orders were delivered by each runner?
  
  select count(order_id) as successfull_orders_count ,runner_id from runner_orders where cancellation is null group by 2;
  
  # Q4. How many of each type of pizza was delivered?
  
  select count(c_o.order_id) as pizza_delivered, c_o.pizza_id from customer_orders c_o join runner_orders r_o
  on c_o.order_id = r_o.order_id where r_o.cancellation is null group by 2 ;
  
  # Q5. How many vegetarian and meatlover were ordered by each customer?
  
  select count(c_o.order_id) as order_count, c_o.customer_id, p_n.pizza_name from customer_orders as c_o join pizza_names as p_n
  on c_o.pizza_id = p_n.pizza_id group by 3,2;
  
  # Q6. What was the maximum number of pizzas deivered in a single order?
  
 select c_o.order_id, count(c_o.pizza_id) no_of_pizza  from runner_orders r_o
  join customer_orders c_o on r_o.order_id = c_o.order_id
  where cancellation is null group by 1 order by  no_of_pizza desc;
  
  # Q7. For each customer, how many delivered pizzas had atleast 1 change and how many had no change?
  
  select c_o.customer_id, count(c_o.pizza_id) as no_of_pizza,
  sum(case when c_o.exclusions >= 1 or c_o.extras >= 1 then 1 else 0 
  end) as 'Atleast 1 change',
  sum(case when c_o.exclusions is null or c_o.extras is null then 1 else 0
  end) as 'No Change'
  from runner_orders r_o join customer_orders c_o on
  r_o.order_id = c_o.order_id where r_o.cancellation is null group by 1;
  
 # Q8. How many pizzas were delivered that had both exclusions and extras?
 
 select c_o.customer_id, count(c_o.pizza_id) as no_of_pizza,
  sum(case when c_o.exclusions >= 1 and c_o.extras >= 1 then 1 else 0 
  end) as 'Both Exclusion and Extras'
  from runner_orders r_o join customer_orders c_o on
  r_o.order_id = c_o.order_id where r_o.cancellation is null group by 1;
  
  # Q9. What was the total volume of pizzas ordered for each hour of day?
  
  select count(pizza_id) as no_of_pizza, hour(order_time) as hours from customer_orders group by 2;
  
  # Q10. What was the volume of orders for each day of the week?
  
  select count(pizza_id) as no_of_pizza, dayname(order_time) as day_name from customer_orders group by 2;
  
  # Q11. What was the average time in minutes it took for each runner to arrive at the pizza runner HQ to pickup the order?
  
  SELECT r_o.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE, c_o.order_time, r_o.pickup_time)) AS minute_taken
FROM runner_orders r_o join customer_orders c_o on r_o.order_id = c_o.order_id
WHERE c_o.order_time IS NOT NULL AND r_o.pickup_time IS NOT NULL
GROUP BY r_o.runner_id;

  # Q12. What was the average distance travelled for each customer?
  
  SELECT
    co.customer_id,
    round(AVG(ro.distance),2)
    AS avg_distance_travelled
FROM
    customer_orders co JOIN runner_orders ro 
    ON co.order_id = ro.order_id
GROUP BY co.customer_id;
  
# Q13. What was the difference between largest and shortest delivery times for all order? 
 
SELECT 
    MAX(duration) - MIN(duration) AS time_difference
FROM runner_orders where distance IS NOT NULL;

# Q14. What was the average speed for each runner for each delivery?

SELECT
    runner_id,
    sum(distance) as km,
    round(avg((distance/duration)*60),2) as avg_speed_per_hr
FROM runner_orders 
WHERE distance is not null 
group by runner_id;

# Q15. What is the successfull delivery % for each runner?

WITH delivery_counts AS (
    SELECT
        runner_id,
        COUNT(*) AS total_deliveries,
        SUM(CASE WHEN cancellation is null THEN 1 ELSE 0 END) AS successful_deliveries
    FROM runner_orders
    GROUP BY runner_id
)
SELECT
    runner_id,
    total_deliveries,
    successful_deliveries,
    CASE WHEN total_deliveries > 0 THEN
            (successful_deliveries / total_deliveries) * 100
        ELSE 0
    END AS success_perc
FROM delivery_counts ORDER BY runner_id;



   





  
  
  
  