# Example to plot SRS - BioOptical absorption
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 13-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/absorption/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-absorption-CDOM_END-19971207T180500Z_C-20121129T130000Z.nc'
dataset <- ncParse( file_URL)

## Select a single profile and its associated measurements
nprof <- dataset$dimensions$profile$data # Number of profiles in the NetCDF file
profile <- 10
nobs <- dataset$variables$rowSize$data[profile] # Number of observations for this profile
startobs <- sum( dataset$variables$rowSize$data[1 : ( profile - 1)]) + 1
endobs <- startobs + ( nobs -1)

## Extract data from variables and dimensions
date <- dataset$variables$TIME$data[profile]
lon <- dataset$variables$LONGITUDE$data[profile]
lat <- dataset$variables$LATITUDE$data[profile]
depth <- dataset$variables$DEPTH$data[startobs:endobs]
abscoeff <- dataset$variables$ag$data[,startobs:endobs]
wavelength <- dataset$dimensions$wavelength$data

## Extract data from global and variable attributes
abscoefflab <- gsub( '_', ' ', dataset$variables$ag$long_name)
wavelengthlab <- dataset$dimensions$wavelength$long_name
depthlab <- dataset$variables$DEPTH$long_name
abscoeffunit <- dataset$variables$ag$units
wavelengthunit <- dataset$dimensions$wavelength$units
depthunit <- dataset$variables$DEPTH$units

## Plot the variation in the volume absorption coefficient for different wavelengths and depths
plot( wavelength, abscoeff[,1], type = 'l', col = rainbow( n = ncol( abscoeff))[1], 
xlab = paste( wavelengthlab, ' (', wavelengthunit, ')', sep = ''), ylab = paste( abscoefflab, ' (', abscoeffunit, ')', sep = ''), main = paste( abscoefflab, ' (', abscoeffunit, ')', '
', ' station ', dataset$variables$station_name$data[profile], ' - Lat/Lon = ', round( lat, 1), '/', round( lon, 1), '
', date, ' UTC', sep = ''), xlim = c( 350, 850), ylim = c( 0, 0.25))
for (i in 2 : ncol( abscoeff)){
	lines( wavelength, abscoeff[,i], col = rainbow( n = ncol( abscoeff))[i])
}
legend( 775, 0.25, bty = 'n', paste( depthlab, ': ', depth, ' ', depthunit, sep =''),
lty = c(rep( 'solid', 6)), col = rainbow( n = ncol( abscoeff))[1:6])

########################### All profiles
## Load the raster package
library(raster)

## Create a raster of depth, wavelength and absorption coefficient data
dat1 <- list()
dat1$x <- dataset$variables$DEPTH$data
dat1$y <- dataset$dimensions$wavelength$data
dat1$z <- dataset$variables$ag$data
raster <- raster( dat1$z, xmn = range( dat1[[1]])[1], xmx = range( dat1[[1]])[2], ymn = range( dat1[[2]])[1], ymx = range( dat1[[2]])[2])
raster <- flip( t( raster), direction = 'x')

## Plot the variation in the volume absorption coefficient for all wavelengths and depths
par( mar = c(5.5, 4.5, 5.5, 4.5))
plot( extent( raster), bty = 'n', main = paste( dataset$metadata$source, sep = ''), 
xlab = paste( wavelengthlab, ' (', wavelengthunit, ')', sep = ''), ylab = paste( depthlab, ' (', depthunit, ')', sep = ''))
plot( raster, col = colorRampPalette( c( "blue", 'green', "yellow", "orange", "red"))( 255), add = T, zlim = c( 0, 0.25), cex.lab = 1.5,
legend.width = 1.5, legend.shrink = .75, legend.args = list( text = paste( abscoefflab, ' ', '(', abscoeffunit, ')', sep = ''), side = 4, line = 3, cex = 1.25),
axis.args = list( at = seq( 0, 0.25, 0.05), labels =  seq( 0, 0.25, 0.05)))