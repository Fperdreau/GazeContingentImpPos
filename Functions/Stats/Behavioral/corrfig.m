function [stats fig] = corrfig(X,Y,opt,graph,label,labels)



%% find dimension
[Mx Nx] = size(X);
[My Ny] = size(Y);

if Mx > 1
    X = median(X);
end

if My > 1
    Y = median(Y);
end

dimX = find(size(X)~=1, 1);
dimY = find(size(Y)~=1, 1);

if isempty(dimX)
    dimX = 1;
end
if isempty(dimY)
    dimY = 1;
end

if dimX == 2
    X = X';
end
if dimY == 2
    Y = Y';
end

%% Correlation
[r p] = corr(X,Y,opt{:});
stats = [r p];

%% plot the stat distribution + confidence interval 
if graph
    % Figure settings
    close all;
    fig = figure();
    set(fig, 'Name', label,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
    figSize_X = 800;
    figSize_Y = 600;
    start_X = 0;start_Y = 0;
    set(fig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

    % Graph settings
    black = [0,0,0];
    red  = [1,0,0];
    fontsize = 12;

    ylim = [0 max(Y)];
    xlim = [floor(min(X)) ceil(max(X))];
    ytick = linspace(ylim(1),ylim(end),10);
    xtick = round(xlim(1):round(length(X)/10):xlim(end));
    xticklabel = xtick; 

    % Plot correlation
    hold on
    % Draw data points
    for tLevel = 1:max(size(X))
        x = X(tLevel);
        y = Y(tLevel);
        num = 20*.5;
        dataP(tLevel) = plot(x,y,'o');
        set(dataP(tLevel),'MarkerSize',num,'MarkerFaceColor',red,'MarkerEdgeColor',black);
        set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
    end
    xlabel(labels{3});
    ylabel(labels{2});
    title(labels{1});

    text(0.1,0.9,sprintf('r(%1.0f) = %1.3f, p = %1.3f',Nx-2,r,p),'Units','normalized','FontSize',fontsize);
else
    fig = [];
end

end