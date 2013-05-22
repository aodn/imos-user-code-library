#!/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Laurent Besnard
# Institute: IMOS / eMII
# email address: laurent.besnard@utas.edu.au
# Website: http://imos.aodn.org.au/imos/
# May 2013; Last revision: 21-May-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License

from netCDF4 import num2date


def getAttNC(dataset):
# getAttNC - harvest all the metadata from a NetCDF dataset object into a
# dictionnary

# Syntax: attributsDic = getAttNC(dataset)
#
# Inputs:
# dataset -  netcdf4 object
#
# Outputs:
# attributsDic - dictionnary of metadata
#
# Example:
# from netCDF4 import Dataset
# DATA = Dataset('netcdf_file_example.nc') 
# metadata = getAttNC(DATA)
#
   return dataset.__dict__


def convertTime(TIME):
# convertTime - converts a time variable from a netCDF4 Dataset object 
# into an array of datetime objects.
#
# The function uses the variable attribute 'units', usually written such as :
# 'days since ...' or 'seconds since ...' . The rest of the string is always
# written in the same way 'DD-MM-YYYY' (where DD=int(Day); MM=int(Month);
# YYYY=int(Year)) in order to convert the time properly
#
# See help on netCDF4.num2date for more details.
#
# Syntax: timeValues = convertTime(TIME)
#
# Inputs: TIME - time variable from a netCDF4 Dataset object. Must
# have a 'units' attribute, and optionally a 'calendar' attribute
# (otherwise 'standard' is assumed, which is a mixed Julian/Gregorian
# calendar).
#
# Outputs:
# timeValues - numpy array of datetime objects
#
# Example:
# from netCDF4 import Dataset
# DATA = Dataset('netcdf_file_example.nc') 
# timeConverted = convertTime(DATA.variables['TIME'])
#
# Other python-files/library required: netCDF4
# Subfunctions: none

   if 'calendar' in TIME.ncattrs():
      calendar = TIME.calendar
   else:
      calendar = 'standard'

   return num2date(TIME, TIME.units, calendar)
