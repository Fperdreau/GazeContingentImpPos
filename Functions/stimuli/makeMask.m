function maskblob = makeMask(opt, xsd, ysd, SD, layer, bgcolor)

% -------------------------------------------------------------------------
% E.g: maskblob = makeMask(opt, xsd, ysd, SD, layer, bgcolor)
% -------------------------------------------------------------------------
% Description:
% Create a transparency mask 
% Draw a window of visibility (transparent mask) either using a log-normal 
% 2D blob, a gaussian 2D blob or simply a disc.
% -------------------------------------------------------------------------
% Input:
%   opt: Mask type
%       1: log-normal
%       2: gaussian
%       3: disc
%   xsd,ysd: width of the mask along the x and y axis
%   SD: standard deviation of the gaussian
%   layer: output layer of the maskblob matrix
%   bgcolor: background color (filled part of the mask)
% -------------------------------------------------------------------------
% Author: Florian Perdreau (florian.perdreau@parisdescartes.fr)
% -------------------------------------------------------------------------

%% Manual parameters (for debugging)
% opt = 1;
% xsd = 10;
% SD = 2;
% layer = 2;
% backgroundcolor = 127;

%% function core

if ~exist('ysd','var')
    ysd = xsd;
end

ms = round(SD*xsd);
[x,y]=meshgrid(-ms:ms, -ms:ms);
[~, r] = cart2pol(x,y);
maskblob = ones(size(x))*bgcolor;

switch opt
    case 1 % use log-normal blob
        % Layer 1 (Luminance)
        FilterSFsd      = 0.1; % octaves
        FreqSdAbsolute  = (1/(2.^(FilterSFsd))); % scaling factor in absolute c/im (bw is specfied in octaves)
        DistLog = log(r/xsd);
        Gauss=1-exp(-(DistLog.^2) / (2 * log(FreqSdAbsolute)^2));
        Gauss(r<xsd) = 0;
        Gauss = Gauss .* 255;
    case 2 % use gaussian blob
        % xsd=ms/SD;
        % ysd=ms/SD;
        Gauss=(1 - exp(-((x./xsd).^2)-((y./ysd).^2)));
        Gauss(r < xsd) = 0;
        Gauss = Gauss.*255;
    case 3 % use a simple circle mask
        Gauss=(1 - exp(-((x./xsd).^2)-((y./ysd).^2)));
        Gauss(r > xsd) = 1;
        Gauss(r < xsd) = 0;
        Gauss = Gauss.*255;
    otherwise
        error('myApp:argChk', 'Invalid opt argument');    
end

maskblob(:,:,layer)=Gauss;

%% Plot and show the mask blob
% Gs = round(size(Gauss)/2);
% Gs = Gs(1);
% plot(x(Gs,:),Gauss(Gs,:))
% xlabel('Window width');
% ylabel('transparency value: 0=maximum transparency');
% 
% figure,
% imshow(Gauss./255);

end


