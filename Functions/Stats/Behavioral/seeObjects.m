function seeObjects(Data,test,win)

content = getcontent('E:\My Dropbox\PHD\ImpPosExp\Stimuli\Objects','file','png');
x(1,:)=Data.Resp(Data.win == win);
x(2,:)=Data.cat(Data.win == win);
x(3,:) = test.design(test.design(:,3) == win,4);
for i = 1:size(x,2)
    im = x(3,i);
    img = imread(char(content(im,:)));
    fprintf('Img:%d | cat:%d | resp:%d \n',im,x(2,i),x(1,i));
    image(img);
    pause;
end

close all;

end