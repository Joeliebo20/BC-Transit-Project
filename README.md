# BC Transit Data Analysis

This repository includes various files of code that were used for our project with the Broome County Department of Transportation (BC Transit).
Our goal was to use their data to find trends in Binghamton University student ridership during the Fall 2023 semester.

Their data consisted of two main types:

1. Student Rider Transactions - a record of each time a student ID was used to board a bus, including information such as date, time, bus number, and route.
  These transactions did NOT include location information of the bus/where the student boarded it.
2. Bus Geo-Location Data - coordinate locations of each bus, logged every 15 seconds while the bus is turned on. Includes date, time, bus number, latitude, & longitude coordinates.

## Data Transformation & Assigning Location Coordinates (JOIN_V2.R)

To create the desired table for analysis, showing each student boarding with its associated location information, a join was conducted on the tables where a set of coordinates was matched to each student boarding based on the date, bus number, and the location of that bus closest in time to that of the actual boarding; this was executed in an R script using POSIXlt date-time objects and the difftime() and slice_min() functions to find the bus location that was logged the closest in time to when a student boarding the bus occured.

Example: To find the location of a boarding transaction that occured on 9/15/24, 2:50:27 PM on bus 703, we look at the location data for bus 703 from that date and close to that time. Let's say we have the location coordinates of the bus logged at these times: 2:49:45 ('location 1'), 2:50:00 ('location 2'), 2:50:15 ('location 3'), 2:50:30 ('location 4'). Because location 4 was logged the closest in time to when the student actually boarded the bus, with only a 3 second time difference between these events, we conclude that location 4 accurately estimates where the student boarded the bus.

For cases where two locations were equally the most accurate/had the same minimum time difference, a duplicate record of the transaction was made to take into account both possible locations. Since these cases occured less than 2% of the time, these duplicate transactions were kept, as they did not heavily skew the data or its trends.

### Accuracy

After joining the data, the average time difference between the actual boarding times and the times of its closest known bus location was 6.135 seconds and 93% of all transactions were accurate within 15 seconds.

In theory, ALL of the transactions should be accurate within 15 seconds, as this is how often a bus's location is logged while it is running. Upon further investigation, all cases where the bus's closest known location was 15 or more seconds away occured during a period where the bus's GPS system was not pinging as consistently due to error.

All transactions with a location-time-difference of more than 1 minute were deemed not accurate and were removed (~2% of the total data), finally leaving us with 214,997 student rides, now with accurate location coordinates of where the student boarded the bus.

## Assigning the Nearest Bus Stop (Matching_Bus_Stop.ipynb)

Now that we had the coordinates of all boarding locations, we needed to determine which stop each student boarded at. Since it's likely that many locations pinged while the bus was moving and not when it was actually at the stop, the current boarding locations are likely to differ slightly from the location of the actual bus stop.

Using an official list of all bus stop locations, along with the scikit-learn Python library, we used the Ball-Tree algorithm to efficiently perform a nearest neighbor search and determine at which bus stop a student boarded the bus.

## Additional Fields

Finally, we added several additional fields to the data to expand our analysis, including: day of the week, whether it was a holiday or part of an extended school break (T/F), bus stop category (BU campus, shopping, residential, other), etc..
