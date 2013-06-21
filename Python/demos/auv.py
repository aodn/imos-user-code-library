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

from netCDF4 import Dataset, num2date
from matplotlib.pyplot import figure, xlabel, title, show

############# AUV
auv_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AUV/GBR201102/r20110301_012810_station1195_09_transect/hydro_netcdf/IMOS_AUV_ST_20110301T012815Z_SIRIUS_FV00.nc' 
auv_DATA = Dataset(auv_URL) 

TIME = auv_DATA.variables['TIME']
tempData = auv_DATA.variables['TEMP']
depthData = auv_DATA.variables['DEPTH']

timeData = num2date(TIME[:], TIME.units)

averageLat = auv_DATA.variables['LATITUDE'][:].mean()
averageLon = auv_DATA.variables['LONGITUDE'][:].mean()

figure1 = figure( figsize=(10, 7), dpi=80, facecolor='w', edgecolor='k')

ax1 = figure1.add_subplot(111)
ax1.plot(timeData,tempData[:], 'b-')
ax1.set_xlabel('time (s)')
# Make the y-axis label and tick labels match the line color.
ax1.set_ylabel(tempData.standard_name + ' in ' + tempData.units, color='b')
for tl in ax1.get_yticklabels():
    tl.set_color('b')


ax2 = ax1.twinx()
ax2.plot(timeData,depthData[:], 'r.')
ax2.set_ylabel(depthData.standard_name + ' in ' + depthData.units, color='r')
for tl in ax2.get_yticklabels():
    tl.set_color('r')


xlabel(TIME.standard_name)

title('campaign ' + auv_DATA.title +  '\nlocation:lat= ' + "%0.2f" % averageLat + '; lon='  + "%0.2f" % averageLon )
show()
