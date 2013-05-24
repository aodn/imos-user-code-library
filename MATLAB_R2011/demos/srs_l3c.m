%% Example to plot a SRS L3C dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

srs_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/SRS-SST/L3C-01day/L3C_GHRSST-SSTskin-AVHRR19_D-1d_night/2013/20130401152000-ABOM-L3C_GHRSST-SSTskin-AVHRR19_D-1d_night-v02.0-fv01.0.nc.gz' ;
srsL3C_DATA = ncParse(srs_URL,'varList' ,{'sea_surface_temperature','l2p_flags'} );
 
step = 10; % we take one point out of 'step'. Only to make it faster to plot on Matlab
% squeeze the data to get rid of the time dimension in the variable shape 
sst = squeeze(srsL3C_DATA.variables.sea_surface_temperature.data(1,1:step:end,1:step:end));
lat = squeeze(srsL3C_DATA.dimensions.lat.data(1:step:end));
% modify the longitude values which across the 180th meridian 
lon = squeeze(srsL3C_DATA.dimensions.lon.data(1:step:end));
if sum(lon<0) > 0
    lon(lon<0) =  lon(lon<0)+360;
end
land = squeeze(srsL3C_DATA.variables.l2p_flags.data(1,1:step:end,1:step:end)); % land data
land (land ~= 2 ) = NaN; % see srsL3C_DATA.variables.l2p_flags.flag_meanings for more information: 2 == land

 
[lon_mesh,lat_mesh] = meshgrid(lon,lat);% we create a matrix of similar size to be used afterwards with pcolor
 
figure1 = figure;set(figure1,'Color',[1 1 1]); %please resize the window manually
surface(double(lon_mesh) , double(lat_mesh) , double(land)) % plot land
hold all

surface(double(lon_mesh) , double(lat_mesh) , double(sst))
shading flat 
caxis([min(min(sst)) max(max(sst))])
cmap = colorbar;
set(get(cmap,'ylabel'),'string',[srsL3C_DATA.variables.sea_surface_temperature.long_name ' in ' srsL3C_DATA.variables.sea_surface_temperature.units ],'Fontsize',10) 
title({srsL3C_DATA.metadata.title ,...
    srsL3C_DATA.metadata.start_time })
xlabel(strrep(([srsL3C_DATA.dimensions.lon.long_name ' in ' srsL3C_DATA.dimensions.lon.units]),'_',' '))
ylabel(strrep(([srsL3C_DATA.dimensions.lat.long_name ' in ' srsL3C_DATA.dimensions.lat.units]),'_',' '))
