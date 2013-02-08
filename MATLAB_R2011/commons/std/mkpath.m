function mkpath(directory)
if iscell(directory)
    directory=char(directory);
end
indexSeparator=regexp((directory),filesep);
nSeparator=length(indexSeparator);

if iscell(indexSeparator)
    indexSeparator=cell2mat(indexSeparator);
    nSeparator=length(indexSeparator);
end

for iiSeparator=1:nSeparator
    if exist(char(directory(1:indexSeparator(iiSeparator))),'dir') == 7
        %         sprintf('directory "%s" already
        %         exist',directory(1:indexSeparator(iiSeparator)))
    elseif exist(char(directory(1:indexSeparator(iiSeparator))),'dir') == 0
        mkdir(char(directory(1:indexSeparator(iiSeparator)))); % we create at each iteration the full path.
    end
    
end



%% last iteration
if exist(char(directory),'dir') ==0
    mkdir(char(directory));
end

end