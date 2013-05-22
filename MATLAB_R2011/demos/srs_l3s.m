%% Example to plot a subset of a SRS L3S dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

srs_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/SRS-SST/L3S-01day/L3S_1d_night/2013/20130401152000-ABOM-L3S_GHRSST-SSTskin-AVHRR_D-1d_night-v02.0-fv01.0.nc.gz';
srsL3S_DATA = ncParse(srs_URL,'geoBoundaryBox', [165 181 -50 -30]) ; % New Zealand subset across the 180th meridian
 
step = 1; % we take one point out of 'step'. Only to make it faster to plot on Matlab
% squeeze the data to get rid of the time dimension in the variable shape 
sst = squeeze(srsL3S_DATA.variables.sea_surface_temperature.data(1,1:step:end,1:step:end));
lat = squeeze(srsL3S_DATA.dimensions.lat.data(1:step:end));
% modify the longitude values which across the 180th meridian
lon = squeeze(srsL3S_DATA.dimensions.lon.data(1:step:end));
land = squeeze(srsL3S_DATA.variables.l2p_flags.data(1,1:step:end,1:step:end)); % land data
land (land ~= 2 ) = NaN; % see srsL3S_DATA.variables.l2p_flags.flag_meanings for more information: 2 == land

if sum(lon<0) > 0
    lon(lon<0) =  lon(lon<0)+360;
end
 
[lon_mesh,lat_mesh] = meshgrid(lon,lat);% we create a matrix of similar size to be used afterwards with pcolor
 
figure1 = figure;set(figure1,'Color',[1 1 1]);%please resize the window manually 
surface(double(lon_mesh) , double(lat_mesh) , double(land)) % plot land
hold all

surface(double(lon_mesh) , double(lat_mesh) , double(sst))
shading flat 
caxis([min(min(sst)) max(max(sst))])
cmap = colorbar;
set(get(cmap,'ylabel'),'string',[srsL3S_DATA.variables.sea_surface_temperature.long_name ' in ' srsL3S_DATA.variables.sea_surface_temperature.units ],'Fontsize',10) 
title({srsL3S_DATA.metadata.title ,...
    srsL3S_DATA.metadata.start_time })
xlabel(strrep(([srsL3S_DATA.dimensions.lon.long_name ' in ' srsL3S_DATA.dimensions.lon.units]),'_',' '))
ylabel(strrep(([srsL3S_DATA.dimensions.lat.long_name ' in ' srsL3S_DATA.dimensions.lat.units]),'_',' '))