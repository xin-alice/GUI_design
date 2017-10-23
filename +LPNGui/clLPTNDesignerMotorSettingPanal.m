classdef clLPTNDesignerMotorSettingPanal < handle
    %set stator yoke,rotor, shapeless, stator teeth(for each, extra parameters)
    %set optimized model parameter
    %set measurement obj.data
    %set geometry
    %change something in geometry
    %set boundary
    %change something in boundary, it could be a MotorInputs
    %in MotorInputs, set the input of the MotorInputs, it could also be
    %further MotorInputs(Lookup Table)
    properties
        lptn_opt_para_openfile_pb
        lptn_opt_measure_openfile_pb
        
        lptn_geometry_popup
        lptn_geometry_table
        lptn_boundary_popup
        
        lptn_opt_para_text
        lptn_opt_measurement_text
        lptn_geometry_text
        lptn_boundary_text
        lptn_geometry_setting_pb
        lptn_boundary_setting_pb
        lptn_geometry_value_temperary
        lptn_opt_para_filename_text
        lptn_opt_measure_filename_text
        default_geo_value
        lptn_geometry_value_temporary
        
        
        lptn_stator_tooth_popup
        lptn_stator_yoke_popup
        lptn_rotor_popup
        lptn_shapeless_popup
        lptn_apply_components_pb
        
        lptn_boundary_table_ThermalMaterial
        lptn_boundary_table_AddNewThermalMaterial
        lptn_boundary_table_ThermalContact
        lptn_boundary_table_other
        
        ThermalMaterialProperties
        ThermalContactProperties
        NumSymProperties
        NumSymProperties_value
        %         CellProperties
        OtherProperties
        lptn_st_text
        lptn_sy_text
        lptn_rt_text
        lptn_sl_text
        AddNewMaterial_name_edit
        AddNewMaterialDensity_edit
        AddNewMaterialThermalCapacitivity_edit
        AddNewMaterialVec_thermal_conductivity_edit1
        AddNewMaterialVec_thermal_conductivity_edit2
        AddNewMaterialVec_thermal_conductivity_edit3
        
        main_figure
        geometry_figure
        boundary_figure
        change_res_figure
        AddNewMaterial_figure
        
        lptn_change_res_text
        lptn_res_setting_pb
        lptn_resolution_table
        
        lptn_columnformat1
    end
    
    properties
        data
    end
    
    methods
        function obj = clLPTNDesignerMotorSettingPanal(varargin)
            obj.main_figure = varargin{1};
            obj.data = varargin{2};
            obj.open_motorgui
        end
        
        function open_motorgui(obj)
            %             obj.lptn_opt_para_text = uicontrol('parent',obj.main_figure,'style','text',...
            %                 'units','normalized','Position',[0.023 0.9 0.35 0.05],...
            %                 'string','Choose optimized parameter:','Fontsize',10);
            %             obj.lptn_opt_measurement_text = uicontrol('parent',obj.main_figure,'style','text',...
            %                 'units','normalized','Position',[0.0235 0.83 0.25 0.05],...
            %                 'string','Measurement File:','Fontsize',10);
            obj.lptn_geometry_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.03 0.85 0.15 0.1],...
                'string','Geometry:','Fontsize',10);
            obj.lptn_boundary_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.03 0.73 0.15 0.1],...
                'string','Boundary:','Fontsize',10);
            
            %             obj.lptn_opt_para_openfile_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
            %                 'units','normalized','Position',[0.75 0.9 0.16 0.046],...
            %                 'Fontsize',9,'callback',@obj.lptn_opt_para_openfile_pb_callback,'string','Open file');
            %             obj.lptn_opt_measure_openfile_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
            %                 'units','normalized','Position',[0.75 0.83 0.16 0.046],...
            %                 'Fontsize',9,'callback',@obj.lptn_opt_measure_openfile_pb_callback,'string','Open file');
            %
            %             obj.lptn_opt_para_filename_text = uicontrol('parent',obj.main_figure,'style','text',...
            %                 'units','normalized','Position',[0.35 0.9 0.385 0.06],...
            %                 'string','','Fontsize',10);
            %             obj.lptn_opt_measure_filename_text = uicontrol('parent',obj.main_figure,'style','text',...
            %                 'units','normalized','Position',[0.35 0.82 0.385 0.06],...
            %                 'string','','Fontsize',10);
            
            Gmt = LPNGui.clDesignerGUI.ListMFilesFromFolder('Geometry');
            Bdy = LPNGui.clDesignerGUI.ListMFilesFromFolder('LPTNBoundary');
            obj.lptn_geometry_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.2 0.9 0.3 0.05],...
                'string',Gmt,'value',4,'Fontsize',9,'callback',@obj.lptn_geometry_popup_callback);
            obj.lptn_boundary_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.2 0.78 0.3 0.05],...
                'value',4,...
                'string',Bdy,'Fontsize',9,'callback',@obj.lptn_boundary_popup_callback);
            
            obj.lptn_geometry_setting_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.55 0.88 0.13 0.07],...
                'Fontsize',9,'callback',@obj.lptn_geometry_setting_pb_callback,'string','Settings');
            obj.lptn_boundary_setting_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.55 0.74 0.13 0.07],...
                'Fontsize',9,'callback',@obj.lptn_boundary_setting_pb_callback,'string','Settings');
            
            obj.lptn_st_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.013 0.63 0.2 0.06],...
                'string','Stator tooth:','Fontsize',10);
            
            st = LPNGui.clDesignerGUI.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.ptf);
            stl = length(st);
            for index = 1:stl
                attribute = eval(['?EMotorComponent.Stator.Inside.',st{index}]);
                if attribute.Abstract
                    st{index} = '';
                end
            end
            st = st(~cellfun(@isempty, st));
            
            obj.lptn_stator_tooth_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.25 0.63 0.65 0.05],...
                'value',5,...
                'string',st,'Fontsize',9,'callback',@obj.lptn_stator_tooth_popup_callback);
            
            obj.lptn_sy_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.013 0.48 0.2 0.06],...
                'string','Stator yoke:','Fontsize',10);
            
            sy = LPNGui.clDesignerGUI.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.ptf);
            syl = length(sy);
            for index = 1:syl
                attribute = eval(['?EMotorComponent.Stator.Outside.',sy{index}]);
                if attribute.Abstract
                    sy{index} = '';
                end
            end
            sy = sy(~cellfun(@isempty, sy));
            
            obj.lptn_stator_yoke_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.25 0.48 0.65 0.05],...
                'value',3,...
                'string',sy,'Fontsize',9,'callback',@obj.lptn_stator_yoke_popup_callback);
            
            
            obj.lptn_rt_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.019 0.35 0.13 0.06],...
                'string','Rotor:','Fontsize',10);
            rt = LPNGui.clDesignerGUI.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.ptf);
            rtl = length(rt);
            for index = 1:rtl
                attribute = eval(['?EMotorComponent.Rotor.',rt{index}]);
                if attribute.Abstract
                    rt{index} = '';
                end
            end
            rt = rt(~cellfun(@isempty, rt));
            obj.lptn_rotor_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.25 0.35 0.65 0.05],...
                'value',6,...
                'string',rt,'Fontsize',9,'callback',@obj.lptn_rotor_popup_callback);
            
            
            obj.lptn_sl_text = uicontrol('parent',obj.main_figure,'style','text',...
                'units','normalized','Position',[0.007 0.2 0.2 0.06],...
                'string','Shapeless:','Fontsize',10);
            sl = LPNGui.clDesignerGUI.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.ptf);
            sll = length(sl);
            for index = 1:sll
                attribute = eval(['?EMotorComponent.Shapeless.',sl{index}]);
                if attribute.Abstract
                    sl{index} = '';
                end
            end
            sl = sl(~cellfun(@isempty, sl));
            obj.lptn_shapeless_popup = uicontrol('parent',obj.main_figure,'style','pop',...
                'units','normalized','Position',[0.25 0.2 0.65 0.05],...
                'value',5,...
                'string',sl,'Fontsize',9,'callback',@obj.lptn_shapeless_popup_callback);
            
            
            obj.lptn_apply_components_pb = uicontrol('parent',obj.main_figure,'style','pushbutton',...
                'units','normalized','Position',[0.65 0.05 0.3 0.07],...
                'Fontsize',10,'callback',@obj.lptn_apply_components_pb_callback,'string','Apply settings above');
            
            
            %
            %             obj.NumSymProperties = {};
            %             NumSymProperties_value = {};
            %             Bdy = LPNGui.clDesignerGUI.ListMFilesFromFolder('LPTNBoundary');
            %             lenbdy = length(Bdy);
            %             for index = 1: lenbdy
            %                 lptn_boundary = LPTNBoundary.(Bdy{index});
            %                 cell_boundary = properties(class(lptn_boundary));
            %                 lencellb = length(cell_boundary);
            %                 for index2 = 1:lencellb
            %                     default_value_num{index2} = lptn_boundary.(cell_boundary{index2});
            %                     if isa(lptn_boundary.(cell_boundary{index2}), 'LPNUtilities.clNumSym')
            %                         obj.data.lptn_cell_numsym{1} = lptn_boundary.(cell_boundary{index2});
            %                         %                     obj.obj.NumSymProperties{end+1} = char(cell_boundary(index2));
            %                         %                     obj.NumSymProperties_value{end+1} = num2str(default_value_num{index2}.numeric) ;
            %                     end
            %                 end
            
            
        end
        
        %         function lptn_opt_para_openfile_pb_callback(obj, ~,~)
        %             if obj.data.lptn_apply_state== 0
        %
        %                 [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
        %                 if ~isempty(PathName)
        %                     if PathName==0
        %                         set(obj.lptn_opt_para_filename_text,'string',obj.data.lptn_opt_para_FileName);
        %                     else
        %                         set(obj.lptn_opt_para_filename_text,'string',FileName);
        %                         obj.data.lptn_opt_para_FileName = FileName;
        %                         obj.data.lptn_opt_para_PathName = PathName;
        %                     end
        %                 else
        %                     set(obj.lptn_opt_para_filename_text,'string',obj.data.lptn_opt_para_FileName);
        %                 end
        %             elseif obj.data.lptn_apply_state== 1
        %                 question = questdlg('Are you sure to change the settings?', ...
        %                     'Yes','No');
        %                 switch question
        %                     case 'Yes'
        %                         obj.data.ResetSettings
        %                     case 'No'
        %                 end
        %             end
        %
        %         end
        %
        %         function lptn_opt_measure_openfile_pb_callback(obj, ~,~)
        %             if obj.data.lptn_apply_state== 0
        %                 [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
        %                 if ~isempty(PathName)
        %                     if PathName==0
        %                         set(obj.lptn_opt_measure_filename_text,'string',obj.data.lptn_opt_measure_FileName);
        %                     else
        %                         set(obj.lptn_opt_measure_filename_text,'string',FileName);
        %                         obj.data.lptn_opt_measure_FileName = FileName;
        %                         obj.data.lptn_opt_measure_PathName = PathName;
        %                     end
        %                 else
        %                     set(obj.lptn_opt_measure_filename_text,'string',obj.data.lptn_opt_measure_FileName);
        %                 end
        %             elseif obj.data.lptn_apply_state== 1
        %                 question = questdlg('Are you sure to change the settings?', ...
        %                     'Yes','No');
        %                 switch question
        %                     case 'Yes'
        %                         obj.data.ResetSettings
        %                     case 'No'
        %                 end
        %             end
        %
        %         end
        
        function lptn_apply_components_pb_callback(obj, ~,~)
            obj.data.lptn_apply_state = 1;
            obj.data.ImplementConstructMachine;
            
        end
        
        function lptn_geometry_popup_callback(obj,eventdata,~)
            if obj.data.lptn_apply_state== 0
                num = get(obj.lptn_geometry_popup,'Value');
                Gmt =LPNGui.clDesignerGUI.ListMFilesFromFolder('Geometry');
                obj.data.lptn_geometry = Geometry.(Gmt{num});
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = LPNGui.clDesignerGUI.ListMFilesFromFolder('Geometry');
                        geo = strrep(class(obj.data.lptn_geometry),'Geometry.','');
                        set(obj.lptn_geometry_popup,'Value',find(ismember(str, geo)));
                end
            end
            
        end
        
        function lptn_geometry_setting_pb_callback(obj,~,~)
            if obj.data.lptn_apply_state== 0
                if isempty(obj.geometry_figure)|| ~ishandle(obj.geometry_figure)
                    geo = obj.data.lptn_geometry;
                    cell_pro = properties(geo);
                    len = length(cell_pro);
                    for index = 1:len
                        obj.default_geo_value{index} = double(geo.(cell_pro{index}));
                    end
                    
                    obj.geometry_figure = figure('menubar','none','name','geometry settings','resize','on');
                    movegui(obj.geometry_figure,'center');
                    
                    obj.lptn_geometry_table = uitable('parent',obj.geometry_figure,...
                        'units','normalized',...
                        'Position',[0.1 0.15 0.78 0.75],...
                        'ColumnName', {'property name','value'},...
                        'ColumnFormat', {'char','numeric'},...
                        'RowName','','ColumnWidth',{210},...
                        'Data',[cell_pro,obj.default_geo_value'],...
                        'CellEditCallback',@obj.GeometryTableCellEditCallback);
                    set(obj.lptn_geometry_table,'ColumnEditable',[false true]);
                    uicontrol('parent',obj.geometry_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.6 0.06 0.1 0.065],...
                        'Fontsize',9,'callback',@obj.lptn_geometry_confirm_pb_callback,'string','OK');
                    uicontrol('parent',obj.geometry_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.72 0.06 0.1 0.065],...
                        'Fontsize',9,'callback',@obj.lptn_geometry_cancel_pb_callback,'string','Cancel');
                    uicontrol('parent',obj.geometry_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.84 0.06 0.1 0.065],...
                        'Fontsize',9,'callback',@obj.lptn_geometry_apply_pushbotton_callback,'string','Apply');
                elseif ishandle(obj.geometry_figure)
                    figure(obj.geometry_figure)
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
        
        function GeometryTableCellEditCallback(obj,~,callbackdata)
            index_r = callbackdata.Indices(1);
            obj.lptn_geometry_value_temporary = obj.default_geo_value;
            obj.lptn_geometry_value_temporary{index_r}= str2double(callbackdata.EditData);
        end
        
        function lptn_geometry_apply_pushbotton_callback(obj, ~,~)
            for index = 1: length(obj.lptn_geometry_value_temporary)
                geo = obj.data.lptn_geometry;
                cell_pro = properties(class(geo));
                geo.(cell_pro{index}) = obj.lptn_geometry_value_temporary{index};
            end
        end
        
        function lptn_boundary_popup_callback(obj,eventdata,~)
            if obj.data.lptn_apply_state== 0
                obj.NumSymProperties{end+1} = '';
                obj.NumSymProperties_value = '';
                obj.data.lptn_cell_numsym = {};
                num = get(eventdata,'Value');
                Bdy = LPNGui.clDesignerGUI.ListMFilesFromFolder('LPTNBoundary');
                obj.data.lptn_boundary = LPTNBoundary.(Bdy{num});
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                        obj.NumSymProperties{end+1} = '';
                        obj.NumSymProperties_value = '';
                    case 'No'
                        str = LPNGui.clDesignerGUI.ListMFilesFromFolder('LPTNBoundary');
                        bod = strrep(class(obj.data.lptn_boundary),'LPTNBoundary.','');
                        set(obj.lptn_boundary_popup,'Value',find(ismember(str, bod)));
                end
            end
            
        end
        
        function lptn_boundary_setting_pb_callback(obj,~,~)
            if obj.data.lptn_apply_state== 0
                if isempty(obj.boundary_figure)|| ~ishandle(obj.boundary_figure)
                    obj.boundary_figure = figure('menubar','none','name','boundary settings','resize','on','position',[200 100 1000 600]);
                    movegui(obj.boundary_figure,'center');
                    
                    %                     uicontrol('parent',obj.boundary_figure,'style','pushbutton',...
                    %                         'units','normalized','Position',[0.43 0.03 0.108 0.046],...
                    %                         'Fontsize',9,'callback',@obj.lptn_boundary_update_options_pb_callback,'string','update options');
                    
                    obj.ThermalMaterialProperties={};
                    ThermalMaterialProperties_value={};
                    obj.ThermalContactProperties={};
                    ThermalContactProperties_value1={};
                    ThermalContactProperties_value2={};
                    obj.OtherProperties={};
                    OtherProperties_value={};
                    
                    bd = obj.data.lptn_boundary;
                    cell_pro = properties(class(bd));
                    len = length(cell_pro);
                    popup1 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalMaterial');
                    popup2 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalContact');
                    popup3 = [' ';LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalContact')];
                    for index = 1:len
                        default_value{index} = bd.(cell_pro{index});
                        if isa(bd.(cell_pro{index}), 'LPNEnum.enumThermalMaterial')
                            obj.ThermalMaterialProperties{end+1} = char(cell_pro(index));
                            ThermalMaterialProperties_value{end+1} = char(default_value{index}) ;
                        elseif isa(bd.(cell_pro{index}), 'LPNEnum.enumThermalContact')
                            obj.ThermalContactProperties{end+1} = char(cell_pro{index});
                            ThermalContactProperties_value1{end+1} = char(default_value{index}) ;
                            ThermalContactProperties_value2{end+1} = '';
                        elseif isa(bd.(cell_pro{index}), 'LPNUtilities.clNumSym')
                            obj.data.lptn_cell_numsym{1} = bd.(cell_pro{index});
                            obj.NumSymProperties{1} = char(cell_pro(index));
                            obj.NumSymProperties_value{1} = num2str(default_value{index}.numeric);
                            
                        elseif isa(bd.(cell_pro{index}), 'LPNUtilities.ThermalMaterial')
                            error('tbd');
                        elseif isa(bd.(cell_pro{index}), 'cell')
                            cell_value_comb = default_value{index};
                            obj.ThermalContactProperties{end+1} =char(cell_pro{index});
                            ThermalContactProperties_value1{end+1} = char(cell_value_comb{1});
                            ThermalContactProperties_value2{end+1} = char(cell_value_comb{2});
                        else
                            obj.OtherProperties{end+1} = char(cell_pro{index});
                            OtherProperties_value{end+1} = num2str(default_value{index}) ;
                        end
                        
                    end
                    
                    
                    data_ThermalMaterial = [obj.ThermalMaterialProperties',ThermalMaterialProperties_value'];
                    data_ThermalContact = [obj.ThermalContactProperties',ThermalContactProperties_value1',ThermalContactProperties_value2'];
                    %             data_other = [obj.OtherProperties',OtherProperties_value'];
                    
                    
                    
                    
                    columnformat = {'char',popup1'};
                    columnformat2 = {'char',popup2',popup3'};
                    
                    obj.lptn_boundary_table_ThermalMaterial = uitable('parent',obj.boundary_figure,...
                        'units','normalized','Position',[0.05 0.57 0.29 0.335],...
                        'ColumnFormat', columnformat,...
                        'ColumnEditable',[false true],...
                        'CellEditCallback',@obj.BoundaryTableThermalMaterialCellEditCallback,...
                        'ColumnName', {'Thermal material','option'},'RowName','','ColumnWidth',{120,160},'Data',data_ThermalMaterial);
                    material_table_name = {};
                    for index = 1:length(obj.data.lptn_cell_new_material)
                        material_table_name{end+1} = obj.data.lptn_cell_new_material{index}.name;
                    end
                    
                    
                    obj.lptn_boundary_table_AddNewThermalMaterial = uitable('parent',obj.boundary_figure,...
                        'units','normalized','Position',[0.356 0.57 0.18 0.335],...
                        'ColumnEditable',[false],...
                        'ColumnName', {'New Material'},'RowName','','ColumnWidth',{200},'Data',material_table_name');
                    uicontrol('parent',obj.boundary_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.357 0.57 0.18 0.042],...
                        'Fontsize',9,'callback',@obj.lptn_new_material_pb_callback,'string','Add new thermal material');
                    obj.lptn_boundary_table_ThermalContact = uitable('parent',obj.boundary_figure,...
                        'units','normalized','Position',[0.05 0.1 0.48 0.42],...
                        'ColumnFormat', columnformat2,...
                        'CellEditCallback',@obj.BoundaryTableThermalContactCellEditCallback,...
                        'ColumnEditable',[false true true],...
                        'ColumnName', {'Thermal Contact','option1','option2'},'RowName','','ColumnWidth',{153},'Data',data_ThermalContact);
                    
                    %             obj.lptn_boundary_table_other = uitable('parent',obj.boundary_figure,...
                    %                 'units','normalized','Position',[0.55 0.75 0.35 0.2],...
                    %                 'ColumnFormat', columnformat4,...
                    %                 'ColumnEditable',[false true],...
                    %                 'ColumnName', {'Others','option'},'RowName','','ColumnWidth',{170},'Data',data_other);
                    %
                    uicontrol('parent',obj.boundary_figure,'style','pushbutton',...
                        'units','normalized','Position',[0.9 0.03 0.06 0.046],...
                        'Fontsize',9,'callback',@obj.lptn_boundary_confirm_pb_callback,'string','save');
                    
                    for index = 1:length(obj.data.lptn_cell_numsym)
                        popup1{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
                        popup2{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
                        popup3{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
                    end
                    for index = 1:length(obj.data.lptn_cell_new_material)
                        popup1{end+1} = obj.data.lptn_cell_new_material{index}.name ;
                    end
                    
                    
                    set(obj.lptn_boundary_table_ThermalMaterial,'ColumnFormat',{'char',popup1'});
                    set(obj.lptn_boundary_table_ThermalContact,'ColumnFormat',{'char',popup2',popup3'});
                    obj.data.ShowGlobalNumSym(obj.boundary_figure,[0.6 0.58 0.31 0.35])
                    obj.data.ShowGlobalMotorinput(obj.boundary_figure,[0.6 0.14 0.31 0.35])
                    
                    
                elseif ishandle(obj.boundary_figure)
                    figure(obj.boundary_figure)
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
        
        function lptn_new_material_pb_callback(obj,~,~)
            obj.AddNewMaterial_figure = figure('menubar','none','name','Add New Material','resize','on','position',[200 100 550 350]);
            movegui(obj.AddNewMaterial_figure,'center');
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.06 0.8 0.3 0.1],...
                'style','text',...
                'Fontsize',11,...
                'string','Add New Material:');
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.2 0.65 0.2 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string','Name:');
            obj.AddNewMaterial_name_edit = uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.4 0.68 0.3 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterial_name_edit,...
            
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.1 0.5 0.3 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string','Thermal capacitivity:');
            obj.AddNewMaterialThermalCapacitivity_edit= uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.4 0.55 0.3 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterialDensity,...
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.2 0.35 0.2 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string','Density:');
            obj.AddNewMaterialDensity_edit = uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.4 0.4 0.3 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterialThermalCapacitivity,...
            
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.1 0.2 0.3 0.1],...
                'style','text',...
                'Fontsize',10,...
                'string',' Vec thermal conductivity:');
            obj.AddNewMaterialVec_thermal_conductivity_edit1 = uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.4 0.25 0.085 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterialVec_thermal_conductivity,...
            
            obj.AddNewMaterialVec_thermal_conductivity_edit2 = uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.51 0.25 0.085 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterialVec_thermal_conductivity,...
            
            obj.AddNewMaterialVec_thermal_conductivity_edit3 = uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.615 0.25 0.085 0.07],...
                'style','edit');
            %                 'callback',@obj.CallbackAddNewMaterialVec_thermal_conductivity,...
            
            
            uicontrol('parent',obj.AddNewMaterial_figure,...
                'units','normalized','Position',[0.71 0.12 0.12 0.1],...
                'style','pushbutton',...
                'Fontsize',9,...
                'callback',@obj.CallbackAddNewMaterialsave_button,...
                'string','Save');
            
            
        end
        
        function CallbackAddNewMaterialsave_button(obj,~,~)
            
            name = get(obj.AddNewMaterial_name_edit,'string');
            density = double(get(obj.AddNewMaterialDensity_edit,'string'));
            thermal_capacitivity = double(get(obj.AddNewMaterialThermalCapacitivity_edit,'string'));
            v1 = double(get(obj.AddNewMaterialVec_thermal_conductivity_edit1,'string'));
            v2 = double(get(obj.AddNewMaterialVec_thermal_conductivity_edit2,'string'));
            v3 = double(get(obj.AddNewMaterialVec_thermal_conductivity_edit3,'string'));
            if isempty(name) ||isempty(density)||isempty(v1)||isempty(v2)||isempty(v3)
                warndlg('You have to fill in all blanks.')
                return
            else
                vec_thermal_conductivity = [{v1},{v2},{v3}];
                obj.data.lptn_cell_new_material{end+1} = LPNUtilities.ThermalMaterial(name,thermal_capacitivity,density,vec_thermal_conductivity);
                popup1 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalMaterial');
                for index = 1:length(obj.data.lptn_cell_numsym)
                    popup1{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
                end
                material_table_name = {};
                for index = 1:length(obj.data.lptn_cell_new_material)
                    material_table_name{end+1} = obj.data.lptn_cell_new_material{index}.name;
                    popup1{end+1} = obj.data.lptn_cell_new_material{index}.name ;
                end
                set(obj.lptn_boundary_table_ThermalMaterial,'ColumnFormat',{'char',popup1'});
                set(obj.lptn_boundary_table_AddNewThermalMaterial,'data',material_table_name');
                close(obj.AddNewMaterial_figure);
            end
        end
        
        %         function lptn_boundary_update_options_pb_callback(obj,~,~)
        %             popup1 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalMaterial');
        %             popup2 = LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumThermalContact');
        %             for index = 1:length(obj.data.lptn_cell_numsym)
        %                 popup1{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
        %                 popup2{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
        %             end
        %             set(obj.lptn_boundary_table_ThermalMaterial,'ColumnFormat',{'char',popup1'});
        %             set(obj.lptn_boundary_table_ThermalContact,'ColumnFormat',{'char',popup2',popup2'});
        %
        %         end
        function BoundaryTableThermalMaterialCellEditCallback(obj,~,callbackdata)
            index_r = callbackdata.Indices(1);
            bd = obj.data.lptn_boundary;
            bd.(char(obj.ThermalMaterialProperties(index_r))) = LPNEnum.enumThermalMaterial.(callbackdata.EditData);
        end
        
        function BoundaryTableThermalContactCellEditCallback(obj,~,callbackdata)
            index_r = callbackdata.Indices(1);
            index_c = callbackdata.Indices(2);
            bd = obj.data.lptn_boundary;
            for index = 1:length(obj.data.lptn_cell_numsym)
                obj.NumSymProperties{end+1} = char(obj.data.lptn_cell_numsym{index}.symbolic);
            end
            if isempty(find(ismember(obj.NumSymProperties, callbackdata.EditData), 1))==0
                obj.data.lptn_cell_thermalcontactchosen{end+1} = {char(obj.ThermalContactProperties(index_r)),'',callbackdata.EditData};
                
            elseif isempty(find(ismember(obj.data.lptn_cell_motorinput, callbackdata.EditData), 1))==0
                obj.data.lptn_cell_thermalcontactchosen{end+1} = {char(obj.ThermalContactProperties(index_r)),'',callbackdata.EditData};
            elseif callbackdata.EditData == ' '
            else
                bd.(char(obj.ThermalContactProperties(index_r))) = LPNEnum.enumThermalContact.(callbackdata.EditData);
            end
            
        end
        
        function lptn_stator_tooth_popup_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                obj.data.lptn_stator_tooth = str{num};
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_stator_tooth_popup,'Value',find(ismember(str, obj.data.lptn_stator_tooth)));
                end
            end
            
        end
        
        
        function lptn_stator_yoke_popup_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                obj.data.lptn_stator_yoke = str{num};
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_stator_yoke_popup,'Value',find(ismember(str, obj.data.lptn_stator_yoke)));
                end
            end
            
        end
        
        function lptn_rotor_popup_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                obj.data.lptn_rotor = str{num};
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_rotor_popup,'Value',find(ismember(str, obj.data.lptn_rotor)));
                end
            end
            
        end
        
        function lptn_shapeless_popup_callback(obj, eventdata,~)
            if obj.data.lptn_apply_state== 0
                
                num = get(eventdata,'Value');
                str = get(eventdata,'String');
                obj.data.lptn_shapeless = str{num};
            elseif obj.data.lptn_apply_state== 1
                question = questdlg('Are you sure to change the settings?', ...
                    'Yes','No');
                switch question
                    case 'Yes'
                        obj.data.ResetSettings
                    case 'No'
                        str = get(eventdata,'String');
                        set(obj.lptn_shapeless_popup,'Value',find(ismember(str, obj.data.lptn_shapeless)));
                end
            end
            
        end
        
        function lptn_geometry_confirm_pb_callback(obj, ~,~)
            geometry_data = get(obj.lptn_geometry_table,'data');
            [r,c] = size(geometry_data);
            for index = 1:r
                if ischar(geometry_data{index,2})
                    if  isnan(str2double(geometry_data{index,2}))
                        geometry_data{index,2} =0;
                        warndlg('Input must be numerical');
                    else
                        geometry_data{index,2} = str2double(geometry_data{index,2});
                    end
                end
            end
            for index = 1: length(obj.lptn_geometry_value_temporary)
                geo = obj.data.lptn_geometry;
                cell_pro = properties(class(geo));
                geo.(cell_pro{index}) = obj.lptn_geometry_value_temporary{index};
            end
            close(obj.geometry_figure);
        end
        
        function lptn_geometry_cancel_pb_callback(obj, ~,~)
            close(obj.geometry_figure);
        end
        function lptn_boundary_confirm_pb_callback(obj, ~,~)
            close(obj.boundary_figure);
        end
        
        
        
        %         function lptn_res_setting_pb_callback(obj, ~,~)
        %             if obj.data.lptn_apply_state== 0
        %                 warndlg('The machine has not been constructed yet.');
        %             else
        %                 if isempty(obj.change_res_figure)|| ~ishandle(obj.change_res_figure)
        %                     row = length(obj.data.lptn_components);
        %                     if isempty(obj.data.lptn_single_unit)
        %                         for index = 1:row
        %                             obj.data.lptn_single_unit{index} = false;
        %                             obj.data.lptn_dimension_radial{index} = 1;
        %                             obj.data.lptn_dimension_tangential{index} = 1;
        %                             obj.data.lptn_dimension_axial{index} = 1;
        %                         end
        %                     end
        %
        %                     columnformat = {'char','logical','numeric','numeric','numeric'};
        %                     resolution_table_data=[obj.data.lptn_components,obj.data.lptn_single_unit',obj.data.lptn_dimension_radial',...
        %                         obj.data.lptn_dimension_tangential',obj.data.lptn_dimension_axial'];
        %                     obj.change_res_figure = figure('menubar','none','name','Resolution settings','resize','on',...
        %                         'position',[200 100 800 500]);
        %                     movegui(obj.change_res_figure,'center');
        %
        %                     obj.lptn_resolution_table = uitable('parent',obj.change_res_figure,...
        %                         'units','normalized','Position',[0.1 0.25 0.8 0.6],...
        %                         'ColumnFormat', columnformat,...
        %                         'ColumnEditable',[false true true true true],...
        %                         'CellEditCallback',@obj.ResolutionEditCallback,...
        %                         'ColumnName', {'Components','Is it a single unit?','Dimension radial','Dimension tangential ','Dimension axial'},'RowName','',...
        %                         'ColumnWidth',{183,95,120,120,120},'Data',resolution_table_data);
        %
        %                     uicontrol('parent',obj.change_res_figure,'style','pushbutton',...
        %                         'units','normalized','Position',[0.9 0.05 0.06 0.046],...
        %                         'Fontsize',9,'callback',@obj.apply_resolution_pb_callback,'string','OK');
        %                     set(obj.lptn_resolution_table,'Tag','myTableTag')
        %                 elseif ishandle(obj.change_res_figure)
        %                     figure(obj.change_res_figure)
        %                 end
        %             end
        %         end
        
        %         function ResolutionEditCallback(obj,~,callbackdata)
        %             myfigure=findobj('Tag','myTableTag');
        %             index_r = callbackdata.Indices(1);
        %             index_c = callbackdata.Indices(2);
        %             switch index_c
        %                 case  2
        %                     if callbackdata.EditData== true
        %                         obj.data.lptn_single_unit{index_r} = true;
        %                         obj.data.lptn_dimension_radial{index_r} = 1;
        %                         obj.data.lptn_dimension_tangential{index_r} = 1;
        %                         obj.data.lptn_dimension_axial{index_r} = 1;
        %                     else obj.data.lptn_single_unit{index_r} = 0;
        %                     end
        %                 case  3
        %                     if obj.data.lptn_single_unit{index_r} == true
        %                         obj.data.lptn_dimension_radial{index_r} = 1;
        %                     else
        %                         obj.data.lptn_dimension_radial{index_r} = str2double(callbackdata.EditData);
        %                     end
        %                 case  4
        %                     if obj.data.lptn_single_unit{index_r} == true
        %                         obj.data.lptn_dimension_tangential{index_r} = 1;
        %                     else
        %                         obj.data.lptn_dimension_tangential{index_r} = str2double(callbackdata.EditData);
        %                     end
        %                 case  5
        %                     if obj.data.lptn_single_unit{index_r} == true
        %                         obj.data.lptn_dimension_axial{index_r} = 1;
        %                     else
        %                         obj.data.lptn_dimension_axial{index_r} = str2double(callbackdata.EditData);
        %                     end
        %             end
        %             myTestData = [obj.data.lptn_components,obj.data.lptn_single_unit',obj.data.lptn_dimension_radial',...
        %                 obj.data.lptn_dimension_tangential',obj.data.lptn_dimension_axial'];
        %             set(findobj(myfigure,'Tag','myTableTag'),'Data',myTestData)
        %         end
        %
        %         function apply_resolution_pb_callback(obj, ~,~)
        %             close(obj.change_res_figure);
        %         end
        %
        %
    end
end

