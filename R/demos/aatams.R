# Example to plot AATAMS datasets
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AATAMS/marine_mammal_ctd-tag/2009_2011_ct64_Casey_Macquarie/ct64-M746-09/IMOS_AATAMS-SATTAG_TSP_20100205T043000Z_ct64-M746-09_END-20101029T071000Z_FV00.nc'
dataset <- ncParse( file_URL)

## Load the aqfig and maps packages
library( aqfig)
library( maps)

## Extract data from variables
temp <- dataset$variables$TEMP$data
psal <- dataset$variables$PSAL$data
pres <- dataset$variables$PRES$data
index <- dataset$variables$parentIndex$data
lat <- round( dataset$variables$LATITUDE$data, 1)
lon <- round( dataset$variables$LONGITUDE$data, 1)
date <- dataset$variables$TIME$data

## Extract data from global and variable attributes
title <- dataset$metadata$title
templab <- gsub( '_', ' ', dataset$variables$TEMP$long_name)
datelab <- gsub( '_', ' ', dataset$variables$TIME$standard_name)
psallab <- gsub( '_', ' ', dataset$variables$PSAL$long_name)
preslab <- gsub( '_', ' ', dataset$variables$PRES$long_name)
latlab <- dataset$variables$LATITUDE$long_name
lonlab <- dataset$variables$LONGITUDE$long_name
tempunit <- gsub( '_', ' ', dataset$variables$TEMP$units)
psalunit <- gsub( '_', ' ', dataset$variables$PSAL$units)
presunit <- gsub( '_', ' ', dataset$variables$PRES$units)

## Creation of a temperature vector
tempsq <- seq( round( min( temp), 0), round( max( temp), 0), 0.1)
tsq <- matrix( ncol = 1, nrow = length( temp))
for (i in 1:length( temp)){
	tsq[i] <- which.min( abs( tempsq- round( temp[i], 1)))
}

## Creation of a date vector
dates <- c()
for (i in as.numeric( rownames( table( index)))){
	dates <- c( dates, as.numeric(rep( date[i], length( which(( index) == i)))))
}

## Creation of a sea surface salinity vector
sssal <- c()
for (i in as.numeric( rownames( table( index)))){
	sssal <- c( sssal, head( psal[which(( index) ==i )], n = 1L))
}

## Creation of a salinity vector
salsq <- seq( round( min( sssal), 2), round( max( sssal), 2), 0.01)
ssq <- matrix( ncol = 1, nrow = length( sssal))
for (i in 1:length( sssal)){
	ssq[i] <- which.min( abs( salsq- round( sssal[i], 1)))
}

## The longitude in the original dataset ranges from [-180 to 180].
## To deal with the international date line issue, we change the range of longitude values to [0 to 360].
for (i in 1:length( lon)){
	if ( lon[i] < 0) {lon[i] = lon[i] + 360}
}

## To deal with the international date line issue, we change the range of the map longitude values to [0 to 360].
map <- map( 'world', plot = F)
map2 <- map
map2$x <- map2$x +360
map$x <- c(map$x,map2$x)
map$y <- c(map$y,map2$y)

## Plot all the profiles of a time series
par( mar = c( 4.5, 4.5, 3, 4.5), cex=  1.2)
split.screen( c( 2, 1))
screen( 1)
plot( dates, -pres, col = colorRampPalette( c( "blue", "green", "yellow", "orange","red"))( length( tempsq))[tsq], type='n',xaxt = 'n',
xlab = datelab, ylab = paste( preslab, ' (negative dbar)', sep = ''), main = paste( dataset$metadata$species_name, ' - released in ', dataset$metadata$release_site, ' / animal reference number : ', dataset$metadata$unique_reference_code, sep = ''))
segments(x0 = dates[1:( length( dates) - 1)], y0 = -pres[1:( length( pres)-1)], x1 = dates[2: length( dates)], y1 = -pres[2:length( pres)], col = colorRampPalette( c( "blue", "green", "yellow", "orange","red"))( length( tempsq))[tsq])
axis.POSIXct( 1, at = seq( date[1], date[length(date)], by = 'months'), seq( date[1], date[length(date)], by = 'months'), format = '%b %Y')
mtext( paste( templab, ' ', '(', tempunit, ')', sep = ''), 4, line = 2.5)
vertical.image.legend( zlim = range( tempsq), colorRampPalette( c( "blue", "green", "yellow", "orange","red"))( length( tempsq)))
screen( 2)
par( mar = c( 4.5, 4.5, .5, 4.5), cex = 1.2)
plot( lon, lat, col = colorRampPalette( c( "blue", "green"))( length(salsq))[ssq], pch = 19, type = 'p', cex = .5, ylim= c(-80,-40),
xlab = lonlab, ylab = latlab)
segments(x0 = lon[1:( length( lon)-1)], y0 = lat[1:( length( lat)-1)], x1 = lon[2:length( lon)], y1 = lat[2:length(lat)], col = colorRampPalette( c( "blue", "green"))( length( salsq))[ssq], lwd = 2)
lines( map$x, map$y)
mtext( paste( psallab, ' ', '(', psalunit, ')', sep = ''), 4, line = 2.75)
vertical.image.legend (zlim = range( salsq), colorRampPalette( c( "blue", "green"))( length( salsq)))
close.screen( all = TRUE)

## Plot the temperature and salinity profiles
profile <- sample( seq(1, max( index)), 1) # Select a profile randomly

split.screen( c( 1, 2))
screen( 1)
plot( temp[which(( index) == profile)], -pres[which(( index) == profile)], xlab = paste( templab, ' ', '(', tempunit, ')', sep = ''), ylab = paste( preslab, ' (negative dbar)', sep = ''), type = 'b', pch = 19)
mtext( paste( title, '
', 'Lat/Lon = ', lat[profile], '/', lon[profile], '
', date[profile], ' UTC', sep = ''), side = 3, line = .5, at = max(temp[which(( index) == profile)]) + .15)
screen( 2)
plot( psal[which(( index) == profile)], -pres[which(( index) == profile)], xlab = paste( psallab, ' ', '(', psalunit, ')', sep = ''), ylab = '', type = 'b', pch = 19, bg = 'transparent')
close.screen( all = TRUE)