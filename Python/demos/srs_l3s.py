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

######## GHRSST – L3S mosaic
srs_L3S_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/SRS-SST/L3S-01day/L3S_1d_night/2013/20130401152000-ABOM-L3S_GHRSST-SSTskin-AVHRR_D-1d_night-v02.0-fv01.0.nc.gz'
geoBoundaryBox = [165, 181, -50 ,-30] # [lon min , lonmax , latmin , latmax] . New Zealand
srs_L3S_DATA = Dataset(srs_L3S_URL) 
metadata = getAttNC(srs_L3S_DATA)

# load all the latitude and longitude values to find the indexes which will match geoBoundaryBox in order to subset the variables
latAll =srs_L3S_DATA.variables['lat'][:]
lonAll = srs_L3S_DATA.variables['lon'][:]
lonAll[lonAll<0] = lonAll[lonAll<0]+360 # modify the longitude values which are across the 180th meridian


indexLatToKeep = (latAll < geoBoundaryBox[3]) & (latAll > geoBoundaryBox[2])
indexLonToKeep = (lonAll < geoBoundaryBox[1]) & (lonAll > geoBoundaryBox[0])

sst = srs_L3S_DATA.variables['sea_surface_temperature'][0,indexLatToKeep,indexLonToKeep]
lat =latAll[indexLatToKeep]
lon = lonAll[indexLonToKeep]
land = srs_L3S_DATA.variables['l2p_flags'][0,indexLatToKeep,indexLonToKeep]  # land mask

[lon_mesh,lat_mesh] = meshgrid(lon,lat)#we create a matrix of similar size to be used afterwards with pcolor

figure1 =  figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
pcolor(lon_mesh,lat_mesh ,land != 2,cmap=plt.get_cmap('gray')) # see srsL3S_DATA.variables.l2p_flags.flag_meanings for more information: 2 == land
draw()
pcolor(lon_mesh,lat_mesh ,sst)
title( metadata['title'] + '-' +  metadata['start_time'] )
xlabel(srs_L3S_DATA.variables['lon'].long_name +  ' in ' + srs_L3S_DATA.variables['lon'].units)
ylabel(srs_L3S_DATA.variables['lat'].long_name +  ' in ' + srs_L3S_DATA.variables['lat'].units)

cbar = colorbar()
cbar.ax.set_ylabel(srs_L3S_DATA.variables['sea_surface_temperature'].long_name + '\n in ' + srs_L3S_DATA.variables['sea_surface_temperature'].units)
plt.show()