function obj = imosAccumarray(obj,unitOfTime, varargin)
%%Facilitates use of inbuilt function accumarray with imos timeseries
% data imported by ncParse.
%
% Elements from a data set are grouped by the input time interval 
% and a function is applied to each group ('mean' by default).
% This function can be used to compute bin averages and statistical 
% summaries for a time series.
%
%Inputs: 
%   obj             a structure created using ncParse
%   unitOfTime      'second', 'minute', 'hour', 'day','month', or 'year'.
%                   the interval periods are taken to be from the start 
%                   of each unit of measure. 
%                   e.g. specifying 'day', the interval will be 
%                   from 00:00:00 on day n to 23:59:59 on day n+1
%
% Optional arguments:
%
%   [fun],[vars]    one or more couplets of a function name fun plus a list of 
%                   variables to apply that function to.
%         [fun]     any function can be used provided it accepts a vector and 
%                   returns a scalar value. e.g. inbuilt functions 
%                   'mean','mode','median','max','min','sum' etc. A user defined
%                   function can also be used if in its own file and known to 
%                   the matlab path. Default is mean.
%        [vars]     optional cell array of variable names, if not present 'fun' 
%                   will be applied to all variables. Vars must be specified 
%                   if more than one [fun],[vars] couplet is used.
% 'flags',[flags]   vector of qc flags. Only data points with these values will 
%                   be included when 'fun' is applied. The mode of the flags of 
%                   the included data points is taken as the qc flag for the 
%                   new data set.
%
% Output:
% A copy of obj with data fields replaced with the modified time series
% the long_name variable attribute is edited to reflect the function and 
% time interval that has been applied.
%
% Examples:
%
% D2 = imosAccumarray(D1,'day','range',{'TEMP','PRESSURE'},...
%                              'median',{TURB},'flags',[0 1]);
% Computes daily range for TEMP and PRESSURE, daily median for 'TURB' and
% mean (default) for all other variables. Ignores any datapoints that are not 
% flagged with a 1 or 0.
%
% D2 = imosAccumarray(D1,'month','max','flags',[0 1]);
% Computes monthly maximum for all variables ignoring any datapoints that are not 
% flagged with a 1 or 0.
%
% Other m-files required: none
% Other files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ncParse, outputCSV
%
% Author: Paul Rigby, AIMS/IMOS
% email: p.rigby@aims.gov.au
% Website: http://imos.org.au/
% Oct 2013; 
%
% Copyright 2013 IMOS
% The script is distributed under the terms of the GNU General Public License

%% Deal with the optional input arguments

% Set defaults:
flagsToInclude = 0:10; 

% Create a lookup table to map function to variable, default is mean
varFunMap = fieldnames(obj.variables);
for i=1:length(varFunMap);
  varFunMap{i,2} = 'mean';
end

if ~isempty(varargin)
  for i=1:length(varargin)
      if strfind(varargin{i},'flag')    %use strfind so flag or flags is ok
        %the next entry should be a vector
        if isnumeric(varargin{i+1})
          flagsToInclude = varargin{i+1};
        else
          error('flags option should be followed by a vector of flags to include.')
        end  
        %remove this couplet from the list 
        varargin(i:i+1) = [];
        break
      end
  end
end

if length(varargin) == 1
  for i=1:length(varFunMap);
    varFunMap{i,2} = varargin{:};
  end
elseif length(varargin) > 1
  for i = 1:2:length(varargin)
    for j = 1:length(varargin{i+1})
      for k = 1:size(varFunMap,1)
        if strcmp(varargin{i+1}{j},varFunMap{k,1})
          varFunMap{k,2} = varargin{i};              
        end
      end     
    end
  end
end

%% TIME dimension
% FIXME dimension can be time or TIME - make case insensitive?

%convert to a datevec.
D = datevec(obj.dimensions.TIME.data);

%enumerate the unitOfTime so it represents a datevec index
%also add a few aliases.
switch unitOfTime
    case {'years','year','yearly','Y',1};         Ti = 1;   
    case {'months','month','monthly','M',2};      Ti = 2;
    case {'days','day','daily','D',3};            Ti = 3;
    case {'hours','hour','hourly','h',4};         Ti = 4;
    case {'minutes','minute','m',5};              Ti = 5;
    case {'seconds','second','s',6};              Ti = 6;
    otherwise
        error('Unit of time not recognised');        
end

% force a consistent tag so that output files are standard
tags = {'yearly','monthly','daily','hourly','minute','second'};

%Find elements in the date vector that are unique up
%until our chosen unit of time. 
[~, ~, idx] = unique(D(:,1:Ti),'rows');

%compute a midpoint based upon the time range within each interval e.g. min + range/2
intervalMidpoint = accumarray(idx,obj.dimensions.TIME.data,[],@(x) {min(x)+0.5*range(x)});

%replace the original data with the new time intervals
obj.dimensions.TIME.data = cell2mat(intervalMidpoint);
obj.dimensions.TIME.name = ['TIME','_',tags{Ti},'_interval_midpoint'];

%% Variables
vars = fieldnames(obj.variables);

for i = 1:size(varFunMap,1)
    var = varFunMap{i,1};
    fun = varFunMap{i,2};        
    try
        flags = obj.variables.(var).flag;
        %convert to single as int8 trips up mode function (and
        %others)
        flags = single(flags);
        qcAvailable = true;
        %get the index of flags that are not on our list
        flagsToDiscard = setdiff(flags,flagsToInclude);                  
        badIndex = find(ismember(flags,flagsToDiscard));      
    catch e
        warning(['No QC flags found for variable',var]);
        qcAvailable = false;
    end

    if sum(sum(flags))==0
        warning(['All QC flags are zero for variable',vars{i}])
    end

    originalData = obj.variables.(vars{i}).data;
    if qcAvailable == false
        badIndex = [];
    end

    %Mark as nan the data points with qc that we want to remove.
    originalData(badIndex) = NaN;
    
    outputData = accumarray(idx,originalData,[],@(x) {executeFunction(x,fun)});
    outputData = cell2mat(outputData);

    %replace the original data in the structure
    obj.variables.(var).data = outputData;
    obj.variables.(var).name = [obj.variables.(var).name,'_',tags{Ti},'_',fun];
    
    %In the same manner, roll up the flags using 'mode' to 
    %give an *indication* of the quality of the processed data.
    %'mode' is already resiliant to NaN
    flags(badIndex) = NaN;
    if qcAvailable
        averagedQcFlags = accumarray(idx,flags,[],@(x) {mode(x)});
        averagedQcFlags = cell2mat(averagedQcFlags);
        %replace flags with averaged flags
        obj.variables.(var).flag = averagedQcFlags;
    end                                                
end
end

function y = executeFunction(x,fun)
  %The NaNs are necessary to keep the array structure, but
  %we need to remove them before executing the function as they will
  %cause functions such as mean to return NaN
  x(isnan(x)) = [];
  y = eval([fun,'(x)']);
  if isempty(y)
    y = single(NaN);
  end
end
  

