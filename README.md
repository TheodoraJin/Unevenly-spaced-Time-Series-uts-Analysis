# Unevenly-spaced-Time-Series-uts-Analysis
Short analyses of an Unevenly-spaced Time Series (UTS) in Pennsylvania, USA, from 07 Jan 2016 to 09 Aug 2016.

The .csv file contains 91 Unix timestamp and corresponding accumulated rainfall (inch) in 1 hour duration. 
It is vague and provides very limited information.



The .R file contains visualisation and predictions.

In 1998, Aksoy published that Gamma distribution was considered to be an appropriate approach to model rainfall. (Use Gamma Distribution in Hydrology Analysis)
Later in 2010, Dan'azumi et.al published the result of hourly rainfall modelling in Malaysia. An Generalised Pareto distribution was found to be the most suitable model particularly for Malaysia. 

Therefore, the contributor performed Locally Estimated Scatterplot Smoothing (Loess) and Generalized Linear Model as analysing tool. 




Finally, the de-accumulated rainfall amount within each 1-hour duration from the original dataset were calculated, based on Loess regression. Also, the corresponding 30-minute peak interval have been computed.


Limitations:


Future work:
- The contributor should consider split the data into training/ test subset, to see how models behave.
- Also, predict result of gamma/ GPD distribution should be illustrated.
- Furthermore, embedded/ anonymous function should be considered, to serve for a large range of input data (from .RData, SQL server, etc.) .
