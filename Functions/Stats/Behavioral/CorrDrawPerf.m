function All = CorrDrawPerf(param,All)
 

%% Compute correlation Visual Span * Performances
xvalues = All.rates.means(All.PSE > 0 & All.err ~= 1)'; % drawings rates
yvalues = All.PSE(All.PSE > 0 & All.err ~= 1); % Visual spans (threshold cuts)

%% compute distance from mean
% yvalues(yvalues>1) = 1;

if size(All.PSE,2) > 1
    [R,P]=corr(xvalues',yvalues','type','Spearman','tail','left');
    All.rates.corr = [R, P];
    All.results.rates.df = length(xvalues);
end

%% Compute Linear regression Visual Span * Performances
All.rates.Lin = regstats(yvalues,xvalues,'linear');
B = All.rates.Lin.beta;
x = sort(xvalues);
yN = B(2,1).*x + B(1,1);

%% Plot the results
perffig = figure();
name = sprintf('Exp: %d | Visual Span vs. Rates',param.blocType);
plotcorr_file=fullfile(param.resultsFolder,sprintf('Exp%d_VisPan-Rates.pdf',param.blocType));
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

sorted_y = sort(yvalues);
sorted_x = sort(xvalues);
ylim = [sorted_y(1) sorted_y(end)];
xlim = [sorted_x(1) 8];
ytick = linspace(ylim(1),ylim(end),10);
xtick = 1:8;
xticklabel = xtick;

set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
set(gca,'YTick',ytick);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',xtick);
set(gca,'YTickLabel',ytick);
xlabel('Rates');
ylabel('Visual Span');
title('Visual Span as a function of drawing rates');

hold on

% plot linear regression
plot(sorted_x,yN);

% Draw data points
for tLevel = 1:size(xvalues,2)
    x = xvalues(tLevel);
    y = yvalues(tLevel);
    
    num = 20*.5;
    dataP(tLevel) = plot(x,y,'o');
    set(dataP(tLevel),'MarkerSize',num,'MarkerFaceColor',red,'MarkerEdgeColor',black);
    set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
end

text(0.1,0.9,sprintf('r(%d) = %s',All.results.rates.df,num2str(roundn(All.rates.corr(1),-2))),'Units','normalized','FontSize',fontsize);
text(0.1,0.8,sprintf('p = %s',num2str(roundn(All.rates.corr(2),-2))),'Units','normalized','FontSize',fontsize);
hold off

% save figures
name = fullfile(param.resultsFolder,sprintf('Exp%d_VisPan-Rates.pdf',param.blocType));
hgsave(perffig,[name,'.fig']);
saveas(perffig,plotcorr_file);

close all hidden;

end