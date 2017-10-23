classdef clLPTNDesignerinput < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        lptn_MotorSettingPanal
        lptn_DetailSettingPanal
        lptn_allglobalsettings
        lptn_popupglobalnumsym
        
        obj_lptn
        lptn_type = 'MachineLPTN';
        lptn_mode = 'parameter_estimation_geometry_fast_restart';
        lptn_duplicate_settings = {};
        lptn_options = {};
        lptn_stop_time = 100;
        lptn_apply_state = 0;
        
        lptn_opt_para_FileName
        lptn_opt_para_PathName
        lptn_opt_measure_FileName
        lptn_opt_measure_PathName
        
        lptn_geometry = Geometry.I06_Vol13;
        lptn_boundary = LPTNBoundary.clI06Vol13WaterCooled;
        
        lptn_stator_tooth = 'clSRMStatorToothWithClosureClosedEndwindingRegion';
        lptn_stator_yoke = 'clMachineStatorWaterJacketThickFrame';
        lptn_rotor = 'clSRMRotorOpen';
        lptn_shapeless = 'clShapelessWaterJacketClosedEndwindingRegion';
        
        lptn_components
        
        lptn_single_unit = {};
        lptn_dimension_radial = {};
        lptn_dimension_tangential = {};
        lptn_dimension_axial = {};
        lptn_cell_motor_inputs
        
        lptn_cell_new_material = {};
        lptn_cell_numsym = {};
        lptn_cell_motorinput = {};
        lptn_cell_measurement = {};
        
        AddGlobalNumsym_figure
        AddGlobalNumsym_name_edit
        AddGlobalNumsym_value_edit
        
        AddGlobalMotorinput_figure
        AddGlobalMotorinput_table
        Motorinput_table_data
        AddGlobalMotorinput_popup
        
        lptn_table_NumSym = {};
        lptn_table_Motorinput = {};
        lptn_Motorinput_added
        
        lptn_table_Measurement
        AddGlobalMeasurement_figure
        AddGlobalMeasurement_x_axis_popup
        AddGlobalMeasurement_y_axis_popup
        
        
        lptn_cell_thermalcontactchosen
        
        lptn_losses
        lptn_sensors
        
        lptn_components_input_temperature
        lptn_components_output_temperature
        lptn_initial_temperature
        
        default
    end
    methods
        function ImplementConstructMachine(obj)
            %% step 1
            para{1} = LPNEnum.enumLPNBuilderMode.(obj.lptn_mode);
            for i=1:length(obj.lptn_options)
                para{end+1} = LPNEnum.enumLPNBuilderOption.(obj.lptn_options{i});
            end
            obj.obj_lptn = MotorTemplate.(['cl' obj.lptn_type])(para{:});
            if ~isempty(obj.lptn_opt_para_PathName)&&~isnumeric(obj.lptn_opt_para_PathName)
                obj.obj_lptn.SetOptimizedModelParameter([obj.lptn_opt_para_PathName,obj.lptn_opt_para_FileName]);
            end
            if ~isempty(obj.lptn_opt_measure_PathName)&&~isnumeric(obj.lptn_opt_measure_PathName)
                obj.obj_lptn.path_measurement_file = [obj.lptn_opt_measure_PathName obj.lptn_opt_measure_FileName];
            end
            %% step 2
            if strcmp(obj.lptn_type,'MachineLPTN')
                obj.obj_lptn.SetObjStatorTooth(EMotorComponent.Stator.Inside.(obj.lptn_stator_tooth));
                obj.obj_lptn.SetObjStatorYoke(EMotorComponent.Stator.Outside.(obj.lptn_stator_yoke));
                obj.obj_lptn.SetObjRotor(EMotorComponent.Rotor.(obj.lptn_rotor));
                obj.obj_lptn.SetObjShapeless(EMotorComponent.Shapeless.(obj.lptn_shapeless));
            else
                error('to be implemented');
                %                 obj.obj_lptn.SetObjStatorTooth(@EMotorComponent.Stator.Inside.(obj.lptn_stator_tooth));
                %                 obj.obj_lptn.SetObjStatorYoke(@EMotorComponent.Stator.Outside.(obj.lptn_stator_yoke));
                %                 obj.obj_lptn.SetObjRotor(@EMotorComponent.Rotor.(obj.lptn_rotor));
                %                 obj.obj_lptn.SetObjShapeless(EMotorComponent.Shapeless.(obj.lptn_shapeless));
            end
            obj.lptn_components = [obj.obj_lptn.stator_teeth.GetCellComponentsNames,obj.obj_lptn.stator_yoke.GetCellComponentsNames,...
                obj.obj_lptn.rotor.GetCellComponentsNames]';
            obj.obj_lptn.ConstructMachine(obj.lptn_geometry,obj.lptn_boundary);
            for index=1:length(obj.lptn_components)
                obj.lptn_single_unit{index} = false;
                obj.lptn_dimension_radial{index} = 1;
                obj.lptn_dimension_tangential{index} = 1;
                obj.lptn_dimension_axial{index} = 1;
                obj.default{index} = '';
            end
            
            table_data = [obj.lptn_components,obj.lptn_single_unit',obj.lptn_dimension_radial',...
                obj.lptn_dimension_tangential',obj.lptn_dimension_axial',obj.default',obj.default',obj.default',obj.default',...
                obj.default',obj.lptn_single_unit',obj.lptn_single_unit'];
            set(obj.lptn_DetailSettingPanal.lptn_all_components_information_table,'data',table_data);
            obj.lptn_DetailSettingPanal.lptn_all_components_information_table_data = table_data;
            % %             obj.obj_lptn.ShowAllConnection
        end
        
        function ResetSettings(obj)
            obj.lptn_apply_state = 0;
            obj.lptn_components = [];
            obj.lptn_single_unit = {};
            obj.lptn_dimension_radial = [];
            obj.lptn_dimension_tangential = [];
            obj.lptn_dimension_axial = [];
            obj.lptn_losses = [];
            obj.lptn_sensors = [];
            obj.lptn_components_input_temperature = [];
            obj.lptn_components_output_temperature = [];
            obj.lptn_initial_temperature = {};
        end
        
        function ApplyResolution(obj)
            ms_features = {...
                LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.name, LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.ptc, LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.index;...
                LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.name, LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.ptc, LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.index;...
                LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.name, LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.ptc, LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.index;...
                LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.name, LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.ptc, LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.index...
                };
            index = 0;
            for i = 1:4
                components = obj.ListComponentsFromEMotorComponentClass([ms_features{i,2} obj.default_components{ms_features{i,3}}]);
                for j = 1:length(components)
                    for k = 1:3
                        if obj.default_resolution{k}{j+index} > 1
                            obj.EvaluateCommand(['lptn.' ms_features{i,1} '.' components{j} '.SetResolution(' ...
                                num2str(obj.default_resolution{1}{j+index}) ',' num2str(obj.default_resolution{2}{j+index}) ',' ...
                                num2str(obj.default_resolution{3}{j+index}) ');']);
                            break;
                        end
                    end
                end
                index = index + length(components);
            end
        end
        
        function ApplySingleUnit(obj)
        end
        function ApplyStopTime(obj)
            obj.EvaluateCommand(['lptn.SetStopTime(' num2str(obj.lptn_stop_time{1}) ');'])
        end
        
        %%Other Functions
        function EvaluateCommand(obj,command)
            if obj.disp_cmd
                disp(command);
            end
            eval(command);
            if obj.fid
                fprintf(obj.fid, [command '\n']);
            end
        end
        
        
        function AddGlobalNumsym(obj)
            obj.AddGlobalNumsym_figure = figure('menubar','none','name','Add Global Numsym','resize','on','position',[200 100 500 270]);
            movegui(obj.AddGlobalNumsym_figure,'center');
            uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.08 0.74 0.3 0.1],...
                'style','text',...
                'Fontsize',11,...
                'string','Add GlobalNumsym:');
            uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.19 0.55 0.1 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string','Name:');
            obj.AddGlobalNumsym_name_edit = uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.3 0.56 0.35 0.1],...
                'callback',@obj.AddGlobalNumsym_name_text_callback,...
                'style','edit');
            uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.19 0.34 0.1 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string','Value:');
            obj.AddGlobalNumsym_value_edit = uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.3 0.36 0.35 0.1],...
                'callback',@obj.AddGlobalNumsym_value_text_callback,...
                'style','edit');
            
            uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.71 0.18 0.12 0.1],...
                'style','pushbutton',...
                'Fontsize',9,...
                'callback',@obj.AddGlobalNumsym_save_button_callback,...
                'string','Save');
            
            uicontrol('parent',obj.AddGlobalNumsym_figure,...
                'units','normalized','Position',[0.2 0.18 0.4 0.1],...
                'style','text',...
                'Fontsize',8.5,...
                'string','*If you need to add a constant, then type in the value of it in both blanks above.');
        end
        
        
        function AddGlobalNumsym_name_text_callback(obj, eventdata,~)
        end
        
        function AddGlobalNumsym_value_text_callback(obj, eventdata,~)
            str = eventdata.String;
            if isempty(str2num(str))
                set(eventdata,'string','0');
                warndlg('Input must be numerical');
            end
        end
        
        
        function AddGlobalNumsym_save_button_callback(obj, eventdata,~)
            name= get(obj.AddGlobalNumsym_name_edit,'String');
            value= str2double(get(obj.AddGlobalNumsym_value_edit,'String'));
            if  (~isempty(name)) && (~isempty(value))
                obj.lptn_cell_numsym{end+1} =  LPNUtilities.clNumSym(name,value);
                NumSymProperties= {};
                NumSymProperties_value = {};
                len_cellnum = length(obj.lptn_cell_numsym);
                for index = 1: len_cellnum
                    NumSymProperties{index} = char(obj.lptn_cell_numsym{index}.symbolic);
                    NumSymProperties_value{index} = num2str(obj.lptn_cell_numsym{index}.numeric) ;
                end
                data_NumSym = [NumSymProperties',NumSymProperties_value'];
                for index = 1:numel(obj.lptn_table_NumSym)
                    try
                        set(obj.lptn_table_NumSym{index},'Data',data_NumSym);
                    end
                end
            end
            obj.UpdatePopupmenu;
            close(obj.AddGlobalNumsym_figure)
        end
        
        function AddGlobalMotorinput(obj)
            obj.AddGlobalMotorinput_figure = figure('menubar','none','name','Add Global Motorinput','resize','on','position',[200 100 1000 600]);
            movegui(obj.AddGlobalMotorinput_figure,'center');
            
            motorinputs_list = LPNGui.clDesignerGUI.ListMFilesFromFolder('Motorinputs');
            uicontrol('parent',obj.AddGlobalMotorinput_figure,...
                'units','normalized','Position',[0.02 0.8 0.25 0.1],...
                'style','text',...
                'Fontsize',11,...
                'string','Add new motorinput:');
            obj.AddGlobalMotorinput_popup = uicontrol('parent',obj.AddGlobalMotorinput_figure,...
                'units','normalized','Position',[0.25 0.8 0.35 0.1],...
                'style','pop',...
                'Fontsize',10,...
                'string',motorinputs_list,...
                'callback',@obj.AddGlobalMotorinput_popup_callback);
            
            columnformat = {'char','char','char'} ;
            obj.AddGlobalMotorinput_table = uitable('parent',obj.AddGlobalMotorinput_figure,...
                'units','normalized','Position',[0.05 0.15 0.55 0.6],...
                'ColumnFormat', columnformat,...
                'CellEditCallback',@obj.AddGlobalMotorinput_tableEditCallback,...
                'ColumnEditable',[false true true],...
                'CellEditCallback',@obj.AddGlobalMotorinput_tableEditCallback,...
                'ColumnName', {'Properties','Values'},'RowName','',...
                'ColumnWidth',{250,250,20},'Data','');
            
            uicontrol('parent',obj.AddGlobalMotorinput_figure,...
                'units','normalized','Position',[0.86 0.04 0.07 0.055],...
                'style','pushbutton',...
                'Fontsize',9,...
                'callback',@obj.AddGlobalMotorinput_save_button_callback,...
                'string','Save');
            obj.ShowGlobalNumSym(obj.AddGlobalMotorinput_figure,[0.63 0.5 0.31 0.3]);
            obj.ShowMeasurement(obj.AddGlobalMotorinput_figure,[0.63 0.13 0.31 0.3]);
        end
        
        function AddGlobalMotorinput_popup_callback(obj, eventdata,~)
            Motorinput_values = {};
            popup_value = {};
            motorinputs_list = eventdata.String;
            num = eventdata.Value;
            obj.lptn_Motorinput_added= motorinputs_list{num};
            MI = MotorInputs.(obj.lptn_Motorinput_added);
            Motorinput_properties = GetProperties({['MotorInputs.',obj.lptn_Motorinput_added],'public',0});
            lenpro = length(Motorinput_properties);
            for index = 1:lenpro
                pro = Motorinput_properties{index};
                Motorinput_values{end+1} = num2str(MI.(pro).numeric);
                popup_value{end+1} = '';
            end
            obj.UpdatePopupmenu
            obj.Motorinput_table_data = [Motorinput_properties',Motorinput_values', popup_value'];
            set(obj.AddGlobalMotorinput_table,'columnformat',{'char','char',obj.lptn_popupglobalnumsym} );
            set(obj.AddGlobalMotorinput_table,'data',obj.Motorinput_table_data);
            set(obj.AddGlobalMotorinput_table,'CellEditCallback',@obj.AddGlobalMotorinput_tableEditCallback);
        end
        function class_properties = GetProperties(varagin)
            if ~isempty(varagin{1})&&~isempty(varagin{2})&&~isempty(varagin{3})
                classname = ['?',varagin{1}];
                class_info = eval(classname);
                PropertyList = class_info.PropertyList;
                property_attribute = varagin{2};
                classlevel = varagin{3};
                property_list = properties(varagin{1});
                class_properties = {};
                if classlevel==0
                    for index = 1 : length(property_list)
                        if strcmp(PropertyList(index,1).DefiningClass.Name,varagin{1})
                            if strcmp(PropertyList(index).GetAccess,property_attribute)
                                class_properties{end+1} = property_list{index};
                            end
                        end
                    end
                end
            end
        end
        
        
        function AddGlobalMotorinput_tableEditCallback(obj,~,callbackdata)
            index_r = callbackdata.Indices(1);
            index_c = callbackdata.Indices(2);
            if index_c==2
                %                 obj.data.lptn_cell_thermalcontactchosen{end+1} = {char(obj.ThermalContactProperties(index_r)),'',callbackdata.EditData};
            elseif index_c==3
                obj.Motorinput_table_data{index_r,2} = callbackdata.EditData;
                set(obj.AddGlobalMotorinput_table,'data',obj.Motorinput_table_data);
            end
        end
        
        function GlobalMotorinputEditCallback(obj,~,callbackdata)
            index_r = callbackdata.Indices(1);
            MI = MotorInputs.(obj.lptn_Motorinput_added);
            Motorinput_properties = properties(MI);
            pro = Motorinput_properties{index_r};
            MI.(pro).numeric = str2num(callbackdata.EditData);
        end
        
        
        
        function AddGlobalMotorinput_save_button_callback(obj,eventdata,~)
            obj.lptn_cell_motorinput{end+1} = obj.lptn_Motorinput_added;
            data_Motorinput = obj.lptn_cell_motorinput';
            for index = 1:numel(obj.lptn_table_Motorinput)
                try
                    set(obj.lptn_table_Motorinput{index},'Data',data_Motorinput);
                end
            end
            
            close(obj.AddGlobalMotorinput_figure);
            UpdatePopupmenu(obj)
        end
        
        
        function ShowGlobalNumSym(obj,figure,position)
            NumSymProperties= {};
            NumSymProperties_value = {};
            len_cellnum = length(obj.lptn_cell_numsym);
            for index = 1: len_cellnum
                NumSymProperties{index} = char(obj.lptn_cell_numsym{index}.symbolic);
                NumSymProperties_value{index} = num2str(obj.lptn_cell_numsym{index}.numeric);
            end
            data_NumSym = [NumSymProperties',NumSymProperties_value'];
            obj.lptn_table_NumSym{end+1} = uitable('parent',figure,...
                'units','normalized','Position',position,...
                'ColumnFormat',  {'char','char'},...
                'ColumnEditable',[false true],...
                'ColumnName', {'Global NumSym','Values'},'RowName','','ColumnWidth',{154},'Data',data_NumSym);
            uicontrol('parent',figure,'style','pushbutton',...
                'units','normalized','Position',[position(1) position(2)-0.04 0.15 0.042] ,...
                'Fontsize',9,'callback',@obj.lptn_new_numsym_pb_callback,'string','Add new NumSym');
            %             uicontrol('parent',figure,'style','pushbutton',...
            %                 'units','normalized','Position',[0.83 0.61 0.11 0.042],...
            %                 'Fontsize',9,'callback',@obj.lptn_update_numsym_pb_callback,'string','Update NumSym');
        end
        
        function lptn_new_numsym_pb_callback(obj, ~,~)
            obj.AddGlobalNumsym
        end
        
        
        function  ShowGlobalMotorinput(obj,figure,position)
            data_Motorinput = obj.lptn_cell_motorinput';
            obj.lptn_table_Motorinput{end+1} = uitable('parent',figure,...
                'units','normalized','Position',position,...
                'ColumnFormat',  {'char'},...
                'ColumnEditable',[false true],...
                'ColumnName', {'Global Motorinput'},'RowName','','ColumnWidth',{308},'Data',data_Motorinput);
            uicontrol('parent',figure,'style','pushbutton',...
                'units','normalized','Position',[position(1) position(2)-0.04 0.13 0.042],...
                'Fontsize',9,'callback',@obj.lptn_new_motorinput_pb_callback,'string','Add new Motorinput');
        end
        
        function lptn_new_motorinput_pb_callback(obj, ~,~)
            obj.AddGlobalMotorinput
        end
        
        function  ShowMeasurement(obj,figure,position)
            MeasurementXaxis= {};
            MeasurementYaxis = {};
            len_cellmeasure = length(obj.lptn_cell_measurement);
            for index = 1: len_cellmeasure
                MeasurementAdded = obj.lptn_cell_measurement{index};
                MeasurementXaxis{index} = MeasurementAdded{1,1};
                MeasurementYaxis{index} = MeasurementAdded{1,2};
            end
            data_Measurement = [MeasurementXaxis',MeasurementYaxis'];
            
            obj.lptn_table_Measurement{end+1} = uitable('parent',figure,...
                'units','normalized','Position',position,...
                'ColumnFormat',  {'char','char'},...
                'ColumnName', {'Measurement x-axis','Measurement y-axis'},'RowName','','ColumnWidth',{154},...
                'data',data_Measurement);
            uicontrol('parent',figure,'style','pushbutton',...
                'units','normalized','Position',[position(1) position(2)-0.04 0.14 0.042],...
                'Fontsize',9,'callback',@obj.lptn_new_measurement_pb_callback,'string','Add new Measurement');
        end
        function lptn_new_measurement_pb_callback(obj, ~,~)
            obj.AddGlobalMeasurement
        end
        
        
        function AddGlobalMeasurement(obj)
            if isempty(obj.lptn_opt_measure_FileName)
                warndlg('There exists no measurement file.');
            else
                obj.AddGlobalMeasurement_figure = figure('menubar','none','name','Add Global Measurement','resize','on','position',[200 100 600 400]);
                movegui(obj.AddGlobalMeasurement_figure,'center');
                uicontrol('parent',obj.AddGlobalMeasurement_figure,...
                    'units','normalized','Position',[0.15 0.7 0.1 0.1],...
                    'style','text',...
                    'Fontsize',11,...
                    'string','Add X axis:');
                uicontrol('parent',obj.AddGlobalMeasurement_figure,...
                    'units','normalized','Position',[0.15 0.45 0.1 0.1],...
                    'style','text',...
                    'Fontsize',11,...
                    'string','Add Y axis:');
                
                
                Measurement = load (obj.lptn_opt_measure_FileName,'-mat');
                Vector_list = fieldnames(Measurement);
                
                obj.AddGlobalMeasurement_x_axis_popup = uicontrol('parent',obj.AddGlobalMeasurement_figure,...
                    'units','normalized','Position',[0.3 0.7 0.4 0.1],...
                    'style','pop',...
                    'Fontsize',10,...
                    'string',Vector_list,...
                    'value',35);
                
                obj.AddGlobalMeasurement_y_axis_popup = uicontrol('parent',obj.AddGlobalMeasurement_figure,...
                    'units','normalized','Position',[0.3 0.45 0.4 0.1],...
                    'style','pop',...
                    'Fontsize',10,...
                    'string',Vector_list);
                
                uicontrol('parent',obj.AddGlobalMeasurement_figure,...
                    'units','normalized','Position',[0.71 0.2 0.11 0.08],...
                    'style','pushbutton',...
                    'Fontsize',9,...
                    'callback',@obj.AddGlobalMeasurement_save_button_callback,...
                    'string','Save');
            end
        end
        
        function AddGlobalMeasurement_save_button_callback(obj, ~,~)
            x_axis_str = get(obj.AddGlobalMeasurement_x_axis_popup,'string');
            y_axis_str = get(obj.AddGlobalMeasurement_y_axis_popup,'string');
            x_axis_val = get(obj.AddGlobalMeasurement_x_axis_popup,'value');
            y_axis_val = get(obj.AddGlobalMeasurement_y_axis_popup,'value');
            
            Measurement = load (obj.lptn_opt_measure_FileName,'-mat');
            Vector_list = fieldnames(Measurement);
            value_length_x = length(Measurement.(Vector_list{x_axis_val}));
            value_length_y = length(Measurement.(Vector_list{y_axis_val}));
            obj.lptn_cell_measurement {end+1} = {[x_axis_str{x_axis_val},' (',num2str(value_length_x),'x1 )'],[y_axis_str{y_axis_val},' (',num2str(value_length_y),'x1 )']};
            MeasurementXaxis= {};
            MeasurementYaxis = {};
            len_cellmeasure = length(obj.lptn_cell_measurement);
            for index = 1: len_cellmeasure
                MeasurementAdded = obj.lptn_cell_measurement{index};
                MeasurementXaxis{index} = MeasurementAdded{1};
                MeasurementYaxis{index} = MeasurementAdded{2};
            end
            data_Measurement = [MeasurementXaxis',MeasurementYaxis'];
            close(obj.AddGlobalMeasurement_figure)
            for index = 1:numel(obj.lptn_table_Measurement)
                try
                    set(obj.lptn_table_Measurement{index},'Data',data_Measurement);
                end
            end
            UpdatePopupmenu(obj)
        end
        
        function UpdatePopupmenu(obj)
            
            obj.lptn_allglobalsettings = {};
            obj.lptn_popupglobalnumsym = {};
            for index = 1: length(obj.lptn_cell_numsym);
                obj.lptn_allglobalsettings{index} = char(obj.lptn_cell_numsym{index}.symbolic);
            end
            for index = 1: length(obj.lptn_cell_motorinput);
                obj.lptn_allglobalsettings{end+1} = obj.lptn_cell_motorinput{index};
            end
            for index = 1: length(obj.lptn_cell_measurement);
                MeasurementAdded = obj.lptn_cell_measurement{index};
                obj.lptn_allglobalsettings{end+1} = MeasurementAdded{1,2};
            end
            %all global settings with blank
            obj.lptn_allglobalsettings = ['  ',obj.lptn_allglobalsettings];
            %measurement and constant value popup
            MeasurementYaxis = {};
            for index = 1: length(obj.lptn_cell_measurement)
                MeasurementAdded = obj.lptn_cell_measurement{index};
                MeasurementYaxis{index} = MeasurementAdded{1,2};
            end
            data_Measurement = MeasurementYaxis;
            %                 set(obj.AddGlobalMotorinput_table,'ColumnFormat',{'char',data_Measurement});
            
            %numsym popup with blank
            for index = 1:length(obj.lptn_cell_numsym)
                obj.lptn_popupglobalnumsym{end+1} = char(obj.lptn_cell_numsym{index}.symbolic);
            end
            obj.lptn_popupglobalnumsym = ['  ',obj.lptn_popupglobalnumsym]
            
            popup2 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalContact');
            popup3 = [' ';LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalContact')];
            
            for index2 = 1:length(obj.lptn_cell_numsym)
                popup2{end+1} = char(obj.lptn_cell_numsym{index2}.symbolic);
                popup3{end+1} = char(obj.lptn_cell_numsym{index2}.symbolic);
            end
            for index = 1:length(obj.lptn_cell_motorinput)
                if isa(MotorInputs.(obj.lptn_cell_motorinput{index}),'LPNUtilities.clVariableContactFilmCoefficient')==1
                    popup2{end+1} = obj.lptn_cell_motorinput{index};
                    popup3{end+1} = obj.lptn_cell_motorinput{index};
                end
            end
            %boundary thermal contact popup
            for index = 1:numel(obj.lptn_MotorSettingPanal.lptn_boundary_table_ThermalContact)
                try
                    set(obj.lptn_MotorSettingPanal.lptn_boundary_table_ThermalContact,'ColumnFormat',{'char',popup2',popup3'});
                end
            end
            
            %losses entry popup
            for index = 1:numel(obj.lptn_DetailSettingPanal.lptn_ChooseComponents_popup)
                try
                    set(obj.lptn_DetailSettingPanal.lptn_ChooseComponents_popup{index},'string',obj.lptn_allglobalsettings);
                end
            end
            %sensors measurement popup
            for index = 1:numel(obj.lptn_DetailSettingPanal.lptn_sensor_measurement_popup)
                try
                    set(obj.lptn_DetailSettingPanal.lptn_sensor_measurement_popup{index},'string',data_Measurement);
                end
            end
        end
    end
end

