function Resp = judObjTrials(ntrials)

global p const test Keys cate

Resp = zeros(1,ntrials);
[keyIsDown,secs,keyCode] = KbCheck; %#ok<*ASGLU>
trial = 0;

while 1 && trial<ntrials
    for trial=1:ntrials
        ok = 0;
        ncount = 0;
        
        %--------------------------------------------------------------
        % Mouse cursor position if const.DummyMode==1

        [a,b]=RectCenter(p.rect);
        WaitSetMouse(a,b,p.screenNum); % set cursor and wait for it to take effect
        
        while ~ok
            while ncount < const.fixDuration
                % Blank Screen
                Screen('FillRect',p.w,p.backgroundcolor);
                Screen('Flip',p.w');
                ncount = ncount + 1;
            end

            % display images
            Im = Screen('MakeTexture',p.w,cate(:,:,test.design(trial,2)));  % Impossible Objects
            Screen('DrawTexture',p.w,Im,[],const.rect);
            [nx, ny, bboxImp] = DrawFormattedText(p.w,const.Imp,const.rectIMCen(1),const.rectIMCen(2),0);
            [nx, ny, bboxPos] = DrawFormattedText(p.w,const.Pos,const.rectPOCen(1),const.rectPOCen(2),0);
            Screen('FrameRect',p.w,0, const.rectIM);
            Screen('FrameRect',p.w,0, const.rectPO);
            Screen('Flip',p.w);

            [mx, my, buttons]=GetMouse; %#ok<*NASGU> %(w);
            cond1 = (mx > const.rectIM(1) && mx<const.rectIM(3));
            cond2 = (my > const.rectIM(2) && my<const.rectIM(4));
            cond3 = (mx > const.rectPO(1) && mx<const.rectPO(3));
            cond4 = (my > const.rectPO(2) && my<const.rectPO(4));
            if ((cond1 && cond2) || (cond3 && cond4)) && ~isempty(find(buttons, 1))
                if (cond1 && cond2)
                    response = 1; % impossible
                else
                    response = 2; % possible
                end
                Resp(trial) = response;
                WaitSecs(0.5);
                ok = 1;
            end
            
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown
                if keyCode(Keys.StopAll)
                    fprintf('Experiment aborted by the user');
                    sca;
                    return;
                end
            end
        end
        if keyCode(Keys.StopAll)
            fprintf('Experiment aborted by the user');
            sca;
            return;
        end
        Screen('Close');
        
        % save Data
        save('Resp.mat','Resp');

    end
end

return;
                
            

        

    

