
close all;
clear;

[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
im=imread(s);

im = imresize(im, [480 NaN]);

imo=im;

imgray = rgb2gray(imo);
%figure,imshow(imo);
imgray=imadjust(imgray);
%imgray=histeq(imgray);
%figure,imshow(imgray)
imbin = imbinarize(imgray);
%im=imsharpen(im);
im=gpuArray(im);

im = edge(imgray, 'sobel');
%figure,imshow(im)

%% Number plate reading
noPlate =getNumPlate(im, imbin, imo);
if length(noPlate) < 6
    im = imdilate(im, strel('diamond', 2));
    im = imfill(im, 'holes');
    im = imerode(im, strel('diamond', 10));
    noPlate = getNumPlate(im,imbin, imo);
end
%{
if length(noPlate) < 6
    res=ocr(imo);
    disp(res.Text)
end
%}

len = length(noPlate);
if len >= 8
    if noPlate(3) == 'O' || noPlate(3) == 'D'
        noPlate(3) = '0'; end
    if noPlate(len-6) == 'O' || noPlate(len-6) == 'D'
        noPlate(len-6) = '0'; end
    if noPlate(len) == 'O' || noPlate(len) == 'D'
        noPlate(len) = '0'; end
    if noPlate(len-1) == 'O' || noPlate(len-1) == 'D'
        noPlate(len-1) = '0'; end
    if noPlate(len-2) == 'O' || noPlate(len-2) == 'D'
        noPlate(len-2) = '0'; end
    if noPlate(len-3) == 'O' || noPlate(len-3) == 'D'
        noPlate(len-3) = '0'; end
    if noPlate(len) == 'B' 
        noPlate(len) = '8'; end
    if noPlate(len-1) == 'B' 
        noPlate(len-1) = '8'; end
    if noPlate(len-2) == 'B' 
        noPlate(len-2) = '8'; end
    if noPlate(len-3) == 'B' 
        noPlate(len-3) = '8';
    end
end
disp(noPlate);



%res=ocr(imo);
%disp(res.Text)
