function [const, el]= EyCustCal(p, const)

% ___________________________________________________________________
% EyeLink CALIBRATION & INITIALIZATION
% Function inputs:
% - p: a structure providing window settings
% - const: structure providing constant settings (name...)
%
% Function outputs:
% - const: same as input + edffilename
% - el: eyelink structure
% ___________________________________________________________________


%--------------------------------------------------------------
% EYETRACKER CONFIGURATION
%--------------------------------------------------------------

%--------------------------------------------------------------
% Provide Eyelink with details about the graphics environment
el=EyelinkInitDefaults(p.w);

% Modify different defaults settings :
el.backgroundcolour = p.backgroundcolor;		
el.foregroundcolour = p.white;
el.black = p.black;
el.calibrationtargetsize = const.Exp.calTargetRadVal;
el.calibrationtargetwidth = const.Exp.calTargetWidthVal;
el.displayCalResults = 1;
el.txtCol = 15;
el.bgCol  = 0; 
el.targetbeep = 1;              % put 0 if no sound desired

%--------------------------------------------------------------
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
% Test mode of eyelink connection :

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(const.DummyMode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end

% open file to record data to
res = Eyelink('Openfile', const.defautfilename);
if res~=0
    fprintf('Cannot create EDF file ''%s'' ', const.defautfilename);
    cleanup;
    Eyelink( 'Shutdown');
    return;
end

Eyelink('command', 'add_file_preamble_text ''Experiment by Florian Perdreau''');

status = Eyelink('IsConnected');
switch status
    case -1
        fprintf(1, '\tEyelink in dummymode.\n\n');
    case  0
        fprintf(1, '\tEyelink not connected.\n\n');
    case  1
        fprintf(1, '\tEyelink connected.\n\n');
end

if Eyelink('IsConnected')==el.notconnected
    fprintf('Not connected. exiting');
    Eyelink('CloseFile');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end 

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && ~dummymode
    fprintf('Not connected. exiting');
    cleanup;
    return;
end  

% %--------------------------------------------------------------
% % Set up tracker calibration
angle = 0:pi/3:5/3*pi;

% compute calibration target locations
[cx1,cy1] = pol2cart(angle,0.90);                           
[cx2,cy2] = pol2cart(angle+pi/6,0.45);
cx = round(p.xc + p.width/2*[0 cx1 cx2]);      
cy = round(p.yc + p.height/2*[0 cy1 cy2]);

% start at center, select randomly, end at center
crp = randperm(12)+1;
c(1:2:28) = [cx(1) cx(crp) cx(1)];
c(2:2:28) = [cy(1) cy(crp) cy(1)];

% compute validation target locations (ca libration targets smaller radius)
[vx1,vy1] = pol2cart(angle,0.85);
[vx2,vy2] = pol2cart(angle+pi/6,0.40);

vx = round(p.xc + p.height/2*[0 vx1 vx2]);
vy = round(p.yc + p.height/2*[0 vy1 vy2]);

% start at center, select randomly, end at center
vrp = randperm(12)+1;
v(1:2:28) = [vx(1) vx(vrp) vx(1)];
v(2:2:28) = [vy(1) vy(vrp) vy(1)];

%--------------------------------------------------------------
% Calibration settings
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, p.width-1, p.height-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, p.width-1, p.height-1);

Eyelink('command', 'generate_default_targets = YES');
Eyelink('command', 'calibration_type = HV9');
Eyelink('command', 'randomize_calibration_order 1');
Eyelink('command', 'randomize_validation_order 1');
Eyelink('command', 'cal_repeat_first_target 1');
Eyelink('command', 'val_repeat_first_target 1');

% Eyelink('command', 'generate_default_targets = NO');
% Eyelink('command', 'calibration_type = HV13');
% Eyelink('command', 'randomize_calibration_order 0');
% Eyelink('command', 'randomize_validation_order 0');
% Eyelink('command', 'cal_repeat_first_target 0');
% Eyelink('command', 'val_repeat_first_target 0');
% 
% Eyelink('command', 'calibration_samples=14');
% Eyelink('command', 'calibration_sequence=0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13');
% Eyelink('command', sprintf('calibration_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',c));
% 
% Eyelink('command', 'validation_samples=14');
% Eyelink('command', 'validation_sequence=0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13');
% Eyelink('command', sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',v));


Eyelink('command', 'heuristic_filter = 1 1');

% allow to use the big button on the eyelink gamepad to accept the
% calibration/drift correction target
Eyelink('command', 'button_function 5 "accept_target_fixation"');


% set pupil Tracking model in camera setup screen
% no = centroid. yes = ellipse
Eyelink('command', 'use_ellipse_fitter = no');
% set sample rate in camera setup screen
Eyelink('command', 'sample_rate = %d',1000);

%--------------------------------------------------------------
% STEP 5.2 retrieve tracker version and tracker software version
[~,vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );
vsn = regexp(vs,'\d','match'); % wont work on EL I
if isempty(vsn)
    eyelinkI = 1;
else
    eyelinkI = 0;
end

%--------------------------------------------------------------
% Set content of the data file

% Experiment descriptions into the edf-file :
Eyelink('message', 'BEGIN OF DESCRIPTIONS');
Eyelink('message', 'The Artist Visual Span'); 
Eyelink('message', 'Gaze-contingent moving window');
Eyelink('message', 'with possible or impossible objects');
Eyelink('message', 'END OF DESCRIPTIONS');

Eyelink('command', 'link_event_filter = RIGHT,LEFT,FIXATION,SACCADE,BLINK,BUTTON');
Eyelink('command', 'link_sample_data = RIGHT,LEFT,GAZE,AREA');
Eyelink('command', 'file_sample_data = RIGHT,LEFT,GAZE,AREA');
Eyelink('command', 'file_event_data = RIGHT,LEFT,FIXATION,SACCADE,BLINK,BUTTON');

%--------------------------------------------------------------
% if desktop mount and tracker version is 4.2 or later change
% illumination
twropts = {'TOWER','MPRIM','MIRROR','BLRR','MLRR'};
% query tracker for mount type using elcl_select_configuration variable
[result,reply]=Eyelink('ReadFromTracker','elcl_select_configuration');

if ~eyelinkI && ~const.DummyMode && ~result && ~any(strcmp(reply,twropts)) && str2double(vsn{1}) == 4 && str2double(vsn{2}) >= 2
    %set illumination power in camera setup screen
    % 1 = 100%, 2 = 75%, 3 = 50%

    Eyelink('command', 'elcl_tt_power = %d',2);
else 
    disp('failed to change illumination. possible causes: DummyMode, EL not desktop mount, EL not 1000, EL version number pre 4.2, EL disconnected');
end

%--------------------------------------------------------------
% query host to see if automatic calibration sequencing is enabled.
% ReadFromTracker needs to have 2 outputs.
% variables querable are listed in the .ini files in the host
% directories. Note that not all variables are querable.
[result, reply]=Eyelink('ReadFromTracker','enable_automatic_calibration'); %#ok<ASGLU>

if reply % reply = 1
    fprintf('Automatic sequencing ON');
else
    fprintf('Automatic sequencing OFF');
end

%--------------------------------------------------------------
% Hide the mouse cursor;
Screen('HideCursorHelper', p.w);
% enter Eyetracker camera setup mode, calibration and validation
EyelinkDoTrackerSetup(el);

%% Functions
function cleanup

% Cleanup routine for EyeLink:

if const.DummyMode==0
    Eyelink('Shutdown');
end
Screen('CloseAll');
Priority(0);
commandwindow;
    
end

end
