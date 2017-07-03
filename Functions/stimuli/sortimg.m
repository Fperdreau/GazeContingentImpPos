Exlist.imp = Res(1,Res(3,:) == .90);
Exlist.pos = Res(1,Res(2,:) == .90);

imgcontent = getcontent('Objects','file','png');
cd(fullfile(folder,'Stimuli','Objects'));
newdir = fullfile(folder,'Stimuli','Examples','Impossible');
for im = Exlist.imp
    file = imgcontent{im,:};
    copyfile(file,fullfile(newdir,file));
end

cd(fullfile(folder,'Stimuli','Objects'));
newdir = fullfile(folder,'Stimuli','Examples','Possible');
for im = Exlist.pos
    file = imgcontent{im,:};
    copyfile(file,fullfile(newdir,file));
end