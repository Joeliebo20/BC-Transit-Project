library(stringr)
library(dplyr)

# run this code for all batches of buses

# create empty dataframe to store location data for the current batch of buses:

batch <- data.frame(date = as.Date(character()),
                     time = character(),
                     am_pm = character(),
                     bus_num = character(),
                     Address = character(),
                     City = character(),
                     Latitude = character(),
                     Longitude = character(),
                     movement = character(),
                     low.gps.accuracy = character())

# iterate through each bus folder in the current batch

for (bus in list.files("/Users/noahrini/Desktop/BC Transit Project/Batch 9")){ # change batch number here
  
  print(bus)
  
  wd <- paste("/Users/noahrini/Desktop/BC Transit Project/Batch 9", bus, sep = "/") # change batch number here
  print(wd)
  
# iterate through each file in each bus folder - each folder has 16 files, one for each week of location tracking
  
  for (df in list.files(wd)){
    
    setwd(wd)
    print(df)
    
# read data:
    
    df <- read.csv(df, header = TRUE)
    df <- df[-c(1:16), ]
    
    colnames(df) <- df[1, ]
    df <- df[-1, ]
    
# skip current sheet if it has no data/data is fully missing
    
    if (nrow(df) == 0){
      print("No data found")
      print("--------------------")
      next
    }
    
    am_pm <- str_sub(df$Date, -2, -1)
    
    time <- format(strptime(df$Date, format='%m/%d/%y %H:%M:%S %p'))
    time <- str_sub(time, -8, -1)
    time <- paste(time, am_pm, sep = ' ')
    date <- as.Date(df$Date, format = '%m/%d/%y')
    
    bus_num <- str_sub(bus, -3, -1)
    bus_num <- rep(bus_num, times = nrow(df))
    
    df <- cbind(date, time, am_pm, bus_num, df)
    
    colnames(df)[28] <- 'movement'
    colnames(df)[31] <- 'low.gps.accuracy'

# remove unneeded columns:
    
    df <- df %>% 
      select(-c(5:9, 12:14, 17:27, 29, 30)) %>% 
      filter(!movement %in% 'Stopped')
    
    print(paste(nrow(df), 'rows'))
    
    print("--------------------")
    
# add data from current bus to the initial dataframe:
    
    batch <- union(batch, df)
    
  }
  
}

# test:

getwd()
setwd("/Users/noahrini/Desktop/BC Transit Project/FINAL DATA")

bu <- read.csv('BU_RIDES_V2.csv', header = TRUE)

bu <- bu %>% 
  filter(bus_num %in% c(704, 742, 748)) # change buses in batch here

time2 <- as.POSIXlt(bu$time, format = '%H:%M:%S %p')
bu <- cbind(bu, time2)

time2 <- as.POSIXlt(batch$time, format = '%H:%M:%S %p')
batch <- cbind(batch, time2)

batch$date <- as.character(batch$date)
batch$bus_num <- as.integer(batch$bus_num)

match <- left_join(bu, batch, by = c('date', 'bus_num', 'am_pm'), relationship = 'many-to-many') %>%  
  group_by(date, bus_num, time.x) %>% 
  mutate(time.diff = abs(as.numeric(difftime(time2.x, time2.y, units = 'secs')))) %>% 
  slice_min(time.diff) # joining each ride with its corresponding coordinate data by date, bus number, and closest time

# if the following lines return NA values, there is missing data somewhere

mean(match$time.diff)
max(match$time.diff)

# the following can be used for trouble shooting:

# match %>% filter(if_any(everything(), is.na)) : use to check for missing dates

# library(tidyr)
# match <- match %>% drop_na() : used to elinimate missing dates

write.csv(match, 'batch9.csv')
