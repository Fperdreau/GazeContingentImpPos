function const = SubjInf(const)

clear S;
S.name={'test'};
S.Age={'none'};
S.Eye={ {'{r}' 'l'} }; % 'r' for righthander, 'l' for lefthander.
S.Gender={ {'f' '{m}'} };
S.Lang = { {'{1}' '2'} }; % 1 = french, 2 = english
S.School = { {'{0}' '1'} };
S.Exp = {'0'};
S.Freq = {'Daily|Weekly|Monthly'};
const.sub = StructDlg(S,'Informations',[],[]);

% create a folder for the subject data
if ~isdir(fullfile(const.folder, 'Data', 'Subjects'))
    mkdir(fullfile(const.folder, 'Data', 'Subjects'));
end

cd(fullfile(const.folder, 'Data', 'Subjects'));
if exist(const.sub.name, 'dir')
    createNewfolder = input('This folder already exist \n overwrite(o), change name(c) ?','s');
    if strcmp(createNewfolder,'c')
        newName = input('Subject initials :','s');
        const.sub.name = newName;
    end
end
mkdir(const.sub.name);

% directories
const.date = datestr(now,'ddmmyy');
const.defautfilename = sprintf('%s.edf',const.sub.name);
const.datafolder = fullfile(const.folder,'/Data/Subjects/',const.sub.name);

% save subject information
save(sprintf('%s/%s_inf.mat',const.datafolder,const.sub.name),'const');


end