function runDemo
    % This function runs a demonstration of the gaze-contingent experiment.
    % During this experiment, line-drawings of objects are presented on a 
    % computer screen and participant has to decide whether the object is
    % structurally possible or impossible. However, the object is only
    % partially visible: a gaze-contingent window either blocks central or 
    % peripheral visual information.
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

    %% User interface
    clear S;
    S.DummyMode = { {'0' '{1}'} };
    S.Movie = { {'{0}' '1'} };
    S.Pretest = { {'{0}' '1'} };
    S.whichPC = {'PC box|{PC lap}|Mac off'};
    const = StructDlg(S,'Informations',[],[]);
    clear S;

    const.Resume = 0;
    const.folder = PATH_TO_ROOT;

    %% Mac/Windows compatibility
    KbName('UnifyKeyNames');

    %% Keys settings
    Keys = KeysConf();
       
    %% Subject information
    const = SubjInf(const);

    %% Experiments' order
    for i=1:10
        const.order = randperm(2);
    end

    %% Display information
    p = DisplayConf('wscr', 2, 'bgcol', [127 127 127], 'distance', 550, 'mode', 1, 'skip',1); % Main Screen
    sca;
    
    %% Experiments settings
    const = EyExpconf(p, const);
   
    %% Eye-tracking experiments
    cpt = 0;
    for exp = [1 2]
        cpt = cpt + 1;
        const.blocType = exp;
        if const.blocType == 1
            const.Exp.apert = const.Exp.apertType1;
        else
            const.Exp.apert = const.Exp.apertType2;
        end
           
        %% Experiments design
        [const, test] = ExpDesignDemo(const);
                
        %% Launch Experiement
        const = demoExp(const,test,Keys);
        
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




