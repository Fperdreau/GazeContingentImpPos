function [All, param] = Group_analysis(param)

param.minperf = .75; %[.60,.70,.75,.80,.85];
param.thresS = 2;

for blocType = 1:2
    
    param.blocType = blocType;

    for e = param.thresS
    
        param.thres = param.Eperf(e);
        %% Gather individual data
        list = getcontent(param.SourceFolder,'dir');       
        groupfile = fullfile(param.resultsFolder,sprintf('Exp%d_AllBehav.mat',blocType));
     
        if exist(groupfile,'file')~=0
            recycle('on');
            delete(groupfile);
        end

        for d = 1:length(list)
            file = fullfile(param.SourceFolder,list{d,:},sprintf('%s-%d-Res.mat',list{d,:},param.blocType));
            if exist(file,'file') ~= 0
                load(file,'Data','Fit','Means','Sub');
            else
                continue
            end

            All.Names{d} = Sub.Names;
            All.err(d) = Sub.err;
            All.Age(d) = Sub.Age;
            All.Gender(d) = Sub.Gender;
            All.School(d) = Sub.School;
            All.Freq(d) = Sub.Freq;
            All.Years(d) = Sub.Years;
            All.Exp(d) = Sub.Exp;

            All.Fit.PSE(d) = real(Fit.PSE(e));
            All.Fit.CiCuts(d,:) = Fit.ciCuts(:,e)';
            All.Fit.SECuts(d) = Fit.SECuts(e);
            All.Fit.Slope(d) = Fit.Slope;
            All.Fit.SEslop(d) = Fit.SEslop;
            All.Fit.Betas(d) = Fit.beta;
            All.Fit.CiSlop(d,:) = Fit.ciSlop;
            if isfield(Fit,'GOF')
                All.Fit.GOF(d) = Fit.GOF(2);
            end
            All.Fit.Bias(d,:) = Fit.bias;
%             All.Fit.BootCuts(:,d) = Fit.Bootcuts(:,e);
%             All.Fit.BootSlop(:,d) = Fit.Boot.paramsSim(:,2);
            All.Fit.Boot{d} = Fit.Boot;
            All.Fit.Probfit(d,:) = Fit.probfit;

            All.Beh.Perf(d,:) = Means.Perf;
            All.Beh.RT(d,:) = Means.RT;
            All.Beh.SubRT(:,:,d) = [Data.RT',Data.win',Data.cat'];

            clear Data Fit Means Sub
        end

        %% Check if indiv data exists
        val = zeros(size(All.Fit.PSE));
        for i = 1:length(All.Fit.PSE)
            if ~isempty(All.Fit.Boot{i})
                val(i) = 1;
            else
                val(i) = 0;
            end
        end
        
        for minperf = param.minperf
            fprintf('Exp: %d | Criterion: %1.2f \n',blocType,minperf);
           param.min = minperf;
            %% conditions
            cond = val == 1 & (All.Beh.Perf(:,9) >= minperf)';
            ind = find(cond == 1);
            All.ind = ind;
            save(groupfile,'All');

            %% Get drawing scores
            Rates = GetdrawScore(param);
            Results.Rates = Rates;
            All.Rates = Rates;    

            %% Analyse group means vs. window size
            [Beh All] = GroupMeanAna(param,All);
            Results.Beh = Beh;

            %% Correlations
            Cor = Correlations2(param,All);
            Results.Cor = Cor;
                        
            %% Save results
            % Move files to subfolders
            ResultsFold = fullfile(param.resultsFolder,sprintf('Results - %1.2f',minperf));
            if ~isdir(ResultsFold)
                mkdir(ResultsFold);
            end
            pdflist = getcontent(param.resultsFolder,'file','pdf');
            matlist = getcontent(param.resultsFolder,'file','mat');
            x = find(strcmp(matlist,'ExpParam.mat'));
            matlist = [matlist(1:x-1);matlist(x+1:end)];
            
            if ~isempty(matlist) && ~isempty(pdflist)
                list = [pdflist;matlist];
            elseif isempty(matlist)
                list = pdflist;
            else
                list = matlist;
            end
            for i = 1:size(list)
                old = fullfile(param.resultsFolder, list{i,:});
                new = fullfile(ResultsFold,list{i,:});
                movefile(old,new);
            end
            save(fullfile(ResultsFold,sprintf('Results-%d.mat',blocType)),'Results','All');
        end % End of perf loop (minperf)
    end % End of thresholds loop
    clear('All', 'Results');
end % End of blockType loop


%% Learning effect
name = 'Learning_effect';
file = fullfile(param.resultsFolder,strcat(name,'.pdf'));
[Results, fig] = bytrial(param,1,name,{'Learning Effect','Blocks','Mean performance'},{'Central Window','Scotoma'});
saveas(fig,file);
save(fullfile(param.resultsFolder,'Learning.mat'),'Results');
close all;

%% Summary plots
% summaryplotCorr(param);

end
