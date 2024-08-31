select * from athlete_events limit 10;

select * from noc_regions;

-- 1. How many olympics games have been held?

select count(distinct games) as total_games from athlete_events;

-- 2. List down all Olympics games held so far.

select distinct games from athlete_events;

-- 3. Mention the total no of nations who participated in each olympics game?


with cte as
	(
select games, nr.region 
from athlete_events ae
join noc_regions nr using(noc)
	)
select games, count(distinct region) as total_country
from cte
group by games
order by games;


-- 4. Which year saw the highest and lowest no of countries participating in olympics?
select * from athlete_events limit 5;


      with all_countries as
              (select games, nr.region
              from athlete_events oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;



-- 5. Which nation has participated in all of the olympic games
with tot_games as
	  (select count(distinct games) as total_games
	  from athlete_events),
  countries as
	  (select games, nr.region as country
	  from athlete_events oh
	  join noc_regions nr using(noc)
	  group by games, nr.region),
  countries_participated as
	  (select country, count(1) as total_participated_games
	  from countries
	  group by country)
select cp.*
from countries_participated cp
join tot_games tg on tg.total_games = cp.total_participated_games
order by 1;

-- 6. Identify the sport which was played in all summer olympics.

with tot_summer_games as
	(select count(distinct games) as total_games
	from athlete_events 
	where games like '%Summer%'),
	t2 as(
	select distinct games, sport
          	from athlete_events where season = 'Summer'
	),
	t3 as (
	select sport, count(sport) as no_of_sports from t2
	group by sport)
	select * from t3
join tot_summer_games tg on t3.no_of_sports = tg.total_games


-- 7. Which Sports were just played only once in the olympics.
with t1 as (select distinct games, sport
          	from athlete_events
	),
	t2 as(
	select sport,
	count(sport) as no_of_sports from t1
	group by sport
	having count(sport) = 1
	)
	select * from t2 
	join t1 using(sport)
	order by sport


-- 8. Fetch the total no of sports played in each olympic games.
with t1 as 
	(
	select distinct games, sport 
	from athlete_events),
	t2 as 
	(
	select games, count(sport) as total
	from t1
	group by games
	)
	select * from t2
	order by total desc, games

-- 9. Fetch oldest athletes to win a gold medal

select * from athlete_events where medal='Gold' and age <> 'NA'
order by age desc
limit 2;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.

with t1 as
	(
	select sex, games from athlete_events
	),
	t2 as
	(
select sex, count(games) as total from t1
group by sex),
	t3 as
	(
select total as total_M from t2 where sex='M'),
	t4 as (
select total as total_F from t2 where sex='F')
	select concat('1:', round(t3.total_M::decimal/t4.total_F, 2)) as ratio
	from t3, t4;
	
-- 11. Fetch the top 5 athletes who have won the most gold medals.

with t1 as
(
select name, team, count(medal) as total_gold
from athlete_events where medal='Gold'
group by name, team),
t2 as(	
select *, 
dense_rank() over(order by total_gold desc) as rnk
	from t1)
select name, team, total_gold from t2 where rnk <=5


-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as
(
select name, team, count(medal) as total_gold
from athlete_events where medal in ('Gold', 'Silver', 'Bronze')
group by name, team),
t2 as(	
select *, 
dense_rank() over(order by total_gold desc) as rnk
	from t1)
select name, team, total_gold from t2 where rnk <=5


-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.


with t1 as
	(
	select region, medal 
	from athlete_events ae
	join noc_regions nr using(noc)
	),
t2 as
	(
	select region, count(medal) as total_gold
	from t1 where medal in ('Gold', 'Silver', 'Bronze')
	group by region
	),
t3 as
	(
select *, 
dense_rank() over(order by total_gold desc) as rnk
	from t2
	)
	select region
	, total_gold, rnk from t3 where rnk <=5


-- 14. List down total gold, silver and bronze medals won by each country.

with t1 as
	(
	select region, medal 
	from athlete_events ae
	join noc_regions nr using(noc)
	),
t2 as
	(
	select region, medal, count(medal) as total_gold
	from t1 where medal in ('Gold', 'Silver', 'Bronze')
	group by region, medal
	)
select * from t2

CREATE EXTENSION tablefunc;

SELECT region
	, coalesce(gold, 0) as gold
    , coalesce(silver, 0) as silver
    , coalesce(bronze, 0) as bronze
FROM CROSSTAB(
$$
	with t1 as
	(
	select region, medal 
	from athlete_events ae
	join noc_regions nr using(noc)
	),
t2 as
	(
	select region, medal, count(medal) as total_gold
	from t1 where medal in ('Gold', 'Silver', 'Bronze')
	group by region, medal
	)
select * from t2 order by region, medal $$,
    $$
      VALUES
        ('Gold'),
        ('Silver'),
	    ('Bronze')
    $$
  ) AS (
    region varchar,
    Gold  INT,
    Silver  INT,
	Bronze  INT
  )
  order by gold desc, silver desc, bronze desc;


-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.


-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.


-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

-- 18. Which countries have never won gold medal but have won silver/bronze medals?


-- 19. In which Sport/event, India has won highest medals.
with t1 as
	(
select sport, medal from athlete_events where team = 'India' and medal <> 'NA'
	)
select sport, count(medal) as total_medal
	from t1
group by sport
order by count(medal) desc
limit 1


-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

    select team, sport, games, count(1) as total_medals
    from athlete_events
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;




