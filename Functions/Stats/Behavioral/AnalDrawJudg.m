function [meanDraw, cron]= AnalDrawJudg(param)
    
% Compute ratings of the drawings
    
    %% Load ratings
    load(fullfile(param.datafolder,'DrawRate.mat'),'Resp');

    %% Test inter- & intra-raters agreement
    cron = cronbach(Resp);
    
    %% Compute mean of the ratings for every drawing
    stp = 1;
    in = 1;
    en = stp;
    meanDraw = zeros(size(Resp,1)/stp,1);
    for k = 1:size(Resp,1)/stp
        meanDraw(k,:) = mean(Resp(in:en,:),2); 
        in = in + stp;
        en = en + stp;
    end
end