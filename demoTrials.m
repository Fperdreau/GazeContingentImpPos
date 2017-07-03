function Data = demoTrials(p, const, test, el, Keys, design, ntrials)
% Data = demoTrials(p, const, test, el, Keys, design, ntrials)
%
% @params struct p: struct-array providing windows information
% @params struct const: struct-array providing experiment settings
% @params struct test: struct-array providing design information
% @params struct el: struct-array providing eye-tracker settings
% @params struct Keys: struct-array providing keys used in experiment
% @params ntrials-by-n matrix design: List of trials
% @params int ntriaks: total number of trials
%
% @return struct Data = behavioral data

% Possible opts:
%   - const.blocType = 1: peripheral mask (central window)
%   - const.blocType = 0: central mask (scotoma)

%% Declare matrices for data storage
Data.Resp = zeros(1,ntrials);
Data.RT = zeros(1,ntrials);
Data.Corr = zeros(1,ntrials);
Data.cat = design(:,2)';
Data.Win = design(:,3)';

%% Make movie
if const.Movie
    timedur = 10;
    const.Exp.trialDuration = timedur;
    Simg = (1/p.flipInt)/25;
    nimg = round((timedur*p.ifi)/Simg);
    imageArray = zeros(const.Exp.VA(1),const.Exp.VA(2),3,nimg);
    vidc = 0;
end

%% Stimuli
% Rects
Array = [0 0 const.Exp.VA];
fieldRect = CenterRect(Array,p.rect);

% Areas of Interest
nRows = 10;
nCols = 10;
cellX = Array(3)/nCols;
cellY = Array(4)/nRows;
columns = ((1:nCols) - .5) * cellX+fieldRect(1);
rows = ((1:nRows) - .5) * cellY+fieldRect(2);
const.Exp.nPositions = nCols * nRows;
[const.Exp.nX, const.Exp.nY] = meshgrid(columns, rows);

timeup = ['Time is up! \n\n Please give your response:' ...
    '\n\n - ', char(KbName(Keys.response(1))),' = IMPOSSIBLE'...
    '\n\n - ',char(KbName(Keys.response(2))),' = POSSIBLE.'];

% Fixation dot
delta = VistoPix(1,1,p.screenNum,const.Exp.distance,p);
fixD = round(const.Exp.calTargetRadVal/2 + delta);
const.Exp.fixationbox = [0 0 fixD fixD];

% General masks
imdatagray = ones(const.Exp.VA(2), const.Exp.VA(1),1) .* p.bgcol(1);    % Gray condition

%--------------------------------------------------------------
% START THE BLOCK
trial = 0;
index = 1;
while 1 && trial<ntrials
         
    %--------------------------------------------------------------
    % START THE TRIAL
    for trial=1:ntrials
              
        ok = 0; % ok will be set to 1 when a response key is pressed
        %--------------------------------------------------------------
        % IMAGE PROCESSING
        % Buid a mask
        ms = design(trial,3);
        maskblob = makeMask(1,ms,ms,const.Exp.SD,2,p.bgcol(1));
        masktex = Screen('MakeTexture', p.w, maskblob);

        % Set default images            
        rot = design(trial,5);
        img = design(trial,4);
        imdata = convImg(img, const.Exp.VA(1), const.Exp.VA(2), rot);
            
        % Compute image for foveated region and periphery:
        if const.blocType == 1                                                % window condition
            peripheryimdata = imdatagray;
            foveaimdata = imdata;
        else                                                            % Mask condition
            foveaimdata = imdatagray;
            peripheryimdata = imdata;
        end
        
        if ms == const.Exp.apert(test.nwindow)                              % full view
            foveaimdata = imdata;
            peripheryimdata = imdata;
        end

        % Build texture for foveated region:
        foveatex=Screen('MakeTexture', p.w, foveaimdata);
        tRect=Screen('Rect', foveatex);

        % Build texture for peripheral (non-foveated) region:
        nonfoveatex=Screen('MakeTexture', p.w, peripheryimdata);
        [ctRect, dx, dy]=CenterRect(tRect, p.rect); 
      
        if const.DummyMode == 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d Apert %d cat %d"', trial, ntrials, ms, design(trial,2));
            Eyelink('Message', 'IMAGEID %d %d', design(trial,2), design(trial,4));
            Eyelink('Message', 'TRIALID %d', trial);
            Eyelink('Command', 'set_idle_mode');
            Eyelink('Command', 'clear_screen %d', 0); % clear tracker display and draw box at center

            WaitSecs(0.1);
            Eyelink('command', 'draw_box %d %d %d %d 15', p.width/2-50, p.height/2-50, p.width/2+50, p.height/2+50);

            % START RECORDING
            Eyelink('StartRecording'); 

            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if eye_used == el.BINOCULAR; % if both eyes are tracked
                eye_used = el.LEFT_EYE; % use left eye
            end
        end
        
        % Wait few ms to make sure we got some samples
        WaitSecs(0.1);
        
        %--------------------------------------------------------------
        % FIXATION POINT & Drift correction
        if const.DummyMode
            ShowCursor('Arrow');
            eye_used = [];
        end
        [~, rx, ry] = fixationTest(p, const, el, eye_used, delta, 'random');

        % Wait until all keys on keyboard are released:
        while KbCheck 
            WaitSecs(0.1); 
        end
        FlushEvents('keyDown');

        HideCursor;
        priorityLevel=MaxPriority(p.w, 'KbCheck', 'GetSecs');
        Priority(priorityLevel);
        MsgEL(char(sprintf('TRIAL_START %d', trial)));
        MsgEL('SYNCTIME');
        WaitSecs(0.1);
                
        % Set parameters to default
        mxold = rx;
        myold = ry;
        initTime = GetSecs;
        trialtime = const.Exp.trialDuration + GetSecs;
        
        % Display the scene till the subject respond 
        %--------------------------------------------------------------
        % MONITOR THE TRIAL EVENTS
        MsgEL('EVENT_DISPLAY_ON');
        countcat = 0;
        needtime = [];
        while GetSecs < trialtime && ok==0

            % GET EYE POSITION
            if const.DummyMode==0 %
                error=Eyelink('CheckRecording');
                if(error~=0)
                    break;
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
                        else
                            % if data is invalid (e.g. during a blink), clear display
                            Screen('FillRect', p.w ,p.bgcol);
                            Screen('Flip', p.w);
                        end
                    end
                end
            else
                % Query current mouse cursor position (our "pseudo-eyetracker") -
                % (mx,my) is our gaze position.
                [mx, my, ~] = GetMouse;
            end

            % We only redraw if gazepos. has changed:
            if (mx~=mxold || my~=myold)
                tic;
                % Compute position and size of source- and destinationrect and
                % clip it, if necessary...
                myrect=[mx-ms my-ms mx+ms+1 my+ms+1]; % center dRect on current mouseposition
                dRect = ClipRect(myrect,ctRect);
                sRect=OffsetRect(dRect, -dx, -dy);

                % Valid destination rectangle?
                if ~IsEmptyRect(dRect) && infixationWindow(mx,my,fieldRect)

                    % Step 1: Draw the alpha-mask into the backbuffer. It
                    % defines the aperture for foveation: The center of gaze
                    % has zero alpha value. Alpha values increase with distance from
                    % center of gaze according to a gaussian function and
                    % approach 255 at the border of the aperture...
                    Screen('BlendFunction', p.w, GL_ONE, GL_ZERO);
                    Screen('DrawTexture', p.w, masktex, [], myrect);

                    % Step 2: Draw peripheral image. It is only drawn where
                    % the alpha-value in the backbuffer is 255 or high, leaving
                    % the foveated area (low or zero alpha values) alone:
                    % This is done by weighting each color value of each pixel
                    % with the corresponding alpha-value in the backbuffer
                    % (GL_DST_ALPHA).
                    Screen('BlendFunction', p.w, GL_DST_ALPHA, GL_ZERO);
                    Screen('DrawTexture', p.w, nonfoveatex, [], ctRect);

                    % Step 3: Draw foveated image, but only where the
                    % alpha-value in the backbuffer is zero or low: This is
                    % done by weighting each color value with one minus the
                    % corresponding alpha-value in the backbuffer
                    % (GL_ONE_MINUS_DST_ALPHA).
                    Screen('BlendFunction', p.w, GL_ONE_MINUS_DST_ALPHA, GL_ONE);
                    Screen('DrawTexture', p.w, foveatex, sRect, dRect);
                    
                    % Show final result on screen. This also clears the drawing
                    % surface back to black background color and a zero alpha
                    % value.
                    % Actually... We use clearmode=2: This doesn't clear the
                    % backbuffer, but we don't need to clear it for this kind
                    % of stimulus and it gives us 2 msecs extra headroom for
                    % higher refresh rates!
                    Screen('Flip', p.w, 0, 2);                    
                else
                    % Blank screen
                    Screen('BlendFunction', p.w, GL_ONE, GL_ZERO);
                    Screen('Flip', p.w,0,2);
                    MsgEL('BLANK_SCREEN');
                end
                needtime = [needtime,toc];
            end
            fprintf('Time needed %1.2f secs\n',mean(needtime));
            countcat = countcat + 1;
            if const.Movie && countcat >= Simg 
                vidc = vidc + 1;
                imageArray(:,:,:,vidc)= Screen('GetImage', p.w, fieldRect);
                countcat = 0;
            end
                
            % Keep track of last gaze position:
            mxold=mx;
            myold=my;

            % check for keyboard press
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown
                if keyCode(Keys.response(1))
                    MsgEL('RESPONSE_1');
                    if design(trial,2) == 1 % Response is IMPOSSIBLE
                        MsgEL('EVENT_ANSWER_CORRECT');
                        Data.Corr(trial) = 1;
                    else
                        MsgEL('EVENT_ANSWER_INCORRECT');
                        Data.Corr(trial) = 0;
                    end
                    Data.Resp(trial) = 1; % Response is IMPOSSIBLE
                    Data.RT(trial) = round((secs-initTime)*1000);
                    ok = 1;
                elseif keyCode(Keys.response(2))
                    MsgEL('RESPONSE_2');
                    if design(trial,2) == 2
                        MsgEL('EVENT_ANSWER_CORRECT');
                        Data.Corr(trial) = 1;
                    else
                        MsgEL('EVENT_ANSWER_INCORRECT');
                        Data.Corr(trial) = 0;
                    end
                    Data.Resp(trial) = 2; % Response is POSSIBLE
                    Data.RT(trial) = round((secs-initTime)*1000);
                    ok = 1;
                elseif keyCode(Keys.StopAll)
                    fprintf('Space pressed, exiting trial\n');
                    MsgEL('EVENT_ESCAPE')
                    return;
                end
            end

            % We wait 1 ms each loop-iteration so that we
            % don't overload the system in realtime-priority:
            WaitSecs(0.001);
        end % End of the eye recording
        
        MsgEL('EVENT_DISPLAY_OFF');
        Screen('FillRect', p.w, p.bgcol); % Blank screen;
        Screen('Flip',p.w);
        
        if  GetSecs >= trialtime && ~keyIsDown
            MsgEL('EVENT_TIMEOUT');
            keypress = Displaynwait(timeup);
            if keypress(Keys.response(1))
                MsgEL('EVENT_RESPONSE_1');
                if design(trial,2) == 1
                    MsgEL('EVENT_ANSWER_CORRECT');
                    Data.Corr(trial) = 1;
                else
                    MsgEL('EVENT_ANSWER_INCORRECT');
                    Data.Corr(trial) = 0;
                end
                Data.Resp(trial) = 1; % Impossible
                Data.RT(trial) = round((secs-initTime)*1000);
            elseif keypress(Keys.response(2))
                MsgEL('EVENT_RESPONSE_2');
                if design(trial,2) == 2
                    MsgEL('EVENT_ANSWER_CORRECT');
                    Data.Corr(trial) = 1;
                else
                    MsgEL('EVENT_ANSWER_INCORRECT');
                    Data.Corr(trial) = 0;
                end
                Data.Resp(trial) = 2; % Possible
                Data.RT(trial) = round((secs-initTime)*1000);
            end
        end

        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Keys.StopAll)
                fprintf('Space pressed, exiting trial\n');
                MsgEL('EVENT_ESCAPE')
                return
            end
        end
        
        endTrial;

    end % End of trial
         
end % end of the while loop

%% --------------------------------------------------------------
% End of Experiment; close the file first
% close graphics window, close data file and shut down tracker
% reset so tracker uses defaults calibration for other experiemnts
if const.DummyMode==0
    Eyelink('command', 'generate_default_targets = YES')
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    try
        fprintf('Receiving data file ''%s''\n', const.edfFile);
        status = Eyelink('ReceiveFile', const.defautfilename, strcat(const.datafolder), 1);
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(const.edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', const.edfFile, pwd );
        end
    catch %#ok<*CTCH>
        fprintf('Problem receiving data file ''%s''\n', const.edfFile );
    end
else
    ShowCursor;
end

return;

%% --------------------------------------------------------
% Functions
    % endTrial routine
    function endTrial
        if const.Movie
            folder = fullfile(const.folder,sprintf('MovieDem-%d-%d',const.blocType,ms));
            if ~isdir(folder)
                mkdir(folder);
            end
            file = fullfile(folder,sprintf('Mov-%d-%d.mat',const.blocType,ms));
            save(file,'imageArray');
            clear imageArray
        end
        Screen('Close');
        clear foveaimdata peripheryimdata imdata ms maskblob masktex foveatex tRect nonfoveatex ctRect PositionIndex initFixtime ncount;
        
        % Blank screen
        Screen('BlendFunction', p.w, GL_ONE, GL_ZERO);
        Screen('Flip', p.w);
        
        % stop the recording of eye-movements for the current trial
        if const.DummyMode==0
            index = index +1;
            WaitSecs(0.001);
            MsgEL(char(sprintf('TRIAL_END %d',trial)));
            Eyelink('StopRecording'); 
            
            WaitSecs(0.001);
            Eyelink('Message', '!V TRIAL_VAR index %d', index);
            Eyelink('Message', 'TRIAL_RESULT 0');
        else
            ShowCursor;
        end   
    end
    
    % send message to the EyeLink
    function MsgEL(msg)
        if const.DummyMode == 0
            Eyelink('Message',msg);
        end
    end

    function fix = infixationWindow(mx,my,fixationWindow)
        % determine if mx and my are within fixation window
        fix = mx > fixationWindow(1) &&  mx <  fixationWindow(3) && ...
            my > fixationWindow(2) && my < fixationWindow(4) ;
    end

    function imdata = convImg(img, h, w, rot)
        
        cd(fullfile(const.folder,'/Stimuli/Objects/'));
        dirData = dir;      %# Get the data for the current directory
        dirIndex = [dirData.isdir];  %# Find the index for directories
        fileList= {dirData(~dirIndex).name}';
        
        ext = char(fileList(img)); % find file type
        ext = ext(end-2:end);
        
        im = imread(char(fileList(img)),ext);
        im = imresize(im,[h w]);
        imdata = rgb2gray(im);
        imdata(imdata == 255) = const.Exp.imBackcolor;
        imdata = rot90(imdata,rot); % rotated image
    end
        
 

end
