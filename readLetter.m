function letter=readLetter(snap)


load imgfildata % Loads the templates of characters in the memory.
snap=imresize(snap,[42 24]); % Resize the input image so it can be compared with the template's images.
comp=[ ];
for n=1:length(imgfile)
    t = imgfile{1,n};
    t2 = t(:,:,1);
    sem=corr2(t2,snap); % Correlation the input image with every image in the template for best matching.
    comp=[comp sem]; % Record the value of correlation for each template's character.
    %display(sem);
    
end
vd=find(comp==max(comp)); % Find the index which correspond to the highest matched character.
if length(vd)
    temp=cell2mat(imgfile(2,vd));
    letter=temp(1);
else
    letter='';
end

