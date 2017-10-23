function varargout = GUIGraphTool(varargin)
% GUIGRAPHTOOL MATLAB code for GUIGraphTool.fig
%      GUIGRAPHTOOL, by itself, creates a new GUIGRAPHTOOL or raises the existing
%      singleton*.
%
%      H = GUIGRAPHTOOL returns the handle to a new GUIGRAPHTOOL or the handle to
%      the existing singleton*.
%
%      GUIGRAPHTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGRAPHTOOL.M with the given input arguments.
%
%      GUIGRAPHTOOL('Property','Value',...) creates a new GUIGRAPHTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIGraphTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIGraphTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIGraphTool

% Last Modified by GUIDE v2.5 26-Mar-2015 15:53:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIGraphTool_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIGraphTool_OutputFcn, ...
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


% --- Executes just before GUIGraphTool is made visible.
function GUIGraphTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIGraphTool (see VARARGIN)

% Choose default command line output for GUIGraphTool
handles.output = hObject;

handles.graph_data = struct('model',[],'contact','all','information1','none','information2',[]);

if ~isempty(varargin) 
    if ischar(varargin{1})
        try
            handles.graph_data.model = evalin('base',varargin{1});
            set(handles.class_information_box,'String', class(handles.graph_data.model))
        catch
            warning('No valid input argument!');
        end
    else
        handles.graph_data.model = varargin{1};
        set(handles.class_information_box,'String', class(handles.graph_data.model))
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIGraphTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIGraphTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function name_of_model_Callback(hObject, eventdata, handles)
% hObject    handle to name_of_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name_of_model as text
%        str2double(get(hObject,'String')) returns contents of name_of_model as a double
try
    handles.graph_data.model = evalin('base',get(hObject,'String'));
    set(handles.class_information_box, 'String', class(handles.graph_data.model));
catch
    set(hObject, 'String', 'No valid name. Model has to exist.');
end


% --- Executes during object creation, after setting all properties.
function name_of_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_of_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in update_model.
function update_model_Callback(hObject, eventdata, handles)
% hObject    handle to update_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in contact_selection_box.
function contact_selection_box_Callback(hObject, eventdata, handles)
% hObject    handle to contact_selection_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns contact_selection_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contact_selection_box

keywords = {'all','default'};
content = get(hObject,'Value');

set(handles.name_of_component, 'Visible', 'off','String','name of component');
set(handles.name_of_function, 'Visible', 'off','String','name of function');
switch content
    case {1,2}
        handles.graph_data.contact = keywords{content};
    case 3
        set(handles.name_of_component, 'Visible', 'on');
    case 4
        set(handles.name_of_function, 'Visible', 'on');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function contact_selection_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contact_selection_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function name_of_component_Callback(hObject, eventdata, handles)
% hObject    handle to name_of_component (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name_of_component as text
%        str2double(get(hObject,'String')) returns contents of name_of_component as a double

handles.graph_data.contact = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function name_of_component_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_of_component (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function name_of_function_Callback(hObject, eventdata, handles)
% hObject    handle to name_of_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name_of_function as text
%        str2double(get(hObject,'String')) returns contents of name_of_function as a double
content = get(hObject,'String');
if content(1) ~= '@'
    content = [ '@' content];
end

handles.graph_data.contact = str2func(content);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function name_of_function_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_of_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in contact_information_box.
function contact_information_box_Callback(hObject, eventdata, handles)
% hObject    handle to contact_information_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns contact_information_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contact_information_box
set(handles.time_information, 'Visible', 'off','String', 'time');
set(handles.function_handle_information, 'Visible', 'off', 'String', 'name of function');
keywords = {'none','direction','type','partial','material','heat','hotspot','input_temperature','loss','contact_area','geometry',''};

content = get(hObject,'Value');
handles.graph_data.information1 = keywords{content};
switch content
    case {6,7}
        set(handles.time_information, 'Visible', 'on');    
    case 12
        set(handles.function_handle_information, 'Visible', 'on');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function contact_information_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contact_information_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function time_information_Callback(hObject, eventdata, handles)
% hObject    handle to time_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_information as text
%        str2double(get(hObject,'String')) returns contents of time_information as a double
handles.graph_data.information2 = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function time_information_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function function_handle_information_Callback(hObject, eventdata, handles)
% hObject    handle to function_handle_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of function_handle_information as text
%        str2double(get(hObject,'String')) returns contents of function_handle_information as a double
content = get(hObject,'String');
if content(1) ~= '@'
    content = [ '@(x)x.' content];
end

handles.graph_data.information1 = str2func(content);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function function_handle_information_CreateFcn(hObject, eventdata, handles)
% hObject    handle to function_handle_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_graph.
function show_graph_Callback(hObject, eventdata, handles)
% hObject    handle to show_graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.graph_data.information2)
    ShowGraph(handles.graph_data.model, handles.graph_data.contact, handles.graph_data.information1);
else
    ShowGraph(handles.graph_data.model, handles.graph_data.contact, handles.graph_data.information1, handles.graph_data.information2);
end


% --- Executes on button press in open_graph.
function open_graph_Callback(hObject, eventdata, handles)
% hObject    handle to open_graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.graph_data.information2)
    OpenGraph(handles.graph_data.model, handles.graph_data.contact, handles.graph_data.information1);
else
    OpenGraph(handles.graph_data.model, handles.graph_data.contact, handles.graph_data.information1, handles.graph_data.information2);
end


% --- Executes during object creation, after setting all properties.
function class_information_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to class_information_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
