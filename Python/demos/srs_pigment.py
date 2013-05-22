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

############# BioOptic pigment
srs_pigment_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/pigment/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-pigment_END-19971207T220700Z_C-20121129T120000Z.nc' 
srs_pigment = Dataset(srs_pigment_URL) 
metadata = getAttNC(srs_pigment)

nProfiles = len(srs_pigment.dimensions['profile'])
# we choose the first profile
ProfileToPlot = 9 # this is arbitrary. We can plot all profiles from 0 to nProfiles
nObsProfile = srs_pigment.variables['rowSize'][ProfileToPlot] #number of observations for ProfileToPlot
timeProfile = convertTime(srs_pigment.variables['TIME'])[ProfileToPlot]
latProfile = srs_pigment.variables['LATITUDE'][ProfileToPlot]
lonProfile = srs_pigment.variables['LONGITUDE'][ProfileToPlot]

# we look for the observations indexes related to the choosen profile
indexObservationStart = sum( srs_pigment.variables['rowSize'][range(0,ProfileToPlot)]) 
indexObservationEnd = sum(srs_pigment.variables['rowSize'][range(0,ProfileToPlot+1)]) 
indexObservation = range(indexObservationStart,indexObservationEnd  )

cphl_aData = srs_pigment.variables['CPHL_a'][indexObservation] # for ProfileToPlot
depthData = srs_pigment.variables['DEPTH'][indexObservation]

figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
plot (cphl_aData,depthData)

title(metadata['source'] +  timeProfile.strftime('%d/%m/%Y') + '\nlocation:lat=' + "%0.2f" % latProfile + '; lon=' + "%0.2f" %lonProfile )
xlabel(srs_pigment.variables['CPHL_a'].long_name + ' in ' + srs_pigment.variables['CPHL_a'].units)
ylabel( srs_pigment.variables['DEPTH'].long_name + ' in ' +  srs_pigment.variables['DEPTH'].units + ';positive ' +  srs_pigment.variables['DEPTH'].positive )

plt.show()