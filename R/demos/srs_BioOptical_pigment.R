# Example to plot SRS - BioOptical pigment
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Load the ncdf4 package and NetCDF parser function
library(ncdf4)
# source( '/path/to/ncParse.R') #please uncomment this line and point the path to the ncParse.R file downloaded from the IMOS User Code Library git repository

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/pigment/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-pigment_END-19971207T220700Z_C-20121129T120000Z.nc'
dataset <- ncParse( file_URL)

## Select a single profile and its associated measurements
nprof <- length( dataset$dimensions$profile$data) # Number of profiles
profile <- 10 # We select arbitrarily profile number 10, we could plot any profile from 1 to nprof
nobs <- dataset$variables$rowSize$data[profile]
obsindex <- seq( sum( dataset$variables$rowSize$data[1:( profile - 1)]) + 1, sum( dataset$variables$rowSize$data[1:profile]), 1)
station_index <- dataset$variables$station_index$data

## Extract data from variables. Lat and lon depnd of station_index, date depends of profile.
date <- dataset$variables$TIME$data[profile]
lat <- round( dataset$variables$LATITUDE$data[station_index[profile]], 1)
lon <- round( dataset$variables$LONGITUDE$data[station_index[profile]], 1)
depth <- dataset$variables$DEPTH$data[obsindex]
cphl_a <- dataset$variables$CPHL_a$data[obsindex]

## Extract data from global and variable attributes
title <- dataset$metadata$source
depthlab <- dataset$variables$DEPTH$long_name
cphl_a_lab <- gsub( '_', ' ', dataset$variables$CPHL_a$long_name)
depthunit <- dataset$variables$DEPTH$units
cphl_a_unit <- dataset$variables$CPHL_a$units

## Plot the chlorophyll concentration profile
plot( cphl_a, depth, xlab = paste( cphl_a_lab, ' (', cphl_a_unit, ') ', sep = ''), ylab = paste( depthlab, ' (', depthunit, ') ', sep = ''), main = paste( title, '
', date, '
', 'Lat / Lon: ', lat, ' / ', lon, sep = ''), type = 'b', pch = 19)