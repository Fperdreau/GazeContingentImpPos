function JudgDraw

% Assessment of hand drawing accuracy
%
% Independent observer is presented a series of hand drawings made by
% participants and has to rate them based on several criteria:
% - 'Similarity'
% - 'General Proportion'
% - 'Proportion of the left side'
% - 'Proportion of the right side (head)'
% - 'Details of the texture'
% - 'Shadows'
% - 'Geometry of volumes'
% - 'Angle top-middle tentacle/head'
%
% @author: Florian Perdreau
% History: 30.11.2011

tic;
%% Mac/Windows compatibility
KbName('UnifyKeyNames');
if strcmp(computer, 'PCWIN')
    warning off MATLAB:DeprecatedLogicalAPI;
    folder=fullfile('E:','My Dropbox','PHD','ImpPosExp'); % PC perso (win)
%     folder=fullfile('c:\','Florian','ImpPosExp'); % PC box (win)
else
%     folder='/Users/lab/Documents/FP/ImpPosExp'; %PC box (mac)
    folder='/Users/florian/Dropbox/PHD/ImpPosExp'; % PC office (mac)
end

addpath(genpath(folder),...
    genpath([folder,'/Stimuli:']),...
    genpath([folder,'/Functions:']),...
    genpath([folder,'/Data:']),...
    '-end')
savepath;

%% Folders
datafolder = fullfile(folder,'Data','JudDraw');
stimfolder = fullfile(folder,'Stimuli');
drawingfold = fullfile(folder,'Data','Drawings');

if ~isdir(datafolder)
    mkdir(datafolder)
end

%% Keys
Keys = KeysConf;

%% Rater infos
name = input('Subject name :','s');
subfilename = fullfile(datafolder,sprintf('%s.mat',name));
if exist(subfilename,'file') ~= 0
    rename = input('This file already exist. (O)verwrite, (R)ename ? ','s');
    if strcmp(rename,'r') || strcmp(rename,'R')
        name = input('Subject name :','s');
        subfilename = fullfile(datafolder,sprintf('%s',name));
    end
end

%% Load save file
filename = fullfile(datafolder,'DrawRate.mat');
fileback = fullfile(datafolder,'DrawRate_backup.mat');
if exist(filename,'file') ~= 0
    copyfile(filename,fileback);
    load(filename,'Draws');
    Resp = Draws.Resp;
    jud = size(Resp,2) + 1;
else
    jud = 1;
end

fprintf('Experiment Judge drawings, with judge %s: %d. \n',name,jud);

%% Get screen param.
Scr=max(Screen('Screens'));
pixelSize=32;
hz=120;
p=setupwindow(Scr, hz, pixelSize);

% Text Preferences
Screen('TextFont',p.w, 'Helvetica');
Screen('TextSize',p.w, 12);
Screen('TextStyle', p.w, 0);

%% Load & save images
modelfile = fullfile(stimfolder,'octopus.jpg');
model = imread(modelfile,'jpg');
model = rgb2gray(model);
DrawList = getcontent(drawingfold,'file','png');

%% Experiment design
Nchoice = 8; % levels on the scale
choice = 1:Nchoice;
ntrials = 5; % trials per drawing
nimg = size(DrawList,1);

for i = 1:ntrials
    orderimg = randperm(nimg);
    if exist('order','var') && ~isempty(order)
        order = [order,orderimg];
    else
        order = orderimg;
    end
end
Data = zeros(size(order,2),2);

total = size(order,2)*Nchoice;

%% Texts
criterion = {'Similarity',...
    'General Proportion',...
    'Proportion of the left side',...
    'Proportion of the right side (head)',...
    'Details of the texture',...
    'Shadows',...
    'Geometry of volumes',...
    'Angle top-middle tentacle/head'};     

%% Define rects
% Get original image proportion
draw = convImg(1);
[hd wd] = size(draw);
[hm wm] = size(model);
drawprop = hd/wd;
modelprop = hm/wm;

% define rects
% Upper part
Rect.Rect = [0 0 p.rect(3)*.5 p.rect(4)*.7];
Rect.w = round(Rect.Rect(3)*.90);
Rect.Img = [drawprop*Rect.w, Rect.w];
Rect.ModelRect = Rect.Rect;
Rect.DrawRect = [p.xc, 0, p.rect(3), Rect.Rect(4)];
Rect.Model = round([0 0 Rect.w modelprop*Rect.w]);
Rect.Draw = round([0 0 Rect.w drawprop*Rect.w]);
Rect.Model = CenterRect(Rect.Model,Rect.ModelRect);
Rect.Draw = CenterRect(Rect.Draw,Rect.DrawRect);
[xm, ~] = RectCenter(Rect.Model);
[xd, ~] = RectCenter(Rect.Draw);

% Lower Part
Rect.Down = [0 Rect.Rect(4) p.rect(3) p.rect(4)];
Rect.boxinit = round([0 0 300 30]);
Rect.box = CenterRect(Rect.boxinit,Rect.Down);
[xs, ys] = RectCenter(Rect.box);
Rect.def = round([0 0 Rect.boxinit(3)/Nchoice  Rect.boxinit(4)]);

on = Rect.box(1);
for b = 1:Nchoice
    Rect.boxes(b,:) = round([on, Rect.box(2), Rect.def(3)+on, Rect.box(4)]);
    on = on + Rect.def(3);
end

Rect.color = p.black;

for i = 1:Nchoice
    rect = Rect.boxes(i,:);
    [x, y] = RectCenter(rect);
    x = x - Rect.def(3)/4;
    y = y - Rect.def(4)/4;
    Rect.centers(i,:) = [x y];
end

%% Start the judgment
cpt = 1;
for im = 1:nimg
    DrawI = convImg(cpt);
    RectDraw = CenterRect(Rect.Draw,p.rect);
    Drawing = Screen('MakeTexture',p.w, DrawI);
    while 1
        Screen('DrawTexture',p.w,Drawing,[],RectDraw);
        
        Screen('Flip',p.w);
        
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && keyCode(Keys.navig(1))
            if cpt > 1
                cpt = cpt - 1;
            end
            break;
        elseif keyIsDown && keyCode(Keys.navig(2))
            cpt = cpt + 1;
            break;
        end   
    end
    Screen('Close');
end

    
for q = 1%:Nchoice % Criterion loop
    WaitSecs(0.1);
    
    for draw = 1:size(order,2) % drawing loop
        img = order(draw);
        [DrawI name] = convImg(img, Rect.Img(1), Rect.Img(2));
        ImName{draw} = name;
        model = imresize(model,Rect.Img(2:-1:1));
        modeltex = Screen('MakeTexture',p.w, model);
        Drawing = Screen('MakeTexture',p.w, DrawI);
        
        criter = criterion{q};
        l = (length(criter)/2)*10;
        
        WaitSecs(0.5);
        ok = 0;

        while ok == 0   

            for i = 1:Nchoice
                Screen('TextColor',p.w, [255 0 0]);
                Screen('FrameRect',p.w,Rect.color,Rect.boxes(i,:));
                Screen('DrawText', p.w, num2str(choice(i)), Rect.centers(i,1), Rect.centers(i,2), p.black);

                Screen('TextSize',p.w, 20);
                Screen('DrawText', p.w, 'Model', xm, 10, p.black);
                Screen('DrawText', p.w, 'Drawing', xd, 10, p.black);

            end
            Screen('TextSize',p.w, 14);
            Screen('DrawText', p.w, 'Very low accuracy', Rect.boxes(1,1) - 200, ys, p.black); 
            Screen('DrawText', p.w, 'Very high accuracy', Rect.box(3) + 50, ys, p.black);
              
            Screen('TextSize',p.w, 20);
            Screen('DrawText', p.w, sprintf('%2.0f',((draw+q)/total)*100), xs, ys - 200, [0 0 0]);
            
            Screen('TextSize',p.w, 20);
            Screen('DrawText', p.w, criter, xs-l, ys - 100, [200 0 0]);
            
            Screen('DrawTexture',p.w,modeltex,[],Rect.Model);
            Screen('DrawTexture',p.w,Drawing,[],Rect.Draw);

            Screen('Flip',p.w);

            [mx, my, buttons]=GetMouse; 
            if ~isempty(buttons(buttons == 1))
                for w = 1:Nchoice
                    fix = infixationWindow(mx,my,Rect.boxes(w,:));
                    if fix == 1
                        Data(draw,1) = img;
                        Data(draw,q+1) = w;
                        ok = 1;
                    end
                end
            end

            [keyIsDown,~,keyCode] = KbCheck;
            if keyIsDown && keyCode(Keys.StopAll)
                fprintf('Experiment aborted by the user \n');
                cleanup;
                return;
            end

        end % end of the while loop
        
    end
    
    Screen('Close');
    clear DrawI modeltex Drawing img;
    
end % end of the for (trials) loop

% Save responses
Data = sortrows(Data,1);
try
    save(subfilename,'Data','ImName','order','ntrials');
catch err
    disp(err);
    save(subfilename,'Data','ImName','order','ntrials');
end    

% end the judgement
toc;
cleanup;

%% Functions
    function cleanup
        Priority(0);
        commandwindow;
        Screen('CloseAll');
    end

    function fix = infixationWindow(mx,my,fixationWindow)
        % determine if mx and my are within fixation window
        fix = mx > fixationWindow(1) &&  mx <  fixationWindow(3) && ...
            my > fixationWindow(2) && my < fixationWindow(4) ;
    end

    % Convert images
    function [imdata imfile] = convImg(img, h, w)
        
        imfile = DrawList{img,:};
        ext = imfile(end-2:end);
        
        imdata = imread(imfile,ext);
        imdata = rgb2gray(imdata);
        if exist('h','var') ~= 0
            imdata = imresize(imdata,[h w]);
        end
    end

end
