#!/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Laurent Besnard
# Institute: IMOS / eMII
# email address: laurent.besnard@utas.edu.au
# Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
# Aug 2014; Last revision: 26-August-2013
#
# Copyright 2014 IMOS
# The script is distributed under the terms of the GNUv3 General Public License

# This script purpose is to provide a tool to users who want to plot a timeseries at
# a given location, from a NetCDF gridded file created by the AODAAC directly from the
# imos portal 123 portal-123.aodn.org.au . 
# The AODAAC is a tool implemented in the 123 portal that allows data products 
# to be partitioned temporally and spatially as well as aggregated into a single file.
# It allows users to create aggregations by selecting various constraints, i.e. date 
# and area of interest directly through the IMOS portal.
# This script can then handle the aggregated file downloaded by the user
# see http://help.aodn.org.au/help/?q=node/67 to learn more about how to use

# It asks for a longitude and latitude values, and return if there is any data available 
# a plot, as well as a csv file
#
#if __name__ == "__main__":
import numpy
from netCDF4 import Dataset, num2date
from matplotlib.pyplot import figure,  plot, xlabel, ylabel, title, setp, show
import matplotlib.pyplot
import csv
from Tkinter import Tk
from tkFileDialog import askopenfilename

#	try:
	# Box Dialog to select an AODAAC file
Tk().withdraw() # we don't want a full GUI, so keep the root window from appearing
srs_AODAAC_URL=askopenfilename(filetypes=[("NetCDF file","*.nc")])
srs_AODAAC_DATA = Dataset(srs_AODAAC_URL) 



# Look for the Variable names in the NetCDF file. 
# There is CURRENTLY always ONLY 1 main Var in the AODAAC file
for v in srs_AODAAC_DATA.variables: 
	if v[0:3].lower() == 'LAT'.lower():
		latName = v
	elif v[0:3].lower() == 'LON'.lower():
		lonName = v
	elif v[0:3].lower() == 'tim'.lower():
		timeName = v
	else :
		mainVarName = v


# loading the data into arrays
mainVar = srs_AODAAC_DATA.variables[mainVarName]
lat =srs_AODAAC_DATA.variables[latName]
lon = srs_AODAAC_DATA.variables[lonName]
TIME = srs_AODAAC_DATA.variables[timeName]
timeData = num2date(TIME[:], TIME.units)

# look for the bounding box values
lat_min = lat[0]
lat_max = lat[-1]
lon_min = lon[0]
lon_max = lon[-1]

print ('Latitude and longitude values to get a timseries plot at the wanted location') 

# Not checking if values entered by the user are numbers. We assume the user wants to make 
# this code run, and not try to kill it

# prompt Lon
prompt_text_Lon = 'Enter longitude value between ' + str(min(lon)) + ' and '+ str(max(lon)) + ": "
input_Lon = raw_input(prompt_text_Lon)
while (float(input_Lon) <  min(lon) ) or (float(input_Lon) >  max(lon) ):
	prompt_text_Lon = 'Enter longitude value between ' + str(min(lon)) + ' and '+ str(max(lon)) + ": "
	input_Lon = raw_input(prompt_text_Lon)
	
# prompt Lat
prompt_text_Lat = 'Enter latitude value between ' + str(min(lat)) + ' and '+ str(max(lat)) + ": "
input_Lat = raw_input(prompt_text_Lat)
while ((float(input_Lat) <  min(lat) ) or (float(input_Lat) >  max(lat) )):
	prompt_text_Lat = 'Enter latitude value between ' + str(min(lat)) + ' and '+ str(max(lat)) + ": "
	input_Lat = raw_input(prompt_text_Lat)

lon_index = int((float(input_Lon)-lon_min)*lon.size/(lon_max - lon_min ))-1
lat_index = int((float(input_Lat)-lat_min)*lat.size/(lat_max - lat_min ))-1

# load timeseries data at the requested location
mainVar_values = mainVar[:,lat_index,lon_index]

# this is a test to check if the mainVar_values array is full of fillvalue or no, ie masked
nValues = 0 # just to initiate

try:
	test_nGoodValues = mainVar_values[~mainVar_values.mask].size
	if test_nGoodValues == 0:
		# Bail
		print  'There is no data at the selected point'
		exit()
	else:
		timeData_unmasked = timeData[~mainVar_values.mask]
		mainVar_values_unmasked = mainVar_values[~mainVar_values.mask]
		nValues = mainVar_values[~mainVar_values.mask].size
except:
	timeData_unmasked = timeData
	mainVar_values_unmasked = mainVar_values
	nValues = mainVar_values.size

if nValues != 0:
	## save timeseries at point in CSV
	csvFilename =  srs_AODAAC_URL[0:-3] + '_lat_' +str(input_Lat) + '_lon_' +str(input_Lon) + '.csv'
	with open(csvFilename,'w') as outputfile:
		wrtr = csv.writer(outputfile, delimiter=',', quotechar='"')
		a = (TIME.long_name,mainVar.long_name +  ' in ' + mainVar.units)
		wrtr.writerow(a) 
		for index in range(nValues) :
			a = (timeData_unmasked[index].strftime('%Y-%m-%d %H:%M:%S'),mainVar_values_unmasked[index])
			wrtr.writerow(a) 
	print ('CSV ouput to ' + csvFilename) 


	# Plot of the timeseries
	figure1 =  figure(num=None, figsize=(15, 10), dpi=80, facecolor='w', edgecolor='k')
	plot (timeData,mainVar_values)

	try :
		title(srs_AODAAC_DATA.title + '-' +  srs_AODAAC_DATA.DSD_entry_id)
	except :
		pass

	try :
		xlabel(TIME.long_name )
	except :
		pass

	try :
		ylabel(mainVar.long_name +  ' in ' + mainVar.units)
	except :
		pass

	show()
	exit()
else:
	print 'There is no data at the selected point'
	exit()