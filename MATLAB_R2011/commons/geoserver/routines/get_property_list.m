function property_list = get_property_list(geoserver_layer_name)

config_geoserver;
geoserver_maxFeature          = '&maxFeatures=1';
geoserver_layer_name_property = ['&typeName=' geoserver_layer_name];

% download CSV header
get_properties_url            = [geoserver_server_url '/ows?' geoserver_service  '&' ...
                                geoserver_version  '&' geoserver_request '&' ...
                                geoserver_layer_name_property  '&' geoserver_maxFeature  '&' ...
                                geoserver_outputformat];

filename_data                 = fullfile(dataWIP,'properties.json');
urlwrite(get_properties_url,filename_data);

% read file header containing the column names
fid   = fopen(filename_data);
tline = fgetl(fid);
fclose(fid);

c             = textscan(tline,'%s','Delimiter',',');
cell_array    = c{1};

% find the following properties assumed to be not of any uses to users
index_boolean = find_indexes_str_in_cell(cell_array,'_b'); % boolean variables
index_lat     = find_indexes_str_in_cell(cell_array,'LATITUDE');
index_lon     = find_indexes_str_in_cell(cell_array,'LONGITUDE');
index_fid     = find_indexes_str_in_cell(cell_array,'FID');
index_geom    = find_indexes_str_in_cell(cell_array,'geom');

boolean_list  = (index_boolean |  index_lat | index_lon | index_lon |  index_fid | index_geom);

% list of properties to keep
property_list = cell_array( ~ismember(boolean_list, ones(length(cell_array),1)) );

% delete CSV file
delete(filename_data)

end

function indexes = find_indexes_str_in_cell(cell_array,str_to_find)
IndexC  = strfind(cell_array,str_to_find);
indexes = (not(cellfun('isempty', IndexC)));
end
