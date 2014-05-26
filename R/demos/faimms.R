# Example to plot FAIMMS datasets
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
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/FAIMMS/Myrmidon_Reef/Sensor_Float_1/water_temperature/sea_water_temperature@5.0m_channel_114/2012/QAQC/IMOS_FAIMMS_T_20121201T000000Z_FV01_END-20130101T000000Z_C-20130426T102459Z.nc'
dataset <- ncParse( file_URL)

## Select only data with QC flags of 1
qcLevel1 <- 1

## Extract data from variables
temp <- dataset$variables$TEMP$data[ which((dataset$variables$TEMP$flags) == qcLevel1)]
date <- dataset$dimensions$TIME$data[ which((dataset$variables$TEMP$flags) == qcLevel1)]

## Extract data from global and variable attributes
title <- dataset$metadata$title
templab <- dataset$variables$TEMP$long_name
tempunit <- dataset$variables$TEMP$units
datelab <- dataset$dimensions$TIME$long_name

## Plot the temperature time series
par( mar = c( 5, 4.5, 5, 2))
plot( date, temp, xlab = datelab, ylab = paste( templab, ' ', '(', tempunit, ')', sep = ''), main = paste( title, '
', dataset$metadata$geospatial_vertical_min, ' m deep', '
', 'Lat/Lon = ', round( dataset$metadata$geospatial_lat_min, 1), '/', round( dataset$metadata$geospatial_lon_min, 1), '
', 'Start = ', dataset$metadata$time_coverage_start, sep = ''), type = 'l', pch = 19, xaxt = 'n', cex.lab = 1.5)
axis.POSIXct( 1, seq( date[1], date[length(date)], by = 'weeks'), format = '%d %b %Y')
