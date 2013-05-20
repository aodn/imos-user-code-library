%% Example to plot a SOOP XBT dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

xbt_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SOOP/SOOP-XBT/aggregated_datasets/line_and_year/IX1/IMOS_SOOP-XBT_T_20040131T195300Z_IX1_FV01_END-20041221T214400Z.nc';
xbt_DATA = ncParse(xbt_URL) ;
 
qcFlag = 4; % flag value to eliminate (bad data)
 
maxSample = length(xbt_DATA.dimensions.MAXZ.data); % 'maximum_number_of_samples_in_vertical_profile'
nProfiles = length(xbt_DATA.dimensions.INSTANCE.data); % number of profiles
 
 
%% we look for all the profiles of a similar cruise
cruiseData = xbt_DATA.variables.cruise_ID.data;
cruiseID = [];
for iiCruise = 1:length(cruiseData) 
    cruiseID{iiCruise} = strrep((cruiseData(iiCruise,:)),' ','');
end
uniqueCruiseIds = unique(cruiseID) ;
cruiseToPlot = uniqueCruiseIds{6}; %  'tb408504' , this is arbitrary. This value can be modified to plot the cruise of choice
indexCruiseToPlot = strcmp(cruiseID , cruiseToPlot); % logical array
    
TEMP = xbt_DATA.variables.TEMP;
DEPTH = xbt_DATA.variables.DEPTH;
TIME = xbt_DATA.variables.TIME;
 
% we load the data for each cruise
timeCruise =  TIME.data(indexCruiseToPlot);
latCruise =  xbt_DATA.variables.LATITUDE.data(indexCruiseToPlot);
lonCruise =  xbt_DATA.variables.LONGITUDE.data(indexCruiseToPlot);
 
% we load only the data which does not have a quality control value equal to qcFlag (see above)
indexGoodData = xbt_DATA.variables.TEMP.flag(:,indexCruiseToPlot) ~= qcFlag;
tempCruise =  double(TEMP.data(:,indexCruiseToPlot));
depthCruise = double(DEPTH.data(:,indexCruiseToPlot));
 
 
% we modify the values which we don't want to plot to replace them with NaN
tempCruise(~indexGoodData) = NaN;
depthCruise(~indexGoodData) = NaN;
 
% creation of a profile array to use it with pcolor. same dimension of temp and depth
[nline, ncol] = size(tempCruise);
sizer = ones(nline,1) ;
profileIndex = 1:ncol;
prof_2D =  sizer * profileIndex ;
 
figure1 = figure;
set(figure1, 'Position',  [1 1000 1100 900 ], 'Color',[1 1 1]);
 
%plot the xbt TEMP timeseries
subplot(2,3,1:3),
pcolor(prof_2D, -depthCruise, tempCruise);
% datetick('x',20)
shading interp;
cmap = colorbar('location','EastOutside');
set(get(cmap,'ylabel'),'string',strrep([xbt_DATA.variables.TEMP.long_name ' in ' xbt_DATA.variables.TEMP.units ],'_',' '),'Fontsize',10) 
 
title({xbt_DATA.metadata.title ,...
     ['Cruise :' char(cruiseToPlot) '-' xbt_DATA.metadata.XBT_line_description]})
xlabel('Profile Index')
ylabel(strrep([xbt_DATA.variables.DEPTH.long_name ' in ' xbt_DATA.variables.DEPTH.units],'_', ' '))
 
%plot the xbt LAT timeseries
subplot(2,3,4),plot(prof_2D,latCruise)
title(strrep([xbt_DATA.variables.LATITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([xbt_DATA.variables.LATITUDE.long_name ' in ' xbt_DATA.variables.LATITUDE.units],'_', ' '))
xlabel('Profile Index')
 
%plot the xbt LON timeseries
subplot(2,3,5),plot(prof_2D,lonCruise)
title(strrep([xbt_DATA.variables.LONGITUDE.long_name ' - Timeseries'],'_', ' '))
ylabel(strrep([xbt_DATA.variables.LONGITUDE.long_name ' in ' xbt_DATA.variables.LONGITUDE.units],'_', ' '))
xlabel('Profile Index')
 
%plot the xbt LON timeseries
subplot(2,3,6),plot(timeCruise,prof_2D)
title(strrep([xbt_DATA.variables.LONGITUDE.long_name ' - Timeseries'],'_', ' '))
xlabel([TIME.long_name   ' in dd/mm/yy'] )
ylabel('Profile Index')
datetick('x',20)
set(figure1, 'Renderer', 'painters') %to get rid of renderer bug with dateticks
 
% plot of a single profile
profileToPlot = 1 ; % this is arbitrary. We can plot all profiles from 1 to ncol, modify profileToPlot if desired 
figure2 = figure;
set(figure2, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
plot (tempCruise(:,profileToPlot),-depthCruise(:,profileToPlot))
title({xbt_DATA.metadata.title ,...
    ['Cruise ' char(cruiseToPlot)] ,...
     xbt_DATA.metadata.XBT_line_description,...     
     ['location:lat=' num2str(latCruise(profileToPlot)) '; lon=' num2str(lonCruise(profileToPlot))],...
     [datestr(timeCruise(profileToPlot)) ]})
xlabel(strrep([xbt_DATA.variables.TEMP.long_name ' in ' xbt_DATA.variables.TEMP.units],'_', ' '))
ylabel(strrep([xbt_DATA.variables.DEPTH.long_name ' in negative ' xbt_DATA.variables.DEPTH.units],'_', ' '))
