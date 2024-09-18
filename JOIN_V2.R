library(stringr)
library(dplyr)

batch1 <- data.frame(date = as.Date(character()),
                     time = character(),
                     am_pm = character(),
                     bus_num = character(),
                     Address = character(),
                     City = character(),
                     Latitude = character(),
                     Longitude = character(),
                     movement = character(),
                     low.gps.accuracy = character())

for (bus in list.files("/Users/noahrini/Desktop/BC Transit Project/Batch 9")){
  
  print(bus)
  
  wd <- paste("/Users/noahrini/Desktop/BC Transit Project/Batch 9", bus, sep = "/")
  print(wd)
  
  for (df in list.files(wd)){
    
    setwd(wd)
    print(df)
    
    df <- read.csv(df, header = TRUE)
    df <- df[-c(1:16), ]
    
    colnames(df) <- df[1, ]
    df <- df[-1, ]
    
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
    
    df <- df %>% 
      select(-c(5:9, 12:14, 17:27, 29, 30)) %>% 
      filter(!movement %in% 'Stopped')
    
    print(paste(nrow(df), 'rows'))
    
    print("--------------------")
    
    batch1 <- union(batch1, df)
    
  }
  
}

# test:

getwd()
setwd("/Users/noahrini/Desktop/BC Transit Project/FINAL DATA")

bu <- read.csv('BU_RIDES_V2.csv', header = TRUE)

bu_subset <- bu %>% 
  filter(bus_num %in% c(704, 742, 748)) # change buses in batch here

time2 <- as.POSIXlt(bu_subset$time, format = '%H:%M:%S %p')
bu_subset_time <- cbind(bu_subset, time2)

time2 <- as.POSIXlt(batch1$time, format = '%H:%M:%S %p')
batch_time <- cbind(batch1, time2)

batch_time$date <- as.character(batch_time$date)
batch_time$bus_num <- as.integer(batch_time$bus_num)

match <- left_join(bu_subset_time, batch_time, by = c('date', 'bus_num', 'am_pm'), relationship = 'many-to-many') %>%  
  group_by(date, bus_num, time.x) %>% 
  mutate(time.diff = abs(as.numeric(difftime(time2.x, time2.y, units = 'secs')))) %>% 
  slice_min(time.diff)

mean(match$time.diff)
max(match$time.diff)

# match %>% filter(if_any(everything(), is.na)) : use to check for missing dates

# library(tidyr)
# match <- match %>% drop_na() : used to elinimate missing dates

write.csv(match, 'batch9.csv')
