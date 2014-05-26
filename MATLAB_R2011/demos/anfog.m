%% Example to plot a ANFOG dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNUv3 General Public License

anfog_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANFOG/seaglider/SOTS20110420/IMOS_ANFOG_BCEOSTUV_20110420T111022Z_SG517_FV01_timeseries_END-20110420T140511Z.nc' ;
anfog_DATA = ncParse(anfog_URL) ;
 
qcLevel = 1 ; % we use the quality control flags to only select the good_data 
psalData = anfog_DATA.variables.PSAL.data (anfog_DATA.variables.PSAL.flag == qcLevel) ;
timeData = anfog_DATA.dimensions.TIME.data (anfog_DATA.variables.PSAL.flag == qcLevel) ;
depthData = anfog_DATA.variables.DEPTH.data (anfog_DATA.variables.PSAL.flag == qcLevel) ;
 
% get the flag meaning values to add it later in the figure title
flag_meanings = textscan(anfog_DATA.variables.PSAL.flag_meanings,'%s','delimiter',' '); 
 
figure1 = figure;set(figure1,'Color',[1 1 1]);%please resize the window manually
[AX,H1,H2] = plotyy(timeData,psalData,timeData,depthData,'plot');% plot 2 functions in same fig
 
set(get(AX(1),'Ylabel'),'String',[strrep( anfog_DATA.variables.PSAL.standard_name,'_', ' ') ' in '  anfog_DATA.variables.PSAL.units]) 
set(get(AX(2),'Ylabel'),'String',[strrep( anfog_DATA.variables.DEPTH.standard_name,'_', ' ') ' in '  anfog_DATA.variables.DEPTH.units '-positive =' anfog_DATA.variables.DEPTH.positive]) 
 
datetick(AX(1),'x',0,'keeplimits','keepticks') 
set(AX(2),'XTick',[])
set(H1,'LineStyle','--')
set(H2,'LineStyle',':')
 
xlabel(anfog_DATA.dimensions.TIME.standard_name) 
title({anfog_DATA.metadata.title,['plot of ' strrep(flag_meanings{1}{qcLevel+1},'_',' ') ' only'] })