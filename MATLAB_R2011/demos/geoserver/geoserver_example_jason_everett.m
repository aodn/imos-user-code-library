% User case - sent by Sebastien
% Jason Everett (Ecologist modeller at UNSW)
%
% Jason is using the altimetry gridded netCDF file produced by David Griffin.
% He has created a script (I think in matlab) to crawl the entire GSLA folder on the THREDDS catalogue and find new files. I am not sure how often he is running his script (once a day or once a week).
% During the ACOMO conference, he told me that he would be better if satellite netCDF filename do not contain the creation date.
% This is because the files are produced once a day but it is impossible to predict the correct filename as the creation data change for each file.
% That is why he has to crawl the THREDDS catalogue to look for new files and find their filenames before opening them.
%
% One solution to his problem would be to change the netCDF filenames and I guess it could be done if we work together with David Griffin.
%
% Another solution will be to use the WFS layer created by Guillaume to list all the files for each product and used by Gogoduck.
% Performing a simple query on this WFS layer using a filter on “time” will provide Jason with a list of URL’s.


config_geoserver; % load config_geoserver.m file. please modify first


% read the get capability feature from geoserver and retrieves a list of layers
layer_list = get_capability() ;


layer_name          = 'imos:gsla_nrt00_timeseries_url';


% Get list of parameters where CQL filtering can be performed on
property_list       = get_property_list(layer_name);


% time filtering
time_start          = '2015-01-21T00:00:00Z';
time_end            = '2015-02-28T00:00:00Z';
cql_filter_time     = create_time_sql(time_start,time_end,layer_name);


% Merge all filters. Order of cql filters does not matter
cql_filter          = create_cql_filter(cql_filter_time);


% Create URL to download filtered data - without max feature
getcapabilities_url = create_download_url(layer_name,cql_filter);
filename_data       = fullfile(dataWIP,strcat(layer_name,'.csv'));
urlwrite(getcapabilities_url,filename_data)   % url retrieved in the CSV aren't useful unless we change imos-t3 ... to www.