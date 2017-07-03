function ListImg = verifimg(param,ind)

list = getcontent(param.targetfold,'dir');
list = list(ind,:);
for d = 1:size(list,1)
    imgc = 0;

    file = fullfile(param.targetfold,list{d,:},sprintf('%s-%d.mat',list{d,:},param.blocType));
    if exist(file,'file') ~= 0
        load(file,'test');
    else
        continue
    end    
    imglist = test.design(:,4)';
    listimg(d,:) = imglist;

    for i = imglist
        imgc = imgc +1;
        img(d,imgc) = sum(test.design(:,4) == i);
    end
    clear test
end


cpt = 0;
Newlist = 0;
for i = 1:numel(listimg)
    v = listimg(i);
    if ~isempty(find(listimg == v)) && isempty(find(Newlist == v))
        cpt = cpt + 1;
        Newlist(cpt) = v;
    end
end
ListImg = sort(Newlist);

end