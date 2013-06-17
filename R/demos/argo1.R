# Example to plot Argo datasets - Example 1
#
# Comments : the ‘aqfig’ and ‘maps’ packages need to be installed and loaded.
#            in the R console, type:
#		install.packages("maps")
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

## Load the maps package
library( maps)

## Determines the number of profiles and observations and select a profile number randomly
nprof <- dataset$dimensions$N_PROF$data # Number of profiles in the NetCDF file
nlevel <- dataset$dimensions$N_LEVELS$data # Maximum number of pressure levels in the NetCDF file
profile <- sample( seq(1, max( nprof)), 1) # Random selection of a profile number

## Extract data from variables
temp <- dataset$variables$TEMP_ADJUSTED$data[,profile]
psal <- dataset$variables$PSAL_ADJUSTED$data[,profile]
depth <- dataset$variables$PRES_ADJUSTED$data[,profile]
lat <- dataset$variables$LATITUDE$data[profile]
lon <- dataset$variables$LONGITUDE$data[profile]
alllat <- dataset$variables$LATITUDE$data
alllon <- dataset$variables$LONGITUDE$data

## Extract data from global and variable attributes
date <- dataset$variables$JULD$data[profile]
templab <- dataset$variables$TEMP_ADJUSTED$long_name
psallab <- dataset$variables$PSAL_ADJUSTED$long_name
depthlab <- dataset$variables$PRES_ADJUSTED$long_name
latlab <- dataset$variables$LATITUDE$long_name
lonlab <- dataset$variables$LONGITUDE$long_name
tempunit <- dataset$variables$TEMP_ADJUSTED$units
psalunit <- dataset$variables$PSAL_ADJUSTED$units
depthunit <- dataset$variables$PRES_ADJUSTED$units

# Plot the temperature and salinity profiles
split.screen( c( 1, 2))
screen( 1)
par( mar = c( 5, 4, 4.5, 2))
plot( temp, -depth, xlab = paste( templab, ' ', '(', tempunit, ')', sep = ''), ylab = paste( depthlab, ' ', '(negative ', depthunit, ')', sep = ''), type = 'b', pch = 19)
mtext( paste( dataset$metadata$description, '
', 'Lat / Lon = ', round( lat, 1), ' / ', round( lon, 1), '
', date, ' UTC','
Argo float number: ', dataset$variables$PLATFORM_NUMBER$data[profile], sep = ''), side = 3, line = .5, at = 31)
screen( 2)
par( mar = c( 5, 4, 4.5, 2))
plot( psal, -depth, xlab = paste( psallab, ' ', '(', psalunit, ')', sep = ''), ylab = '', type = 'b', pch = 19, bg = 'transparent')
close.screen( all = TRUE)

# Plot Argo floats' trajectories
plot( alllon, alllat, pch = 3, col = dataset$variables$PLATFORM_NUMBER$data, xlab = lonlab, ylab = latlab, main = 'Trajectory of Argo floats in the South Pacific ocean in 2002')
map('world',fill=TRUE,add=T,col='grey')
