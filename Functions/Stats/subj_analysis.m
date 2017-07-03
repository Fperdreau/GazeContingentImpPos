function subj_analysis(param, whichsub)
% -------------------------------------------------------------------------
% [All, param] = subj_analysis(param, whichsub)
% -------------------------------------------------------------------------
% Goal:
% Analysis of individual data
% -------------------------------------------------------------------------
% Inputs:
% param: struct array containing information about folders
% whichsub: subject to analyse (optional)
% -------------------------------------------------------------------------
% Outpus:
% status: analysis success or echec (0)
% All: struct array containing summary of individuals results
% -------------------------------------------------------------------------
%
% Created by Florian Perdreau (01/2012)
% -------------------------------------------------------------------------
if exist('whichsub','var') == 0
    whichsub = [];
else
    if ischar(whichsub)
        for d = 1:size(param.dirList,1)
            if strcmp(whichsub,param.dirList{d,:})
                whichsub = d;
                break;
            end
        end
    end          
end

if isempty(whichsub)
    whichsub = 1:size(param.dirList,1);
end

for s = whichsub
    param.s = s;
         
    for blocType = 1:2
        % load individual data
        param.blocType = blocType;
        param.foldername = param.dirList{s,:};
        param.subjectfolder = fullfile(param.targetfold,param.foldername);
        param = arrangefiles(param,blocType);
        if exist(param.filename,'file') == 0
            continue;
        end
        load(param.filename,'AllData','const','p','test');
        fprintf('******************** \n Processing of %s data \n ******************** \n',...
            param.foldername);
             
        %% Behavioral analysis 
        if exist(fullfile(param.SourceFolder,sprintf('Group-%d.mat',blocType)),'file') ~= 0
            if s == 1
                recycle('on');
                delete(fullfile(param.SourceFolder,sprintf('Group-%d.mat',blocType)));
                sprintf('Previous version of the file "Group-%d.mat" has been deleted',blocType)
            else
                load(fullfile(param.SourceFolder,sprintf('Group-%d.mat',blocType)),'All');
            end
        else
            All = [];
        end

        % Perform analyses
        [const, Data, Means, Fit, Sub] = analsub(const, AllData, test, param);

        %% save individual results
        name = fullfile(param.subresultsFolder,sprintf('%s-%d',param.foldername,param.blocType));
        recycle('on');
        if exist([name,'-Res.mat'],'file') ~= 0
            delete([name,'-Res.mat']);
        end
        save([name,'-Res.mat'],'Data','Means','Fit','const','Sub');

        clear Data Means const p test AllData All
    
    end % End of block loop
      
end % end of subject loop

end