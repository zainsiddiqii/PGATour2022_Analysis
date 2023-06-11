-- Create tables to populate with data
CREATE TABLE tournaments (id varchar(20) PRIMARY KEY,
						  name varchar(100),
						  course varchar(100),
						  start_date date,
						  purse float,
						  season int
						  
);

CREATE TABLE players (id varchar(20) PRIMARY KEY,
					  name varchar(100)		  
);

CREATE TABLE stats (tournament_id text REFERENCES tournaments(id),
					  player_id text REFERENCES players(id),
					  hole_par int,
					  strokes int,
					  number_of_rounds int,
					  made_cut bool,
					  position int,
					  finish varchar(50),
					  sg_putting float,
					  sg_aroundthegreen float,
					  sg_approach float,
					  sg_offthetee float,
					  sg_teetogreen float,
					  sg_total float
);

----- Data Cleaning -----

-- Number of Tournaments -- 
SELECT COUNT(DISTINCT name) AS number_of_tournaments
FROM tournaments;

-- Add new columns for the name of the course, the city, and the statethe tournament is held in to the tournaments table
ALTER TABLE tournaments
ADD COLUMN course_name VARCHAR(100),
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(100);

-- Update the course, city, and state columns based on the existing data
UPDATE tournaments
SET course = TRIM(SPLIT_PART(course, '-', 1)),
    city = TRIM(SPLIT_PART(SPLIT_PART(course, '-', 2), ',', 1)),
    state = TRIM(SPLIT_PART(SPLIT_PART(course, ',', 2), '-', 1));

-- Use position and finish to help fill each other
UPDATE stats
SET finish = CAST(position AS VARCHAR)
WHERE finish IS NULL;

-- Make the position column a float
UPDATE stats
SET position = CAST(position AS float);

UPDATE stats
SET position = CASE
    WHEN finish IN ('CUT', 'DQ', 'WD', 'MDF') THEN 0
    WHEN finish IS NULL THEN NULL
    WHEN SUBSTRING(finish, 1, 1) = 'T' THEN CAST(SUBSTRING(finish, 2) AS FLOAT)
    ELSE CAST(finish AS FLOAT)
    END;

-- Remove tournaments we are not interested in
DELETE FROM stats
WHERE tournament_id IN (
    SELECT id
    FROM tournaments
    WHERE name IN ('Corales Puntacana Resort & Club Championship', 'Puerto Rico Open', 'AT&T Pebble Beach Pro-Am', 'Mayakoba Golf Classic', 'Bermuda Championship')
);

-- Create par column that tells us the par of the golf course
ALTER TABLE stats
ADD COLUMN par int;

UPDATE stats
SET par = CASE
    WHEN hole_par < 100 THEN hole_par
    WHEN hole_par < 200 THEN hole_par / 2
    ELSE hole_par / 4
    END;
	
-- Remove rows with nulls in these columns
DELETE FROM stats
WHERE sg_total IS NULL OR position IS NULL OR finish IS NULL;

-- Create joined table to export to CSV for analytics
CREATE TABLE joined_table AS
SELECT t.id AS tournament_id, t.name AS tournament_name, t.course, t.start_date, t.purse, t.season,
       p.id AS player_id, p.name AS player_name,
       s.hole_par, s.strokes, s.number_of_rounds, s.made_cut, s.position, s.finish,
       s.sg_putting, s.sg_aroundthegreen, s.sg_approach, s.sg_offthetee, s.sg_teetogreen, s.sg_total
FROM tournaments t
JOIN stats s ON t.id = s.tournament_id
JOIN players p ON p.id = s.player_id;

-- You can now run -> SELECT * FROM joined_table; and export your results to a CSV!