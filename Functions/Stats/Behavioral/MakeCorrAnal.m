function [cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,type,opt,sdx,sdy,Xobs,Yobs)
 
if ~exist('Xobs','var')
    Xobs = xvalues;
end

if isfield(param,'silent')
    graph = ~param.silent;
end

if ~exist('Yobs','var')
    Yobs = yvalues;
end

if ~exist('type','var')
    opt = 'simple';
end

if ~exist('sdx','var') || isempty(sdx)
    sdx = zeros(size(xvalues));
end

if ~exist('sdy','var') || isempty(sdy)
    sdy = zeros(size(yvalues));
end

%% Compute correlation
if strcmp(type,'simple') || strcmp(type,'both')
    [stats fig] = corrfig(Xobs,Yobs,{'type',param.whichCorr},0,name,labels);
    cor.stats = stats;
    reg = [];
    p = stats(2);
    
    % save figures
    if ~isempty(fig)
        plotR = fullfile(param.resultsFolder,strcat(name,'-Rdist'));
        saveas(fig,strcat(plotR,'.pdf'));
    end
end
        
if strcmp(type,'boot') || strcmp(type,'both')
    %% Compute correlation
    Ropt = opt.corr;

    [stats fig] = myCorrBootstrap2(xvalues,yvalues,Ropt,name,labels);

    cor.corr = [stats.Vcor,stats.H, stats.SE];
    cor.df = length(xvalues);
    cor.ci = stats.ci;
    cor.SE = stats.SE;
    cor.quart = stats.quar;
    cor.rSample = stats.Rsample;
    r = stats.Vobs;
    df = length(xvalues)-1;
    rCI = stats.ci;

    % save figures
    plotR = fullfile(param.resultsFolder,strcat(name,'-Rdist'));
    saveas(fig,strcat(plotR,'.pdf'));
    
    %% Compute Linear regression
    RegOpt = opt.reg;

    [stats fig] = myRegBootstrap2(xvalues,yvalues,RegOpt,name,labels);

    reg.LinB.stats= [stats.B.cor,stats.B.H, stats.B.SE];
    reg.LinI.stats = [stats.I.cor,stats.I.H, stats.I.SE];
    reg.LinR.stats = [stats.R.cor,stats.R.H, stats.R.SE];
    reg.LinB.ci = stats.B.ci;
    reg.LinI.ci = stats.I.ci;
    reg.LinR.ci = stats.R.ci;
    reg.Fstats = stats.Fstat;
    R = stats.R.obs(1);
    RCI = stats.R.ci;
    Fstat = stats.Fstat;

    Bobs = stats.B.obs;
    Iobs = stats.I.obs;
    B = stats.B.SE;  

    % save figures
    plotReg = fullfile(param.resultsFolder,strcat(name,'-Regdist'));
    saveas(fig,strcat(plotReg,'.pdf'));

end

if strcmp(type,'boot') || strcmp(type,'both')

%% Plot the results
perffig = figure();
plotcorr_file=fullfile(param.resultsFolder,strcat(name,'.pdf'));
set(perffig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 800;
figSize_Y = 600;
start_X = 0;start_Y = 0;
set(perffig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
if param.silent
    set(gcf,'Visible','off');
end

% Graph settings
black = [0,0,0];
gray = [0.5,0.5,0.5];
blue = [0,0,1];
red  = [1,0,0];
redd = [.7,0,0];
fontsize = 12;

xvalues = Xobs;
yvalues = Yobs;
x = sort(xvalues);
yN = zeros(3,length(x));
yN(1,:) = Bobs.*x + Iobs;
yN(2,:) = (Bobs - B).*x + (Iobs-(stats.I.SE));
yN(3,:) = (Bobs + B).*x + (Iobs+(stats.I.SE));

sorted_x = x;
minY = min(yvalues)-sdy(yvalues == min(yvalues));
maxY = max(yvalues)+sdy(yvalues == max(yvalues));
minX = min(xvalues)-sdx(xvalues == min(xvalues));
maxX = max(xvalues)+sdx(xvalues == max(xvalues));
ylim = [minY(1) maxY(end)];
xlim = [minX(1) maxX(end)];
ytick = roundn(linspace(floor(ylim(1)),ceil(ylim(2)),10),-1);
xtick = roundn(linspace(floor(xlim(1)),ceil(xlim(2)),10),-1);
xticklabel = xtick;

width_th = 2;
alpha = opt.corr.alpha;

set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
set(gca,'YTick',ytick);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',xtick);
set(gca,'YTickLabel',ytick);
xlabel(labels{2});
ylabel(labels{3});
title(labels{1});

hold on

% plot linear regression
reglinOb = plot(sorted_x,yN(1,:));
set(reglinOb,'LineWidth', width_th,'Color', red,'LineStyle','-')

reglinL = plot(sorted_x,yN(2,:));
set(reglinL,'LineWidth', width_th,'Color', redd,'LineStyle','--')
reglinU = plot(sorted_x,yN(3,:));
set(reglinU,'LineWidth', width_th,'Color', redd,'LineStyle','--')

hold on
% Draw data points
for tLevel = 1:max(size(xvalues))
    x = xvalues(tLevel);
    y = yvalues(tLevel);
    sdX = sdx(tLevel)/2;
    sdY = sdy(tLevel)/2;
    num = 10;
    dataP(tLevel) = plot(x,y,'o');
    dataPerr(tLevel,:) = myerrorbar(x,y,sdX,sdY);
    set(dataP(tLevel),'MarkerSize',num,'MarkerFaceColor',gray,'MarkerEdgeColor',black);
    set(dataPerr(tLevel,1),'LineWidth',2,'Color',black,'LineStyle','-');
    set(dataPerr(tLevel,2),'LineWidth',2,'Color',black,'LineStyle','-');
    set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
end

text(0.1,0.9,sprintf('r(%1.0f)=%1.3f, CI(%1.0f)=[%1.3f;%1.3f], p=%1.3f',df,r,(1-alpha)*100,rCI(1),rCI(2),p),'Units','normalized','FontSize',fontsize);
text(0.1,0.8,sprintf('Adj R2 = %1.2f, F(%d,%d) = %1.2f, p = %1.3f',R,Fstat(2),Fstat(3),Fstat(1),Fstat(4)),'Units','normalized','FontSize',fontsize);

hold off

% save figures
saveas(perffig,plotcorr_file);

end

close all hidden;

end