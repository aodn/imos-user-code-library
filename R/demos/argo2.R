# Example to plot Argo datasets - Example 2
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
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/Argo/aggregated_datasets/south_pacific/IMOS_Argo_TPS-20020101T000000_FV01_yearly-aggregation-South_Pacific_C-20121102T220000Z.nc'
dataset <- ncParse( file_URL)

## Load the raster package
library( raster)

## Select an Argo float arbitrarily
float <- which(( dataset$variables$PLATFORM_NUMBER$data) == 5900106)

## Extract data from variables
temp <- dataset$variables$TEMP_ADJUSTED$data[, float]
psal <- dataset$variables$PSAL_ADJUSTED$data[, float]
depth <- dataset$variables$PRES_ADJUSTED$data[, float]
lat <- dataset$variables$LATITUDE$data[float]
lon <- dataset$variables$LONGITUDE$data[float]

## Extract data from global and variable attributes
date <- dataset$variables$JULD$data[float]
templab <- dataset$variables$TEMP_ADJUSTED$long_name
psallab <- dataset$variables$PSAL_ADJUSTED$long_name
depthlab <- dataset$variables$PRES_ADJUSTED$long_name
latlab <- dataset$variables$LATITUDE$long_name
lonlab <- dataset$variables$LONGITUDE$long_name
tempunit <- dataset$variables$TEMP_ADJUSTED$units
psalunit <- dataset$variables$PSAL_ADJUSTED$units
depthunit <- dataset$variables$PRES_ADJUSTED$units

## Create a raster of date, depth and temperature data
dat1 <- list( )
dat1$x <- as.numeric( date)
dat1$y <- -depth[1:56] # Select only data without NAs
dat1$z <- temp[1:56,]
raster <- raster( dat1$z, xmn = min( dat1[[1]]), xmx = max( dat1[[1]]), ymn = min( dat1[[2]], na.rm = T), ymx = max( dat1[[2]], na.rm = T))

## Plot the temperature profiles and time series along with the float's trajectory
split.screen( c( 2, 1))
screen( 1)
par( mar = c( 4.5, 4.5, 3, 5), cex=  1.2)
plot( extent( raster), xaxt='n', xlab = 'Time', ylab = paste( depthlab, ' (negative dbar)', sep = ''), main = paste( dataset$metadata$description, '
', 'Argo float number: ', dataset$variables$PLATFORM_NUMBER$data[float][1], sep = ''), ylim = c( -1650, 0), bty = 'n')
axis.POSIXct( 1, seq( date[1], date[length( date)], by = 'months'), format = '%b %Y')
mtext( paste( templab, ' ', '(', tempunit, ')', sep = ''), 4.75, line = 2.5)
plot( raster, col = colorRampPalette( c( "blue", 'green', "yellow", "orange", "red"))( 255), add=T, legend.width = 2, legend.shrink = .75)
screen( 2)
par( mar = c( 4.5, 4.5, 3, 5), cex=  1.2)
plot( lon, lat, pch = 19, type = 'b', xlab = lonlab, ylab = latlab, main = paste( 'Trajectory of Argo float ', dataset$variables$PLATFORM_NUMBER$data[float][1], sep = ''))
close.screen( all = TRUE)
