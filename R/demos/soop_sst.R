# Example to plot SOOP-SST datasets - Example 2
#
# Author: Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# June 2013; Last revision: 12-June-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

## Locate and parse NetCDF file
file_URL <- 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SOOP/SOOP-SST/VNSZ_Spirit-of-Tasmania-2/2013/IMOS_SOOP-SST_MT_20130511T000000Z_VNSZ_FV01_C-20130519T233008Z.nc'
dataset <- ncParse( file_URL)

## Select only data with good QC flags
flag_values <- unlist(strsplit(dataset$variables$TEMP$flags,split=','))
good_flags <- which((flag_values) == 'Z')  ## Select only data that have good flag values (i.e. 'Z' = 'Value_passed_all_tests')

## Extract data from variables
temp <- dataset$variables$TEMP$data[good_flags]
lat <- dataset$variables$LATITUDE$data[good_flags]
lon <- dataset$variables$LONGITUDE$data[good_flags]
date <- dataset$dimensions$TIME$data[good_flags]

## Extract data from global and variable attributes
templab <- dataset$variables$TEMP$long_name
latlab <- dataset$variables$LATITUDE$long_name
lonlab <- dataset$variables$LONGITUDE$long_name
datelab <- dataset$dimensions$TIME$long_name
tempunit <- dataset$variables$TEMP$units
latunit <- dataset$variables$LATITUDE$units
lonunit <- dataset$variables$LONGITUDE$units

## Plot the temperature time series and vessel's trajectory
split.screen( c( 2, 1))
screen( 1)
plot( date, temp, xlab = datelab, ylab = paste( templab, ' (', tempunit, ')', sep = ''), main = paste( dataset$metadata$title, ' from ', dataset$metadata$site, '
', ' Start / End dates: ', dataset$metadata$time_coverage_start, ' / ', dataset$metadata$time_coverage_end, '
', dataset$metadata$file_version, sep = ''), type = 'b', pch = 19)
screen( 2)
par( mar = c( 4.5, 4.5, 1, 2), cex=  1.2)
plot( lon, lat, xlab = paste( lonlab, ' (', lonunit, ')', sep = ''), ylab = paste( latlab, ' (', latunit, ')', sep = ''), type = 'b', pch = 19)
close.screen( all = T)