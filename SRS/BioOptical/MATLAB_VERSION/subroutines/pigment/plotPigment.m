function plotPigment(profileData)
%% plotPigment
% This plots profileData previously created by getPigmentData.m
% 
%
% Syntax: plotPigment(profileData)
%
% Inputs: profileData   - structure of data created by getPigmentData.m
%          
% Outputs: 
%
%
% Example:
%   plotPigment(profileData)
%
% Other m-files
% required:
% Other files required:
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
%  getPigmentInfo,plotPigment,getPigmentData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 

if ~isstruct(profileData),       error('profileData must be a structure');        end


%% plot many depth in same graph
fh=figure;
set(fh, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
plot(profileData.mainVar,-profileData.depth,'x')
unitsMainVar=char(profileData.mainVarAtt.units);
xlabel( strrep(strcat(profileData.mainVarname, ' in: ', unitsMainVar),'_', ' '))
ylabel( 'Depth in m')

title({strrep(profileData.mainVarAtt.long_name,'_',' '),...
    strcat('in units:',profileData.mainVarAtt.units),...
    strcat('station :',profileData.stationName,...
    '- location',num2str(profileData.latitude,'%2.3f'),'/',num2str(profileData.longitude,'%3.2f') ),...
    strcat('time :',datestr(profileData.time))
    })
end