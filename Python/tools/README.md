# Small tools to explore AODN data

## geoserverCatalog

This is a very handy tool that gives you the URLs of the AODN moorings facility files according to various arguments. You can re-direct the output to a text file. To download the data files using the retrieved URLs and `wget` you can ask for the AODN Amazon S3 prefix (default, recommended) with the argument `-url S3` or the AODN THREDDS server prefix with `-url thredds`. To open the files directly from the AODN OPeNDAP server, you can ask for the opendap prefix with `-url opendap`. Remeber to exclude (`-exc`) or include (`-inc`) the new LTSP products (aggregated, hourly, gridded).

```
usage: geoserverCatalog.py [-h] [-var VARNAME] [-site SITE] [-ft FEATURETYPE]
                           [-fv FILEVERSION] [-ts TIMESTART] [-te TIMEEND]
                           [-dc DATACATEGORY] [-realtime]
                           [-exc FILTEROUT [FILTEROUT ...]]
                           [-inc FILTERIN [FILTERIN ...]] [-url WEBURL]

Get a list of urls from the AODN geoserver

optional arguments:
  -h, --help            show this help message and exit
  -var VARNAME          name of the variable of interest, like TEMP
  -site SITE            site code, like NRMMAI
  -ft FEATURETYPE       feature type, like timeseries
  -fv FILEVERSION       file version, like 1
  -ts TIMESTART         start time like 2015-12-01
  -te TIMEEND           end time like 2018-06-30
  -dc DATACATEGORY      data category like Temperature
  -realtime             indicates you also want realtime files
  -exc FILTEROUT [FILTEROUT ...]
                        regex to filter out the url list. Case sensitive
  -inc FILTERIN [FILTERIN ...]
                        regex to include files in the url list. case sensitive
  -url WEBURL           S3 -> amazon S3 prefix, opendap -> AODN OPeNDAP,
                        thredds -> AODN HTML THREDDS server

```

--------------

