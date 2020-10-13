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
dwm_DATA = ncParse(dwm_URL) ;
 
tempDataStructure = dwm_DATA.variables.TEMP_85_1;
tempData = tempDataStructure.data;
timeData = dwm_DATA.dimensions.(char(tempDataStructure.dimensions)).data;
 
abstract = dwm_DATA.metadata.abstract;
 
figure1 = figure;set(figure1,'Color',[1 1 1]);%please resize the window manually
plot (timeData,tempData)
title([dwm_DATA.metadata.title ' at ' num2str(tempDataStructure.sensor_depth) ' m depth' ])
xlabel([strrep(dwm_DATA.dimensions.(char(tempDataStructure.dimensions)).long_name,'_', ' ')])
ylabel([strrep( tempDataStructure.standard_name,'_', ' ') ' in '  tempDataStructure.units])
datetick('x',12)
