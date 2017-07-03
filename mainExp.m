function const = mainExp(const, test, Keys)
% Experiment using a gaze-contingent window paradigm and an object
% categorization task in order to measure the visual span of artists vs.
% nonartists subjects.
% 2 conditions: Central Window, Central Mask.
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

%% Resume experiment (get starting block number)
if const.Resume == 1
    fromblock = const.Fromblock;
else
    fromblock = 1;
end

%% Display Screen Parameters & open window
p = DisplayConf('wscr', 2, 'bgcol', [127 127 127], 'distance', 550, 'mode', 1, 'skip',1); % Main Screen
       
%% Texts
title = 'Practice. \n\n Press the Space button to continue';

restart = 'Do you want to restart the practice? (y/n)';

endtext = 'I know, it is sad, but this is the end...';

%% Start the Experiment
const.edfFile = [const.sub.name,'.edf']; % Eye-tracker file name
const.defautfilename = const.edfFile; % Set default EDF file name

%% Defragment memory
cd(const.datafolder);
save('AllVar.mat');
clearvars;
load('AllVar.mat');

%% Practice block
if const.Practice == 1
    
    % Get trials list for practice block
    practice = PracticeDesign(const,test);
    
    % Start practice trials
    while 1
        % Display instructions
        if const.sub.Lang == 1
            InstructionsEy('french',const,p);
        else
            InstructionsEy('english',const,p);
        end
        InstructionsEy('Examples',const,p);

        % Total number of trials
        ntrials = practice.ntesttrials;
        
        % Trials list
        design = practice.design;

        % GazeTracker Configuration, calibration and drift correction
        if const.DummyMode==0
            cd(const.datafolder);
            InstructionsEy('calib',const,p); % calibration instructions
            [const, el] = EyCustCal(p, const);

            % Drift Correction
            EyelinkDoDriftCorrection(el);
        else
            el = [];
        end
        
        % Show experiment welcome message and wait for key press.
        Displaynwait(title);
        
        % Launch the experiment
        expTrials(p, const, test, el, Keys, design, ntrials);
        
        % Ask to restart
        keyCode = Displaynwait(restart);
        if keyCode(Keys.Practice(1))
            continue;
        else
            break;
        end
    end
end

%% Start the test blocks
% Total number of test trials
ntrials = test.bloStep;

for block = fromblock : test.nblock
    % Subject data filename
    const.filename = [const.sub.name, '-', num2str(const.blocType), '-',num2str(block)];
    
    % Subject EDF filename
    const.edfFile = strcat(const.filename,'.edf');
    const.defautfilename = const.edfFile;
    
    % Get trials list for the current block
    design = test.DesignCell{block};

    % Display block information and wait for key press
    text = ['Block ', num2str(block),'/',num2str(test.nblock),' blocks. \n\n Press a key to continue.'];
    Displaynwait(text);
    
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
        Data = expTrials(p, const, test, el, Keys, design, ntrials);
    catch err
        disp(err);
        save(sprintf('%s/resume_%s.mat',const.datafolder,const.sub.name),'block','test','const','err');
        sprintf('name: %s | block: %d',const.sub.name,block)
        cleanup;
        return
    end
    
    % Save Data
    cd(fullfile(const.folder,'Data'));
    AllData.Age = const.sub.Age;
    AllData.Eye = const.sub.Eye;
    AllData.Corr(block,:) = Data.Corr;
    AllData.Resp(block,:) = Data.Resp;
    AllData.RT(block,:) = Data.RT;
    AllData.cat(block,:) = Data.cat;
    AllData.Win(block,:) = Data.Win;

    cd(const.datafolder);
    save([const.filename,'.mat'],'AllData','const','test','p');
    
    % For pre-test (Check if participant reached minimum performances)
    if block == 1 && const.Pretest == 1
        corr = sum(Data.Corr(block,:))/20; % Proportion of correct responses
        if corr < const.Exp.minthresh
            fprintf('Subject %s has a performance of %d <.80 \n',const.sub.name,corr);
            fprintf('Experiment aborted \n');
            break;
        end
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

