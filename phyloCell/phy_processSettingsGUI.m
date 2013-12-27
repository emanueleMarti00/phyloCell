function varargout = phy_processSettingsGUI(varargin)
% PHY_PROCESSSETTINGSGUI M-file for phy_processSettingsGUI.fig
%      PHY_PROCESSSETTINGSGUI, by itself, creates a new PHY_PROCESSSETTINGSGUI or raises the existing
%      singleton*.
%
%      H = PHY_PROCESSSETTINGSGUI returns the handle to a new PHY_PROCESSSETTINGSGUI or the handle to
%      the existing singleton*.
%
%      PHY_PROCESSSETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHY_PROCESSSETTINGSGUI.M with the given input arguments.
%
%      PHY_PROCESSSETTINGSGUI('Property','Value',...) creates a new PHY_PROCESSSETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phy_processSettingsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phy_processSettingsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help phy_processSettingsGUI

% Last Modified by GUIDE v2.5 24-Aug-2012 16:44:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phy_processSettingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @phy_processSettingsGUI_OutputFcn, ...
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


% --- Executes just before phy_processSettingsGUI is made visible.
function phy_processSettingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phy_processSettingsGUI (see VARARGIN)

% Choose default command line output for phy_processSettingsGUI
handles.output = hObject;

updateDisplay(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes phy_processSettingsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = phy_processSettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_Features.
function listbox_Features_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Features contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Features
global segmentation
segmentation.processing.selectedFeature=get(hObject,'Value');
updateDisplay(handles)


% --- Executes during object creation, after setting all properties.
function listbox_Features_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_Process.
function listbox_Process_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Process contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Process
global segmentation
val=get(handles.listbox_Features,'Value');
segmentation.processing.selectedProcess(val)=(get(hObject,'Value'));
updateDisplay(handles)

% --- Executes during object creation, after setting all properties.
function listbox_Process_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateDisplay(handles)
global segmentation

%segmentation.processing.parameters{segmentation.processing.selectedFeature,segmentation.processing.selectedProcess(segmentation.processing.selectedFeature)}

set(handles.listbox_Features,'String',segmentation.processing.features,'Value',segmentation.processing.selectedFeature);
set(handles.listbox_Process,'String',segmentation.processing.process,'Value',segmentation.processing.selectedProcess(segmentation.processing.selectedFeature)); 

set(handles.uitable_Parameters,'Data',...
    segmentation.processing.parameters{segmentation.processing.selectedFeature,segmentation.processing.selectedProcess(segmentation.processing.selectedFeature)});




% --- Executes when entered data in editable cell(s) in uitable_Parameters.
function uitable_Parameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_Parameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global segmentation
ind= eventdata.Indices;
segmentation.processing.parameters{segmentation.processing.selectedFeature,segmentation.processing.selectedProcess(segmentation.processing.selectedFeature)}{ind(1),ind(2)}=str2num(eventdata.EditData);