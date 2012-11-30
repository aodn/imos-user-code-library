function [allVarnames,allVaratts]=listVarNC(nc)
%%listVarNC gets all the variables of one NetCDF file
% 
% The script lists all the Variables in the NetCDF file. 
% Syntax:  [allVarnames,allVaratts]=listVarNC(nc)
%
% Inputs:
%       nc           : netcdf identifier resulted from netcdf.open
% Outputs:
%    allVarnames         : array of string of variable names
%    allVaratts          : array of string of attribute values for all variables
%
% Example:
%    ncid=netcdf.open('IMOS_AUV_B_20070928T014025Z_SIRIUS_FV00.nc','NC_NOWRITE');
%   [allVarnames,allVaratts]=listVarNC(ncid)
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: netcdf.open,getVarNetCDF,getGlobAttNC
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Oct 2012; Last revision: 30-Oct-2012
%% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 


%% list all the Variables
ii=1;
Bool=1;
% preallocation
[~,nvars,~,~] = netcdf.inq(nc);% nvar is actually the number of Var + dim. 
allVarnames=cell(1,nvars);
allVaratts=cell(1,nvars);

while  Bool==1
    try
        [varname, ~, ~, varatts] = netcdf.inqVar(nc,ii-1);
        allVarnames{ii}=varname;
        allVaratts{ii}=varatts;
        ii=ii+1;
        Bool=1;
    catch
        Bool=0;
    end
end
end
