# Example to plot ACORN datasets
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ACORN/monthly_gridded_1h-avg-current-map_non-QC/TURQ/2012/IMOS_ACORN_V_20121001T000000Z_TURQ_FV00_monthly-1-hour-avg_END-20121029T180000Z_C-20121030T160000Z.nc.gz'
dataset <- ncParse( file_URL)

## Load the raster package
library( raster)

## Extract data from variables and dimensions
lat <- dataset$variables$LATITUDE$data
lon <- dataset$variables$LONGITUDE$data
speed <- dataset$variables$SPEED$data
udata <- dataset$variables$UCUR$data
vdata <- dataset$variables$VCUR$data
date <- dataset$dimensions$TIME$data

## Extract data from global and variable attributes
title <- dataset$metadata$title
latlab <- gsub( '_', ' ', dataset$variables$LATITUDE$long_name)
lonlab <- gsub( '_', ' ', dataset$variables$LONGITUDE$long_name)
speedlab <- gsub( '_', ' ', dataset$variables$SPEED$long_name)
speedunits <- gsub( '_', ' ', dataset$variables$SPEED$units)

## Create a raster of longitude, latitude and sea surface speed data
dat1 <- list( )
dat1$x <- c( lon)
dat1$y <- c( lat)
dat1$z <- speed[,,5]  # select sea surface speed values for the 5th time value.
raster <- raster( dat1$z, xmn = range( dat1[[2]])[1], xmx = range( dat1[[2]])[2], ymn = range( dat1[[1]])[1], ymx = range( dat1[[1]])[2])
raster <- t( raster)

## Sea water U and V velocity components
udata <- udata[,,5]  # select sea surface velocity U values for the 5th time value.
vdata <- vdata[,,5]  # select sea surface velocity V values for the 5th time value.
x1 <- c( lon) + c( udata)/5 # Divide u values by 5 to resize the length of the current directional arrow
y1 <- c( lat) + c( vdata)/5 # Divide v values by 5 to resize the length of the current directional arrow

## Determines latitudinal, longitudinal and depth ranges of those data
nas <- which( ( is.na ( c( dat1$z))) == TRUE)
xrange <- c( min( c( lon)[-nas]) - .2, max( c( lon)[-nas]) + .2)
yrange <- c ( min( c( lat)[-nas]) - .2, max( c( lat)[-nas]) + .2)
zrange <- c( min( speed[,,5], na.rm = TRUE), max( speed[,,5], na.rm = TRUE))

## Plot sea surface speed along with directional arrows 
plot( raster, col = colorRampPalette( c( "blue", 'green', "yellow", 'orange', "red"))( 255), main = paste( title, '
', date[5], sep = ''), xlab = lonlab, ylab = latlab, cex.lab = 1.5,
xlim = xrange, ylim = yrange, zlim = zrange, 
legend.width = 2, legend.shrink = .75, legend.args = list( text = paste( speedlab, ' ', '(', speedunits, ')', sep = ''), side = 4, line = 2.5, cex = 1.5),
axis.args = list( at = seq( round( min( speed[,,5], na.rm = TRUE),1), round( max( speed[,,5], na.rm = TRUE),1), .1), labels = seq( round( min( speed[,,5], na.rm = TRUE),1), round(max( speed[,,5], na.rm = TRUE),1), .1)))
arrows( dat1$x, dat1$y, x1, y1,length = 0.05)