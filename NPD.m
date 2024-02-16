function varargout = NPD(varargin)
% NPD MATLAB code for NPD.fig
%      NPD, by itself, creates a new NPD or raises the existing
%      singleton*.
%
%      H = NPD returns the handle to a new NPD or the handle to
%      the existing singleton*.
%
%      NPD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NPD.M with the given input arguments.
%
%      NPD('Property','Value',...) creates a new NPD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NPD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NPD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NPD

% Last Modified by GUIDE v2.5 23-Apr-2023 18:49:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NPD_OpeningFcn, ...
                   'gui_OutputFcn',  @NPD_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before NPD is made visible.
function NPD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NPD (see VARARGIN)

% Choose default command line output for NPD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NPD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NPD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function noPlate = getNumPlate(im, imbin, imo)
global imc;
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
global noPlate;
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
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global imc;
global noPlate;
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
im=imread(s);
axes(handles.axes1);
imshow(im);

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
axes(handles.axes2);
imshow(imc);
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
set(handles.screen,'String',noPlate);
set(handles.screen,'FontSize',24);



%res=ocr(imo);
%disp(res.Text)

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function text2_Callback(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text2 as text
%        str2double(get(hObject,'String')) returns contents of text2 as a double


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function screen_Callback(hObject, eventdata, handles)
% hObject    handle to screen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screen as text
%        str2double(get(hObject,'String')) returns contents of screen as a double


% --- Executes during object creation, after setting all properties.
function screen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global noPlate;
set(handles.screen,'String',noPlate);
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
