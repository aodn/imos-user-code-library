#!/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Laurent Besnard
# Institute: IMOS / eMII
# email address: laurent.besnard@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# May 2013; Last revision: 20-May-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

from netCDF4 import Dataset
from datetime import datetime, timedelta
from pylab import * 
import numpy
import matplotlib.pyplot as plt    
from imosNetCDF import *

## AATAMS - Animal Tagging and Monitoring
aatams_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AATAMS/marine_mammal_ctd-tag/2009_2011_ct64_Casey_Macquarie/ct64-M746-09/IMOS_AATAMS-SATTAG_TSP_20100205T043000Z_ct64-M746-09_END-20101029T071000Z_FV00.nc';
aatams_DATA = Dataset(aatams_URL) 
metadata = getAttNC(aatams_DATA)

nProfiles = len(aatams_DATA.dimensions['profiles']) # the number of profiles undertaken by the seal
parentIndex = aatams_DATA.variables['parentIndex'][:] #for each obs which profile it is linked to

# loading of the variable objects
TEMP = aatams_DATA.variables['TEMP']
PRES = aatams_DATA.variables['PRES']
PSAL = aatams_DATA.variables['PSAL']
TIME = aatams_DATA.variables['TIME']

# creation of a 2 dimension array for temperature, pressure and salinity  
psalData = aatams_DATA.variables['PSAL'][:]
tempData = aatams_DATA.variables['TEMP'][:]
presData = aatams_DATA.variables['PRES'][:]

# we want to know the maximum number of observations (or depth level) per profile 
# for all the profile. This number 'maxObsProfile' will be used to create a 2d 
# array for Temperature salinity and pressure. 
maxObsProfile = 0.
for profileNumber in range(1,nProfiles):
    indexVar = where(parentIndex == profileNumber)
    if size(indexVar) > maxObsProfile:
        maxObsProfile = size(indexVar)

# we recreate those variables to have a 2d array
TEMP_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))
PSAL_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))
PRES_DATA_reshaped = numpy.empty((nProfiles,maxObsProfile,))

for profileNumber in range(nProfiles):
    indexVar = where(parentIndex == profileNumber)
    TEMP_DATA_reshaped[profileNumber,0:size(indexVar)] = tempData[indexVar]
    PSAL_DATA_reshaped[profileNumber][range(0,size(indexVar))] = psalData[indexVar]
    PRES_DATA_reshaped[profileNumber][range(0,size(indexVar))] = presData[indexVar]

# we load the latitude and longitude values for all the profiles
latProfile =  numpy.array(aatams_DATA.variables['LATITUDE'][:])
lonProfile = numpy.array(aatams_DATA.variables['LONGITUDE'][:])

#longitude in the original dataset goes from -180 to +180
#For a nicer plot, we change the values to the [0 360] range
lonProfile[lonProfile < 0 ] = lonProfile[lonProfile < 0 ] +360 

# we convert the time values into a python time object
timeData = convertTime(TIME) # one value per profile

# creation of a profile variable array
sizer = ones((1,maxObsProfile),'float') 
#observation = range(nProfiles)
profIndex = array(range(nProfiles))
profIndex = profIndex.reshape(nProfiles,1) 
prof_2D =  profIndex * sizer

## PLOT
#plot all the profiles as a timeseries
figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
subplot(311)
pcolor(prof_2D, -PRES_DATA_reshaped, TEMP_DATA_reshaped)
cbar = colorbar()
cbar.ax.set_ylabel(TEMP.long_name + ' in ' + TEMP.units)
title(metadata['species_name'] + ' - released in ' + metadata['release_site'] +' \n animal reference number : ' + metadata['unique_reference_code'])
xlabel('Profile Index')
ylabel(PRES.long_name + ' in negative ' + PRES.units)

from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator
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
ylabel(aatams_DATA.variables['LONGITUDE'].long_name + ' in ' + aatams_DATA.variables['LONGITUDE'].units)

#plot the LAT timeseries
ax4 = subplot(235)
plot(timeData,latProfile)
ax4.xaxis.set_major_locator(loc)
ax4.xaxis.set_major_formatter(formatter)
labels = ax4.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel(aatams_DATA.variables['LATITUDE'].long_name  + ' in ' +  aatams_DATA.variables['LATITUDE'].units)

#plot the profile index with time values
ax5 = subplot(236)
plot(timeData,profIndex)
ax5.xaxis.set_major_locator(loc)
ax5.xaxis.set_major_formatter(formatter)
labels = ax5.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel('Profile Index')

#plot of a single profile
profileToPlot = 1# this is arbitrary. We can plot all profiles from 1 to nProfiles, modify profileToPlot if desired
figure2 = figure(num=None, figsize=(7, 10), dpi=80, facecolor='w', edgecolor='k')
plot (TEMP_DATA_reshaped[profileToPlot,:],-PRES_DATA_reshaped[profileToPlot,:])
title(metadata['title'] + '\nlocation ' + "%0.2f" % latProfile[profileToPlot] + '/' + "%0.2f" % lonProfile[profileToPlot] + '\n' + timeData[profileToPlot].strftime('%d/%m/%Y'))
xlabel(TEMP.long_name +  ' in ' + TEMP.units)
ylabel(PRES.long_name +  ' in negative ' + PRES.units)
plt.show()