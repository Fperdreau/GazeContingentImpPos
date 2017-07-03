function fix = fixationCheck(p,const,el,eye_used,X,w)
% ----------------------------------------------------------------------
% fix = fixationCheck(const,el,eye_used)
% ----------------------------------------------------------------------
% Goal of the function:
% Check is eye's location are within a specific rectangle.
% ----------------------------------------------------------------------
% Inputs:
% p: struct array providing display information.
% const: struct array providing experiment settings.
% Keys: allowed keys.
% ----------------------------------------------------------------------
% Outputs:
% fix: if fixation has succeed.
% record: if the eyelink 'checkrecording' has succeed.
% mx and my: coordinates of the dot.
% ----------------------------------------------------------------------
% Function created by Florian Perdreau (florian.perdreau@parisdescartes.fr)
% last update: 31/01/2012
% ----------------------------------------------------------------------       

cx = X(1); cy = X(2);
mx = 0;
my = 0;
% GET EYE POSITION
if const.DummyMode == 0           
    error = Eyelink('CheckRecording');
    if error ~= 0
        fix = 0;
        disp('Failed to record the eye');
        return;
    end

    % get the sample in the form of an event structure
    evt = Eyelink( 'NewestFloatSample');
    if eye_used ~= -1 % do we know which eye to use yet?

        % if we do, get current gaze position from sample
        x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
        y = evt.gy(eye_used+1);
        if x == el.MISSING_DATA | y == el.MISSING_DATA | evt.pa(eye_used+1)==0 | evt.pa(eye_used+1)== el.MISSING_DATA
            x = 0;
            y = 0;
        end
        % do we have valid data and is the pupil visible?
        mx = x;
        my = y;   
    end        
else
    [mx, my, ~] = GetMouse(p.w);
end

[t,r] = cart2pol(mx-cx,my-cy);
fix = r <= w;

end