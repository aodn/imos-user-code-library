%% Example to plot a ANMN ADCP dataset
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  https://github.com/aodn/imos_user_code_library
% May 2013; Last revision: 20-May-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

anmn_URL = 'http://thredds.aodn.org.au/thredds/dodsC/IMOS/eMII/demos/ANMN/WA/WATR50/Velocity/IMOS_ANMN-WA_VATPE_20120516T040000Z_WATR50_FV01_WATR50-1205-Workhorse-ADCP-498_END-20121204T021500Z_C-20121207T023956Z.nc' ;
anmn_DATA = ncParse(anmn_URL) ;
 
%it is a lot more relevant for ADCP data to plot the good and probably good data only (flags 1 and 2).
qcLevel = [1 2];
qcIndex = anmn_DATA.variables.UCUR.flag == qcLevel(1) | anmn_DATA.variables.UCUR.flag == qcLevel(2) ;
uCurrentData =  anmn_DATA.variables.UCUR.data;
uCurrentData (~qcIndex) = NaN;
 
timeData = anmn_DATA.dimensions.TIME.data;
depthData = anmn_DATA.dimensions.HEIGHT_ABOVE_SENSOR.data;
 
% we create a matrix of similar size to be used afterwards with pcolor
[depthData_mesh,timeData_mesh] = meshgrid(depthData,timeData);
 
% get the flag meaning values to add it later in the figure title
flag_meanings = textscan(anmn_DATA.variables.UCUR.flag_meanings,'%s','delimiter',' ');
 
%% creation of a blue and red colormap centered in white
% initialise limits with RGB values
bluecolor = [0,0,1];% blue 
redcolor =  [1,0,0];%white 
whitecolor = [1,1,1];% red 
 
% create each vector individually
maplength = 64; % number of color 'steps'
part1 = linspace(bluecolor(1),whitecolor(1),maplength/2);
part2 = linspace( whitecolor(1), redcolor(1),maplength/2);
 
part3 = linspace(bluecolor(2),whitecolor(2),maplength/2);
part4 = linspace( whitecolor(2), redcolor(2),maplength/2);
 
part5 = linspace(bluecolor(3),whitecolor(3),maplength/2);
part6 = linspace( whitecolor(3), redcolor(3),maplength/2);
 
% compose colormap
cmap_r_b = [horzcat(part1, part2)',horzcat(part3, part4)',horzcat(part5, part6)'];
 
%creation of the figure
figure1 = figure;
set(figure1, 'Renderer', 'painters') %to get rid of renderer bug with dateticks 
set(figure1, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
pcolor(timeData_mesh , double(depthData_mesh) , double(uCurrentData))
 
 
shading flat
caxis([-max(max(abs(uCurrentData))) max(max(abs(uCurrentData)))]) % colorbar centered . we take the abs value
colormap(cmap_r_b)
cmap = colorbar;
set(get(cmap,'ylabel'),'string',strrep([anmn_DATA.variables.UCUR.long_name ' in ' anmn_DATA.variables.UCUR.units ],'_',' '),'Fontsize',10)
title({strrep([anmn_DATA.metadata.title ],'_',' ') , ['plot of ' strrep(flag_meanings{1}{qcLevel(1)+1},'_',' ')  ' and ' strrep(flag_meanings{1}{qcLevel(2)+1},'_',' ') ' only'] })
xlabel(anmn_DATA.dimensions.TIME.standard_name)
ylabel(strrep([anmn_DATA.dimensions.HEIGHT_ABOVE_SENSOR.long_name ' in ' anmn_DATA.dimensions.HEIGHT_ABOVE_SENSOR.units],'_',' '))
 
datetick('x',12)
