# Sayed Amini ( University Winter Weather Impact Analysis "Data Engineering - Assignment 04)

## 1. Project Objective
This project calculates the potential impact of severe winter weather on universities in Washington State for January 2026. We use the **"Student-Days Impacted"** metric to show the scale of disruption.

## 2. Important Constraints & Solutions
To meet the assignment requirements and handle environment limits, we used these methods:

* **Manual Geocoding:** I did not have permission to use automated geocoding tools. Therefore, I **manually entered** the Latitude and Longitude for each city.
* **No Database Access:** We were not allowed to create a database for the school. Instead, we used **Pandas DataFrames** to process and store data in memory.

## 3. Methodology
* **Scraping:** Extracted school data from Wikipedia using `BeautifulSoup`.
* **Weather:** Fetched daily temperatures from **Open-Meteo API**.
* **Severe Weather Definition:** Any day with a minimum temperature below **-2.0°C**.
* **Formula:** `Enrollment × Number of Severe Days`.

## 4. Deliverables
* **Final Table:** A professional, styled table with commas and color formatting.
* **Visualization:** A horizontal bar chart showing the total impact per university (saved as an image).

---
*Developed as Data Engineering - Assignment 04
Universities Impacted by Severe Winter Weather (January 2026)
*