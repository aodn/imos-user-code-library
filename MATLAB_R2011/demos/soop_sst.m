%% Example to plot a SOOP SST dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

soop_sst_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/SOOP/SOOP-SST/VNSZ_Spirit-of-Tasmania-2/2013/IMOS_SOOP-SST_MT_20130511T000000Z_VNSZ_FV01_C-20130519T233008Z.nc';
soop_sst_DATA = ncParse(soop_sst_URL) ;

% BOM quality control flags
flag_meanings = textscan(soop_sst_DATA.variables.TEMP.flag_meanings,'%s','delimiter',' ');
flag_values = textscan(soop_sst_DATA.variables.TEMP.flag_values,'%s','delimiter',',');
qcFlag = 'Z'; % flag value to keep (Value_passed_all_tests)
qcFlag_meaning = flag_meanings{1}{strcmp(flag_values{1},qcFlag)} ;

qcIndex = soop_sst_DATA.variables.TEMP.flag == qcFlag; % look for data which only match qcFlag.  a logical array of index

sstData = soop_sst_DATA.variables.TEMP.data(qcIndex);
timeData = soop_sst_DATA.dimensions.TIME.data(qcIndex);
latData = soop_sst_DATA.variables.LATITUDE.data(qcIndex);
lonData = soop_sst_DATA.variables.LONGITUDE.data(qcIndex);

%% plot sst timeseries
figure1 = figure;set(figure1, 'Color',[1 1 1]);%please resize the window manually
subplot(2,2,1:2),plot(timeData,sstData)

title({ [soop_sst_DATA.metadata.title ' from ' soop_sst_DATA.metadata.site],...
   strrep( [soop_sst_DATA.variables.TEMP.long_name ' - Timeseries'],'_', ' ') ,...
    ['plot of ' strrep(qcFlag_meaning,'_',' ') ' only'] })
xlabel([soop_sst_DATA.dimensions.TIME.long_name   ' (ISO 8601) yyyymmddTHHMMSS'] )
ylabel(strrep([soop_sst_DATA.variables.TEMP.long_name ' in ' soop_sst_DATA.variables.TEMP.units],'_', ' '))
datetick('x',30,'keepticks')

% plot latitude timeseries
subplot(2,2,3),plot(timeData,latData)
ylabel(strrep([soop_sst_DATA.variables.LATITUDE.long_name ' in ' soop_sst_DATA.variables.LATITUDE.units],'_', ' '))
xlabel([soop_sst_DATA.dimensions.TIME.long_name   ' (ISO 8601) yyyymmddTHHMMSS'] )
datetick('x',30,'keepticks')

% plot longitude timeseries
subplot(2,2,4),plot(timeData,lonData)
ylabel(strrep([soop_sst_DATA.variables.LONGITUDE.long_name ' in ' soop_sst_DATA.variables.LONGITUDE.units],'_', ' '))
xlabel([soop_sst_DATA.dimensions.TIME.long_name   ' (ISO 8601) yyyymmddTHHMMSS'] )
datetick('x',30,'keepticks')
