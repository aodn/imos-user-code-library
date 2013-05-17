srs_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SRS/BioOptical/1997_cruise-FR1097/pigment/IMOS_SRS-OC-BODBAW_X_19971201T052600Z_FR1097-pigment_END-19971207T220700Z_C-20121129T120000Z.nc' ;
srs_DATA = ncParse(srs_URL) ;
 
nProfiles = length (srs_DATA.dimensions.profile.data);% number of profiles 
 
% we choose the first profile
ProfileToPlot = 10; % this is arbitrary. We can plot all profiles from 1 to nProfiles
nObsProfile = srs_DATA.variables.rowSize.data(ProfileToPlot);  %number of observations for ProfileToPlot
timeProfile = srs_DATA.variables.TIME.data(ProfileToPlot);
latProfile = srs_DATA.variables.LATITUDE.data(ProfileToPlot);
lonProfile = srs_DATA.variables.LONGITUDE.data(ProfileToPlot);
 
% we look for the observations indexes related to the chosen profile
indexObservationStart = sum( srs_DATA.variables.rowSize.data(1:ProfileToPlot)) - srs_DATA.variables.rowSize.data(ProfileToPlot) +1;
indexObservationEnd = sum( srs_DATA.variables.rowSize.data(1:ProfileToPlot));
indexObservation =  indexObservationStart:indexObservationEnd ;
 
% we chose arbitrary to plot CPHL_a but there are many more variables
% available
cphl_aData = srs_DATA.variables.CPHL_a.data(indexObservation);  %for ProfileToPlot
depthData = srs_DATA.variables.DEPTH.data(indexObservation);
 
figure1 = figure;
set(figure1, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
 
plot (cphl_aData,depthData)
title({srs_DATA.metadata.source ,...
    datestr(timeProfile),...
    ['location:lat=' num2str(latProfile) '; lon=' num2str(lonProfile) ]})
xlabel([strrep(srs_DATA.variables.CPHL_a.long_name,'_', ' ') ' in ' srs_DATA.variables.CPHL_a.units])
ylabel([strrep(srs_DATA.variables.DEPTH.long_name,'_', ' ') ' in ' srs_DATA.variables.DEPTH.units ';positive ' srs_DATA.variables.DEPTH.positive ])
