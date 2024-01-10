function varargout = bpod_helper(varargin)
% BPOD_HELPER MATLAB code for bpod_helper.fig
%      BPOD_HELPER, by itself, creates a new BPOD_HELPER or raises the existing
%      singleton*.
%
%      H = BPOD_HELPER returns the handle to a new BPOD_HELPER or the handle to
%      the existing singleton*.
%
%      BPOD_HELPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BPOD_HELPER.M with the given input arguments.
%
%      BPOD_HELPER('Property','Value',...) creates a new BPOD_HELPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bpod_helper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bpod_helper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bpod_helper

% Last Modified by GUIDE v2.5 30-Jun-2019 13:47:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bpod_helper_OpeningFcn, ...
                   'gui_OutputFcn',  @bpod_helper_OutputFcn, ...
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
end

function bpod_helper_OpeningFcn(hObject, eventdata, handles, varargin)
    % make all buttons invisible:
    set([handles.text_1, handles.text_2, handles.text_3, handles.text_4, ...
        handles.text_5, handles.text_6, handles.text_7, handles.text_8, ...
        handles.text_9,  handles.text_10, handles.edit_1, handles.edit_2, handles.edit_3, ...
        handles.edit_4, handles.edit_5, handles.edit_6, handles.edit_7, ...
        handles.edit_8, handles.edit_9, handles.edit_10, handles.popup_1, handles.popup_1, ...
        handles.popup_1, handles.popup_2, handles.popup_3, handles.popup_4, ...
        handles.popup_5, handles.popup_6, handles.popup_7, handles.popup_8, ...
        handles.popup_9, handles.popup_10, handles.add_animals_button, ...
        handles.choose_protocol_text, handles.choose_protocol_popup, ...
        handles.load_existing_button, handles.save_button], 'Visible', 'Off');
    % store data in GUI data S
    gui = Gui;
    gui.data.animals_path = '\\132.64.104.28\citri-lab\shared\Claustrum_team\bpod_results\animals';
    gui.data.protocols_path = 'C:\Users\owner\Documents\Bpod Local\Protocols';     
    gui.data.save_path = '\\132.64.104.28\citri-lab\shared\Claustrum_team\bpod_results\animals'; %temporary saved as animals if nothis else it set

    gui.data.text_list = {'text_1', 'text_2', 'text_3','text_4', 'text_5',...
        'text_6', 'text_7', 'text_8', 'text_9', 'text_10'};
    gui.data.edit_list = {'edit_1', 'edit_2', 'edit_3', 'edit_4', 'edit_5',...
        'edit_6', 'edit_7', 'edit_8', 'edit_9','edit_10'};
    gui.data.popup_list = {'popup_1', 'popup_2', 'popup_3', 'popup_4',...
        'popup_5', 'popup_6', 'popup_7', 'popup_8', 'popup_9', 'popup_10'};
    gui.data.option = [];
    gui.data.protocol_path = 'C:\Users\owner\Documents\Bpod Local\Protocols';
    gui.data.TESTER_RFID = '00782B1799DD';
    handles.gui = gui;
    handles.gui.data.options = [];
    handles.gui.data.is_gui_settings = 0;
    handles.gui.data.choose_settings_path = ...
        '\\132.64.104.28\citri-lab\shared\Claustrum_team\bpod_results';
   
    handles.output = hObject;
    guidata(hObject, handles);

end 

function varargout = bpod_helper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end 


% ======================= callback functions =============================

function create_animals_button_Callback(hObject, eventdata, handles)
    handles.choose_setting_button.Enable = 'off';
    handles.create_settings_button.Enable = 'off';
    handles.run_bpod_button.Enable = 'off';
   
    handles.add_animals_button.Visible = 'On';
    handles.save_button.Visible = 'On';
    handles.gui.data.options = 'animals';
    handles.gui.data.save_path = '\\132.64.104.28\citri-lab\shared\Claustrum_team\bpod_results\animals';
    handles.gui.data.animal_ind = 0;                                       % will be added with add animal button 
    try
        msgbox('Please make sure Bpod consule is not open');
        instrreset;
        handles.gui.data.RFID = serial('COM17');                           % what happen if com 17 belongs to Bpod?
        fopen(handles.gui.data.RFID);
    catch
        %instrreset
        answer = inputdlg('Enter the RFID COM port (example: COM17)');
        handles.gui.data.RFID = serial(answer{1});                         % errors like non com / empty are not treated 
        fopen(handles.gui.data.RFID);
    end 
end

function choose_setting_button_Callback(hObject, eventdata, handles)
   handles.gui.data.options = 'choose';
   handles.create_settings_button.Enable = 'off';
   handles.run_bpod_button.Enable = 'off';
   handles.create_animals_button.Enable = 'off';
   
   handles.choose_protocol_text.Visible = 'On';
   handles.choose_protocol_popup.Visible = 'On';
   protocols_list = dir(handles.gui.data.protocol_path);
   handles.choose_protocol_popup.String = ...
        {protocols_list.name};
   
   handles.choose_animals_text.Visible = 'On';
   handles.choose_animals_popup.Visible = 'On';
   animals_list = dir(handles.gui.data.animals_path);
   handles.choose_animals_popup.String = ...
        {animals_list.name}; 
 end

function create_settings_button_Callback(hObject, eventdata, handles)
    disp('choose')
    handles.gui.data.options = 'settings';
    handles.choose_protocol_text.Visible = 'On';
    handles.choose_protocol_popup.Visible = 'On';
    protocols_list = dir(handles.gui.data.protocol_path);
    handles.choose_protocol_popup.String = ...
        {protocols_list.name};
 end

function run_bpod_button_Callback(hObject, eventdata, handles)
instrreset
    Bpod %('COM , 'UseJAva')
end

function add_animals_button_Callback(hObject, eventdata, handles)

    handles.gui.data.animal_ind = handles.gui.data.animal_ind +1;
    handles.(handles.gui.data.text_list{handles.gui.data.animal_ind}).Visible = ...
                'On';
    handles.(handles.gui.data.edit_list{handles.gui.data.animal_ind}).Visible = ...
                'On';
    drawnow()        
    tag = read_rf(handles.gui.data.RFID);
    
    handles.(handles.gui.data.text_list{handles.gui.data.animal_ind}).String = ...
                tag;
    drawnow()
end 

function save_button_Callback(hObject, eventdata, handles)
 switch handles.gui.data.options 
     case 'animals'
         % create animals table: 
         animals = table();
         animals.tags=zeros(0);
         animals.names=zeros(0);
         for i = 1: handles.gui.data.animal_ind
             tmp.tags = {handles.(handles.gui.data.text_list{i}).String};
             tmp.names = {handles.(handles.gui.data.edit_list{i}).String};
             animals = [animals;struct2table(tmp)];
         end 
         cd('\\132.64.104.28\citri-lab\shared\Claustrum_team\bpod_results\animals');
         uisave('animals');
         
     case  'settings'
         s = struct();
         for j = 1:length(handles.gui.data.settings_params)
             value = str2num(handles.(handles.gui.data.edit_list{j}).String);
             s.(handles.(handles.gui.data.text_list{j}).String) = ...
                value;
         end 
         
         if handles.gui.data.is_gui_settings
             S.GUI = s;
         else
             S = s;
         end 
         cd(handles.gui.data.settings_path);
         uisave('S');
         
     case 'choose'
         tmp = handles.gui.data.animals;
         tmp.settings = cell(height(tmp), 1);
         for i = 1 : height(tmp)
             content = cellstr(handles.(handles.gui.data.popup_list{i}).String);
             chosen_settings = content{handles.(handles.gui.data.popup_list{i}).Value};
             tmp.settings{i} = chosen_settings;
         end 
         tester.names = {'0'};                                                 % allways add the tester with template settings
         tester.tags = {handles. gui.data.TESTER_RFID};
         tester.settings = {'template'};
         tmp = [tmp; struct2table(tester)];
         
         cd(handles.gui.data.choose_settings_path);
         uisave('tmp');
 end 

end

function load_existing_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_existing_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.gui.data.options
    case 'settings'
         [f_name, p_name] = uigetfile('.mat', 'Select a file',...
             handles.gui.data.settings_path);
         pre_s = load(fullfile(p_name, f_name));
         display_settings(pre_s, handles);
         
    case 'choose'
        [f_name, p_name] = uigetfile('.mat', 'Select a file',...
             handles.gui.data.choose_settings_path);
         pre_s = load(fullfile(p_name, f_name));                           % assume a table of settings is loaded
         z = fields(pre_s);
         pre_s = pre_s.(z{1});
         
         for i = 1 : height(pre_s)
             switch class(pre_s.names)
                 case 'cell'
                     handles.(handles.gui.data.text_list{i}).String = pre_s.names{i};
                 case 'double'
                     handles.(handles.gui.data.text_list{i}).String = pre_s.names(i);
             end 
             value = strcmp(handles.gui.data.settings_list , pre_s.settings{i});
             handles.(handles.gui.data.popup_list{i}).Value = find(value);
         end 
         
end
end 

function back_button_Callback(hObject, eventdata, handles)
% delete all texts
% hide all texts
% enable all top buttons

    for i = 1:length(handles.gui.data.text_list)
         handles.(handles.gui.data.text_list{i}).Visible = 'off';
         handles.(handles.gui.data.text_list{i}).String = [];
         handles.(handles.gui.data.edit_list{i}).Visible = 'off';
         handles.(handles.gui.data.edit_list{i}).String = [];
         handles.(handles.gui.data.popup_list{i}).Visible = 'off';
     end
     handles.choose_setting_button.Enable = 'On';
     handles.create_animals_button.Enable = 'On';
     handles.create_settings_button.Enable = 'On';
     handles.run_bpod_button.Enable = 'On';

     handles.add_animals_button.Visible = 'Off';
     handles.choose_protocol_text.Visible = 'Off';
     handles.choose_animals_text.Visible = 'Off';
     handles.load_existing_button.Visible = 'Off';
     handles.choose_protocol_popup.Visible = 'Off';
     handles.choose_animals_popup.Visible = 'Off';
     handles.save_button.Visible = 'Off';
     handles.choose_protocol_popup.Value = 1;
     handles.choose_animals_popup.Value = 1;
 end 

function choose_protocol_popup_Callback(hObject, eventdata, handles)
% when its freate new settings mode it finds the fields of the template settings file and displays them in the static text lins, enabling the edit of an existinf file  
% the first part is relevant both for choosing settings and for creating settings. - extract the list of settings files     
    content = cellstr(handles.choose_protocol_popup.String);
    protocol = content{handles.choose_protocol_popup.Value};
    settings_path_a = [handles.gui.data.protocols_path, '\', ...
        protocol, '\Settings'];
    x = dir(settings_path_a);
    y = {x.name};
    handles.gui.data.first_settings_path = settings_path_a;                % this will not be changed to the sub folder - for animals to settings files. 
    if ismember('template.mat', y)
         handles.gui.data.settings_path = settings_path_a;      
    else
        settings_path_b = [handles.gui.data.protocols_path, '\', ...
        protocol, '\Settings\Settings_files'];
        x = dir(settings_path_b);
        y = {x.name};
        handles.gui.data.settings_path = settings_path_b;
        
    end 
    handles.gui.data.settings_list = y;
    
    switch handles.gui.data.options
        case 'settings'
            template = load (fullfile(handles.gui.data.settings_path,...
                'template.mat'));
            display_settings(template, handles);
                        
        case 'choose'
            for  i = 1:length(handles.gui.data.popup_list)                 % reset options to match the protocol
                handles.(handles.gui.data.popup_list{i}).String = ...
                        handles.gui.data.settings_list; 
                 handles.(handles.gui.data.popup_list{i}).Value = 1;
            end
    end 
    handles.load_existing_button.Visible = 'On';
    handles.save_button.Visible = 'On';
    

end 
function choose_protocol_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function choose_animals_popup_Callback(hObject, eventdata, handles)
    content = cellstr(handles.choose_animals_popup.String);
    animals = content{handles.choose_animals_popup.Value};
    animals = load(fullfile(handles.gui.data.animals_path, animals));
    for  i = 1:length(handles.gui.data.text_list)                          % first delete every other possibility that was displayed before
                handles.(handles.gui.data.text_list{i}).String = [];
                handles.(handles.gui.data.text_list{i}).Visible = 'Off';
                handles.(handles.gui.data.popup_list{i}).Visible = 'Off';
    end
    display_animals(animals, handles);                                     % then dispaly the chosen option
end
function choose_animals_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 

function edit_1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_1 as a double
end 
function edit_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_2_Callback(hObject, eventdata, handles)
end 
function edit_2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_3_Callback(hObject, eventdata, handles)
end 
function edit_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_4_Callback(hObject, eventdata, handles)
end
function edit_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_5_Callback(hObject, eventdata, handles)
end 
function edit_5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function edit_6_Callback(hObject, eventdata, handles)
end
function edit_6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_7_Callback(hObject, eventdata, handles)

end 
function edit_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_8_Callback(hObject, eventdata, handles)
end
function edit_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function edit_9_Callback(hObject, eventdata, handles)
end
function edit_9_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function popup_1_Callback(hObject, eventdata, handles)
% hObject    handle to popup_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_1

end
function popup_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_2_Callback(hObject, eventdata, handles)
% hObject    handle to popup_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_2

end
function popup_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_3_Callback(hObject, eventdata, handles)
% hObject    handle to popup_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_3
end
function popup_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_4_Callback(hObject, eventdata, handles)
% hObject    handle to popup_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_4
end
function popup_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_5_Callback(hObject, eventdata, handles)
% hObject    handle to popup_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_5
end
function popup_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_6_Callback(hObject, eventdata, handles)
% hObject    handle to popup_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_6
end
function popup_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_7_Callback(hObject, eventdata, handles)
% hObject    handle to popup_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_7

end
function popup_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popup_8_Callback(hObject, eventdata, handles)
% hObject    handle to popup_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_8

end
function popup_8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function popup_9_Callback(hObject, eventdata, handles)
% hObject    handle to popup_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_9
end 
function popup_9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function edit_10_Callback(hObject, eventdata, handles)
% hObject    handle to edit_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_10 as text
%        str2double(get(hObject,'String')) returns contents of edit_10 as a double

end 
function edit_10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 
function popup_10_Callback(hObject, eventdata, handles)
% hObject    handle to popup_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_10

end 
function popup_10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end 

% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('debug')

end


% ============== helper funcrions ==================================
function tag = read_rf(RFID)
    for i=1:5
        tag = fscanf(RFID);
        tag = tag(logical(isstrprop(tag,'digit') + isstrprop(tag,'alpha')));   %eliminate white spaces from the RF read
        disp (tag);
        if (length(tag)==12) 
            break
        end 
    end
    confirm_read = questdlg(['tag ' tag, ' was read'], 'RFID read',...
                    'OK', 'Read_again', 'OK');
    switch confirm_read
        case 'OK'
            return
        case 'Read_again'
            tag = read_rf(RFID);
    end 
end

function display_settings(settings, handles)

% inputs : 
% settings  = a variable into which the settings file was loaded
% handles

    z = fields(settings);
    settings = settings.(z{1});
    if isfield(settings, 'GUI')
        settings = settings.GUI;
        handles.gui.data.is_gui_settings = 1;
    end
    settings_params = fields(settings);
    handles.gui.data.settings_params = settings_params; 
    for i = 1:length(settings_params)
        handles.(handles.gui.data.text_list{i}).Visible = 'On';
        handles.(handles.gui.data.text_list{i}).String = ...
            settings_params{i};
        handles.(handles.gui.data.edit_list{i}).Visible = 'On';
        handles.(handles.gui.data.edit_list{i}).String = ...
            settings.(settings_params{i});
    drawnow() 
    end
end 

function display_animals(animals, handles)
% inputs : 
% animals  = animals table (tags, names)
% handles
    z = fields(animals);
   animals = animals.(z{1});
   handles.gui.data.animals = animals;
    for i = 1:height(animals)
        handles.(handles.gui.data.text_list{i}).Visible = 'On';
        handles.(handles.gui.data.text_list{i}).String = ...
            animals.names(i);                                              % what if its a cell?
        handles.(handles.gui.data.popup_list{i}).Visible = 'On';
        drawnow() 
    end
end 



