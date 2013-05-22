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

############# ABOS
abos_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ABOS/SOTS/Pulse/IMOS_ABOS-SOTS_20110803T000000Z_PULSE_FV01_PULSE-8-2011_END-20120719T000000Z_C-20121009T214808Z.nc' 
abos_DATA = Dataset(abos_URL) 

tempDataStructure = abos_DATA.variables['TEMP_85_1']
TIME = abos_DATA.variables['TIME']

tempData = tempDataStructure[:]
timeData = convertTime(TIME) # one value per profile

metadata = getAttNC(abos_DATA)
abstract = metadata['abstract']

figure1 =figure( figsize=(10, 10), dpi=80, facecolor='w', edgecolor='k')
ax = subplot(111)
# we have to find the index for no nan values
indexNoNan = where( ~numpy.isnan(tempData))
plot(timeData[indexNoNan],tempData[indexNoNan])

xlabel(TIME.long_name  + ' in ' +  'dd/mm/yy' )
ylabel(tempDataStructure.standard_name + ' in ' + tempDataStructure.units)
title(metadata['title']  + '\nat ' +  "%0.2f" %tempDataStructure.sensor_depth + ' m depth' )

# time ticks
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator
rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)
ax.xaxis.set_major_locator(loc)
ax.xaxis.set_major_formatter(formatter)
labels = ax.get_xticklabels()
setp(labels, rotation=30, fontsize=10)
show()