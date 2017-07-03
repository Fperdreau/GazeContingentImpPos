function [fix, rx, ry, record, el, eye_used] = fixationTest(p,const,el,eye_used,w,opt)
% ----------------------------------------------------------------------
% [fix, rx, ry, record, el, eye_used] = fixationTest(p,const,el,eye_used,w,opt)
% ----------------------------------------------------------------------
% Goal of the function:
% Draw a fixation dot till the subject has fixated at it during a specific
% time. The dot position is randomly chosen accross the screen at the
% beginning of every presentation.
% ----------------------------------------------------------------------
% Inputs:
% p: struct array providing display information.
% const: struct array providing experiment settings.
% el: eyetracker instance
% eye_used: eye id
% w: width of fixation tolerance area (in pixels)
% opt: 
%   - 'fix': display fixation dot at screen center
%   - 'random': display fixation dot at random location on screen
% ----------------------------------------------------------------------
% Outputs:
% fix: if fixation has succeed.
% record: if the eyelink 'checkrecording' has succeed.
% rx and ry: coordinates of the dot.
% ----------------------------------------------------------------------
% Function created by Florian Perdreau (florian.perdreau@parisdescartes.fr)
% last update: 16/02/2013
% ----------------------------------------------------------------------
  
if ~const.DummyMode
    record = 0;
else
    record = 1;
end

MsgEL('EVENT_FIXATION_TEST');
MsgEL('EVENT_FIXATION_START');
fix = 0;
fixtime = 2; % Time to fixate (in seconds)
addtime = .200; % Extra validation time (in seconds)
cpt = 0;
while ~fix || ~record

    switch char(opt)
        case 'fix'
            rx = p.xc;
            ry = p.yc;
        otherwise
            % Generate random location of fixation dot within an area
            % covering prop_cover of the screen
            npos = 10; % Number of bins
            prop_cover = 0.90; % Proportion of screen covered by area
            x_on = p.width - (prop_cover*p.width);
            x_off = prop_cover*p.width;
            y_on = p.width - (prop_cover*p.height);
            y_off = prop_cover*p.height;
            XX = round(linspace(x_on, x_off, npos));
            YY = round(linspace(y_on, y_off, npos));
            % Randomize the position of the fixation dot
            rx = XX(randi(npos));
            ry = YY(randi(npos));
    end

    %% Fixation Point
    mx=0;
    my=0;
    if const.DummyMode==1
        el.calibrationtargetsize = 30;
        el.calibrationtargetwidth = 10;
        Screen('FrameOval',p.w,p.Color.black,CenterRectOnPoint([0 0 w w],rx, ry));
    end
    
    center= [rx, ry];
    Screen( 'DrawDots', p.w, [0 0], 10, p.Color.black,  center, 2 );
    Screen( 'Flip',  p.w);

    endtime = fixtime + GetSecs;
    while GetSecs < endtime && fix == 0

        % GET EYE POSITION
        if const.DummyMode == 0 %              
            error = Eyelink('CheckRecording');
            if error == 0
                record = 1;
            else
                record = 0;
            end

            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        mx=x;
                        my=y;
                    end
                end
            end
        else
            % Query current mouse cursor position (our "pseudo-eyetracker") -
            % (mx,my) is our gaze position.
            [mx, my, ~] = GetMouse(p.w);
        end

        % Test whether the target eye is within the window
        [t, r] = cart2pol(mx-rx,my-ry);
        if r <= w % If yes, we add an extra time of fixation, just to make sure the eye hasn't fallen on the window by accident
            cpt = cpt + 1;
            if cpt == 1
                timefix = GetSecs + addtime;
            end
        end
                
        if cpt >= 1 && GetSecs >= timefix
            fix = 1;
            break;
        end

        % Redo a calibration if asked
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('c'))
            fprintf('Calibration requested by the user \n');
            
            % GazeTracker Configuration, calibration and drift correction
            [const, el] = launchEyeCal(const,p);
            
            Eyelink('Command', 'set_idle_mode');
            Eyelink('Command', 'clear_screen %d', 0); % clear tracker display and draw box at center

            WaitSecs(0.1);
            Eyelink('command', 'draw_box %d %d %d %d 15', p.xc-50, p.yc-50, p.xc+50, p.yc+50);

            % START RECORDING
            Eyelink('StartRecording'); 

            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if eye_used == el.BINOCULAR; % if both eyes are tracked
                eye_used = el.LEFT_EYE; % use left eye
            end
            
            return
        end
        
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            fprintf('Esc pressed, exiting fixation test\n');
            MsgEL('Abort')
            return
        end
    end 
    
     % if not we display a warning at the fixation location and reset the timer
     if fix == 0
        msg = 'Fixez SVP';
        msSecs = GetSecs + addtime;
        while GetSecs < msSecs 
            Screen( 'DrawDots', p.w, [0 0], 10, p.Color.black,  center, 2 );
            DrawFormattedText(p.w,msg,'center',p.yc - 50);
            Screen('Flip',p.w);
        end
     end
end % End of the fixation loop
MsgEL('EVENT_FIXATION_END');
Screen('Flip',p.w, 0, 0);

% functions
    % send message to the EyeLink
    function MsgEL(msg)
        if const.DummyMode == 0
            Eyelink('Message',msg);
        end
    end

end