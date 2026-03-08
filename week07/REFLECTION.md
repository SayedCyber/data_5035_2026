Sayed_Amini
Data Engineering - Assignment 07 - Programming Paradigms


Reflection

Which programming paradigm did I use where?

for this project, i used two main paradigms: Python "Imperative" and SQL "Declarative". but i also used AI Driven methods to help me with both of them.
First, i used Python "Imperative" in my notebook. I liked this for the final selection because I could use a for loop and if statements to make sure I wasn't picking too many segments from the same highway. It felt like giving step-by-step instructions.

Second, i used SQL "Declarative " in Snowflake. Here, i didn't write steps; i just described what i wanted using JOINs and CTEs. i used the same weigts for both: 40% for EV demand, 35% for safety, and 25% for road quality.

Why did I choose that paradigm in that area?

I chose python for the final part because its easier to control the logic. i needed to keep track of which highways I already picked, and doing that with a Python list and a loop is very intuitive. It also helped me print out the results to check if the math was working correctly.

I chose SQL for the heavy lifting joining the 4 tables like ROAD_SEGMENTS and TRAFFIC_COUNTS. SQL is built for this. Using PARTITION BY in SQL was great because it automatically ranked the best segments for each interstate in just one line of code, which would be much longer to write in python. also the results were different because the sql version is stricter about picking one per highway, while my python loop was a bit more flexible.

What additional data would improve my confidence?

Right now, i am just looking at traffic numbers. it will be better to have actual surveys from EV drivers to see if they actually use these lanes. Also, i don't know if the power grid in those specific areas can handle a big charging lane that is a huge piece of missing information. 
Data about road pavement quality and how much it costs to build in Missouri vs illinois would also make my plan more realistic.

 What political or operational risks exist?
On the political side, dealing with two different states "Missouri and Illinois" is always tricky becaus they have different rules. Also, oil companies might not like this project, and local people may complain about the noise during construction.

Operationally, the biggest risk is safety. Slowing cars down to 30 mph when everyone else is going 70 mph sound like a recipe for accidents. also, if the charging equipment breaks in the middle of winter with ice and snow, it can block the highway.


