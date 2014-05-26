%% Example to plot a SRS BioOptical Absorption dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

srs_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/absorption/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-absorption-CDOM_END-19971207T180500Z_C-20121129T130000Z.nc' ;
srs_DATA = ncParse(srs_URL) ;
 
nProfiles = length (srs_DATA.dimensions.profile.data);% number of profiles 
 
% we choose the first profile
ProfileToPlot = 10; % this is arbitrary. We can plot all profiles from 1 to nProfiles
nObsProfile = srs_DATA.variables.rowSize.data(ProfileToPlot);  %number of observations for ProfileToPlot
timeProfile = srs_DATA.variables.TIME.data(ProfileToPlot);

% lat and lon depend of station index. while time depends of profile
stationName = srs_DATA.variables.station_name.data;
stationIndex = srs_DATA.variables.station_index.data;
latProfile = srs_DATA.variables.LATITUDE.data(stationIndex(ProfileToPlot));
lonProfile = srs_DATA.variables.LONGITUDE.data(stationIndex(ProfileToPlot));

 
% we look for the observations indexes related to the chosen profile
indexObservationStart = sum( srs_DATA.variables.rowSize.data(1:ProfileToPlot)) - srs_DATA.variables.rowSize.data(ProfileToPlot) +1;
indexObservationEnd = sum( srs_DATA.variables.rowSize.data(1:ProfileToPlot));
indexObservation =  indexObservationStart:indexObservationEnd ;
 
agData = double(srs_DATA.variables.ag.data(indexObservation,:));
wavelengthData = double(srs_DATA.dimensions.wavelength.data);
depthData = double(srs_DATA.variables.DEPTH.data(indexObservation));
 
 % we create a matrix of similar size to be used afterwards with pcolor
[wavelengthData_mesh,depthData_mesh] = meshgrid(wavelengthData,depthData);
 
figure1 = figure;set(figure1,'Color',[1 1 1]);%please resize the window manually
pcolor(wavelengthData_mesh , depthData_mesh , agData)
 
shading flat 
caxis([min(min(agData)) max(max(agData))])
cmap = colorbar;
set(get(cmap,'ylabel'),'string',strrep([srs_DATA.variables.ag.long_name ' in ' srs_DATA.variables.ag.units ],'_',' '),'Fontsize',10) 
title(strrep([srs_DATA.metadata.source ],'_',' '))
xlabel( strrep([srs_DATA.dimensions.wavelength.long_name ' in: ', srs_DATA.dimensions.wavelength.units],'_', ' '))
ylabel(strrep([srs_DATA.variables.DEPTH.long_name ' in ' srs_DATA.variables.DEPTH.units '; positive ' srs_DATA.variables.DEPTH.positive ],'_',' '))
 
%%%%%%%%%%%%%%
nDepth = length(depthData);
figure2 = figure;set(figure2,'Color',[1 1 1]);%please resize the window manually
plot(wavelengthData,agData,'x')
unitsMainVar=char(srs_DATA.variables.ag.units);
ylabel( strrep([srs_DATA.variables.ag.long_name ' in: ', srs_DATA.variables.ag.units],'_', ' '))
xlabel( strrep([srs_DATA.dimensions.wavelength.long_name ' in: ', srs_DATA.dimensions.wavelength.units],'_', ' '))
 
title({strrep(srs_DATA.variables.ag.long_name,'_',' '),...
    strcat('in units:',srs_DATA.variables.ag.units),...
    strcat('station :',char(srs_DATA.variables.station_name.data(ProfileToPlot,:)),...
    '- location',num2str(latProfile,'%2.3f'),'/',num2str(lonProfile,'%3.2f') ),...
    strcat('time :',datestr(timeProfile))
    })
 
for iiDepth=1:nDepth
    legendDepthString{iiDepth}=strcat('Depth:',num2str(depthData(iiDepth)),'m');
end
legend(legendDepthString)