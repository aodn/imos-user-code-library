#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Laurent Besnard
# Institute: IMOS / eMII
# email address: laurent.besnard@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# May 2013; Last revision: 20-May-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNUv3 General Public License

import numpy
from matplotlib.pyplot import (figure, subplot, pcolor, colorbar, title, 
                               xlabel, ylabel, plot, setp, show)
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator
from netCDF4 import Dataset, num2date


## AATAMS - Animal Tagging and Monitoring
aatams_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AATAMS/marine_mammal_ctd-tag/2009_2011_ct64_Casey_Macquarie/ct64-M746-09/IMOS_AATAMS-SATTAG_TSP_20100205T043000Z_ct64-M746-09_END-20101029T071000Z_FV00.nc'
aatams_DATA = Dataset(aatams_URL) 

nProfiles = len(aatams_DATA.dimensions['profiles']) # the number of profiles undertaken by the seal
parentIndex = aatams_DATA.variables['parentIndex'][:] #for each obs which profile it belongs to

# loading of the variable objects
TEMP = aatams_DATA.variables['TEMP']
PRES = aatams_DATA.variables['PRES']
PSAL = aatams_DATA.variables['PSAL']
TIME = aatams_DATA.variables['TIME']
LATITUDE = aatams_DATA.variables['LATITUDE']
LONGITUDE = aatams_DATA.variables['LONGITUDE']

# extract the temperature, pressure and salinity values
psalData = aatams_DATA.variables['PSAL'][:]
tempData = aatams_DATA.variables['TEMP'][:]
presData = aatams_DATA.variables['PRES'][:]

# We want to know the maximum number of observations (or depth level) per profile 
# for every profile. This number 'maxObsProfile' will be used to create 2-dimensional
# arrays for Temperature, salinity and pressure. 
maxObsProfile = 0
for profileNumber in range(1, nProfiles+1):
    nObs = sum(parentIndex == profileNumber)
    if nObs > maxObsProfile:
        maxObsProfile = nObs

# we create 2-d arrays to represent the profile variables
TEMP_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))
PSAL_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))
PRES_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))

for profileNumber in range(nProfiles):
    indexVar = numpy.where(parentIndex == profileNumber+1)
    nObs = numpy.size(indexVar)
    TEMP_DATA_reshaped[profileNumber,0:nObs] = tempData[indexVar]
    PSAL_DATA_reshaped[profileNumber,0:nObs] = psalData[indexVar]
    PRES_DATA_reshaped[profileNumber,0:nObs] = presData[indexVar]

# we load the latitude and longitude values for all the profiles
latProfile = LATITUDE[:]
lonProfile = LONGITUDE[:]

#longitude in the original dataset goes from -180 to +180
#For a nicer plot, we change the values to the [0 360] range
lonProfile[lonProfile < 0 ] = lonProfile[lonProfile < 0 ] +360 

# convert the time values into an array of datetime objects
timeData = num2date(TIME[:], TIME.units)   # one value per profile

# creation of a profile variable array
sizer = numpy.ones((1,maxObsProfile),'float') 
#observation = range(nProfiles)
profIndex = numpy.array(range(nProfiles))
profIndex = profIndex.reshape(nProfiles,1) 
prof_2D =  profIndex * sizer

## PLOT
#plot all the profiles as a timeseries
figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
subplot(311)
pcolor(prof_2D, -PRES_DATA_reshaped, TEMP_DATA_reshaped)
cbar = colorbar()
cbar.ax.set_ylabel(TEMP.long_name + ' in ' + TEMP.units)
title(aatams_DATA.species_name + ' - released in ' + aatams_DATA.release_site +
      ' \n animal reference number : ' + aatams_DATA.unique_reference_code)
xlabel('Profile Index')
ylabel(PRES.long_name + ' in negative ' + PRES.units)

rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)

#plot the LON timeseries
ax3 = subplot(234)
plot(timeData,lonProfile)
ax3.xaxis.set_major_locator(loc)
ax3.xaxis.set_major_formatter(formatter)
labels = ax3.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel(LONGITUDE.long_name + ' in ' + LONGITUDE.units)

#plot the LAT timeseries
ax4 = subplot(235)
plot(timeData,latProfile)
ax4.xaxis.set_major_locator(loc)
ax4.xaxis.set_major_formatter(formatter)
labels = ax4.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel(LATITUDE.long_name  + ' in ' +  LATITUDE.units)

#plot the profile index with time values
ax5 = subplot(236)
plot(timeData,profIndex)
ax5.xaxis.set_major_locator(loc)
ax5.xaxis.set_major_formatter(formatter)
labels = ax5.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel('Profile Index')

# plot of a single profile
# We can plot any profile from 0 to nProfiles-1, modify profileToPlot if desired
profileToPlot = 1
figure2 = figure(num=None, figsize=(7, 10), dpi=80, facecolor='w', edgecolor='k')
plot (TEMP_DATA_reshaped[profileToPlot,:],-PRES_DATA_reshaped[profileToPlot,:])
title('%s\nlocation %0.2f/%0.2f\n%s' % (aatams_DATA.title, 
                                        latProfile[profileToPlot], lonProfile[profileToPlot], 
                                        timeData[profileToPlot].strftime('%d/%m/%Y'))
)
xlabel(TEMP.long_name +  ' in ' + TEMP.units)
ylabel(PRES.long_name +  ' in negative ' + PRES.units)
show()
