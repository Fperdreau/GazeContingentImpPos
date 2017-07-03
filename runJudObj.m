function runJudObj
%--------------------------------------------------------------
% E.g: JudObj
%
% Simple experiment whom aim is to judge whether an object is structurally
% possible or impossible.
%
% Author: Florian Perdreau (Laboratoire Psychologie de la Perception)
%--------------------------------------------------------------

close all;
global p const test Keys cate

tic;

%% Mac/Windows compatibility
KbName('UnifyKeyNames');
if strcmp(computer, 'PCWIN')
    warning off MATLAB:DeprecatedLogicalAPI;
    folder=fullfile('E:','My Dropbox','PHD','Matlab');
%     folder=fullfile('c:\','Documents and Settings','lpp','Bureau','Matlab');
else
%     folder='/Users/lab/Documents/FP/Matlab';
    folder='/Users/florian/Dropbox/PHD/Matlab';
end

addpath(folder,[folder,'/Stimuli'],[folder,'/Functions'],[folder,'/Data'],'-end')
addpath([folder,'/Functions','/Exp_functions'],...
    [folder,'/Functions','/Graphic'],...
    [folder,'/Functions','/System'],...
    [folder,'/Functions','/Conversion'],...
    [folder,'/Functions','/Config'],...
    [folder,'/Functions','/Eyelink'],...
    [folder,'/Functions','/Stats'],'-end');
savepath;

Keys.StopAll=KbName('ESCAPE');

%% Load Data file
cd(fullfile(folder,'Data'));
if exist('JudObj.mat','file') ~= 0
    load('JudObj.mat','Data');
    save('JudObj_backup','Data');
end

const.NumSubj = size(Data.Resp,1) + 1;

fprintf('Subject num :%d \n %s (%s)\n', const.NumSubj, mfilename, datestr(now));
fprintf('Press ESC to stop the experiment.\n');
commandwindow;


%% Display Screen Parameters & open window
Scr = max(Screen('Screens'));
pixelSize = 32;
hz = 100;
p = setupwindow(Scr, hz, pixelSize, 255);

%% --------------------------------------------------------------
% Constant parameters (const structure)
const.ifi = 1/p.flipInt;
const.fixDuration = round(0.5*const.ifi);
const.size = round(p.rect(4)/2);
const.rect = [0 0 const.size const.size];
const.rect = CenterRectonPoint(const.rect,p.xc,p.yc/2);
const.rectTEXT = [0 0 200 50];
const.Imp = 'IMPOSSIBLE';
const.Pos = 'POSSIBLE';
const.rectIM = CenterRectonPoint(const.rectTEXT,p.xc/2,p.yc+p.yc/2);
const.rectPO = CenterRectonPoint(const.rectTEXT,p.xc + (p.xc/2),p.yc+p.yc/2);
x = const.rectIM(RectLeft);
y = const.rectIM(RectTop);
const.rectIMCen = [x,y];
x = const.rectPO(RectLeft);
y = const.rectPO(RectTop);
const.rectPOCen = [x,y];
%% --------------------------------------------------------------
% Preload Images
cd(fullfile(folder,'Stimuli')); 
load('Obj.mat','Mat');
cate = Mat;
clear Mat;

%% --------------------------------------------------------------
% Setting of general variable for the experiment
test.nimg= size(cate,3); % number of image per categories
test.ntri= 1; % number of trial per image
test.design = fullfact([test.ntri test.nimg]); % factorial experimental plan
test.design = test.design(randperm(length(test.design(:,1))),:); % randomize trials order
test.ntesttrials = size(test.design);
test.ntesttrials = test.ntesttrials(1); % Number of test trials

%% --------------------------------------------------------------
%Start the Experiment

% Display instructions
% Text settings
text=['Objects are going to be presented.'...
    '\n Your task is to determine whether the object is structurally POSSIBLE or IMPOSSIBLE.'...
    '\n Click on the corresponding box by using the left button of the mouse.'...
    '\n\n Press any key to start the experiment'];
Displaynwait(text);
    
% Declare matrices for data storage
ImgList = test.design(:,2)';
        
% Launch the experiment
Resp = judObjTrials(test.ntesttrials);

%% Save Data
cd(fullfile(folder,'Data'));
Data.Resp(const.NumSubj,:) = Resp;
Data.Img(const.NumSubj,:) = ImgList;
save('JudObj.mat','Data');

% Remove back up files
if exist('Resp.mat','file') ~= 0
    delete('Resp.mat');
end

%% End of the experiment
text = 'Thank you for your participation';
Displaynwait(text);
EndTime = toc;
disp(EndTime);

% Cleanup and close
cleanup;
return;

%% --------------------------------------------------------------
% Functions
% Cleanup Functions
function cleanup
    Screen('CloseAll');
    Priority(0);
    commandwindow;
end

end

