function DrawingTask(const,Keys)
% -------------------------------------------------------------------------
% Drawing task: a model picture is displayed on a computer screen and
% participant has to copy it on a A4 sheet of paper as accurately as
% possible within a limited time.
%
% @param struct const: struct-array providing experiment constants
% @param struct Keys: struct-array providing list of keys used in
% experiment
%
% @return void
%
% @author: Florian Perdreau (2011)
% -------------------------------------------------------------------------

%% Get display parameters and open a window
p = DisplayConf('wscr', 2, 'bgcol', [127 127 127], 'distance', 550, 'mode', 1, 'skip',1); % Main Screen

%% Load Images
cd(fullfile(const.folder,'Stimuli'));
img = imread('octopus.jpg','jpg'); % Get model picture
ratio = size(img,1)/size(img,2); % Compute initial ratio

% Compute desired picture width from visual degrees to pixels
wdth = VistoPix(21, 1, p.screenNum, const.Exp.distance,p);
hght = wdth / ratio;

% Make picture black and white
img = rgb2gray(img);

% Resize image
img = imresize(img, [hght wdth]);

% Make texture from image
img = Screen('MakeTexture',p.w,img);

% Frame for model image
rect.pic = [0 0 hght wdth];
rect.pic = CenterRect(rect.pic,p.rect);

% Frame for timer
rect.timer = [0 0 p.width/8 50];
rect.timer = AlignRect(rect.timer, p.rect, 'center', 'bottom');
timerbackcolor = [127 0 0];

%% Constant parameters
time = 15*60; % in seconds
time_elapsed = 0;
T1 = clock;

%% Display the image
while 1 && (time_elapsed < time)
    
    % Compute elasped time
    time_elapsed = etime(clock, T1);
    str = formatTimeFcn(time - time_elapsed);
    
    Screen('FillRect', p.w, p.Color.gray, p.rect);
    Screen('Drawtexture', p.w, img, [], rect.pic);
    
    Screen('FillRect', p.w, timerbackcolor, rect.timer);
    Screen('FrameRect', p.w, 0, rect.timer);
    DrawFormattedText(p.w, str, 'center', rect.timer(RectTop), 0);
    Screen('Flip', p.w);
            
    [keyIsDown,secs,keyCode] = KbCheck; %#ok<*ASGLU>
    if keyCode(Keys.StopAll)
        fprintf('Experiment aborted by the user \n');
        Screen('CloseAll');
        return;
    end     
end

%% Clean the display
Screen('Closeall');
clear mex;

%% Nested Functions
function str = formatTimeFcn(float_time)
    % This function convert elapsed time to string (for timer)
    % @param float float_time: elapsed time
    % @return string str: stringyfied timer
    
    float_time = abs(float_time);
    hrs = floor(float_time/3600);
    mins = floor(float_time/60 - 60*hrs);
    secs = float_time - 60*(mins + 60*hrs);
    h = sprintf('%1.0f:',hrs);
    m = sprintf('%1.0f:',mins);
    s = sprintf('%1.0f',secs);
    if hrs < 10
        h = sprintf('0%1.0f:',hrs);
    end
    if mins < 10
        m = sprintf('0%1.0f:',mins);
    end
    if secs < 9.9995
        s = sprintf('0%1.0f',secs);
    end
    str = [m s];
end

end