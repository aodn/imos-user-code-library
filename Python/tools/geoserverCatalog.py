#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
geoserverCatalog.py
Collect files names from the AODN geoserver according to several arguments
Output a list of urls
Eduardo Klein. ekleins at gmail dot com
Last version 2020-03-11
"""

from __future__ import print_function

import sys
import argparse
from datetime import datetime

import pandas as pd


def args():
    parser = argparse.ArgumentParser(description="Get a list of urls from the AODN geoserver")
    parser.add_argument('-var', dest='varname', help='name of the variable of interest, like TEMP', default=None, required=False)
    parser.add_argument('-site', dest='site', help='site code, like NRMMAI',  type=str, default=None, required=False)
    parser.add_argument('-ft', dest='featuretype', help='feature type, like timeseries', default=None, required=False)
    parser.add_argument('-fv', dest='fileversion', help='file version, like 1', default=None, type=int, required=False)
    parser.add_argument('-ts', dest='timestart', help='start time like 2015-12-01', default=None, type=str, required=False)
    parser.add_argument('-te', dest='timeend', help='end time like 2018-06-30', type=str, default=None, required=False)
    parser.add_argument('-dc', dest='datacategory', help='data category like Temperature', type=str, default=None, required=False)
    parser.add_argument('-realtime', dest='realtime', help='indicates you also want realtime files', default=False, action="store_true", required=False)
    parser.add_argument('-exc', dest='filterout', help='regex to filter out the url list. Case sensitive', type=str, nargs='+',  default=None, required=False)
    parser.add_argument('-inc', dest='filterin', help='regex to include files in the url list. case sensitive', type=str, nargs='+', default=None, required=False)
    parser.add_argument('-url', dest='webURL', help='S3 -> amazon S3 prefix, opendap -> AODN OPeNDAP, thredds -> AODN HTML THREDDS server', type=str, default=None, required=False)

    vargs = parser.parse_args()
    return(vargs)


def get_moorings_urls(varname=None, site=None, featuretype=None, fileversion=None, datacategory=None, realtime=False, timestart=None, timeend=None, filterout=None, filterin=None, webURL='S3'):
    """
    get moorings file URLS from AODN geoserver
    :param varname: name of the variable, like TEMP
    :param site: ANMN site code, like NRSMAI
    :param featuretype: feature type, like timeseries
    :param fileversion: file version, like 1
    :param datacategory: data category like Temperature
    :param realtime: yes or no. If absent, all modes will be retrieved
    :param timestart: start time like 2015-12-01
    :param timeend: end time like 2018-06-30
    :param filterout: regex to filter out the url list. Case sensitive
    :param weburl: returns S#, opendap or wget url path root
    :return: list of URLs
    """

    
    if webURL == "opendap": 
        WEBROOT = 'http://thredds.aodn.org.au/thredds/dodsC/'
    elif webURL == "wget":
        WEBROOT = 'http://thredds.aodn.org.au/thredds/fileServer/'
    else:
        WEBROOT = 'https://s3-ap-southeast-2.amazon.com/imos-data/'
    
        
    if realtime:
        url = "http://geoserver-123.aodn.org.au/geoserver/ows?typeName=moorings_all_map&SERVICE=WFS&REQUEST=GetFeature&VERSION=1.0.0&outputFormat=csv&CQL_FILTER=(realtime=TRUE)"
    else:
        url = "http://geoserver-123.aodn.org.au/geoserver/ows?typeName=moorings_all_map&SERVICE=WFS&REQUEST=GetFeature&VERSION=1.0.0&outputFormat=csv&CQL_FILTER=(realtime=FALSE)"

    df = pd.read_csv(url)
    df = df.sort_values(by='time_coverage_start')
    criteria_all = df.url != None

    if varname:
        separator = ', '
        varnames_all = set(separator.join(list(df.variables)).split(', '))
        if varname in varnames_all:
            criteria_all = criteria_all & df.variables.str.contains('.*\\b'+varname+'\\b.*', regex=True)
        else:
            raise ValueError('ERROR: %s not a valid variable name' % varname)

    if site:
        site_all = list(df.site_code.unique())
        if site in site_all:
            criteria_all = criteria_all & df.site_code.str.contains(site, regex=False)
        else:
            raise ValueError('ERROR: %s is not a valid site code' % site)

    if featuretype:
        if featuretype in ["timeseries", "profile", "timeseriesprofile"]:
            criteria_all = criteria_all & (df.feature_type.str.lower() == featuretype.lower())
        else:
            raise ValueError('ERROR: %s is not a valid feature type' % featuretype)

    if datacategory:
        datacategory_all = list(df.data_category.str.lower().unique())
        if datacategory.lower() in datacategory_all:
            criteria_all = criteria_all & (df.data_category.str.lower() == datacategory.lower())
        else:
            raise ValueError('ERROR: %s is not a valid data category' % datacategory)

    if fileversion is not None:
        if fileversion in [0, 1, 2]:
            criteria_all = criteria_all & (df.file_version == fileversion)
        else:
            raise ValueError('ERROR: %s is not a valid file version' % fileversion)

    if timestart:
        try:
            criteria_all = criteria_all & (pd.to_datetime(df.time_coverage_end) >= datetime.strptime(timestart, '%Y-%m-%d'))
        except ValueError:
            raise ValueError('ERROR: invalid start date.')

    if timeend:
        try:
            criteria_all = criteria_all & (pd.to_datetime(df.time_coverage_start) <=  datetime.strptime(timeend, '%Y-%m-%d'))
        except ValueError:
            raise ValueError('ERROR: invalid end date.')

    if filterout is not None:
        for keyword in filterout:
            criteria_all = criteria_all & (~df.url.str.contains(keyword, regex=True))

    if filterin is not None:
        for keyword in filterin:
            criteria_all = criteria_all & (df.url.str.contains(keyword, regex=False))

    return list(WEBROOT + df.url[criteria_all])


if __name__ == "__main__":
    vargs = args()
    urls = get_moorings_urls(**vars(vargs))
    print(*urls, sep='\n')
