function cql_filter = create_cql_filter(varargin)
% create_cql_filter appends all differents filters created by a user
% ( see create_geom_cql , create_property_cql , create_time_cql ) into a
% CQL_FILTER url string used by geoserver

cql_filter = varargin{1};
for ii = 2 : nargin
    cql_filter = [cql_filter ' AND ' varargin{ii} ];
end


cql_filter = convert_str_hex(cql_filter); % only this part of the string has to be encoded
cql_filter = strcat('CQL_FILTER=',cql_filter);

end