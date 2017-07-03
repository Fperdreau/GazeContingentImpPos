% This script convert frame snapshots taken during experiment demo and
% convert them into a movie.
%
% @author: Florian Perdreau

% Wirking directory
x = what;
folder = x.path;
    
% Get list of folders
list = getcontent(folder,'dir');

% Length of list
n = size(list,1);

% Loop over folders
for i = 1:n
    ext = list{i,:};
    ext = ext(10:end);
    
    % Load data
    new = fullfile(folder, sprintf('MovieDem-%s', ext));
    content = load(fullfile(new, sprintf('Mov-%s.mat',ext)), 'imageArray');
    imageArray = content.imageArray;
    
    % Defrag memory
    defrag;
    
    data = [];
    d = size(imageArray,4);
    imSave = 0;
    
    % Converting images
    fprintf(1,'\n Conversion \n');
    c = ones(1,d);
    for tIm = 1:d
        if max(max(imageArray(:,:,:,tIm))) > 1
            imageArray(:,:,:,tIm) = imageArray(:,:,:,tIm)./255;
        else
            imageArray(:,:,:,tIm) = imageArray(:,:,:,tIm);
        end
        if isempty(find(imageArray(:,:,:,tIm) ~= 0,1))
            c(tIm) = 0;
        end  
    end
    imageArray = imageArray(:,:,:,c==1);
    if isempty(imageArray)
        continue
    end
    mov = immovie(imageArray);
    avif = fullfile(new,sprintf('Mov-%s.avi',ext));    
    movie2avi(mov, avif, 'compression', 'none','fps',25);
    
    clear imageArray
end
fprintf('Done \n');
