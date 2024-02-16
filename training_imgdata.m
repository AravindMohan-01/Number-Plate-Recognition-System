clc;           
clear;        
close all;  
di=dir('letters_numbers');
st={di.name};
nam=st(3:end);
imgfile=cell(2,length(nam));
for i=1:length(nam)
   t =imread(strcat('letters_numbers','/',cell2mat(nam(i))));
   t=imresize(t,[42 24]);
   imgfile(1,i)={t(:,:,1)};
   temp=cell2mat(nam(i));
   imgfile(2,i)={temp(1)};
end
save('imgfildata.mat','imgfile');
