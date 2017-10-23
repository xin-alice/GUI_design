%> @file clLumpedParameterNetwork.m
%> @brief definition of class clLumpedParameterNetwork. Some
%> functions are defined in separate files in the same folder
%> @class clLumpedParameterNetwork
%> all thermal simulation should inherit from this class
classdef clLumpedParameterNetwork < LPNSystem.clLPAbstractSimulinkSystem
    properties(Access = protected)
        %>a cell contain lptn components. see clLPTNComponent
        cell_obj_lptn_component = {};
        %>cell of contact object, that should save the connections
        cell_obj_contacts = {};
        %>other buildable system, the system will be built an the end
        cell_obj_buildable_system = {};
        %>cell of measuring point. Measuring point is a thermal sensor
        %attached to a component.
        cell_obj_measuring_point = {};
        %>cell of measured signal, which could be any output of the system.
        cell_obj_measured_output = {};
    end
    properties(Access = private)
        %>handle of the documentation of the simulation.
        my_docu_handle
        %>name of the simulation folder. All the documentation and results
        %>should be saved in this folder
        str_folder
        %>save the handle of solver, so that the solver can be reachable.
        %>when creating subsystem, all the component should be put into the
        %>subsystem including solver.
        solver_handle
        %>the name of the workspace variable for the simscape log
        str_simscape_log_name = 'SimLog';
        %>if create_docu = 1,then docu will be created.default create docu
        create_docu = 0;
        %>name of the model
        str_model_name
        %>name of the referened model
        str_mdlref_name
        coordinate_system
        %% Buidling Statistic
        %>save the building time-consuming.
        time_build
        %% Parameter runtime
        %>save the simulation output if StartSimulation is called.
        simulation_output
        %>save the simulation time, if StartSimulation function is called.
        time_simulation
        %>time to simulate
        stop_time = 10;
        %% Manage symbolic variable
        %>save thermal numsym parameter, which will be variable in limited
        %>parameter mode
        vec_obj_numsym_non_geometry_parameter = LPNUtilities.clNumSym.empty(1,0);
        %>save struct with optimized parameter. 
        stct_optimized_parameter = [];
        %>cell of object of clNumSym from geometry.
        %>only in complete parameter variation mode needed
        cell_obj_numsym_geometry
        %% for show progress of building subsystem
        number_nodes = 0;
        total_subsystem_number = 0;
        finished_subsystem_number = 0;
    end
    methods
%         function obj = clLumpedParameterNetwork
%             obj@LPNSystem.clLPAbstractSimulinkSystem;
%             obj.SetCurrentLPTN(obj);
%         end
        %% Get-Function
        function stct_parameter = GetOptimizedModelParameter(obj)
            stct_parameter = obj.stct_optimized_parameter;
        end
        %>@brief get component, which is not connected to any other components in one direction
        function cell_open_components = GetOpenComponent(obj,enum_direction)
            cell_components = obj.cell_obj_lptn_component;
            cell_open_components = {};
            for index_component = 1:numel(cell_components)
                if cell_components{index_component}.HaveOpenUnit(enum_direction)
                    cell_open_components{end+1} = cell_components{index_component};
                end
            end
        end
        %>@brief get the model name. This is also the ID of the simulink
        %>environment
        function str_name = GetModelName(obj)
            str_name = obj.str_model_name;
        end
        %>@brief get access of the simscape log data in workspace.
        function simscape_log = GetSimscapeLogData(obj)
            try
                simscape_log = evalin('base',obj.str_simscape_log_name);
                simscape_log = obj.GetMySimscapeNode(simscape_log);
            catch ME
                % 				obj.StartSimulation;
                % 				simscape_log = evalin('base',obj.str_simscape_log_name);
                % 				simscape_log = obj.GetMySimscapeNode(simscape_log);
                warning('there is no simulation result as Simscape_Log available');
                simscape_log = [];
            end
        end
        %>@brief Get Volumn of one component
        %>@param str_component_name this name must be identical as the
        %>simulink block name
        function GetComponentVolumn(obj,str_component_name)
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if strcmp(obj.cell_obj_lptn_component{index_component}.GetComponentName,str_component_name);
                    disp(['Volumn of component ' obj.cell_obj_lptn_component{index_component}.GetComponentName ' is ' ...
                        num2str(obj.cell_obj_lptn_component{index_component}.GetVolume*obj.cell_obj_lptn_component{index_component}.GetTotalRepeatingTimes*1e9) 'mm^3']);
                    disp(['Volumn of component in simulation' obj.cell_obj_lptn_component{index_component}.GetComponentName ' is ' ...
                        num2str(obj.cell_obj_lptn_component{index_component}.GetVolume*1e9) 'mm^3']);
                end
            end
        end
        %>@brief get all measuring point including measured signal(LPNUtilities.clMeasuredSignal)
        function cell_obj_measuring_point = GetCellMeasuringPoint(obj)
            cell_obj_measuring_point = [obj.cell_obj_measuring_point,obj.cell_obj_measured_output];
        end
        %>@brief return the component object with certain name
        %>@param str_name the name of the componet
        function cell_obj_component = GetCellObjComponent(obj,varargin)
            cell_obj_component = {};
            for index = 1:numel(varargin)
                if isnumeric(varargin{index})
                    cell_obj_component{end+1} = obj.cell_obj_lptn_component{varargin{index}};
                elseif ischar(varargin{index})
                    for index_component = 1:length(obj.cell_obj_lptn_component)
                        if strcmp(obj.cell_obj_lptn_component{index_component}.GetComponentName,varargin{index})
                            cell_obj_component{end+1} = obj.cell_obj_lptn_component{index_component};
                            break;
                        end
                    end
                    % 					warning(['Component with the name ' varargin{index} ' doesn''t exist!']);
                elseif isa(varargin{index},'LPNComponent.clLPComponent')
                    cell_obj_component{end+1} = varargin{index};
                elseif isa(varargin{index},'LPNUtilities.clComponentGroup')
                    cell_obj_component = [cell_obj_component varargin{index}.GetCellComponents];
                else
                    error('parameter must be char of numeric')
                end
            end
        end
        %>@brief get the shapeless component in enum_direction of
        %>obj_component
        function [obj_convection_component,enum_contact]= GetShapelessComponentInContactWith(obj,enum_direction,obj_component)
            obj_convection_component = [];
            for index_contact = 1:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{index_contact}.IsPhysicalContact
                    if obj.cell_obj_contacts{index_contact}.IsConvectionContact
                        if obj.cell_obj_contacts{index_contact}.IsComponentContactOn(obj_component,enum_direction)
                            obj_convection_component = obj.cell_obj_contacts{index_contact}.GetTheOtherComponent(obj_component);
                            enum_contact = obj.cell_obj_contacts{index_contact}.GetEnumerationThermalContact;
                        end
                    end
                end
            end
        end
        %>return the number of connections
        function nr_connections = GetNumberOfConnections(obj,cell_obj_component)
            nr_connections = 0;
            %%output contact information
            for index_component = 1:length(cell_obj_component)
                for index = 1:length(obj.cell_obj_contacts)
                    if obj.cell_obj_contacts{index}.IsComponentContactOn(cell_obj_component{index_component})
                        nr_connections = nr_connections + 1;
                    end
                end
            end
        end
        %>return the coordinate system type
        function enum = GetCoordinateSystem(obj)
            enum = obj.coordinate_system;
        end
        %>get all symbolic variable
        function vec_numsym = GetAllSymbolicVariableInVec(obj)
            vec_numsym = obj.GetThermalSymbolicVariable;
            vec_numsym = [vec_numsym obj.GetGeometrySymbolicVariable];
        end
        %>@brief get all symbolics variable of model in cell
        function vec_obj_numsym = GetThermalSymbolicVariable(obj)
%             vec_obj_numsym = LPNUtilities.clNumSym.empty(1,0);
%             for index = 1:numel(obj.vec_obj_numsym_non_geometry_parameter)
%                 vec_obj_numsym(end+1) = obj.vec_obj_numsym_non_geometry_parameter(index);
%             end
             vec_obj_numsym = obj.vec_obj_numsym_non_geometry_parameter;
        end
        %>@brief get all symbolic variable, which represent the geometry of
        %>the component
        function vec_obj_numsym = GetGeometrySymbolicVariable(obj)
            vec_obj_numsym = LPNUtilities.clNumSym.empty(1,0);
            for index = 1:numel(obj.cell_obj_numsym_geometry)
                vec_obj_numsym(index) = obj.cell_obj_numsym_geometry{index};
            end
        end
        %% Set-Function
        function SetOptimizedModelParameter(obj,str_path)
            obj.stct_optimized_parameter = load(str_path);
        end
        %>set the time to simulate
        function SetStopTime(obj,stop_time)
            obj.stop_time = stop_time;
        end
        %>@brief turn on simscape logging, can make the simulation slow
        function SetSimscapeLogging(obj,on)
            if nargin == 1
                on = 1;
            end
            if on
                obj.SetSimulationParameter('SimscapeLogType', 'all');
            else
                obj.SetSimulationParameter('SimscapeLogType', 'none');
            end
        end
        %>@brief set global simulink parameter
        function SetSimulationParameter(obj,varargin)
            set_param(bdroot(obj.GetBlockID),varargin{:});
        end
        function obj_measuring_point = GetMeasuringPoint(obj,name)
            obj_measuring_point = [];
            for index_point = 1:numel(obj.cell_obj_measuring_point)
                if strcmp(obj.cell_obj_measuring_point{index_point}.GetNameMeasuringPoint,name)
                    obj_measuring_point = obj.cell_obj_measuring_point{index_point};
                    return;
                end
            end
            if isempty(obj_measuring_point)
                disp('Available measuring point:');
                for index_point = 1:numel(obj.cell_obj_measuring_point)
                    disp(obj.cell_obj_measuring_point{index_point}.GetNameMeasuringPoint);
                end
                error([name ' is not found']);
            end
        end
        %% Build-Function
        %> add a measuring point
        %> varargin should at least contain a string for the name of the
        %> point, a numeric vector of a cell of string for the measuring
        %> position, a obj_component for the measured component
        %> as option it can contain a numeric or numsym for the contact
        %> resistance to measured component and second numeric or numsym
        %> for the thermal capacitance of the sensor. If a second
        %> obj_component as disturbance component is provided, the third
        %> numeric or numsym should be the contact resistance to the
        %> disturbance component
        %> exp:
        %> AddMeasuringPoint('average_winding');
        %> AddMeasuringPoint('sensor_name',lptn.stator_teeth.stator_teeth,[0.1,0.2,0])
        %>
        %> AddMeasuringPoint('sensor_name',lptn.stator_teeth.stator_teeth,[0.1,0.2,0],0.3,0.4),where
        %> 0.3 is the resistance, 0.4 is the capacitance
        %>
        %> AddMeasuringPoint('sensor_name',lptn.stator_teeth.stator_teeth,[0.1,0.2,0],0.3,0.4,lptn.shapeless.airgap,20),
        %> where 20 is the resistance to the disturbance component.
        function obj_measuring_point = AddMeasuringPoint(obj,varargin)
            for index = 1:numel(varargin)
                current = varargin{index};
                if ischar(current)
                    name = current;
                elseif iscell(current)||length(current)>1
                    vec_measuring_position = current;
                elseif isobject(current)
                    obj_measured_component = current;
                    if ~obj.ComponentIsDefined(obj_measured_component)
                        obj_measuring_point = [];
                        warning(['MeasuringPoint' name ' removed']);
                        return;
                    end
                end
            end
            obj_measuring_point = LPNElement.clMeasuringPoint;
            try
                for index_point = 1:numel(obj.cell_obj_measuring_point)
                    if strcmp(obj.cell_obj_measuring_point{index_point}.GetNameMeasuringPoint,name)
                        obj_measuring_point = obj.cell_obj_measuring_point{index_point};
                        disp([name 'is already defined!']);
                        return;
                    end
                end
                if iscell(vec_measuring_position)%&&~isempty(strfind(vec_position_on_measured_component{1},'%'));
                    vec_measuring_position = obj.RegistSymbolicVariable(LPNUtilities.clNumSym({['measured_pos1_' name],['measured_pos2_' name],['measured_pos3_' name]},mytools.ConvertPercentageToNumber(vec_measuring_position)));
                    vec_measuring_position = obj_measured_component.ConvertPercentageToRelativePosition(vec_measuring_position);
                end
                obj_measuring_point.SetMeasuringPoint(name,obj_measured_component,vec_measuring_position);
            catch ME
                warning(ME.message);
                obj_measuring_point = [];
                return;
            end
            obj.cell_obj_measuring_point{end+1} = obj_measuring_point;
            
        end
        %>@brief add a object of measuring point into the LPTN
        function AddObjMeasuringPoint(obj,obj_measuring_point)
            obj.cell_obj_measuring_point{end+1} = obj_measuring_point;
        end
        %>@brief register a component in simulation environment
        function RegisterComponent(obj,varargin)
            for index = 1:nargin-1
                obj_component = varargin{index};
                for index_component = 1:length(obj.cell_obj_lptn_component)
                    if strcmp(obj.cell_obj_lptn_component{index_component}.GetComponentName,obj_component.GetComponentName);
                        error([obj_component.GetComponentName ' have been defined twice!']);
                    end
                end
                obj.cell_obj_lptn_component{end+1} = obj_component;
                obj_component.CheckComponent;
%                 cell_heat_flux = obj_component.GetHeatFluxInput;
%                 for index_heat = 1:numel(cell_heat_flux)
%                     if isa(cell_heat_flux{index_heat},'LPNUtilities.clInputFunction')
%                         cell_heat_flux{index_heat}.RegisterFunctionProperties(obj);
%                         stct_optimum = obj.GetOptimizedModelParameter;
%                         cell_heat_flux{index_heat}.OverwriteFunctionPropertiesWithOptimizedValues(stct_optimum);
%                     end
%                 end
            end
        end
        %>@brief register a contact
        function RegisterContact(obj,varargin)
            for index = 1:nargin-1
                obj_contact = varargin{index};
                
                if isempty(obj_contact.GetObjComponent(1))
                    error(['Contact ' inputname(index+1) ' is not initialized']);
                end
                if ~obj.ComponentIsDefined(obj_contact.GetObjComponent(1))
                    error([obj_contact.GetObjComponent(1).GetComponentName ' is not registered']);
                end
                if ~obj.ComponentIsDefined(obj_contact.GetObjComponent(2))
                    error([obj_contact.GetObjComponent(2).GetComponentName ' is not registered']);
                end
                if ~obj_contact.IsEmptyContact
                    % 					if isa(obj_contact,'LPNContact.clPhysicalComponentContact')
                    % 						obj.cell_obj_contacts{end+1} = obj_contact;
                    % 					elseif isa(obj_contact,'LPNContact.clThermalRadiationContact') && obj.ConsiderRadiation
                    % 						obj.cell_obj_non_physical_contacts{end+1} = obj_contact;
                    % 					end
                    if isa(obj_contact,'LPNContact.clThermalRadiationContact')
                        if obj.ConsiderRadiation
                            obj.cell_obj_contacts{end+1} = obj_contact;
                        else
                            disp(['Radiation contact ' obj_contact.GetContactName ' ignored. Use LPNEnum.enumLPNBuilderOption.include_radiation to active radiation contact.']);
                        end
                    else
                        obj.cell_obj_contacts{end+1} = obj_contact;
                    end
                end
            end
        end
        %>@brief register a buildable system, which has a Build function,
        %>but does not belong to component or contact
        
        function RegisterBuildableSystem(obj,obj_buildable_system)
            obj.cell_obj_buildable_system{end+1} = obj_buildable_system;
        end
        %>@brief regist a symbolic variable. so that this will be save to
        %>structure in workspace
        function obj_numsym = RegistSymbolicVariable(obj,varargin)
            if numel(varargin) == 1
                obj_numsym = varargin{1};
                assert(isa(obj_numsym,'LPNUtilities.clNumSym'));
            elseif numel(varargin) == 2
                obj_numsym = LPNUtilities.clNumSym(varargin{:});
            else
                error('varargin too long')
            end
            if ~obj.UseSymbolicThermalParameter
                obj_numsym = obj_numsym.numeric;
                if nargout == 0
                    warning('symbolic variable is automatically deactivated, but no return value is detected. This can cause missed workspace parameter. Please use the return value of this function for further assignment');
                end
            else
                stct_optimum = obj.GetOptimizedModelParameter;
                if isfield(stct_optimum,obj_numsym.sym2str)&&~strcmp(obj_numsym.sym2str,'global_initial_temperature')
                    %                     if obj_numsym.numeric ~= stct_optimum.(obj_numsym.sym2str);
                    %                         %                             warning(['numsym ' obj_numsym.sym2str ' is not updated before use. This will cause a bias between numsym and numeric calculation']);
                    obj_numsym.numeric = stct_optimum.(obj_numsym.sym2str);
                    %                     end
                end
                obj.AddThermalNumSymParameter(obj_numsym);
                %                 found = 0;
                %                 for index = 1:numel(obj.vec_obj_numsym_non_geometry_parameter)
                %                     if obj.vec_obj_numsym_non_geometry_parameter(index).symbolic == obj_numsym.symbolic
                %                         found = 1;
                % %                         warning(['numsym ' char(obj_numsym) ' already exist']);
                %                     end
                %                 end
                %                 if found == 0
                %                     obj.AddThermalNumSymParameter(obj_numsym);
                % %                     obj.vec_obj_numsym_non_geometry_parameter = [obj.vec_obj_numsym_non_geometry_parameter obj_numsym];
                %                 end
            end
        end
        %% Show-Function
        %>@brief Show statstic of the model.
        function ShowBuildingStatistic(obj)
            display(['Building Time: ' num2str(obj.time_build) ' seconds']);
            display(['Number Nodes: ' num2str(obj.number_nodes)]);
            cell_resistor = find_system(obj.str_model_name,'ComponentVariantNames','thermal_resistor');
            cell_resistor2 = find_system(obj.str_model_name,'ComponentVariantNames','variable_thermal_resistor');
            cell_capacitor = find_system(obj.str_model_name,'ComponentVariantNames','capacitor');
            cell_capacitor2 = find_system(obj.str_model_name,'ComponentVariantNames','variable_capacitor');
            display(['Number Resistor: ' num2str(numel(cell_resistor))]);
            display(['Number Capacitor: ' num2str(numel(cell_capacitor))]);
            display(['Number Variable Resistor: ' num2str(numel(cell_resistor2))]);
            display(['Number Variable Capacitor: ' num2str(numel(cell_capacitor2))]);
            cell_component = find_system([obj.str_model_name '/' obj.str_model_name],'SearchDepth',1,'BlockType','SubSystem');
            display(['Number Component and Contact: ' num2str(numel(cell_component))]);
        end
        %>@brief show statistic of the simulation
        function ShowSimulationStatistic(obj)
            simlog_variable = obj.GetSimscapeLogData;
            disp(mytools.GetTableLine('[component name]',30,'[number of units]',20,'[maximum gradient]',20,'[maximum difference]',23,'[axis with maximum gradient]',20));
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    obj.cell_obj_lptn_component{index_component}.ShowComponentSimulationStatistic(simlog_variable);
                end
            end
        end
        %>@brief debug function
        function ShowAllDivision(obj)
            disp('The shapeless components are blinded out');
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    obj.cell_obj_lptn_component{index_component}.ShowDivision;
                end
            end
            % 			cellfun(@(x)x.ShowDivision,obj.cell_obj_lptn_component);
        end
        %>@brief debug function
        function ShowAllMeasuringPointsPosition(obj)
            cellfun(@(x)x.ShowMeasuringPointsPosition,obj.cell_obj_lptn_component);
        end
        %>@brief debug function: show connection in enum_direction on
        %>obj_component
        function ShowConnectionInOneDirectionOfComponent(obj,obj_component,enum_direction)
            for index = 1:length(obj.cell_obj_contacts)
                
                if obj.cell_obj_contacts{index}.GetEnumDirection == enum_direction && obj.cell_obj_contacts{index}.GetObjComponent(2) == obj_component
                    obj.cell_obj_contacts{index}.ShowContactInfoInRespectOf(obj_component);
                elseif (obj.cell_obj_contacts{index}.GetEnumDirection.GetOppositeDirection == enum_direction) && (obj.cell_obj_contacts{index}.GetObjComponent(1) == obj_component)
                    obj.cell_obj_contacts{index}.ShowContactInfoInRespectOf(obj_component);
                end
            end
        end
        %>@brief display all contacts of one type
        function ShowAllConnectionOf(obj,enum_contact)
            % 			disp(['Contact type:' enum_contact.char])
            for index_contact = 1:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{index_contact}.HaveEnumerationThermalContact(enum_contact)
                    disp(obj.cell_obj_contacts{index_contact}.GetContactName);
                end
            end
        end
        %>@brief display all contacts between components
        %>or all connections with certain contact enumeration type
        function ShowAllConnection(obj,varargin)
            %%find relative components
            if nargin == 1
                cell_obj_component = obj.cell_obj_lptn_component;
            else
                if ischar(varargin{1})
                    cell_obj_component = obj.GetCellObjComponent(varargin{:});
%                     cell_obj_component = mat2cell(vec_obj_component,1,ones(1, numel(vec_obj_component)));
                else
                    cell_obj_component = varargin{1};
                end
            end
            %%output contact information
            for index_component = 1:length(cell_obj_component)
                for index = 1:length(obj.cell_obj_contacts)
                    if obj.cell_obj_contacts{index}.IsComponentContactOn(cell_obj_component{index_component})
                        obj.cell_obj_contacts{index}.ShowContactInfoInRespectOf(cell_obj_component{index_component});
                    end
                end
            end
        end
        %>@brief shows a graph as picture.png
        %>@param contact_filter
        %>'no_filter','noneshapeless','convection','radiation',string withname,
        %>obj of a component,function handle with bool as output
        %>@param graph_information
        %>information of contacts on edges or nodes
        %>possible arguments are 'direction', 'type', 'partial', 'heat', 'material',
        %>'hotspot','input-temperature', 'loss', 'none' and also
        %>functionhandles with the following outputs: numeric, char, cell,
        %>enumeration, logical
        %> e.g.:
        %> lptn.ShowGraph('no_filter', 'direction')
        %> ShowGraph(lptn,@IsRadialContact ,@(x)x.GetLength(1))
        function ShowGraph(obj,contact_filter,graph_information,varargin)
            graph_tool = LPNTool.clGraphTool;
            obj.SetGraphTool(graph_tool,contact_filter, graph_information,obj.GetSimscapeLogData,varargin{:});
            graph_tool.DrawGraph('show');
        end
        function OpenGraph(obj,contact_filter,graph_information,varargin)
            graph_tool = LPNTool.clGraphTool;
            obj.SetGraphTool(graph_tool,contact_filter,graph_information,obj.GetSimscapeLogData,varargin{:});
            graph_tool.DrawGraph('open');
        end
        %>@brief show symmetry boundary condition
        %>plot the side of a solid component without a connection
        function ShowOpenComponents(obj,varargin)
            % 			cell_direction = [];
            if numel(varargin) == 0
                for index_dim = 1:3
                    for index_dir = 1:2
                        cell_direction(index_dim,index_dir) = LPNEnum.enumCylindricalDirection.GetDirection(index_dim,index_dir);
                    end
                end
            else
                cell_direction = [varargin{:}];
            end
            for index = 1:numel(cell_direction)
                enum_direction = cell_direction(index);
                cell_open_componets = obj.GetOpenComponent(enum_direction);
                if numel(cell_open_componets)~=0
                    disp(['open components ' enum_direction.char]);
                    for index_comp = 1:numel(cell_open_componets)
                        if ~cell_open_componets{index_comp}.IsShapeless
                            disp(cell_open_componets{index_comp}.GetComponentName);
                        end
                    end
                end
            end
        end
        %% Run-Function
        function Reset(obj)
            obj.Reset@LPNSystem.clAbstractSimulinkSystem;
            for index_component = 1:numel(obj.cell_obj_lptn_component)
                obj.cell_obj_lptn_component{index_component}.Reset;
            end
            for index = 1:length(obj.cell_obj_contacts)
                obj.cell_obj_contacts{index}.Reset;
            end
            for index_system = 1:length(obj.cell_obj_buildable_system)
                obj.cell_obj_buildable_system{index_system}.Reset;
            end
            for index = 1:numel(obj.cell_obj_measuring_point)
                obj.cell_obj_measuring_point{index}.Reset;
            end
            obj.str_simscape_log_name = 'Simscape_Log';
            obj.vec_obj_numsym_non_geometry_parameter = LPNUtilities.clNumSym.empty(1,0);
            obj.number_nodes = 0;
            obj.total_subsystem_number = 0;
            obj.finished_subsystem_number = 0;
        end
        %>@brief this function should be called before StartSimulation to build the
        %>thermal network in Simulink. This function should not be modified
        %>@param str_system_name
        function BuildEnvironment(obj,str_system_name)
            % 			restoredefaultpath;
            % 			obj.root_name = str_system_name;
            obj.SetCurrentLPTN(obj);
            if obj.create_docu
                obj.str_folder = [str_system_name ' ' datestr(now,30)];
                mkdir(obj.str_folder);
                obj.docu_handle = fopen([obj.str_folder '\readme.txt'],'a');
            end
            %obj.str_block_ID = str_system_name;
            obj.str_model_name = str_system_name;
            obj.str_simscape_log_name = [obj.str_simscape_log_name '_' str_system_name];
            %for symbolic variable
            obj.SetNameDataStruct(['data_' obj.str_model_name]);
            % 			obj.Docu(['Building ' obj.GetBlockID ' started!'])
            %obj.str_simulink_model_name = obj.str_block_ID;
            obj.OpenSystemInSimulink(str_system_name);
            tic;
            % 			obj.ConstructModel;
            obj.AssignGlobalOptions;
            obj.SaveThermalSymbolicVariableInWorkspace;
            %>for override from children class
            obj.FinishConstructModel;
            %> take over global option
            obj.ValidateModel;
            %go through all the contact and calculate domain division, unit division
            obj.AnalyzeContacts;
            %build component in simulink
            obj.BuildComponentsAndConnections;
            %build subsystem
            obj.BuildSubsystem(str_system_name);
            try
                obj.PostProcessSimulinkModel();
            catch ME
                disp('error in PostProcessSimulinkModel');
                warning(ME.message);
            end
            %			toc;
            % 			obj.Docu(['Building ' str_system_name ' done!'])
            obj.time_build = toc;
            % 			obj.Docu(['BuildEnvironment time:' num2str(obj.time_build) 'Seconds']);
            vec_numsym = obj.GetAllSymbolicVariableInVec;
            obj.SaveNumsymVectorInWorkspace(vec_numsym);
            obj.SetDefaultSimulationParameter;
            obj.ShowBuildingStatistic;
        end
        function SetDefaultSimulationParameter(obj)
            obj.SetSimscapeLogging;
            %			For a typical Simscape model, MathWorks recommends the Simulink® variable-step solvers ode15s and ode23t. Of these two global solvers:
            %			The ode15s solver is more stable, but tends to damp out oscillations.
            %			The ode23t solver captures oscillations better but is less stable.
            %			With Simscape models, these solvers solve the differential and algebraic parts of the physical model simultaneously, making the simulation more accurate and efficient.
            obj.SetSimulationParameter('Solver','ode15s');
            % 			obj.SetSimulationParameter('Solver','ode23t');
            %To avoid simulation errors in sample time propagation, go to the Solver pane in the Configuration Parameters dialog box and select the Automatically handle rate transition for data transfer check box.
            obj.SetSimulationParameter('AutoInsertRateTranBlk','on');
            %parameters for simscape logging
            obj.SetSimulationParameter('SimscapeLogName', obj.str_simscape_log_name);
            obj.SetSimulationParameter('SimscapeLogDecimation', 1);
            obj.SetSimulationParameter('SimscapeLogLimitData', 'off');
            % 			obj.SetSimulationParameter('SimscapeLogDataHistory', 5000);
            obj.SetSimulationParameter('StopTime', num2str(obj.stop_time));
            obj.SetSimulationParameter('ZeroCrossAlgorithm', 'Adaptive');
            obj.SetSimulationParameter('LimitDataPoints', 'off');
            try
				if obj.MakeSimscapeParameterTunable
					obj.SetSimulationParameter('FastRestart','on');
				end
            catch
                warning('Use FastRestart feature in Matlab2015b for fast parameter estimation!');
            end
            %obj.SetSimulationParameter('StartFcn', 'disp(''Remember to reset simulation result using ResetAllSimulationResult'')');
		end
		function SetWorkspaceParameter(obj,name,value)
			hws = get_param(obj.GetModelName, 'modelworkspace');
			hws.assignin(name,value);
		end
        %>@brief to start the simulation and save the scope data in scope_output
        %>@param stop_time
        %>@todo change name to RunSimulation
        function simulation_output = StartSimulation(obj,stop_time)
            % 			display('Starting simulation...');
            tic;
            if nargin == 2
                obj.SetSimulationParameter('StopTime', num2str(stop_time));
            end
            simulation_output = sim(obj.GetHostName(), 'ReturnWorkspaceOutputs','on');
            obj.time_simulation = toc;
            %  			display('Simulation finished');
            obj.simulation_output = simulation_output;
            display(['Simulation lasts for ' num2str(obj.time_simulation) 'Seconds']);

            obj.ResetAllSimulationResult;

            for output_field = 1:length(simulation_output.get)
                assignin('base',simulation_output.get{output_field},simulation_output.get(simulation_output.get{output_field}));
            end
        end
        %>@brief empty the simulation result saved in the component and
        %>contact. If simscape log file is changed, this function should be
        %>called
        function ResetAllSimulationResult(obj)
            for index_component = 1:length(obj.cell_obj_lptn_component)
                obj.cell_obj_lptn_component{index_component}.ResetSimulationResult;
            end
            for index_contact = 1:length(obj.cell_obj_contacts)
                obj.cell_obj_contacts{index_contact}.ResetSimulationResult;
            end
        end
        %>@convert the subsystem to model reference
        function ConvertToModelReference(obj,varargin)
            if ~strcmp(obj.GetParameter('BlockType'),'ModelReference')
                if nargin == 2
                    if ischar(varargin{1})
                        obj.str_mdlref_name = varargin{1};
                    else
                        obj.str_mdlref_name = 'default';
                    end
                else
                    obj.str_mdlref_name = [obj.str_model_name datestr(now,30)];
                end
                obj.SetSimulationParameter('InlineParams','on');
                obj.SetParameter('TreatAsAtomicUnit','on');%set_param([obj.str_block_ID '/Subsystem'],'TreatAsAtomicUnit','on');
                [success,mdlRefBlkH] = Simulink.SubSystem.convertToModelReference(obj.GetBlockID,obj.str_mdlref_name,'ReplaceSubsystem',true,'Force',true);
                if mdlRefBlkH ~= get_param(obj.GetBlockID,'handle')
                    warning('model name error');
                end
                % 			else
                % 				mdlRefBlkH = get_param(obj.GetBlockID,'handle');
            end
        end
        %>@brief to create protected subsystem
        function RunProtectingSubsystem(obj)
            warning('protected model with variable parameter is slower as not protected model');
            obj.SetSimscapeLogging(0);
            obj.ConvertToModelReference;
            %for protected subsystem, all needed parameter must be setted.
            obj.SetParameterArgumentForProtecedModel;
            [~, neededVars] = Simulink.ModelReference.protect(obj.GetBlockID,'Harness', true);
        end
        %>@brief get names of all ouptut blocks of simulink model
        function cell_output_blocks = GetNameOutputBlocks(obj)
            lptn_name = obj.GetModelName;
            % get names of all output blocks
            cell_scopes = find_system(lptn_name,'SearchDepth',1,'BlockType','Scope');
            cell_outport = find_system(lptn_name,'SearchDepth',1,'BlockType','Outport');
            cell_display = find_system(lptn_name,'SearchDepth',1,'BlockType','Display');
            cell_toworkspace = find_system(lptn_name,'SearchDepth',1,'BlockType','ToWorkspace');
            cell_tofile = find_system(lptn_name,'SearchDepth',1,'BlockType','To File');
            cell_output_blocks = [cell_scopes;cell_outport;cell_display;cell_toworkspace;cell_tofile];
            for index_block = 1:length(cell_output_blocks)
                cell_output_blocks{index_block}(1:length(lptn_name)+1) = [];
            end
        end
        
        %>@brief get initial model for model reduction/finding proper
        %>@ discretization
        function resolution_setting = RebuildAsInitialModel(obj)
            lptn_name = obj.GetModelName;
            resolution_setting = ones(length(obj.cell_obj_lptn_component),3);
            % determine initial model resolution
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    has_hotspot_output = obj.cell_obj_lptn_component{index_component}.IfOutputHotspotTemperature;
                    % here: no different initial resolution for components with
                    % hotspot output
                    if has_hotspot_output
                        obj.cell_obj_lptn_component{index_component}.SetResolution(1,1,1);
                        resolution_setting(index_component,:) = [1,1,1];
                    else
                        obj.cell_obj_lptn_component{index_component}.SetResolution(1,1,1);
                    end
                end
            end
            % build initial model
            obj.Reset;
            obj.BuildEnvironment([lptn_name '_reduced']);
        end
        %>@brief get matrix with unit resolution of a model
        function mat_resolution = GetAllComponentsUnitResolution(obj)
            % rows of matrix: components
            % 3 collumns: discretization of component in 3 dimensions
            mat_resolution = zeros(length(obj.cell_obj_lptn_component),3);
            % get model resolution
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    mat_resolution(index_component,:) = obj.cell_obj_lptn_component{index_component}.GetUnitResolution;
                end
            end
        end
    end
    methods (Hidden)
        %>get the name of reference model
        % 		function name = GetReferenceModelName(obj)
        % 			name = obj.str_mdlref_name;
        % 		end
        %>@brief node number plus 1
        %>called by component and contact after build of unit.
        function NodePlusOne(obj)
            obj.number_nodes = obj.number_nodes+1;
        end
        %>show progress of building subsystem
        function EventFinishSubsystem(obj)
            %			if isempty(obj.obj_waitbar)
            % 				obj.obj_waitbar = waitbar(0,'Building Subsystem...');
            %				obj.finished_subsystem_number = 0;
            %			end
            obj.finished_subsystem_number = obj.finished_subsystem_number+1;
            if rem(obj.finished_subsystem_number,10) == 0
                disp([num2str(obj.finished_subsystem_number/obj.total_subsystem_number*100) '% finished...']);
            end
            % 			waitbar(obj.finished_subsystem_number/obj.total_subsystem_number,obj.obj_waitbar);
        end
        %>@brief create a mask on the subsystem. The original purpose is to
        function CreateMaskOnSubsystem(obj)
            if ~hasmask(obj.GetBlockID)
                obj_mask = Simulink.Mask.create(obj.GetBlockID);
            else
                obj_mask = Simulink.Mask.get(obj.GetBlockID);
            end
            vec_symnum = obj.GetAllSymbolicVariableInVec;
            for index = 1:length(vec_symnum)
                %for variable contacts, e.g. with a function block, makes
                %no sense to assign to workspace (and is not possible)
                if isa(vec_symnum(index),'LPNEnum.enumThermalVariableContact')
                    continue;
                end
				if isa(vec_symnum(index),'LPNUtilities.clVariableContactFilmCoefficient')
                    continue;
                end
                vec_symnum(index).AssignInMask(obj_mask);
            end
        end
        %>@brief get the simscape log name. simscape log is activated in
        %>default. It save all the voltage, current simulated in the
        %>thermal network
        function str_name = GetSimscapeLogName(obj)
            str_name = obj.str_simscape_log_name;
        end
        %>@brief get all symbolic variable in a struct
        % 		function stct_symbolics_parameter = GetAllSymbolicVariableInStruct(obj)
        % 			vec_numsym = obj.GetAllSymbolicVariableInVec;
        % 			for index = 1:numel(vec_numsym)
        % 				stct_symbolics_parameter.(vec_numsym(index).sym2str) = vec_numsym(index).sym2str;
        % 			end
        %         end
        %>write parameter into workspace for simulink model
        %         function AssignParameterFromFile(obj,str_file)
        %             tmp = load(str_file);
        %             parameter_names = fieldnames(tmp);
        %             for index = 1:numel(parameter_names)
        %                 vec_numsym(index) = LPNUtilities.clNumSym(parameter_names{index},tmp.(parameter_names{index}));
        %             end
        %             obj.SaveNumsymVectorInWorkspace(vec_numsym);
        %         end
    end
    methods (Access = protected)
        %>set parameter argument for subsystem, get ready for create
        %>protected model
        function SetParameterArgumentForProtecedModel(obj)
            if obj.UseSymbolicThermalParameter
                obj.SaveThermalSymbolicVariableInWorkspace;
                str_all_symbolics_parameter = obj.GetNameDataStruct;
                if ~isempty(obj.GetNameDataStruct)
                    set_param(obj.GetBlockID,'ParameterArgumentValues',str_all_symbolics_parameter);
                    set_param(obj.str_mdlref_name,'ParameterArgumentNames',str_all_symbolics_parameter);
                end
                evalin('base',['save(''' [obj.str_model_name '.mat'] ''',''' obj.GetNameDataStruct ''');']);
                hws = get_param(obj.str_mdlref_name, 'modelworkspace');
                hws.DataSource = 'MAT-File';
                hws.FileName = obj.str_model_name;
                hws.reload;
                save_system(obj.str_mdlref_name);
            end
        end
        %>geometry object set geometry using this function
        function SetGeometrySymbolicVariable(obj,cell_numsym)
            obj.cell_obj_numsym_geometry = cell_numsym;
            for index = 1:numel(obj.cell_obj_numsym_geometry)
                obj_numsym = obj.cell_obj_numsym_geometry{index};
                stct_optimum = obj.GetOptimizedModelParameter;
                if isfield(stct_optimum,obj_numsym.sym2str)
                    obj_numsym.numeric = stct_optimum.(obj_numsym.sym2str);
                end
            end
        end

        function output = GetSimulationOutput(obj)
            if isempty(obj.simulation_output)
                obj.StartSimulation;
            end
            output = obj.simulation_output;
        end
        %>@brief hand over global options to components and contacts
        function AssignGlobalOptions(obj)
            for index_component = 1:length(obj.cell_obj_lptn_component)
                obj.cell_obj_lptn_component{index_component}.TakeOverOptions(obj);
            end
            for index_contact = 1:length(obj.cell_obj_contacts)
                obj.cell_obj_contacts{index_contact}.TakeOverOptions(obj);
            end
            % 			for index_contact = 1:length(obj.cell_obj_non_physical_contacts)
            % 				obj.cell_obj_non_physical_contacts{index_contact}.TakeOverOptions(obj);
            % 			end
            for index_system = 1:length(obj.cell_obj_buildable_system)
                obj.cell_obj_buildable_system{index_system}.TakeOverOptions(obj);
            end
            for index = 1:numel(obj.cell_obj_measuring_point)
                obj.cell_obj_measuring_point{index}.TakeOverOptions(obj);
            end
        end
        %@brief destructor, close the document
        %@param obj
        %		function delete(obj)
        % 			if obj.docu_handle ~= -1
        % 				fclose(obj.docu_handle);
        % 			end
        %		end
        %>@brief for children class to overwrite.
        %>@warning this function will be abstract function later
        %>this function will be called after Construct Model to finish the
        %>job, such as finish thermal settings.
        function FinishConstructModel(obj)
            warning('for thermal modeling, please use clThermalNetwork class, magnetical modeling is not implemented');
        end
        function [mat_min_resolution] = GetMinimalResolution(obj)
            mat_min_resolution = zeros(numel(obj.cell_obj_lptn_component),3);
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    vec_domain_resolution = obj.cell_obj_lptn_component{index_component}.GetDomainResolution;
                    mat_min_resolution(index_component,1) = vec_domain_resolution(1);
                    mat_min_resolution(index_component,2) = vec_domain_resolution(2);
                    mat_min_resolution(index_component,3) = vec_domain_resolution(3);
                end
            end
        end
    end
    methods (Access = private)
        %>@brief set members of clGraphTool
        %>@param graph_tool, filter
        function SetGraphTool(obj,graph_tool,contact_filter, info_identifier, simscape_log_data, varargin)
            %set name of file
            if isa(info_identifier, 'function_handle')
                str_info_identifier = func2str(info_identifier);
            elseif isa(info_identifier,'char')
                str_info_identifier = info_identifier;
            else
                error('Input has to be a string or a function handle!');
            end
            if isa(contact_filter, 'function_handle')
                str_contact_filter = func2str(contact_filter);
            elseif isa(contact_filter, 'char')
                str_contact_filter = contact_filter;
            else
                str_contact_filter = contact_filter.GetComponentName;
            end
            str_output_file = [obj.str_model_name '_' str_contact_filter '_' str_info_identifier];
            %set attributes of graph
            graph_tool.SetAttributes('output_file', str_output_file);
            graph_tool.SetAttributes('title', str_output_file);
            graph_tool.SetAttributes('leftright', 0);
            if (strcmp('heat',str_info_identifier)||strcmp('hotspot',str_info_identifier)) && ~isempty(obj.cell_obj_contacts)
                for index = 1:length(obj.cell_obj_contacts)
                    [heatflux,actual_time] = obj.cell_obj_contacts{index}.GetHeatFluxFromSimscape(simscape_log_data, varargin{:});
                    if ~isempty(actual_time)
                        if length(actual_time) > 1
                            error('Please specify a simulation time');
                        end
                        break;
                    end
                end
                graph_tool.SetAttributes('title', [str_output_file '; Time: ' num2str(actual_time) ' s']);
            end
            if strcmp('direction',str_info_identifier)||strcmp('heat',str_info_identifier)
                graph_tool.SetAttributes('directed', 1);
            end
            %             if strcmp('type',str_info_identifier)||strcmp('geometry',str_info_identifier)
            %                 graph_tool.SetAttributes('leftright', 1);
            %             end
            
            if isa(contact_filter, 'function_handle')
            elseif strcmp('noneshapeless',contact_filter)
                contact_filter = @(x)(x.IsNoneshapelessContact);
            elseif strcmp('no_filter',contact_filter)
                contact_filter = @(x)~(isempty(x)); %function which always should be true
            elseif strcmp('convection',contact_filter)
                contact_filter = @(x)(x.IsConvectionContact);
            elseif strcmp('radiation',contact_filter)
                contact_filter = @(x)(isa(x,'LPNContact.clThermalRadiationContact'));
            else
                contact_filter = @(x)x.IsComponentContactOn(contact_filter);
            end
            %checking contacts
            for index = 1:length(obj.cell_obj_contacts)
                func_output = cell(3,1);
                try func_output{1} = contact_filter(obj.cell_obj_contacts{index}); %check whether function handle work for contacts or components
                catch
                    for component = 1:2
                        try func_output{component+1} = contact_filter(obj.cell_obj_contacts{index}.GetObjComponent(component));
                        catch ME
                            disp(ME.message);
                            error(['The feature ''' str_contact_filter ''' or ''' str_info_identifier ''' does not fit for contacts of class ''' class(obj.cell_obj_contacts{index}) '''!']);
                        end
                    end
                end
                for index2 = 1:3
                    if func_output{index2}
                        cell_info = obj.cell_obj_contacts{index}.GetCellInformationForGraph(info_identifier,simscape_log_data, varargin{:});
                        graph_tool.AddContact(cell_info{:});
                    end
                end
                if ~exist('func_output')
                    warning('Input functor is not defined.');
                end
            end
        end
        %>@brief get all contact that related to a component in vector
        function vec_contact = GetVecContactsConnectedTo(obj,str_component_name)
            vec_contact = {};
            for index_contact = 1:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{index_contact}.IsComponentContactOn(str_component_name)
                    vec_contact{end+1} = obj.cell_obj_contacts{index_contact};
                end
            end
        end
        %>@brief get all symbolics varaiable of model in a string
        function str_all_symbolics_parameter = GetAllSymbolicVariableNames(obj)
            vec_all_symbolics_parameter = obj.GetAllSymbolicVariableInVec;
            str_all_symbolics_parameter = '';
            for index = 1:length(vec_all_symbolics_parameter)
                str_all_symbolics_parameter = [str_all_symbolics_parameter vec_all_symbolics_parameter(index).sym2str ','];
            end
            if str_all_symbolics_parameter(end)==','
                str_all_symbolics_parameter = str_all_symbolics_parameter(1:end-1);
            end
        end
        function AddThermalNumSymParameter(obj,vec_obj_to_save)
            for index_save = 1:numel(vec_obj_to_save)
				obj_numsym = vec_obj_to_save(index_save);
                found = 0;
                for index = 1:numel(obj.vec_obj_numsym_non_geometry_parameter)
                    if strcmp(obj.vec_obj_numsym_non_geometry_parameter(index).sym2str,obj_numsym.sym2str);
                        found = 1;
                        a = obj.vec_obj_numsym_non_geometry_parameter(index).numeric;
                        b = obj_numsym.numeric;
                        if(isnan(a)&&~isnan(b))
                            obj.vec_obj_numsym_non_geometry_parameter(index).numeric = b;
                        else
                            assert(a == b||(~isnan(a)&&isnan(b)),[sym2str(obj_numsym) ' is not set or inconsistent']);
                        end
                        break;
                    end
                end
                if ~found
				    stct_optimum = obj.GetOptimizedModelParameter;
                    if isfield(stct_optimum,obj_numsym.sym2str)&&~strcmp(obj_numsym.sym2str,'global_initial_temperature')
                        if obj_numsym.numeric ~= stct_optimum.(obj_numsym.sym2str);
%                             warning(['numsym ' obj_numsym.sym2str ' is not updated before use. This will cause a bias between numsym and numeric calculation']);
                            obj_numsym.numeric = stct_optimum.(obj_numsym.sym2str);
                        end
                    end
                    obj.vec_obj_numsym_non_geometry_parameter(end+1) = obj_numsym;
                end
            end
        end
        %>delete simscape port.
        function CloseSimscapeEnvironment(obj)
            sys = obj.GetBlockID;
            % get handles to all blocks in system
            blocks = find_system( sys, ...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...%'all', ...
                'FindAll', 'on', ...
                'Type', 'block' ) ;
            for i=1:length(blocks)
                if ishandle(blocks(i))
                    if strcmp(get( blocks(i), 'BlockType'),'PMIOPort')
                        delete_block(blocks(i));
                    end
                end
            end
        end
%         function SaveAllSymbolicsVariable(obj)
%             error('use SaveThermalSymbolicVariableInWorkspace');
%             evalin('base',['save(''' [obj.str_model_name '.mat'] ''',''' obj.GetNameDataStruct ''');']);
%             %			obj.GetNameDataStruct;
%             % 			cell_variable = obj.GetAllSymbolicsVariableNamesInCell;
%             % 			for index = 1:numel(cell_variable)
%             % 				if index == 1
%             % 					evalin('base',['save(''' [obj.str_model_name '.mat'] ''',''' cell_variable{index} ''');']);
%             % 				else
%             % 					evalin('base',['save(''' [obj.str_model_name '.mat'] ''',''' cell_variable{index} ''',''-append'');']);
%             % 				end
%             % 			end
%         end
        function DeleteUnconnectedLines(obj)
            %DELETE_UNCONNECTED_LINES  Delete unconnected lines from a Simulink system.
            %   DELETE_UNCONNECTED_LINES('SYS') deletes all lines which has either no
            %   source or no destination under a system. That is, lines that are not
            %   fully connected to two blocks are removed (red-dotted in the GUI).
            %
            %   See also DELETE_LINE.
            
            %   Developed by Per-Anders Ekstrm, 2003-2006 Facilia AB.
            
            sys = obj.str_model_name;
            
            % get handles to all lines in system
            lines = find_system( sys, ...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...%'all', ...
                'FindAll', 'on', ...
                'Type', 'line' ) ;
            
            % for each line, call delete_recursive if handle still exist
            for i=1:length( lines )
                if ishandle( lines(i) )
                    if get( lines(i), 'SrcPortHandle' )<0 || get( lines(i), 'DstPortHandle' )< 0
                        delete_line( lines(i) );
                    end
                end
            end
        end
        %>@brief to write the string in the document if create_docu is active. The
        %>text will be also displayed in matlab command window
        %>@param str_text
        %>@param obj
        % 		function Docu(obj,str_text)
        % 			if obj.create_docu
        % 				fprintf(obj.docu_handle,'\r%s\n',str_text);
        % 				display(str_text);
        % 			end
        % 		end
        %>the basic test of the model
        %>@brief the basic test of the model
        %>@todo: check if all the object connect to any other object
        function ValidateModel(obj)
            %check component number
            if numel(obj.cell_obj_lptn_component) == 0
                warning('No Object Defined!');
            end
            %check contact number
            if numel(obj.cell_obj_contacts) == 0
                warning('No Connections Defined!');
                obj.coordinate_system = LPNEnum.enumCoordinateSystem.cartesian_coordinate_system;
            else
                try
                    obj.coordinate_system = obj.cell_obj_contacts{1}.GetCoordinateSystem;
                catch ME
                    obj.coordinate_system = obj.cell_obj_contacts{2}.GetCoordinateSystem;
                end
            end
            %check shapeless component without contact
            cell_temp_component = obj.cell_obj_lptn_component;
            obj.cell_obj_lptn_component = {};
            for index_component = 1:length(cell_temp_component)
                current_component = cell_temp_component{index_component};
                if current_component.IsShapeless
                    name_shapeless_component = current_component.GetComponentName;
                    vec_contacts = obj.GetVecContactsConnectedTo(name_shapeless_component);
                    if isempty(vec_contacts)&&~isa(current_component,'LPNContact.clCoolantFlow')
                        warning([name_shapeless_component ' is shapless component but is not connected to any other component']);
                    else
                        obj.cell_obj_lptn_component{end+1} = current_component;
                    end
                else
                    obj.cell_obj_lptn_component{end+1} = current_component;
                end
                if obj.BalanceDomainResolution&&current_component.HasSingleUnit
                    disp([current_component.GetComponentName ':single unit option is deactivated because of the option:balanced domain resolution.']);
                    current_component.SetSingleUnit(false);
                end
            end
            %check coordinatesystem
            for index = 2:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{2}.GetCoordinateSystem ~= obj.coordinate_system;
                    error('All the contacts must be defined in the same coordinate system');
                end
            end
        end
        
        %>@brief if the component name already defined
        function true = ComponentIsDefined(obj,obj_component)
            true = 0;
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if obj.cell_obj_lptn_component{index_component} == obj_component
                    true = 1;
                end
            end
        end
        %>@brief go throw all the contact and define the unit dividition of all
        %>the component.
        function AnalyzeContacts(obj)
            cellfun(@(x)x.InitDomainDivision,obj.cell_obj_lptn_component);
            display('Analyse Contacts...');
            %2013.03.05 fqi:the convection contact will not be analyzed.
            %so the contact range in convection contact will be empty.
            %while the connection, the convection component will connected
            %to all the unit, that havn't been connected.
            for index = 1:length(obj.cell_obj_contacts)
%                 if obj.cell_obj_contacts{index}.IsPhysicalContact
%                     if ~obj.cell_obj_contacts{index}.IsConvectionContact
                        obj.cell_obj_contacts{index}.AnalyzeContactRange;
%                     else
%                         obj.cell_obj_contacts{index}.AddManualContactRangeInDivision;
%                     end
%                 end
            end
            %measuring position must be considered globally, because two
            %measuring points in two neihbour component may conflict with
            %eachother
            obj.BalanceDivisionAndMeasuringPositionRecursively;
            %for index_component = 1:length(obj.cell_obj_lptn_component)
            %	obj.cell_obj_lptn_component{index_component}.CalculateAndAddDivisionPositionForMeasuringPoints;
            % 				obj.ShowAllDivision;
            % end
            cellfun(@(x)x.CalculateAndAddDivisionPositionForMeasuringPoints,obj.cell_obj_lptn_component);
            % 			obj.CalculateAndSetDivisionPoints;
            % 			for index_component = 1:numel(obj.cell_obj_lptn_component)
            % 				obj.cell_obj_lptn_component{index_component}.AddDivisionForMeasuringPoint;
            % 			end
            % 			obj.CreateDomainDivision;
            %initialize the unit_division between each division with the own
            %resolution settings. This settings may be overwriten.
            cellfun(@(x)x.CalculateInitialUnitResolution,obj.cell_obj_lptn_component);
            %adjust conflict with measuring point
            %fqi: the measuring point on the boundary of a unit is also modelled accurately. increase resolution may be not necessary.
            cellfun(@(x)x.CheckConflictDomainUnitResolutionWithMeasuringPoint,obj.cell_obj_lptn_component);
            %reset the unit resolution consider component
            %contact iterativly
            
            obj.AdaptUnitResolutionDependingOnContacts;
            
            
            %calculate the final unit_division
            cellfun(@(x)x.CalculateUnitDivision,obj.cell_obj_lptn_component);
            %debug function
            %cellfun(@(x)x.ShowDivision,obj.cell_obj_lptn_component);
            %initialize the unit contact of the component
            % 			cellfun(@(x)x.InitUnitCellContact,obj.cell_obj_lptn_component);
            display('Analyse Contacts finished.');
        end
        function CalculateTotalSubsystemNumber(obj)
            obj.total_subsystem_number = 0;
            for index_component = 1:length(obj.cell_obj_lptn_component)
                obj.total_subsystem_number = obj.total_subsystem_number + obj.cell_obj_lptn_component{index_component}.GetSubsystemNumber;
            end
            if ~obj.FastMode
                obj.total_subsystem_number = obj.total_subsystem_number + length(obj.cell_obj_contacts)+length(obj.cell_obj_measuring_point);
            end
        end
        %>@brief build block in Simulink
        function BuildComponentsAndConnections(obj)
            %load the object from component
            for index_component = 1:length(obj.cell_obj_lptn_component)
                obj.AddBlock(obj.cell_obj_lptn_component{index_component});
            end
            %create first the contact without convection component
            obj.BuildNonConvectionConnections;
            %if there is free area, connect convection component
            obj.BuildConvectionConnections;
            obj.BuildRadiationConnections;
            %add measurement points
            obj.BuildMeasurementPoints;
            %connect units inside a component
            for index = 1:numel(obj.cell_obj_lptn_component)
                obj.cell_obj_lptn_component{index}.FinishUnitStructure;
            end
            
            cell_real_loss_output = {};
            for index = 1:numel(obj.cell_obj_lptn_component)
                real_loss_output = obj.cell_obj_lptn_component{index}.GetRealLossOutput;
                if ~isempty(real_loss_output)
                    cell_real_loss_output{end+1} = real_loss_output;
                end
            end
            if ~isempty(cell_real_loss_output)
                obj.CreateSumOutput(cell_real_loss_output,'total_losses');
            end
            % 			cellfun(@(x)x.FinishUnitStructure,obj.cell_obj_lptn_component);
            %add global simscape colver
            obj.AddSimscapeSolver;
            %for updating building status
            obj.CalculateTotalSubsystemNumber;
            %add other buildable system
            for index_system = 1:numel(obj.cell_obj_buildable_system)
                obj.AddBlock(obj.cell_obj_buildable_system{index_system});
            end
            obj.FinishComponentAndContactSubsystems;
        end
        %build measurement points on components, considering the measurement
        %point may be connect with other shapeless component. This is for the
        %modeling of the undesire effect on the thermo sensor. The thermosensor
        %has its own capacitance and resistance to other component
        function BuildMeasurementPoints(obj)
            % 			warning('BuildMeasurementPoints to be implemented');
            for index = 1:numel(obj.cell_obj_measuring_point)
                obj.cell_obj_measuring_point{index}.UpdateComponentPortHandle;
                obj.AddBlock(obj.cell_obj_measuring_point{index});
            end
        end
        %>create first the contact without convection component
        function BuildNonConvectionConnections(obj)
            for index = 1:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{index}.IsPhysicalContact
                    if ~obj.cell_obj_contacts{index}.IsConvectionContact
                        %                         try
                        obj.AddBlock(obj.cell_obj_contacts{index});
                        %                         catch ME
                        % 						if strcmp(ME.identifier,'clComponentContact:ConnectUnits')
                        %                             obj.ShowConnectionInOneDirectionOfComponent(obj.cell_obj_contacts{index}.GetObjComponent(1),obj.cell_obj_contacts{index}.GetEnumDirection.GetOppositeDirection);
                        %                             obj.ShowConnectionInOneDirectionOfComponent(obj.cell_obj_contacts{index}.GetObjComponent(2),obj.cell_obj_contacts{index}.GetEnumDirection);
                        %     % 						end
                        %                             error(ME.message);
                        %                         end
                    end
                elseif isa(obj.cell_obj_contacts{index},'LPNContact.clVirtualThermalContact')
                    obj.AddBlock(obj.cell_obj_contacts{index});
                end
            end
        end
        %>if there is free area, connect convection component
        function BuildConvectionConnections(obj)
            for index = 1:length(obj.cell_obj_contacts)
                if obj.cell_obj_contacts{index}.IsPhysicalContact
                    if obj.cell_obj_contacts{index}.IsConvectionContact
                        obj.AddBlock(obj.cell_obj_contacts{index});
                    end
                end
            end
        end
        %>build radiation connection at last.
        function BuildRadiationConnections(obj)
            for index = 1:length(obj.cell_obj_contacts)
                if isa(obj.cell_obj_contacts{index},'LPNContact.clThermalRadiationContact')
                    obj.AddBlock(obj.cell_obj_contacts{index});
                end
            end
        end
        %>add simscape physical solver to the network
        %In a Simscape model, MathWorks recommends that you implement fixed-step solvers by continuing to use a global variable-step solver and switching the physical networks within your model to local fixed-step solvers through each network Solver Configuration block. The local solver choices are Backward Euler and Trapezoidal Rule. Of these two local solvers:
        %The Backward Euler tends to damp out oscillations, but is more stable, especially if you increase the time step.
        %The Trapezoidal Rule solver captures oscillations better but is less stable.
        function AddSimscapeSolver(obj)
            solver = obj.AddBlock(LPNEnum.enumSimulinkElement.solver);
            for index_component = 1:numel(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    obj.AddLine(obj.cell_obj_lptn_component{index_component}.GetConnectionPointToSolver,solver.GetPortRight);
                    break;
                end
            end
        end
        function FinishComponentAndContactSubsystems(obj)
            for index_component = 1:numel(obj.cell_obj_lptn_component)
                if obj.FastMode
                    obj.cell_obj_lptn_component{index_component}.FinishComponentSubsystem(0);
                    obj.TakeOverElements(obj.cell_obj_lptn_component{index_component});
                else
                    %					component_name = obj.cell_obj_lptn_component{index_component}.GetComponentName;
                    % 					display(['Building ' component_name ' subsystem...'])
                    %                 if strcmp(obj.cell_obj_lptn_component{index_component}.GetComponentName,'frame')
                    %                     1;
                    %                 end
                    obj.cell_obj_lptn_component{index_component}.FinishComponentSubsystem;
                end
                %  				end
            end
            
            for index = 1:length(obj.cell_obj_contacts)
                if obj.FastMode
                    obj.TakeOverElements(obj.cell_obj_contacts{index});
                else
                    obj.cell_obj_contacts{index}.FinishContactSubsystem;
                    obj.EventFinishSubsystem;
                end
            end
            % 			for index = 1:length(obj.cell_obj_non_physical_contacts)
            % 				if obj.FastMode
            % 					obj.TakeOverElements(obj.cell_obj_non_physical_contacts{index});
            % 				else
            % 					obj.cell_obj_non_physical_contacts{index}.FinishContactSubsystem;
            % 					obj.EventFinishSubsystem;
            % 				end
            %             end
            for index_point = 1:numel(obj.cell_obj_measuring_point)
                if obj.FastMode
                    obj.TakeOverElements(obj.cell_obj_measuring_point{index_point});
                else
                    obj.cell_obj_measuring_point{index_point}.FinishMeasuringPointSubsystem;
                    obj.EventFinishSubsystem;
                end
            end
            for index_system = 1:numel(obj.cell_obj_buildable_system)
                obj.cell_obj_buildable_system{index_system}.BuildSubsystem('buildable_system');
            end
        end
        %>go throw all the contact until there's no change any more in
        %>the division. Because the new divition will cause changes of
        %>the division in other component.
        function BalanceDivisionAndMeasuringPositionRecursively(obj)
            changed = 1;
            while changed == 1;
                changed = 0;
                for index = 1:length(obj.cell_obj_contacts)
                    obj_contact = obj.cell_obj_contacts{index};
                    if obj_contact.IsPhysicalContact
                        if obj_contact.BalanceDivisionAndMeasuringPositionOfComponents == 1
                            changed = 1;
                        end
                    end
                end
            end
        end
        %>@brief Set the unit of every component
        %>because every component can have different max unit size. go
        %>throw all the contact and set the unit size until there are all
        %>full contact between units.
        function AdaptUnitResolutionDependingOnContacts(obj)
            changed = 1;
            %go throw all the contact until there's no change any more in
            %the divition. Because the new divition will lead to change of
            %the divition in other component.
            while changed == 1;
                changed = 0;
                for index = 1:length(obj.cell_obj_contacts)
                    obj_contact = obj.cell_obj_contacts{index};
                    if obj_contact.IsPhysicalContact
                        if isempty(obj_contact.GetEnumerationThermalContact)||obj.BalanceDomainResolution
                            if obj_contact.UnifyUnitResolution == 1
                                changed = 1;
                            end
                        end
                    end
                end
                %                 if ~obj.BalanceDomainResolution
                %                     %in unbalance domain resolution mode, only the components in adjacent need
                %                     %have balanced domain resolution
                %                     break;
                %                 end
            end
        end
        
        function ReadSymbolicVariableFromMaterialAndContact(obj)
            for index_component = 1:length(obj.cell_obj_lptn_component)
                obj_component = obj.cell_obj_lptn_component{index_component};
                enum_material = obj_component.GetEnumMaterial;
                if ~isempty(enum_material)
                    obj.AddThermalNumSymParameter(enum_material.GetSymbolicVariable(~obj.IsSteadyState));
                end
                cell_heat_flux = obj_component.GetHeatFluxInput;
                for index_heat = 1:numel(cell_heat_flux)
                    if isa(cell_heat_flux{index_heat}.heat_flux_input,'LPNUtilities.clInputFunction')
                        stct_optimum = obj.GetOptimizedModelParameter;
                        cell_heat_flux{index_heat}.heat_flux_input.OverwriteFunctionPropertiesWithOptimizedValues(stct_optimum,0);
						cell_heat_flux{index_heat}.heat_flux_input.RegisterFunctionProperties(obj);
                    end
                end
            end
            for index_contact = 1:length(obj.cell_obj_contacts)
                if ~isempty(obj.cell_obj_contacts{index_contact}.GetEffectiveAirgap)
                    obj.AddThermalNumSymParameter(obj.cell_obj_contacts{index_contact}.GetEffectiveAirgap);
                elseif obj.cell_obj_contacts{index_contact}.IsPhysicalContact
                    obj.AddThermalNumSymParameter(obj.cell_obj_contacts{index_contact}.GetFilmCoefficientThermalContact);
                    [~,scaling] = obj.cell_obj_contacts{index_contact}.GetContactArea;
                    if isa(scaling,'LPNUtilities.clNumSym')
                        obj.AddThermalNumSymParameter(scaling);
                    end
                elseif isa(obj.cell_obj_contacts{index_contact},'LPNContact.clThermalRadiationContact')
                    enum_emissivity = obj.cell_obj_contacts{index_contact}.GetThermalEmissivity;
                    for i=1:length(enum_emissivity)
                        obj.AddThermalNumSymParameter(enum_emissivity{i}.emissivity);
                    end
                else
                    error('unknown type');
                end
            end
            for index_point = 1:length(obj.cell_obj_measuring_point)
                enum_material = obj.cell_obj_measuring_point{index_point}.GetEnumMaterial;
                if ~isempty(enum_material)
                    obj.AddThermalNumSymParameter(enum_material.GetSymbolicVariable(~obj.IsSteadyState));
                end
            end
            % 			for index_non_physical_contact = 1:length(obj.cell_obj_non_physical_contacts)
            % 				enum_emissivity = obj.cell_obj_non_physical_contacts{index_non_physical_contact}.GetThermalEmissivity;
            % 				for i=1:length(enum_emissivity)
            % 					obj.AddThermalNumSymParameter(enum_emissivity{i}.emissivity);
            % 				end
            % 			end
        end
        %>@brief go throw all the component and contact, save the parameter
        %>in workspace, for parameter tunable model.
        function SaveThermalSymbolicVariableInWorkspace(obj)
            if obj.UseSymbolicThermalParameter
                obj.ReadSymbolicVariableFromMaterialAndContact;
            end
        end
        %>save numsym vector in the workspace for model, depending on which
        %>workspace is currently used by the simulink model.
        function SaveNumsymVectorInWorkspace(obj,vec_numsym)
%             used_vars = Simulink.findVars(obj.GetModelName);
%             cell_name_used_vars = {used_vars.Name};
            
            hws = get_param(obj.GetModelName,'modelworkspace');
            hws.DataSource = 'Model File';
            % 				hws.FileName = 'workspace';
            %				hws.saveToSource;
            for index = 1:numel(vec_numsym)
%                 found = 0;
%                 for index_used_vars = 1:numel(cell_name_used_vars)
%                     if strcmp(used_vars(index_used_vars),vec_numsym(index).sym2str)
%                         found = 1;
%                         break;
%                     end
%                 end
%                 if found == 1
                    if obj.OptionUseModelWorkspace
                        vec_numsym(index).AssignInWorkspace(hws);
                    else
                        vec_numsym(index).AssignInBase(obj.GetNameDataStruct);
                    end
%                 else
%                     warning([vec_numsym(index).sym2str ' is not used in model']);
%                 end
            end
%             else
%                 for index = 1:numel(vec_numsym)
%                     found = 0;
%                     for index_used_vars = 1:numel(cell_name_used_vars)
%                         if strcmp(used_vars(index_used_vars),vec_numsym(index).sym2str)
%                             found = 1;
%                             break;
%                         end
%                     end
%                     if found == 1
%                         vec_numsym(index).AssignInBase(obj.GetNameDataStruct);
%                     else
%                         warning([vec_numsym(index).sym2str ' is not used in model']);
%                     end
%                 end
%             end
        end
        %>get the minimal resolution/domain resolution of the components of
        %>the model, save them in a matrix
    end
    
end

