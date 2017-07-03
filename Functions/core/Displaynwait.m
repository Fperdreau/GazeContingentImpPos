function keyCode = Displaynwait (content,x,y,l,textcolor,backcolor)

% -------------------------------------------------------------------------
% This function display a message (content) till the subject press a key.
% Coordinates of the text (x,y) can be provided. Otherwise, the text is
% automatically centered on the screen. 'l' is the length of the text box.
% The text and the background colors can also be provided by the users.
% Both colors should be color index or [r g b] triplet or [r g b a]
% quadruple.
% As output, the code of the pressed key is retrieved.
%
% e.g.: keyCode = Displaynwait (content,x,y,l,textcolor,backcolor)
%
% Florian Perdreau (2011)
% -------------------------------------------------------------------------    
    
    if ~exist('x','var')
        x = 'center';
    end
    if ~exist('y','var')
        y = 'center';
    end
    if ~exist('l','var')
        l = 100;
    end
    if ~exist('backcolor','var')
        backcolor = 127.5;
    end
    if ~exist('textcolor','var')
        textcolor = 0;
    end
      
    % Get the current opened window
    wptr=Screen('Windows');
    wptr=wptr(1);
    
    WaitSecs(0.5);
    FlushEvents('keyDown');
    keyIsDown = 0;
    while ~keyIsDown
        Screen('FillRect', wptr, backcolor); % Blank screen;
        DrawFormattedText(wptr,content,x,y,textcolor,l);
        Screen('Flip', wptr);
        
        [keyIsDown, ~, keyCode] = KbCheck;
    end
    
    while KbCheck; end;

end