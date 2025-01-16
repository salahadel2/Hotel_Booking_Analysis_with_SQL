--# Hotel Booking Data Analysis: Key Questions and Insights

Create database hotel_revenue_historical_full

CREATE VIEW DBO.Hotel AS
SELECT * FROM dbo.['2018']
UNION
SELECT * FROM dbo.['2019']
UNION
SELECT * FROM dbo.['2020'];

-- Examine a sample of data:
SELECT TOP(10) * FROM Hotel;
----------------------
--### Hotel Type Distribution
--### Question 1: How many bookings were made for each hotel type?
-- Purpose: Analyze the distribution of bookings across different hotel types.

SELECT 
    hotel AS "Hotel Type", 
    COUNT(hotel) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY hotel
ORDER BY "Total Bookings" DESC;

-------------
/*SELECT hotel AS "Hotel Type", 
	   COUNT(*) AS "Total Canceled Bookings",
	   ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
WHERE is_canceled = 1
GROUP BY hotel*/
--_________________________________________________________________________________________
--### Cancellation Analysis
--### Question 2: How many bookings were canceled and how many were not canceled?
-- Purpose: Evaluate booking reliability and cancellation patterns.

SELECT 
    CASE
        WHEN is_canceled = 0 THEN 'Not Canceled'
        ELSE 'Canceled'
    END AS "Booking Status",
    COUNT(is_canceled) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
WHERE is_canceled IS NOT NULL
GROUP BY is_canceled;
--_________________________________________________________________________________________
--### Lead Time Analysis
--### Question 3: What is the average lead time for bookings?
--Purpose: Understand booking patterns and customer planning behavior.

SELECT 
    ROUND(AVG(lead_time), 0) AS "Average Lead Days",
    ROUND(MIN(lead_time), 0) AS "Minimum Lead Days",
    ROUND(MAX(lead_time), 0) AS "Maximum Lead Days"
FROM Hotel;
--_________________________________________________________________________________________
--### Family Bookings Analysis
--### Question 4: How many bookings were made with children, babies, or both?
--Purpose: Analyze family travel patterns.

SELECT 
    CASE 
        WHEN children > 0 AND babies > 0 THEN 'Both Children and Babies'
        WHEN children > 0 THEN 'With Children Only'
        WHEN babies > 0 THEN 'With Babies Only'
        ELSE 'No Children or Babies'
    END AS "Family Type",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY 
    CASE 
        WHEN children > 0 AND babies > 0 THEN 'Both Children and Babies'
        WHEN children > 0 THEN 'With Children Only'
        WHEN babies > 0 THEN 'With Babies Only'
        ELSE 'No Children or Babies'
    END;
--_________________________________________________________________________________________
--### Special Requests Analysis
--### Question 5: How many bookings included special requests?
--Reveals whether basic services meet guest needs or additional amenities are needed.

SELECT CASE 
            WHEN total_of_special_requests > 0 THEN 'Bookings With Special Requests'
            ELSE 'Bookings Without Special Requests'
        END AS "Type Of Bookings",
        COUNT(*) AS "Total Bookings",
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY CASE 
            WHEN total_of_special_requests > 0 THEN 'Bookings With Special Requests'
            ELSE 'Bookings Without Special Requests'
        END;
-------------
/*SELECT 
    total_of_special_requests AS "Number of Requests",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;*/
---------------
/*SELECT COUNT(*) AS "Bookings With Special Requests"
FROM Hotel
WHERE total_of_special_requests > 0;

SELECT COUNT(*) AS "Bookings Without Special Requests"
FROM Hotel
WHERE total_of_special_requests = 0;*/
--_________________________________________________________________________________________
--### Geographic Distribution
--### Question 6: What is the proportion of guests by country of origin?
--Purpose: To identify key markets for targeted marketing campaigns.
-- Identify key markets for targeted marketing.

SELECT TOP 10
    country AS "Country",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY country
ORDER BY "Total Bookings" DESC;
--_________________________________________________________________________________________
--### Monthly Booking Trends
--### Question 7: Which month of the year sees the highest and lowest bookings?
-- Purpose: To identify seasonal patterns and peak, off-season periods.

SELECT 
    arrival_date_year AS "Year",
    arrival_date_month AS "Month",
    COUNT(*) AS "Total Bookings",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY arrival_date_year, arrival_date_month
ORDER BY arrival_date_year,
    CASE arrival_date_month 
        WHEN 'January' THEN 1 
        WHEN 'February' THEN 2 
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;

-- mast use the year
/*SELECT arrival_date_year, arrival_date_month, COUNT(*) AS "Total Bookings"
FROM Hotel
GROUP BY arrival_date_year, arrival_date_month
ORDER BY "Total Bookings" DESC;*/
--_________________________________________________________________________________________
--### Market Segment Analysis
--### Question 8: Which market segment generates the most bookings?
-- Purpose: To analyze the popularity of various market segments.

SELECT 
    market_segment AS "Segment",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS "Cancellation Rate"
FROM Hotel
GROUP BY market_segment
ORDER BY "Total Bookings" DESC;

--_________________________________________________________________________________________
--### Distribution Channel Efficiency
--### Question 9: What is the ratio of bookings made through various methods (e.g., direct, agent, OTA)?
-- Helps analyze the efficiency and popularity of distribution channels.

SELECT 
    distribution_channel AS "Channel",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
    ROUND(AVG(lead_time), 0) AS "Average Lead Time",
    ROUND(AVG(adr), 2) AS "Average Daily Rate"
FROM Hotel
GROUP BY distribution_channel
ORDER BY "Total Bookings" DESC;
--_________________________________________________________________________________________
--### Room Type Analysis
--### Question 10: What is the ratio of guests who were assigned a different room type than they reserved?
-- Identifies potential issues with room availability and booking accuracy.

SELECT CASE 
            WHEN reserved_room_type = assigned_room_type THEN 'Matched Assignments'
            ELSE'Not Matched Assignments'
        END AS "Room Type", 
        COUNT(*) AS "Total Reservations",
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM Hotel
GROUP BY CASE 
            WHEN reserved_room_type = assigned_room_type THEN 'Matched Assignments'
            ELSE'Not Matched Assignments'
        END;

-----------
/*SELECT 
    reserved_room_type AS "Room Type",
    COUNT(*) AS "Total Reservations",
    COUNT(CASE WHEN assigned_room_type = reserved_room_type THEN 1 END) AS "Matched Assignments",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(COUNT(CASE WHEN assigned_room_type = reserved_room_type THEN 1 END) * 100.0 / COUNT(*), 2) AS "Assignment Match Rate"
FROM Hotel
GROUP BY reserved_room_type
ORDER BY "Total Reservations" DESC;*/
-----------
/*SELECT COUNT(*) AS "Total Booking"
FROM Hotel
WHERE reserved_room_type <> assigned_room_type;

SELECT COUNT(*) AS "Total Booking"
FROM Hotel
WHERE reserved_room_type = assigned_room_type;*/
--_________________________________________________________________________________________
--### Question 11: What is the most frequently requested room type?
-- Purpose: To analyze demand and optimize inventory for popular room types.

SELECT reserved_room_type, COUNT(reserved_room_type) AS "Total Bookings"
FROM Hotel
GROUP BY reserved_room_type
ORDER BY "Total Bookings" DESC;
--_________________________________________________________________________________________
--### Length of Stay Patterns
--### Question 12:
WITH StayLength AS (
    SELECT 
        (stays_in_weekend_nights + stays_in_week_nights) AS total_nights
    FROM Hotel
)
SELECT 
    CASE 
        WHEN total_nights <= 1 THEN '1 Night'
        WHEN total_nights <= 3 THEN '2-3 Nights'
        WHEN total_nights <= 7 THEN '4-7 Nights'
        ELSE '8+ Nights'
    END AS "Stay Duration",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage"
FROM StayLength
GROUP BY 
    CASE 
        WHEN total_nights <= 1 THEN '1 Night'
        WHEN total_nights <= 3 THEN '2-3 Nights'
        WHEN total_nights <= 7 THEN '4-7 Nights'
        ELSE '8+ Nights'
    END
ORDER BY 
    CASE 
        WHEN total_nights <= 1 THEN '1 Night'
        WHEN total_nights <= 3 THEN '2-3 Nights'
        WHEN total_nights <= 7 THEN '4-7 Nights'
        ELSE '8+ Nights'
    END;
--_________________________________________________________________________________________
--### Guest Type Analysis
--### Question 13: What is the distribution of customers based on their purpose of stay (e.g., transient, group, contract)?"
-- Helps segment customers for tailored service and marketing.

SELECT 
    customer_type AS "Guest Type",
    COUNT(*) AS "Total Guests",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(AVG(total_of_special_requests), 2) AS "Average Special Requests"
FROM Hotel
GROUP BY customer_type
ORDER BY "Total Guests" DESC;
--_________________________________________________________________________________________
--### Meal Plan Preferences
--### Question 14: What is the ratio of meal plans chosen by guests?
-- Purpose: To optimize inventory and resource planning for catering services.

SELECT 
    meal AS "Meal Plan",
    COUNT(*) AS "Total Bookings",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS "Cancellation Rate"
FROM Hotel
GROUP BY meal
ORDER BY "Total Bookings" DESC;
--_________________________________________________________________________________________
--### Parking Requirements Analysis
--### Question 15: What is the percentage of guests who requested parking spaces?
--Purpose: To evaluate the demand for parking facilities.

SELECT CASE
            WHEN required_car_parking_spaces = 0 THEN 'No Required Parking Spaces'
            ELSE 'Required Parking Spaces'
        END AS "Parking Spaces",
        COUNT(*) AS "Total Requests",
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
        ROUND(AVG(adr), 2) AS "Average Daily Rate"
FROM Hotel
GROUP BY CASE
            WHEN required_car_parking_spaces = 0 THEN 'No Required Parking Spaces'
            ELSE 'Required Parking Spaces'
        END;
------------
/*SELECT 
    required_car_parking_spaces AS "Parking Spaces",
    COUNT(*) AS "Total Requests",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS "Percentage",
    ROUND(AVG(adr), 2) AS "Average Daily Rate"
FROM Hotel
GROUP BY required_car_parking_spaces
ORDER BY required_car_parking_spaces;*/
------------
/*SELECT COUNT(*)
FROM Hotel
WHERE required_car_parking_spaces > 0;

SELECT COUNT(*)
FROM Hotel
WHERE required_car_parking_spaces = 0;*/
--_________________________________________________________________________________________
--### Question 16: What is the percentage of new versus returning guests?
--Purpose: Measures guest retention and loyalty and Indicates the success of marketing campaigns in attracting new guests.

SELECT
    CASE
        WHEN is_repeated_guest = 0 THEN 'New Guest'
        ELSE 'Returning Guest'
    END AS "Guest Type",
    COUNT(*) AS "Total Guests",
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM Hotel
GROUP BY is_repeated_guest;
--_________________________________________________________________________________________
--### Question 17: What is the number of weekend booking to weekday booking?
--Purpose: To understanding guest preferences for short leisure trips versus business stays.
SELECT 
        SUM(CASE WHEN stays_in_weekend_nights > 0 THEN 1 ELSE 0 END) AS weekend_bookings,
        SUM(CASE WHEN stays_in_week_nights > 0 THEN 1 ELSE 0 END) AS weekday_bookings
FROM Hotel;
---  The CASE statement grouping could miss bookings that have both weekend and weekday stays
--_________________________________________________________________________________________
--### Annual Revenue Performance by Hotel Type
--### Question 18: How does total revenue differ by hotel type annually?
--This query provides an annual breakdown of total revenue, categorized by hotel type.
-- Critical Insight: Tracks year-over-year growth and hotel type performance

SELECT 
    arrival_date_year AS "Year",
    hotel AS "Hotel Type",
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr), 2) AS "Total Revenue",
    COUNT(DISTINCT arrival_date_month) AS "Operating Months",
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr) / 
          COUNT(DISTINCT arrival_date_month), 2) AS "Average Monthly Revenue"
FROM Hotel
WHERE is_canceled = 0  -- Only consider non-canceled bookings
GROUP BY arrival_date_year, hotel
ORDER BY arrival_date_year, "Total Revenue" DESC;
--_________________________________________________________________________________
--### Monthly Revenue Trends with Seasonal Analysis
--### Question 19: What is the monthly revenue trend across all years?
--This query helps track revenue trends on a monthly basis.
--Critical Insight: Identifies peak revenue months and weekend vs. weekday performance

SELECT 
    arrival_date_month AS "Month",
    ROUND(SUM(CASE WHEN stays_in_weekend_nights > 0 THEN stays_in_weekend_nights * adr ELSE 0 END), 2) AS "Weekend Revenue",
    ROUND(SUM(CASE WHEN stays_in_week_nights > 0 THEN stays_in_week_nights * adr ELSE 0 END), 2) AS "Weekday Revenue",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    COUNT(*) AS "Total Bookings"
FROM Hotel
WHERE is_canceled = 0
GROUP BY arrival_date_month
ORDER BY 
    CASE arrival_date_month 
        WHEN 'January' THEN 1 
        WHEN 'February' THEN 2 
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;

/*SELECT arrival_date_year, arrival_date_month,
    SUM((stays_in_week_nights + stays_in_weekend_nights) * adr) AS Revenue
FROM Hotel
WHERE is_canceled = 0
GROUP BY arrival_date_year, arrival_date_month
ORDER BY arrival_date_year, arrival_date_month;*/
--_________________________________________________________________________________
--### Revenue by Room Type
--### Question 20: What are trends in customer preferences for room types, and how do these preferences influence revenue?
--This query analyzes preferences and revenue trends for the types of rooms booked.

SELECT 
    reserved_room_type AS "Room Type",
    COUNT(*) AS "Total Bookings",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    SUM(CASE WHEN is_canceled = 0 THEN (stays_in_weekend_nights + stays_in_week_nights) ELSE 0 END) AS "Total Nights Stayed",
    ROUND(SUM((CASE WHEN is_canceled = 0 THEN (stays_in_weekend_nights + stays_in_week_nights) ELSE 0 END) * adr), 2) AS "Total Revenue"
FROM Hotel
GROUP BY reserved_room_type
ORDER BY "Total Revenue" DESC;
--_________________________________________________________________________________
--### Revenue Impact Factors
--### Question 21: What key factors significantly impact hotel revenue annually?
--Factors include hotel type, market segment, meal plans, and total nights booked.
--Critical Insight: Identifies key factors affecting revenue performance

SELECT 
    hotel AS "Hotel Type",
    meal AS "Meal Plan",
    ROUND(AVG(adr), 2) AS "Average Daily Rate",
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr), 2) AS "Total Revenue",
    COUNT(*) AS "Total Bookings",
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS "Cancellation Rate",
    ROUND(AVG(lead_time), 0) AS "Average Lead Time",
    ROUND(AVG(total_of_special_requests), 2) AS "Average Special Requests"
FROM Hotel
GROUP BY hotel, meal
ORDER BY "Total Revenue" DESC;