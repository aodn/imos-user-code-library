%% AATAMS - Animal Tagging and Monitoring
aatams_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/AATAMS/marine_mammal_ctd-tag/2009_2011_ct64_Casey_Macquarie/ct64-M746-09/IMOS_AATAMS-SATTAG_TSP_20100205T043000Z_ct64-M746-09_END-20101029T071000Z_FV00.nc';
aatams_DATA = ncParse(aatams_URL) ;
 
nProfiles = length (aatams_DATA.dimensions.profiles.data);
 
% creation of a 2 dimension array for temperature, pressure and salinity
for profileNumber = 1 : nProfiles
    indexVar = (aatams_DATA.variables.parentIndex.data == profileNumber); % a logical array of index
    
    tempVec = aatams_DATA.variables.TEMP.data(indexVar);
    tempData(profileNumber,1:length(tempVec)) = tempVec; clear tempVec
    
    presVec = aatams_DATA.variables.PRES.data(indexVar);
    presData(profileNumber,1:length(presVec)) = presVec; clear tempVec
    
    psalVec = aatams_DATA.variables.PSAL.data(indexVar);
    psalData(profileNumber,1:length(psalVec)) = psalVec; clear tempVec
end
 
% we replace the 0 values automatically created by Matlab with NaN
psalData(psalData == 0) = NaN;
presData(presData == 0) = NaN;
tempData(tempData == 0) = NaN;
 
 
timeData = aatams_DATA.variables.TIME.data;
latProfile = aatams_DATA.variables.LATITUDE.data;
lonProfile = aatams_DATA.variables.LONGITUDE.data;
 
%longitude in the original dataset goes from -180 to +180
%For a nicer plot, we change the values to the  [0  360] range
lonProfile(lonProfile < 0 ) = lonProfile(lonProfile < 0 ) +360 ;
 
% creation of the Time array
[nline, ncol] = size(tempData);
sizer = ones(1, ncol);
TIME_CYCLE_NUMBER2D = timeData * sizer;
 
%plot all the profiles as a timeseries
figure1 = figure; 
set(figure1, 'Renderer', 'painters') %to get rid of renderer bug with dateticks
set(figure1, 'Position',  [1 1000 1100 900 ], 'Color',[1 1 1]);
subplot(2,2,1:2),
pcolor(TIME_CYCLE_NUMBER2D, double(-presData), double(tempData));
datetick('x',20)
shading interp
cmap = colorbar('location','EastOutside');
set(get(cmap,'ylabel'),'string',strrep([aatams_DATA.variables.TEMP.long_name ' in ' aatams_DATA.variables.TEMP.units ],'_',' '),'Fontsize',10)
 
 
title({[aatams_DATA.metadata.species_name  ' - released in ' aatams_DATA.metadata.release_site ' / animal reference number : ' aatams_DATA.metadata.unique_reference_code],...
    })
zlabel(strrep([aatams_DATA.variables.TEMP.long_name ' in ' aatams_DATA.variables.TEMP.units],'_', ' '))
xlabel('Time in DD/MM/YY')
ylabel(strrep([aatams_DATA.variables.PRES.long_name ' in negative ' aatams_DATA.variables.PRES.units],'_', ' '))
 
 
%plot the  LAT timeseries
subplot(2,2,3),plot(TIME_CYCLE_NUMBER2D,latProfile)
title(strrep([aatams_DATA.variables.LATITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([aatams_DATA.variables.LATITUDE.long_name ' in ' aatams_DATA.variables.LATITUDE.units],'_', ' '))
datetick('x',20)
 
%plot the  LON timeseries
subplot(2,2,4),plot(TIME_CYCLE_NUMBER2D,lonProfile)
title(strrep([aatams_DATA.variables.LONGITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([aatams_DATA.variables.LONGITUDE.long_name ' in ' aatams_DATA.variables.LONGITUDE.units],'_', ' '))
datetick('x',20)
 
% plot of a single profile
profileToPlot = 1 ; % this is arbitrary. We can plot all profiles from 1 to nProfiles, modify profileToPlot as desired
 
figure2 = figure;
set(figure2, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
plot (tempData(profileToPlot,:),presData(profileToPlot,:))
title({aatams_DATA.metadata.title,...
    [ 'location',num2str(latProfile(profileToPlot),'%2.3f'),'/',num2str(lonProfile(profileToPlot),'%3.2f') ],...
    [ datestr(timeData(profileToPlot)) 'UTC']})
xlabel([strrep(aatams_DATA.variables.TEMP.long_name,'_', ' ') ' in ' aatams_DATA.variables.TEMP.units])
ylabel([strrep(aatams_DATA.variables.PRES.long_name,'_', ' ') ' in ' aatams_DATA.variables.PRES.units])
