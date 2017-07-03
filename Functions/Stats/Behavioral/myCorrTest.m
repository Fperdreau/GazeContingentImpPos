function [r p] = myCorrTest(X,Y,type,tail)

% ----------------------------------------------------------
% r = myCorrTest(X,Y,type)
% ----------------------------------------------------------
% Goal of the function:
% Compute correlation coefficient between two random variable
% ----------------------------------------------------------
% Inputs: 
% - X and Y = Vectors representing the two samples
% - type: 'Pearson' or 'Spearman'
% - tail: 'lower','greater','two'.
% ----------------------------------------------------------
% Outputs:
% - r: correlation coefficient (Pearson's R or Spearman's Rho)
% - p: probability associated to r.
% ----------------------------------------------------------
% Function created by Florian Perdreau (florian.perdreau@parisdescartes.fr)
% Project: ATUT Bloc 1-3
% Last update: 06/03/2012
% ----------------------------------------------------------

%% Determine which dimension to use
dim = find(size(X)~=1, 1);
if isempty(dim)
  dim = 1;
end

N = size(X,dim);
df = N-1;

if ~exist('type','var')
    type = 'Pearson';
end

if ~exist('tail','var')
    tail = 'two';
end

switch char(type)
    case 'Pearson'

        %% Pearson's R (product moment coefficient)
        mX = mean(X);
        mY = mean(Y);

        devX = X - mX;
        devY = Y - mY;

        VarX = sum(devX.^2)/df;
        VarY = sum(devY.^2)/df;
        CovXY = sum(devX .* devY)./df;

        sdX = sqrt(VarX);
        sdY = sqrt(VarY);

        r = CovXY / (sdX*sdY);
        
    case 'Spearman'

        %% Spearman's correlation (rho): rank correlation coefficient
        sortX = sort(X);
        sortY = sort(Y);

        % search ranks of the values for each sample
        for i = 1:N
            indf = find(sortX == X(i));
            if size(indf,2) > 1 % in case of ex aequo
                indf = indf(1);
            end
            Xind(i) = indf;
            
            indf = find(sortY == Y(i));
            if size(indf,2) > 1
                indf = indf(1);
            end
            Yind(i) = indf;
        end

        mX = mean(Xind);
        mY = mean(Yind);

        devX = Xind - mX;
        devY = Yind - mY;

        CovXY = sum(devX.*devY);
        DevX2 = sum(devX.^2);
        DevY2 = sum(devY.^2);

        r = CovXY / sqrt(DevX2 * DevY2);
end

%% find signicance of r using fischer's F (T distribution). 
tval = r*sqrt((N-2)/(1-r^2));

% Now search the appropriate p-value for tval
switch char(tail)
    case 'lower'
        p = tcdf(tval,df);
    case 'greater'
        p = tcdf(-tval,df);
    case 'two'
        p = 2*tcdf(-abs(tval),df);
end

end
