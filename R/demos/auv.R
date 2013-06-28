# Example to plot AUV datasets
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
source( '../commons/NetCDF/ncParse.R') #please modify if needed this line and point the path to the ncParse.R file downloaded from the IMOS User Code Library git repository

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AUV/GBR201102/r20110301_012810_station1195_09_transect/hydro_netcdf/IMOS_AUV_ST_20110301T012815Z_SIRIUS_FV00.nc'
dataset <- ncParse( file_URL)

## Extract data from variables and dimensions
temp <- dataset$variables$TEMP$data
depth <- dataset$variables$DEPTH$data
time <- dataset$dimensions$TIME$data

## Extract data from global and variable attributes
title <- dataset$metadata$title
templab <- dataset$variables$TEMP$long_name
tempunit <- dataset$variables$TEMP$units
depthlab <- dataset$variables$DEPTH$long_name
depthunit <- dataset$variables$DEPTH$units
timelab <- dataset$dimensions$TIME$standard_name

## Plot the depth and temperature profiles
par( mar = c( 4.5, 4.5, 4.5, 4.5))
plot( time, -depth, xlab = timelab, ylab = paste( depthlab, ' ', '(', depthunit, ')', sep = ''), main = paste( 'Campaign ',title, '
', 'Lat / Lon = ', round( dataset$metadata$geospatial_lat_min, 1), ' / ', round( dataset$metadata$geospatial_lon_min, 1), '
', 'Start - End = ', time[1], ' - ', time[length(time)], sep = ''), type = 'l', pch = 19, xaxt = 'n', cex.lab = 1.5)
par( new = TRUE)
plot( time, temp, xlab = '', type = 'l', col = 'red', pch = 19, xaxt = 'n', ylab = '', main = '', yaxt = 'n')
axis.POSIXct( 1, seq( time[1], time[length(time)], by = 'hours'), format = '%H:%M')
axis( 4, at = seq( round( min( temp), 2), round( max( temp), 2), .02), labels = T, col.axis = 'red')
mtext( paste( templab, ' ', '(', tempunit, ')', sep = ''), side = 4, line = 2.5, cex = 1.5, col = 'red')
