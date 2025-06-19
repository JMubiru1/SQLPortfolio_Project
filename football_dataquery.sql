-- Data Exploration for European nations
-- Table 1 (all time ranking for European nations)
select*
from sports.alltimerankingbycountry;
 -- need to rename the first column to ranks 
alter table sports.alltimerankingbycountry
change MyUnknownColumn FIFA_Rank int;

alter table sports.alltimerankingbycountry
change FIFA_Rank Nation_Rank int;

select*
from sports.alltimerankingbycountry;

-- Table 2 goals stats in Euro competitions
select*
from sports.goalstatspergroupround;

alter table sports.goalstatspergroupround
drop column MyUnknownColumn;

-- Table 3 coaches stats at club level
select*
from sports.coachesappeardetails;
 -- delete the first column named "MyUnknownColumn"as it doesnt make any sense in the data set
alter table sports.coachesappeardetails
drop column MyUnknownColumn;

select*
from sports.coachesappeardetails;

-- table 4 - UCL top scorers stats
select*
from sports.topgoalscorer;

alter table sports.topgoalscorer
drop column MyUnknownColumn;

-- data cleaning and renaming tables where necessary
-- 1) looking if any duplicates

select count(Country) - count(distinct Country) as duplicates
from sports.alltimerankingbycountry;
 -- no duplicates in table with all time ranks of European countries
 
select count(Season) - count(distinct Season) as duplicates
from sports.goalstatspergroupround;
-- no duplicates in table with all goal stats in Euros
alter table goalstatspergroupround
rename to Euros_goalstatspergroupround;

select Coach, Club, count(*) as count
from sports.coachesappeardetails
group by Coach, Club
having count > 1;
-- no duplicates in this table either

select count(*) - count(distinct Year) as duplicates
from sports.topgoalscorer;
select Year, count(*) as count
from sports.topgoalscorer
group by Year
having count > 1;
-- shows there are like 5 duplicates so we have to explore them basing on Year and goal 
select Year, Goals, count(*) as count
from sports.topgoalscorer
group by Year, Goals
having count > 1;  -- the years 1998/99, 1999/00 and 2014/15 have counts > 1 so we explore those

select *
from sports.topgoalscorer
where Year like "1998/99" or Year like"1999/00" or Year like"2014/15";

-- these are not duplicates, they are just seasons when more than one player tie on the golden boot
-- however I will first clean the improper entry on Neymar in 2014/15 

update sports.topgoalscorer
set Goals = " 10 goals", Appearances = "12 appearances", Club = "FC Barcelona"
where Player like "%Neymar%" and Year like "%2014/15%";

-- Missing data 
select
sum(case when coach is null then 1 else 0 end) as missing_coach,
sum(case when club is null then 1 else 0 end) as missing_club,
sum(case when Appearance is null then 1 else 0 end) as missing_appearances
from sports.coachesappeardetails;

select
sum(case when Year is null then 1 else 0 end) as missing_year,
sum(case when Player is null then 1 else 0 end) as missing_Player,
sum(case when Club is null then 1 else 0 end) as missing_club,
sum(case when Goals is null then 1 else 0 end) as missing_Goals,
sum(case when Appearances is null then 1 else 0 end) as missing_appearances
from sports.topgoalscorer;

-- no missing data in the two tables of top scorers and coaches stats. 

-- Formating data types on table of goal scorers
select *
from sports.topgoalscorer; 

select cast(REGEXP_SUBSTR(Goals, '[0-9]+') as unsigned) as Goals_integer, Goals
from sports.topgoalscorer; 

alter table sports.topgoalscorer
add column Goal_integer int;

alter table sports.topgoalscorer
add column appearance_integer int;

select *
from sports.topgoalscorer;

update sports.topgoalscorer
set Goal_integer = cast(REGEXP_SUBSTR(Goals, '[0-9]+') as unsigned);

update sports.topgoalscorer
set appearance_integer = cast(REGEXP_SUBSTR(Appearances, '[0-9]+') as unsigned);

-- Descriptive statistics
-- 1. All time ranking by countries
select *
from sports.alltimerankingbycountry;
-- a) Total number of countries
select count(distinct Country) as Total_count_of_countries
from sports.alltimerankingbycountry;

-- b) Top 5 countries with most games played, wins, draws, losses

select Country, Played as Total_games_played
from sports.alltimerankingbycountry
Order by Played desc limit 5;

select Country, Win as Total_number_of_wins
from sports.alltimerankingbycountry
Order by Win desc limit 5;

select Country, Draw as Total_number_of_draws
from sports.alltimerankingbycountry
Order by Draw desc limit 5;

select Country, Loss as Total_number_of_Loses
from sports.alltimerankingbycountry
Order by Loss desc limit 5;

-- c)Teams which have had less than the overall mean games played, wins, points

select round(avg(Played), 0) as average_games_played,
round(avg(Win), 0) as average_Wins,
round(avg(Pts), 0) as average_number_of_points
from sports.alltimerankingbycountry;

select Country, Win
from sports.alltimerankingbycountry
where Win  < (select round(avg(Win), 0)
from sports.alltimerankingbycountry
)
order by Win asc;

select Country, Played
from sports.alltimerankingbycountry
where Played < 289
order by played asc;

select Country, Pts
from sports.alltimerankingbycountry
where Win  < (select round(avg(Pts), 0)
from sports.alltimerankingbycountry
)
order by Pts asc;

-- 2. All times coaches statistics
select *
from sports.coachesappeardetails
;
-- a) summary statistitics
select sum(Appearance) as Total_appearances,
round(avg(Appearance), 0) as average_appearances,
count(distinct Coach) as number_of_managers,
count(distinct Club) as number_of_clubs
from sports.coachesappeardetails
;

-- b) Top apperances managers and then those that have managed more than one club
select Coach, count(distinct Club) as teams_coached
from sports.coachesappeardetails
group by Coach
order by teams_coached desc;

select Coach, count(distinct Club) as teams_coached
from sports.coachesappeardetails
group by Coach
having teams_coached > 1
order by teams_coached desc;

-- finding all the teams managed by the manager who has managed the most number of distinct teams
select Coach, count(distinct Club) as teams_coached
from sports.coachesappeardetails
group by Coach
order by teams_coached desc limit 1
;

select Club, Appearance as total_games_managed
from sports.coachesappeardetails
where Coach like "%Ancelotti%"
order by total_games_managed desc;

-- b) Managers with most games managed
select Coach, sum(Appearance) as total_games_managed
from sports.coachesappeardetails
group by Coach
order by total_games_managed desc limit 5;

-- Top goal scorer stats

-- Finding average goals and appearance
-- a) overall ranks by goals, overall averages of goals and averages
select *
from sports.topgoalscorer;

create view Top_scorer_clean as
select Year, Player, Club, Goal_integer, Appearance_integer
from sports.topgoalscorer
order by Goal_integer desc;

select *
from sports.top_scorer_clean;

select Player, count(Player) as Number_topscorer_awards
from sports.top_scorer_clean
group by Player
order by count(Player) desc;

select round(avg(Goal_integer), 0), round(avg(Appearance_integer), 0)
from sports.top_scorer_clean;

-- b) average goals and apearances within 10 year groups (1990-1999, 2000-2009, 2010-2019, 2020-)

select round(avg(Goal_integer), 0) as avg_goals_in_90s, 
round(avg(Appearance_integer), 0) as avg_appearance_in_90s
from sports.top_scorer_clean
where Year like "199%";

select round(avg(Goal_integer), 0) as avg_goals_in_early2000s, 
round(avg(Appearance_integer), 0) as avg_appearance_in_early2000s
from sports.top_scorer_clean
where Year like "200%";

select round(avg(Goal_integer), 0) as avg_goals_in_2010s, 
round(avg(Appearance_integer), 0) as avg_appearance_in_2010s
from sports.top_scorer_clean
where Year like "201%";

select round(avg(Goal_integer), 0) as avg_goals_in_2020s, 
round(avg(Appearance_integer), 0) as avg_appearance_in_2020s
from sports.top_scorer_clean
where Year like "202%";



