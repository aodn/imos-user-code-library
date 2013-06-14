# Example to plot SOOP-XBT datasets - Example 1
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SOOP/SOOP-XBT/aggregated_datasets/line_and_year/IX1/IMOS_SOOP-XBT_T_20040131T195300Z_IX1_FV01_END-20041221T214400Z.nc'
dataset <- ncParse( file_URL)

## Select only data with QC flags of 1 or 2 for the first XBT profile recorded during cruise_id 'tb408504'.
cruiseid <- which(( dataset$variables$cruise_ID$data) == 'tb408504') # List all profiles recorded during cruise_id 'tb408504'
cruiseid1 <- cruiseid[1] # Select only the first XBT profile recorded during cruise_id 'tb408504'
qcLevel1 <- 1
qcLevel2 <- 2

## Extract data from variables
temp <- dataset$variables$TEMP$data[cruiseid1,]
depth <- dataset$variables$DEPTH$data[cruiseid1,]
tempflags <- dataset$variables$TEMP$flags[cruiseid1,]
temp <- temp[c( which(( tempflags) == qcLevel1), which(( tempflags) == qcLevel2))]
depth <- depth[c( which(( tempflags) == qcLevel1), which(( tempflags) == qcLevel2))]
lat <- round( dataset$variables$LATITUDE$data[cruiseid1], 1)
lon <- round( dataset$variables$LONGITUDE$data[cruiseid1], 1)
date <- dataset$variables$TIME$data[cruiseid1]

## Extract data from global and variable attributes
title <- dataset$metadata$title
templab <- dataset$variables$TEMP$long_name
depthlab <- dataset$variables$DEPTH$long_name
lonlab <- dataset$variables$LONGITUDE$long_name
latlab <- dataset$variables$LATITUDE$long_name
tempunit <- dataset$variables$TEMP$units
depthunit <- dataset$variables$DEPTH$units

# Plot the XBT temperature profile
par( mar = c( 5, 4.5, 5, 2))
plot( temp, -depth, main = paste( title, '
', 'Cruise ', dataset$variables$cruise_ID$data[cruiseid1], '
', 'Lat / Lon = ', lat, ' / ', lon, '
', date, sep = ''), xlab = paste( templab, ' ', '(', tempunit, ')', sep = ''), ylab = paste( depthlab, ' ', '(negative ', depthunit, ')', sep = ''), type = 'l')
abline( h = 0, lty = 'dashed')

########################### All profiles
## Load the raster package
library( raster)

## Extract data from variables
temp <- dataset$variables$TEMP$data[cruiseid,]
depth <- dataset$variables$DEPTH$data[cruiseid,]
tempflags <- dataset$variables$TEMP$flags[cruiseid,]
lat <- round( dataset$variables$LATITUDE$data[cruiseid], 1)
lon <- round( dataset$variables$LONGITUDE$data[cruiseid], 1)
date <- dataset$variables$TIME$data[cruiseid]

## Select only temperature and depth data with QC flags of 1 or 2
for (i in 1:nrow( temp)){
	for (j in 1:length(tempflags[i,])){
	if((tempflags[i,j]) == qcLevel1 || (tempflags[i,j])==qcLevel2) temp[i,j] <- temp[i,j] else temp[i,j] <- NA
	if((tempflags[i,j]) == qcLevel1 || (tempflags[i,j])==qcLevel2) depth[i,j] <- depth[i,j] else depth[i,j] <- NA
	}
}

## Create a raster of date, depth and temperature data
dat1 <- list( )
dat1$x <- as.numeric( date)
dat1$y <- - depth
dat1$z <- t( temp)
raster <- raster( dat1$z, xmn = min( dat1[[1]]), xmx = max( dat1[[1]]), ymn = min( dat1[[2]], na.rm = T), ymx = max( dat1[[2]], na.rm = T))

## Plot all temperature profiles along with the vessel's trajectory
split.screen( c( 2, 1))
screen( 1)
par( mar = c( 4.5, 4.5, 3, 5), cex=  1.2)
plot( extent( raster), xaxt = 'n', xlab = 'Time', ylab = paste( depthlab, ' (negative dbar)', sep = ''), main = paste( title, '
', 'Cruise ', dataset$variables$cruise_ID$data[cruiseid1], sep = ''), ylim = c( -1000, 0), bty = 'n')
axis.POSIXct( 1, seq( date[1], date[length( date)], by = 'days'), format = '%d %b %Y')
mtext( paste( templab, ' ', '(', tempunit, ')', sep = ''), 4.75, line = 2.5)
plot( raster, col = colorRampPalette( c( "blue", 'green', "yellow", 'orange', "red"))( 255), add = T, legend.width = 2, legend.shrink = .75)
screen( 2)
par( mar = c( 4.5, 4.5, 3, 5), cex=  1.2)
plot( lon, lat, pch = 19, type = 'b', xlab = lonlab, ylab = latlab, main = paste('Cruise ', dataset$variables$cruise_ID$data[cruiseid1], sep = ''))
close.screen( all = TRUE)