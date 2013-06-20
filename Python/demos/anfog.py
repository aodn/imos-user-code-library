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


from numpy import where
from netCDF4 import Dataset, num2date
from matplotlib.pyplot import figure, xlabel, ylabel, title, show

############# ANFOG
anfog_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANFOG/seaglider/SOTS20110420/IMOS_ANFOG_BCEOSTUV_20110420T111022Z_SG517_FV01_timeseries_END-20110420T140511Z.nc' 
anfog_DATA = Dataset(anfog_URL) 

TIME = anfog_DATA.variables['TIME']
PSAL = anfog_DATA.variables['PSAL']
DEPTH =  anfog_DATA.variables['DEPTH']
PSAL_qcFlag = anfog_DATA.variables['PSAL_quality_control']

# convert the time values into an array of datetime objects
timeData = num2date(TIME[:], TIME.units)

qcLevel = 1 # we use the quality control flags to only select the good_data
index_qcLevel = where( PSAL_qcFlag[:] == qcLevel)

psalData = PSAL[index_qcLevel] 
timeData = timeData[index_qcLevel]
depthData = DEPTH[index_qcLevel]


# plot depth and salinity timeseries
figure1 = figure( figsize=(13, 10), dpi=80, facecolor='w', edgecolor='k')

ax1 = figure1.add_subplot(111)
ax1.plot(timeData,psalData, 'b-')
ax1.set_title(anfog_DATA.title +  ' starting at ' + anfog_DATA.time_coverage_start  + 'UTC')
ax1.set_xlabel(TIME.standard_name)
# Make the y-axis label and tick labels match the line color.
ax1.set_ylabel(PSAL.standard_name + ' in ' + PSAL.units, color='b')
for tl in ax1.get_yticklabels():
    tl.set_color('b')

ax2 = ax1.twinx()
ax2.plot(timeData,depthData, 'r.')
ax2.set_ylabel(DEPTH.standard_name + ' in ' + DEPTH.units, color='r')
for tl in ax2.get_yticklabels():
    tl.set_color('r')

show()
