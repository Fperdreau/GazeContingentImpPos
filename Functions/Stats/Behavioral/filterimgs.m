function [imglist Data] = filterimgs(param,Data)

file = fullfile(param.resultsFolder,'StatImg');
load(file,'StatImg');
file2 = fullfile(param.datafolder,'JudObj.mat');
d = load(file2,'Data');
pilotR = d.Data.Resp;
pilotI = d.Data.Img;
clear d

l = size(Resp,1);
Scores = zeros(size(pilotR));
for i = 1:size(Resp,2)
    scoreI = sum(Resp(:,i)==1)/l;
    scoreP = sum(Resp(:,i)==2)/l;
    if scoreI > .95
        Scores(:,i) = Resp(:,i) == 1;
    elseif scoreP >.95
        Scores(:,i) = Resp(:,i) == 2;
    else
        Scores(:,i) = zeros(l,1);
    end
end
per = sum(Scores)/l;

%%
imgs = StatImg(:,sum(StatImg(2:end,:)) > 0);
sumi(1,:) = imgs(1,:);
sumi(2,:) = sum(imgs(2:end,:))./sum(imgs(2:end,:) > 0);
imglist = sumi(1,sumi(2,:) == 1,:);

%% Process pre-test data
Resp = zeros(size(pilotR));
for i = 1:max(max(pilotI))
    ind = find(pilotI == i)';
    for in = 1:size(ind,2)
        Resp(in,i) = pilotR(ind(in));
    end
end
Resp = Resp(:,imglist);

%%
l = size(Resp,1);
Scores = zeros(size(pilotR));
for i = 1:size(Resp,2)
    scoreI = sum(Resp(:,i)==1)/l;
    scoreP = sum(Resp(:,i)==2)/l;
    if scoreI > .95
        Scores(:,i) = Resp(:,i) == 1;
    elseif scoreP >.95
        Scores(:,i) = Resp(:,i) == 2;
    else
        Scores(:,i) = zeros(l,1);
    end
end

%%
dati = zeros(size(Data.win));
for i = 1:length(imglist)
    im = imglist(i);
    dati = dati + (Data.win == im);
end
%%


%%
Data.Corr = Data.Corr(dati == 1);
Data.Resp = Data.Resp(dati == 1);
Data.win = Data.win(dati == 1);
Data.cat = Data.cat(dati == 1);
Data.RT = Data.RT(dati == 1);


end