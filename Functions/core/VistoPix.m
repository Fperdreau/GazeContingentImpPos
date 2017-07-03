function [Wdth, Hght]= VistoPix(n, AskedSize, whichscreen, distance, p) 

% -------------------------------------------------------------------------
% [width, Hght] = VistoPix(n,AskedSize,whichscreen, distance,p)
% -------------------------------------------------------------------------
% Goal of the function:
% This function's aim is to convert visual angle to pixels or pixels to
% visual angle.
% -------------------------------------------------------------------------
% Inputs :
% - n: is the size to be converted. n can be either a simple value or a raw
% vector. In the later case, output will also be raw vectors.
% - Askedsize: is the direction of the convertion (1: Visual angle to
% pixels; 2= pixels to visual angle).
% - whichscreen: is the display screen where stimuli is going to be
% projected.
% - distance: is the distance separating the eyes from the center of the
% screen (in mm).
% - p: structure array providing information about the desired display
% setting.
% -------------------------------------------------------------------------
% Outputs:
% - Wdth: width expressed in pixels or visual angles.
% - Hght: height expressed in pixels or visual angles.
% -------------------------------------------------------------------------
% Florian Perdreau (florian.perdreau@parisdescartes.fr)
% last update: 30/01/2012.
% -------------------------------------------------------------------------

if nargin < 3
	error('myApp:argChk', 'Not enougth arguements have been provided');
end

if exist('p','var') ~= 0
    widthScr = p.displaySize(1);  heightScr = p.displaySize(2);
    widthRes = p.screensize(1);   heightRes = p.screensize(2);
else
    % Get Display size and screen resolution
    [widthScr, heightScr]=Screen('DisplaySize',whichscreen);
    [widthRes, heightRes]=Screen('WindowSize',whichscreen);
end

% Angle: size for converting (in VS), AskedSize(1:pixels, 2:visual angle).
if AskedSize==1
    Wdth=round(tan(deg2rad(n./2)).*2*distance*(widthRes/widthScr));
    Hght=round(tan(deg2rad(n./2)).*2*distance*(heightRes/heightScr));
else
    Wdth= rad2deg(atan(((n./2)./(distance*(widthRes/widthScr))))).*2;
    Hght= rad2deg(atan(((n./2)./(distance*(heightRes/heightScr))))).*2;
end
    
end