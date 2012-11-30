function plotAbsorption(profileData)
%% plotAbsorption
% This plots profileData previously created by getAbsorptionData.m
% 
%
% Syntax: plotAbsorption(profileData)
%
% Inputs: profileData   - structure of data created by getAbsorptionData.m
%          
% Outputs: 
%
%
% Example:
%   plotAbsorption(profileData)
%
% Other m-files
% required:
% Other files required:
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
%  getAbsorptionInfo,plotAbsorption,getAbsorptionData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 


[nWavelength,nDepth]=size(profileData.mainVar);
fh=figure;
set(fh, 'Position',  [1 500 900 500 ], 'Color',[1 1 1]);
plot(profileData.wavelength,profileData.mainVar,'x')
unitsMainVar=char(profileData.mainVarAtt.units);
ylabel( strrep(strcat(profileData.mainVarAtt.varname, ' in: ', unitsMainVar),'_', ' '))
xlabel( 'wavelength in nm')

title({strrep(profileData.mainVarAtt.long_name,'_',' '),...
    strcat('in units:',profileData.mainVarAtt.units),...
    strcat('station :',profileData.stationName,...
    '- location',num2str(profileData.latitude,'%2.3f'),'/',num2str(profileData.longitude,'%3.2f') ),...
    strcat('time :',datestr(profileData.time))
    })

for iiDepth=1:nDepth
    legendDepthString{iiDepth}=strcat('Depth:',num2str(-profileData.depth(iiDepth)),'m');
end
legend(legendDepthString)
end