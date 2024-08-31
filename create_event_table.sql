
-- DROP TABLE IF EXISTS public.athlete_events;
drop table if exists athlete_events;

CREATE TABLE IF NOT EXISTS athlete_events
(
    id int,
    name varchar,
    sex varchar,
    age varchar,
    height varchar,
    weight varchar,
    team varchar,
    noc varchar,
    games varchar,
    year int,
    season varchar,
    city varchar,
    sport varchar,
    event varchar,
    medal varchar
);

select * from athlete_events;