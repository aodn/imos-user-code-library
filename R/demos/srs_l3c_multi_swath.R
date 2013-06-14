# Example to plot SRS - GHRSST - L3C multi swath
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse a subset of a local NetCDF file
file <- '/path/to/20130401152000-ABOM-L3C_GHRSST-SSTskin-AVHRR19_D-1d_night-v02.0-fv01.0.nc'
dataset <- ncParse( file, parserOption = 'all', variables = 'sea_surface_temperature') # Only harvest the sea surface temperature variable

## Load the raster and maps package
library( raster)
library( maps)

## Extract data from variables and dimensions
lat <- dataset$dimensions$lat$data
lon <- dataset$dimensions$lon$data
temp <- dataset$variables$sea_surface_temperature$data
date <- dataset$dimensions$time$data

## Extract data from global and variable attributes
title <- dataset$metadata$title
latlab <- gsub( '_', ' ', dataset$dimensions$lat$long_name)
lonlab <- gsub( '_', ' ', dataset$dimensions$lon$long_name)
templab <- gsub( '_', ' ', dataset$variables$sea_surface_temperature$long_name)
tempunit <- gsub( '_', ' ', dataset$variables$sea_surface_temperature$units)
latunit <- gsub( '_', ' ', dataset$dimensions$lat$units)
lonunit <- gsub( '_', ' ', dataset$dimensions$lon$units)

## The longitude in the original dataset ranges from [-180 to 180].
## To deal with the international date line issue, we add 360 to all longitude values that are negative.
for (i in 1:length(lon)){
	if(lon[i] < 0) lon[i] <- lon[i] + 360
}

## Create a raster of longitude, latitude, and temperature data
dat1 <- list( )
dat1$x <- c( lon)
dat1$y <- c( lat)
dat1$z <- t( temp)
raster <- raster( dat1$z, xmn = range( dat1[[1]])[1], xmx = range( dat1[[1]])[2], ymn = range( dat1[[2]])[1], ymx = range( dat1[[2]])[2])

## Plot the sea surface temperature grid
par( mar = c(5, 4.5, 4.5, 5.5))
plot( extent( raster), bty = 'n', main = paste( title, '
', date, sep = ''), xlab = paste( lonlab, ' (', lonunit, ') ', sep = ''), ylab = paste( latlab, ' (', latunit, ') ', sep = ''))
plot( raster, add = T, col = colorRampPalette( c( "blue", "yellow", "red"))( 255), cex.lab = 1.5,
xlim=c( min( lon), max( lon)), ylim = c ( min( lat), max( lat)), zlim = c( min( temp, na.rm = TRUE), max( temp, na.rm = TRUE)), 
legend.width = 2, legend.shrink = .75, legend.args = list( text = paste( templab, ' ', '(', tempunit, ')', sep = ''), side = 4, line = 3, cex = 1.5),
axis.args = list( at = seq( round( min( temp, na.rm = TRUE), 0), round( max( temp, na.rm = TRUE),0), 5), labels = seq( round( min( temp, na.rm = TRUE),0), round( max( temp, na.rm = TRUE),0), 5)))
map( 'world', fill = TRUE, add = T, col = 'grey')