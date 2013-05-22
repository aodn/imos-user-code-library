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

######## GHRSST – L3P mosaic
srs_L3P_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/SRS-SST/L3P/2013/20130315-ABOM-L3P_GHRSST-SSTsubskin-AVHRR_MOSAIC_01km-AO_DAAC-v01-fv01_0.nc' 
srs_L3P_DATA = Dataset(srs_L3P_URL) 
metadata = getAttNC(srs_L3P_DATA)

step = 20 # we take one point out of 'step'. Only to make it faster to plot
sst = srs_L3P_DATA.variables['sea_surface_temperature'][0,::step,::step]
lat =srs_L3P_DATA.variables['lat'][::step]
lon = srs_L3P_DATA.variables['lon'][::step]
[lon_mesh,lat_mesh] = meshgrid(lon,lat)  #we create a matrix of similar size to be used afterwards with pcolor

figure1 =  figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
pcolor(lon_mesh,lat_mesh ,sst)

title( metadata['title'] + '-' +  metadata['start_date'] )
xlabel(srs_L3P_DATA.variables['lon'].long_name +  ' in ' + srs_L3P_DATA.variables['lon'].units)
ylabel(srs_L3P_DATA.variables['lat'].long_name +  ' in ' + srs_L3P_DATA.variables['lat'].units)

cbar = colorbar()
cbar.ax.set_ylabel(srs_L3P_DATA.variables['sea_surface_temperature'].long_name + '\n in ' + srs_L3P_DATA.variables['sea_surface_temperature'].units)
plt.show()