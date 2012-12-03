function profileData=getPigmentData(ncFile,variable,profile)
%% getPigmentData
% This function loads the data of one profile number 'profile' from a netcdf file
% 'ncFile' for one variable.
%
% Syntax:  profileData=getPigmentData(ncFile,variable,profile)
%
% Inputs: ncFile   - string of the NetCDF location
%         variable - string of variable name
%         profile  - number of profile to grab data from
%
% Outputs: profileData - structure with values and metadata of the profile
%
%
% Example:
%    profileData=getPigmentData('/this/is/thepath/IMOS_test.ncid','ag',1)
%
% Other m-files
% required:
% Other files required:config.txt
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

if ~ischar(ncFile),          error('ncFile must be a string');        end
if ~isstruct(variable),      error('variable must be a structure');        end
if ~isnumeric(profile),       error('profile must be a numerical value');        end


if exist(ncFile,'file') ==2
    ncid = netcdf.open(char(ncFile),'NC_NOWRITE');
    
    try
        
        % 8 known variables
        dimidDEPTH = netcdf.inqVarID(ncid,'DEPTH');
        dimidVAR= netcdf.inqVarID(ncid,variable.varname);
        
        
        rowSize=getVarNetCDF('rowSize',ncid);
        StationIndex=getVarNetCDF('station_index',ncid);
        StationNames=getVarNetCDF('station_name',ncid);
        
        %% which profile do we plot ?
        strlen=size(StationNames,1);
        nStation=length(unique(StationIndex));
            stationName=cell(1,nStation);
        for iiStation=1:nStation
            stationName{iiStation}=regexprep(StationNames(1:strlen,iiStation)','[^\w'']','');
        end
        
        
        numberObsSation=rowSize( profile);
        startIndexStation=sum(rowSize(1:profile-1));
        
        
        varData=double(netcdf.getVar(ncid,dimidVAR,startIndexStation,[numberObsSation]));
        varData(varData==variable.FillValue)=NaN;
        depthData=double(netcdf.getVar(ncid,dimidDEPTH,startIndexStation,[numberObsSation]));
        time=getVarNetCDF('TIME',ncid);
        timeData=time(profile);
        lon=getVarNetCDF('LONGITUDE',ncid);
        lonData=lon(StationIndex(profile));
        lat=getVarNetCDF('LATITUDE',ncid);
        latData=lat(StationIndex(profile));        
        
        
        profileData.mainVarAtt=variable;
        profileData.depth=depthData;
        profileData.mainVar=varData;
        profileData.mainVarname=variable.varname;
        profileData.stationName=char(stationName(StationIndex(profile)));
        profileData.latitude=latData;
        profileData.longitude=lonData;
        profileData.time=timeData;
        
        netcdf.close(ncid)
    catch err
        netcdf.close(ncid)
        error('MATLAB:NetCDF',  'error while reading NetCDF');
    end
    
end