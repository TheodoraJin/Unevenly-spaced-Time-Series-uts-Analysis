#### simple random number generate ####

## Assumptions: Rainfall of each minute are iid, which would be easily violated.

## set work directory
getwd()
setwd("E:/Mott MacDonald test question")


x <- read.csv("accumRainfall.csv", header = T)


library(dplyr)
library(lubridate)
library(VGAM)

# vector from 18:00 to 19:00 pm
time <- format(as.POSIXct(x$unixdatetime[1] + c(0:60) * 60 - 3600,
                          origin = "1970-01-01 ", tz = "EST"), "%H:%M")
# date of supplied data range
date <- as.character(as.Date(as.POSIXct(x$unixdatetime, origin = "1970-01-01 ", 
                                        tz = "EST")))




### Gamma

#set.seed(666)

rand_vect_cont_gamma <- function(M) 
  {
    use.60 <- rep(60, length(M))
    vec <- rgamma(use.60, 1)
    vec / sum(vec) * M
  }  


## de-accumulated data set: gamma
time.mat.gamma = matrix(sapply(x$value, rand_vect_cont_gamma), nrow = 91, byrow = T,
           dimnames = list(date, time[-1]))
#View(time.mat.gamma)


###### Find the peak 30-min interval ###### 

peak.interval = numeric(0)
for (i in (1:dim(time.mat.gamma)[1])) 
{
  index <- which.max(diff(cumsum(c(0, time.mat.gamma[1, ])), 30))
  peak.interval[i] <- paste(time[index], time[index + 30], sep = "--")
}

names(peak.interval) <- date

#### Not run. 
# peak.interval

table(peak.interval) 


### Note that the answer is same for each day 
### as we already assume the underlying distribution is Gamma.









### GPD

#set.seed(666)
rand_vect_cont_gpd <- function(M) 
  {
    use.60 <- rep(60, length(M))
    vec <- rgpd(use.60, location = M/60)
    vec / sum(vec) * M
}  


## de-accumulated data set: gamma
time.mat.gpd = matrix(sapply(x$value, rand_vect_cont_gamma), nrow = 91, byrow = T,
                        dimnames = list(date, time[-1]))
View(time.mat.gpd)


###### Find the peak 30-min interval ###### 

peak.interval = numeric(0)
for (i in (1:dim(time.mat.gpd)[1])) 
{
  index <- which.max(diff(cumsum(c(0, time.mat.gpd[1, ])), 30))
  peak.interval[i] <- paste(time[index], time[index + 30], sep = "--")
}

names(peak.interval) <- date

#### Not run. 
# peak.interval

table(peak.interval) 
### Note that the answer is same for each day 
### as we already assume the underlying distribution is GPD.

