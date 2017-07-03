function [const, Data, Means, Fit, Sub] = analsub(const, AllData, test, param)

% -------------------------------------------------------------------------
% [const, All, Data, Means] = analsub(const, AllData,test, param)
% -------------------------------------------------------------------------
% Goal:
% Analysis of individual data
% -------------------------------------------------------------------------
% s: number of the subject
% const : subject information
% AllData: individual data
% test: experiment information
% -------------------------------------------------------------------------
% const: subject information
% All : summary
% Data: individual results
% Means: individual means (for group analysis)
% -------------------------------------------------------------------------
%
% Created by Florian Perdreau (01/2012)
% -------------------------------------------------------------------------

%% Matrices
sizDa = size(AllData.Resp);
sizW = length(const.Exp.apert);

blocstep = sizDa(2);
Data.Corr = zeros(1,sizDa(1)*sizDa(2));
Data.Resp = zeros(1,sizDa(1)*sizDa(2));
Data.RT = zeros(1,sizDa(1)*sizDa(2));
Data.win = zeros(1,sizDa(1)*sizDa(2));
Data.cat = zeros(1,sizDa(1)*sizDa(2));
Data.Perf = zeros(sizDa(2),sizDa(1));
Data.RTs = Data.Perf;
Data.img = test.design(:,4)';

%% Load Data of the second pretest;
if param.group == 1
    if param.blocType == 1
        file = fullfile(param.subjectfolder,sprintf('%s-2.mat',param.foldername));
    elseif param.blocType == 2
        file = fullfile(param.subjectfolder,sprintf('%s-1.mat',param.foldername));
    end

    if exist(file,'file')
        x = load(file,'AllData');
        x = x.AllData;   

        in = 1;
        en = blocstep;
        for i = 1:sizDa(1)
            Resp(in:en) = x.Resp(i,:);
            RT(in:en) = x.RT(i,:);
            win(in:en) = x.Win(i,:);
            cat(in:en) = x.cat(i,:);
            in = in + blocstep;
            en = en + blocstep;
        end

        % only keep pretest data
        ind = find(win == max(win));
        Resp = Resp(ind);
        RT = RT(ind);
        cat = cat(ind);
        clear x
    else
        Resp = [];
        RT = [];
        cat = []; 
    end
else
    Resp = [];
    RT = [];
    cat = [];
end

%% Reorganize data
in = 1;
en = blocstep;
for i = 1:sizDa(1)
    Data.Corr(in:en) = AllData.Corr(i,:);
    Data.Resp(in:en) = AllData.Resp(i,:);
    Data.RT(in:en) = AllData.RT(i,:);
    Data.win(in:en) = AllData.Win(i,:);
    Data.cat(in:en) = AllData.cat(i,:);
    in = in + blocstep;
    en = en + blocstep;
end

%% Individual info
% Age
Sub.Names = const.sub.name;
Sub.Age = str2double(const.sub.Age);

% Gender
if strcmp(const.sub.Gender,'f')
    Sub.Gender = 1; % f=1
else
    Sub.Gender = 2; % m=2
end

% School
Sub.School = const.sub.School; % 0 or 1

% Experience
if isfield(const.sub,'Freq') == 0
    const.sub.Freq = 0;
end
if strcmp(const.sub.Freq,'Daily')
    Freq = 365;
elseif strcmp(const.sub.Freq,'Weekly')
    Freq = 52;
elseif strcmp(const.sub.Freq,'Monthly')
    Freq = 12;
else
    Freq = 0;
end
Sub.Freq = Freq;
Sub.Years = str2double(const.sub.Exp);
if Freq == 0
    Sub.Exp = 0;
else
    Sub.Exp = (Freq/365)*Sub.Years;
end

%% Window sizes
fitparam = GetFitParam(param,const);
Data.WinX = fitparam.WinX;
apert = fitparam.apert;

%% trash trials with RTs > time trial
Data.RT(Data.RT > const.Exp.trialDuration*1000) = const.Exp.trialDuration*1000;
RT(RT > const.Exp.trialDuration*1000) = const.Exp.trialDuration*1000;

%% store response correctness for each window size
Data.perf = Data.Resp == Data.cat;
Perf = Resp == cat;

%% Compare results
for w = 1:sizW
    Data.Perf(:,w) = Data.perf(Data.win == apert(w))';
    Data.RTs(:,w) = Data.RT(Data.win == apert(w))';
end
Data.Perf = [Data.Perf,Perf'];
Data.RTs = [Data.RTs, RT'];

%% compute mean performance and RT for each window 
PreRTs = reshape(Data.RTs(:,9:end),1,numel(Data.RTs(:,9:end)));
meanPre = mean(PreRTs);
varRt = std(PreRTs)/sqrt(size(PreRTs,2));
Perfs = reshape(Data.Perf(:,9:end),1,numel(Data.Perf(:,9:end)));
meanPer = sum(Perfs)/size(Perfs,2);

Means.RT = [mean(Data.RTs(:,1:8)), meanPre];
Means.Var.RT = [std(Data.RTs(:,1:8))/sqrt(size(Data.RTs,1)), varRt];
Means.Perf = [sum(Data.Perf(:,1:8))/size(Data.Perf,1), meanPer];

fprintf('Sujet: %s | Exp: %d\n',const.sub.name,const.blocType);
disp(Means.Perf);

if Means.Perf(9) < param.Eperf
    fprintf('Subject %s is too bas. His max perf is %1.2f \n', const.sub.name, max(Means.Perf));
    Sub.err = 1;
else
    Sub.err = 0;
end

%% Curve fitting (Palamedes)
if max(Data.WinX) > 10
    e = [450 500];
else
    e = log([450 500]);
end

w = ones(size(e)).*40;
xvalues = [Data.WinX, e];
yvalues = [sum(Data.Perf(:,1:8)),sum(sum(Data.Perf(:,9:end))),Means.Perf(end).*w];
[n, ~] = size(Data.Perf);
n = [ones(1,8).*n, (n+numel(Resp)),w];

% find slope (linear approximation)
stats = regstats(yvalues,xvalues,'linear');
betaS = stats.beta(2,1)*2;

% fit parameters
nruns = 100;
cutparam = param.Eperf;
confI = .68;
ParOrNonPar = 1;
GOF = 1;
GridGrain = 5;
searchGrid.alpha = linspace(0,max(xvalues),GridGrain); % cut at 75%
searchGrid.beta = betaS+logspace(-1,2,GridGrain); % slope
searchGrid.gamma = .5:.005:.6;%linspace(.5,.6,GridGrain);  %guess-rate
searchGrid.lambda = 0:.005:.10;%linspace(0,.06,GridGrain);  %lapse-rate
whichfitparams = [1 1 1 1]; % [threshold slope guess-rate lapse-rate]

[Results, StimLevelsFineGrain, ~, probfit]= runPalFit(xvalues,yvalues,n,searchGrid,whichfitparams,nruns,ParOrNonPar,GOF,cutparam,confI);
xfine = StimLevelsFineGrain;
Fit.paramsValues = Results.paramsValues;
Fit.PSE = Results.cuts;
Fit.Cuts = Results.bootcuts;
Fit.SECuts = Results.SEcuts;
Fit.ciCuts = Results.ciCuts;
Fit.beta = betaS;
Fit.Slope = Results.slope;
Fit.SEslop = Results.SEslop;
Fit.ciSlop = Results.ciSlop;
if GOF == 1
    Fit.GOF = [Results.GOF.Dev, Results.GOF.pDev];
end
Fit.bias = Results.bias;
Fit.Bootcuts = Results.bootcuts;
Fit.Boot = Results.Boot;
Fit.probfit = probfit;

fprintf('\n Fitting Results \n');
fprintf('Slope: %1.2f \n',Fit.Slope)
fprintf('Thres: %1.2f \n',Fit.PSE(2));
fprintf('Guess: %1.2f \n', Results.paramsValues(3));
fprintf('Lapse: %1.2f \n', Results.paramsValues(4));
fprintf('GOF: %1.2f \n', Fit.GOF(2)); 

%% plot the result for each window size
% % Values
xvalues = Data.WinX;
thVal = .75;
CI = Results.ciCuts(:,cutparam == .75)';
cuts = Results.cuts(cutparam == .75);
% Threshold percent
yvalues = Means.Perf;
cutEst = cuts;
cutCI = CI;
xfine = xfine;

% Figure settings
rtfig = figure();
name = sprintf('Exp: %d | Subject: %s', param.blocType,const.sub.name(1:2));
plotrt_file=fullfile(param.subresultsFolder,sprintf('RT_%s_%d_psyCurves.pdf',param.foldername,param.blocType));
set(rtfig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 800;
figSize_Y = 600;
start_X = 0;start_Y = 0;
set(rtfig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
if param.silent
    set(gcf,'Visible','off');
end
% Graph settings
black = [0,0,0];
gray = [0.7,0.7,0.7];
blue = [0,0,1];
red  = [1,0,0];
fontsize = 12;

% Plot Reaction time
errorbar(xvalues,Means.RT,Means.Var.RT,'o','linewidth',2);

% Axis
if param.blocType == 1
    step = [1 10 20 50 100 200 500];
else
    step = 100:50:500;
end
xlim = [log(step(1)),log(step(end))];
xtick = roundn(log(step),-2);
xticklabel = num2cell(step);
set(gca,'XLim',xlim);
set(gca,'YLim',[0, max(Means.RT(1:8))]);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',xticklabel);

title('RT as a function of window sizes');
xlabel('Windows diameter (visual angle)');
ylabel('Reaction times (in msec)');

% save figures
saveas(rtfig,plotrt_file);

%% Performance plot
% Figure settings
perffig = figure();
name = sprintf('Exp: %d | Subject: %s', param.blocType,const.sub.name(1:2));
plotperf_file=fullfile(param.subresultsFolder,sprintf('Perf_%s_%d_psyCurves.pdf',param.foldername,param.blocType));
set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 800;
figSize_Y = 600;
start_X = 0;start_Y = 0;
set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
if param.silent
    set(gcf,'Visible','off');
end

% Plot Performance fitting
% Axis
if param.blocType == 1
    step = [1 10 20 50 100 200 500];
else
    step = 100:50:500;
end
xlim = [log(step(1)),log(step(end))];
xtick = roundn(log(step),-2);
xticklabel = num2cell(step);
ylim = [.45,1.05];
ytick = 0:0.1:1;
set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
set(gca,'YTick',ytick);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',xticklabel);

% Values
v = Results.paramsValues(2);
x_th = xvalues;
y_th = thVal;
width_th = 2;
y_thresh = ylim(1):0.1:ylim(2);

% Draw psych curve
hold on
plot(xfine, probfit, '-', 'color', blue, 'linewidth', width_th );

% Draw threshold level
pl_th = plot(x_th,0*x_th+y_th);
set(pl_th,'LineWidth', width_th,'Color', gray,'LineStyle','-')

% Draw threshold line
pl_th1 = plot(0*y_thresh+cutEst,y_thresh);
set(pl_th1,'LineWidth', width_th *1.2,'Color', blue,'LineStyle','-')
pl_th_ci1 = plot(0*y_thresh+cutCI(1),y_thresh);
set(pl_th_ci1,'LineWidth', width_th,'Color', gray,'LineStyle','--')
pl_th_ci2 = plot(0*y_thresh+cutCI(2),y_thresh);
set(pl_th_ci2,'LineWidth', width_th,'Color', gray,'LineStyle','--')

% Draw data points
for tLevel = 1:size(xvalues,2)
    x = xvalues(tLevel);
    y = yvalues(tLevel);
    num = n(tLevel)*.5;
    dataP(tLevel) = plot(x,y,'o');
    set(dataP(tLevel),'MarkerSize',num,'MarkerFaceColor',red,'MarkerEdgeColor',black);
    set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
end

text(0.1,0.9,sprintf('Threshold (@ %1.2f) = %1.3f, CI=[%1.3f,%1.3f]',thVal,exp(cutEst),exp(cutCI(1)),exp(cutCI(2))),'Units','normalized','FontSize',fontsize);
text(0.1,0.8,sprintf('Slope = %1.3f',v),'Units','normalized','FontSize',fontsize);

% save figures
saveas(perffig,plotperf_file);

close all hidden;
clear Resp RT cat

end