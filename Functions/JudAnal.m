function JudAnal

% Select images according to their rates.
% Florian Perdreau 2011

    %% Mac/Windows compatibility
    if strcmp(computer, 'PCWIN')
        warning off MATLAB:DeprecatedLogicalAPI;
        folder=fullfile('E:','My Dropbox','PHD','Matlab'); % PC perso (win)
    %     folder=fullfile('c:\','Florian','Matlab'); % PC box (win)
    else
    %     folder='/Users/lab/Documents/FP/Matlab'; %PC box (mac)
        folder='/Users/florian/Dropbox/PHD/Matlab'; % PC office (mac)
    end

    addpath(folder,[folder,'/Stimuli'],[folder,'/Functions'],[folder,'/Data'],'-end')
    addpath([folder,'/Functions','/Exp_functions'],...
        [folder,'/Functions','/Graphic'],...
        [folder,'/Functions','/System'],...
        [folder,'/Functions','/Conversion'],...
        [folder,'/Functions','/Config'],...
        [folder,'/Functions','/Eyelink'],...
        [folder,'/Functions','/Stats'],'-end');
    savepath;
    
    %% Load Data & Files
    cd(fullfile(folder,'Data'));
    load 'JudObj.mat';
    
    %% Pre-allocation
    Si = size(Data.Resp);
    Resp = zeros(Si(1),Si(2));
    Img = sort(Data.Img(1,:));
    totalImg = max(max(Data.Img));
    total = length(find(Data.Resp(:,Img==1)));
    poss = zeros(1,totalImg);
    imp = zeros(1,totalImg);
   
    %% Load images
    cd(fullfile(folder,'/Stimuli'));
    load Obj.mat;

    %% General parameter
    level = 1;% - (1/size(Data.Resp,1));

    %% Sort the Data
    for i = 1:Si(1)
        x = [Data.Resp(i,:) ; Data.Img(i,:)]';
        x = sortrows(x,2);
        Resp(i,:) = x(:,1)';
    end

    for im = 1:totalImg
        poss(im) = length(find(Resp(:,Img==im) == 2))/total;
        imp(im) = 1-poss(im);
    end

    %% Display results
    countposs = sum(poss>=level);
    countimp = sum(imp>=level);
    disp(['Poss = ',num2str(countposs),' Imp = ',num2str(countimp)]);
    
    %% Save correct images
    Res(1,:) = Img;
    Res(2,:) = poss;
    Res(3,:) = imp;

    poscat = Mat(:,:,Res(1,Res(2,:)>=level));
    impcat = Mat(:,:,Res(1,Res(3,:)>=level));

    cd(fullfile(folder,'Stimuli'));
    save('TestImg.mat','poscat','impcat','Res');

end

