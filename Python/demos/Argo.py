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

from numpy import unique, ones, arange
from netCDF4 import Dataset, num2date
from matplotlib.pyplot import (figure, subplot, pcolor, colorbar, xlabel, ylabel, 
                               title, plot, setp, show)
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator

############# Argo
argo_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/Argo/aggregated_datasets/south_pacific/IMOS_Argo_TPS-20020101T000000_FV01_yearly-aggregation-South_Pacific_C-20121102T220000Z.nc' 
argo_DATA = Dataset(argo_URL) 

nProfData = len(argo_DATA.dimensions['N_PROF'])  #Number of profiles contained in the file.
nLevelData = len(argo_DATA.dimensions['N_LEVELS'])  #Maximum number of pressure levels contained in a profile.

TEMP_ADJUSTED = argo_DATA.variables['TEMP_ADJUSTED']
PRES_ADJUSTED = argo_DATA.variables['PRES_ADJUSTED']
LATITUDE = argo_DATA.variables['LATITUDE']
LONGITUDE = argo_DATA.variables['LONGITUDE']
JULD = argo_DATA.variables['JULD']

# Get the Argo float number (ID) for each profile...
profileFloatNumber = argo_DATA.variables['PLATFORM_NUMBER'][:]
# ... then find the unique ones to see which floats are in this file
uniqueFloatNumber = unique(profileFloatNumber)

argoFloatNumberChosen = 5900106   # we randomly chose one float number
# we load the data for this float

argoFloatProfilesIndexes = profileFloatNumber == argoFloatNumberChosen 
tempData = TEMP_ADJUSTED[argoFloatProfilesIndexes,:]
presData = PRES_ADJUSTED[argoFloatProfilesIndexes,:]
latProfile = LATITUDE[argoFloatProfilesIndexes]
lonProfile = LONGITUDE[argoFloatProfilesIndexes]
# convert the time values into an array of datetime objects
timeProfile = num2date(JULD[argoFloatProfilesIndexes], JULD.units)

# creation of a profile variable array
nProfForFloat = sum(argoFloatProfilesIndexes)
sizer = ones((1,nLevelData),'float') 
profIndex = arange(nProfForFloat)
profIndex = profIndex.reshape(nProfForFloat,1) 
prof_2D =  profIndex * sizer


figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
subplot(311)
pcolor(prof_2D, -presData, tempData)
cbar = colorbar()
cbar.ax.set_ylabel(TEMP_ADJUSTED.long_name + '\n in ' + TEMP_ADJUSTED.units)

xlabel('Profile Index')
ylabel(PRES_ADJUSTED.long_name + ' in negative ' + PRES_ADJUSTED.units)
title(argo_DATA.description + '\nArgo Float Number : %d' % argoFloatNumberChosen )

# format labels on time axis (for plots below)
rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)

# plot the LON timeseries
ax3 = subplot(234)
plot(timeProfile,lonProfile)
ax3.xaxis.set_major_locator(loc)
ax3.xaxis.set_major_formatter(formatter)
labels = ax3.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(JULD.long_name  + ' in dd/mm/yy' )
ylabel(LONGITUDE.long_name + ' in ' + LONGITUDE.units)

#plot the LAT timeseries
ax4 = subplot(235)
plot(timeProfile,latProfile)
ax4.xaxis.set_major_locator(loc)
ax4.xaxis.set_major_formatter(formatter)
labels = ax4.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(JULD.long_name  + ' in dd/mm/yy' )
ylabel(LATITUDE.long_name  + ' in ' +  LATITUDE.units)

#plot the profile index with time values
ax5 = subplot(236)
plot(timeProfile,profIndex)
ax5.xaxis.set_major_locator(loc)
ax5.xaxis.set_major_formatter(formatter)
labels = ax5.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(JULD.long_name  + ' in dd/mm/yy' )
ylabel('Profile Index')


# Plot of an arbitrary profile. Modify profileToPlot (between 0 and nProfiles-1) if desired.
profileToPlot = 1
figure2 = figure(num=None, figsize=(8, 10), dpi=80, facecolor='w', edgecolor='k')
plot (tempData[profileToPlot,:],-presData[profileToPlot,:])

title(argo_DATA.description + 
      '\nlocation %0.2f / %0.2f\n' % (latProfile[profileToPlot], lonProfile[profileToPlot]) + 
      timeProfile[profileToPlot].strftime('%d/%m/%Y'))

xlabel(TEMP_ADJUSTED.long_name +  ' in ' + TEMP_ADJUSTED.units)
ylabel(PRES_ADJUSTED.long_name +  ' in negative ' + PRES_ADJUSTED.units)

show()
