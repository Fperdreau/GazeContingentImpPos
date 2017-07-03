function [const, test, p, AllData] = resumeinf(folder)

const.folder = folder;

% load the last save
whichsub = input('Which subject? ','s');
whichexp = str2num(input('Which experiment? ','s'));
whichblock = str2num(input('Which block? ','s'));
file = sprintf('%s-%d-%d.mat',whichsub,whichexp,whichblock);
subjfolder = fullfile(const.folder,'Data','Subjects',whichsub);
load(fullfile(subjfolder,file),'const','test','p','AllData');

% Set some parameters
const.order = str2num(input('Which order?','s'));
const.Resume = 1;
const.Practice = 0;
const.Fromblock = str2num(input('From block? ','s'));

end