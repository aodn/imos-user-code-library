%% Example to plot a ARGO dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

argo_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/Argo/aggregated_datasets/south_pacific/IMOS_Argo_TPS-20020101T000000_FV01_yearly-aggregation-South_Pacific_C-20121102T220000Z.nc';
argo_DATA = ncParse(argo_URL) ;
 
nProfData = argo_DATA.dimensions.N_PROF.data; %Number of profiles contained in the file. 
nLevelData = argo_DATA.dimensions.N_LEVELS.data;%Maximum number of pressure levels contained in a profile. 
 
% we choose a random profile number
profileNumber = 7; 
% Casting data to double to be used afterwards with surface function 
tempData = double(argo_DATA.variables.TEMP_ADJUSTED.data(profileNumber,:));
psalData = double(argo_DATA.variables.PSAL_ADJUSTED.data(profileNumber,:));
presData = double(argo_DATA.variables.PRES_ADJUSTED.data(profileNumber,:));
latProfile = argo_DATA.variables.LATITUDE.data(profileNumber);
lonProfile = argo_DATA.variables.LONGITUDE.data(profileNumber);
timeProfile = argo_DATA.variables.JULD.data(profileNumber);
 
latArgo = argo_DATA.variables.LATITUDE.data;
lonArgo = argo_DATA.variables.LONGITUDE.data;
 
% temperature profile
figure1 = figure;set(figure1, 'Color',[1 1 1]);%please resize the window manually 
plot (tempData,presData)
title({argo_DATA.metadata.description ,...
     datestr(timeProfile) ,...
     ['location:lat=' num2str(latProfile) '; lon=' num2str(lonProfile)],...
     ['Argo Float Number :' num2str(argo_DATA.variables.PLATFORM_NUMBER.data(profileNumber)) ]})
xlabel(strrep([argo_DATA.variables.TEMP_ADJUSTED.long_name ' in ' argo_DATA.variables.TEMP_ADJUSTED.units],'_', ' '))
ylabel(strrep([argo_DATA.variables.PRES_ADJUSTED.long_name ' in ' argo_DATA.variables.PRES_ADJUSTED.units],'_', ' '))
 
% salinity profile
figure2 = figure; set(figure2, 'Color',[1 1 1]); %please resize the window manually
plot (psalData,presData) % for this example there is no data to display. But another profile should.
title({argo_DATA.metadata.description ,...
     datestr(timeProfile) ,...
     ['location:lat=' num2str(latProfile) '; lon=' num2str(lonProfile)],...
     ['Argo Float Number :' num2str(argo_DATA.variables.PLATFORM_NUMBER.data(profileNumber)) ]})
xlabel(strrep([argo_DATA.variables.PSAL_ADJUSTED.long_name ' in ' argo_DATA.variables.PSAL_ADJUSTED.units],'_', ' '))
ylabel(strrep([argo_DATA.variables.PRES_ADJUSTED.long_name ' in ' argo_DATA.variables.PRES_ADJUSTED.units],'_', ' '))
 
% argo float trajectory
figure3 = figure;set(figure3, 'Color',[1 1 1]); %please resize the window manually
plot(lonArgo,latArgo,'+')
xlabel(argo_DATA.variables.LONGITUDE.long_name)
ylabel(argo_DATA.variables.LATITUDE.long_name)
title('Argo Floats stations')