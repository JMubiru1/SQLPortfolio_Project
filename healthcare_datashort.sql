-- import data sets (hospital data and patient demographic data)
-- checking that the data is imported as needed
select *
from portfolio_project.healthcare_hospitaldatashort;
select *
from portfolio_project.healthcare_ptdemographicsdatashort;

-- exploring total of each condition and genders statistics

select 
Medical_Condition,
count(Medical_Condition) as Total_cases
from portfolio_project.healthcare_ptdemographicsdatashort
group by Medical_Condition;

-- we have Cancer, Obesity, Diabetes, Asthma, Hypertension, Arthritis

select 
Gender,
count(Gender) as Total_gender
from portfolio_project.healthcare_ptdemographicsdatashort
group by Gender;

select 
Gender,
(count(Gender)/99)*100 as Total_gender
from portfolio_project.healthcare_ptdemographicsdatashort
group by Gender;

-- Explore total cases by gender

select 
Medical_Condition,
count(Medical_Condition) as Total_cases,
(count(Medical_Condition)/99)*100 as percentage
from portfolio_project.healthcare_ptdemographicsdatashort
group by Medical_Condition
order by percentage desc;

select 
Gender,
Medical_Condition,
count(Medical_Condition) as Total_cases,
(count(Medical_Condition)/99)*100 as percentage
from portfolio_project.healthcare_ptdemographicsdatashort
group by Gender, Medical_Condition
order by percentage desc;

select 
Gender,
count(Gender) as Total_obesity
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Obesity%'
group by Gender;

select 
Gender,
count(Gender) as Total_cancer
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Cancer%'
group by Gender;

select 
Gender,
count(Gender) as Total_Arthritis
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Arthritis%'
group by Gender;

select 
Gender,
count(Gender) as Total_Diabetes
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Diabetes%'
group by Gender;

select 
Gender,
count(Gender) as Total_asthma
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Asthma%'
group by Gender;

select 
Gender,
count(Gender) as Total_HTN
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Hypertension%'
group by Gender;

select 
Gender,
count(Gender) as Total_HTN,
(count(Gender)/20) as percentage
from portfolio_project.healthcare_ptdemographicsdatashort
where Medical_Condition like '%Hypertension'
group by Gender;

-- exploring hospital date; admitting docctors, hospital admission numbers, insurance providers, admission type, billing sums
select Doctor,
Hospital,
Insurance_Provider,
Billing_Amount,
Admission_Type
from portfolio_project.healthcare_hospitaldatashort;

select count(distinct Insurance_Provider)
from portfolio_project.healthcare_hospitaldatashort;

select count(distinct Doctor)
from portfolio_project.healthcare_hospitaldatashort;

select count(distinct Hospital)
from portfolio_project.healthcare_hospitaldatashort;

select count(distinct Admission_Type)
from portfolio_project.healthcare_hospitaldatashort;

select Insurance_Provider,
count(Insurance_Provider) as total_clients,
(count(Insurance_Provider)/99)*100 as percentage
from portfolio_project.healthcare_hospitaldatashort
group by Insurance_Provider
order by percentage desc;

select Admission_Type,
count(Admission_Type) as total_clients,
(count(Admission_Type)/99)*100 as percentage
from portfolio_project.healthcare_hospitaldatashort
group by Admission_Type
order by percentage desc;

select
sum(Billing_Amount), min(Billing_Amount), max(Billing_Amount), avg(Billing_Amount)
from portfolio_project.healthcare_hospitaldatashort;

select Insurance_Provider,
sum(Billing_Amount), min(Billing_Amount), max(Billing_Amount), avg(Billing_Amount)
from portfolio_project.healthcare_hospitaldatashort
group by Insurance_Provider;

select Insurance_Provider,
sum(Billing_Amount) as total_revenue,
(sum(Billing_Amount)/2492515.95096455)*100 as percentage
from portfolio_project.healthcare_hospitaldatashort
group by Insurance_Provider
order by percentage desc;

-- create a new combined table by joining the two tables together (select ptdemographics and select hospital data)

use portfolio_project;
drop table if exists Combined_healthdata;
create table  Combined_healthdata (
Name nvarchar(100),
Age int,
gender nvarchar (100),
Medical_Condition nvarchar (100),
Admission_Type nvarchar (100),
Blood_Type nvarchar (100),
Medication nvarchar (100),
Date_of_Admission nvarchar (100),
Discharge_Date nvarchar (100),
Insurance_Provider nvarchar (100),
Billing_Amount numeric
);

Insert into Combined_healthdata
select healthcare_hospitaldatashort.Name, healthcare_ptdemographicsdatashort.Age, 
healthcare_ptdemographicsdatashort.gender,
healthcare_ptdemographicsdatashort.Medical_Condition,
healthcare_hospitaldatashort.Admission_Type,
healthcare_ptdemographicsdatashort.Blood_Type,
healthcare_hospitaldatashort.Medication,
healthcare_hospitaldatashort.Date_of_Admission, 
healthcare_hospitaldatashort.Discharge_Date,
healthcare_hospitaldatashort.Insurance_Provider,
healthcare_hospitaldatashort.Billing_Amount 
from portfolio_project.healthcare_hospitaldatashort
join portfolio_project.healthcare_ptdemographicsdatashort
on healthcare_hospitaldatashort.Name = healthcare_ptdemographicsdatashort.Name
order by Age asc;

select*
from portfolio_project.combined_healthdata;

create view Top_50_expenses as
select*
from portfolio_project.combined_healthdata
order by Billing_Amount desc
limit 50
;

create view Top_25_expenses as
select*
from portfolio_project.combined_healthdata
order by Billing_Amount desc
limit 25
;

create view all_expenses as
select*
from portfolio_project.combined_healthdata
order by Billing_Amount desc
;

-- export my combined table as csv 
select*
from portfolio_project.combined_healthdata
;