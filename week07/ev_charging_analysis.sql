-- find the best 4 locations for EV charging lanes
-- we use 4 tables and give each road a score

USE DATABASE DATA5035;
USE SCHEMA SPRING26;

-- put all our data together from 4 tables
WITH combined_data AS (
    SELECT 
        r.SEGMENT_ID, r.INTERSTATE, r.START_MILE, r.END_MILE,
        r.LANES, r.SPEED_LIMIT, t.AADT_EV, i.CRASH_RATE, w.RISK_SCORE AS WEATHER_RISK
    FROM DATA5035.SPRING26.ROAD_SEGMENTS r
    LEFT JOIN DATA5035.SPRING26.TRAFFIC_COUNTS t ON r.SEGMENT_ID = t.SEGMENT_ID
    LEFT JOIN DATA5035.SPRING26.INCIDENTS i ON r.SEGMENT_ID = i.SEGMENT_ID
    LEFT JOIN DATA5035.SPRING26.WEATHER_RISK w ON r.SEGMENT_ID = w.SEGMENT_ID
),

-- get min and max so we can scale everything to 0-100
stats AS (
    SELECT 
        MIN(AADT_EV) AS min_ev, MAX(AADT_EV) AS max_ev,
        MIN(CRASH_RATE) AS min_crash, MAX(CRASH_RATE) AS max_crash,
        MIN(WEATHER_RISK) AS min_weather, MAX(WEATHER_RISK) AS max_weather,
        MAX(LANES) AS max_lanes, MAX(SPEED_LIMIT) AS max_speed
    FROM combined_data
),

-- give each road 3 scores
-- demand = how many EVs use it
-- safety = crashes (60%) and waether (40%), less is better
-- road = how many lanes and speed limit
scored AS (
    SELECT 
        c.*,
        ROUND((c.AADT_EV - s.min_ev) / NULLIF(s.max_ev - s.min_ev, 0) * 100) AS DEMAND_SCORE,
        ROUND(100 - (
            (c.CRASH_RATE - s.min_crash) / NULLIF(s.max_crash - s.min_crash, 0) * 60
            + (c.WEATHER_RISK - s.min_weather) / NULLIF(s.max_weather - s.min_weather, 0) * 40
        )) AS SAFETY_SCORE,
        ROUND((c.LANES / s.max_lanes * 50) + (c.SPEED_LIMIT / s.max_speed * 50)) AS ROAD_SCORE
    FROM combined_data c
    CROSS JOIN stats s
),

-- add up the 3 scores with weights
final_scores AS (
    SELECT *,
        ROUND(DEMAND_SCORE * 0.40 + SAFETY_SCORE * 0.35 + ROAD_SCORE * 0.25) AS COMPOSITE_SCORE
    FROM scored
),

-- rank roads within each highway
-- we dont want all 4 from the same highway
-- PARTITION BY give us exactly 1 pick per highway
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY INTERSTATE ORDER BY COMPOSITE_SCORE DESC) AS rank_in_corridor
    FROM final_scores
),

-- keep only the best one from each highway
top_per_corridor AS (
    SELECT * FROM ranked WHERE rank_in_corridor = 1
)

-- show the top 4
SELECT 
    SEGMENT_ID, INTERSTATE, START_MILE, END_MILE, AADT_EV,
    DEMAND_SCORE, SAFETY_SCORE, ROAD_SCORE, COMPOSITE_SCORE
FROM top_per_corridor
ORDER BY COMPOSITE_SCORE DESC
LIMIT 4;
