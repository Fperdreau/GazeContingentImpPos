function Results = Correlations2(param,All)

ind = All.ind;

%% Bootstrap options
% correlation
opt.corr.nruns = 5000;
opt.corr.alpha = .05;
opt.corr.boottype = 'resampling';
opt.corr.type = 3;
opt.corr.functopt= {'type',param.whichCorr,'tail','both'};
opt.corr.confint = 'percent';
opt.corr.graph = 1;
opt.corr.silent = param.silent;

% Regression
whichstats = {'beta','rsquare','adjrsquare','tstat','fstat','standres'};
whichstats = 'all';
opt.reg.nruns = 5000;
opt.reg.alpha = .05;
opt.corr.type = 1;
opt.reg.functopt= {'linear',whichstats};
opt.reg.boottype = 'fixed';
opt.reg.confint = 'percent';
opt.reg.graph = 3;
opt.reg.silent = param.silent;

% multiple regression
opt.mult.graph = 1;
opt.mult.silent = param.silent;
opt.mult.name = sprintf('Exp%d-Multiple regression',param.blocType);
opt.mult.labels = {'Perf','Rates','Years','Age'};

%% Define variables
% Drawing rates
Rates = All.Rates.Grmeans(ind,:)';
SimRates = All.Rates.means(ind)';
% Rates = SimRates;
Pretest = All.Beh.Perf(ind,9)';

% Performances
si = zeros(size(ind));
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        si(i) = sum(All.Fit.Boot{in}.conv);
    end
end
mi = min(si(si >0));

cpt = 0;
Perf = zeros(mi,length(ind));
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        cpt = cpt +1;
        conv = All.Fit.Boot{in}.conv'; 
        dat = All.Fit.Boot{in}.paramsSim(conv,1)';
        Perf(:,cpt) = dat(1:mi);% Visual spans (threshold cuts)
    end
end
SimPerf = All.Fit.PSE(ind);
Perf = SimPerf;

% Slopes
cpt = 0;
Slop = zeros(mi,length(ind));
for i = 1:length(ind)
    in = ind(i);
    if ~isempty(All.Fit.Boot{in})
        cpt = cpt +1;
        conv = All.Fit.Boot{in}.conv'; 
        dat = All.Fit.Boot{in}.paramsSim(conv,2)';
        Slop(:,cpt) = dat(1:mi);% Visual spans (threshold cuts)
    end
end
SimSlop = All.Fit.Slope(ind);
Slop = SimSlop;

%% Correlation Performance * Drawing rates
sdx = All.Rates.std(ind)';
sdy = All.Fit.SECuts(ind);
xvalues = Rates;
yvalues = Perf;
Xobs = SimRates;
Yobs = SimPerf;

name = sprintf('Exp%d_VisPan-Rates',param.blocType);
labels = {'Performances vs. drawing rates',...
    'Rates',...
    'Visual span'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.thres.cor = cor;
Results.thres.reg = reg;
Results.thres.simp = cor.stats;

%% Correlation Performances * Exp
sdx = [];
sdy = All.Fit.SECuts(ind);
xvalues = All.Exp(ind);
yvalues = Perf;
Xobs = xvalues;
Yobs = SimPerf;

name = sprintf('Exp%d_VisPan-Exp',param.blocType);
labels = {'Performances vs. Experience in drawing',...
'Experience (freq*years)',...
'Visual span'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.exp.cor = cor;
Results.exp.reg = reg;
Results.exp.simp = cor.stats;

%% Correlation Performances * Years of training
xvalues = All.Years(ind);
yvalues = Perf;
sdx = [];
sdy = All.Fit.SECuts(ind);
Xobs = xvalues;
Yobs = SimPerf;

name = sprintf('Exp%d_Vispan-Years',param.blocType);
labels = {'Performances vs. years of training',...
'Years of training',...
'Visual span'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.PerfYears.cor = cor;
Results.PerfYears.reg = reg;
Results.PerfYears.simp = cor.stats;

%% Correlation Performances * Age
xvalues = All.Age(ind); % Exp
yvalues = Perf; % drawings rates
sdx = [];
sdy = All.Fit.SECuts(ind);
Xobs = xvalues;
Yobs = SimPerf;

name = sprintf('Exp%d_Vispan-Age',param.blocType);
labels = {'Performances vs. Age',...
'Age(in years)',...
'Visual Span'};

[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.Age.cor = cor;
Results.Age.reg = reg;
Results.Age.simp = cor.stats;

%% Correlation Baseline * Experience
xvalues = All.Years(ind); % Exp
yvalues = Pretest; % drawings rates
sdx = [];
sdy = [];
Xobs = xvalues;
Yobs = yvalues;

name = sprintf('Exp%d_Pretest-Years',param.blocType);
labels = {'Pretest vs. Years of experience',...
'Years of Experience',...
'Prestest Performance'};

[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.Pretest.cor = cor;
Results.Pretest.reg = reg;
Results.Pretest.simp = cor.stats;

%% Drawing rates * RT
xvalues = Rates;
yvalues = All.Beh.RT(ind,:)';
sdx = All.Rates.std(ind)';
sdy = std(yvalues);
Xobs = SimRates;
Yobs = mean(yvalues);

name = sprintf('Exp%d_VisPan-RTs',param.blocType);
labels = {'Performances vs. RT',...
    'Drawing Rates',...
    'RTs (in msec)'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.RTs.cor = cor;
Results.RTs.reg = reg;
Results.RTs.simp = cor.stats;

%% Correlation Drawing score * slopes
sdx = All.Rates.std(ind)';
sdy = All.Fit.SEslop(ind);
xvalues = Rates;
yvalues = Slop;
Xobs = SimRates;
Yobs = SimSlop;

name = sprintf('Exp%d_Slope-Rates',param.blocType);
labels = {'Slopes vs. drawing rates',...
'Rates',...
'Slopes'};
[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.slop.cor = cor;
Results.slop.reg = reg;
Results.slop.simp = cor.stats;

%% Correlation Drawing score * Exp
xvalues = All.Exp(ind); % Exp
yvalues = Rates; % drawings rates
sdx = [];
sdy = All.Rates.std(ind)';
Xobs = xvalues;
Yobs = SimRates;

name = sprintf('Exp%d_Rates-Exp',param.blocType);
labels = {'Drawing rates vs. Experience',...
'Experience (freq*Years)',...
'Rates'};

[cor reg] = MakeCorrAnal(param,xvalues,yvalues,name,labels,'both',opt,sdx,sdy,Xobs,Yobs);
Results.drawExp.cor = cor;
Results.drawExp.reg = reg;
Results.drawExp.simp = cor.stats;

%% Multiple Regression
Age = All.Age(ind)';
Pse = All.Fit.PSE(ind)';
Years = All.Years(ind)';
Rates = All.Rates.means(ind);
y = Pse;
X = [Years,Age];

[multi, fig] = MultiReg(X,y,opt.mult);
plot_file=fullfile(param.resultsFolder,strcat(opt.mult.name,'.pdf'));
Results.MultiReg = multi;
saveas(fig,plot_file);
close all

%% Summary bar plot
corthres = Results.thres.cor.corr(1);
corslop = Results.slop.cor.corr(1);
corexp = Results.exp.cor.corr(1);
corYears = Results.PerfYears.cor.corr(1);
corRTs = Results.RTs.cor.corr(1);
corDraw = Results.drawExp.cor.corr(1);
corAge = Results.Age.cor.corr(1);
corPre = Results.Pretest.cor.corr(1);

sdthres = Results.thres.cor.SE;
sdslop = Results.slop.cor.SE;
sdexp = Results.exp.cor.SE;
sdYears = Results.PerfYears.cor.SE;
sdRTs = Results.RTs.cor.SE;
sdDraw = Results.drawExp.cor.SE;
sdAge = Results.Age.cor.SE;
sdPre = Results.Pretest.cor.SE;

pthres = Results.thres.simp(2);
pslop = Results.slop.simp(2);
pexp = Results.exp.simp(2);
pYears = Results.PerfYears.simp(2);
pRTs = Results.RTs.simp(2);
pDraw = Results.drawExp.simp(2);
pAge = Results.Age.simp(2);
pPre = Results.Pretest.simp(2);

Hthres = Results.thres.cor.corr(2);
Hslop = Results.slop.cor.corr(2);
Hexp = Results.exp.cor.corr(2);
HYears = Results.PerfYears.cor.corr(2);
HRTs = Results.RTs.cor.corr(2);
HDraw = Results.drawExp.cor.corr(2);
HAge = Results.Age.cor.corr(2);
HPre = Results.Pretest.cor.corr(2);

Cithres = Results.thres.cor.ci;
Cislop = Results.slop.cor.ci;
Ciexp = Results.exp.cor.ci;
CiYears = Results.PerfYears.cor.ci;
CiRTs = Results.RTs.cor.ci;
CiDraw = Results.drawExp.cor.ci;
CiAge = Results.Age.cor.ci;
CiPre = Results.Pretest.cor.ci;

Yval = [corthres, corYears, corAge, corPre, corRTs, corDraw];
SDval = [sdthres, sdYears, sdAge, sdPre, sdRTs, sdDraw];
pval = [pthres, pYears, pAge, pPre, pRTs, pDraw];
Hval = [Hthres, HYears, HAge, HPre, HRTs, HDraw];
Cival = [Cithres; CiYears; CiAge; CiPre; CiRTs; CiDraw]';
Samples = [Results.thres.cor.rSample', Results.PerfYears.cor.rSample',Results.Age.cor.rSample',Results.Pretest.cor.rSample'];

[pperf, ~] = bonf_holm(pval([1 2 3])); % Bonferroni correction for Perf
pval(1:3) = pperf; 

[pperf, ~] = bonf_holm(pval([4 5 6])); % Bonferroni correction for Rates
pval(4:6) = pperf; 

Results.Resume = [Yval',SDval',pval',Hval',Cival'];

Yval = [corthres, corYears, corAge, corPre];
pval = pval(1:4);
Hval = [Hthres, HYears, HAge, HPre];
Cival = [Cithres; CiYears; CiAge; CiPre]';

name = sprintf('Exp%d-%1.2f-Summary',param.blocType,param.min);
plot_file=fullfile(param.resultsFolder,strcat(name,'.pdf'));
Legends = {'Span*rates';'Years*Span';'Span*Age';'Pretest*Years'};
fig = mybarweb(Yval,Cival,pval,Hval,.5,[],name,{'Correlations',[],'Correlation Coefficient'},[],'y',Legends,2,[],1);
text(0.1,0.9,sprintf('n = %1.0f',length(ind)),'Units','normalized','FontSize',12);

saveas(fig,plot_file);
close all

% box plot
name = sprintf('Exp%d-%1.2f- Box plot',param.blocType,param.min);
box_file = fullfile(param.resultsFolder,strcat(name,'.pdf'));
Labels = {'Correlations',[],'Correlation Coefficient'};
opt.legend_type = 'axis';
opt.bw_legend = {'Span*rates';'Years*Span';'Span*Age';'Pretest*Years'};
box = myboxplot(Samples, pval, Hval, [], name, Labels, opt);
saveas(box,box_file);
close all

end
