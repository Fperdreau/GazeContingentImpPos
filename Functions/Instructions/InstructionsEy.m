function keyCode = InstructionsEy(whichcontent,const,p)

% -------------------------------------------------------------------------
% keyCode = InstructionsEy(whichcontent,const,p)
% -------------------------------------------------------------------------
% Goal of the function:
% Display instructions till the subject press a key.
% -------------------------------------------------------------------------
% Inputs:
% whichcontent: instructions to be displayed ('french','english','calib')
% const: structure array proving experiment information
% p: structure array providing the screen parameters
% -------------------------------------------------------------------------
% Outputs:
% keyCode: code corresponding to the key pressed by the subject.
% -------------------------------------------------------------------------
% Function created by Florian Perdreau (florian.perdreau@parisdescartes.fr)
% last update: 31/01/2012
% -------------------------------------------------------------------------


switch char(whichcontent)
    case 'english'
        imdata = imread(sprintf('%s/Stimuli/Instructions/english.png',const.folder),'png');
    case 'french'
        imdata = imread(sprintf('%s/Stimuli/Instructions/french.png',const.folder),'png');
    case 'calib'
        imdata = imread(sprintf('%s/Stimuli/Instructions/calib.png',const.folder),'png');
    case 'Examples'
        imdata = imread(sprintf('%s/Stimuli/Instructions/examples.png',const.folder),'png');
    otherwise
        fprintf('Invalid instruction');
        return;
end

instru = Screen('MakeTexture',p.w,imdata);

% Get the current opened window
WaitSecs(0.5);
FlushEvents('keyDown');
keyIsDown = 0;
while ~keyIsDown
    Screen('FillRect', p.w, p.white); % Blank screen;
    Screen('DrawTexture',p.w,instru,[],p.rect);
    Screen('Flip', p.w);

    [keyIsDown, ~, keyCode] = KbCheck;
end

while KbCheck; end;

end