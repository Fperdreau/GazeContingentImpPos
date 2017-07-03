function Results = Correlations(param,All)

ind = All.ind;

%% Bootstrap options
% correlation
opt.corr.nruns = 20000;
opt.corr.alpha = .05;
opt.corr.boottype = 'resampling';
opt.corr.type = 3;
opt.corr.functopt= {'type','Spearman'};
opt.corr.confint = 'percent';

% Regression
whichstats = {'beta','rsquare','adjrsquare','tstat','standres'};
opt.reg.nruns = 1000;
opt.reg.alpha = .05;
opt.corr.type = 1;
opt.reg.functopt= {'linear',whichstats};
opt.reg.boottype = 'fixed';
opt.reg.confint = 'percent';

%% Correlation Drawing score * performances
xvalues = All.Rates.means(ind); % drawings rates
yvalues = All.Fit.PSE(ind)';
myx = All.Rates.Grmeans(ind,:)';
clear myy

% find minimum common
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        si(i) = sum(All.Fit.Boot{in}.conv);
    end
end
mi = min(si(si >0));

cpt = 0;
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        cpt = cpt +1;
        conv = All.Fit.Boot{in}.conv'; 
        dat = All.Fit.Boot{in}.paramsSim(conv,1)';
        myy(:,cpt) = dat(1:mi);% Visual spans (threshold cuts)
    end
end

sdx = All.Rates.std(ind)';
sdy = All.Fit.SECuts(ind);
xvalues = median(myx);
yvalues = median(myy);

name = sprintf('Exp%d_VisPan-Rates',param.blocType);
labels = {'Performances vs. drawing rates',...
    'Visual span',...
    'Rates'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt,sdx,sdy,myx,myy);
Results.thres.cor = cor;
Results.thres.reg = reg;

name = sprintf('Simple-Exp%d_VisPan-Rates',param.blocType);
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.thres.simp.cor = cor;
Results.thres.simp.reg = reg;

%% Correlation Drawing score * slopes
xvalues = All.Rates.means(ind)'; % drawings rates
yvalues = All.Fit.Slope(ind); % slopes
clear myy
myx = All.Rates.Grmeans(ind,:)';  

cpt = 0;
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        cpt = cpt +1;
        conv = All.Fit.Boot{in}.conv'; 
        dat = All.Fit.Boot{in}.paramsSim(conv,2)';
        myy(:,cpt) = dat(1:mi);% Visual spans (threshold cuts)
    end
end

sdx = All.Rates.std(ind)';
sdy = All.Fit.SEslop(ind);
name = sprintf('Exp%d_Slope-Rates',param.blocType);
labels = {'Slopes vs. drawing rates',...
'Slopes',...
'Rates'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt,sdx,sdy,myx,myy);
Results.slop.cor = cor;
Results.slop.reg = reg;

name = sprintf('Simple-Exp%d_Slope-Rates',param.blocType);
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.slop.simp.cor = cor;
Results.slop.simp.reg = reg;

%% Correlation Performances * Exp
opt.corr.myval = 0;
opt.reg.myval = 0;

xvalues = All.Exp(ind); % drawings rates
yvalues = All.Fit.PSE(ind); % Visual spans (threshold cuts)
name = sprintf('Exp%d_VisPan-Exp',param.blocType);
labels = {'Performances vs. Experience in drawing',...
'Visual span',...
'Experience (freq*years)'};
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt); 
Results.exp.cor = cor;

name = sprintf('Simple-Exp%d_VisPan-Exp',param.blocType);
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.exp.simp = cor;

%% Correlation Drawing score * Exp
xvalues = All.Exp(ind); % Exp
yvalues = All.Rates.means(ind); % drawings rates
name = sprintf('Exp%d_Rates-Exp',param.blocType);
labels = {'Drawing rates vs. Experience',...
'Drawing rates',...
'Experience (freq*Years)'};
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt); 
Results.drawExp.cor = cor;

name = sprintf('Simple-Exp%d_Rates-Exp',param.blocType);
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.drawExp.simp = cor;

%% Correlation Performances * Years of training
xvalues = All.Years(ind); % Exp
yvalues = All.Fit.PSE(ind); % drawings rates
name = sprintf('Exp%d_Vispan-Years',param.blocType);
labels = {'Performances vs. years of training',...
'Visual span',...
'Years of training'};
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt); 
Results.PerfYears.cor = cor;

name = sprintf('Simple-Exp%d_VisPan-Years',param.blocType);
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.PerfYears.simp = cor;

%% Reaction times
% Correlation RT * performances
yvalues = mean(All.Beh.RT(ind,:),2); % drawings rates
xvalues = All.Rates.means(ind);%All.Fit.PSE(ind)';

name = sprintf('Exp%d_VisPan-RTs',param.blocType);
labels = {'Performances vs. RT',...
    'Visual span',...
    'RTs (in msec)'};
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'boot',opt);
Results.RTs.cor = cor;

name = sprintf('Simple-Exp%d_VisPan-RTs',param.blocType);
[cor ~] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'simple');
Results.RTs.simp = cor;

%% Summary bar plot
corthres = Results.thres.cor.corr(1);
corslop = Results.slop.cor.corr(1);
corexp = Results.exp.cor.corr(1);
corYears = Results.PerfYears.cor.corr(1);
corRTs = Results.RTs.cor.corr(1);
corDraw = Results.drawExp.cor.corr(1);

sdthres = Results.thres.cor.SE;
sdslop = Results.slop.cor.SE;
sdexp = Results.exp.cor.SE;
sdYears = Results.PerfYears.cor.SE;
sdRTs = Results.RTs.cor.SE;
sdDraw = Results.drawExp.cor.SE;

pthres = Results.thres.simp.cor.corr(2);
pslop = Results.slop.simp.cor.corr(2);
pexp = Results.exp.simp.corr(2);
pYears = Results.PerfYears.simp.corr(2);
pRTs = Results.RTs.simp.corr(2);
pDraw = Results.drawExp.simp.corr(2);

Hthres = Results.thres.cor.corr(2);
Hslop = Results.slop.cor.corr(2);
Hexp = Results.exp.cor.corr(2);
HYears = Results.PerfYears.cor.corr(2);
HRTs = Results.RTs.cor.corr(2);
HDraw = Results.drawExp.cor.corr(2);

Yval = [corthres, corslop, corexp, corYears, corRTs, corDraw];
SDval = [sdthres, sdslop, sdexp, sdYears, sdRTs, sdDraw];
pval = [pthres, pslop, pexp, pYears, pRTs, pDraw];
Hval = [Hthres, Hslop, Hexp, HYears, HRTs, HDraw];

name = sprintf('Exp%d-%1.2f-Summary',param.blocType,param.min);
plot_file=fullfile(param.Resfolder,strcat(name,'.pdf'));
fig = mybarweb(Yval,SDval,pval,Hval,.5,[],name,{'Correlations',[],'Spearman R'},[],'y',{'Span*rates';'Slope*rates';'Exp*Span';'Years*Span';'Span*RTs';'Rates*Exp'},2,[],1);
text(0.1,0.9,sprintf('n = %1.0f',length(ind)),'Units','normalized','FontSize',12);

saveas(fig,plot_file);
close all

end
