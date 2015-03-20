function layer_list = get_capability()
% reads the get capability from the IMOS geoserver and list all the active
% layers

config_geoserver;

% this bit overwrites variables from config_geoserver;
geoserver_request              = 'request=GetCapabilities';


get_unique_property_values_url = [geoserver_server_url '/ows?' geoserver_request '&' ...
                                    geoserver_service '&' geoserver_version  ];

filename_data                  = fullfile(dataWIP,'get_capability.xml');
urlwrite(get_unique_property_values_url,filename_data);


% the downloaded files is a XML which has to be parsed by the xml2struct toolbox
data                           = xml2struct( filename_data) ;
nVal                           = length(data.Children(1,3).Children);
layer_name                     = cell (nVal,1);
title                          = cell (nVal,1);


for i = 2 : nVal
    layer_name{i}                  = data.Children(1,3).Children(i).Children(1).Children.Data;
    title{i}                       = data.Children(1,3).Children(i).Children(2).Children.Data;
end

layer_list.layer_name          = layer_name;
layer_list.title               = title;

% delete CSV files
delete(filename_data)