function dataset = netCDFParse (inputFileName,varargin)
%%netCDFParse retrieves all information stored in the NetCDF file.
%
% The NetCDF parser function, named netCDFParse, is the core of the
% “IMOS user code library”. This function parses a NetCDF file, wether
% from a local address or an OPeNDAP URL, and harvests its entire
% content into the workspace
%
%
% Inputs:
%    inputFileName : opendap URL or local address of the NetCDF file
%
% Optional arguments:
%    'parserOption' , [parserOption]
%     [parserOption]   'all'       => to retrieve the entire file
%                      'metadata'  => to retrieve metadata only
%
%
%    'varList' , [varList]   => Parse only a specified set of variables
%
%
% Outputs:
%    dataset         : struct
%
% Example:
%   dataset = netCDFParse (inputFileName, 'parserOption' , [parserOption] , 'varList' , [varList] )
%
%
%    netCDFParse('/path/to/netcdfFile.nc' , 'varList' , {'PSAL' , 'TEMP'})
%    will only grab data and metadata for both PSAL and TEMP
%
%    netCDFParse('/path/to/netcdfFile.nc' , 'parserOption' , 'all', 'varList' , {'PSAL' , 'TEMP'})
%    will parse absolutely everything, because 'parserOption' has the value
%    'all'. This is similar to call
%    netCDFParse('/path/to/netcdfFile.nc' , 'varList' , {'PSAL' , 'TEMP'})
%
%    netCDFParse('/path/to/netcdfFile.nc' , 'parserOption' , 'metadata', 'varList' , { 'TEMP'})
%    will parse all global attributes plus data only for the TEMP variable
%
% Other m-files required:
% Other files required:nctoolbox, http://code.google.com/p/nctoolbox/
% Subfunctions: none
% MAT-files required: none
%
% See also:
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Jan 2013; Last revision: 22-Jan-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

dataset=struct;

if ~ischar(inputFileName),          error('inputFileName must be a string value');        end


%% section to read the optional arguments
optargin = size(varargin,2);
if optargin > 0
    for ii_optargin = 1:2:optargin
        
        if ~ischar(varargin{1}),          error('%s must be a string value',varargin{1});        end
        
        if strcmpi(varargin{ii_optargin} , 'parserOption')
            parserOptionValue = varargin{ii_optargin+1};
            
            if  ~(strcmpi(parserOptionValue , 'all') || strcmpi(parserOptionValue , 'metadata'))
                error('%s is a bad option for parserOption',parserOptionValue);
            end
            
        elseif strcmpi(varargin{ii_optargin} , 'varList')
            variablesChoosenByUser = varargin{ii_optargin+1};
            
        else  error('%s is not a valid option',varargin{ii_optargin});
        end
        
    end
end

if exist('parserOptionValue','var');    else parserOptionValue='all' ;end

try
    nctoolbox_datasetInfo = ncdataset(inputFileName); %open the netcdf file
catch ME
    errorString = getErrorString(ME);
    error('netCDFParse:fileCheck',char(errorString))
end

%% collect global attributes
globalAttributes = nctoolbox_datasetInfo.attributes;
for iiGlobalAtt = 1:length(globalAttributes)
    dataset.metadata.(globalAttributes{iiGlobalAtt,1}) = globalAttributes{iiGlobalAtt,2};
end

%list ALL variables
listVariables = nctoolbox_datasetInfo.variables;

%list only all noqc variables
testFindString=strfind(listVariables,'_quality_control');
indexQCVar=~cellfun('isempty', testFindString);
listVariables_NOQC=listVariables(~indexQCVar);

% for each variable, list it's dimensions. result is string.
% if same dimension name is the same as the variable name, then it it a
% variable and not a dimension. This bit is tricky and proper to the
% nctoolbox behaviour.
idim=1;
ivar=1;
otherDimension=[];
for iiVar=1:length(listVariables_NOQC)
    if length(nctoolbox_datasetInfo.dimensions(listVariables_NOQC(iiVar))) == 1 && strcmpi(nctoolbox_datasetInfo.dimensions(listVariables_NOQC(iiVar)),listVariables_NOQC(iiVar))
        %then it is a dimension and not a variable
        dimensionsList(idim) = listVariables_NOQC(iiVar); % dimension variables with proper data values. some dimension might be missing from this list, in this case the values correspond to a vector of 1 to size of the dimension
        idim=idim+1;
    else
        variablesList(ivar) = listVariables_NOQC(iiVar);
        ivar=ivar+1;
    end
    
    otherDimension = cat(1, otherDimension , nctoolbox_datasetInfo.dimensions(listVariables_NOQC(iiVar)));
end

if exist('dimensionsList','var')
    dimensionsList = unique(cat(1,otherDimension,dimensionsList'));
else
    dimensionsList = unique(cat(1,otherDimension));
end

if ~exist('variablesChoosenByUser','var')
    variablesChoosenByUser=variablesList;
else
    if sum(strcmpi(variablesChoosenByUser, (variablesList))) == 0
        warning('variable does not exist in dataset','Variable %s does not exist in the NetCDF file. Only medata will be parsed',variablesChoosenByUser);
    end
    %check variable exist
end

variablesToExport = variablesChoosenByUser;
%% get variables , only QC ones
% for iiVar=1:length(variablesList)
for iiVar=1:length(variablesToExport)

    
    dimensionAssociated = nctoolbox_datasetInfo.dimensions(variablesToExport(iiVar))';
    
    dataset.variables.(variablesToExport{iiVar}).dimensions = [dimensionAssociated];
    
    varAttributes = nctoolbox_datasetInfo.attributes(variablesToExport(iiVar));
    
    for iiVarAttributes=1:size(varAttributes,1)
        attName=(varAttributes{iiVarAttributes,1});
        if  strfind(attName(1),'_') %remove the underscore at the beginning of an attribute
            attName=attName(2:end);
        end
        
        if isempty(regexp(attName,'ancillary_variables', 'once')) % we remove this attribute
            dataset.variables.(variablesToExport{iiVar}).(attName) = varAttributes{iiVarAttributes,2};
        end
    end
    
    if ~strcmpi (parserOptionValue,'metadata')
        if sum( strcmpi(variablesChoosenByUser, (variablesToExport{iiVar})) ~= 0)
            
            data =  nctoolbox_datasetInfo.data(variablesToExport(iiVar));
            
            dataset.variables.(variablesToExport{iiVar}).data = data;
            clear data
        end
    end
    %     dimensionAssociated = nctoolbox_datasetInfo.dimensions(listVariables_NOQC(iiVar))';
    %     dataset.variables.(variablesList{iiVar}).dimensions = [dimensionAssociated];
    %     varAttributes = nctoolbox_datasetInfo.attributes(variablesList(iiVar));
    %     
    %     for iiVarAttributes=1:size(varAttributes,1)
    %         attName=(varAttributes{iiVarAttributes,1});
    %         if  strfind(attName(1),'_') %remove the underscore at the beginning of an attribute
    %             attName=attName(2:end);
    %         end
    %         dataset.variables.(variablesList{iiVar}).(attName) = varAttributes{iiVarAttributes,2};
    %     end
    %
    %     if ~strcmpi (parserOptionValue,'metadata')
    %         if sum( strcmpi(variablesChoosenByUser, (variablesList{iiVar})) ~= 0)
    %
    %             data =  nctoolbox_datasetInfo.data(variablesList(iiVar));
    %
    %             dataset.variables.(variablesList{iiVar}).data = data;
    %             clear data
    %         end
    %     end
end



% when a dimension does not have any data, we need at least to know its size.
% The nctoolbox does not help to retrieve this information easily
% we can find this information looking at the size of the variable
% depending of this variable
%initialise the two next variables as cells does not work
% dimensionsNames = cell(1,length(variablesList));
% dimensionsSize = cell(1,length(variablesList));
dimensionsNames = [];
dimensionsSize = [];
% for iiVar=1:length(variablesList)
%     dimensionsNames = [dimensionsNames nctoolbox_datasetInfo.dimensions(listVariables_NOQC(iiVar))'];
%     dimensionsSize = [dimensionsSize nctoolbox_datasetInfo.size(listVariables_NOQC(iiVar))];
% end
for iiVar=1:length(variablesToExport)
    dimensionsNames = [dimensionsNames nctoolbox_datasetInfo.dimensions(variablesToExport(iiVar))'];
    dimensionsSize = [dimensionsSize nctoolbox_datasetInfo.size(variablesToExport(iiVar))];
end
[~, m_dim, ~] = unique(dimensionsNames) ;
dimensionsNames = dimensionsNames(m_dim);
dimensionsSize = dimensionsSize(m_dim);


%% get attributes and values of the 'dimensions' variables
for iiDim=1:length(dimensionsList)
    
    if  sum(strcmp(listVariables,dimensionsList{iiDim})) ~= 0
        dimAttributes = nctoolbox_datasetInfo.attributes(dimensionsList(iiDim));
    else
        dimAttributes = [];
    end
    
    dataset.dimensions.(dimensionsList{iiDim})=struct; % we initialise the structure, even if there is no data, nor metadata to fill in
    for iiDimAttributes = 1:size(dimAttributes,1)
        attName=(dimAttributes{iiDimAttributes,1});
        if  strfind(attName(1),'_') %remove the underscore at the beginning of an attribute
            attName=attName(2:end);
        end
        dataset.dimensions.(dimensionsList{iiDim}).(attName) = dimAttributes{iiDimAttributes,2};
    end
    
    if ~strcmpi (parserOptionValue,'metadata') % harvest data
        
        if  sum(strcmp(listVariables,dimensionsList{iiDim})) ~= 0 % means if there is no data for this dimension
            data =  nctoolbox_datasetInfo.data(dimensionsList(iiDim));
            dataset.dimensions.(dimensionsList{iiDim}).data = data;
            
        else
            
            data = ( 1:dimensionsSize( strcmpi(dimensionsNames,dimensionsList{iiDim})))';
            dataset.dimensions.(dimensionsList{iiDim}).data = data;
        end
        
        
    end
    clear data
end


%% add QC variables and flags
if ~strcmpi (parserOptionValue,'metadata')
%     for iiVar=1:length(variablesList)
%         
%         %first we look for the variable attribute ancillary variables to see if
%         %it exists. If the field does not exist, then we try to look for the
%         %qc variable assuming its name is <variable>_quality_control
%         if isfield(dataset.variables.(variablesList{iiVar}),'ancillary_variables')
%             ancillaryVariables = dataset.variables.(variablesList{iiVar}).ancillary_variables;
%             
%             ancillaryVariables_uncertainty = regexp(ancillaryVariables,'\w+uncertainty','match'); % this is not used yet ! in next version
%             ancillaryVariables_qc = regexp(ancillaryVariables,'\w+quality_control','match');
%             
%             if ~isempty(ancillaryVariables_qc)
%                 
%                 
%                 dataQC =  nctoolbox_datasetInfo.data(ancillaryVariables_qc{1});
%                 attNameQC = nctoolbox_datasetInfo.attributes(ancillaryVariables_qc{1});
%                 
%                 if (sum(strcmpi('quality_control_set',attNameQC(:,1)) == 0))
%                     quality_control_set = cell2mat(attNameQC(strcmpi('quality_control_set',attNameQC),2));
%                 else
%                     quality_control_set=1; %we assume it is IMOS
%                 end
%                 
%                 % quality_control_set=1  =>1, IMOS standard set using the IODE flags,                 0 1 2 3 4 5 6 7 8 9,       byte, 99
%                 % quality_control_set=2  =>2, ARGO quality control procedure,                         0 1 2 3 4 5 6 7 8 9,       byte, 99
%                 % quality_control_set=3  =>3, BOM quality control procedure (SST and Air-Sea fluxes), B C D E F G H L T U V X Z, char, 0
%                 
%                 if quality_control_set == 1     %IMOS standard set using the IODE flags
%                     flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
%                     flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
%                     flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                     
%                     flag_values = flag_values{:};
%                     flag_meanings = flag_meanings{:};
%                     flag_quality_control_conventions = flag_quality_control_conventions{:};
%                 elseif quality_control_set == 2 %ARGO quality control procedure
%                     
%                 elseif quality_control_set == 3 %BOM quality control procedure (SST and Air-Sea fluxes)
%                     flag_values = attNameQC(strcmpi('quality_control_flag_values',attNameQC),2);
%                     flag_meanings = attNameQC(strcmpi('quality_control_flag_meanings',attNameQC),2);
%                     flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                     
%                     flag_values = flag_values{:};
%                     flag_meanings = flag_meanings{:};
%                     flag_quality_control_conventions = flag_quality_control_conventions{:};
%                 else %we assume it is IMOS
%                     flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
%                     flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
%                     flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                     
%                     flag_values = flag_values{:};
%                     flag_meanings = flag_meanings{:};
%                     flag_quality_control_conventions = flag_quality_control_conventions{:};
%                 end
%                 
%                 dataset.variables.(variablesList{iiVar}).flag_meanings = flag_meanings;
%                 dataset.variables.(variablesList{iiVar}).flag_values = flag_values;
%                 dataset.variables.(variablesList{iiVar}).flag = dataQC;
%                 dataset.variables.(variablesList{iiVar}).flag_quality_control_conventions = flag_quality_control_conventions;
%                 dataset.variables.(variablesList{iiVar}).quality_control_set = quality_control_set;
%             end
%         else
%             try
%                 ancillaryVariables_qc=strcat(variablesList{iiVar},'_quality_control');
%                 if isempty(strfind(listVariables,ancillaryVariables_qc)) % if the variable name we just created is actually in the list of variables
%                     dataQC =  nctoolbox_datasetInfo.data(ancillaryVariables_qc);
%                     attNameQC = nctoolbox_datasetInfo.attributes(ancillaryVariables_qc);
%                     quality_control_set = cell2mat(attNameQC(strcmpi('quality_control_set',attNameQC),2));
%                     
%                     % quality_control_set=1  =>1, IMOS standard set using the IODE flags,                 0 1 2 3 4 5 6 7 8 9,       byte, 99
%                     % quality_control_set=2  =>2, ARGO quality control procedure,                         0 1 2 3 4 5 6 7 8 9,       byte, 99
%                     % quality_control_set=3  =>3, BOM quality control procedure (SST and Air-Sea fluxes), B C D E F G H L T U V X Z, char, 0
%                     
%                     if quality_control_set == 1     %IMOS standard set using the IODE flags
%                         flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
%                         flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
%                         flag_quality_control_conventions=attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                         
%                     elseif quality_control_set == 2 %ARGO quality control procedure
%                         
%                     elseif quality_control_set == 3 %BOM quality control procedure (SST and Air-Sea fluxes)
%                         flag_values = attNameQC(strcmpi('quality_control_flag_values',attNameQC),2);
%                         flag_meanings = attNameQC(strcmpi('quality_control_flag_meanings',attNameQC),2);
%                         flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                         
%                         flag_values = flag_values{:};
%                         flag_meanings = flag_meanings{:};
%                         flag_quality_control_conventions = flag_quality_control_conventions{:};
%                     else %we assume it is IMOS
%                         flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
%                         flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
%                         flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
%                         
%                     end
%                     
%                     dataset.variables.(variablesList{iiVar}).flag_meanings = flag_meanings;
%                     dataset.variables.(variablesList{iiVar}).flag_values = flag_values;
%                     dataset.variables.(variablesList{iiVar}).flag = dataQC;
%                     dataset.variables.(variablesList{iiVar}).flag_quality_control_conventions = flag_quality_control_conventions;
%                     dataset.variables.(variablesList{iiVar}).quality_control_set = quality_control_set;
%                     
%                 end
%             end
%         end
%         
%         
%     end
    for iiVar=1:length(variablesToExport)
        
        %first we look for the variable attribute ancillary variables to see if
        %it exists. If the field does not exist, then we try to look for the
        %qc variable assuming its name is <variable>_quality_control
        if isfield(dataset.variables.(variablesToExport{iiVar}),'ancillary_variables')
            ancillaryVariables = dataset.variables.(variablesToExport{iiVar}).ancillary_variables;
            
            ancillaryVariables_uncertainty = regexp(ancillaryVariables,'\w+uncertainty','match'); % this is not used yet ! in next version
            ancillaryVariables_qc = regexp(ancillaryVariables,'\w+quality_control','match');
            
            if ~isempty(ancillaryVariables_qc)
                
                
                dataQC =  nctoolbox_datasetInfo.data(ancillaryVariables_qc{1});
                attNameQC = nctoolbox_datasetInfo.attributes(ancillaryVariables_qc{1});
                
                if (sum(strcmpi('quality_control_set',attNameQC(:,1)) == 0))
                    quality_control_set = cell2mat(attNameQC(strcmpi('quality_control_set',attNameQC),2));
                else
                    quality_control_set=1; %we assume it is IMOS
                end
                
                % quality_control_set=1  =>1, IMOS standard set using the IODE flags,                 0 1 2 3 4 5 6 7 8 9,       byte, 99
                % quality_control_set=2  =>2, ARGO quality control procedure,                         0 1 2 3 4 5 6 7 8 9,       byte, 99
                % quality_control_set=3  =>3, BOM quality control procedure (SST and Air-Sea fluxes), B C D E F G H L T U V X Z, char, 0
                
                if quality_control_set == 1     %IMOS standard set using the IODE flags
                    flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
                    flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
                    flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                    
                    flag_values = flag_values{:};
                    flag_meanings = flag_meanings{:};
                    flag_quality_control_conventions = flag_quality_control_conventions{:};
                elseif quality_control_set == 2 %ARGO quality control procedure
                    
                elseif quality_control_set == 3 %BOM quality control procedure (SST and Air-Sea fluxes)
                    flag_values = attNameQC(strcmpi('quality_control_flag_values',attNameQC),2);
                    flag_meanings = attNameQC(strcmpi('quality_control_flag_meanings',attNameQC),2);
                    flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                    
                    flag_values = flag_values{:};
                    flag_meanings = flag_meanings{:};
                    flag_quality_control_conventions = flag_quality_control_conventions{:};
                else %we assume it is IMOS
                    flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
                    flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
                    flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                    
                    flag_values = flag_values{:};
                    flag_meanings = flag_meanings{:};
                    flag_quality_control_conventions = flag_quality_control_conventions{:};
                end
                
                dataset.variables.(variablesToExport{iiVar}).flag_meanings = flag_meanings;
                dataset.variables.(variablesToExport{iiVar}).flag_values = flag_values;
                dataset.variables.(variablesToExport{iiVar}).flag = dataQC;
                dataset.variables.(variablesToExport{iiVar}).flag_quality_control_conventions = flag_quality_control_conventions;
                dataset.variables.(variablesToExport{iiVar}).quality_control_set = quality_control_set;
            end
        else
            try
                ancillaryVariables_qc=strcat(variablesToExport{iiVar},'_quality_control');
                if isempty(strfind(listVariables,ancillaryVariables_qc)) % if the variable name we just created is actually in the list of variables
                    dataQC =  nctoolbox_datasetInfo.data(ancillaryVariables_qc);
                    attNameQC = nctoolbox_datasetInfo.attributes(ancillaryVariables_qc);
                    quality_control_set = cell2mat(attNameQC(strcmpi('quality_control_set',attNameQC),2));
                    
                    % quality_control_set=1  =>1, IMOS standard set using the IODE flags,                 0 1 2 3 4 5 6 7 8 9,       byte, 99
                    % quality_control_set=2  =>2, ARGO quality control procedure,                         0 1 2 3 4 5 6 7 8 9,       byte, 99
                    % quality_control_set=3  =>3, BOM quality control procedure (SST and Air-Sea fluxes), B C D E F G H L T U V X Z, char, 0
                    
                    if quality_control_set == 1     %IMOS standard set using the IODE flags
                        flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
                        flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
                        flag_quality_control_conventions=attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                        
                    elseif quality_control_set == 2 %ARGO quality control procedure
                        
                    elseif quality_control_set == 3 %BOM quality control procedure (SST and Air-Sea fluxes)
                        flag_values = attNameQC(strcmpi('quality_control_flag_values',attNameQC),2);
                        flag_meanings = attNameQC(strcmpi('quality_control_flag_meanings',attNameQC),2);
                        flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                        
                        flag_values = flag_values{:};
                        flag_meanings = flag_meanings{:};
                        flag_quality_control_conventions = flag_quality_control_conventions{:};
                    else %we assume it is IMOS
                        flag_values = attNameQC(strcmpi('flag_values',attNameQC),2);
                        flag_meanings = attNameQC(strcmpi('flag_meanings',attNameQC),2);
                        flag_quality_control_conventions = attNameQC(strcmpi('quality_control_conventions',attNameQC),2);
                        
                    end
                    
                    dataset.variables.(variablesToExport{iiVar}).flag_meanings = flag_meanings;
                    dataset.variables.(variablesToExport{iiVar}).flag_values = flag_values;
                    dataset.variables.(variablesToExport{iiVar}).flag = dataQC;
                    dataset.variables.(variablesToExport{iiVar}).flag_quality_control_conventions = flag_quality_control_conventions;
                    dataset.variables.(variablesToExport{iiVar}).quality_control_set = quality_control_set;
                    
                end
            end
        end
        
        
    end

end

%warning, don't change the following order. It is important to clean first,
%then to modify the values such as time. Otherwise there might be some
%conflits with the valid min and max values ...

%% clean variable and dimensions values - fillvalue offset ...
if ~strcmpi (parserOptionValue,'metadata')
    dataset = cleanNetCDFValues(dataset);
end

%% convert time from dimension and/or variable type
if ~strcmpi (parserOptionValue,'metadata')
    
    for iiDim=1:length(dimensionsList)
        if strcmpi( dimensionsList(iiDim), 'TIME')
            timeUnits =  dataset.dimensions.(dimensionsList{iiDim}).units;
            data = convertTimeToMatlab(dataset.dimensions.(dimensionsList{iiDim}).data,timeUnits); %convert time
            dataset.dimensions.(dimensionsList{iiDim}).data = data;
            clear data
        end
    end
    
    for iiVar=1:length(variablesToExport)
        if strcmpi( variablesToExport(iiVar), 'TIME')
            timeUnits =  dataset.variables.(variablesToExport{iiVar}).units;
            data = convertTimeToMatlab(dataset.variables.(variablesToExport{iiVar}).data,timeUnits);  %convert time
            dataset.variables.(variablesToExport{iiVar}).data = data;
            clear data
        end
    end
%     for iiVar=1:length(variablesList)
%         if strcmpi( variablesList(iiVar), 'TIME')
%             timeUnits =  dataset.variables.(variablesList{iiVar}).units;
%             data = convertTimeToMatlab(dataset.variables.(variablesList{iiVar}).data,timeUnits);  %convert time
%             dataset.variables.(variablesList{iiVar}).data = data;
%             clear data
%         end
%     end
end

%% add filename origine information
[~, nameNC, extNC] = fileparts(inputFileName);
dataset.metadata.netcdf_filename = [nameNC extNC];

end


function cleanedDataset = cleanNetCDFValues(dataset)
%%cleanNetCDFValues modifies the raw values from a NetCDF files according
% to CF or IMOS attributes names, such as scale factors, valid_min and max
% and Fillvalue. The dataset is afterwards ready to be used.
%
%
% Syntax:  cleanedDataset = cleanNetCDFValues(dataset)
%
% Inputs:
%    dataset  : array of doubles of time values to convert
%
% Outputs:
%    cleanNetCDFValues    : same structure as dataset, with modified values
%
% Example:
%   dataset = cleanNetCDFValues (inputFileName):
%   cleanedDataset = cleanNetCDFValues(dataset)
%
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: netCDFParse
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Jan 2013; Last revision: 22-Jan-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

cleanedDataset=dataset;
varnames= fieldnames(dataset.variables);

for iiVar=1:length(varnames)
    
    if isfield(dataset.variables.(varnames{iiVar}),'data')
        
        if isfield(dataset.variables.(varnames{iiVar}),'valid_min')
            cleanedDataset.variables.(varnames{iiVar}).data (dataset.variables.(varnames{iiVar}).data  <dataset.variables.(varnames{iiVar}).valid_min) = NaN;
        end
        
        if isfield(dataset.variables.(varnames{iiVar}),'valid_max')
            cleanedDataset.variables.(varnames{iiVar}).data(dataset.variables.(varnames{iiVar}).data > dataset.variables.(varnames{iiVar}).valid_max) = NaN;
        end
        
        if isfield(dataset.variables.(varnames{iiVar}),'FillValue')
            cleanedDataset.variables.(varnames{iiVar}).data(dataset.variables.(varnames{iiVar}).data  == dataset.variables.(varnames{iiVar}).FillValue) = NaN;
        end
        
        if isfield(dataset.variables.(varnames{iiVar}),'scale_factor') && ~isfield(dataset.variables.(varnames{iiVar}),'add_offset')
            cleanedDataset.variables.(varnames{iiVar}).data = dataset.variables.(varnames{iiVar}).data*varAtt.scale_factor;
        elseif isfield(dataset.variables.(varnames{iiVar}),'scale_factor') && isfield(dataset.variables.(varnames{iiVar}),'add_offset')
            cleanedDataset.variables.(varnames{iiVar}).data = dataset.variables.(varnames{iiVar}).data*dataset.variables.(varnames{iiVar}).scale_factor+dataset.variables.(varnames{iiVar}).add_offset;
        elseif ~isfield(dataset.variables.(varnames{iiVar}),'scale_factor') && isfield(dataset.variables.(varnames{iiVar}),'add_offset')
            cleanedDataset.variables.(varnames{iiVar}).data = dataset.variables.(varnames{iiVar}).data+dataset.variables.(varnames{iiVar}).add_offset;
        end
        
    end
end


dimensionsnames= fieldnames(dataset.dimensions);

for iiDim=1:length(dimensionsnames)
    
    if isfield(dataset.dimensions.(dimensionsnames{iiDim}),'data')
        
        
        if isfield(dataset.dimensions.(dimensionsnames{iiDim}),'valid_min')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data (dataset.dimensions.(dimensionsnames{iiDim}).data  <dataset.dimensions.(dimensionsnames{iiDim}).valid_min) = NaN;
        end
        
        if isfield(dataset.dimensions.(dimensionsnames{iiDim}),'valid_max')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data(dataset.dimensions.(dimensionsnames{iiDim}).data > dataset.dimensions.(dimensionsnames{iiDim}).valid_max) = NaN;
        end
        
        if isfield(dataset.dimensions.(dimensionsnames{iiDim}),'FillValue')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data(dataset.dimensions.(dimensionsnames{iiDim}).data  == dataset.dimensions.(dimensionsnames{iiDim}).FillValue) = NaN;
        end
        
        if isfield(dataset.dimensions.(dimensionsnames{iiDim}),'scale_factor') && ~isfield(dataset.dimensions.(dimensionsnames{iiDim}),'add_offset')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data = dataset.dimensions.(dimensionsnames{iiDim}).data*varAtt.scale_factor;
        elseif isfield(dataset.dimensions.(dimensionsnames{iiDim}),'scale_factor') && isfield(dataset.dimensions.(dimensionsnames{iiDim}),'add_offset')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data = dataset.dimensions.(dimensionsnames{iiDim}).data*dataset.dimensions.(dimensionsnames{iiDim}).scale_factor+dataset.dimensions.(dimensionsnames{iiDim}).add_offset;
        elseif ~isfield(dataset.dimensions.(dimensionsnames{iiDim}),'scale_factor') && isfield(dataset.dimensions.(dimensionsnames{iiDim}),'add_offset')
            cleanedDataset.dimensions.(dimensionsnames{iiDim}).data = dataset.dimensions.(dimensionsnames{iiDim}).data+dataset.dimensions.(dimensionsnames{iiDim}).add_offset;
        end
        
    end
end

end


function timeConverted =  convertTimeToMatlab (timeToConvert,units)
%%timeConverted converts a array of time values extracted from a netcdf file
% into a matlab readable value.
%
% The function uses a string called units which is usually written such as :
% 'days since ...' or 'seconds since ...' . The rest of the string is always
% written in the same way 'DD-MM-YYYY' (where DD=int(Day); MM=int(Month);
% YYYY=int(Year))
% in order to convert the time properly
%
% Syntax:  timeConverted =  convertTimeToMatlab (timeToConvert,units)
%
% Inputs:
%    timeToConvert  : array of doubles of time values to convert
%    units      : string of the unit attribut field in the NetCDF file
%
% Outputs:
%    timeConverted    : array of doubles of converted time values
%
% Example:
%   dataset = netCDFParse (inputFileName):
%   timeConverted = convertTimeToMatlab(dataset.dimensions.TIME.data, dataset.dimensions.TIME.units);
%
%
% Other m-files required:
% Other files required:
% Subfunctions: none
% MAT-files required: none
%
% See also: netCDFParse
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/
% Jan 2013; Last revision: 22-Jan-2013
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License
strOffset =units;
indexNum = regexp(strOffset,'[^0-9]*(\d{4})-(\d{2})-(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})*','tokens');

Y_off = str2double(indexNum{1}{1});
M_off = str2double(indexNum{1}{2});
D_off = str2double(indexNum{1}{3});
H_off = str2double(indexNum{1}{4});
MN_off= str2double(indexNum{1}{5});
S_off = str2double(indexNum{1}{6});

if ~isempty(regexpi(strOffset,'days'))
    NumDay = double(D_off+timeToConvert);
    preDATAmodified = datenum(Y_off, M_off, NumDay, H_off, MN_off, S_off);
    timeConverted = preDATAmodified;
    
elseif ~isempty(regexpi(strOffset,'seconds'))
    NumSec = double(S_off+timeToConvert);
    preDATAmodified = datenum(Y_off, M_off, D_off, H_off, MN_off, NumSec);
    timeConverted = preDATAmodified;
end
end
