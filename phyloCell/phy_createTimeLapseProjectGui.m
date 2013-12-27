%create time lapse project from images
function varargout = phy_createTimeLapseProjectGui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phy_createTimeLapseProjectGui_OpeningFcn, ...
                   'gui_OutputFcn',  @phy_createTimeLapseProjectGui_OutputFcn, ...
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


% --- Executes just before phy_createTimeLapseProjectGui is made visible.
function phy_createTimeLapseProjectGui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global tempProject;

tempProject=[];

if numel(tempProject)==0
tempProject.position=1;
tempProject.channel=1;
tempProject.pathList=[];
tempProject.imageList=[];
tempProject.phaseChannel=1;
tempProject.retreat=0;
tempProject.segment=0;
tempProject.path=strcat(pwd,'/');
tempProject.makemovie=0;
tempProject.budsegment=0;
tempProject.budChannel=2;
tempProject.filename='template';

end
updateChannelList(handles,1);

% --- Outputs from this function are returned to the command line.
function varargout = phy_createTimeLapseProjectGui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



function setPosition_Callback(hObject, eventdata, handles)
% hObject    handle to setPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setPosition as text
%        str2double(get(hObject,'String')) returns contents of setPosition as a double
global tempProject;

tempProject.position=str2num(get(hObject,'String'));

tempProject.imageList=[];
tempProject.pathList=[];


updateChannelList(handles,1);

function updateChannelList(handles,currentItem);
global tempProject;

n=1;

for i=1:tempProject.position
    for j=1:tempProject.channel
        str=strcat('Position_',num2str(i),' - Channel_',num2str(j),' - ');
        
        if numel(tempProject.pathList)>=n
            if numel(tempProject.pathList(n))~=0
                if numel(tempProject.pathList(n).data)~=0
                    str=strcat('Position_',num2str(i),' - Channel_',num2str(j),' - ',tempProject.pathList(n).data , cell2mat(tempProject.imageList(n).data(1)));
                    if exist('cmpNImages','var')
                        NImages=numel(tempProject.imageList(n).data);
                        if cmpNImages~=NImages
                            warndlg({str;['have a different number of images:',num2str(NImages),' .Before was ',num2str(cmpNImages)]},'Different number of images');
                        end
                    else
                        cmpNImages=numel(tempProject.imageList(n).data);
                    end
                end
            end
        end
        tab(n)={str};
        
        n=n+1;
    end
end

 set(handles.ListOfImages,'String',tab,'Value',currentItem);
 set(handles.path,'String',[tempProject.path tempProject.filename '-project.mat']);

% --- Executes during object creation, after setting all properties.
function setPosition_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global tempProject;
if isfield(tempProject,'position')
set(hObject,'String',num2str(tempProject.position));
else
  set(hObject,'String','1');  
end


function setChannel_Callback(hObject, eventdata, handles)
% hObject    handle to setChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setChannel as text
%        str2double(get(hObject,'String')) returns contents of setChannel as a double
global tempProject;

tempProject.channel=str2num(get(hObject,'String'));

tempProject.imageList=[];
tempProject.pathList=[];


updateChannelList(handles,1);

% --- Executes during object creation, after setting all properties.
function setChannel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global tempProject;

if isfield(tempProject,'channel')
set(hObject,'String',num2str(tempProject.channel));
else
  set(hObject,'String','1');  
end

% --- Executes on button press in setPath.
function setPath_Callback(hObject, eventdata, handles)
global tempProject;

[baseFilename,basePath] = uiputfile('*.mat','Select the default filename');

if baseFilename==0
    return
end
[pathstr, name, ext, versn] = fileparts(baseFilename) ;

if (baseFilename~=0)
tempProject.path=basePath;
tempProject.filename=name;
end

set(handles.path,'String',[basePath name '-project.mat']);

% --- Executes on selection change in ListOfImages.
function ListOfImages_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function ListOfImages_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setImageListPath.
function setImageListPath_Callback(hObject, eventdata, handles)

global tempProject; 

setappdata(0,'UseNativeSystemDialogs',false);
if isempty(tempProject.pathList)
[FileName,PathName,FilterIndex] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.tiff;*.bmp','All Image Files';'*.*','All Files'},'Select all wanted images at once',[],'MultiSelect','on');
else
    [FileName,PathName,FilterIndex] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.tiff;*.bmp','All Image Files';'*.*','All Files'},'Select all wanted images at once',tempProject.pathList(1).data,'MultiSelect','on');
end

if isa(FileName,'double')
    return; 
end

if ischar(FileName)
    FileName=mat2cell(FileName,1);
end
curpos=get(handles.ListOfImages,'Value');
n=1;
for i=1:tempProject.position
    for j=1:tempProject.channel
        if n==curpos
           ind=i;
           jnd=j;
           break; 
        end
        n=n+1;
    end
end

tempProject.imageList(n).data=FileName;
tempProject.pathList(n).data=PathName;

updateChannelList(handles,curpos);



% --- Executes on button press in generateProject.
function generateProject_Callback(hObject, eventdata, handles)
global tempProject;

phy_createTimeLapseProject(tempProject);


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
global tempProject;
delete(handles.figure1);
tempProject=[];


% --- Executes on button press in resetPath.
function resetPath_Callback(hObject, eventdata, handles)

global tempProject;
tempProject.imageList=[];
tempProject.pathList=[];

updateChannelList(handles,1);








