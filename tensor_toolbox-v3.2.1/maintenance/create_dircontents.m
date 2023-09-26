function C = create_dircontents(dirname,varargin)%CREATE_DIRCONTENTS Scan a directory and create a contents list.%%   C = CREATE_DIRCONTENTS(DIR) creates a list of function names and%   descriptions that can be used to create a Contents.m file or be%   inserted into the constructor for a class.%%   C = CREATE_DIRCONTENTS(DIR,'Copyright',false) skips the copyright%   check.%%   C = CREATE_DIRCONTENTS(DIR,'Debug',true) prints out extra information.%%   See also UPDATE_CLASSLIST, CREATE_TOPCONTENTS.%% Parse inputsparams = inputParser;params.addParameter('Debug',false);params.addParameter('Copyright',true);params.parse(varargin{:});debug = params.Results.Debug;copyright = params.Results.Copyright;%% Get the directory contentsD = dir(dirname);if (numel(D) == 0)    error('ERROR: Cannot find directory!');end%% Check which files to keepif (debug)    fprintf('\nDetermining the m-files.\n');endcnt = 0;for i = 1:numel(D)    fname = D(i).name;    if D(i).isdir, continue, end    if isempty(regexp(fname,'.*\.m$','once')), continue, end    if regexp(fname,'^tmp_','once'), continue, end    if strcmp(fname,'Contents.m'), continue, end    if regexp(fname,'^tt_','once')        if ~(strcmp(fname,'tt_ind2sub.m') || strcmp(fname,'tt_sub2ind.m'))            continue        end    end    if debug        fprintf('Valid filename: %s\n', fname);    end    cnt = cnt + 1;    F{cnt} = fname;end%% Extract the descriptionsif (debug)    fprintf('\nExtracing the M-file descriptions.\n');endfor i = 1:cnt    % Open file    fname = fullfile(dirname,F{i});    fid = fopen(fname);    if (fid == -1)        error('Unable to open file %s',fname);    end    % Find function declaration    while 1        tline = fgetl(fid);        if ~ischar(tline)            error('No function declaration in %s', fname);        end        if regexp(tline,'^function.*')            break;        end    end    % Find title line    while 1        tline = fgetl(fid);        if tline == -1            break        end        if regexp(tline,'^%.*')            fname = regexp(tline,'%([A-Z_0-9]*)\s*(.*)','tokens');            name{i} = lower(fname{1}{1});            desc{i} = fname{1}{2};                        if ~isequal(name{i},F{i}(1:end-2))                warning('Filename/description mismatch for %s', name{i});            elseif isempty(regexp(desc{i},'\.\s*$','once'))                warning('Missing final period for description in %s', name{i});            end                        break;        end    end    % Find copyright    if copyright            c = 0;        while 1            fline = fgetl(fid);            if ~ischar(fline), break, end            if strcmp(fline,'%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>')                c = 2;                break;             end        end        if c == 0            warning('Missing link in %s',[dirname '/' F{i}]);        end    end        fclose(fid);        end%% Clean up contents linesw =  max(cellfun(@length,name));pat = sprintf('%%-%ds - %%s',w);for i = 1:cnt    C{i} = sprintf(pat,name{i},desc{i});    if (debug)        fprintf('Descp for %-30s: %s\n',F{i},C{i});    endend