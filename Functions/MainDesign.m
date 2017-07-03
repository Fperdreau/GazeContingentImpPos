function  [const, test] = MainDesign(const)
% This function generates randomized list of trials
% Inputs
% @param struct const: struct-array providing experiments constants
% 
% Returns
% @return struct const: struct array providing updated experiments
% constants
% @return struct test: struct-array storing design information
%
% @author: Florian Perdreau

%% Setting of general variable for the experiment

test.nblock = 9; % number of test blocks
test.ncat = 2; % number of tested categories;
test.nimg = 30; % number of image per categories
test.ntri = 10; % number of trial per condition
test.nori = 3; % number of different orientation (rotation and reflection)
test.nwindow = 9; % Number of window apertures
test.design = fullfact([test.ntri, test.ncat, test.nwindow]); % factorial experimental plan
test.ntesttrials = size(test.design,1); % Total number of trials

for i= 1:test.nwindow
    test.design(test.design(:,3) == i,3) = const.Exp.apert(i);
end
fprintf('trials: %d | win: %d | cat: %d \n',test.ntesttrials, length(find(test.design(:,3) == const.Exp.apert(1))), test.ntesttrials/2)

%% Set images order
cd(fullfile(const.folder, 'Stimuli'));
load('TestImg.mat', 'Res');
test.poss = Res(1, Res(2,:) >= const.Exp.level);
test.imp = Res(1, Res(3,:) >= const.Exp.level);
test.poss = test.poss(randperm(size(test.poss, 2)));
test.poss = test.poss(1:test.nimg);
test.imp = test.imp(randperm(size(test.imp, 2)));
test.imp = test.imp(1:test.nimg);

%% Set image and orientation order
impimg = sort([test.imp, test.imp, test.imp]);
posimg = sort([test.poss, test.poss, test.poss]);

for i = 1:test.nori:test.ntesttrials/2
    ori(i:i+test.nori-1) = 1:test.nori;
end
impimg(2,:) = ori; 
posimg(2,:) = ori;

impimg = impimg(:,randperm(size(impimg,2)))';
posimg = posimg(:,randperm(size(posimg,2)))';

test.design(test.design(:,2) == 1,4:5) = impimg;
test.design(test.design(:,2) == 2,4:5) = posimg;

%% Randomize the trials
test.design = test.design(randperm(length(test.design(:,1))),:); % randomize trials order

test.bloStep = test.ntesttrials/(test.nblock); % Number of trials per block

% Split trials list into separated blocks
in = 1;
en = test.bloStep;
test.DesignCell = cell(test.nblock);
for b = 1:test.nblock
    test.DesignCell{b}= test.design(in:en,:);
    in = in + test.bloStep;
    en = en + test.bloStep;
end

% Save trials list
save(sprintf('%s/%s_design.mat',const.datafolder,const.sub.name),'const','test');

end