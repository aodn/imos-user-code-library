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

from netCDF4 import Dataset, num2date
from numpy import arange, meshgrid
from matplotlib.pyplot import (figure, subplot, pcolor, clim, colorbar, title, 
                               xlabel, ylabel, plot, setp, show)
import matplotlib.colors as mcolors
from matplotlib.dates import MONTHLY, DateFormatter, rrulewrapper, RRuleLocator

# open the dataset
anmn_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANMN/WA/WATR50/Velocity/IMOS_ANMN-WA_VATPE_20120516T040000Z_WATR50_FV01_WATR50-1205-Workhorse-ADCP-498_END-20121204T021500Z_C-20121207T023956Z.nc' 
anmn_DATA = Dataset(anmn_URL) 

# create short-cuts to the variables we're interested in
UCUR = anmn_DATA.variables['UCUR']
UCURqc = anmn_DATA.variables['UCUR_quality_control']
HEIGHT = anmn_DATA.variables['HEIGHT_ABOVE_SENSOR']
TIME = anmn_DATA.variables['TIME']

# extract time values and convert into an array of datetime objects
timeData = num2date(TIME[:], TIME.units, TIME.calendar)

# extract height and eastward velocity values
heightData = HEIGHT[:]
uCurrentData = UCUR[:]
# Note: because UCUR has some missing values, this gives us a numpy
# MaskedArray object, which works the same way as a normal array,
# except missing values are automatically excluded from calculations
# and plots.

# it is a lot more relevant for ADCP data to plot the good and
# probably good data only (flags 1 and 2).
qcLevel = [1, 2]
qcIndex = ( UCURqc[:] == qcLevel[0]) | ( UCURqc[:] == qcLevel[1] )
# update the mask to exclude all but the good data data
uCurrentData.mask = ~qcIndex

# get the flag meaning values to add it later in the figure title
flag_meanings = (UCURqc.flag_meanings).split()

# create a profile index variable because pcolor can't handle datetime
# objects on the x axis
profIndex = arange(len(timeData))

# create a matrices of the coordinate variables (same shape as
# uCurrentData) to be used with pcolor
heightData_mesh, prof_2D_mesh = meshgrid(heightData, profIndex)


# creation of a blue and red colormap centered in white
levs = range(64)
assert len(levs) % 2 == 0, 'N levels must be even.'

cmap = mcolors.LinearSegmentedColormap.from_list(name='red_white_blue', 
                                                 colors =[(0, 0, 1), 
                                                          (1, 1., 1), 
                                                          (1, 0, 0)],
                                                 N=len(levs)-1,
                                                 )
                                            
# plot current profiles
figure1 =figure( figsize=(13, 18), dpi=80, facecolor='w', edgecolor='k')
ax1 = subplot(211)

pcolor(prof_2D_mesh , heightData_mesh , uCurrentData[:,:,0,0],cmap=cmap)
clim(UCUR.valid_min, UCUR.valid_max)
cbar = colorbar()
cbar.ax.set_ylabel(UCUR.long_name + ' in ' + UCUR.units)

title(anmn_DATA.title + '\nplot of ' + flag_meanings[qcLevel[0]] + 
      ' and ' + flag_meanings[qcLevel[1]] + ' only')
xlabel('Profile Index')
ylabel(HEIGHT.long_name +' in ' + HEIGHT.units)

# plot profile index with time 
ax2 = subplot(212)
plot(timeData,profIndex)
ylabel('Profile Index')
xlabel(anmn_DATA.variables['TIME'].long_name +' in DD/MM/YY')

# format date ticks
rule = rrulewrapper(MONTHLY, bymonthday=1, interval=1)
formatter = DateFormatter('%d/%m/%y')
loc = RRuleLocator(rule)
ax2.xaxis.set_major_locator(loc)
ax2.xaxis.set_major_formatter(formatter)
labels = ax2.get_xticklabels()
setp(labels, rotation=30, fontsize=10)

show()
