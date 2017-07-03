function [Results fig]= reganal(X,Y,opt)

if ~exist('X','var') || ~exist('Y','var')
    fprintf('Two variables are needed');
    return;
end

if isfield(opt,'cut')
    cut = opt.cut;
else
    cut = [];
end

if isfield(opt,'graph')
    graph = opt.graph;
else
    graph = 0;
end

if isfield(opt,'silent')
    silent = opt.silent;
else
    silent = 0;
end

if isfield(opt,'width')
    width = opt.width;
else
    width = 1;
end

if isfield(opt,'labels')
    labels = opt.labels;
else
    labels = {'Regression','X','Y'};
end

if isfield(opt,'name')
    name = opt.name;
else
    name = 'Regression';
end

%% compute regression
const = ones(size(X,1),1);
% Simple fitting
[b,bint,r,rint,stats] = regress(Y,[const,X]);

% find outliers
out = zeros(size(r));
for i = 1:size(r,1)
    if rint(i,1) < 0 && rint(i,2) > 0
        out(i) = 0;
    else
        out(i) = 1;
    end
end

st = regstats(Y,X);
f = st.fstat;
t = st.tstat;
CoeffTable = dataset({t.beta,'Coef'},{t.se,'StdErr'}, {t.t,'tStat'},{t.pval,'pVal'});      

% Robust fitting
[robustbeta, strob] = robustfit(X,Y);
RobCoeftab = dataset({robustbeta,'Coef'},{strob.se,'StdErr'}, {strob.t,'tStat'},{strob.p,'pVal'}); 

fine = 0:.001:1;
Robfit = robustbeta(1) + robustbeta(2).*fine;
Regfit = b(1) + b(2).*fine;

% find cut
if cut
    cuts = robustbeta(1) + robustbeta(2).*cut;
    Results.cuts = cuts;
end
    
% Store results
Results.Fstats = stats;
Results.Coef = CoeffTable;
Results.b = [b,bint];
Results.Robust = RobCoeftab;

%% Plot results
if graph
    fig = figure();
    set(fig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
    figSize_X = 800;
    figSize_Y = 600;
    start_X = 0;start_Y = 0;
    set(fig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
    if silent
        set(gcf,'Visible','off');
    end
    
    % Graph settings
    black = [0,0,0];
    gray = [0.5,0.5,0.5];
    blue = [0,0,1];
    red  = [1,0,0];

    subplot(1,2,1);
    hold on
    % plot data points
    data = plot(X,Y,'o');
    set(data,'Markersize',10,'MarkerFaceColor',gray,'MarkerEdgeColor',black);

    % plot reg lines
    robline = plot(fine,Robfit,'-');
    set(robline,'LineWidth', width,'Color',blue,'LineStyle','-');

    regline = plot(fine,Regfit,'r-');
    set(regline,'LineWidth', width,'Color',red,'LineStyle','-');
    
    hold off
    title(labels{1});
    xlabel(labels{2});
    ylabel(labels{3});
    text(0.1,0.9,sprintf('y = %1.3f + %1.3fx',robustbeta(1),robustbeta(2)),'Units','normalized');
    text(0.1,0.8,sprintf('R2=%1.2f, F(%d,%d)=%1.3f, p=%1.3f',stats(1),f.dfe,f.dfr,stats(2),stats(3)),'Units','normalized');

    subplot(1,2,2);
    % Residuals plots
    rcoplot(r,rint);
    
end
