function [Results, fig] = bytrial(param,graph,name,Labels,Legends)

if ~exist('graph','var')
    graph = 0;
end

list = getcontent(param.targetfold,'dir');
sl = size(list,1);

for blocType = 1:2
    mD = zeros(sl,9);

    for i = 1:sl
        dirname = sprintf('%s-%d',list{i,:},blocType);
        file = fullfile(param.targetfold,list{i,:},strcat(dirname,'.mat'));
        if exist(file,'file') ~= 0
            load(file,'AllData');
        else
            continue;
        end
        Data = AllData.Corr;
        mD(i,:) = mean(Data,2)';
        clear AllData
    end

    Exp{blocType} = mD(mD(:,1) ~= 0,:);

    GrM(blocType,:) = mean(mD);
    GrSd(blocType,:) = std(mD)/sqrt(size(mD,1));
       
end
Exp1 = Exp{1};
Exp1 = Exp1(:,1:8);
Exp2 = Exp{2};
Exp2 = Exp2(:,1:8);
[p, table] = anova_rm({Exp1 Exp2},'off');
Results = [table(2,5), table(2,3), table(5,3), table(2,6)];

%% Plot results
if graph
    % Figure settings
    fig = figure();
    set(fig, 'Name', name,'PaperOrientation', 'landscape','PaperUnits','normalized','PaperPosition', [0,0,1,1]);
    figSize_X = 800;
    figSize_Y = 600;
    start_X = 0;start_Y = 0;
    set(fig,'Position',[start_X,start_Y,figSize_X+start_X,figSize_Y+start_Y]);
    if param.silent
        set(gcf,'Visible','off');
    end
    hold on
      
    h = errorbar(GrM(:,2:9)',GrSd(:,2:9)','o-','Linewidth',1);
    c = get(h(:),'Color');

    errorbar(GrM(1,1),GrSd(1,1)','o','Linewidth',1,'Color',c{1})
    errorbar(GrM(2,1),GrSd(2,1)','*','Linewidth',1,'Color',c{2})   
   
    title(Labels{1});
    xlabel(Labels{2});
    ylabel(Labels{3});
    legend(Legends{:});
    
    text(0.3,0.9,sprintf('Effect: F(%d,%d)=%1.3f, p = %1.3f',Results{2}, Results{3}, Results{1}, Results{4}),'Units','normalized');

    hold off
end

end