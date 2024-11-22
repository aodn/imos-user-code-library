function url = create_download_url(layer_name,cql_filter)
% create_download_url concatenate the geoserver layer, as well as the CQL filter part
% the url can be directely past in CURL or a web browser

config_geoserver;
geoserver_layer_name_property = ['&typeName=' layer_name ];
url                           = strcat(geoserver_server_url, '/ows?', geoserver_service, '&', geoserver_version,'&', ...
                                        geoserver_request , '&',geoserver_layer_name_property,'&', ...
                                        geoserver_outputformat, '&', cql_filter);

end