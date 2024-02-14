select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;

-- Base price greater than 500 and "BOGOF"
select product_code,promo_type,base_price
from fact_events 
where base_price >=500 and promo_type="BOGOF" 
group by product_code
order by product_code;

-- Store distribution by city
select s.city,count(f.store_id) as store_count from fact_events f 
right join dim_stores s 
on f.store_id=s.store_id
group by s.city;

-- total revenue by diffrent campaigns
select * from fact_events;
select campaign_id,
sum(revenue_beforepromo)/1000000 beforepromo_in_millions,
sum(revenue_after_promo)/1000000 as afterprom_in_millions
from fact_events
group by campaign_id
order by 2,3 desc ;

-- ISU% for each category
select * from fact_events;
with ISU_cte as (
select pr.category,sum(f.ISU)/sum(f.quantity_sold_beforepromo)*10 as percent
from fact_events f
join dim_products pr
on f.product_code=pr.product_code
where f.campaign_id='CAMP_DIW_01'
group by pr.category
) 
select category,round(percent,2),RANK() OVER (ORDER BY percent DESC) AS categoryrank
from ISU_cte
order by categoryrank ;

-- top 5 products on incremental revenue

with IR_cte as (
select pr.product_name,pr.category,sum(f.IR)/sum(f.revenue_beforepromo)*10 as percent
from fact_events f
join dim_products pr
on f.product_code=pr.product_code
group by pr.product_name,pr.category
)
select * from(
select product_name,category
,percent,RANK() OVER (ORDER BY percent DESC) AS categoryrank
from IR_cte
group by product_name,category
order by categoryrank 
)as ranked_data
where categoryrank<=5


