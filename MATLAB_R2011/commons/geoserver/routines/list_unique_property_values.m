function unique_property_values = list_unique_property_values (geoserver_layer_name , property)
% list_unique_property_values reads a property/column field from geoserver, and retrieves
% all its unique values, string or numerical. This is a new service from the IMOS geoserver
% plugin : https://github.com/aodn/geoserver-layer-filter-extension

config_geoserver;

% this bit overwrites variables from config_geoserver;
geoserver_request              = 'request=uniqueValues';
geoserver_service              = 'service=layerFilters';
geoserver_layer_name           = ['layer=' geoserver_layer_name];
geoserver_property_name        = ['propertyName=' property];

get_unique_property_values_url = [geoserver_server_url '/wms?' geoserver_request '&' ...
                                    geoserver_service '&' geoserver_version '&'...
                                    geoserver_layer_name  '&' geoserver_property_name];

filename_data                  = fullfile(dataWIP,'property_values.xml');
urlwrite(get_unique_property_values_url,filename_data);

% the downloaded files is a XML which has to be parsed by the xml2struct toolbox
data                           = xml2struct( filename_data) ;
nVal                           =length(data.Children);
unique_property_values         = cell (nVal,1);

for i = 1 : nVal
    unique_property_values{i} = data.Children(i).Children.Data;
end

% delete CSV files
delete(filename_data)

end