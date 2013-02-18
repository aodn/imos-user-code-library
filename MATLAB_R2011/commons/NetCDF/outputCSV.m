function outputCSV(dataset, varargin)
%%outputCSV export data ouput from netCDFParse into a csv file.
% 
% A NetCDF file can be parsed into the working environment of the programing language used by a
% user with the function netCDFParse. Outputting a parsed NetCDF into a CSV file (comma-
% separated values), with options defined by the user, can be performed with the function outputCSV
% described in this section.
% The exported CSV file will have the same information as one can find in the original NetCDF file:
% • metadata
% • variable attributes
% • QC flags for data quality
% The CSV file once created is characterized by a text delimiter ' “ ' and and cell delimiter ' , ' .
% A user will find many interests in this tool, such as importing afterwards the data into the software
% of his choice (for example Excel or LibreOffice) in order to have a more visual interaction with the
% data.
% 
% 
% Inputs:
%    dataset : output from the function netCDFParse
%    
%   'varList' is an optional input : needs to be followed by a string of
%            variable names found in dataset.variables, such as
%           'varList' , {'VAR_1' , 'VAR_2'}
%
%   'folderOutput' is an optional input so the user can choose the folder of his choice where the
%           csv file(s) will be created. If this argument does not exist, the function will create the files in
%           the home directory of the user (either the environment is Linux or Windows).
% 
%
%   Outputs: a csv file following this filenaming convention:
%         <original NetCDF filename minus extension>_<dimensionName>_DimensionDependency.csv
% 
%
% Example:
%
% url = 'http://opendap-vpac.arcs.org.au/thredds/dodsC/IMOS/ANMN/NSW/PH100/Temperature/IMOS_ANMN-NSW_TE_20091029T025500Z_PH100_FV01_PH100-0910-Aqualogger-520T-40_END-20091223T000500Z_C-20111216T031406Z.nc';
% dataset = netCDFParse (url)
% • outputCSV(dataset ,'varList',{'TEMP'})
% • outputCSV(dataset ,'varList',{'TEMP','DEPTH'})
% • outputCSV(dataset ,'varList',{'TEMP'},'folderOutput','~/testCSV')
% • outputCSV(dataset ,'varList',{'TEST'},'folderOutput','~/testCSV') ->
% returns a warning
%
% Other m-files required: 
% Other files required:
% Subfunctions: mkpath
% MAT-files required: none
%
% See also: netCDFParse
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Feb 2013; Last revision: 18-Feb-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License


if ~isstruct(dataset),          error('dataset must be a structure');        end

% initialise the optional arguments
if ispc
    folderOutput= getenv('USERPROFILE');
elseif isunix
    folderOutput= getenv('HOME');
end
variableListUser = [];

%% section to read the optional arguments
optargin = size(varargin,2);
if optargin > 0
    variableListUser = [];
    
    for ii_optargin = 1:2:optargin
        
        if strcmpi(varargin{ii_optargin} , 'folderOutput')
            folderOutput = varargin{ii_optargin+1};
            
            if ~exist('folderOutput','dir')
                mkpath(folderOutput)
            end
            
        elseif strcmpi(varargin{ii_optargin} , 'varList')
            variableListUser = varargin{ii_optargin+1};
            
        else  error('%s is not a valid option',varargin{ii_optargin});
            
        end
        
    end

end


% for each variable to export, we need to find the dimensions
varNames = fieldnames(dataset.variables);
nVar = length(varNames);

for iiVar = 1 : nVar
    nDimForVar = length(dataset.variables.(varNames{iiVar}).dimensions);
    
    if nDimForVar > 1
        %we need to find out if the the variable has the type of a one
        %dimension variable, even if it depends of others such as
        %latitude(1) and longitude(1) for example
        for iiDim = 1 : nDimForVar
            sizeDim(iiDim) = length(dataset.dimensions.(dataset.variables.(varNames{iiVar}).dimensions{iiDim}).data);
        end
        
        if sum(sizeDim > 1) == 1
            %then there is only one true dimension
            dimNameForVar{iiVar} = dataset.variables.(varNames{iiVar}).dimensions{sizeDim > 1};
            netcdfVarType{iiVar} = [num2str(sum(sizeDim > 1) ) 'DIM'];
        else
            %more than one dimension. Need to create a new function for
            %this type of variable
            strDimsName = dataset.variables.(varNames{iiVar}).dimensions{1};
            for ttDimName = 2 : length(dataset.variables.(varNames{iiVar}).dimensions)
                strDimsName = [ strDimsName '___' dataset.variables.(varNames{iiVar}).dimensions{ttDimName}  ]; % we create a string of dimensions separated by a ___ delimeter. We will use a regexp later to find out those dim names
            end
            dimNameForVar{iiVar} = strDimsName;
            netcdfVarType{iiVar} = [num2str(sum(sizeDim > 1) ) 'DIM'];
        end
    else
        dimNameForVar{iiVar} = dataset.variables.(varNames{iiVar}).dimensions{1};
        netcdfVarType{iiVar} = '1DIM';
    end
end

[dimNameForVar_unique] = unique(dimNameForVar);
for ii_uniqueDim = 1:length(dimNameForVar_unique)
    indexSameVariableType_1D = ~cellfun('isempty',(regexp(netcdfVarType,'1DIM'))) & ~cellfun('isempty',(regexp(dimNameForVar,strcat('\<',dimNameForVar_unique{ii_uniqueDim}, '\>'))));
    if sum(indexSameVariableType_1D) ~= 0
        listVarForUniqueDim_1D.(dimNameForVar_unique{ii_uniqueDim}) = varNames(indexSameVariableType_1D);
    end
    
    indexSameVariableType_2D = ~cellfun('isempty',(regexp(netcdfVarType,'2DIM'))) & ~cellfun('isempty',(regexp(dimNameForVar,strcat('\<',dimNameForVar_unique{ii_uniqueDim}, '\>') )));
    if sum(indexSameVariableType_2D) ~= 0
        listVarForUniqueDim_2D.(dimNameForVar_unique{ii_uniqueDim}) = varNames(indexSameVariableType_2D);
    end
end

%we create one CSV file per field in the previous structure
%listVarForUniqueDim

if exist('listVarForUniqueDim_1D','var')
    dimList_1D = fieldnames(listVarForUniqueDim_1D);
    for iidimList = 1:length(dimList_1D)
        variableExportable = listVarForUniqueDim_1D.(dimList_1D{iidimList});
        mainDimension = dimList_1D{iidimList};
        if ~isempty(variableListUser)
            %         variableToExport_1D = variableExportable(~cellfun('isempty',regexp(variableExportable, strcat('\<', variableListUser, '\>'))));
            %                 variableToExport_1D = variableExportable(~cellfun('isempty',regexp(variableExportable,  variableListUser')));
            variableToExport_1D = variableExportable(~cellfun('isempty',cellfun(@(s) find(cellfun(@numel,regexp(s,strcat('\<', variableListUser, '\>'),'once'))),variableExportable,'uni',0)));
            
            if ~isempty(variableToExport_1D)
                outputCSV_1D (dataset,mainDimension,variableToExport_1D,folderOutput)
            else
                warning('No Variable to export')
            end
        else
            outputCSV_1D (dataset,mainDimension,variableExportable,folderOutput)
        end
    end
end

if exist('listVarForUniqueDim_2D','var')
    dimList_2D = fieldnames(listVarForUniqueDim_2D);
    for iidimList = 1:length(dimList_2D)
        variableExportable = listVarForUniqueDim_2D.(dimList_2D{iidimList});
        mainDimension = dimList_2D{iidimList};
        if ~isempty(variableListUser)
            variableToExport_2D = variableExportable(~cellfun('isempty',cellfun(@(s) find(cellfun(@numel,regexp(s,strcat('\<', variableListUser, '\>'),'once'))),variableExportable,'uni',0)));
            
            if ~isempty(variableToExport_2D)
                %             outputCSV_2D (dataset,mainDimension,variableToExport_2D)
                fprintf('no function written yet for 2D\n');
            end
        else
            fprintf('no function written yet for 2D\n');
            
            %                  outputCSV_2D (dataset,mainDimension,variableExportable)
        end
        
    end
end

end

function converted = something2str(somethingToConvert)
%%something2str tends to convert any matlab type into a string.
% 
% 
% Inputs:
%    somethingToConvert : cell, matrice, or char
%    
%
%   Outputs:
%     converted     : a string
%
% Example:
%     something2str(3) -> '3'
%
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: outputCSV
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Feb 2013; Last revision: 18-Feb-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

if isnumeric(somethingToConvert)
    converted = mat2str(somethingToConvert);
elseif iscell(somethingToConvert)
    converted = cellstr(somethingToConvert);
else
    converted = char(somethingToConvert);
end
end

function writeGlobAtt(dataset,filenameOutput)
%%writeGlobAtt writes the global attribute found in the structure dataset
%%into the CSV file filenameOutput
% 
% 
% Inputs:
%    dataset : structure from netCDFParse
%    filenameOutput : filename of the CSV file
%
%   Outputs:
%     
%
% Example:
%     writeGlobAtt(dataset,'test.csv')
%
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: outputCSV
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Feb 2013; Last revision: 18-Feb-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License
fid = fopen(filenameOutput, 'a+');

%% write global attributes
attName = fieldnames(dataset.metadata);
fprintf(fid, '"GLOBAL ATTRIBUTES"\n');
for att=1:length(attName)
    fprintf(fid, '"%s","%s"\n', something2str(attName{att}) , something2str(dataset.metadata.(attName{att}) ));
end
fprintf(fid, '\n\n');
fclose(fid);
end

function outputCSV_1D (dataset,mainDimension,variableToExport_1D,folderOutput)
%%outputCSV_1D sub function of outputCSV. Only for variables of a 1D type.
% 
% Inputs:
%    dataset : structure from netCDFParse
%    mainDimension : filename of the CSV file
%    variableToExport_1D
%    folderOutput

%   Outputs:
%     
%
% Example:
%     writeGlobAtt(dataset,'test.csv')
%
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: outputCSV
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Feb 2013; Last revision: 18-Feb-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License
%% we create a new file per dimension type
[~, nameNC, ~] = fileparts(dataset.metadata.netcdf_filename);
filenameNC = [nameNC '_' mainDimension '_DimensionDependency.csv'];
filenameOutput = fullfile(folderOutput, filenameNC);

%% open filenameOutput
if exist(filenameOutput,'file')
    delete(filenameOutput)
end

%% write global attributes
writeGlobAtt(dataset,filenameOutput)

fid = fopen(filenameOutput, 'a+');
delimiter = ',';

%% write variables
fprintf(fid, '"VARIABLES"\n');
%section to create the attribute line which will be the same for all
%variables
nVar = length(variableToExport_1D);
for iiVar = 1 : nVar
    varAtt = fieldnames(dataset.variables.(variableToExport_1D{iiVar})) ;
    varAtt = [varAtt; varAtt];
end
varAtt = unique (varAtt);
attIndexes = 1:length(varAtt);
attIndexesToKeep = attIndexes(setdiff(1:length(attIndexes),[ attIndexes(~cellfun('isempty',(regexp(varAtt,'data')))) , ...
    attIndexes(~cellfun('isempty',(regexpi(varAtt,'\<flag\>')))), ...
    attIndexes(~cellfun('isempty',(regexpi(varAtt,'FillValue')))), ...
    attIndexes(~cellfun('isempty',(regexpi(varAtt,'dimensions'))))...
    ]));
varAttNameToKeep = varAtt(attIndexesToKeep);


for iiVar = 1 : nVar
    if iiVar == 1  % we jsut write this information on the first line
        fprintf(fid, '"shortname",');
        for att = 1 : length(varAttNameToKeep)
            fprintf(fid, '"%s",', something2str(varAttNameToKeep{att}));
        end
        fprintf(fid, '\n');
    end
    
    fprintf(fid, '"%s",',variableToExport_1D{iiVar});
    for att = 1 : length(varAttNameToKeep)
        if isfield(dataset.variables.(variableToExport_1D{iiVar}),(varAttNameToKeep{att}))
            fprintf(fid, '"%s",', something2str(dataset.variables.(variableToExport_1D{iiVar}).(varAttNameToKeep{att})));
        else
            fprintf(fid, delimiter);
        end
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

%% write main dimensions
fprintf(fid, '"DIMENSION"\n');
dimAtt = fieldnames(dataset.dimensions.(mainDimension)) ;

attIndexes = 1:length(dimAtt);
attIndexesToKeep = attIndexes(setdiff(1:length(attIndexes),[ attIndexes(~cellfun('isempty',(regexp(dimAtt,'data')))) , ...
    attIndexes(~cellfun('isempty',(regexpi(dimAtt,'\<flag\>')))), ...
    attIndexes(~cellfun('isempty',(regexpi(dimAtt,'FillValue')))), ...
    attIndexes(~cellfun('isempty',(regexpi(dimAtt,'dimensions'))))...
    ]));
dimAttNameToKeep = dimAtt(attIndexesToKeep);

fprintf(fid, '"shortname",');
for att = 1 : length(dimAttNameToKeep)
    fprintf(fid, '"%s",', something2str(dimAttNameToKeep{att}));
end
fprintf(fid, '\n');

fprintf(fid, '"%s",',something2str(mainDimension));
for att = 1 : length(dimAttNameToKeep)
    if isfield(dataset.dimensions.(mainDimension),(dimAttNameToKeep{att}))
        
        fprintf(fid, '"%s",', something2str(dataset.dimensions.(mainDimension).(dimAttNameToKeep{att})));
    else
        fprintf(fid, delimiter);
    end
end

%% write the other dimension of size == 1 . This is useful only for the user to see for example the location (lat lon with a dimension == 1)
%first we need to find the other dimensions for this variable (the first
%one will do )
indexOtherDimensions = cellfun('isempty',(regexpi(dataset.variables.(variableToExport_1D{1}).dimensions,mainDimension)));
if sum (indexOtherDimensions) ~= 0
    fprintf(fid, '\n\n"OTHER DIMENSIONS (SIZE == 1)"\n');
    
    otherDimensions = dataset.variables.(variableToExport_1D{1}).dimensions(indexOtherDimensions);
    %now that we have the other dimensions names, we can write their attribute,
    %or value
    dimAtt = fieldnames(dataset.dimensions.(otherDimensions{1})) ;
    
    attIndexes = 1:length(dimAtt);
    attIndexesToKeep = attIndexes(setdiff(1:length(attIndexes),[ ...
        attIndexes(~cellfun('isempty',(regexpi(dimAtt,'\<flag\>')))), ...
        attIndexes(~cellfun('isempty',(regexpi(dimAtt,'FillValue')))), ...
        attIndexes(~cellfun('isempty',(regexpi(dimAtt,'dimensions'))))...
        ]));
    dimAttNameToKeep = dimAtt(attIndexesToKeep);
    
    fprintf(fid, '"shortname",');
    for att = 1 : length(dimAttNameToKeep)
        fprintf(fid, '"%s",', something2str(dimAttNameToKeep{att}));
    end
    
    for iiOtherDimensions = 1 : length(otherDimensions)
        fprintf(fid, '\n');
        fprintf(fid, '"%s",',something2str(otherDimensions{iiOtherDimensions}));
        for att = 1 : length(dimAttNameToKeep)
            if isfield(dataset.dimensions.(otherDimensions{iiOtherDimensions}),(dimAttNameToKeep{att}))
                
                fprintf(fid, '"%s",', something2str(dataset.dimensions.(otherDimensions{iiOtherDimensions}).(dimAttNameToKeep{att})));
            else
                fprintf(fid, delimiter);
            end
        end
    end
end

fprintf(fid, '\n\n\n');

%% write variable and dimension related

fprintf(fid, '"DATA"\n');
fprintf(fid, '"%s",',something2str(mainDimension));
for iiVar = 1 : nVar
    fprintf(fid, '"%s",',something2str(variableToExport_1D{iiVar}));
    if isfield(dataset.variables.(variableToExport_1D{iiVar}),'flag')
        fprintf(fid, '"%s",',[variableToExport_1D{iiVar} '_flag_QC']);
    end
end
fprintf(fid, '\n');


for iiData = 1:max(size(dataset.dimensions.(mainDimension).data))
    if regexpi(mainDimension, 'TIME')
        timeValue = dataset.dimensions.(mainDimension).data(iiData);
        if ~isnan(timeValue)
            dimValue =  datestr(timeValue,'yyyy-mm-ddTHH:MM:SSZ');
        else
            dimValue ='NaN';
        end
    else
        dimValue = something2str( dataset.dimensions.(mainDimension).data(iiData)); %warning need to change again time value
    end
    fprintf(fid, '"%s",',dimValue);
    
    for iiVar = 1 : nVar
        
        if regexpi(variableToExport_1D{iiVar}, 'TIME')
            timeValue = dataset.variables.(variableToExport_1D{iiVar}).data(iiData);
            if ~isnan(timeValue)
                varValue =  datestr(timeValue,'yyyy-mm-ddTHH:MM:SSZ');
            else
                varValue ='NaN';
            end
        else
            varValue = something2str( dataset.variables.(variableToExport_1D{iiVar}).data(iiData));
        end
        
        %         varValue = something2str( dataset.variables.(variableToExport_1D{iiVar}).data(iiData));
        if isfield(dataset.variables.(variableToExport_1D{iiVar}),'flag')
            qcValue =  something2str( dataset.variables.(variableToExport_1D{iiVar}).flag(iiData));
            fprintf(fid, '"%s","%s",',varValue,qcValue);
        else
            fprintf(fid, '"%s",',varValue);
        end
    end
    
    fprintf(fid, '\n');
end

fclose(fid);
end