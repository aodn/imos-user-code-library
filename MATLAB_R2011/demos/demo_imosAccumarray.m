%% Example use of imosAccumarray
%
% Author: Paul Rigby, AIMS/IMOS
% email: p.rigby@aims.gov.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% Sep 2013; Last revision: 3-Sep-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/IMOS_ANMN-NRS_KOSTUZ_20080623T004500Z_NRSYON_FV01_NRSYON-0806-WQM-5_END-20080916T041400Z_C-20130310T112118Z.nc';
D = ncParse(URL);

%% Compare different (mean) averaging intervals for TEMP on one plot
month_av = imosAccumarray(D,'month','flags',[0 1],...
                          'median',{'TURB','CHLU'});                          
day_av = imosAccumarray(D,'day','flags',[0 1],...
                        'median',{'TURB','CHLU'});                                          
hour_av = imosAccumarray(D,'hour','flags',[0 1],...
                        'median',{'TURB','CHLU'});                      
                      
figure(1);cla
hold on
plot(month_av.dimensions.TIME.data,month_av.variables.TEMP.data,'r-*')
plot(day_av.dimensions.TIME.data,day_av.variables.TEMP.data,'g-x')
plot(hour_av.dimensions.TIME.data,hour_av.variables.TEMP.data,'b')
datetick('x','yy-mm-dd','keepticks')
axis tight
hold off
title(D.metadata.title)
xlabel(D.dimensions.TIME.standard_name)
ylabel(strrep([D.variables.TEMP.long_name ' in ' D.variables.TEMP.units],'_',' '))
legend({month_av.variables.TEMP.name,day_av.variables.TEMP.name,hour_av.variables.TEMP.name},'interpreter','none')

%% Compare different (median) averaging intervals for TURB on one plot

figure(2);cla
hold on
plot(month_av.dimensions.TIME.data,month_av.variables.TURB.data,'r-*')
plot(day_av.dimensions.TIME.data,day_av.variables.TURB.data,'g-x')
plot(hour_av.dimensions.TIME.data,hour_av.variables.TURB.data,'b')
datetick('x','yy-mm-dd','keepticks')
axis tight
hold off
title(D.metadata.title)
xlabel(D.dimensions.TIME.standard_name)
ylabel(strrep([D.variables.TURB.long_name ' in ' D.variables.TURB.units],'_',' '))
legend({month_av.variables.TURB.name,day_av.variables.TURB.name,hour_av.variables.TURB.name},'interpreter','none')

%% Plot daily maximum salinity
day_min = imosAccumarray(D,'day','flags',[0 1],'min');
day_max = imosAccumarray(D,'day','flags',[0 1],'max');
figure(3);cla
plot(day_min.dimensions.TIME.data,day_min.variables.PSAL.data,'r-+')
hold on
plot(day_max.dimensions.TIME.data,day_max.variables.PSAL.data,'g-x')
plot(day_av.dimensions.TIME.data,day_av.variables.PSAL.data,'k-.')

datetick('x','yy-mm-dd','keepticks')
title(D.metadata.title)
xlabel(D.dimensions.TIME.standard_name)
ylabel(strrep([D.variables.PSAL.long_name ' in ' D.variables.PSAL.units],'_',' '))
legend({day_min.variables.PSAL.name,day_max.variables.PSAL.name,day_av.variables.PSAL.name},'interpreter','none')


%% Plot mean DO with 2 sigma error bars
day_std = imosAccumarray(D,'day','flags',[0 1],'std');   
figure(4);cla
errorbar( day_av.dimensions.TIME.data,...
          day_av.variables.DOX2.data,...
          2*day_std.variables.DOX2.data,'xk'); 
datetick('x','yy-mm-dd','keepticks')
title(D.metadata.title)
xlabel(D.dimensions.TIME.standard_name)
ylabel(strrep([D.variables.DOX2.long_name ' in ' D.variables.DOX2.units],'_',' '))

                      