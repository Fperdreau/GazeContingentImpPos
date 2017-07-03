mainfun = 'ImpPosExp2.m';
dir = which(mainfun);
dir = dir(1:findstr(dir,mainfun)-2);
folder = dir;

datafolder = fullfile(folder,'Data','Subjects');
datafile = fullfile(folder,'Data','Weibull_logarea_Results_FREE','Results - 0.75');

dirList = getcontent(datafolder,'dir');
nS = numel(dirList);

for exp = 1:2
    CSV_name = fullfile(datafile,sprintf('Table_%d.csv',exp));
    fid = fopen(CSV_name,'w');
    fprintf(fid,'Name, Accept, Age, Gender, School, Freq, Years, Exp, Rating, Perf, RT \n');
    current_resfile = fullfile(datafile,sprintf('Results-%d.mat',exp));
    load(current_resfile,'All');
    
    for s = 1:nS
        fprintf(fid,'\n');
        current_name = dirList{s,:};
        accept = isempty(find(All.ind == s, 1));
        dataToWrite = {current_name,accept,All.Age(s),All.Gender(s),All.School(s),All.Freq(s),All.Years(s),All.Exp(s),All.Rates.means(s),...
            All.Beh.Perf(s,:),All.Beh.RT(s,:)};
        for d = 1:numel(dataToWrite)
            dat = dataToWrite{d};
            if ~ischar(dat)
                for dt = 1:numel(dat)
                    datstr = num2str(dat(dt));
                    fprintf(fid,'%s, ',datstr);
                end
            else
                fprintf(fid,'%s, ',dat);
            end
        end
    end
    clear All
    fclose(fid);
end
    


