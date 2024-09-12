% Example to download a csv file from the abos_ts_timeseries_data layer filtering
% on time, geom, and deployment_code

config_geoserver; % load config_geoserver.m file. please modify first


% read the get capability feature from geoserver and retrieves a list of layers
layer_list = get_capability() ;


% Layer Name
layer_name             = 'imos:abos_ts_timeseries_data';


% Get list of parameters where CQL filtering can be performed on
property_list          = get_property_list(layer_name);


% list unique values of properties - can be long depending on layer
unique_property_values = list_unique_property_values (layer_name , 'deployment_code')


% property filtering
cql_property           = create_property_cql('deployment_code', 'EAC5-2012');


% geometry filtering POINT (155.2993 -27.102)
lon_lat_left_bottom    = [154,-35];
lon_lat_right_top      = [157,-20];
cql_filter_geom        = create_geom_cql(lon_lat_left_bottom,lon_lat_right_top);


% time filtering
time_start             = '2012-07-21T00:00:00Z';
time_end               = '2012-07-28T00:00:00Z';
cql_filter_time        = create_time_sql(time_start,time_end,layer_name);


% Merge all filters. Order of cql filters does not matter
cql_filter             = create_cql_filter(cql_filter_time,cql_property,cql_filter_geom);


% Create URL to download filtered data - without max feature
getcapabilities_url    = create_download_url(layer_name,cql_filter);
filename_data          = fullfile(dataWIP,strcat(layer_name,'.csv'));
urlwrite(getcapabilities_url,filename_data)