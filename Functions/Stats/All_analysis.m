function All_analysis(whichsub,cont)

% Analyse of subjects data
% opt = bloc type
% whichsub (optional) = subject to analyse
% retrieve the structure array All, which contains Means, fit and rates.
%
% Florian Perdreau 2011

if exist('whichsub','var') == 0
    whichsub = [];
end

param.cont = 1;
param.silent = 1;
param.group = 1;
param.whichCorr = 'Spearman';

whichana = input('Which analysis? (a)ll, (b)ehavioral, (e)yes, (g)roup? ','s');

%% Mac/Windows compatibility

mainfun = 'ImpPosExp2.m';
dir = which(mainfun);
dir = dir(1:findstr(dir,mainfun)-2);
folder = dir;

addpath(genpath(folder),...
    genpath([folder,'/Stimuli:']),...
    genpath([folder,'/Functions:']),...
    genpath([folder,'/Data:']),...
    '-end')

%% Create folder settings
param.root = folder;
param.datafolder = fullfile(folder,'Data');
param.targetfold = fullfile(folder,'Data','Subjects');
param.statfolder = fullfile(folder,'/Functions/Stats');
param.EyeFolder = fullfile(folder,'Data','EyeData');
param.Imgfolder = fullfile(folder,'Stimuli','Objects');

param.SourceFolder = fullfile(folder,'Data','Weibull_logarea_FREE');
param.resultsFolder = fullfile(folder,'Data','Weibull_logarea_Results_FREE');

if ~isdir(param.resultsFolder)
    mkdir(param.resultsFolder);
end
if ~isdir(param.SourceFolder)
    mkdir(param.SourceFolder);
end

%% Get the list of directories (subjects folders)
dirList = getcontent(param.targetfold,'dir');

%% Some parameters
param.dirList = dirList;
param.Eperf = [.50 .75 .80];        % used for computing the visual span
param.scan = 0;                     % Should we perform a scanpath analysis

%% Start individual analysis (behavioral)
if strcmp(whichana,'a') || strcmp(whichana,'b')
    subj_analysis(param,whichsub);
end

%% start group analysis (behavioral)
if strcmp(whichana,'a') || strcmp(whichana,'g')
    Group_analysis(param);
end

%% Start eye-movement analysis
if strcmp(whichana,'a') || strcmp(whichana,'e')
%     sub_eye_analysis(param, whichsub);
    Group_eye_analysis(param);
end

disp('Analyses are done');
end

