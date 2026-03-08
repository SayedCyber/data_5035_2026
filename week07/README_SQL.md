How to run
open the file "ev_charging_analysis" in Snowflake account and just run it. it will show you the top 4 locations

What does this project do?
it is one big query using CTEs that does everything in a specific order. i used 4 tables from the DATA5035.SPRING26 database:

Join tables: i joined ROAD_SEGMENTS, TRAFFIC_COUNTS, INCIDENTS, and WEATHER_RISK all together using the SEGMENT ID.

Normalizing: i found the min and max values so i can make all the scores between 0 and 100. this makes it easy to compare.

Calculating 3 scores:

DEMAND: more EVs = higher score.

SAFETY: i used a mix of fewer crashes (60%) and low weather risk (40%).

ROAD: having more lanes and better speed limits gives a higher score.

Final Score: i used a weighted formula: demand 40% + safety 35% + road 25%.

Ranking: i used PARTITION BY INTERSTATE to rank the roads inside each highway separately.

Final Result: i only kept the "rank 1" (the best one) from each highway and picked the top 4

Why SQL (declarative)?
SQL is declarative. this means i just describe what i want, not how the computer should do it step-by-step. i just tell Snowflake: "join these 4 tables, calculate these scores, and rank them." the database figures out the best way to do it. there are no for loops or manual variables like in python.

for joining 4 tables and doing math on 103 rows, SQL is very fast and clean. using CTEs makes the code look organized, so you can read it like a list of steps even though it is one query. the PARTITION BY part is great because it strictly picks 1 segment each highway to make sure we have geographic diversity.

Assumptions:
I used the same scores and weights as my python version so they are fair.

PARTITION BY gives exactly 1 segment per highway which is a bit stricter than my python loop.

I trust that the data in the snowflake database is correct

I rounded all the final scores to whole numbers to make the output look cleaner.