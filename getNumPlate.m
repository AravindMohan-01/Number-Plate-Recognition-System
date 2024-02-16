function noPlate = getNumPlate(im, imbin, imo)
[h,w]=size(im);
Iprops=regionprops(im,'BoundingBox','Area', 'Image');
hold on
i=1;
while i<numel(Iprops)
   [ih,iw]=size(Iprops(i).Image);
   if (ih/iw >0.5) || (iw< w/10) || (ih/iw <0.1) || (ih < h/100)
       %rectangle('Position',Iprops(i).BoundingBox,'EdgeColor','r','LineWidth',2) 
       Iprops(i)=[];
       i=i-1; 
   else
       %rectangle('Position',Iprops(i).BoundingBox,'EdgeColor','g','LineWidth',2)
       %im1=imcrop(imo, Iprops(i).BoundingBox);
       %res=ocr(im1);
       %disp(res.Text)
   end
   i=i+1;
end
count = numel(Iprops);


%%noPlate=[]; % Initializing the variable of number plate string.
%max=bwarea(im)
noPlate='';
while isempty(noPlate) && numel(Iprops)>0
area = Iprops.Area;
count = numel(Iprops);
maxa= area;
pos=1;
boundingBox = Iprops(pos).BoundingBox;

for i=1:count
   %rectangle('Position',Iprops(i).BoundingBox,'EdgeColor','g','LineWidth',2)
   if maxa<Iprops(i).Area %&& Iprops(i).Area < max
       maxa=Iprops(i).Area;
       pos=i;
       boundingBox=Iprops(i).BoundingBox;
   end
end  


imc = imcrop(imbin, boundingBox);


%resize number plate to 240 NaN
imc = imresize(imc, [240 NaN]);
%figure, imshow(imc);
imco= imcrop(imo, boundingBox);
%clear dust
imc = imopen(imc, strel('rectangle', [4 4]));

%remove some object if it width is too long or too small than 500
imc = bwareaopen(~imc, 500);
%figure, imshow(imc);
 [h, w] = size(imc);
% disp(w/h);
%figure,imshow(imc);

IpropsC=regionprops(imc,'BoundingBox','Area', 'Image','Orientation');

count = numel(IpropsC);

hold on
for i=1:count
   ow = length(IpropsC(i).Image(1,:));
   oh = length(IpropsC(i).Image(:,1));
   if ow<(w/2) && oh>(7*h/24) && (ow/oh <1.2) && (ow/oh >0.19)
       %disp(ow/oh);
       %rectangle('Position',IpropsC(i).BoundingBox,'EdgeColor','g','LineWidth',2)
       letter=readLetter(IpropsC(i).Image); % Reading the letter corresponding the binary image 'N'.
       %figure,  imshow(IpropsC(i).Image);
       noPlate=[noPlate letter]; 
   end
   
end
hold off
Iprops(pos)=[];

if length(noPlate) < 6
    noPlate = [];
else
    figure, imshow(imc);
end
end
%disp(noPlate);
%res=ocr(imco);
%var=res.Text;
%len =length(var)
%var=strip(var);
%var = regexprep(var,'[^a-zA-Z0-9]','')
