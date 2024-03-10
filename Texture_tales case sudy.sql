select * from sales
select * from product_details
select * from product_hierarchy
select * from product_prices

## 1. What was the total quantity sold for all products? 
select pd.product_name, sum(qty) as total_qty_sold from product_details pd join sales s
on pd.product_id = s.prod_id
group by pd.product_name
order by total_qty_sold desc

## 2. What is the total generated revenue per product before discounts? 
select pd.product_name, sum(s.qty*s.price) as total_revenue_before_discount from 
product_details pd join sales s
on pd.product_id = s.prod_id
group by pd.product_name
order by total_revenue_before_discount

## 3. What was the total discount amount for all products? 
select sum(discount*qty) as total_discount from sales

## 4. How many unique transactions were there? 
select count(distinct txn_id) as unique_txn_count from sales

## 5. What are the average unique products purchased in each transaction? 
with cte as 
(select txn_id, count(distinct prod_id) as unique_prod_count from sales 
group by txn_id)
select txn_id, round(avg(unique_prod_count),2) as average_unique_products 
from cte group by txn_id order by average_unique_products

## 6. What is the average discount value per transaction? 
with cte as 
(select txn_id, sum(qty*discount) as total_discount from sales group by txn_id)
select txn_id, round(avg(total_discount),2) as avg_discount from cte group by txn_id

## 7. What is the average revenue for member transactions and non-member transactions? 
with cte as
(select member, txn_id, sum(price * qty) as total_rev from sales group by member,txn_id)
select member, round(avg(total_rev),2) as avg_rev from cte group by member

## 8. What are the top 3 products by total revenue before discount? 
select pd.product_name, sum(s.qty * s.price) as total_rev from product_details pd join sales s
on pd.product_id = s.prod_id group by pd.product_name order by total_rev desc limit 3

## 9. What are the total quantity, revenue and discount for each segment? 
select pd.segment_id, pd.segment_name, sum(s.qty) as total_qty, sum(s.qty * s.price) as total_rev,
round(sum(s.qty * s.price * s.discount)/100,2) as total_discount
from product_details pd join sales s on pd.product_id = s.prod_id
group by pd.segment_id, pd.segment_name

## 10. What is the top selling product for each segment? 
with cte as
(select pd.segment_id, pd.segment_name, pd.product_name, sum(s.qty) as qty_count,
dense_rank() over(partition by pd.segment_name order by sum(s.qty) desc) as segment_rank
from product_details pd join sales s on pd.product_id = s.prod_id
group by pd.segment_id, pd.segment_name, pd.product_name)
select segment_id, segment_name, product_name, qty_count from cte where segment_rank = 1
group by segment_id, segment_name, product_name, qty_count

## 11. What are the total quantity, revenue and discount for each category? 
select pd.category_name, sum(s.qty) as total_qty, sum(s.qty * s.price) as total_rev
from product_details pd join sales s on pd.product_id= s.prod_id
group by pd.category_name

## 12. What is the top selling product for each category?
with cte as(select pd.category_name, pd.product_name, sum(s.qty) as total_qty, 
dense_rank() over(partition by pd.category_name order by sum(s.qty) desc) as cat_rank
from product_details pd join sales s on pd.product_id = s.prod_id
group by pd.category_name, pd.product_name)

select category_name, product_name, total_qty from cte where cat_rank = 1
group by category_name, product_name, total_qty