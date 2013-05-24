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
from numpy import ones, array, meshgrid
from matplotlib.pyplot import (figure, subplot, pcolor, clim, colorbar, title, 
                               xlabel, ylabel, plot, setp, show)
import matplotlib.colors as mcolors
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator

anmn_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANMN/WA/WATR50/Velocity/IMOS_ANMN-WA_VATPE_20120516T040000Z_WATR50_FV01_WATR50-1205-Workhorse-ADCP-498_END-20121204T021500Z_C-20121207T023956Z.nc' 
anmn_DATA = Dataset(anmn_URL) 

UCUR = anmn_DATA.variables['UCUR']
UCURqc = anmn_DATA.variables['UCUR_quality_control']
DEPTH = anmn_DATA.variables['HEIGHT_ABOVE_SENSOR']

# extract time values and convert into an array of datetime objects
TIME = anmn_DATA.variables['TIME']
timeData = num2date(TIME[:], TIME.units, TIME.calendar)

depthData = DEPTH[:]
uCurrentData = UCUR[:]

#it is a lot more relevant for ADCP data to plot the good and probably good data only (flags 1 and 2).
qcLevel = [1, 2]
qcIndex = ( UCURqc[:] == qcLevel[0]) | ( UCURqc[:] == qcLevel[1] )

# get the flag meaning values to add it later in the figure title
flag_meanings = (UCURqc.flag_meanings).split()

# we modify the mask 
uCurrentData.mask = ~qcIndex

# creation of a observation/profile variable  because pcolor can't handle a time object in the x axis
sizer = ones((1,len(depthData)),'float') 
profIndex = array(range(len(timeData)))
profIndex = profIndex.reshape(len(timeData),1) 
prof_2D =  profIndex * sizer
   
# we create a matrix of similar size to be used afterwards with pcolor  
[depthData_mesh,prof_2D_mesh] = meshgrid(depthData,profIndex)


# creation of a blue and red colormap centered in white
levs = range(64)
assert len(levs) % 2 == 0, 'N levels must be even.'

cmap = mcolors.LinearSegmentedColormap.from_list(name='red_white_blue', 
                                                 colors =[(0, 0, 1), 
                                                          (1, 1., 1), 
                                                          (1, 0, 0)],
                                                 N=len(levs)-1,
                                                 )
                                            
# plot adcp 
figure1 =figure( figsize=(13, 18), dpi=80, facecolor='w', edgecolor='k')
ax1 = subplot(211)

pcolor(prof_2D_mesh , depthData_mesh , uCurrentData[:,:,0,0],cmap=cmap)
clim(UCUR.valid_min, UCUR.valid_max)
cbar = colorbar()
cbar.ax.set_ylabel(UCUR.long_name + ' in ' + UCUR.units)

title(anmn_DATA.title + '\nplot of ' + flag_meanings[qcLevel[0]] + ' and ' + flag_meanings[qcLevel[1]] + ' only')
xlabel('Profile Index')
ylabel(DEPTH.long_name +' in ' + DEPTH.units)

# plot profile index with time 
ax2 = subplot(212)
plot(timeData,profIndex)
ylabel('Profile Index')
xlabel(anmn_DATA.variables['TIME'].long_name +' in DD/MM/YY')

rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)

ax2.xaxis.set_major_locator(loc)
ax2.xaxis.set_major_formatter(formatter)
labels = ax2.get_xticklabels()
setp(labels, rotation=30, fontsize=10)

show()
