%% Example to plot a ACORN dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

acorn_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ACORN/monthly_gridded_1h-avg-current-map_non-QC/TURQ/2012/IMOS_ACORN_V_20121001T000000Z_TURQ_FV00_monthly-1-hour-avg_END-20121029T180000Z_C-20121030T160000Z.nc.gz' ;
acorn_DATA = ncParse(acorn_URL) ;
 
% we load the data. Casting data to double to be used afterwards with surface function
speedData = double(acorn_DATA.variables.SPEED.data);
latData = double(acorn_DATA.variables.LATITUDE.data);
lonData = double(acorn_DATA.variables.LONGITUDE.data);
timeData = acorn_DATA.dimensions.TIME.data;
 
% sea water U and V components
uData = (acorn_DATA.variables.UCUR.data);
vData = (acorn_DATA.variables.VCUR.data);
 
% Only one time value is being plotted. modify timeIndex if
% desired (value between 1 and length(timeData)
timeIndex = 5;
 
figure1 = figure; set(figure1,'Color',[1 1 1]);%please resize the window manually
quiver(lonData,latData,squeeze(uData(timeIndex,:,:)),squeeze(vData(timeIndex,:,:)),1.5,'LineWidth',1,'Color','k')
hold all
 
% to place a quiver plot on top of a surface plot, we need to create this z
% function
z = lonData .* exp(-lonData.^2 - latData.^2);
h = surface(lonData ,latData , squeeze(speedData(timeIndex,:,:)));
set(h,'ZData',-1+0*z) % Move the surface plot to Z = -1 in order to plot quivers over surface
 
shading interp
cmap = colorbar ;
caxis([min(min(min(speedData(timeIndex,:,:)))) max(max(max(speedData(timeIndex,:,:))))])
set(get(cmap,'ylabel'),'string',[acorn_DATA.variables.SPEED.long_name ' in ' acorn_DATA.variables.SPEED.units ],'Fontsize',10)
 
title({acorn_DATA.metadata.title ,...
    datestr(timeData(timeIndex),31) })
xlabel(acorn_DATA.variables.LONGITUDE.long_name)
ylabel(acorn_DATA.variables.LATITUDE.long_name)
