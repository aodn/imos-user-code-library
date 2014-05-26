# Example to plot ANFOG datasets
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
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANFOG/seaglider/SOTS20110420/IMOS_ANFOG_BCEOSTUV_20110420T111022Z_SG517_FV01_timeseries_END-20110420T140511Z.nc'
dataset <- ncParse( file_URL)

qcLevel1 <- 1 # We use the quality control flags to select only data with good QC flags

## Extract data from variables and dimensions
psal <- dataset$variables$PSAL$data[ which(( dataset$variables$PSAL$flags) == qcLevel1)]
time <- dataset$dimensions$TIME$data[ which(( dataset$variables$PSAL$flags) == qcLevel1)]
depth <- dataset$variables$DEPTH$data[ which(( dataset$variables$PSAL$flags) == qcLevel1)]

## Extract data from global and variable attributes
title <- dataset$metadata$title
psallab <- dataset$variables$PSAL$standard_name
psalunit <- dataset$variables$PSAL$units
timelab <- dataset$dimensions$TIME$standard_name
depthlab <- dataset$variables$DEPTH$long_name
depthunit <- dataset$variables$DEPTH$units

## Plot the depth and salinity profiles
par( mar = c( 4.5, 4.5, 4.5, 4.5))
plot( time, -depth, xlab = timelab, ylab = paste( depthlab, ' ', '(', depthunit, ')', sep = ''), main = paste( title, ' - data with good QC flags only', '
', 'Lat / Lon = ', round( dataset$metadata$geospatial_lat_min, 1), ' / ', round( dataset$metadata$geospatial_lon_min, 1), '
', 'Start - End = ', dataset$metadata$time_coverage_start, ' - ', dataset$metadata$time_coverage_end, sep = ''), type = 'l', pch = 19, xaxt = 'n', cex.lab = 1.5)
par( new = TRUE)
plot( time, psal, xlab = '', type = 'l', col = 'red', pch = 19, xaxt = 'n', ylab = '', main = '', yaxt = 'n')
axis.POSIXct( 1, seq( time[1], time[length(time)], by = 'hours'), format = '%H:%M')
axis( 4, at = seq( round( min( psal), 2), round( max( psal), 2), .02), labels = T, col.axis = 'red')
mtext( paste( psallab, ' ', '(', psalunit, ')', sep = ''), side = 4, line = 2.5, cex = 1.5, col = 'red')


