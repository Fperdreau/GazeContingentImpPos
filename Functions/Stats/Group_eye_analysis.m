function Group_eye_analysis(param)

for blocType = 2
    param.blocType = blocType;
    
    %% Gather EL data from every subject
    load(fullfile(param.datafolder,'ExpParam.mat'),'const','p');
    list = getcontent(param.EyeFolder,'dir');
    groupfile = fullfile(param.resultsFolder,sprintf('Exp%d_EL.mat',blocType));
       
    for d = 1:length(list)
        file = fullfile(param.EyeFolder,list{d,:},sprintf('%s-%d-Sac.mat',list{d,:},param.blocType));
        if exist(file,'file') ~= 0
            load(file,'sacVal','fixVal','ascMat');
        else
            continue
        end
        
        if isempty(sacVal)
            continue
        end
        
        if d == 1
            Sac = sacVal;
            Fix = fixVal;
        else
            Sac = [Sac;sacVal];
            Fix = [Fix;fixVal];
        end
              
        clear sacVal fixVal ascMat

    end
    
    %% Load behavioral data
    load(fullfile(param.resultsFolder,sprintf('Exp%d_AllBehav.mat',param.blocType)),'All');
    
    ind = All.ind;
    
    % Only keep good data
    t = zeros(size(Fix,1),1);
    s = zeros(size(Sac,1),1);
    for in = ind
        for i = 1:size(Fix,1)
            if Fix(i,1) == in
                t(i) = 1;
            end
        end
        for i = 1:size(Sac,1)
            if Sac(i,1) == in
                s(i) = 1;
            end
        end
    end
    Fix = Fix(t == 1,:);
    Sac = Sac(s == 1,:);
    
    %% Convert coordinates
    [Fix, Sac] = convcoord(const,p, Fix,Sac);
    
    %% Fixation map for every image
    Results = anaEyeMovements(param,const,Sac,Fix, ind);
    
    %% Save Data
    save(groupfile,'Sac','Fix','Results');
    clear Sac Fix const p
end