abos_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ABOS/SOTS/Pulse/IMOS_ABOS-SOTS_20110803T000000Z_PULSE_FV01_PULSE-8-2011_END-20120719T000000Z_C-20121009T214808Z.nc' ;
abos_DATA = ncParse(abos_URL) ;
 
tempDataStructure = abos_DATA.variables.TEMP_85_1;
tempData = tempDataStructure.data;
timeData = abos_DATA.dimensions.(char(tempDataStructure.dimensions)).data;
 
abstract = abos_DATA.metadata.abstract;
 
figure1 = figure;
set(figure1, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
 
plot (timeData,tempData)
title([abos_DATA.metadata.title ' at ' num2str(tempDataStructure.sensor_depth) ' m depth' ])
xlabel([strrep(abos_DATA.dimensions.(char(tempDataStructure.dimensions)).long_name,'_', ' ')])
ylabel([strrep( tempDataStructure.standard_name,'_', ' ') ' in '  tempDataStructure.units])
datetick('x',12)
