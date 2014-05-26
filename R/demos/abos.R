# Example to plot ABOS datasets
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNUv3 General Public License

## Load the ncdf4 package and NetCDF parser function
library(ncdf4)
source( '../commons/NetCDF/ncParse.R') #please modify if needed this line and point the path to the ncParse.R file downloaded from the IMOS User Code Library git repository

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ABOS/SOTS/Pulse/IMOS_ABOS-SOTS_20110803T000000Z_PULSE_FV01_PULSE-8-2011_END-20120719T000000Z_C-20121009T214808Z.nc'
dataset <- ncParse( file_URL)

## Extract data from variables, dimensions, and metadata
temp <- dataset$variables$TEMP_85_1$data
date <- dataset$dimensions$TIME$data
pres <- dataset$variables$TEMP_85_1$sensor_depth
lat <- round( dataset$metadata$Latitude, 2)
lon <- round( dataset$metadata$Longitude, 2)

## Extract data from global and variable attributes
title <- dataset$metadata$title
templab <- gsub( '_', ' ', dataset$variables$TEMP_85_1 $standard_name)
tempunit <- gsub( '_', ' ', dataset$variables$TEMP_85_1 $units)

## Remove NA values from the date and temperature vectors 
date <- date[- which((is.na(temp))==TRUE)]
temp <- temp[- which((is.na(temp))==TRUE)]

## Plot the temperature time series
plot( date, temp, xlab = 'Date', ylab = paste( templab, ' ', '(', tempunit, ')', sep = ''), main = paste( title, '
', 'Lat/Lon = ', lat, '/', lon, '
', 'Depth = ', pres, ' m.', sep = ''), type = 'l', pch = 19, xaxt = 'n')
axis.POSIXct( 1, seq( date[1], date[length(date)], by = 'months'), format = '%b %Y')
