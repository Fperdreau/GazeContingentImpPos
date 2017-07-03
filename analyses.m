% Analysis script including additional analyses asked during reviewing
% process
%
% @author: Florian Perdreau
% @copyright: Florian Perdreau, University Paris Descartes, 2012

home; close all;

%% Get environment information
x = what;
PATH_TO_ROOT = x.path;
PATH_TO_FUNCTIONS = fullfile(PATH_TO_ROOT, 'Functions');
PATH_TO_DATA = fullfile(PATH_TO_ROOT, 'Data');
folder = PATH_TO_ROOT;

% Add folders to MATLAB path
addpath(genpath(PATH_TO_ROOT),...
    genpath([PATH_TO_FUNCTIONS, ':']),...
    genpath([PATH_TO_DATA, ':']),...
    '-end')

% Create folder settings
datafolder = fullfile(folder,'Data');
targetfold = fullfile(folder,'Data','Subjects');
dirlist = getcontent(targetfold,'dir');
nsub = numel(dirlist);
resultsFolder = fullfile(folder,'Data','Weibull_logarea_Results_FREE','Results - 0.75');

CSSdot = stylesheet('dot');
CSSline = stylesheet('line');
CSSlabel = stylesheet('label');
CSStick = stylesheet('tick');
CSSlegend = stylesheet('legend');
CSStitle = stylesheet('title');
CSStext = stylesheet('text');
CSSci = stylesheet('ci');

%% Criterion of rejection
fid = fopen(fullfile(datafolder,'Rejected.txt'),'w');
newind = cell(1,2);
for t = 1:2
    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
    crit1 = .75;
    if t == 1
        crit2 = 2;
    else
        crit2 = 10;
    end
    nsubt = numel(find(All.Beh.Perf(:,1) > 0));
    
    % Baseline condition
    ind1 = find(All.Beh.Perf(:,9) >= crit1);
    
    % Performance condition
    Perf = mean(All.Beh.Perf(ind1,1:8),2);
    Perf = (Perf - mean(Perf))./std(Perf);
    dev = zeros(nsub,1);
    dev(ind1) = Perf;
    newind{t} = All.Beh.Perf(:,9) >= crit1 & abs(dev) <= crit2;
    rej = find(All.Beh.Perf(:,9) < crit1 | abs(dev) > crit2);
    
    novices = All.Years(newind{t}) == 0;
    experts = All.Years(newind{t}) > 0;
    
    Ages = All.Age(newind{t});
    GroupAges = [mean(Ages(novices)),stde(Ages(novices)),mean(Ages(experts)),stde(Ages(experts))];
    
    fprintf(fid,'\r\n \r\n Experiment %d',t);
    fprintf(fid,'\r\n Age: Novices=%1.1f(%1.1f), Trained=%1.1f(%1.1f) \r\n',GroupAges);
    fprintf(fid,'\r\n Gender: Female=%d \r\n',sum(All.Gender(newind{t})==1));
    fprintf(fid,'\r\n n = %d/%d \r\n',sum(newind{t}),nsubt);
    fprintf(fid,'\r\n Subjects rejected : %s',dirlist{rej,:});
end
fclose(fid);

%% Sort for SPSS
load(fullfile(datafolder,'ExpParam.mat'));

figname = 'Revision';
indivFig = figure('name',figname);
set(indivFig, 'Name', figname,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 1920;
figSize_Y = 1080;
start_X = 0;start_Y = 0;
set(indivFig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

groups = zeros(nsub,2,2);
sorted_RT = zeros(nsub,9,2);
sorted_RTall = zeros(nsub,9);
RegRT = zeros(nsub,5,2);
nrows = 2;
ncols = 2;
cptfig = 1;

for t = 1:2
    
    subind = newind{t};
    rating = All.Rates.means;
    years = All.Years;
    
    if t == 1
        WinX = pi.*(const.Exp.VAapertType1./2).^2;
        step = [1 10 20 50 100 200 450];
        sizes = const.Exp.apertType1;
    else
        WinX = ((21^2)-(pi.*(const.Exp.VAapertType2./2).^2));
        WinX = [WinX(8:-1:1), (21)^2];
        step = 100:50:450;
        sizes = rot90(const.Exp.apertType2,2);
        sizes = [sizes(2:9) max(sizes)];
    end
    WinX(9) = (21^2);
    WinX = log(WinX);
    
    xlim = [log(step(1)),log(step(end))];
    xtick = roundn(log(step),-2);
    xticklabel = num2cell(step);
    
    for su = 1:nsub
        current_sub = dirlist{su,:};
        current_file = fullfile(targetfold,current_sub,sprintf('%s-%d.mat',current_sub,t));
        if exist(current_file,'file') == 0
            continue
        end
        load(current_file,'AllData');
        rtt = [];
        rtcat = [];
        rtsize = [];
        for b = 1:size(AllData.RT,1)
            rtt = [rtt, AllData.RT(b,:)];
            rtcat = [rtcat, AllData.cat(b,:)];
            rtsize = [rtsize, AllData.Win(b,:)];
        end
        rtt(rtt > const.Exp.trialDuration*1000) = const.Exp.trialDuration*1000;

        nsize = numel(sizes);
        for si = 1:nsize
            indrt = find(rtsize == sizes(si));
            sorted_RT(su,si,t) = mean(rtt(indrt));
        end
    end
    
    labels = {'Novices','Experts'};
    titles = {'Drawing skill','Experience'};
    for tt = 1:2
        if tt == 1
            novices = rating < median(rating(subind));
            experts = rating >= median(rating(subind));
        else
            novices = (years' == 0);
            experts = (years' > 0);
        end
        groups(:,tt,t) = experts; 
        
        subplot(nrows,ncols,cptfig);
        axis square;
        hold on
        gcol = copper(2);
        for g = 1:2
            if g == 1
                gg = novices;
            else
                gg = experts;
            end
            
            Yvalues = sorted_RT(subind & gg,1:9,t);
            
            plot(WinX,mean(Yvalues),'-o',CSSdot{:},'Color',gcol(g,:));
            plot(WinX,mean(Yvalues)+stde(Yvalues),'-','Color',gcol(g,:));
            plot(WinX,mean(Yvalues)-stde(Yvalues),'-','Color',gcol(g,:));   
        end
        set(gca,'XTick',xtick,CSStick{:});
        set(gca,'XTickLabel',xticklabel,CSStick{:});
        set(gca,'Xlim',xlim);
        set(gca,'Ylim',[2000 10000]);
        legend(labels,CSSlegend{:});
        xlabel('Viewable area (deg^2)',CSSlabel{:});
        ylabel('Reaction times (ms)',CSSlabel{:});
        title(titles{tt});
        cptfig = cptfig + 1;
    end
    
    for sub = 1:nsub
        sorted_RTall(sub,:,t) = mean(sorted_RT(sub,1:8,t));
        Reg = regstats(sorted_RT(sub,:,t),WinX);
        RegRT(sub,:,t) = [Reg.beta', Reg.tstat.se(2), Reg.tstat.t(2),Reg.tstat.pval(2)];
    end
    
    if t == 1
        clear WinX;
    end
    clear Alldata;

end

saveas(indivFig,fullfile(datafolder,'ReactionTime.pdf'));
close(indivFig);

%% Effect of window sizes on RT
fid = fopen(fullfile(datafolder,'Results.txt'),'w');
fprintf(fid,'SUPPLEMENTARY ANALYSIS FOR REVISION \r\n');

fprintf(fid,'\r\n \r\n Effect of Window sizes on RTs: \r\n');
RTstats = zeros(2,6);
for t = 1:2
    RTslope = RegRT(newind{t},2,t);
        
    [H,P,CI,STATS] = ttest(RTslope,0);
    cd = (mean(RTslope)-0)/std(RTslope);
    RTstats(t,:) = [STATS.df,STATS.tstat,CI',P,cd];
    fprintf(fid,'Experiment %d: mean:%1.1f(%1.1f), t(%d)=%1.2f[%1.2f,%1.2f], p=%1.3f, d=%1.2f \r\n',...
        t,mean(RTslope),stde(RTslope),RTstats(t,:));
end

%% Images in baseline
BasePerfres = zeros(nsub,2);
TestPerfres = zeros(nsub,2);
indlist = zeros(nsub,2);
for n = 1:nsub
    for t = 1:2
        load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
        indlist(n,t) = sum(All.ind == n);
        
        current_name = dirlist{n,:};
        current_file = fullfile(targetfold,current_name,sprintf('%s-%d.mat',current_name,t));
        if exist(current_file,'file') > 0
            load(current_file,'test','AllData');
        else
            fprintf('%s excluded \n',current_name);
            continue
        end
        
        Corr = [];
        RT = [];
        nblock = 8;
        for b = 2:9
            Corr = [Corr,AllData.Corr(b,:)];
            RT = [RT,AllData.RT(b,:)];
        end
        baselist = test.design(1:20,4);
        
        imglist = test.design(21:end,4);
        
        ind = zeros(size(imglist));
        for i = 1:numel(baselist)
            ind = ind + (imglist == baselist(i));
        end
        testlist = imglist(ind == 0);
            
        BasePerf = zeros(1,20);
        BaseRT = zeros(1,20);
        for i = 1:20
            ind = find(imglist == baselist(i));
            BasePerf(i) = sum(Corr(ind))/numel(ind);
            BaseRT(i) = mean(RT(ind));
        end
        
        TestPerf = zeros(1,numel(testlist));
        TestRT = zeros(1,numel(testlist));
        for i = 1:numel(testlist)
            ind = find(imglist == testlist(i));
            TestPerf(i) = sum(Corr(ind))/numel(ind);
            TestRT(i) = mean(RT(ind));
        end
        
        BasePerfres(n,t) = mean(BasePerf);
        TestPerfres(n,t) = mean(TestPerf);       
    end
end

fprintf(fid,'\r\n \r\n ANALYSIS OF OBJECT REPETITION: \r\n');

% Experiment 1: Central Window
Base1 = BasePerfres(indlist(:,1) == 1,1);
Test1 = TestPerfres(indlist(:,1) == 1,1);
[h, p, ci, stats] = ttest2(asin(sqrt(Base1)),asin(sqrt(Test1)));
fprintf(fid,'\r\n Experiment 1: Central Window');
fprintf(fid,'\r\n Mean Base: %1.2f, Mean Test: %1.2f, t(%d)=%1.2f,CI(95%%)=[%1.2f,%1.2f],p=%1.2f',...
    mean(Base1),mean(Test1),stats.df,stats.tstat,ci(1),ci(2),p);

% Experiment 2: Central Mask
Base2 = BasePerfres(indlist(:,2) == 1,2);
Test2 = TestPerfres(indlist(:,2) == 1,2);
[h, p, ci, stats] = ttest2(asin(sqrt(Base2)),asin(sqrt(Test2)));
fprintf(fid,'\r\n Experiment 2: Central Mask');
fprintf(fid,'\r\n Mean Base: %1.2f, Mean Test: %1.2f, t(%d)=%1.2f,CI(95%%)=[%1.2f,%1.2f],p=%1.2f',...
    mean(Base1),mean(Test1),stats.df,stats.tstat,ci(1),ci(2),p);

% All experiments
AllBase = [Base1;Base2];
AllTest = [Test1;Test2];
[h, p, ci, stats] = ttest2(asin(sqrt(AllBase)),asin(sqrt(AllTest)));
fprintf(fid,'\r\n All Experiments:');
fprintf(fid,'\r\n Mean Base: %1.2f, Mean Test: %1.2f, t(%d)=%1.2f,CI(95%%)=[%1.2f,%1.2f],p=%1.2f',...
    mean(Base1),mean(Test1),stats.df,stats.tstat,ci(1),ci(2),p);

%% Learning effect
fprintf(fid,'\r\n\r\n LEARNING EFFECT:\r\n');
Learn = zeros(nsub,9,2);
for t = 1:2
    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
        
    subind = newind{t};
    
    rating = All.Rates.means;
    years = All.Years;
    LearnInd = zeros(nsub,6);
    for n = 1:nsub
        Y = All.Beh.Perf(n,1:8);
        Y = asin(sqrt(Y));
        X = 1:8;
        stats = regstats(Y,X,'Linear');
        
        LearnInd(n,:) = [stats.beta',stats.rsquare,stats.tstat.se(2),stats.tstat.t(2),stats.tstat.pval(2)];
    end
    
    Learn(:,:,t) = [subind,rating >= median(rating(subind)), (years > 0)',LearnInd];
    
end

for t = 1:2
    Lslope = Learn(newind{t},5,t);
        
    [H,P,CI,STATS] = ttest(Lslope,0);
    cd = (mean(Lslope)-0)/std(Lslope);
    RTstats(t,:) = [STATS.df,STATS.tstat,CI',P,cd];
    fprintf(fid,'Experiment %d: mean:%1.3f(%1.3f), t(%d)=%1.2f[%1.2f,%1.2f], p=%1.3f, d=%1.2f \r\n',...
        t,mean(Lslope),stde(Lslope),RTstats(t,:));
end

%% FITTING
F = 'PAL_Weibull';
nruns = 10;
cutparam = .75;
confI = .68;
ParOrNonPar = 1;
GOF = 1;
GridGrain = 20;
searchGrid.beta = logspace(-2,2,GridGrain); % slope
searchGrid.gamma = .5;  %lapse-rate
whichfitparams = [1 1 0 1]; % [threshold slope guess-rate lapse-rate]
searchGrid.lambda = 0:.005:.05;  %lapse-rate
DTt = zeros(nsub,3,2);

for t = 1:2
    
    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
    load(fullfile(datafolder,'ExpParam.mat'),'p','const');
    
    subind = newind{t};
    Perf = All.Beh.Perf;

    % Convert sizes
    if t == 1
        WinX = pi.*(const.Exp.VAapertType1./2).^2;
    else
        WinX = ((21^2)-(pi.*(const.Exp.VAapertType2./2).^2));
        WinX = [WinX(8:-1:1),21^2];
    end
    WinX(9) = (21^2);
    WinX = log(WinX);

    % fit parameters
    n = [ones(1,8).*20,40,ones(1,2).*40];
    xvalues = [WinX, log(450), log(500)];
    
    % Curve fitting
    thres = zeros(1,nsub);
    slopes = zeros(1,nsub);
    rsquare = zeros(2,nsub);

    % Figure
    perffig = figure();
    name = 'IndivFits';
    set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
    figSize_X = 1600;
    figSize_Y = 1020;
    start_X = 0;start_Y = 0;
    set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

    xx = xvalues;
    if t == 1
        step = [1 10 20 50 100 200 450];
    else
        step = 100:50:450;
    end

    xlim = [log(step(1)),log(step(end))];
    xtick = roundn(log(step),-2);
    xticklabel = num2cell(step);
    
    ylim = [.4 1.05];
    ytick = .4:.1:1.05;
    
    nrows = 5;
    ncols = ceil(nsub/nrows);
    for s = 1:nsub

        current_name = dirlist{s,:};
        yvalues = round([Perf(s,:),ones(1,2).*Perf(s,end)].*n);

        searchGrid.alpha = linspace(0,max(xvalues),GridGrain); % cut at 75%
        [Fit, StimLevelsFineGrain, ~, probfit]= runPalFit(xvalues,yvalues,n,searchGrid,whichfitparams,nruns,ParOrNonPar,GOF,cutparam,confI,F);
        xfine = StimLevelsFineGrain;
        rsquare(:,s) = [Fit.GOF.Dev;Fit.GOF.pDev];
        thres(s) = Fit.cuts;
        slopes(s) = Fit.slope;
        ci = Fit.ciCuts;

        % Plot
        subplot(nrows,ncols,s);
        axis square;
        hold on
        plot(xfine,probfit);
        plot(xx,yvalues./n,'o',CSSdot{:});
        plot([xx(1) xx(end)],[.5 .5],'--','Color',[.5 .5 .5]);
        plot([1 1].*thres(s),[0 .75],'--','Color',[.3 .3 .3]);
        plot([ci(1) ci(2)],[.75 .75],'-','Color',[0 0 0]);
        set(gca,'XLim',xlim);
        set(gca,'YLim',ylim);
        set(gca,'YTick',ytick);
        set(gca,'XTick',xtick);
        set(gca,'XTickLabel',xticklabel);
        text(.1,.9,sprintf('%s\n D=%1.2f p=%1.2f',current_name,rsquare(:,s)),'Units','Normalized');
        text(.1,.7,sprintf('Mean rating: %1.2f',rating(s)),'Units','Normalized');
        text(.1,.6,sprintf('Threshold(@.75): %1.2f',exp(thres(s))),'Units','Normalized');
        hold off
    end
    
    DTt(:,:,t) = [subind, slopes', thres'];
    
    saveas(perffig,fullfile(datafolder,sprintf('IndivFits%d.pdf',t)));
    close all;
end

%% Statistics
fprintf(fid,'\r\n\r\n GROUP COMPARISONS: \r\n');

perffig = figure();
name = sprintf('Results');
set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0 0 1 1]);
figSize_X = 1920;
figSize_Y = 1080;
start_X = 0;start_Y = 0;
set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

nrows = 2;
ncols = 2;
cptfig = 1;

SPSSThres = zeros(nsub,5,2);
spssthres = cell(2,2);
for t = 1:2
    
    fprintf(fid,'\r\n Experiment %d: \r\n',t);
    
    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
    load(fullfile(datafolder,'ExpParam.mat'),'p','const');
    subind = newind{t};

    base = All.Beh.Perf(:,9);
    rating = All.Rates.means;
    years = All.Years;
    school = All.School;
    indlabel(years' == 0) = 1;
    indlabel(years' > 0 & school' == 0) = 2;
    indlabel(years' > 0 & school' == 1) = 3;
    indlabel = indlabel';
    Fit = DTt(:,2:3,t);
    Fit = [Fit(:,1),exp(Fit(:,2))];
    RT = sorted_RT(:,:,t);
    LearnEff = Learn(:,5,t);
    
    SPSSThres(:,:,t) = [subind,rating,years',school',Fit(:,2)];
    ylabels = {'Threshold size (deg^2)','Slope','p(correct)','RT (ms)','Learning rate'};
    sections = {'Threshold','Curve slope','Baseline performance','Baseline RT','Learning rate'};
    
    allstats = zeros(numel(ylabels),9,2);
    raw_pvals = zeros(2,numel(ylabels));
    for tt = 1:2
        if tt == 1
            novices = rating < median(rating(subind));
            experts = rating >= median(rating(subind));
        else
            novices = (years' == 0);
            experts = (years' > 0);
        end

        labelnov = indlabel(novices & subind);
        labelexp = indlabel(experts & subind);
        
        Thres_novice = Fit(novices & subind,2);
        Thres_expert = Fit(experts & subind,2);

        Slope_novice = Fit(novices & subind,1);
        Slope_expert = Fit(experts & subind,1);

        base_novice = base(novices & subind);
        base_expert = base(experts & subind);

        baseRT_novice = mean(RT(novices & subind,end),2);
        baseRT_expert = mean(RT(experts & subind,end),2);

        testRT_novice = mean(RT(novices & subind,1:8),2);
        testRT_expert = mean(RT(experts & subind,1:8),2);
        
        SlopeRT_novice = RegRT(novices & subind,2,t);
        SlopeRT_expert = RegRT(experts & subind,2,t);

        NOVICES = [Thres_novice,Slope_novice,base_novice,baseRT_novice,LearnEff(novices & subind)];
        EXPERTS = [Thres_expert,Slope_expert,base_expert,baseRT_expert,LearnEff(experts & subind)];
                    
        for n = 1:size(NOVICES,2)
            X = EXPERTS(:,n); Y = NOVICES(:,n);
            
            Data = [EXPERTS(:,n);NOVICES(:,n)];
            G = [ones(numel(EXPERTS(:,n)),1);ones(numel(NOVICES(:,n)),1).*2];
            
            if n == 1
%                 [p,h,stats] = ranksum(Data,G);
%                 [HL,CI] = HodgesLehmann(X,Y,'alpha',95,'runs',5000);
%                 printftext = sprintf('Experts:%1.1f(%1.1f), Novices:%1.1f(%1.1f), U=%d, n1:%d n2:%d, p=%1.3f, HL=%1.1f,CI=[%1.1f,%1.1f]',...
%                     median(X),stde(X),median(Y),stde(Y),stats.ranksum,numel(X),numel(Y),p,HL,CI);
                spssthres{t,tt} = [G,Data];
            end
            
            if n == 3
                nX = asin(sqrt(X)); nY = asin(sqrt(Y));
            elseif n>3 && n<5
                nX = log(X); nY = log(Y);
            else
                nX = X; nY = Y;
            end
            [h,p,ci,stats] = ttest2(nX,nY,[],'both','equal');
            d = cohend(nX,nY);
            allstats(n,:,tt) = [mean(X),stde(X),mean(Y),stde(Y),stats.df,stats.tstat,ci',d];
            
            raw_pvals(tt,n) = p;

        end
    end
        
    % Adjust p-value for multiple comparison
    corrected_pvals = zeros(size(raw_pvals));
    for n = 1:size(NOVICES,2)
        corrected_pvals(:,n) = bonf_holm(raw_pvals(:,n));
    end
    
    for tt = 1:2
        if tt == 1
            fprintf(fid,'\r\n \r\n --- Drawing skills ---\r\n');
            titlelab = 'Drawing skill';
            novices = rating < median(rating(subind));
            experts = rating >= median(rating(subind));
        else
            fprintf(fid,'\r\n \r\n --- Experience ---\r\n');
            titlelab = 'Experience';
            novices = (years' == 0);
            experts = (years' > 0);
        end
        
        labelnov = indlabel(novices & subind);
        labelexp = indlabel(experts & subind);
        
        Data = spssthres{t,tt}(:,2);
        G = spssthres{t,tt}(:,1);
        
        for n = 1:size(NOVICES,2) 
            printftext = sprintf('Experts:%1.2f(%1.2f), Novices:%1.2f(%1.2f), t(%1.1f)=%1.2f, CI(95%%)=[%1.2f,%1.2f], d=%1.2f, p=%1.3f',...
                allstats(n,:,tt),corrected_pvals(tt,n));
            fprintf(fid,'\r\n %s: ',sections{n});
            fprintf(fid,'%s',printftext);

            if n == 1
                if t == 1
                    datlim = 200;
                else
                    datlim = inf;
                end
                subplot(nrows,ncols,cptfig);
                hold on
                myboxplot(Data,G);
                subcol = copper(3);
                for g = 1:2
                    if g == 1
                        labs = labelexp;
                    else
                        labs = labelnov;
                    end
                    data = Data(G == g);
                    for l = 1:numel(labs)
                        if labs(l) == 1
                            cols = subcol(1,:);
                        elseif labs(l) == 2
                            cols = subcol(2,:);
                        else
                            cols = subcol(3,:);
                        end
                        plot(g,data(l),'o','Color',cols,'MarkerSize',6,'MarkerFaceColor',cols);
                    end
                end

                set(gca,'Xtick',[1 2]);
                set(gca,'Xticklabel',{'Trained','Untrained'});
                set(gca,'Xlim',[0 3]);
                ymax = max(Data);
                ymin = min(Data);
                if t == 1
                    ylim = [0 150];
                else
                    ylim = [0, ceil(ymax + .15*ymax)];
                end
                set(gca,'Ytick',0:50:max(ylim));
                set(gca,'Ylim',ylim);

                title(titlelab);
                ylabel(ylabels{n});
                
                text(.1,.95,sprintf('t(%1.1f)=%1.2f p=%1.3f',allstats(n,5:6),corrected_pvals(tt,n)),CSStext{:});

                axis square
                hold off

                cptfig = cptfig + 1;
            end
        end
    end
    
    fprintf(fid,'\r\n \r\n');
end
saveas(perffig,fullfile(datafolder,sprintf('Results.pdf')));
close all;

%% Correlations
fprintf(fid,'\r\n\r\n CORRELATIONS: \r\n');

Cookd = cell(1,2);
for t = 1:2
    
    % Correlations
    fig = figure();
    name = sprintf('Scatter plots: Exp %d',t);
    set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
    figSize_X = 1080;
    figSize_Y = 1080;
    start_X = 0;start_Y = 0;
    set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
    
    fprintf(fid,'\r\n Experiment %d \r\n',t);

    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
    subind = newind{t};
    nsub = sum(subind);
    Cookdist = zeros(nsub,nrows*ncols);

    % Variables
    rating = All.Rates.means(subind);
    years = All.Years(subind);
    school = All.School(subind);
    age = All.Age(subind);
    RT = All.Beh.RT(subind,:);
    Perf = All.Beh.Perf(subind,:);
    base = Perf(:,9);
    mRTtest = mean(RT(:,1:8),2);
    mRTbase = mean(RT(:,9),2);
    RTslope = RegRT(subind,2,t);
    Fit = DTt(subind,2:3,t); 
    Slope = Fit(:,1);
    Thres = exp(Fit(:,2));
    LearnEff = Learn(subind,5,t);
    x = [years',rating,age'];
    y = [Thres,base,mRTbase,mRTtest,RTslope,LearnEff];
    ny = size(y,2);
    nx = size(x,2);

    dat = [y,x];
    [pobs, robs, CI, pcorrect, bias, rSample] = CorrBoot(dat,'type','Spearman','nruns',10000,'CI',0);   
    ylabels = {'Threshold','Base Perf','RT base','RT test','RT slope','Learning Rate'};
    xlabels = {'Years','Drawing','Age'};

    pvals = zeros(ny,nx);
    pcorr = zeros(ny,nx);
    CIs = zeros(2,ny,nx);
    rvals = zeros(ny,nx);
    Sample = zeros(size(rSample,1),ny,nx);
    for y = 1:ny
        for x = 1:nx
            pvals(y,x) = pobs(y,x+ny);
            rvals(y,x) = robs(y,x+ny);
            CIs(:,y,x) = [CI(y,x+ny,1);CI(y,x+ny,2)];
            Sample(:,y,x) = rSample(:,x+ny,y);
        end
        pcorr(y,:) = bonf_holm(pvals(y,:));
    end

    pcorr(pcorr > 1) = 1;
    pvals = pcorr;
    
    fprintf(fid,'\r\n Speed-Accuracy tradeoff:\r\n'); 
    [pSA, rSA, saCI, pcorrect, bias] = CorrBoot([mean(Perf)',mean(RT)'],'type','Pearson','nruns',10000);
    saCI = [saCI(2,1,1);saCI(2,1,2)];
    fprintf(fid,'r(%d)=%1.2f, p=%1.2f, CI(95%%)=[%1.2f,%1.2f]',7,rSA(1,2),pSA(1,2),saCI(1),saCI(2));
    
    fprintf(fid,'\r\n Correlations Results:\r\n'); 

    subcol = copper(3);
    nrows = ny;
    ncols = nx;
    dataset = dat;
    cpt = 1;
    for y = 1:ny
        yy = dataset(:,y);
        for x = 1:nx
            xx = dataset(:,x+ny);

            subplot(nrows,ncols,cpt);
            R = regstats(yy,xx,'Linear');
            xfine = linspace(min(xx),max(xx),1000);
            regline = R.beta(1) + R.beta(2).*xfine;
            [top_int, bot_int] = regression_line_ci(.05,R.beta,xx,yy,1000);

            hold on
            for xy = 1:numel(xx)
                if years(xy) == 0
                    col = subcol(1,:);
                elseif years(xy)>0 && school(xy)==0
                    col = subcol(2,:);
                else
                    col = subcol(3,:);
                end
                plot(xx(xy),yy(xy),'o','MarkerFaceColor',col,'MarkerEdgeColor',[0 0 0],'MarkerSize',2);
            end
            plot(xfine,regline,CSSline{:});
            plot(xfine,top_int,CSSci{:});
            plot(xfine,bot_int,CSSci{:});
            xlabel(xlabels{x},CSSlabel{:});
            ylabel(ylabels{y},CSSlabel{:});
            if min(xx) > 0
                set(gca,'Xlim',[min(xx)-.15*min(xx),max(xx)+.15*max(xx)]);
            else
                set(gca,'Xlim',[-1,max(xx)+.15*max(xx)]);
            end
            if y == 1
                if t == 1
                    set(gca,'ylim',[0 150]);
                    set(gca,'Yticklabel',0:50:150);
                else
                    set(gca,'ylim',[0 500]);
                    set(gca,'Yticklabel',0:50:500);
                end
            else
                set(gca,'Ylim',[min(yy)-.15*min(yy),max(yy)+.15*max(yy)]);
            end

            text(.1,.8,sprintf('r(%d)=%1.3f, p=%1.2f, CI(95%%)=[%1.3f,%1.3f]',nsub-2,rvals(y,x),pvals(y,x),CIs(:,y,x)),CSStext{:});
            fprintf(fid,sprintf('\r\n %s * %s: r(%d)=%1.3f[%1.3f,%1.3f], p=%1.3f',ylabels{y},xlabels{x},nsub-2,rvals(y,x),CIs(1,y,x),CIs(2,y,x),pvals(y,x)));
            hold off
            axis square
            cpt = cpt + 1;
        end
    end
    
    % Comparing correlation coefficients
    fprintf(fid,'\r\n Comparison of correlation coefficients: Experiment %d \r\n',t);
    r1 = rvals(1,1);
    r2 = rvals(1,2);
    r12 = robs(6,7);
    df = nsub -3;
    zr1 = atanh(r1);
    zr2 = atanh(r2);
    rm = ((r1^2)+(r2^2))/2;
    f = (1-r12)/(2*(1-rm));
    h = (1-(f*rm))/(1-rm);
    Z = (zr1 - zr2)*(sqrt(df)/(sqrt(2*(1-r12)*h)));
    pZ = normpdf(Z,0,1);
    CIz = (zr1-zr2) + [-1.96;1.96].*sqrt((2*(1-r12)*h)/(df));
    compare(t,:) = [Z,pZ];
    fprintf(fid,'Fisher test: r1=%1.2f, r2=%1.2f, Z=%1.2f, df:%1.2f, CI(95%%)=[%1.2f,%1.2f], p=%1.2f \r\n',...
        r1,r2,Z,df,CIz(1),CIz(2),pZ);
    
    saveas(fig,fullfile(datafolder,sprintf('ScatterPlots%d.pdf',t)));
    close all
    clear All
end
close all;

% Partial correlations
fprintf(fid,'\r\n\r\n PARTIAL CORRELATION ANALYSIS: \r\n');
for t = 1:2
    fprintf(fid,'\r\n Experiment %d \r\n',t);

    load(fullfile(resultsFolder,sprintf('Results-%d.mat',t)),'All');
    subind = newind{t};
    nsub = numel(subind);
    Cookdist = zeros(nsub,nrows*ncols);

    % Variables
    rating = All.Rates.means(subind);
    years = All.Years(subind);
    school = All.School(subind);
    age = All.Age(subind);
    Fit = DTt(subind,2:3,t); 
    Thres = exp(Fit(:,2));
    
    x = [years',age'];
    y = [Thres];
    ny = size(y,2);
    nx = size(x,2)-1;

    dat = [y,x];
    [pobs, robs, CI, pcorrect, bias, rSample] = PartialCorrBoot([Thres,years'],age','type','Spearman','nruns',10000,'CI',0);   
    ylabels = {'Threshold'};
    xlabels = {'Years','Drawing','Age'};

    pvals = zeros(ny,nx);
    pcorr = zeros(ny,nx);
    CIs = zeros(2,ny,nx);
    rvals = zeros(ny,nx);
    Sample = zeros(size(rSample,1),ny,nx);
    for y = 1:ny
        for x = 1:nx
            pvals(y,x) = pobs(y,x+ny);
            rvals(y,x) = robs(y,x+ny);
            CIs(:,y,x) = [CI(y,x+ny,1);CI(y,x+ny,2)];
            Sample(:,y,x) = rSample(:,x+ny,y);
        end
        pcorr(y,:) = bonf_holm(pvals(y,:));
    end

    pcorr(pcorr > 1) = 1;
    pvals = pcorr;
        
    dataset = dat;
    for y = 1:ny
        yy = dataset(:,y);
        for x = 1:nx
            xx = dataset(:,x+ny);
            fprintf(fid,sprintf('\r\n %s * %s: r(%d)=%1.2f[%1.2f,%1.2f], p=%1.3f',ylabels{y},xlabels{x},nsub-2,rvals(y,x),CIs(1,y,x),CIs(2,y,x),pvals(y,x)));
        end
    end
end
close all;
fclose(fid);
   
fprintf('\n Done \n');