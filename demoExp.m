function const = demoExp(const,test,Keys)
% Experiment using a gaze-contingent window paradigm and an object
% categorization task in order to measure the visual span of artists vs.
% nonartists subjects.
% 2 conditions: Central Window (opt=1), Central Mask (opt=2).
%
% NOTE: This only run the DEMO version of the experiment (do not call pre-test,
% practice or drawing task
%
% @params struct const: struct array providing experiment settings
% @params struct test: struct-array providing design information
% @params struct Keys: struct-array providing keys used in experiment
%
% @return struct const: struct array providing updated experiment settings
%
% @author: Florian Perdreau (Laboratoire Psychologie de la Perception)
% @copyright: Florian Perdreau, 2011

%% Start timer
tic;

%% User interface
fprintf('Press ESC to stop the experiment.\n');
commandwindow;

%% Display Screen Parameters & open window
p = DisplayConf('wscr', 2, 'bgcol', [127 127 127], 'distance', 550, 'mode', 1, 'skip',1); % Main Screen
       
%% Texts
endtext = 'I know, it is sad, but this is the end...';

%% Start the Experiment
const.edfFile = [const.sub.name,'.edf'];
const.defautfilename = const.edfFile;

%% Defragment memory
cd(const.datafolder);
save('AllVar.mat');
clearvars;
load('AllVar.mat');

%% Start the test blocks
for block = 2
    if block == 1
        ntrials = 2;
    else
        ntrials = 3;
    end
    const.filename = [const.sub.name,'-',num2str(const.blocType),'-',num2str(block)];
    const.edfFile = strcat(const.filename,'.edf');
    const.defautfilename = const.edfFile;
    design = test.DesignCell{block};

    text = ['Block ', num2str(block),'/',2,' blocks. \n\n Press a key to continue.'];
    Displaynwait(text);
    
    %--------------------------------------------------------------
    % GazeTracker Configuration, calibration and drift correction
    if const.DummyMode==0
        cd(const.datafolder);
        [const, el] = EyCustCal(p, const);
        
        % Drift Correction
        EyelinkDoDriftCorrection(el);
    else
        el = [];
    end
    
    % Launch the experiment
    try
        demoTrials(p, const, test, el, Keys, design, ntrials);
    catch err
        disp(err);
        sprintf('name: %s | block: %d',const.sub.name,block)
        cleanup;
    end
    
    % check for abortion
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Keys.StopAll)
            sprintf('Experiment aborted by the user \n');
            break;
        end
    end
end
Displaynwait(endtext);

%% End of Experiment; close the file first close graphics window.
cleanup;
return;

%% Nested Functions
function cleanup
    % This function implement clean-up routine: close connection to
    % Eye-tracker and clean variables
    % @return: void
    
    sprintf('This part of the experiment took: %d min',floor(toc/60));
    if const.DummyMode==0
        Eyelink('Shutdown');
    end
    Screen('CloseAll');
    clear mex;
    
    % Remove back up files
    content = getcontent(const.datafolder,'file','mat');
    if ~isempty(find(strcmp(content,'AllVar.mat'), 1))
        delete(fullfile(const.datafolder, 'AllVar.mat'));
    end
    
    Priority(0);
    commandwindow;
end

end

