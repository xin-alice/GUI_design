classdef clLPTNDesignerGlobalSettingPanal < handle
    properties
        
        lptn_type_popup
        lptn_mode_popup
        lptn_type_duplicate_add_pb
        lptn_option_pb
        lptn_option_table
        lptn_option_choose_cb
        lptn_apply_pb
        lptn_options
        main_figure
        option_figure
        
        
        lptn_type_text6
        
        lptn_type_axial_et
        lptn_type_stator_et
        lptn_type_rotor_et
        
        lptn_stop_time_et
        lptn_stop_time_pb
        lptn_stop_time_text
        lptn_type_text2
        lptn_type_text3
        lptn_type_text4
        valuegroup = zeros(100,1)
        
        lptn_opt_para_text
        lptn_opt_measurement_text
        lptn_opt_para_openfile_pb
        lptn_opt_measure_openfile_pb
        lptn_opt_para_filename_text
        lptn_opt_measure_filename_text
        lptn_apply_components_pb
    end
    properties
        data
        lptn_type
        lptn_mode
        lptn_duplicate_settings = {};
        lptn_stop_time
    end
    methods
        function obj = clLPTNDesignerGlobalSettingPanal(varargin)
            obj.main_figure = varargin{1};
            obj.data = varargin{2};
            obj.open_globalgui()
        end
        
        function open_globalgui(obj)
            
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.03 0.86 0.25 0.1],...
                'string','LPTN Template:','Fontsize',10);
            obj.lptn_type_text2 = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','visible','off','Position',[0.05 0.76 0.2 0.1],...
                'string','Axial repetition ','Fontsize',9);
            obj.lptn_type_text3 = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','visible','off','Position',[0.28 0.76 0.3 0.1],...
                'string','Stator tangential repetition ','Fontsize',9);
            obj.lptn_type_text4 = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.63 0.76 0.3 0.1],...
                'string','Rotor tangential repetition ','visible','off','Fontsize',9);
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.06 0.25 0.15 0.1],...
                'string','Stop time: ','Fontsize',9);
            
            
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.55 0.74 0.15 0.1],...
                'string','Axial symmetric','Fontsize',9,'Visible','off');
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.65 0.74 0.1 0.1],...
                'string','Radial','Fontsize',9,'Visible','off');
            
            obj.lptn_type_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.28 0.92 0.25 0.05],...
                'value',1,...
                'string',{'MachineLPTN','MachineLPTNDuplicate'},'Fontsize',9,'callback',@obj.lptn_type_popup_callback);
            obj.lptn_type_axial_et = uicontrol('parent',obj.main_figure,'style','edit',...
                'units','normalized','Position',[0.235 0.805 0.035 0.06],'visible','off','callback',@obj.lptn_type_axial_et_callback,'string','1');
            obj.data.lptn_duplicate_settings{1} = 1;
            obj.lptn_type_stator_et = uicontrol('parent',obj.main_figure,'style','edit',...
                'units','normalized','Position',[0.582 0.805 0.035 0.06],'visible','off','callback',@obj.lptn_type_stator_et_callback,'string','1');
            obj.data.lptn_duplicate_settings{2} = 1;
            obj.lptn_type_rotor_et = uicontrol('parent',obj.main_figure,'style','edit',...
                'units','normalized','Position',[0.93 0.805 0.035 0.06],'visible','off','callback',@obj.lptn_type_rotor_callback,'string','1');
            obj.data.lptn_duplicate_settings{3} = 1;
            
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.06 0.7 0.2 0.1],...
                'string','Choose mode:','Fontsize',10);
            uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.056 0.55 0.2 0.1],...
                'string','More options:','Fontsize',10);
            
            modestr = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderMode');
            obj.lptn_mode_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.28 0.75 0.6 0.05],...
                'string',modestr,'Fontsize',9,'callback',@obj.lptn_mode_popup_callback);
            set(obj.lptn_mode_popup,'Value',11);
            
            obj.lptn_option_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.72 0.57 0.12 0.07],...
                'Fontsize',9,'callback',@obj.lptn_option_pb_callback,'string','Choose');
            obj.lptn_option_table = uitable('parent',obj.main_figure,...
                'units','normalized','Position',[0.28 0.36 0.43 0.28],...
                'Data',obj.lptn_options,'ColumnName', '','RowName','','ColumnWidth',{230});
            
            obj.lptn_stop_time_et = uicontrol('parent',obj.main_figure,'style','edit',...
                'units','normalized','Position',[0.28 0.27 0.08 0.08],...
                'Fontsize',10,'callback',@obj.lptn_stop_time_et_callback,'string','100');
            
            obj.lptn_opt_para_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.01 0.17 0.35 0.05],...
                'string','Choose optimized parameter:','Fontsize',10);
            obj.lptn_opt_measurement_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.01 0.1 0.35 0.05],...
                'string','Measurement File:','Fontsize',10);
    obj.lptn_opt_para_openfile_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.75 0.17 0.16 0.055],...
                'Fontsize',9,'callback',@obj.lptn_opt_para_openfile_pb_callback,'string','Open file');
            obj.lptn_opt_measure_openfile_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.75 0.1 0.16 0.055],...
                'Fontsize',9,'callback',@obj.lptn_opt_measure_openfile_pb_callback,'string','Open file');
            
            obj.lptn_opt_para_filename_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.35 0.17 0.385 0.06],...
                'string','','Fontsize',10);
            obj.lptn_opt_measure_filename_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.35 0.1 0.385 0.06],...
                'string','','Fontsize',10);
            
           obj.lptn_apply_components_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.65 0.01 0.3 0.06],...
                'Fontsize',10,'string','Apply settings above');
            
        end
        
           function lptn_opt_para_openfile_pb_callback(obj, ~,~)
            if obj.data.lptn_apply_state== 0
                [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
                if ~isempty(PathName)
                    if PathName==0
                        set(obj.lptn_opt_para_filename_text,'string',obj.data.lptn_opt_para_FileName);
                    else
                        set(obj.lptn_opt_para_filename_text,'string',FileName);
                        obj.data.lptn_opt_para_FileName = FileName;
                        obj.data.lptn_opt_para_PathName = PathName;
                    end
                else
                    set(obj.lptn_opt_para_filename_text,'string',obj.data.lptn_opt_para_FileName);
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
           end
        
            function lptn_opt_measure_openfile_pb_callback(obj, ~,~)
            if obj.data.lptn_apply_state== 0
                [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
                if ~isempty(PathName)
                    if PathName==0
                        set(obj.lptn_opt_measure_filename_text,'string',obj.data.lptn_opt_measure_FileName);
                    else
                        set(obj.lptn_opt_measure_filename_text,'string',FileName);
                        obj.data.lptn_opt_measure_FileName = FileName;
                        obj.data.lptn_opt_measure_PathName = PathName;
                    end
                else
                    set(obj.lptn_opt_measure_filename_text,'string',obj.data.lptn_opt_measure_FileName);
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
            
        end
        
        function lptn_type_popup_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                lptn_type_choose = str{num};
                obj.data.lptn_type = lptn_type_choose;
                
                if num ==2
                    set(obj.lptn_type_text2,'visible','on');
                    set(obj.lptn_type_text3,'visible','on');
                    set(obj.lptn_type_text4,'visible','on');
                    set(obj.lptn_type_axial_et,'visible','on');
                    set(obj.lptn_type_stator_et,'visible','on');
                    set(obj.lptn_type_rotor_et,'visible','on');
                else
                    set(obj.lptn_type_axial_et,'visible','off');
                    set(obj.lptn_type_stator_et,'visible','off');
                    set(obj.lptn_type_rotor_et,'visible','off');
                    set(obj.lptn_type_axial_et,'string','1');
                    set(obj.lptn_type_stator_et,'string','1');
                    set(obj.lptn_type_rotor_et,'string','1');
                    set(obj.lptn_type_text2,'visible','off');
                    set(obj.lptn_type_text3,'visible','off');
                    set(obj.lptn_type_text4,'visible','off');
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                        num = get(eventdata,'Value');
                        str = get(eventdata,'String');
                        lptn_type_choose = str{num};
                        obj.data.lptn_type = lptn_type_choose;
                        
                        if num ==2
                            set(obj.lptn_type_text2,'visible','on');
                            set(obj.lptn_type_text3,'visible','on');
                            set(obj.lptn_type_text4,'visible','on');
                            set(obj.lptn_type_axial_et,'visible','on');
                            set(obj.lptn_type_stator_et,'visible','on');
                            set(obj.lptn_type_rotor_et,'visible','on');
                        else
                            set(obj.lptn_type_axial_et,'visible','off');
                            set(obj.lptn_type_stator_et,'visible','off');
                            set(obj.lptn_type_rotor_et,'visible','off');
                            set(obj.lptn_type_axial_et,'string','1');
                            set(obj.lptn_type_stator_et,'string','1');
                            set(obj.lptn_type_rotor_et,'string','1');
                            set(obj.lptn_type_text2,'visible','off');
                            set(obj.lptn_type_text3,'visible','off');
                            set(obj.lptn_type_text4,'visible','off');
                        end
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_type_popup,'Value',find(ismember(str,obj.data.lptn_type)));
                end
            end
        end
        
        function lptn_type_axial_et_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                
                str=get(eventdata,'String');
                if isempty(str2num(str))
                    set(eventdata,'string','0');
                    warndlg('Input must be numerical');
                elseif mod(str2num(str),2)
                    set(eventdata,'string','0');
                    warndlg('Input must be even numbers(eg.2,4,6...)');
                elseif str2num(str)>6 || str2num(str)<2
                    set(eventdata,'string','0');
                    warndlg('Input can only be 2,4,6');
                else
                    obj.data.lptn_duplicate_settings{1} = str;
                    set(obj.lptn_type_duplicate_add_pb,'visible','on');
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                        
                    case 'No'
                end
            end
            
            
        end
        function lptn_type_stator_et_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                
                str=get(eventdata,'String');
                if isempty(str2num(str))
                    set(eventdata,'string','0');
                    warndlg('Input must be numerical');
                elseif mod(str2num(str),2)
                    set(eventdata,'string','0');
                    warndlg('Input must be even numbers(eg.2,4,6...)');
                elseif str2num(str)>6 || str2num(str)<2
                    set(eventdata,'string','0');
                    warndlg('Input can only be 2,4,6');
                else
                    obj.data.lptn_duplicate_settings{2} = str;
                    set(obj.lptn_type_duplicate_add_pb,'visible','on');
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
            
        end
        
        function lptn_type_rotor_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                
                str=get(eventdata,'String');
                if isempty(str2num(str))
                    set(eventdata,'string','0');
                    warndlg('Input must be numerical');
                elseif mod(str2num(str),2)
                    set(eventdata,'string','0');
                    warndlg('Input must be even numbers(eg.2,4,6...)');
                elseif str2num(str)>6 || str2num(str)<2
                    set(eventdata,'string','0');
                    warndlg('Input can only be 2,4,6');
                else
                    obj.data.lptn_duplicate_settings{3} = str;
                    set(obj.lptn_type_duplicate_add_pb,'visible','on');
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
            
        end
        
        
        function lptn_mode_popup_callback(obj, eventdata, ~)
            if obj.data.lptn_apply_state== 0
                
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                obj.data.lptn_mode =  str{num};
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_mode_popup,'Value',find(ismember(str, obj.data.lptn_mode)));
                end
            end
            
        end
        
        function lptn_option_pb_callback(obj, ~, ~)
            if obj.data.lptn_apply_state== 0
                if isempty(obj.option_figure)|| ~ishandle(obj.option_figure)
                    obj.option_figure = figure('units','pixels',...
                        'position',[200 100 400 600],...
                        'menubar','none',...
                        'name','More options',...
                        'numbertitle','off',...
                        'resize','on');
                    
                    set(obj.option_figure,'CloseRequestFcn',@obj.option_figure_my_closereq);
                    movegui(obj.option_figure,'center');
                    Opt = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption');
                    obj.valuegroup = zeros(100,1);
                    
                    for index = 1: length(obj.data.lptn_options)
                        val = find(ismember(Opt, obj.data.lptn_options{index}));
                        obj.valuegroup(val,1) = 1;
                    end
                    
                    for i = 1:length(Opt)
                        obj.lptn_option_choose_cb(i) = uicontrol('parent',obj.option_figure,'style','checkbox',...
                            'units','normalized','Position',[0.08 0.98-i*0.0356 0.6 0.04],'string',Opt{i},...
                            'Fontsize',8,'Enable','on','value', obj.valuegroup(i,1),'callback',@obj.lptn_option_choose_cb_callback);
                    end
                    
                    uicontrol('parent',obj.option_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.8 0.025 0.1 0.046],...
                        'Fontsize',9,'callback',@obj.lptn_option_confirm_pb_callback,'string','save');
                    
                    uicontrol('parent',obj.option_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.6 0.025 0.15 0.046],...
                        'Fontsize',9,'callback',@obj.lptn_option_clear_pb_callback,'string','clear all');
                elseif ishandle(obj.option_figure)
                    figure(obj.option_figure)
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
            
        end
        
        function option_figure_my_closereq(obj, ~, ~)
            selection = questdlg('Do you want to save your settings?',...
                'Close Request Function',...
                'Save','Do not save','Save');
            switch selection
                case 'Save'
                    set(obj.lptn_option_table,'data',obj.lptn_options');
                    obj.data.lptn_options = obj.lptn_options;
                    delete(gcf)
                case 'Do not save'
                    delete(gcf)
            end
        end
        
        function lptn_option_choose_cb_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                
                Opt = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption');
                num = get(eventdata,'value');
                str = get(eventdata,'String');
                nu = find(ismember(Opt,str));
                switch num
                    case  0
                        if ismember(str,obj.lptn_options) == 1
                            n=find(ismember(obj.lptn_options,cellstr(str)));
                            obj.lptn_options{n} ='';
                            obj.lptn_options = obj.lptn_options(~cellfun(@isempty, obj.lptn_options));
                            obj.valuegroup(nu) = 0;
                        else
                            obj.lptn_options = obj.lptn_options;
                        end
                        
                    case 1
                        if ismember(str,obj.lptn_options) == 0
                            obj.lptn_options{end+1} = str;
                            obj.valuegroup(nu) = 1;
                        else
                            obj.lptn_options = obj.lptn_options;
                        end
                end
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                end
            end
            
        end
        
        
        function lptn_option_confirm_pb_callback(obj,~,~)
            set(obj.lptn_option_table,'data',obj.lptn_options');
            obj.data.lptn_options = obj.lptn_options;
            delete(gcf);
        end
        
        function lptn_option_clear_pb_callback(obj,~,~)
            obj.lptn_options = {};
%             set(obj.lptn_option_table,'data',obj.lptn_options');
            Opt = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption');
            index = length(Opt);
            for i = 1:index
                set(obj.lptn_option_choose_cb(i),'value',0);
            end
            obj.valuegroup = zeros(100,1);
        end
        
        function lptn_stop_time_et_callback(obj,eventdata,~)
            if obj.data.lptn_apply_state== 0
                str=get(eventdata,'String');
                if isempty(str2num(str))
                    set(eventdata,'string','0');
                    warndlg('Input must be numerical');
                elseif str2num(str) <0
                    set(eventdata,'string','0');
                    warndlg('Input must be larger then zero');
                else
                    if length(str2num(str))>1
                    set(eventdata,'string','0');
                    warndlg('Input can only be one number.');
                    else
                    obj.data.lptn_stop_time = str2double(str);
                    end
                end
                
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch questiond
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        set(obj.lptn_stop_time_et,'String',num2str(obj.data.lptn_stop_time));
                end
            end
            
        end
        
    end
end
