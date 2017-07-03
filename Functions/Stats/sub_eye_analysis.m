function [All, param] = sub_eye_analysis(param, whichsub)
% -------------------------------------------------------------------------
% [All, param] = subj_eye_analysis(param, whichsub)
% -------------------------------------------------------------------------
% Goal:
% Analysis of individual eye movements data
% -------------------------------------------------------------------------
% Inputs:
% param: struct array containing information about folders
% whichsub: subject to analyse (optional)
% -------------------------------------------------------------------------
% Outpus:
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
        
        % Convert EDF files to ASC
        status = edf2asc(param);
        if status == 0
            sprintf('Conversion edf2asc has been skiped');
        end


        %% Eye tracking analysis
        for blocknum = 1:9
            param.blocknum = blocknum;

            % Data extraction 
            % First analysis configuration :
            [anaEye] = xanaEyeMovements(p,const);

            % Create a tab file from ascFile : EL saccade data
            [ascMat, fixVal, sacVal] = xasc2tab(const,test,param);
        end
        
        %% save data
        name = fullfile(param.subresultsFolder,sprintf('%s-%d',param.foldername,param.blocType));
        recycle('on');
        if exist([name,'-Sac.mat'],'file') ~= 0
            delete([name,'-Sac.mat']);
        end
        save([name,'-Sac.mat'],'ascMat', 'fixVal', 'sacVal','anaEye');

        clear ascMat fixVal sacVal anaEye const p test  
    end % End of block loop
      
end % end of subject loop

end