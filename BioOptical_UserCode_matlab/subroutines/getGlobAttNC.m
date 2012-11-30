function [gattname,gattval]=getGlobAttNC(nc)
%%getGlobAttNC gets all the global attribute of one NetCDF file
% 
% The script lists all the Variables in the NetCDF file. If the 
% variable is called TIME (case does not matter), then the variable is
% converted to a matlab time value, by adding the time offset ... following
% the CF conventions 
% If the variable to load is not TIME, the data is extracted, and all values
% are modified according to the attributes of the variable following the CF
% convention (such as value_min value_max, scale-factor , _Fillvalue ...)
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.1/cf-conventions.html
% Syntax:  [varData,varAtt]=getVarNC_2(varName,ncid)
%
% Inputs:
%       nc           : netcdf identifier resulted from netcdf.open
% Outputs:
%    gattname         : array of string of attribute names
%    gattval          : array of string of attribute values
%
% Example:
%    ncid=netcdf.open('IMOS_AUV_B_20070928T014025Z_SIRIUS_FV00.nc','NC_NOWRITE');
%    [varData,varAtt]=getVarNetCDF('TIME',ncid)
%
% Other m-files required:readConfig
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: netcdf.open,listVarNC,getVarNetCDF
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Oct 2012; Last revision: 30-Oct-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 


% preallocation
[ ~, ~, natts ,~] = netcdf.inq(nc);
gattname=cell(1,natts);
gattval=cell(1,natts);
for aa=0:natts-1
    gattname{aa+1} = netcdf.inqAttName(nc,netcdf.getConstant('NC_GLOBAL'),aa);
    gattval{aa+1} = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),gattname{aa+1});
end

end
