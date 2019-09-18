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
from numpy import meshgrid
from matplotlib.pyplot import (figure, pcolor, colorbar, plot, xlabel, ylabel, 
                               title, legend, show)
from six.moves import range

############# BioOptic absorption
srs_absorption_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/absorption/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-absorption-CDOM_END-19971207T180500Z_C-20121129T130000Z.nc'
srs_absorption = Dataset(srs_absorption_URL) 

nProfiles = len(srs_absorption.dimensions['profile'])
# we choose the first profile
ProfileToPlot = 9 # this is arbitrary. We can plot all profiles from 0 to nProfiles
nObsProfile = srs_absorption.variables['rowSize'][ProfileToPlot] #number of observations for ProfileToPlot
TIME = srs_absorption.variables['TIME']
timeProfile = num2date(TIME[ProfileToPlot], TIME.units)  # convert time to a datetime object
latProfile = srs_absorption.variables['LATITUDE'][ProfileToPlot]
lonProfile = srs_absorption.variables['LONGITUDE'][ProfileToPlot]

# we look for the observations indexes related to the choosen profile
indexObservationStart = sum( srs_absorption.variables['rowSize'][list(range(0,ProfileToPlot))]) 
indexObservationEnd = sum(srs_absorption.variables['rowSize'][list(range(0,ProfileToPlot+1))]) 
indexObservation = list(range(indexObservationStart,indexObservationEnd))

agData = srs_absorption.variables['ag'][indexObservation,:]
wavelengthData = srs_absorption.variables['wavelength']
depthData = srs_absorption.variables['DEPTH'][indexObservation]

#we create a matrix of similar size to be used afterwards with pcolor
[wavelengthData_mesh,depthData_mesh] = meshgrid(wavelengthData,depthData)

figure1 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
pcolor(wavelengthData_mesh , depthData_mesh , agData)
cbar = colorbar()
cbar.ax.set_ylabel(srs_absorption.variables['ag'].long_name + '\n in ' + srs_absorption.variables['ag'].units)


title(srs_absorption.source)
xlabel( srs_absorption.variables['wavelength'].long_name + ' in: ' + srs_absorption.variables['wavelength'].units)
ylabel(srs_absorption.variables['DEPTH'].long_name + ' in ' + srs_absorption.variables['DEPTH'].units + '; positive '+srs_absorption.variables['DEPTH'].positive )


##
nDepth = len(depthData)
figure2 = figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')

labels = []
for iplot in range(agData.shape[0]):
    plot(wavelengthData[:],agData[iplot,:],'x')
    labels.append(r'Depth = %i m' % depthData[iplot])
    
legend(labels,loc='upper right')

ylabel(srs_absorption.variables['ag'].long_name + ' in: ' + srs_absorption.variables['ag'].units)
xlabel( srs_absorption.variables['wavelength'].long_name + ' in: ' + srs_absorption.variables['wavelength'].units)

title(srs_absorption.variables['ag'].long_name + 'in units:' + srs_absorption.variables['ag'].units + '\nstation :' +  '\nlocation:lat=' + "%0.2f" % latProfile + '; lon=' + "%0.2f" %lonProfile  + timeProfile.strftime('%d/%m/%Y') )

show()
