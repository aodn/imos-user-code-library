# Example to plot ANMN datasets
#
# Comments : the ‘aqfig’ and ‘maps’ packages need to be installed and loaded.
#            in the R console, type:
#		install.packages("ggplot2")
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
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANMN/WA/WATR50/Velocity/IMOS_ANMN-WA_VATPE_20120516T040000Z_WATR50_FV01_WATR50-1205-Workhorse-ADCP-498_END-20121204T021500Z_C-20121207T023956Z.nc'
dataset <- ncParse( file_URL)

## Load the ggplot2 package
library(ggplot2)

## Extract data from variables and dimensions
ucur <- dataset$variables$UCUR$data
depth <- dataset$dimensions$HEIGHT_ABOVE_SENSOR$data
date <- dataset$dimensions$TIME$data

## Extract data from global and variable attributes
title <- dataset$metadata$title
ucurlab <- gsub( '_', ' ', dataset$variables$UCUR$long_name)
ucurunit <- gsub( '_', ' ', dataset$variables$UCUR$units)
depthlab <- gsub( '_', ' ', dataset$dimensions$HEIGHT_ABOVE_SENSOR$long_name)
depthunit <- gsub( '_', ' ', dataset$dimensions$HEIGHT_ABOVE_SENSOR$units)
datelab <- dataset$dimensions$TIME$long_name

## Create a data frame holding the dates, depths, and eastward sea water velocity
dat1 <- data.frame( rep( date, each = length( depth)),c( rep( depth, length( date))), c( ucur))
colnames( dat1) <- c( 'x', 'y', 'z')

## Plot the eastward sea water velocity profiles and time series
ggplot( data = dat1, aes( x = x, y = y)) +
geom_raster( aes( fill = z)) +
scale_fill_gradient2( name = paste( ucurlab, ' ', '(', ucurunit, ')', sep = ''), limits = c( -1, 1), low = 'blue' , high = 'red', midpoint = 0, na.value = 'white')+
theme( panel.background = element_rect( fill = 'white', colour = 'black'), panel.grid.major = element_blank())+
labs( list( title = paste( title, '
', 'Lat / Lon = ', round( dataset$metadata$geospatial_lat_min, 1), ' / ', round( dataset$metadata$geospatial_lon_min, 1), '
', 'Start - End = ', dataset$metadata$time_coverage_start, ' - ', dataset$metadata$time_coverage_end, sep = ''), x = datelab, y = paste( depthlab, ' (', depthunit, ')', sep = '')))
