###C. Kelly      17 July 2015
###Introduction

This assignment analyzes data from a personal activity monitoring device such as a Fitbit, Nike Fuelband or Jawbone Up. Such devices are used by individuals interested in monitoring their daily
movements as part of their health improvement efforts. 

For this assignment data was provided by Coursera containing the number of steps during 5 minute intervals throughout the day in months of October and November 2012. 

The analyses was guided by the Coursera questions. Code was written to determine the answers and produce the required graphs.

Data: Activity monitoring data was obtained from the course website (https://class.coursera.org/repdata-036/human_grading/view/courses/975149/assessments/3/submissions). The data was contained in a CSV file [52K] with a total of 17,568 observations over 3 variables.

Variables (as described by Coursera):   

-steps: Number of steps taking in a 5-minute interval (missing values are coded as NA)

-date: The date on which the measurement was taken in YYYY-MM-DD format

-interval: Identifier for the 5-minute interval in which measurement was taken

###Task 1: Prepare the enviroment, load and preprocess the data

```r
setwd("~/Documents/Coursera/1. DataScience/5. Reproducible Data Anaylsis/Peer Assessment Project 1")
library(knitr)
opts_chunk$set(echo=TRUE, results="show") 
```
The dataset was downloaded and read into R as a master file. This file was copied to a working file thus preserving the integrity of the original data set and avoiding re-downloading and re-reading in the event of an error.

```r
if(!file.exists("./activity.zip")) {
        print("Zipped file not in directory; download from Coursera and unzip before proceeding.")
} 

if (!file.exists('activity.csv')) {
        unzip('activity.zip')
}

if(!file.exists('StepsDataMaster')) {
        StepsDataMaster <- read.csv("activity.csv", header=TRUE, sep=',',)
}
if(!file.exists('StepsData')) {
        StepsData <- StepsDataMaster
} 
```
The file was explored using the structure (str) and summary commands. Additionally it was determined that the 2 month data period covered 61 days (unique(StepsData$date)). It was deemed that the only pre-processing needed was converting the factor date entries to a date format. Based on the questions in the assignment it did not appear necessary to convert the time intervals to "real time".

```r
StepsData$date <- as.Date(StepsData$date, format = "%Y-%m-%d") 
```

###Task 2: What is mean total number of steps taken per day?
This is the overarching question and is answered in separate parts below.
For this part of the assignment, Coursera says to ignore NAs. The resulting data frame, 
TotalStepsPerDay, is a table of dates with the total number of steps for each day. 


```r
TotalStepsPerDay <- aggregate(steps ~ date, StepsData, sum)
```

###Task 2.1: Based on the result form 2.1, prepare a histogram.

```r
library(ggplot2)
plot1 <- ggplot(TotalStepsPerDay, aes(x = steps)) + geom_histogram(fill = "blue", binwidth = 2000) + labs(title="Total Steps Taken per Day", x = "Number of Steps per Day", y = "Frequency of Occurance of Step Count") + theme_bw()  
print(plot1)
```

![](PA1_template_files/figure-html/Histogram-1.png) 

###Task 2.2: Calculate and report the mean and median of the total number of steps taken per day

```r
MeanStepsPerDay   <- mean(TotalStepsPerDay$steps, na.rm=TRUE) 
MedianStepsPerDay <- median(TotalStepsPerDay$steps, na.rm=TRUE) 
```
The average number of steps taken in a day is 1.0766189\times 10^{4}.
The median number of steps taken in a day is 10765.

The mean and median values matched those given in the initial summary report in Task 1.

###Task 3: What is the average daily activity pattern?
This question is asking for the mean of each interval over the 61 days. That is "What is the average number of steps in interval 0 over the 61 days? In interval 5, etc."


```r
StepsPerInterval <- aggregate(steps ~ interval, StepsData, mean, na.rm = TRUE)
```

###Task 3.1: Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)
Begin by renaming the columns in the dataframe from Task 3 to make the graphing easier.

```r
colnames(StepsPerInterval) <- c("Interval", "Steps")
plot2<-ggplot(StepsPerInterval, aes(x=Interval, y=Steps)) + geom_line(color='green', size = 1) + labs(title = 'Average Daily Activity Pattern', x = 'Interval', y="Average Number of Steps over 2 Months") + theme_bw()
print(plot2)
```

![](PA1_template_files/figure-html/Time series plot-1.png) 

###Task 3.2: Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?


```r
MaxSteps <- max(StepsPerInterval$Steps)
IntervalwithMaxSteps <- StepsPerInterval[which(StepsPerInterval$Steps==MaxSteps),]
```
The interval with the maximum number of steps is Interval 835 containg 206.1698113 steps.

###Task 4: Imputing missing values
There are a number of days/intervals wit missing steps values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.

###Task 4.1: Calculate and report the total number of missing values in the dataset.


```r
MissingValues <- sum(is.na(StepsData))
nrow <- nrow(StepsData)
PercentNA <- (MissingValues/nrow)*100
```
The number of missing values is 2304 which is 13.1147541 percent of the data.

###Task 4.2: Devise a strategy for filling in all of the missing values in the dataset. 

The approach chosen was to use the average number of steps across all interavals and all days to replace the NAs. 

```r
AvgStepsPerInterval <- mean(StepsPerInterval$Steps)
```

###Task 4.3: Create a new dataset that is equal to the original dataset but with the missing data filled in.

```r
StepsDataImputed <- StepsData

for (i in 1:nrow) if(is.na(StepsDataImputed[i,1])) {
        StepsDataImputed[i, 1] <- AvgStepsPerInterval
}
```
The new data set was checked to verify that NAs were not present; a value of zero was returned.

```r
(sum(is.na(StepsDataImputed))) 
```

```
## [1] 0
```
###Task 4.4: Make a histogram of the total number of steps taken each day and calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?


```r
StepsPerDayImputed <- aggregate(steps ~ date, StepsDataImputed, sum)

plot3 <- ggplot(StepsPerDayImputed, aes(x = steps)) + geom_histogram(fill = "purple", binwidth = 2000) + labs(title="Total Steps Taken per Day", x = "Number of Steps per Day", y = "Frequency of Occurance") + theme_bw()  
print(plot3)
```

![](PA1_template_files/figure-html/Mean and Median of the imputed data set-1.png) 

```r
MeanStepsPerDayImputed   <- mean(StepsPerDayImputed$steps) 
MedianStepsPerDayImputed   <- median(StepsPerDayImputed$steps) 
```
The mean number of steps in the imputed data set is 1.0766189\times 10^{4}.
The median number of steps in the imputed data set is 1.0766189\times 10^{4}.

The mean of the imputed data set and the original data set are identical. The median of the imputed data set differs only slightly from the median of the original data set. The comparison can be seen in the table generated by the following code which shows the percent difference in the values between the original and the imputed data set:

```r
PercentMeanDifferance <- ((MeanStepsPerDay  - MeanStepsPerDayImputed)/MeanStepsPerDay)*100
PercentMedianDifferance <- ((MedianStepsPerDay  - MedianStepsPerDayImputed)/MedianStepsPerDay)*100
PercentResults <- data.frame(PercentMeanDifferance, PercentMedianDifferance)
colnames(PercentResults) <- c('Mean', 'Median')
print(PercentResults)
```

```
##   Mean      Median
## 1    0 -0.01104207
```
As part of the investigation I looked at other imputed values, some close to this average and some much lower and higher just to see how the mean and median of the new data set varied. As expected using the average number of steps per interval for the imputed value gave mean and median values of the imputed data set nearly identical to those of the original data set. As the imputed value deviated from the average so did the new mean and median. Therefore the choice for the imputed value is critical if the data are to have meaning. This raises the issue of even replacing the NAs as the results can be greatly skewed depending on the choice of imputed value.

###Task 5: Are there differences in activity patterns between weekdays and weekends?

###Task 5.1: Create a new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.

```r
library(plyr)   
weekdays <- weekdays(StepsData$date)
weekdays <- as.factor(weekdays)
DayType <- revalue(weekdays, c('Monday'='Weekday','Tuesday'='Weekday','Wednesday'='Weekday','Thursday'='Weekday','Friday'='Weekday','Saturday'='Weekend','Sunday'='Weekend'))

StepsDataByDayType <- cbind(StepsDataImputed, DayType)
StepsByIntervalandDayType <- aggregate(steps ~ interval + DayType, data = StepsDataByDayType, mean) 
```


###Task 5.2: Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis). 

```r
library(lattice)
plot4 <-xyplot(steps ~ interval | DayType, StepsByIntervalandDayType, type = "l", layout = c(1, 2), xlab = "Interval", ylab = "Number of Steps") 
print(plot4)
```

![](PA1_template_files/figure-html/panel plot for weekday/weekend activity-1.png) 


Two characteristics of the Weekend/Weekday plots seem to be notable. As compared to the Weekend plot, the Weekday plot shows a higher number of steps in the interval around 8am and then a lower number of steps throughout the rest of the day. Assuming the individual is working, this data makes sense: he or she experiences greater movement in the morning while preparing for and getting to work and then settles into the work environment. On the weekend, the individual experiences fewer steps in the morning (sitting and reading the paper after preparing coffee) but then experiences greater motion the rest of the due to playing, running errands, doing housework, etc. The weekend days afford the opprotunity for greater movement as compared to a work day and the data seem to support this. Not knowing anything about the individual for whom this data applies this explanation of the data seems to be a reasonable one. Of course there would be people who work on the weekend and have Monday and Tuesday off or who work a weekday job where there is a lot of walking (postal delivery). The plots of their movement would differ greatly from the ones prepared in this exercise. Without knowing more about the study participants one can only hazzard a reasonable explanation of the data based on stereotypes: the results of this analysis seem to apply to folks who work a 9-5 fairly sedintary job Monday through Friday and have the weekends for play and other activites.
