FAIMMS_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/FAIMMS/Myrmidon_Reef/Sensor_Float_1/water_temperature/sea_water_temperature@5.0m_channel_114/2012/QAQC/IMOS_FAIMMS_T_20121201T000000Z_FV01_END-20130101T000000Z_C-20130426T102459Z.nc' ;
faimms_DATA = ncParse(FAIMMS_URL) ;

qcLevel = 1; % only the Good data are being used
tempData = faimms_DATA.variables.TEMP.data (faimms_DATA.variables.TEMP.flag == qcLevel);
timeData = faimms_DATA.dimensions.TIME.data(faimms_DATA.variables.TEMP.flag == qcLevel);
 
figure1 = figure;
set(figure1, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
 
plot (timeData,tempData)
title({faimms_DATA.metadata.title ,...
    [num2str(faimms_DATA.variables.TEMP.sensor_depth) ' m depth'] ,...
    ['location:lat=' num2str(faimms_DATA.dimensions.LATITUDE.data) '; lon='  num2str(faimms_DATA.dimensions.LONGITUDE.data) ]})
xlabel([strrep(faimms_DATA.dimensions.TIME.long_name,'_', ' ')])
ylabel([strrep( faimms_DATA.variables.TEMP.standard_name,'_', ' ') ' in '  faimms_DATA.variables.TEMP.units])
datetick('x',20)
