classdef clDesignerGUI < handle
    % clDesignerGUI class for opening and saving a GUI for thermal-model-building
    %   Create an instance of this class and use the function StartDesignerGUI
    %   for starting a GUI. For saving the GUI contents, save the instance.
    %   In this class no uicontrols are used. All the UI-commands are in
    %   class LPNEnum.enumDesignerGUIWindowType.
    
    properties (Access = public)
        fid = false; 
        fname = 'Untitled_Model.m';
        disp_cmd = false; %Debugg-Tool. If set, every command will be displayed before evaluation 
        %%default_values
        default_boundary;
        default_components;
        default_geometry;
        default_measurement_file;
        default_opt_para;
        default_para_mode;
        default_para_option = {{false}};
        default_resolution = {{1},{1},{1}};   
        default_single_unit = {{false}}; 
        default_stop_time;
    end
    methods(Access = public)
        function obj = clDesignerGUI
            obj.StartSavingCommands;
            obj.StartDesignerGUI;
        end
        function StartDesignerGUI(obj)
            % StartDesignerGUI starts the GUI
            %   This function is the central function of this class. The
            %   order and the appearance of the different GUI-windows is
            %   specified in this function.
            
            obj.default_para_mode = LPNEnum.enumDesignerGUIWindowType.popup_dialog.OpenDialog('Parameter',...
                {'Parameter Mode:'},{obj.ListEnumerationMembers('LPNEnum.enumLPNBuilderMode')},obj.default_para_mode);
            obj.default_para_option = LPNEnum.enumDesignerGUIWindowType.table_dialog.OpenDialog('Parameter',...
                obj.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption'),{'Parameter Options:'}, obj.default_para_option);
            obj.ApplyParameter;
            
            obj.default_components = LPNEnum.enumDesignerGUIWindowType.popup_dialog.OpenDialog('Type of components',...
                {'Stator_Tooth: ','Stator_Yoke: ','Rotor: ','Shapeless: '}, ...
                {obj.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.ptf),...
                obj.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.ptf),...
                obj.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.ptf),...
                obj.ListMFilesFromFolder(LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.ptf)}, ...
                obj.default_components);
            obj.ApplyComponents;

            obj.default_opt_para = LPNEnum.enumDesignerGUIWindowType.input_dialog.OpenDialog(...
                'Optimized Parameter',{'Do you want to set optimized paramter? Path to file:'},{},obj.default_opt_para);
            obj.ApplyOptimizedParameter;
            
            obj.default_measurement_file = LPNEnum.enumDesignerGUIWindowType.input_dialog.OpenDialog(...
                'Measurement File',{'Do you want to include a measurement? Path to file:'},{},obj.default_opt_para);
%             [FileName,PathName] = uigetfile('.mat','Choose optimized measurement file.',obj.default_measurement_file);
%             obj.default_measurement_file = [PathName FileName];
            obj.ApplyMeasurementFile;
            
            obj.default_geometry = LPNEnum.enumDesignerGUIWindowType.popup_dialog.OpenDialog('Geometry', ...
                {'Geometry: '}, {obj.ListMFilesFromFolder('Geometry')}, obj.default_geometry);
            obj.default_boundary = LPNEnum.enumDesignerGUIWindowType.popup_dialog.OpenDialog('Boundary', ...
                {'Boundary: '}, {obj.ListMFilesFromFolder('LPTNBoundary')}, obj.default_boundary);
            obj.ApplyBoundaryAndGeometry;
                        
            obj.default_resolution = LPNEnum.enumDesignerGUIWindowType.table_dialog.OpenDialog('Change Resolution',...
                [obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.index}])],...
                {'Dim1','Dim2','Dim3'},obj.default_resolution);
            obj.ApplyResolution;
            
            obj.default_single_unit = LPNEnum.enumDesignerGUIWindowType.table_dialog.OpenDialog('Set Single Unit', ...
                [obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.index}]),...
                obj.ListComponentsFromEMotorComponentClass([LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.ptc obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.index}])],...
                {'Single Unit'}, obj.default_single_unit); 
             obj.ApplySingleUnit;

            obj.default_stop_time = LPNEnum.enumDesignerGUIWindowType.input_dialog.OpenDialog('Stop Time',...
                {'Set Stop Time:'},{}, obj.default_stop_time);
            obj.ApplyStopTime;
            
            if obj.fid
                obj.StopSavingCommands;
            end
        end
        function StartSavingCommands(obj)
            % StartSavingCommands Saving and debug function
            %   Creates an script with all the executed commands. You can
            %   execute the script and get the same thermal model without 
            %   executing the GUI.
            %
            %   See also STOPSAVINGCOMMANDS.
                [FileName,PathName,FilterIndex] = uiputfile(obj.fname,'Choose file name');
                obj.fid = fopen([PathName '\' FileName], 'w');
        end
        function StopSavingCommands(obj)
            % StopSavingCommands Stops the recording of commands.
            %   This function will be called if STARTSAVINGCOMMANDS is be
            %   called before. You don't have to called it yourself.
            %
            %   See also STARTSAVINGCOMMANDS.
            fclose(obj.fid);
            obj.fid = false;
        end
    end
    methods%(Access = private)      
        %%ApplyFunctions (alphabetical)
        function ApplyBoundaryAndGeometry(obj)
            obj.EvaluateCommand(['lptn.ConstructMachine(Geometry.' obj.default_geometry{1} ',LPTNBoundary.' obj.default_boundary{1} ');']);
        end
        function ApplyComponents(obj)
            obj.EvaluateCommand(['lptn.SetObjStatorTooth(EMotorComponent.Stator.Inside.' obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_inside.index} ');']);
            obj.EvaluateCommand(['lptn.SetObjStatorYoke(EMotorComponent.Stator.Outside.' obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_stator_outside.index} ');']);
            obj.EvaluateCommand(['lptn.SetObjRotor(EMotorComponent.Rotor.' obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_rotor.index} ');']);
            obj.EvaluateCommand(['lptn.SetObjShapeless(EMotorComponent.Shapeless.' obj.default_components{LPNEnum.enumDesignerGUIMotorStructure.enum_shapeless.index} ');']);
        end
        function ApplyMeasurementFile(obj)
            if ~isempty(obj.default_measurement_file{1})
                obj.Itrms1Scaled(['lptn.path_measurement_file = ''' obj.default_measurement_file{1} ''';']);
            end
        end
        function ApplyOptimizedParameter(obj)
            if ~isempty(obj.default_opt_para{1})
                obj.EvaluateCommand(['lptn.SetOptimizedModelParameter(''' obj.default_opt_para{1} ''');']);
            end
        end
        function ApplyParameter(obj)
            para = ['LPNEnum.enumLPNBuilderMode.' obj.default_para_mode{1}];
            all_options = obj.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption');
            for i=1:length(obj.default_para_option{1})
                if obj.default_para_option{1}{i}
                    para = [para ',LPNEnum.enumLPNBuilderOption.' all_options{i}];
                end
            end
            obj.EvaluateCommand(['lptn = MotorTemplate.clMachineLPTN(' para ');']);
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
            obj.EvaluateCommand(['lptn.SetStopTime(' num2str(obj.default_stop_time{1}) ');'])
        end
        
        %%Other Functions
        function EvaluateCommand(obj,command)
            if obj.disp_cmd
                disp(command);
            end
            evalin('base',command);
            if obj.fid
                fprintf(obj.fid, [command '\n']);
            end
        end
    end
    methods(Static)
        function cell_components = ListComponentsFromEMotorComponentClass(path_to_class)
            cell_components = {};
            cell_prop = properties(path_to_class);
            for i = 1:length(cell_prop)
                if ~strncmp(cell_prop{i},'contact_',8)
                    cell_components{end+1} = cell_prop{i};
                end
            end
        end
        function cell_enum = ListEnumerationMembers(path_to_class)
            %example: path_to_class = 'LPNEnum.enumLPNBuilderMode'
            en = enumeration(path_to_class);
            cell_enum = cell(length(en),1);
            for index = 1:length(en);
                cell_enum{index} = en(index).char;
            end
        end
        function cell_mfiles = ListMFilesFromFolder(path_to_folder)
            complete_folder_content = what(path_to_folder);
            cell_mfiles = complete_folder_content.m;
            for i = 1:length(cell_mfiles)
                cell_mfiles{i} = cell_mfiles{i}(1:end-2); %deletes '.m' 
            end
        end
    end
end

