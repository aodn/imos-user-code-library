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

############# FAIMMS
FAIMMS_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/FAIMMS/Myrmidon_Reef/Sensor_Float_1/water_temperature/sea_water_temperature@5.0m_channel_114/2012/QAQC/IMOS_FAIMMS_T_20121201T000000Z_FV01_END-20130101T000000Z_C-20130426T102459Z.nc' 
faimms_DATA = Dataset(FAIMMS_URL) 
metadata = getAttNC(faimms_DATA)

qcLevel = 1 # only good data are being used

TEMP = faimms_DATA.variables['TEMP'][:]
TEMP_qcFlag = faimms_DATA.variables['TEMP_quality_control']
index_qcLevel = where( TEMP_qcFlag[:,0,0] == qcLevel)


timeData = convertTime(faimms_DATA.variables['TIME'])[index_qcLevel]
tempData = TEMP[index_qcLevel[0][:],0,0]

figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
ax1 = subplot(111)
plot (timeData,tempData[:,])

title(metadata['title'] + '\n' + "%0.2f" % faimms_DATA.variables['TEMP'].sensor_depth + ' m depth' + '\nlocation:lat=' + "%0.2f" % faimms_DATA.variables['LATITUDE'][:] + '; lon=' + "%0.2f" % faimms_DATA.variables['LONGITUDE'][:] )
xlabel( faimms_DATA.variables['TIME'].long_name)
ylabel( faimms_DATA.variables['TEMP'].standard_name +' in ' + faimms_DATA.variables['TEMP'].units)

from matplotlib.dates import DAILY, DateFormatter, rrulewrapper, RRuleLocator
rule = rrulewrapper(DAILY,  interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)
ax1.xaxis.set_major_locator(loc)
ax1.xaxis.set_major_formatter(formatter)
labels = ax1.get_xticklabels()
setp(labels, rotation=30, fontsize=10)

plt.show()