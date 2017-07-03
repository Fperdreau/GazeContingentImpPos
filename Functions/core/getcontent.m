function content = getcontent(folder,filetype,ext)
% -------------------------------------------------------------------------
% content = getcontent(folder,filetype,ext)
% -------------------------------------------------------------------------
% Goal of the function:
% Get file or directories list from a specific path.
% -------------------------------------------------------------------------
% Inputs:
% folder: path to the target folder (absolute or relative).
% filetype : directories ('dir'), files ('file') or all files ('all') list..
% ext (only for files): extension of the wanted files.
% -------------------------------------------------------------------------
% Outputs:
% param: struct array providing information about folder hierarchy.
% -------------------------------------------------------------------------
% author: Florian Perdreau (florian.perdreau@parisdescartes.fr)
% Last update: 09/12/2015
% -------------------------------------------------------------------------

if nargin < 2
    error('You must provide a file type: "dir","file" or "all"');
elseif nargin < 3
    ext = '*';
end

dircontent = dir(folder);
dirIndex = [dircontent.isdir];

switch lower(char(filetype))
    case 'file'
        dircontent = {dircontent(~dirIndex).name};
        nfile = numel(dircontent);
        content = cell(1,1);
        ii = 1;
        for f = 1:nfile
            split = strsplit('.',dircontent{f});
            extension = split{end};
            if strcmp(extension, ext)
                content{ii,:} = dircontent{f};
                ii = ii+ 1;
            end
        end
    case 'dir'
        content = [];
        dircontent = {dircontent(dirIndex).name};
        validDir = ~ismember(dircontent,{'.','..'});
        if sum(validDir)>0
            content = dircontent(validDir);
        else
            warning('No directories in %s',folder);
        end
    case 'all'
        content = [];
        content = getcontent(folder,'file',ext);
        dirlist = getcontent(folder,'dir');
        ndir = numel(dirlist);
        for d = 1:ndir
            content = [content; getcontent(fullfile(folder,dirlist{d}),'file',ext)];
        end
    otherwise
        error('"%s" is not a valid argument. Please choose either "file","dir" or "all"',filetype);
end

%% Nested functions
function split = strsplit(delimiter, str)
    ind = strfind(str, delimiter);
    split = cell(1,numel(ind));
    onset = 1;
    for i = 1:numel(ind)
        split{i} = str(onset:ind(i)-1);
        onset = ind(i)+1;
    end
    split{end+1} = str(ind(end)+1:end); % Append last chunk
end


end
