% Example to download a csv file from the anmn_ctd_profiles_data layer filtering
% on time and cruise_id

config_geoserver; % load config_geoserver.m file. please modify first


% read the get capability feature from geoserver and retrieves a list of layers
layer_list = get_capability() ;


% Layer Name
layer_name               = 'imos:anmn_ctd_profiles_data';


% Get list of parameters where CQL filtering can be performed on
property_list            = get_property_list(layer_name);


% list unique values of properties
% unique_property_values = list_unique_property_values (layer_name , 'cruise_id') ; % not working for this layer. see Bug https://github.com/aodn/geoserver-layer-filter-extension/issues/12


% property filtering
cql_property             = create_property_cql('site_code', 'NRSYON');


% time filtering
time_start               = '2010-07-21T00:00:00Z';
time_end                 = '2014-07-28T00:00:00Z';
cql_filter_time          = create_time_sql(time_start,time_end,layer_name);


% Merge all filters. Order of cql filters does not matter
cql_filter               = create_cql_filter(cql_filter_time,cql_property);


% Create URL to download filtered data
getcapabilities_url      = create_download_url(layer_name,cql_filter);
filename_data            = fullfile(dataWIP,strcat(layer_name,'.csv'));
urlwrite(getcapabilities_url,filename_data)