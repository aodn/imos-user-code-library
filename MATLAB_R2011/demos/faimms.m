%% Example to plot a FAIMMS dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

FAIMMS_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/FAIMMS/Myrmidon_Reef/Sensor_Float_1/water_temperature/sea_water_temperature@5.0m_channel_114/2012/QAQC/IMOS_FAIMMS_T_20121201T000000Z_FV01_END-20130101T000000Z_C-20130426T102459Z.nc' ;
faimms_DATA = ncParse(FAIMMS_URL) ;

qcLevel = 1; % only the Good data are being used
tempData = faimms_DATA.variables.TEMP.data (faimms_DATA.variables.TEMP.flag == qcLevel);
timeData = faimms_DATA.dimensions.TIME.data(faimms_DATA.variables.TEMP.flag == qcLevel);
 
figure1 = figure; set(figure1, 'Color',[1 1 1]);%please resize the window manually
plot (timeData,tempData)
title({faimms_DATA.metadata.title ,...
    [num2str(faimms_DATA.variables.TEMP.sensor_depth) ' m depth'] ,...
    ['location:lat=' num2str(faimms_DATA.dimensions.LATITUDE.data) '; lon='  num2str(faimms_DATA.dimensions.LONGITUDE.data) ]})
xlabel([strrep(faimms_DATA.dimensions.TIME.long_name,'_', ' ')])
ylabel([strrep( faimms_DATA.variables.TEMP.standard_name,'_', ' ') ' in '  faimms_DATA.variables.TEMP.units])
datetick('x',20)