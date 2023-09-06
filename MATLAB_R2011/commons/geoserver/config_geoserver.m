geoserver_server_url   = 'http://geoserver-systest.aodn.org.au/geoserver';
geoserver_version      = 'version=1.0.0';
geoserver_outputformat = 'outputFormat=CSV';
geoserver_request      = 'request=GetFeature';
geoserver_service      = 'service=WFS';
geoserver_maxFeature   = 'maxFeatures=100';

dataWIP                = '/tmp/wms_testing'; %folder location where files will be downloaded. need to be modified by the user
mkpath(dataWIP)