%% Example to plot a AUV dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

auv_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AUV/GBR201102/r20110301_012810_station1195_09_transect/hydro_netcdf/IMOS_AUV_ST_20110301T012815Z_SIRIUS_FV00.nc' ;
auv_DATA = ncParse(auv_URL) ;
 
tempData = auv_DATA.variables.TEMP.data;
timeData = auv_DATA.dimensions.TIME.data;
depthData = auv_DATA.variables.DEPTH.data;
averageLat = mean(auv_DATA.variables.LATITUDE.data);
averageLon = mean(auv_DATA.variables.LONGITUDE.data);
 
figure1 = figure;set(figure1, 'Color',[1 1 1]);%please resize the window manually
 
xlabel([strrep(auv_DATA.dimensions.(char(auv_DATA.variables.TEMP.dimensions)).long_name,'_', ' ')])
ylabel([strrep( auv_DATA.variables.TEMP.standard_name,'_', ' ') ' in '  auv_DATA.variables.TEMP.units])
datetick('x',15)
 
[AX,H1,H2] = plotyy (timeData,tempData,timeData,depthData);
 
set(get(AX(1),'Ylabel'),'String',[strrep( auv_DATA.variables.TEMP.standard_name,'_', ' ') ' in '  auv_DATA.variables.TEMP.units]) 
set(get(AX(2),'Ylabel'),'String',[strrep( auv_DATA.variables.DEPTH.standard_name,'_', ' ') ' in '  auv_DATA.variables.DEPTH.units '-positive =' auv_DATA.variables.DEPTH.positive]) 
 
datetick(AX(1),'x',31,'keeplimits','keepticks') 
set(AX(2),'XTick',[])
 
xlabel(auv_DATA.dimensions.TIME.standard_name) 
title({['campaign ' auv_DATA.metadata.title ],...
     ['location:lat=' num2str(averageLat) '; lon=' num2str(averageLon) ]})
 
set(H1,'LineStyle','--')
set(H2,'LineStyle',':')