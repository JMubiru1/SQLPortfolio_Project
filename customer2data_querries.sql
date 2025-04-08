-- after importing data (data set attached in github)
select *
from customer_data_exploration.customer2data;

select count(*) 
from customer_data_exploration.customer2data;

select 
count(distinct Loyalty_no)
from customer_data_exploration.customer2data;


-- data cleaning (duplicates, missing data, format, outliers, null values)

-- 1. Duplicate
select count(*) - count(distinct Loyalty_no) as duplicate_count
from customer_data_exploration.customer2data;
-- there are 9 duplicates

select loyalty_no, count(Loyalty_no) as duplicate_entries
from customer_data_exploration.customer2data
group by loyalty_no
having count(Loyalty_no) > 1;

with ranked_entries as (
    select *,
           row_number() over (partition by Loyalty_no order by Loyalty_no) as row_num
    from customer_data_exploration.customer2data
    where Loyalty_no in (202299, 826271, 616030, 747903, 870394, 326810, 101958, 131469, 106190)
)
delete from customer_data_exploration.customer2data
where Loyalty_no in (
    select Loyalty_no
    from ranked_entries
    where row_num > 1
);

-- 2. Formats outliersm on categorical variables (intentionaly placed some wrong genders)
select distinct Loyalty_no 
from customer_data_exploration.customer2data;

select distinct Country 
from customer_data_exploration.customer2data;

select distinct Education 
from customer_data_exploration.customer2data;

select distinct Gender 
from customer_data_exploration.customer2data;

update customer_data_exploration.customer2data
set Gender = 'male'
where Gender = 'males';

update customer_data_exploration.customer2data
set Gender = 'male'
where Gender = 'M';

update customer_data_exploration.customer2data
set Gender = 'female'
where Gender in ('F' , 'Girl');

-- 3. Missing data
 select 
  count(*) as total_rows,
  sum(case when Gender is null then 1 else 0 end) as missing_gender,
  sum(case when Education is null then 1 else 0 end) AS missing_education,
  sum(case when Location_Code is null then 1 else 0 end) AS missing_location,
  sum(case when Income is null then 1 else 0 end) as missing_income,
  sum(case when Marital_Status is null then 1 else 0 end) AS missing_mariatalstatus,
  sum(case when Order_Year is null then 1 else 0 end) AS missing_orderyear,
  sum(case when LoyaltyStatus is null then 1 else 0 end) as missing_loyalty,
  sum(case when MonthsAsMember is null then 1 else 0 end) AS missing_membermonths,
  sum(case when Product_Line is null then 1 else 0 end) AS missing_pdtline,
  sum(case when Quantity_Sold is null then 1 else 0 end) as missing_qtsold,
  sum(case when Unit_Sale_Price is null then 1 else 0 end) AS missing_unitprice,
  sum(case when Unit_Cost is null then 1 else 0 end) AS missing_unitcost,
  sum(case when Revenue is null then 1 else 0 end) AS missing_Revenue   
from customer_data_exploration.customer2data;

