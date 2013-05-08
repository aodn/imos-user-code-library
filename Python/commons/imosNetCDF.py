#!/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Laurent Besnard
# Institute: IMOS / eMII
# email address: laurent.besnard@utas.edu.au
# Website: http://imos.aodn.org.au/imos/
# May 2013; Last revision: 5-May-2013
#
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License


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
   attVarName = dataset.ncattrs()
   attributsDic = {}#we start a dictionar
   nAtts = len(attVarName)
   for attVal in range(0, nAtts-1): 
      attributsDic [ attVarName[attVal] ] = getattr(dataset, attVarName[attVal])    
   return attributsDic


def convertTime(TIME):
# convertTime - convertTime converts a time variable from a netcdf4 object 
# into a python time object.
#
# The function uses the variable attribute 'units', usually written such as :
# 'days since ...' or 'seconds since ...' . The rest of the string is always
# written in the same way 'DD-MM-YYYY' (where DD=int(Day); MM=int(Month);
# YYYY=int(Year)) in order to convert the time properly
#
# Syntax: [output1,output2] = convertTime(input1,input2,input3)
#
# Inputs:
# TIME -  time variable from a netcdf4 object
#
# Outputs:
# time_corr - time object with corrected values
#
# Example:
# from netCDF4 import Dataset
# DATA = Dataset('netcdf_file_example.nc') 
# timeConverted = convertTime(acorn_DATA.variables['TIME'])
#
# Other python-files/library required: none
# Subfunctions: none
#
    from datetime import timedelta 
    import datetime,re,string 
    from pylab import * 
    attVarName = TIME.ncattrs()
    attVar_dic = {}#we start a dictionary
    for attVal in attVarName: 
        attVar_dic[ attVal ] = getattr(TIME, attVal)
    varData = TIME[:]   
    strOffset=attVar_dic['units']    
    pattern='[^0-9]*(\d{4})-(\d{2})-(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})*'
    [dateVec]=re.findall (pattern, strOffset)
    Y_off = int(dateVec[0])
    M_off = int(dateVec[1])
    D_off = int(dateVec[2])
    H_off = int(dateVec[3])
    MN_off= int(dateVec[4])
    S_off = int(dateVec[5])       
    if string.find(strOffset,'days') >= 0:
        time_uncorr = varData
        time_corr=[]
        for dayValue in time_uncorr:
            e = datetime.datetime(Y_off, M_off, D_off, H_off, MN_off, S_off) + timedelta(days=float(dayValue))
            time_corr.append(e)#Gregorian ordinal    
    elif  string.find(strOffset,'hours') >= 0:
        time_uncorr = varData
        time_corr = []
        for hoursValue in time_uncorr:
            e = datetime.datetime(Y_off, M_off, D_off, H_off, MN_off, S_off) + timedelta(hours=float(hoursValue))
            time_corr.append(e)#Gregorian ordinal
    elif  string.find(strOffset,'seconds') >= 0:
        time_uncorr = varData
        time_corr = []
        for secValue in time_uncorr:
            e = datetime.datetime(Y_off, M_off, D_off, H_off, MN_off, S_off) + timedelta(seconds=float(secValue))
            time_corr.append(e)#Gregorian ordinal
    time_corr = array(time_corr)
    varData = time_uncorr
    return time_corr
