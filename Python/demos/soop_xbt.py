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

#### XBT
xbt_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SOOP/SOOP-XBT/aggregated_datasets/line_and_year/IX1/IMOS_SOOP-XBT_T_20040131T195300Z_IX1_FV01_END-20041221T214400Z.nc'
xbt_DATA = Dataset(xbt_URL) 
metadata = getAttNC(xbt_DATA)

qcFlag = 4 # flag value to eliminate (bad data)

maxSample = len(xbt_DATA.variables['MAXZ'][:]) # 'maximum_number_of_samples_in_vertical_profile'
nProfiles = len(xbt_DATA.variables['INSTANCE'][:]) # number of profiles
 
import string, re 
## we look for all the profiles of a similar cruise
cruiseData = xbt_DATA.variables['cruise_ID'][:]
cruiseID = []
for iiCruise in range( len(cruiseData)) :
    cruiseID.append ( string.join(cruiseData[iiCruise,:]).replace(" ", ""))

uniqueCruiseIds = unique(cruiseID) 
cruiseToPlot = uniqueCruiseIds[5] #  'tb408504' , this is arbitrary. This value can be moified to plot the cruise of choice
indexCruiseToPlot = [item for item in range(len(cruiseID)) if cruiseID[item] == cruiseToPlot] 

TEMP = xbt_DATA.variables['TEMP']
DEPTH = xbt_DATA.variables['DEPTH']
TIME = xbt_DATA.variables['TIME']

# we load the data for each cruise
timeCruise =  convertTime(TIME)[indexCruiseToPlot]
latCruise =  xbt_DATA.variables['LATITUDE'][indexCruiseToPlot]
lonCruise =  xbt_DATA.variables['LONGITUDE'][indexCruiseToPlot]

# we load only the data which does not have a quality control value equal to qcFlag (see above)
indexGoodData = xbt_DATA.variables['TEMP_quality_control'][:,indexCruiseToPlot] != qcFlag
tempCruise =  TEMP[:,indexCruiseToPlot]
depthCruise = DEPTH[:,indexCruiseToPlot]


import numpy.ma as ma
# we modify the values which we don't want to plot to replace them with the Fillvalue
tempCruise[~indexGoodData] = xbt_DATA.variables['TEMP']._FillValue
depthCruise[~indexGoodData] = xbt_DATA.variables['DEPTH']._FillValue 
# we modify the mask in order to change the boolean, since some previous non Fillvalue data are now Fillvalue
tempCruise = ma.masked_values(tempCruise, xbt_DATA.variables['TEMP']._FillValue)
depthCruise = ma.masked_values(depthCruise, xbt_DATA.variables['DEPTH']._FillValue)

# creation of a profile array to use it with pcolor. same dimension of temp and depth
[nline, ncol] = shape(tempCruise)
sizer = ones((nline,1),'float') 
profileIndex = range(ncol)
prof_2D =  sizer * profileIndex 

##### creation of the plots
figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
# Profile timeseries 
subplot(311)
pcolor(prof_2D, -depthCruise, tempCruise)
cbar = colorbar()
cbar.ax.set_ylabel(TEMP.long_name + ' in ' + TEMP.units)
title(metadata['title'] + '\n Cruise  ' + cruiseToPlot + '-' + metadata['XBT_line_description'])
xlabel('Profile Index')
ylabel(DEPTH.long_name + ' in negative ' + DEPTH.units)

#plot the LON timesexbt_DATAries
ax3 = subplot(234)
plot(profileIndex,lonCruise)
xlabel('Profile Index')
ylabel(xbt_DATA.variables['LONGITUDE'].long_name + ' in ' + xbt_DATA.variables['LONGITUDE'].units)

#plot the LAT timeseries
ax4 = subplot(235)
plot(profileIndex,latCruise)
xlabel('Profile Index')
ylabel(xbt_DATA.variables['LATITUDE'].long_name  + ' in ' +  xbt_DATA.variables['LATITUDE'].units)

#plot the profile index with time values
# create the time label ticks
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator
rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)

ax5 = subplot(236)
plot(timeCruise,profileIndex)
ax5.xaxis.set_major_locator(loc)
ax5.xaxis.set_major_formatter(formatter)
labels = ax5.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel('Profile Index')

# plot of a single profile of this cruise
profileToPlot = 1  # this is arbitrary. We can plot all profiles from 1 to ncol, modify profileToPlot if desired

figure2 = figure(num=None, figsize=(13, 9.2), dpi=80, facecolor='w', edgecolor='k')
plot (tempCruise[:,profileToPlot],-depthCruise[:,profileToPlot])

xlabel(TEMP.long_name +' in ' +TEMP.units)
ylabel(DEPTH.long_name + ' in negative '  + DEPTH.units)

title(metadata['title'] +   '\n Cruise  ' + cruiseToPlot + '-' + metadata['XBT_line_description']+ '\nlocation ' + "%0.2f" % latCruise[profileToPlot] + '/' + "%0.2f" % lonCruise[profileToPlot] + '\n' + timeCruise[profileToPlot].strftime('%d/%m/%Y'))

plt.show()