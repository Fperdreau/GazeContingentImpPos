function runExp
    % This function runs the full set of experiment conditions.
    %
    % List of conditions:
    %   - Drawing task: participant has to copy as accurately as possible a
    %   model picture displayed on a computer screen within a limited time.
    %   - Pre-test: Pre-selected objects are presented to the participant
    %   and his task is to judge whether the object is structurally
    %   possible or impossible. Objects are fully visible during this
    %   condition.
    %   - Gaze-contingent experiment: during this experiment, line-drawings
    % of objects are presented on a computer screen and participant has to 
    % decide whether the object is structurally possible or impossible. 
    % However, the object is only partially visible: a gaze-contingent 
    % window either blocks central or peripheral visual information.
    %
    % @author: Florian Perdreau
    % @copyright: Florian Perdreau, University Paris Descartes, 2012
    
    clearvars;
    close all;
    
    %% Get environment information
    x = what;
    PATH_TO_ROOT = x.path;
    PATH_TO_FUNCTIONS = fullfile(PATH_TO_ROOT, 'Functions');
    PATH_TO_DATA = fullfile(PATH_TO_ROOT, 'Data');
    PATH_TO_STIMULI = fullfile(PATH_TO_ROOT, 'Stimuli');

    % Make data folder if it does not exist yet
    if ~isdir(PATH_TO_DATA)
        mkdir(PATH_TO_DATA);
    end
    
    % Add folders to MATLAB path
    addpath(genpath(PATH_TO_ROOT),...
        genpath([PATH_TO_STIMULI, ':']),...
        genpath([PATH_TO_FUNCTIONS, ':']),...
        genpath([PATH_TO_DATA, ':']),...
        '-end')
    savepath;
    
    %% Admin interface
    clear S;
    S.Resume = { {'{0}' '1'} };
    S.DummyMode = { {'{0}' '1'} };
    S.Demo = { {'{0}' '1'} };
    S.Pretest = { {'0' '{1}'} };
    S.ConvImg = { {'{0}' '1'} };
    S.Practice = { {'0' '{1}'} };
    S.whichPC = {'{PC box}|PC lap|Mac off'};
    const = StructDlg(S,'Informations',[],[]);
    clear S;

    const.folder = PATH_TO_ROOT;
    %% Mac/Windows compatibility
    KbName('UnifyKeyNames');

    %% Keys settings
    Keys = KeysConf;
       
    if const.Resume == 0 || const.Demo == 1
        %% Subject information
        const = SubjInf(const);
        
        %% Experiments' order
        const.order = [2 1];

        %% Display information
        p = DisplayConf('wscr', 2, 'bgcol', [127 127 127], 'distance', 550, 'mode', 1, 'skip',1); % Main Screen
        sca;
        
        %% Experiments settings
        const = EyExpconf(p,const);

        %% Drawing experiment
        const.starttiscame = clock;
        fprintf('\nPress any key when ready to start\n');
        pause;
        DrawingTask(const,Keys);
    else
        [const, test, p, AllData] = resumeinf(const.folder);
    end
   
    %% Eye-tracking experiments
    cpt = 0;
    for exp = const.order
        cpt = cpt + 1;
        const.blocType = exp;
        if const.blocType == 1
            const.Exp.apert = const.Exp.apertType1;
        else
            const.Exp.apert = const.Exp.apertType2;
        end
           
        %% Experiments design
        if const.Resume == 0
            if const.Pretest == 0
                [const, test] = MainDesign(const);
            else
                [const, test] = PreTestDesign(const);
            end
        end
        
        %% Launch Experiement
        if const.Demo == 0
            const = mainExp(const,test,Keys);
        else 
            const = demoExp(const,test,Keys);
        end
        const.Resume = 0;
        
        if cpt == 1
            aswcont = input('Do you want to continue? (y)es or (n)o','s');
            if strcmp(aswcont,'y')
                continue;
            else
                break;
            end
        end
    end

    const.endtime = clock;
    
    %% End of the experiment
    clearvars;

end




