function [All, param] = eye_analysis(param, whichsub)
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

param.skip = 0;
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
        
        if blocType == 1
            % Convert EDF files to ASC
            status = edf2asc(param);
            if status == 0
                sprintf('Conversion edf2asc has been skiped');
            end
        end

        %% Eye tracking analysis
        if param.skip == 0
            for blocknum = 1:9
                if blocknum == 1
                    ascfoldercontent = getcontent(param.ASCfolder,'file','asc');
                    if ~isempty(ascfoldercontent)
                        fprintf('Subject: %s | Exp: %d \n', const.sub.name,blocType);
                        asw = input('EL analysis - ASC files already exist. Overwrite(o), continue(c)? ','s');
                        if strcmp(asw,'c')
                            param.skip = 1;
                            break;
                        end
                    end
                end
                param.blocknum = blocknum;
                
                % Data extraction 
                const = eyeDataAnalysis(const, test, p, param);
            end
        end
        
        %% save data
        recycle('on');
        if exist([name,'-Res.mat'],'file') ~= 0
            delete([name,'-Res.mat']);
        end
        save([name,'-Res.mat'],'Data','Means','const');
        save(fullfile(param.resultsFolder,sprintf('Group-%d',param.blocType)),'All');

        clear Data Means const p test AllData
    
    end % End of block loop
      
end % end of subject loop

end