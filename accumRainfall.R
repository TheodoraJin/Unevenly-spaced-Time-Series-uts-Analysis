
## set work directory
getwd()
setwd("E:/Mott MacDonald test question")


#################### Unevenly-spaced Time Series (uts) Analysis #####################

x <- read.csv("accumRainfall.csv", header = T)


library(dplyr)
library(lubridate)

## we do not need that much data.frame!

# vector  from 18:00 to 19:00 pm
time.vec <- format(as.POSIXct(x$unixdatetime[1] + c(0:60) * 60 - 3600,
                              origin = "1970-01-01 ", tz = "EST"), "%H:%M")
date.vec <- as.Date(as.POSIXct(x$unixdatetime, origin = "1970-01-01 ", tz = "EST")) 


##### visualisation of original data set


plot(date.vec, x$value,  type = 'o', 
     main = 'Pennsylvania 2016 Accumulated Rainfall Amount (18:00 -- 19:00 pm)',
     sub = 'from 07 Jan 2016 to 09 Aug 2016',
     xlab = 'Time', ylab = 'Rainfall (inch)', pch = 16, col = "orange")
legend('topleft', legend = c('Trend line', 'Observed'), 
       col = c('orange', 'orange'), pch = c(NA, 16), lty = c(1111, NA))



#####################################################################################

#### In theory, Rainfall could be fitted as either gamma or gen-Pareto distribution

#### Glancing at behavious of 2 distributions




######### gamma distribution ########

rainfall.glm <- glm(value ~ as.Date(as.POSIXct(unixdatetime, origin = "1970-01-01 "
                                               , tz = "EST")) + 
                      as.factor(quarter(as.POSIXct(unixdatetime, 
                                                   origin = "1970-01-01 ", tz = "EST"),
                                        fiscal_start = 3)),
                    data = x, family = Gamma(link = "log"))

### plot 
plot(date.vec, x$value,  type = 'o', main = 'Rainfall Distribution -- Gamma Distribution',
     xlab = 'Time', ylab = 'Rainfall (inch)', col = "orange")
lines(date.vec, fitted(rainfall.glm), pch = 16, col = "skyblue")
points(date.vec, fitted(rainfall.glm), pch = 16, col = "skyblue")
legend('topleft', legend = c('Trend line', 'Observed', 'Smooth Curve',  'Fitted values'), 
       col = c('orange', 'orange', 'skyblue', 'skyblue'), pch = c(NA, 16, NA, 16), 
       lty = c(1111, NA, 1111, NA))





########### Generalized Pareto Distribution (GPD) ##########

### fit VGLM ###

library(VGAM)

# Threshold was default to be zero.
fit <- vglm(value ~ as.Date(as.POSIXct(unixdatetime, origin = "1970-01-01 ", tz = "EST")) + 
              as.factor(quarter(as.POSIXct(unixdatetime, origin = "1970-01-01 ", tz = "EST"), 
                                fiscal_start = 3)), 
            gpd, data = x, trace = TRUE)

### plot 
plot(date.vec, x$value,  type = 'o', 
     main = 'Rainfall Distribution -- Generalized Pareto Distribution',
     xlab = 'Time', ylab = 'Rainfall (inch)', col = "orange")
lines(date.vec, fitted(fit)[, 1], pch = 16, col = "skyblue")
points(date.vec, fitted(fit)[, 1], pch = 16, col = "skyblue")
legend('topleft', legend = c('Trend line', 'Observed', 'Smooth Curve',
                             'Fitted values'), 
       col = c('orange', 'orange', 'skyblue', 'skyblue'), pch = c(NA, 16, NA, 16), 
       lty = c(1111, NA, 1111, NA))




# In general, GDP distribution behaves better than Gamma distribution, 
# in a manner of catching seasonalities. 


##################################################################################

##### Analytical solving ####

library(ProgGUIinR)
library(astsa)


#day = yday(date.vec) #x$datetime)
#mon = month(x$datetime)
year <- as.numeric(format(as.POSIXct(x$unixdatetime[1],
                                     origin = "1970-01-01 ", tz = "EST"), "%Y"))

plot(yday(date.vec), x$value, type = 'o',  
     main = 'Pennsylvania 2016 Accumulated Rainfall Amount (18:00 -- 19:00 pm)',
     xlab = 'The ith days in a year', ylab = 'Rainfall (inch)', col = "orange")
dim = sapply(1:12, function(x) days.in.month(year, x))
abline(v = cumsum(dim), lty = 2222)
legend('topleft', legend = c('Trend line', 'Observed', 'Month cut'), 
       col = c('orange', 'orange', 'black'), pch = c(NA, 1, NA), 
       lty = c(1111, NA, 2222))



############################ interpolating values #################################

### generate non-missing data frame 
library(tis)
library(imputeTS)


isLeapYear(year)
ifelse(isLeapYear(year), 366, 365) # 2016 is a leap year

start <- as.numeric(as.POSIXct("2016-01-01  19:00:00 EST", tz = "EST"))
end <- as.numeric(as.POSIXct("2016-12-31  19:00:00 EST", tz = "EST"))

### creating unix time stamp
### from  "2016-01-01  19:00:00 EST", tz = "EST", 
### to "2016-12-31  19:00:00 EST", tz = "EST"
interpol.vec <- seq(start, end, 24*60*60)

### create interpolation vector
interpol.val <- numeric(ifelse(isLeapYear(year), 366, 365))
interpol.val[yday(date.vec)] <- x$value
#k <- as.POSIXct(vec, origin = "1970-01-01 ", tz = "EST")

df = data.frame(value = interpol.val, time = interpol.vec, bin = 1:366)
df$value[df$value == 0] = NA
ts = ts(df)

### Stineman interpolation 
ts.nonmis = na.interpolation(ts, option = "stine")
df.nonmis <- data.frame(ts.nonmis)

index <- match(last(x$unixdatetime), df.nonmis$time)
df.nonmis = df.nonmis[1:index, ]
df = df[1:index, ]
# interpolation points
df.pred = df.nonmis[is.na(df$value), ]



######### plotting

## original df plot (no prediction, no smooth)
plot(1:nrow(df), df$value, type = 'p', pch = 16,
     xlab = 'The ith days in a year', ylab = 'Rainfall (inch)', col = "orange",
     main = 'Original Rainfall data')

## interpolation plot
plot(1:nrow(df), df$value, type = 'p', pch = 16,
     xlab = 'The ith days', ylab = 'Inch', col = "orange",
     main = 'Rainfall data (Interpolation with missing values)')
points(df.pred$bin, df.pred$value, pch = 16, col = 'skyblue')
legend('topleft', legend = c('Data points', 'Interpolation points'), 
       col = c('orange', 'skyblue'), pch = c(16, 16))










############################### smoothing ###########################################

## naive model
smooth = loess(value ~ bin, data = df.nonmis)
plot(smooth, type = 'o', pch = 16, main = 'Smooth and interpolation (Rainfall)',
     xlab = 'The ith days', ylab = 'Inch', col = "orange")
points(df.pred$bin, df.pred$value, pch = 16, col = 'skyblue')
lines(smooth$fitted, type = 'l', col = 'coral2', lty = 2)
legend('topleft', legend = c('Smooth Curve', 'Data points', 'Interpolation points'), 
       col = c('orange', 'orange', 'skyblue'), pch = c(NA, 16, 16), 
       lty = c(1111, NA, NA))


######### comparing with GLM
#### Gamma distribution 

rainfall.nonmis.gamma <-  
  glm(value ~ bin + # day
        quarter(as.POSIXct(time, origin = "1970-01-01 ", tz = "EST"),
                fiscal_start = 3), # season term
      data = df.nonmis, family = Gamma(link = "log"))

smooth.gamma  = loess(rainfall.nonmis.gamma, data = df.nonmis)

# plot
plot(1:nrow(df.nonmis), df.nonmis$value, type = 'o', pch = 16, 
     main = 'Smooth and interpolation (Gamma)',
     xlab = 'The ith days', ylab = 'Inch', col = "orange")
points(df.pred$bin, df.pred$value, pch = 16, col = 'skyblue')
lines(smooth.gamma$fitted, type = 'l', col = 'darkred', lty = 2)

legend('topleft', legend = c('Smooth Curve', 'Data points', 
                             'Interpolation points', 'Trend line'), 
       col = c('orange', 'orange', 'skyblue', 'darkred'), pch = c(NA, 16, 16, NA),
       lty = c(1111, NA, NA, 2222))




######## Generalized Pareto Distribution (GPD) ###

rainfall.nonmis.gpd <- 
  vglm(value ~ bin + 
         quarter(as.POSIXct(time, origin = "1970-01-01 ", tz = "EST"),
                 fiscal_start = 3),# season term
       gpd, data = df.nonmis, trace = TRUE) 


plot(df.nonmis$bin, df.nonmis$value, type = 'o',
     main = 'Smooth and interpolation (GPD)',
     xlab = 'Time', ylab = 'Rainfall (inch)', col = "orange", pch = 16)
points(df.pred$bin, df.pred$value, pch = 16, col = 'skyblue')
lines(df.nonmis$bin, fitted(rainfall.nonmis.gpd)[, 1], type= 'o', pch = 1, col = "aquamarine4")
#points(df.nonmis$bin, fitted(rainfall.nonmis.gpd)[, 1], col = "aquamarine4")
legend('topleft', 
       legend = c('Trend line', 'Observed', 'Smooth Curve',  'Fitted values'), 
       col = c('orange', 'orange', 'aquamarine4', 'aquamarine4'), pch = c(NA, 16, NA, 1), 
       lty = c(1111, NA, 1111, NA))


#### Comparisons

plot(df.nonmis$bin, df.nonmis$value, type = 'o',
     main = 'Comparison among three different methods',
     xlab = 'Time', ylab = 'Rainfall (inch)', pch = 16, col = "orange")
points(df.pred$bin, df.pred$value, pch = 16, col = 'skyblue')
lines(smooth$fitted, type = 'l', col = 'coral2', lty = 2)
lines(smooth.gamma$fitted, type = 'l', col = 'darkred', lty = 2)
lines(df.nonmis$bin, fitted(rainfall.nonmis.gpd)[, 1], lty = 2, col = "aquamarine4")
legend('topleft', 
       legend = c('Trend line', 'Observed', 'Interpolation points',
                  'Loess', 'Smooth Gamma', 'GPD'), 
       col = c('orange', 'orange', 'skyblue', 'coral2', 'darkred', 'aquamarine4'), 
       pch = c(NA, 16, 16, NA, NA, NA), 
       lty = c(1111, NA, NA, 2222, 2222, 2222))




############################################################################


#### Note that the de-accumulative data was based on 
#### Local Polynomial Regression Fitting (Loess) 


df.nonmis = df.nonmis %>% mutate(cum = cumsum(value))
smooth.cum = loess(cum ~ time, data = df.nonmis)

# plot.
plot(df.nonmis$bin, df.nonmis$cum, type = 'p', 
     main = 'Cumulative Rainfall in PA, 2016.',
     sub ='by Stineman interpolation',
     xlab = 'Time', ylab = 'Cumulative Rainfall (inch)',  col = "orange")
lines(smooth.cum$fitted, type = 'l', col = 'skyblue')



time.mat <- rep(x$unixdatetime, each = 61) + c(0:60) * 60 - 3600
time.mat <- matrix(time.mat, nrow = length(x$unixdatetime), ncol = length(0:60),
                   byrow = T, dimnames = list(date.vec, time.vec))


tv <- rep(x$unixdatetime, each = 61) + c(0:60) * 60 - 3600
tv <- predict(smooth.cum, tv)  
tv <- matrix(tv, nrow = length(x$unixdatetime), ncol = length(0:60),
                byrow = T, dimnames = list(date.vec, time.vec))

#de-accumulated data using 
de.accum.rainfall <- apply(tv, 1, diff)


#### Not run. 
# de.accum.rainfall 

### The sum is not equal to observed data,
### because we could only fit the parsimonious model with limited information.
sum(diff(predict(smooth.cum, time.mat[1, ]))) # 0.0105994, not equal to 0.23.





### find the 30-min peak interval
peak.interval = numeric(0)
for (i in (1:dim(time.mat)[1])) 
{
  index <- which.max(diff(predict(smooth.cum, time.mat[i, ]), 30))
  peak.interval[i] <- paste(time.vec[index], time.vec[index + 30], sep = "--")
}
    
names(peak.interval) <- date.vec

#### Not run. 
# peak.interval


### End.
