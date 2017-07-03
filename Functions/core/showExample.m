function showExample(folder,p)

cd(fullfile(folder,'Stimuli')); 

imp = imread('Eximp.jpg','jpg');
pos = imread('Exposs.jpg','jpg');

rect.im = p.screensize/2;

rect.im = [0 0 p.rect(3)/2 p.rect(4)/2];
rect.imR = CenterRectOnPoint(rect.im,p.xc,p.yc/2);
rect.text = p.yc+(p.yc/2);


Screen('FillRect',p.w,p.gray);
impEx = Screen('MakeTexture',p.w,imp);
posEx = Screen('MakeTexture',p.w,pos);

for i =1:2
    if i ==1
        Screen('DrawTexture',p.w,impEx,[],rect.imR);
        DrawFormattedText(p.w,'IMPOSSIBLE','center',rect.text);
    else
        Screen('DrawTexture',p.w,posEx,[],rect.imR);
        DrawFormattedText(p.w,'POSSIBLE','center',rect.text);
    end

    Screen('Flip',p.w);
    pause
end
Screen('Close');
clear impEx posEx imp pos rect;
end
   