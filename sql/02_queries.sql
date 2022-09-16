-- The starting point
select players.name, points.passing_yards, points.td_passes
from points
inner join players on players.id = points.player_id
inner join positions on positions.id = players.position_id
where positions.name = 'QB'
order by passing_yards desc;

-- Getting more complicated
select 
  players.name, 
  passing_yards, 
  td_passes,
  (td_passes * 4) + (passing_yards/4) as score
from points
inner join players on players.id = points.player_id
inner join positions on positions.id = players.position_id
where positions.name = 'QB'
order by score desc;

-- Our view
drop view if exists raw_score;
create view raw_score as
select 
  players.id,
  players.name,
  positions.name as position,
  (4 * points.td_passes) + 
  (points.passing_yards / 10) -
  (points.intercepted * 3) + 
  (points.rushing_tds * 6) + 
  (points.rushing_yards / 5) + 
  (points.receiving_yards / 5) + 
  (points.receiving_tds * 6) + 
  (points.carries / 2 ) + 
  (points.receptions / 2 ) + 
  (points.sacks * 2) + 
  (points.interceptions * 3) + 
  (points.fumbles * 3)
  as fantasy_points,
  rob_factor
from points
inner join players on players.id = points.player_id
inner join positions on positions.id = players.position_id
order by fantasy_points desc;

-- weighting things
update points set rob_factor = 1.2 where player_id=1;
update points set rob_factor = 0.7 where player_id=125;
update points set rob_factor = 0 where player_id = 4;

--- The analysis query
select
  id, 
  name, 
  position,
  fantasy_points,
  fantasy_points * rob_factor as projection
from raw_score