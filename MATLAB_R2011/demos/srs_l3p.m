srs_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/SRS-SST/L3P/2013/20130315-ABOM-L3P_GHRSST-SSTsubskin-AVHRR_MOSAIC_01km-AO_DAAC-v01-fv01_0.nc' ;
srsL3P_DATA = ncParse(srs_URL) ;
 
step = 20; % we take one point out of 'step'. Only to make it faster to plot on Matlab
% squeeze the data to get rid of the time dimension in the variable shape 
sst = squeeze(srsL3P_DATA.variables.sea_surface_temperature.data(1,1:step:end,1:step:end));
lat = squeeze(srsL3P_DATA.dimensions.lat.data(1:step:end));
lon = squeeze(srsL3P_DATA.dimensions.lon.data(1:step:end));
 
[lon_mesh,lat_mesh] = meshgrid(lon,lat);% we create a matrix of similar size to be used afterwards with pcolor
 
figure1 = figure;
surface(double(lon_mesh) , double(lat_mesh) , double(sst))
shading flat 
caxis([min(min(sst)) max(max(sst))])
cmap = colorbar;
set(get(cmap,'ylabel'),'string',[srsL3P_DATA.variables.sea_surface_temperature.long_name ' in ' srsL3P_DATA.variables.sea_surface_temperature.units ],'Fontsize',10) 
title([srsL3P_DATA.metadata.title '-' srsL3P_DATA.metadata.start_date ])
xlabel(strrep(([srsL3P_DATA.dimensions.lon.long_name ' in ' srsL3P_DATA.dimensions.lon.units]),'_',' '))
ylabel(strrep(([srsL3P_DATA.dimensions.lat.long_name ' in ' srsL3P_DATA.dimensions.lat.units]),'_',' '))
