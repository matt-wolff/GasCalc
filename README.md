# GasCalc
![GasCalcScreenshot](https://user-images.githubusercontent.com/86255323/211381137-f29a556d-dd51-485e-9fee-1799d04f7658.png)

## Overview
This repository is for a simple iOS app I created called GasCalc, which calculates the price of the gas used in a short car trip within a US state. The motivation behind this app is that I got tired of having to calculate how much gas money my friend owed me whenever he drove my car. I had to find my car's gas mileage, the current price of gas, and calculate the number of miles he traveled to get an accurate estimate. It's much easier to use this app, as it contains the gas mileage (MPG) for all the cars currently listed on www.fueleconomy.gov as of January 3rd 2023, and gets the current gas prices for each state from gasprices.aaa.com, doing the calculation for you.


## Next Steps
One issue is that you still have to approximate the number of miles traveled by putting the route into Google Maps. This should be possible to do in-app using the Google Maps API. Another problem is that the app does not differentiate between the different types of gas cars use when calculating the total cost, as it only uses the price of regular gas. The data from www.fueleconomy.gov lists the type of gas each car uses though, so this can be fixed with better data processing.
