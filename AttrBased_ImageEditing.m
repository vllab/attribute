function varargout = AttrBased_ImageEditing(varargin)
% AttrBased_ImageEditing MATLAB code for AttrBased_ImageEditing.fig
%      AttrBased_ImageEditing, by itself, creates a new AttrBased_ImageEditing or raises the existing
%      singleton*.
%
%      H = AttrBased_ImageEditing returns the handle to a new AttrBased_ImageEditing or the handle to
%      the existing singleton*.
%
%      AttrBased_ImageEditing('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AttrBased_ImageEditing.M with the given INPUT arguments.
%
%      AttrBased_ImageEditing('Property','Value',...) creates a new AttrBased_ImageEditing or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI bcefore AttrBased_ImageEditing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AttrBased_ImageEditing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AttrBased_ImageEditing

% Last Modified by GUIDE v2.5 26-Jul-2016 13:39:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AttrBased_ImageEditing_OpeningFcn, ...
                   'gui_OutputFcn',  @AttrBased_ImageEditing_OutputFcn, ...
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


% --- Executes just before AttrBased_ImageEditing is made visible.
function AttrBased_ImageEditing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no RESULT args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AttrBased_ImageEditing (see VARARGIN)

% Choose default command line RESULT for AttrBased_ImageEditing
handles.output = hObject;

if ~isfield(handles,'hListener')
    handles.hListener1 = addlistener(handles.BA_sky_bar,'ContinuousValueChange',@BA_sky_bar_Callback);
    handles.hListener2 = addlistener(handles.BA_sea_bar,'ContinuousValueChange',@BA_sea_bar_Callback);
    handles.hListener3 = addlistener(handles.BA_sand_bar,'ContinuousValueChange',@BA_sand_bar_Callback);
end

set(handles.INPUT,'xtick', [], 'ytick', []);  
set(handles.LABEL,'xtick', [], 'ytick', []);
set(handles.RESULT,'xtick', [], 'ytick', []);

% set the slider range and step size
set(handles.BA_sky_bar, 'Min', 0);
set(handles.BA_sky_bar, 'Max', 1);
set(handles.BA_sky_bar, 'Value', 0);
set(handles.BA_sky_bar, 'SliderStep', [0.01, 0.1]);
set(handles.BA_sea_bar, 'Min', 0);
set(handles.BA_sea_bar, 'Max', 1);
set(handles.BA_sea_bar, 'Value', 0);
set(handles.BA_sea_bar, 'SliderStep', [0.01, 0.1]);
set(handles.BA_sand_bar, 'Min', 0);
set(handles.BA_sand_bar, 'Max', 1);
set(handles.BA_sand_bar, 'Value', 0);
set(handles.BA_sand_bar, 'SliderStep', [0.01, 0.1]);

set(handles.CT_sky_bar, 'Min', 0);
set(handles.CT_sky_bar, 'Max', 1);
set(handles.CT_sky_bar, 'Value', 0);
set(handles.CT_sky_bar, 'SliderStep', [0.01, 0.1]);
set(handles.CT_sea_bar, 'Min', 0);
set(handles.CT_sea_bar, 'Max', 1);
set(handles.CT_sea_bar, 'Value', 0);
set(handles.CT_sea_bar, 'SliderStep', [0.01, 0.1]);
set(handles.CT_sand_bar, 'Min', 0);
set(handles.CT_sand_bar, 'Max', 1);
set(handles.CT_sand_bar, 'Value', 0);
set(handles.CT_sand_bar, 'SliderStep', [0.01, 0.1]);
% save the current/last slider value
handles.per_value(1, 2) = get(handles.BA_sky_bar,'Value');
handles.per_value(1, 4) = get(handles.BA_sea_bar,'Value');
handles.per_value(1, 3) = get(handles.BA_sand_bar,'Value');
 
axes(handles.ColorBar_sky);
imshow(imread('dataset/ColorSlider_sky.png'));
axes(handles.ColorBar_sea);
imshow(imread('dataset/ColorSlider_sea.png'));
axes(handles.ColorBar_sand);
imshow(imread('dataset/ColorSlider_sand.png'));

handles.CT_labelEnable = zeros(4, 1);
handles.CT_Ref = ones(4, 1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AttrBased_ImageEditing wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = AttrBased_ImageEditing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning RESULT args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line RESULT from handles structure
varargout{1} = handles.RESULT;



% --- Executes on button press in OpenImage.
function OpenImage_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.jpg'}, 'Open Image');
if isequal(filename,0)
    %msgbox('image not selected', 'File Open Error', 'error');
    return;
end

str = [pathname filename];
handles.im_ori = imread(str);

axes(handles.INPUT);
imshow(handles.im_ori);

set(handles.InfoText,'string', 'executing image segmentation');
drawnow;

% scene segmentation by FCN
[scores, maxlabel] = image_segmentation(handles.im_ori, 1);

% OPTIONAL: alignment
% scores(end+1, :, :) = scores(end, :, :);
% scores(end+1, :, :) = scores(end, :, :);
% scores(1:2, :, :) = [];
% maxlabel(end+1, :) = maxlabel(end, :);
% maxlabel(end+1, :) = maxlabel(end, :);
% maxlabel(1:2, :) = [];

% calculate the percentage of each label from the input image
per_init = percentage_cal(maxlabel);


set(handles.BA_sky_bar, 'Value', per_init(2));
set(handles.BA_sea_bar, 'Value', per_init(4));
set(handles.BA_sand_bar, 'Value', per_init(3));
set(handles.display_per_sky,'string', sprintf('%0.2f', per_init(2)));
set(handles.display_per_sea,'string', sprintf('%0.2f', per_init(4)));
set(handles.display_per_sand,'string', sprintf('%0.2f', per_init(3)));

handles.scores = scores;
handles.maxlabel = maxlabel;
handles.result = maxlabel;
handles.per_init = per_init;
handles.per_cur = handles.per_init;
handles.per_final = handles.per_init;
handles.im = handles.im_ori;

% backup for reset execution
handles.scores_ori = scores;
handles.maxlabel_ori = maxlabel;


axes(handles.LABEL);
imagesc(maxlabel); axis off;
set(handles.InfoText,'string', 'done');

guidata(hObject, handles);

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.im = handles.im_ori;
handles.scores = handles.scores_ori;
handles.maxlabel = handles.maxlabel_ori;
handles.per_cur = handles.per_init;
handles.per_final = handles.per_init;

axes(handles.INPUT);
imshow(handles.im);
axes(handles.LABEL);
imagesc(handles.maxlabel); axis off;
axes(handles.RESULT);
imagesc(ones(200, 200, 3)*255); axis off;

set(handles.BA_sky_bar, 'Value', handles.per_init(2));
set(handles.BA_sea_bar, 'Value', handles.per_init(4));
set(handles.BA_sand_bar, 'Value', handles.per_init(3));
set(handles.display_per_sky,'string', sprintf('%0.2f', handles.per_init(2)));
set(handles.display_per_sea,'string', sprintf('%0.2f', handles.per_init(4)));
set(handles.display_per_sand,'string', sprintf('%0.2f', handles.per_init(3)));

set(handles.CT_sky_enable,'Value',0);
set(handles.CT_sea_enable,'Value',0);
set(handles.CT_sand_enable,'Value',0);

handles.CT_labelEnable = zeros(4, 1);
guidata(hObject, handles);

% --- Executes on slider movement.
function BA_sky_bar_Callback(hObject, eventdata, handles)
% hObject    handle to BA_sky_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
newVal = get(hObject,'Value');
set(hObject,'Value',newVal);

if newVal ~= handles.per_value(1, 2)
    
    % save the new value
    handles.per_value(1, 2) = newVal;
    guidata(hObject,handles);
    % display the current value of the slider
    set(handles.display_per_sky,'string', sprintf('%0.2f', get(hObject,'Value')));
    
    set(handles.InfoText,'string', 'executing boundary adjustment');
    drawnow;
    
    LABEL = 2;
    handles.per_final(LABEL) = handles.per_value(1, 2);
    
    for i = 2:4
        if i ~= LABEL
            handles.per_final(i) = ...
                handles.per_cur(i) * ((1-handles.per_init(1))-handles.per_final(LABEL))/(1-handles.per_cur(LABEL));
        end
    end
    
    set(handles.BA_sky_bar, 'Value', handles.per_final(2));
    set(handles.BA_sea_bar, 'Value', handles.per_final(4));
    set(handles.BA_sand_bar, 'Value', handles.per_final(3));
    set(handles.display_per_sky,'string', sprintf('%0.2f', handles.per_final(2)));
    set(handles.display_per_sea,'string', sprintf('%0.2f', handles.per_final(4)));
    set(handles.display_per_sand,'string', sprintf('%0.2f', handles.per_final(3)));
    
    set(handles.InfoText,'string', 'done');
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function BA_sky_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BA_sky_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function BA_sea_bar_Callback(hObject, eventdata, handles)
% hObject    handle to BA_sea_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
newVal = get(hObject,'Value');
set(hObject,'Value',newVal);

if newVal ~= handles.per_value(1, 4)
    
    % save the new value
    handles.per_value(1, 4) = newVal;
    guidata(hObject,handles);
    % display the current value of the slider
    set(handles.display_per_sea,'string', sprintf('%0.2f', get(hObject,'Value')));
    
    set(handles.InfoText,'string', 'executing boundary adjustment');
    drawnow;
    
    LABEL = 4;
    handles.per_final(LABEL) = handles.per_value(1, 4);
    
    for i = 2:4
        if i ~= LABEL
            handles.per_final(i) = ...
                handles.per_cur(i) * ((1-handles.per_init(1))-handles.per_final(LABEL))/(1-handles.per_cur(LABEL));
        end
    end
    
    set(handles.BA_sky_bar, 'Value', handles.per_final(2));
    set(handles.BA_sea_bar, 'Value', handles.per_final(4));
    set(handles.BA_sand_bar, 'Value', handles.per_final(3));
    set(handles.display_per_sky,'string', sprintf('%0.2f', handles.per_final(2)));
    set(handles.display_per_sea,'string', sprintf('%0.2f', handles.per_final(4)));
    set(handles.display_per_sand,'string', sprintf('%0.2f', handles.per_final(3)));
    
    set(handles.InfoText,'string', 'done');
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function BA_sea_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BA_sea_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function BA_sand_bar_Callback(hObject, eventdata, handles)
% hObject    handle to BA_sand_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
newVal = get(hObject,'Value');
set(hObject,'Value',newVal);

if newVal ~= handles.per_value(1, 3)
    
    % save the new value
    handles.per_value(1, 3) = newVal;
    guidata(hObject,handles);
    % display the current value of the slider
    set(handles.display_per_sand,'string', sprintf('%0.2f', get(hObject,'Value')));
    
    set(handles.InfoText,'string', 'executing boundary adjustment');
    drawnow;
    
    LABEL = 3;
    handles.per_final(LABEL) = handles.per_value(1, 3);
    
    for i = 2:4
        if i ~= LABEL
            handles.per_final(i) = ...
                handles.per_cur(i) * ((1-handles.per_init(1))-handles.per_final(LABEL))/(1-handles.per_cur(LABEL));
        end
    end
    
    set(handles.BA_sky_bar, 'Value', handles.per_final(2));
    set(handles.BA_sea_bar, 'Value', handles.per_final(4));
    set(handles.BA_sand_bar, 'Value', handles.per_final(3));
    set(handles.display_per_sky,'string', sprintf('%0.2f', handles.per_final(2)));
    set(handles.display_per_sea,'string', sprintf('%0.2f', handles.per_final(4)));
    set(handles.display_per_sand,'string', sprintf('%0.2f', handles.per_final(3)));
    
    set(handles.InfoText,'string', 'done');
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function BA_sand_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BA_sand_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in SeamCarving.
function SeamCarving_Callback(hObject, eventdata, handles)
% hObject    handle to SeamCarving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.InfoText,'string', 'executing seam carving');
drawnow;

maxlabel = imresize(handles.maxlabel, [size(handles.im_ori, 1), size(handles.im_ori, 2)]);
maxlabel(:) = round(maxlabel(:));

%handles.per_final = handles.per_cur; % record the desire percentange
[final_result, maxlabel_result] = seamcarving(handles.im, maxlabel, handles.per_init, handles.per_final);

axes(handles.RESULT);
imshow(final_result);
axes(handles.LABEL);
imagesc(maxlabel_result); axis off;

handles.im = final_result; 
handles.maxlabel = maxlabel_result;

set(handles.InfoText,'string', 'done');
guidata(hObject, handles);


% --- Executes on slider movement.
function CT_sky_bar_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sky_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.CT_Ref(2) = round(113*get(hObject,'Value'));
if handles.CT_Ref(2) == 0
    handles.CT_Ref(2) = 1;
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function CT_sky_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CT_sky_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function CT_sea_bar_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sea_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.CT_Ref(4) = round(114*get(hObject,'Value'));
if handles.CT_Ref(4) == 0
    handles.CT_Ref(4) = 1;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CT_sea_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CT_sea_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function CT_sand_bar_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sand_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
handles.CT_Ref(3) = round(109*get(hObject,'Value'));
if handles.CT_Ref(3) == 0
    handles.CT_Ref(3) = 1;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CT_sand_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CT_sand_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in CT_sky_enable.
function CT_sky_enable_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sky_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CT_labelEnable(2) = get(hObject, 'value');
guidata(hObject, handles);


% --- Executes on button press in CT_sea_enable.
function CT_sea_enable_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sea_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CT_labelEnable(4) = get(hObject, 'value');
guidata(hObject, handles);


% --- Executes on button press in CT_sand_enable.
function CT_sand_enable_Callback(hObject, eventdata, handles)
% hObject    handle to CT_sand_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CT_labelEnable(3) = get(hObject, 'value');
guidata(hObject, handles);


% --- Executes on button press in ColorTransfer.
function ColorTransfer_Callback(hObject, eventdata, handles)
% hObject    handle to ColorTransfer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LabelSelected = any(handles.CT_labelEnable); % check if any labels are selected

if LabelSelected
    set(handles.InfoText,'string', 'executing color transfer');
    drawnow;
    
    maxlabel = imresize(handles.maxlabel, [size(handles.im, 1), size(handles.im, 2)]);
    maxlabel(:) = round(maxlabel(:));
    
    axes(handles.RESULT);
    result_CT = color_transfer(handles.im, maxlabel, handles.CT_Ref, handles.CT_labelEnable);
    imshow(result_CT);
    
    handles.im = result_CT;
    set(handles.InfoText,'string', 'done');
else
    set(handles.InfoText,'string', 'no labels are selected for color transfer, terminated.');
end
guidata(hObject, handles);
