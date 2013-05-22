%% Example to plot a ARGO dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

argo_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/Argo/aggregated_datasets/south_pacific/IMOS_Argo_TPS-20020101T000000_FV01_yearly-aggregation-South_Pacific_C-20121102T220000Z.nc' ;
argo_DATA = ncParse(argo_URL) ;
 
nProfData = argo_DATA.dimensions.N_PROF.data; %Number of profiles contained in the file. 
nLevelData = argo_DATA.dimensions.N_LEVELS.data;%Maximum number of pressure levels contained in a profile. 
 
% we list all the Argo floats number in the variable 'argoFloatNumber' and
% chose one value
argoFloatNumber = unique(argo_DATA.variables.PLATFORM_NUMBER.data);
argoFloatNumberChosen = 5900106 ;% we randomly chose one float number;
 
% we load the data for this float. Casting data to double to be used afterwards with surface function
argoFloatProfilesIndexes = argo_DATA.variables.PLATFORM_NUMBER.data == argoFloatNumberChosen ;
tempData = double(argo_DATA.variables.TEMP_ADJUSTED.data(argoFloatProfilesIndexes,:));
psalData = double(argo_DATA.variables.PSAL_ADJUSTED.data(argoFloatProfilesIndexes,:));
presData = double(argo_DATA.variables.PRES_ADJUSTED.data(argoFloatProfilesIndexes,:));
latProfile = argo_DATA.variables.LATITUDE.data(argoFloatProfilesIndexes,:);
lonProfile = argo_DATA.variables.LONGITUDE.data(argoFloatProfilesIndexes,:);
timeProfile = argo_DATA.variables.JULD.data(argoFloatProfilesIndexes,:);
 
% creation of a time array which will be used by pcolor
[nline, ncol] = size(tempData);
sizer = ones(1, ncol);
CYCLE_NUMBER2D = double(argo_DATA.variables.CYCLE_NUMBER.data(argoFloatProfilesIndexes)) * sizer;
TIME_CYCLE_NUMBER2D = timeProfile * sizer;
 
figure1 = figure;set(figure1, 'Color',[1 1 1]); %please resize the window manually
%plot the argofloat TEMP timeseries
subplot(2,2,1:2),
pcolor(TIME_CYCLE_NUMBER2D, -presData, tempData);
datetick('x',20)
shading interp;
cmap = colorbar('location','EastOutside');
set(get(cmap,'ylabel'),'string',strrep([argo_DATA.variables.TEMP_ADJUSTED.long_name ' in ' argo_DATA.variables.TEMP_ADJUSTED.units ],'_',' '),'Fontsize',10) 
 
title({argo_DATA.metadata.description ,...
     ['Argo Float Number :' num2str(argoFloatNumberChosen) ]})
xlabel('Time in DD/MM/YY')
ylabel(strrep([argo_DATA.variables.PRES_ADJUSTED.long_name ' in ' argo_DATA.variables.PRES_ADJUSTED.units],'_', ' '))
 
%plot the argofloat LAT timeseries
subplot(2,2,3),plot(TIME_CYCLE_NUMBER2D,latProfile)
title(strrep([argo_DATA.variables.LATITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([argo_DATA.variables.LATITUDE.long_name ' in ' argo_DATA.variables.LATITUDE.units],'_', ' '))
datetick('x',20)
 
%plot the argofloat LON timeseries
subplot(2,2,4),plot(TIME_CYCLE_NUMBER2D,lonProfile)
title(strrep([argo_DATA.variables.LONGITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([argo_DATA.variables.LONGITUDE.long_name ' in ' argo_DATA.variables.LONGITUDE.units],'_', ' '))
datetick('x',20)
set(figure1, 'Renderer', 'painters') %to get rid of renderer bug with dateticks