%% Example to plot a DWM dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

dwm_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/DWM/SOTS/Pulse/IMOS_DWM-SOTS_20110803T000000Z_PULSE_FV01_PULSE-8-2011_END-20120719T000000Z_C-20121009T214808Z.nc' ;
temp = ncread(dwm_URL,'TEMP_85_1');
time = double(ncread(dwm_URL,'TIME'));


nc_meta = ncinfo(dwm_URL);
metadata = cell2struct({nc_meta.Attributes.Value},{nc_meta.Attributes.Name},2);
abstract = metadata.abstract;
titlestr = metadata.title;

var_metadata = containers.Map({nc_meta.Variables.Name},{nc_meta.Variables(:).Attributes});
vstruct = var_metadata('TEMP_85_1');
var_att = containers.Map({vstruct.Name},{vstruct.Value});
sensor_depth = var_att('sensor_depth');

var_ind = find(strcmp({nc_meta.Variables.Name},'TEMP_85_1'));
xlabelname = nc_meta.Variables(var_ind).Dimensions.Name;
ylabelname = nc_meta.Variables(var_ind).Name;


time=time/24 + datenum(1950,1,1); %assumes hourly units and default calendar

fig = figure;
plot(time,temp,'b.','MarkerSize',10);
valid = ~isnan(temp);
plot(time(valid),temp(valid),'b');
title([titlestr ' at ' num2str(sensor_depth) ' m depth' ])
xlabel(xlabelname,'Interpreter','none')
ylabel(ylabelname,'Interpreter','none')
datetick('x',12)
