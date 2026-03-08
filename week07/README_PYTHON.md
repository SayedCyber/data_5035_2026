How to run
open the file ev_charging_analysis.ipynb in Snowflake account and just click Run All. it goes from the top to the bottom.

What it does
i used these 4 tables from the DATA5035.SPRING26 database for my project:

ROAD_SEGMENTS (information about lanes and speed)

TRAFFIC_COUNTS (how many EVs are there)

INCIDENTS (crash rates)

WEATHER_RISK (bad weather risk for each part)

i merged all of them using SEGMENT_ID to make one big table then i gave each road 3 scores (0 to 100):

DEMAND: more EVs driving there means a higher score.

SAFETY: i used fewer crashes (60%) and low weather risk (40%) to get this scoer

ROAD: more lanes and higher speed limits are better.

The final score is: demand 40% + safety 35% + road 25%.
After calculating, i sorted the list. but i didn't just take the top 4. i wrote a for loop to make sure we pick segments from different highways. if i didn't do this, all 4 picks might be on the same road (like I-55) and that's not good for a pilot program.

Why Python (imperative):
I chose python because it is imperative. this mean i write each step one by one: load data, merge, calculate, and then loop.
I picked this because the selection logic needs a loop with "if" conditions. i have to check "did i already pick from this highway?" at every step. doing this with a for loop and if statements is very natural in python. also, this way is more flexible than SQL.

Output
The file SEGMENTS.csv in the" week07" folder contains all 103 road segments with their suitability scores. The 4 recommended locations are marked with "YES" in the RECOMMENDED column.

Assumptions
ev traffic is the most important part (40%) because we need people to use the lanes.

weather risk is important for safety because chaging in ice or snow is risky.

picking from different highways is better to see how the tech works in different areas.

I rounded the scores to whole numbers to keep it simple.