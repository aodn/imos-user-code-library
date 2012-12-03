function [profileInfo,variableInfo,globalAttributes]=getAbsorptionInfo(ncFile)
%% getAbsorptionInfo
% This function reads the information of an absorption NetCDF file from the BioOptical Database
% sub-facility. For each NetCDF file, there could be many profile for many stations. All the
% information concerning the profiles and variables measured are harvested
%
% Syntax: [profileInfo,variableInfo,globalAttributes]=getAbsorptionInfo(ncFile)
%
% Inputs:  ncFile - location of the NetCDF file to process
%
% Outputs: profileInfo - structure of all the profile, time and location associated to each profile
%          variableInfo- structure of different variables and their attributes
%          globalAttributes - structure of global attributes names and values
%
%
% Example:
%    [profileInfo,variableInfo,globalAttributes]=getAbsorptionInfo('/this/is/thepath/IMOS_test.ncid')
%
% Other m-files
% required:
% Other files required:
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
% getAbsorptionData,plotAbsorption,getAbsorptionData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License

if ~ischar(ncFile),           error('ncFile must be a string');        end

if exist(ncFile,'file') ==2
    ncid = netcdf.open(char(ncFile), 'NC_NOWRITE');
    
    try
        [allVarnames,~]=listVarNC(ncid);
        
        % 9 known variables
        dimidTIME       = netcdf.inqVarID(ncid,'TIME');
        dimidLAT        = netcdf.inqVarID(ncid,'LATITUDE');
        dimidLON        = netcdf.inqVarID(ncid,'LONGITUDE');
        dimidLAMBDA     = netcdf.inqVarID(ncid,'wavelength'); %WAVELENGHT?
        dimidDEPTH      = netcdf.inqVarID(ncid,'DEPTH');
        dimidstation_name = netcdf.inqVarID(ncid,'station_name');
        dimidprofile    = netcdf.inqVarID(ncid,'profile');
        dimidstation_index = netcdf.inqVarID(ncid,'station_index');
        dimidrowSize    = netcdf.inqVarID(ncid,'rowSize');
        
        [~,  numvars, ~,  ~] = netcdf.inq(ncid);
        array_of_all_variables=1:numvars;
        
        sub_array_of_variables = array_of_all_variables(setdiff(1:length(array_of_all_variables),...
            [array_of_all_variables(dimidTIME+1),array_of_all_variables(dimidLAT+1), ...
            array_of_all_variables(dimidLON+1),array_of_all_variables(dimidLAMBDA+1),...
            array_of_all_variables(dimidDEPTH+1), ...
            array_of_all_variables(dimidstation_name+1),array_of_all_variables(dimidprofile+1),array_of_all_variables(dimidstation_index+1), ...
            array_of_all_variables(dimidrowSize+1)]));
        
        dimidVAR = cell(1,length(sub_array_of_variables));
        variableList = cell(1,length(sub_array_of_variables));
        for ii = 1:length(sub_array_of_variables)
            dimidVAR{ii} = netcdf.inqVarID(ncid,allVarnames{sub_array_of_variables(ii)});
            variableList{ii} = allVarnames{sub_array_of_variables(ii)};            
            [~,varAtt{ii}]=getVarNetCDF(variableList{ii},ncid);
            varAtt{ii}.varname = variableList{ii};
            variableInfo.(variableList{ii})=varAtt{ii};
        end
        
        [lat,~] = getVarNetCDF('LATITUDE',ncid);
        [lon,~] = getVarNetCDF('LONGITUDE',ncid);
        [time,~]= getVarNetCDF('TIME',ncid);
        
        
        %% which profile do we plot ?
        profileData=getVarNetCDF('profile',ncid);
        
        StationIndex = (netcdf.getVar(ncid,dimidstation_index));
        StationNames = (netcdf.getVar(ncid,dimidstation_name));
        strlen = size(StationNames,1);
        nStation = length(unique(StationIndex));
        stationName=cell(1,nStation);
        for iiStation = 1:nStation
            stationName{iiStation} = regexprep(StationNames(1:strlen,iiStation)', '[^\w'']', '');
        end
        
        
        for ii=1:length(profileData)
            profileInfo(ii).index = ii;
            profileInfo(ii).stationName = stationName(StationIndex(ii));
            profileInfo(ii).stationLatitude = lat(StationIndex(ii));
            profileInfo(ii).stationLongitude = lon(StationIndex(ii));
            profileInfo(ii).profileTime = time(ii);
        end
        
        [globalAttributes.gattName,globalAttributes.gattVal] = getGlobAttNC(ncid);
        
        netcdf.close(ncid)
        
    catch err
        netcdf.close(ncid)
        error('MATLAB:NetCDF',  'error while reading NetCDF');
    end
    
else
    return
end