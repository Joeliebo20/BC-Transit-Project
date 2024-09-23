# BC Transit Data Analysis

This repository includes various files of code that were used for our project with the Broome County Department of Transportation (BC Transit).
Our goal was to use their data to find trends in Binghamton University student ridership during the Fall 2023 semester.

Their data consisted of two main types:

1. Student Rider Transactions - a record of each time a student ID was used to board a bus, including information such as date, time, bus number, and route.
  These transactions did NOT include location information of the bus/where the student boarded it.
2. Bus Geo-Location Data - coordinate locations of each bus, logged every 15 seconds while the bus is turned on. Includes date, time, bus number, latitude, & longitude coordinates.

## Data Transformation

To create the desired table for analysis, showing each student boarding with its associated location information, a join was conducted on the tables where a set of coordinates was matched to each student boarding based on the date, bus number, and the location of that bus closest in time to that of the actual boarding; this was executed in an R script using POSIXlt date-time objects and the difftime() and slice_min() functions to find the bus location that was logged the closest in time to when a student boarding the bus occured.

### Accuracy

After joining the data, the average time difference between the actual boarding times and the times of its closest known bus location was 6.135 seconds and 93% of all transactions were accurate within 15 seconds.

In theory, ALL of the transactions should be accurate within 15 seconds, as this is how often a bus's location is logged while it is running. Upon further investigation, all cases where the bus's closest known location was 15 or more seconds away occured during a period where the bus's GPS system was not pinging as consistently due to error.

All transactions with a location-time-difference of more than 1 minute were deemed not accurate and were removed (~2% of the total data), finally leaving us with 214,997 student rides, now with accurate location coordinates of where the student boarded the bus.

