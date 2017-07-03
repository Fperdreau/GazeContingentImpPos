e = log([450 500]);
   
w = ones(size(e)).*40;

xvalues = [WinX, e];
n = [ones(1,8).*20,40];
yvalues = round([Results.Means.Perf.*n,Results.Means.Perf(end).*w]);
n = [n,w];

% find slope (linear approximation)
stats = regstats(yvalues,xvalues,'linear');
betaS = stats.beta(2,1)*2;
betaS = 1/((max(xvalues')-min(xvalues'))/4);
% fit parameters
nruns = 400;
cutparam = param.thres;
confI = .68;
ParOrNonPar = 1;
GOF = 1;
GridGrain = 5;
searchGrid.alpha = linspace(mean(xvalues),max(xvalues),GridGrain); % cut at 75%
searchGrid.beta = exp(betaS) + logspace(-1,2,GridGrain); % slope
searchGrid.gamma = .5;%linspace(.5,.6,GridGrain);  %guess-rate
searchGrid.lambda = .10;  %lapse-rate

whichfitparams = [1 1 0 0]; % [threshold slope guess-rate lapse-rate]


[Fit, StimLevelsFineGrain, ~, probfit]= runPalFit(xvalues,yvalues,n,searchGrid,whichfitparams,nruns,ParOrNonPar,GOF,cutparam,confI);
xfine = StimLevelsFineGrain;
cutEst = Fit.cuts;
v = Fit.slope;

xvalues = WinX;
yvalues = Results.Means.Perf;

fprintf('\n Fitting Results \n');
fprintf('Slope: %1.2f \n',v)
fprintf('Thres: %1.2f \n',cutEst);
fprintf('Guess: %1.2f \n', Fit.paramsValues(3));
fprintf('Lapse: %1.2f \n', Fit.paramsValues(4));
fprintf('GOF: %1.2f \n', Fit.GOF.pDev); 

%% Performance plot
% Figure settings
perffig = figure();
name = sprintf('Exp: %d', param.blocType);
plotperf_file=fullfile(param.resultsFolder,sprintf('Exp-%d_Perf.pdf',param.blocType));
set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 800;
figSize_Y = 600;
start_X = 0;start_Y = 0;
set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

% Graph settings
black = [0,0,0];
gray = [0.7,0.7,0.7];
blue = [0,0,1];
red  = [1,0,0];
fontsize = 12;

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

% Threshold values
thVal = param.thres;
SDth = std(Results.Means.Perf)/sqrt(numel(ind));
CIth = [cutEst - SDth; cutEst + SDth];

% Threshold percent
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
set(pl_th1,'LineWidth', width_th *1.2,'Color', black,'LineStyle','-')
pl_thL = plot(0*y_thresh+CIth(1),y_thresh);
pl_thU = plot(0*y_thresh+CIth(2),y_thresh);
set(pl_thL,'LineWidth', width_th *0.9,'Color', gray,'LineStyle','--')
set(pl_thU,'LineWidth', width_th *0.9,'Color', gray,'LineStyle','--')

% Draw data points
for tLevel = 1:size(xvalues,2)
    x = xvalues(tLevel);
    y = yvalues(tLevel);
    sdy = Results.SD.Perf(tLevel);
    num = 20*.5;
    dataP(tLevel,:) = plot(x,y,'o');
    dataE(tLevel,:) = myerrorbar(x,y,[],sdy,'simple');
    set(dataP(tLevel),'MarkerSize',num,'MarkerFaceColor',red,'MarkerEdgeColor',black);
    set(dataE(tLevel),'MarkerSize',num,'MarkerFaceColor',red,'MarkerEdgeColor',black);
%     set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
end

text(0.1,0.9,sprintf('Threshold (@ %1.2f) = %1.3f',thVal,exp(cutEst)),'Units','normalized','FontSize',fontsize);
text(0.1,0.8,sprintf('Slope = %1.3f',v),'Units','normalized','FontSize',fontsize);