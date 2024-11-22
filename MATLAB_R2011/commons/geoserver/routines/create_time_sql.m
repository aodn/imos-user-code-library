function cql_filter_time = create_time_sql(time_start,time_end,layer_name)
% create_time_cql creates the time CQL filter part

property_list   = get_property_list(layer_name) ;

%% we look for the time variable srting. since this is not necessarely consistent across datasets
idxTIME         = strcmpi(property_list,'TIME') == 1;
TimeVarName     = property_list{idxTIME};

cql_filter_time = [TimeVarName ' >= ''' time_start ''' AND ' TimeVarName ' <= ''' time_end ''''];

