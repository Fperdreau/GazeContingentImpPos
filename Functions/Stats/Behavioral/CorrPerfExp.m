function All = CorrPerfExp(param,All)


%% Compute correlation Exp * Performances

xvalues = All.Exp.Exp(All.err == 0);
% xvalues = All.Exp.Years(All.err == 0);
yvalues = All.PSE(All.err == 0);

if size(All.Exp.Exp,2) > 1
    [R,P]=corr(xvalues',yvalues','type','Pearson');
    All.Results.Exp.Corr = [R, P];
end

%% Compute Linear regression Visual Span * Performances
All.Results.Exp.Lin = regstats(yvalues,xvalues,'linear');
u=0;
L = All.Results.Exp.Lin.beta;
yN=zeros(1,size(yvalues,1));
for x = xvalues
    u = u+1;
    yN(u)=L(2,1)*x+L(1,1);
end

%% Plot the results
fig = figure('name',sprintf('Exp: %d | Visual Span vs. Experience',param.blocType)); 
hold on
y = sort(yvalues);
fig = plot(xvalues,yvalues, 'ro');
plot(xvalues',yN);
hold off
% set(gca,'YTick',y);
% set(gca,'YTickLabel',num2cell(roundn(y.*(21/2),-1)));
xlabel('Rates');
ylabel('Visual Span');
title('Visual Span as a function of drawing rates');

hgsave(fig,fullfile(param.resultsFolder,sprintf('Exp%d - VisPan vs Exp',param.blocType)));
close all;

end