-- you can run this locally using psql if you have PostgreSQL installed
-- createdb ff
-- psql ff < 01_load.sql

-- or you can copy/paste into PG Web

drop table if exists players cascade;
drop table if exists teams cascade;
drop table if exists points cascade;
drop table if exists seasons cascade;
drop table if exists positions cascade;

-- lookups
create table teams(
  id serial primary key not null,
  name text not null unique
);

create table positions(
  id integer primary key not null,
  name text not null unique
);

create table seasons(
  id serial primary key,
  year int not null
);

-- players
create table players(
  id serial primary key not null,
  name text not null,
  team_id integer references teams(id),
  position_id integer not null references positions(id)
);

-- the transactional points table
create table points(
  id serial primary key not null,
  player_id int not null references players(id),
  season_id int not null references seasons(id),
  completions int not null default 0,
  attempts int not null default 0,
  passing_yards int not null default 0,
  td_passes int not null default 0,
  intercepted int not null default 0,
  carries int not null default 0,
  receptions int not null default 0,
  rushing_yards int not null default 0,
  receiving_yards int not null default 0,
  rushing_tds int not null default 0,
  receiving_tds int not null default 0,
  sacks int not null default 0,
  interceptions int not null default 0,
  fumbles int not null default 0
);


-- data
insert into seasons(year)
values(2019);

insert into positions(id, name)
values
(1, 'QB'),
(2, 'RB'),
(3, 'WR'),
(4, 'TE'),
(5, 'Def');


insert into teams(name)
select distinct(team) 
from csvs.running_backs 
order by team;

insert into players(name, team_id, position_id)
select name, (
  select id from teams where teams.name = csvs.quarterbacks.team limit 1
), 1
from csvs.quarterbacks;

insert into players(name, team_id, position_id)
select name, (
  select id from teams where teams.name = csvs.running_backs.team limit 1
), 2
from csvs.running_backs;

insert into players(name, team_id, position_id)
select name, (
  select id from teams where teams.name = csvs.wide_receivers.team limit 1
), 3
from csvs.wide_receivers;

insert into players(name, team_id, position_id)
select name, (
  select id from teams where teams.name = csvs.tight_ends.team limit 1
), 4
from csvs.tight_ends;

insert into players(name, team_id, position_id)
select name, (
  select id from teams where teams.name || ' D/ST' = csvs.defense.name limit 1
), 5
from csvs.defense;

-- insert the points
insert into points(
  player_id, 
  season_id, 
  carries, 
  rushing_yards, 
  rushing_tds, 
  receptions, 
  receiving_yards, 
  receiving_tds
)
select
  (select id from players where players.name = csvs.running_backs.name limit 1),
  1,
  (carries::numeric)::int as carries,
  (rushing_yards::numeric)::int as rushing_yards,
  (rushing_tds::numeric)::int as rushing_tds,
  (receptions::numeric)::int as receptions,
  (receiving_yards::numeric)::int as receiving_yards,
  (receiving_tds::numeric)::int as receiving_tds
from csvs.running_backs
where rushing_yards <> '';

insert into points(
  player_id, 
  season_id, 
  carries, 
  rushing_yards, 
  rushing_tds, 
  receptions, 
  receiving_yards, 
  receiving_tds
)
select
  (select id from players where players.name = csvs.wide_receivers.name limit 1),
  1,
  (carries::numeric)::int as carries,
  (rushing_yards::numeric)::int as rushing_yards,
  (rushing_tds::numeric)::int as rushing_tds,
  (receptions::numeric)::int as receptions,
  (receiving_yards::numeric)::int as receiving_yards,
  (receiving_tds::numeric)::int as receiving_tds
from csvs.wide_receivers
where receiving_yards <> '';

insert into points(
  player_id, 
  season_id, 
  carries, 
  rushing_yards, 
  rushing_tds, 
  receptions, 
  receiving_yards, 
  receiving_tds
)
select
  (select id from players where players.name = csvs.tight_ends.name limit 1),
  1,
  (carries::numeric)::int as carries,
  (rushing_yards::numeric)::int as rushing_yards,
  (rushing_tds::numeric)::int as rushing_tds,
  (receptions::numeric)::int as receptions,
  (receiving_yards::numeric)::int as receiving_yards,
  (receiving_tds::numeric)::int as receiving_tds
from csvs.tight_ends
where receiving_yards <> '';

insert into points(
  player_id, 
  season_id, 
  completions, 
  attempts, 
  passing_yards, 
  td_passes, 
  carries, 
  rushing_yards, 
  rushing_tds,
  intercepted
)
select
  (select id from players where players.name = csvs.quarterbacks.name limit 1),
  1,
  (completions::numeric)::int as completions,
  (attempts::numeric)::int as attempts,
  (passing_yards::numeric)::int as passing_yards,
  (tds::numeric)::int as td_passes,
  (carries::numeric)::int as carries,
  (rushing_yards::numeric)::int as rushing_yards,
  (rushing_tds::numeric)::int as rushing_tds,
  (interceptions::numeric)::int as intercepted
from csvs.quarterbacks
where completions <> '';

insert into points(
  player_id, 
  season_id, 
  sacks, 
  interceptions, 
  fumbles, 
  rushing_tds
)
select
  (select id from players where players.name = csvs.defense.name limit 1),
  1,
  (sacks::numeric)::int as sacks,
  (interceptions::numeric)::int as interceptions,
  (fumbles::numeric)::int as fumbles,
  (tds::numeric)::int as rushing_tds
from csvs.defense;