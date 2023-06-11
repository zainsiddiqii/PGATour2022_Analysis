----- Exploratory Data Analysis and Answering some questions -----

-- Total Prize Money in Million Dollar
SELECT ROUND(SUM(purse)::numeric, 1) AS total_prize_money
FROM tournaments;

-- Unique number of players
SELECT COUNT(DISTINCT id) AS total_players
FROM players;

-- Get Mean, Median, and Standard Deviation for all statistics
SELECT 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_offthetee) AS median_sg_offthetee,
ROUND(AVG(sg_offthetee::numeric),3) AS mean_sg_offthtee,
ROUND(STDDEV(sg_offthetee::numeric),3) AS stddev_sg_offthetee
FROM joined_table;

SELECT 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_approach) AS median_sg_approach,
ROUND(AVG(sg_approach::numeric),3) AS mean_sg_approach,
ROUND(STDDEV(sg_approach::numeric),3) AS stddev_sg_approach
FROM joined_table;

SELECT 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_aroundthegreen) AS median_sg_aroundthegreen,
ROUND(AVG(sg_aroundthegreen::numeric),3) AS mean_sg_aroundthegreen,
ROUND(STDDEV(sg_aroundthegreen::numeric),3) AS stddev_sg_aroundthegreen
FROM joined_table;

SELECT 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_teetogreen) AS median_sg_teetogreen,
ROUND(AVG(sg_teetogreen::numeric),3) AS mean_sg_teetogreen,
ROUND(STDDEV(sg_teetogreen::numeric),3) AS stddev_sg_teetogreen
FROM joined_table;

SELECT 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_putting) AS median_sg_putting,
ROUND(AVG(sg_putting::numeric),3) AS mean_sg_putting,
ROUND(STDDEV(sg_putting::numeric),3) AS stddev_sg_putting
FROM joined_table;

-- Can also separate by tournament
SELECT 
tournament_name,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sg_total) AS median_sg_total,
ROUND(AVG(sg_total::numeric),3) AS mean_sg_total,
ROUND(STDDEV(sg_total::numeric),3) AS stddev_sg_total
FROM joined_table
GROUP BY tournament_name;


-- Tournament difficulty from easiest -> hardest
WITH round_score AS (
    SELECT strokes / number_of_rounds AS round, tournament_name
    FROM joined_table
    WHERE number_of_rounds = 4
)
SELECT
tournament_name,
ROUND(AVG(round::numeric), 2) as average_round,
ROUND(STDDEV(round::numeric), 2) AS stddev_round
FROM round_score
GROUP BY tournament_name
ORDER BY average_round;

-- Top and bottom (add DESC after ORDER BY average_round) 10 players by round average throughout the year
WITH round_score AS (
    SELECT strokes / number_of_rounds AS round, player_name
    FROM joined_table
)
SELECT
player_name,
ROUND(AVG(round::numeric), 2) as average_round
FROM round_score
GROUP BY player_name
ORDER BY average_round
LIMIT 10;

-- Most 1st place finishes
SELECT player_name, COUNT(*) as number_of_wins
FROM joined_table
WHERE position = 1
GROUP BY player_name
ORDER BY number_of_wins DESC
LIMIT 5;

