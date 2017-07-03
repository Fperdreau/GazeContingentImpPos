function [Results, fig] = MultiReg(X,y,opt)

if ~exist('X','var') || ~exist('y','var')
    fprintf('Two variables are needed');
    return;
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

if isfield(opt,'name')
    name = opt.name;
else
    name = 'Regression';
end

if isfield(opt,'labels')
    labels = opt.labels;
else
    labels = num2str(1:size(X,2));
end

%% Compute regression coefficients
const = ones(size(X,1),1);
[b,bint,r,rint,stats] = regress(y,[const,X]);

% find outliers
out = zeros(size(r));
for i = 1:size(r,1)
    if rint(i,1) < 0 && rint(i,2) > 0
        out(i) = 0;
    else
        out(i) = 1;
    end
end

st = regstats(y,X);
t = st.tstat;
f = st.fstat;
CoeffTable = dataset({t.beta,'Coef'},{t.se,'StdErr'}, {t.t,'tStat'},{t.pval,'pVal'});      

% Robust fitting
[robustbeta, strob] = robustfit(X,y);
RobCoeftab = dataset({robustbeta,'Coef'},{strob.se,'StdErr'}, {strob.t,'tStat'},{strob.p,'pVal'});        
    
% Store results
Results.Fstats = stats;
Results.Coef = CoeffTable;
Results.b = [b,bint];
Results.Robust = RobCoeftab;

%% Plot graphs
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
    
    m = size(X,2);
    n = m+1;
    s = 1;
    subplot(m,n,s); 

    % Correlation diagram
    F = X;
    si = size(F,2);
    diag = fullfact([si si]);
    ind = 1:si^2;
    ind = rot90(reshape(ind, si, si),3);
    for i = 1: si^2
        x1 = diag(i,1);
        x2 = diag(i,2);
        subplot(m,n,ind(i));
        s = s+1;
        plot(F(:,x1),F(:,x2),'o');
        [rho p] = corr(F(:,x1),F(:,x2));
        p = p*3;
        xlabel(labels{x1});
        ylabel(labels{x2});
        text(0.1,0.9,sprintf('r=%1.2f, p=%1.2f',rho,p),'Units','normalized');
    end
    hold off
        
    subplot(m,n,s);
    s = s+1;
    % Residuals plots
    rcoplot(r,rint);
    
    subplot(m,n,s);
    s = s+1;
    
    % Multiple regression model
    if m == 2
        x1 = X(:,1);
        x2 = X(:,2);
        scatter3(x1,x2,y,'filled')
        hold on
        x1fit = linspace(min(x1),max(x1),100);
        x2fit = linspace(min(x2),max(x2),10);
        [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT;
        mesh(X1FIT,X2FIT,YFIT)
        xlabel(labels{2})
        ylabel(labels{3})
        zlabel('Y')
        view(50,10)
    end
    
    coe = double('a'):double('a')+size(X,2);
    cpt = 0;
    for c = 1:n+1
        if c > 1
            cpt = cpt+1;
        end
        if c == 1
            tex = 'y = ';
        elseif c>1 && c<n+1
            tex = strcat(tex, '(%1.3f)*',char(coe(cpt)),'+');
        elseif c == n+1
            tex = strcat(tex, '%1.2f');
        end
    end
    cval = [b(2:end)', b(1)];
    text(0.1,0.9,sprintf(tex,cval),'Units','normalized');
    text(0.1,0.8,sprintf('R2=%1.2f, F(%d,%d)=%1.3f, p=%1.3f',stats(1),f.dfe,f.dfr,stats(2),stats(3)),'Units','normalized');
end