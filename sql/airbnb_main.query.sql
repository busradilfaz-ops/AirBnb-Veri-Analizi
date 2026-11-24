SELECT 
'id' as column_name,
count(*) as nb_null
 FROM `data-analytics-469406.airbnb.listing` 
 where id is null

 union all

SELECT
 'room_type' as column_name,
 count(*) as nb_null
  FROM `data-analytics-469406.airbnb.listing` 
 where room_type is null

 union all

 select
 'host_response_time' as column_name,
 count(*) as nb_null
 FROM `data-analytics-469406.airbnb.listing` 
 where host_response_time is null

 union all

 select 'review_scores_value' as column_name,
 count(*) as nb_null
 FROM `data-analytics-469406.airbnb.listing` 
 where review_scores_value is null; -- null değer yok

-- Dublicate sorgusu
 select
 id,
 count(*) as nb_dublicate
 from`data-analytics-469406`.airbnb.listing
 group by id
 having nb_dublicate > 1;

 /** Calender Null sorgusu**/

 SELECT 
  'listing_id' as column_name,
  count(*) as nb_nulls
  from `adroit-cortex-511517-b2`.airbnb.calendar
  where listing_id is null

  union all

  select 
  'date' as column_name,
  count(*) as nb_nulls
  from `adroit-cortex-511517-b2`.airbnb.calendar
  where date is null

  union all

  select 
  'available' as column_name,
  count(*) as nb_nulls
  from `adroit-cortex-511517-b2`.airbnb.calendar
  where available is null

  union all

  select 
  'price' as column_name,
  count(*) as nb_nulls
  from `adroit-cortex-511517-b2`.airbnb.calendar
  where price is null; -- null değer yok

  -- benzersizlik sorgusu

  select 
  listing_id,date,
  count(*) as nb_dublicate
  from `adroit-cortex-511517-b2`.airbnb.calendar
  group by listing_id,date
  having nb_dublicate > 1;

 create or replace table  `adroit-cortex-511517-b2`.airbnb.joined_dataset as
 with join_tables as (
  select
  ca.listing_id,
  ca.date as date_date,
  ca.available,
  ca.price,
  li.room_type,
  li.host_response_time,
  li.review_scores_value
  from `adroit-cortex-511517-b2`.airbnb.calendar as ca
  join `data-analytics-469406`.airbnb.listing as li
  on ca.listing_id = li.id
 )
 
 select * from join_tables;

 -- LISTING PERFORMANS TABLOSU

create or replace table  `adroit-cortex-511517-b2`.airbnb.listing_performance as
with base as (select
listing_id,room_type, host_response_time, review_scores_value, date_date,
(available = false) as is_booked,
price
from `adroit-cortex-511517-b2`.airbnb.joined_dataset
),
agg as( select
listing_id,
any_value(room_type) as room_type,
any_value(host_response_time) as host_response_time,
any_value(review_scores_value) as review_scores_value,
count(*) as total_days,
countif(is_booked) as booked_days,
round(safe_divide(countif(is_booked),count(*)),2) as occupancy_rate,
round(avg(if(is_booked,price,null)),2) as avg_booked_price,
round(sum(if(is_booked,price,null)),2) as est_revenue
from base
group by listing_id
order by review_scores_value desc
)
select*,
ntile(10) over (order by est_revenue desc) as revenue_decile,
case 
  when ntile(10) over ( order by est_revenue desc) = 1 then "Yüksek Performans"
  when ntile(10) over (order by est_revenue desc) <= 5 then "Orta"
  else "Düşük"
end as performance_segment,
case
  when review_scores_value >= 4.8 then "4.8+"
  when review_scores_value >= 4.5 then "4.5-4.8"
  when review_scores_value is not null then "< 4.5"
  else "Puansız"
end as review_band
from agg;

-- DAILY PERFORMANCE TABLOSU

create or replace table `adroit-cortex-511517-b2`.airbnb.daily_performans 
partition by date_date
cluster by performance_segment as
select
j.listing_id,
j.date_date,j.room_type, j.host_response_time, j.review_scores_value,j.price, p.performance_segment, p.review_band,
 if(available=false,1,0) as is_booked
 from `adroit-cortex-511517-b2`.airbnb.joined_dataset as j
 join `adroit-cortex-511517-b2`.airbnb.listing_performance as p 
 using (listing_id)




