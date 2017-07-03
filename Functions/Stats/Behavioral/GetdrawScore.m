function Results = GetdrawScore(param)


%% Load ratings
% datafile = fullfile(param.datafolder,'JudDraw3','JudDraw.mat');
% load(datafile,'Resp');
drawfold = fullfile(param.datafolder,'JudDraw');
datafile = fullfile(drawfold,'DrawRate.mat');
if exist(datafile,'file') ~= 0
    recycle('on');
    delete(datafile);
end
list = getcontent(drawfold,'file','mat');
listimg = getcontent(fullfile(param.datafolder,'Drawings'),'file','png');

sl1 = size(listimg,1);
sl2 = size(list,1);
indivCron = zeros(1,sl2);
Resp = zeros(sl1,sl2);
for i = 1:size(list,1)
    file = fullfile(drawfold,list{i,:});
    load(file,'Data','ntrials');
    
    in = 1:ntrials:size(Data,1);
    % ignore the first trials
    co = zeros(1,size(Data,1));
    for t = 1:size(Data,1)
        if isempty(find(in == t))
            co(t) = 1;
        end
    end
    Data = Data(co == 1,:);
    Data = [Data(:,1), mean(Data(:,2:end),2)];
    Allresp = zeros(sl1,ntrials-1);
    for n = 1:sl1
        x = Data(Data(:,1) == n,2:end);
        Allresp(n,:) = reshape(x,1,numel(x));
    end
    indivCron(i) = cronbach(Allresp);
    Resp(:,i) = mean(Allresp,2);
    clear Data ntrials Allresp;
end

%% Test inter- & intra-raters agreement
cron = cronbach(Resp);

%% Compute mean of the ratings for every drawing
stp = 1;
in = 1;
en = stp;
meanDraw = zeros(size(Resp,1)/stp,1);
stdDraw = zeros(size(Resp,1)/stp,1);
sub = size(Resp,2);
for k = 1:size(Resp,1)/stp
    d = reshape(Resp(in:en,:),1,stp*sub);
    meanDraw(k,:) = mean(d); 
    stdDraw(k,:) = std(d)/sqrt(stp*sub);
    in = in + stp;
    en = en + stp;
end

%% Plot ICC
fig = figure();
ICC_file = fullfile(param.resultsFolder,strcat('ICC Drawings','.pdf'));
set(fig, 'Name', 'ICC Drawings','PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
figSize_X = 800;
figSize_Y = 600;
start_X = 0;start_Y = 0;
set(fig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);

% Graph settings
black = [0,0,0];
gray = [0.7,0.7,0.7];
fontsize = 12;

ylim = [0 8.5];
xlim = [0 28];
ytick = linspace(1,8,8);
xtick = 1:27;
xticklabel = xtick;

width_th = 0.5;

set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
set(gca,'YTick',ytick);
set(gca,'XTick',xtick);
set(gca,'XTickLabel',xtick);
set(gca,'YTickLabel',ytick);
xlabel('Subjects');
ylabel('Drawing rates');
title('ICC on drawing rates');

% plot points
hold on
for i = 1:size(Resp,1)
    li = plot(i*[1,1],ylim);
    num = 5;
    set(li,'LineWidth', width_th,'Color', gray,'LineStyle','-')
    for j = 1:size(Resp,2)
        x = i;
        y = Resp(i,j);
        tplot(i) = plot(x,y,'o');
        set(tplot(i),'MarkerSize',num,'MarkerFaceColor',gray,'MarkerEdgeColor',black);
        set(gca,'XLim', xlim ,'XTick', xtick,'XTickLabel',xticklabel,'YLim',ylim,'YTick',ytick);
    end
end

text(0.1,0.9,sprintf('alpha = %1.3f',cron),'Units','normalized','FontSize',fontsize);

hold off

%% save figures
saveas(fig,ICC_file);

%% Store results
Results.cronbach = cron;
Results.indivCron = indivCron;
Results.means = meanDraw;
Results.Grmeans = Resp;
Results.std = stdDraw;

end
