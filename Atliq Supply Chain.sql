#Number of Customer from City
SELECT city, count(*) as no_of_customer from dim_customers
group by city;

#What are the minimum and maximum order quantities for each product?
select p.product_id,p.product_name,min(order_qty) as min,max(order_qty) as max from fact_order_lines f
join dim_products p on p.product_id=f.product_id
group by p.product_id,p.product_name;

#Unfullfilled Qty for each month
select monthname(order_placement_date) as month,sum(order_qty-delivery_qty) as unfullfilled_qty from fact_order_lines
group by month;

# Unfullfilled qty for each customer
select product_name,sum(order_qty-delivery_qty) as unfullfilled_qty from fact_order_lines f
join dim_products p on p.product_id=f.product_id
group by product_name
order by unfullfilled_qty desc;

#What is the percentage breakdown of order_qty by category?
select p.category,sum(order_qty)as total_qty,round(sum(order_qty)/sum(sum(order_qty)) over()*100,2) as pct from fact_order_lines f
join dim_products p
on p.product_id=f.product_id
group by p.category;

#Generate a report that lists all the product categories, along with the product names and total count of products in each category.
select category,count(*) as nO_of_product,group_concat(product_name) as products from dim_products
group by category;


# Each customer target and real IF%,ot%,otif%
SELECT
    c.customer_name,avg(ontime_target_pct),
    ROUND((SUM(f.on_time) / COUNT(f.order_id) * 100), 2) AS OT_percentage,
	avg(infull_target_pct),
    ROUND((SUM(f.in_full) / COUNT(f.order_id) * 100), 2) AS IF_percentage,
    avg(otif_target_pct),
    ROUND((SUM(f.otif) / COUNT(f.order_id) * 100), 2) AS OTIF_percentage
FROM
    gdb080.fact_orders_aggregate f
JOIN
    dim_targets_orders t ON t.customer_id = f.customer_id
join
	dim_customers c on c.customer_id=f.customer_id

GROUP BY
    c.customer_name;

# Each city target and real IF%,ot%,otif%
SELECT
    c.city,avg(ontime_target_pct) as target_ontime,
    ROUND((SUM(f.on_time) / COUNT(f.order_id) * 100), 2) AS OT_percentage,
	avg(infull_target_pct) as target_in_full,
    ROUND((SUM(f.in_full) / COUNT(f.order_id) * 100), 2) AS IF_percentage,
    avg(otif_target_pct) as target_OTIF,
    ROUND((SUM(f.otif) / COUNT(f.order_id) * 100), 2) AS OTIF_percentage
FROM
    gdb080.fact_orders_aggregate f
JOIN
    dim_targets_orders t ON t.customer_id = f.customer_id
join
	dim_customers c on c.customer_id=f.customer_id

GROUP BY
    c.city;
#LFR and VFR for each customer    
with cte1 as 
(SELECT order_id,customer_id, round(sum(In_Full)/count(order_id),2) as LFR, 
round(sum(delivery_qty)/sum(order_qty),2) as VFR   
FROM gdb080.fact_order_lines  
group by order_id,customer_id)
  select c.customer_name,round(avg(LFR)*100,2) as LFR ,
  round(avg(VFR)*100,2) as VFR
  from cte1  t
  join dim_customers c on c.customer_id=t.customer_id 
  group by 1
  order by LFR desc, VFR desc;
#LFR and VFR for each product
with cte1 as 
(SELECT order_id,product_id, round(sum(In_Full)/count(order_id),2) as LFR, 
round(sum(delivery_qty)/sum(order_qty),2) as VFR   
FROM gdb080.fact_order_lines  
group by order_id,product_id)
  select d.product_id,product_name,round(avg(LFR)*100,2) as LFR ,
  round(avg(VFR)*100,2) as VFR
  from cte1  c
  join dim_products d on d.product_id=c.product_id
  group by 1,2;
# monthly trend of LFR VFR
with cte1 as(SELECT order_id,mmm_yy,round(sum(In_Full)/count(order_id),2) as LFR,
round(sum(delivery_qty)/sum(order_qty),2) as VFR FROM fact_order_lines f
join dim_dates d
on d.date=f.order_placement_date
group by order_id,mmm_yy)
select mmm_yy ,round(avg(LFR)*100,2) as LFR ,round(avg(VFR)*100,2) as VFR from cte1 
group by mmm_yy;
# ot%,if% anfotif% for every month
SELECT mmm_yy,
    ROUND((SUM(f.on_time) / COUNT(f.order_id) * 100), 2) AS OT_percentage,
	ROUND((SUM(f.on_time) / COUNT(f.order_id) * 100), 2) AS OT_percentage,
    ROUND((SUM(f.in_full) / COUNT(f.order_id) * 100), 2) AS IF_percentage,

    ROUND((SUM(f.otif) / COUNT(f.order_id) * 100), 2) AS OTIF_percentage FROM gdb080.fact_orders_aggregate f
join dim_dates d on d.date=f.order_placement_date
group by mmm_yy;
#total qty for each product
select p.product_name,round(sum(order_qty)/1000000,2) qty_ml from fact_order_lines f
join dim_products p
on p.product_id=f.product_id

group by product_name
order by 2 desc;
