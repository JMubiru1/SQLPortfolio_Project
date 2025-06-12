-- Exploring the data
select *
from parks_and_recreation.employee_demographics d;
select *
from parks_and_recreation.employee_salary s;
select *
from parks_and_recreation.parks_departments p;

-- cleaning (duplicates, missing, outliers)
select (count(*) - count(distinct employee_id)) as duplicate_count
from parks_and_recreation.employee_demographics;

select employee_id, count(employee_id) as duplicate_entries
from parks_and_recreation.employee_demographics
group by employee_id
having count(employee_id) > 1;


select 
sum(case when age is null then 1 else 0 end) as missinge_age,
sum(case when gender is null then 1 else 0 end) as missinge_gender
from parks_and_recreation.employee_demographics;

-- join tables and create views for the combined tables
create view combined_tables as
select d.*, s.occupation, s.salary, s.dept_id
from parks_and_recreation.employee_demographics d
join parks_and_recreation.employee_salary s
on d.employee_id = s.employee_id
;

-- combined table with the department data
create view overall_table as
select c.*, a.department_name
from parks_and_recreation.parks_departments a
join parks_and_recreation.combined_tables c
on a.department_id = c.dept_id
;

select *
from parks_and_recreation.overall_table;

-- create a new view classifying salary into high, mid level and high level earners
create view salary_categories as
select *,
case when salary > 50000 then "High earner"
	when salary > 45000 and salary <= 50000 then "Mid level earner"
    when salary <= 45000 then "Low earner"
    end as "salary_category"
from parks_and_recreation.overall_table;

-- explore which positions earn more
select*
from parks_and_recreation.salary_categories;

select distinct occupation, round(avg(salary), 0) as average_salary
from parks_and_recreation.salary_categories
group by occupation
order by avg(salary) desc;

-- explore which departments spend more on salary
select sum(salary) as Total_salary
from parks_and_recreation.salary_categories;

select distinct department_name, round(sum(salary), 0) as Total_salary,
round((((sum(salary))/ 597000) * 100), 0) as percentage
from parks_and_recreation.salary_categories
group by department_name
order by sum(salary) desc;
-- parks and creations department spends the most
-- exploring how many categories of earners are in parks and creation
select distinct salary_category,   count(distinct salary_category)
from parks_and_recreation.salary_categories
where department_name like "Parks and Recreation"
group by salary_category
order by count(distinct salary_category) desc
;

-- summarising all the high earners who are males and females separately
select first_name, last_name, age, occupation, department_name, salary
from parks_and_recreation.salary_categories
where employee_id in(
	select employee_id
	from parks_and_recreation.salary_categories
	where gender like "Male" and salary_category like "High earner")
order by salary desc;

select first_name, last_name, age, occupation, department_name, salary
from parks_and_recreation.salary_categories
where employee_id in(
	select employee_id
	from parks_and_recreation.salary_categories
	where gender like "Female" and salary_category like "High earner")
order by salary desc;

-- Finally rank the top 5 earning jobs
select occupation, department_name, salary
from parks_and_recreation.salary_categories
order by salary desc limit 5;