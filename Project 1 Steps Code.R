# Task 1: Prepare the environment and data:

setwd("~/Documents/Coursera/1. DataScience/5. Reproducible Data Anaylsis/Peer Assessment Project 1/RepData_PeerAssessment1")
library(knitr) 
opts_chunk$set(echo=TRUE,results="show",cache=TRUE) 

# *************************************************************************************
# Get the data: download from the coursera link and unzip if not alaready done. 

if(!file.exists("./activity.zip")) {
        print("Zipped file not in directory; download from Coursera and unzip before proceeding.")
} 

if (!file.exists('activity.csv')) {
        unzip('activity.zip')
}

# *************************************************************************************
# Read in the data as a Master file, checking first to see if it's already there. Make a working copy of the data.

if(!file.exists('StepsDataMaster')) {
        StepsDataMaster <- read.csv("activity.csv", header=TRUE, sep=',',)
}
if(!file.exists('StepsData')) {
        StepsData <- StepsDataMaster
} 

# Inspect the data. Once inspected this coded was commented out as it doesn't need to be repreated.
# str(StepsData) revealed the following:
# 'data.frame':    17568 obs. of  3 variables:
# StepsData$steps   : int  NA NA NA NA NA NA NA NA NA NA ...
# StepsData$date    : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 1 1 1 1 1 1 1 1 1 1 ...
# StepsData$interval: int  0 5 10 15 20 25 30 35 40 45 ...

# summary(StepsData) - provides the mean, median, and numbr of NAs which will be useful for
# validating some of the required calculations in this exercise.
#         steps             date               interval     
# Min.   :  0.00   Min.   :2012-10-01   Min.   :   0.0  
# 1st Qu.:  0.00   1st Qu.:2012-10-16   1st Qu.: 588.8  
# Median :  0.00   Median :2012-10-31   Median :1177.5  
# Mean   : 37.38   Mean   :2012-10-31   Mean   :1177.5  
# 3rd Qu.: 12.00   3rd Qu.:2012-11-15   3rd Qu.:1766.2  
# Max.   :806.00   Max.   :2012-11-30   Max.   :2355.0  
# NA's   :2304                                          

# Over how many days was the data collected?
# unique(StepsData$date)  yields 61 days

# According to the Coursera instructions, 
#  "steps" refers to the number of steps taken in a 5-minute interval for an individual over the two month period.
#   Missing values are coded as NA.
#  "date" is the date on which the measurement was taken in YYYY-MM-DD" format
#  "interval" identifies the 5-minute interval in which measurement was taken

# *************************************************************************************
# Pre-process the data: Convert the dates (currently as factor) to a date format:
StepsData$date <- as.Date(StepsData$date, format = "%Y-%m-%d") 

# *************************************************************************************
# Task 2: What is mean total number of steps taken per day?
#This is the overarching question and is answered in separate parts below.
# For this part of the assignment, Coursera says to ignore NAs. The resulting data frame, 

TotalStepsPerDay <- aggregate(steps ~ date, StepsData, sum) 

# Create the required histogram:
library(ggplot2)
plot1 <- ggplot(TotalStepsPerDay, aes(x = steps)) + geom_histogram(fill = "blue", binwidth = 2000) + labs(title="Total Steps Taken per Day", x = "Number of Steps per Day", y = "Frequency of Occurance of Step Count") + theme_bw()  
print(plot1)

# Alternatively plot could have been generated using the base plotting system:
# plot1 <- hist(TotalStepsPerDay$steps, col='blue', main='Frequency of Total Steps per Day', xlab = 'Steps', ylab = 'Number of Days at the Specified Steps')

# Now find the mean and the median.  These values were already noted in the initial summary output.
# But it will be more useful to calculate the mean and median and store them as a variable for future use. 
MeanStepsPerDay   <- mean(TotalStepsPerDay$steps, na.rm=TRUE) 
MedianStepsPerDay <- median(TotalStepsPerDay$steps, na.rm=TRUE) 
print("Mean ="); print(MeanStepsPerDay)
print("Median ="); print(MedianStepsPerDay)

# *************************************************************************************
# The second task: What is the daily average activity pattern? i.e., What is the average of each
# interval over the 61 days?
StepsPerInterval <- aggregate(steps ~ interval, StepsData, mean, na.rm = TRUE)
colnames(StepsPerInterval) <- c("Interval", "Steps")

#  Plot a time series of the average number of steps, across all 61 days, against each 
#  5-minute interval:
plot2<-ggplot(StepsPerInterval, aes(x=Interval, y=Steps)) + geom_line(color='green', size = 1) + labs(title = 'Average Daily Activity Pattern', x = 'Interval', y="Average Number of Steps over 2 Months") + theme_bw()
print(plot2)

# Now find the 5-minute interval associated with the maximum number of steps:
MaxSteps <- max(StepsPerInterval$Steps)

IntervalwithMaxSteps <- StepsPerInterval[which(StepsPerInterval$Steps==MaxSteps),]
print('Max Steps and Associated Interval = ')
print(IntervalwithMaxSteps)

# *************************************************************************************
# The third task: Dealing with missing values.
# First find the total number of missing values and its percentage of the data.
MissingValues <- sum(is.na(StepsData))
print("Missing Values ="); print(MissingValues)
nrow <- nrow(StepsData)
PercentNA <- (MissingValues/nrow)*100
print('Percent data that has missing values ='); print(PercentNA)

# Devise and implement a strategy for imputting the NAs. 
# A reasonable approach would be to substitue the NAs in steps with an interval average computed over
# all days and all intervals. 

AvgStepsPerInterval <- mean(StepsPerInterval$Steps)

# Create and fill the data frame where the substituted values will go:
StepsDataImputed <- StepsData

for (i in 1:nrow) if(is.na(StepsDataImputed[i,1])) {
        StepsDataImputed[i, 1] <- AvgStepsPerInterval
}
# Check that are no NAs in the new data frame
print(sum(is.na(StepsDataImputed))) 
# [1] 0 

# Make a histogram of the total number of steps taken each day and recalculate the mean and median for the daily average steps with the new data frame:

StepsPerDayImputed <- aggregate(steps ~ date, StepsDataImputed, sum)

plot3 <- ggplot(StepsPerDayImputed, aes(x = steps)) + geom_histogram(fill = "purple", binwidth = 2000) + labs(title="Total Steps Taken per Day", x = "Number of Steps per Day", y = "Frequency of Occurance") + theme_bw()  
print(plot3)

MeanStepsPerDayImputed   <- mean(StepsPerDayImputed$steps) 
MedianStepsPerDayImputed   <- median(StepsPerDayImputed$steps) 
print("Mean ="); print(MeanStepsPerDayImputed)
print("Median ="); print(MedianStepsPerDayImputed)

# Compare these values to the mean and median calculated by omitting the NAs (First taks).
Means <- c(MeanStepsPerDay, MeanStepsPerDayImputed )
Medians <- c(MedianStepsPerDay, MedianStepsPerDayImputed)
Results <- data.frame(Means, Medians)
rownames(Results) <- c('NAs Omitted', 'NAs replaced with Avg Interval = 37.38')
print(Results)
# Compute a percent difference and tablulate:
PercentMeanDifferance <- ((MeanStepsPerDay  - MeanStepsPerDayImputed)/MeanStepsPerDay)*100
print("Percent Difference in the Means ="); print(PercentMeanDifferance)
PercentMedianDifferance <- ((MedianStepsPerDay  - MedianStepsPerDayImputed)/MedianStepsPerDay)*100
print("Percent Difference in the Medians ="); print(PercentMedianDifferance)
PercentResults <- data.frame(PercentMeanDifferance, PercentMedianDifferance)
colnames(PercentResults) <- c('Mean', 'Median')
print(PercentResults)

# *************************************************************************************
# The 4th task:  Are there differences in activity patterns between weekdays and weekends?
# The solution will involve the revalue function which will require plyr to be loaded
library(plyr)   
weekdays <- weekdays(StepsData$date)
weekdays <- as.factor(weekdays)
DayType <- revalue(weekdays, c('Monday'='Weekday','Tuesday'='Weekday','Wednesday'='Weekday','Thursday'='Weekday','Friday'='Weekday','Saturday'='Weekend','Sunday'='Weekend'))

StepsDataByDayType <- cbind(StepsDataImputed, DayType)
StepsByIntervalandDayType <- aggregate(steps ~ interval + DayType, data = StepsDataByDayType, mean) 

plot4 <-xyplot(steps ~ interval | DayType, StepsByIntervalandDayType, type = "l", layout = c(1, 2), xlab = "Interval", ylab = "Number of Steps") 
print(plot4)

# *************************************************************************************
# An alternative approach to the 4th task. This uses Michael's suggestion to converting
# the days of the week to the weekday and weekend labels, which I didn't understand.
# Of course his is more efficient than mine but I at least understand mine!

#library(dplyr)   #This is needed in order to use the mutate function on the date column
#WeekdayWeekend <- function(x) {
#        as.factor(ifelse(weekdays(as.Date(x), abbreviate = T) %in% c('Sat','Sun'), 'weekend', 'weekday'))
#}
#StepsDataByDayType <- mutate(StepsData, DayType = WeekdayWeekend(date))
#StepsByIntervalandDayType <- aggregate(steps ~ interval + DayType, data = StepsDataByDayType, mean) 

#plot3 <-xyplot(steps ~ interval | DayType, StepsByIntervalandDayType, type = "l", layout = c(1, 2), xlab = "Interval", ylab = "Number of Steps") 
#print(plot3)