classdef clThermalNetwork < LPNSystem.clLumpedParameterNetwork
    properties(Access = protected)
        global_initial_temperature
        %         cell_thermal_sensor = {};
        my_visualizer
        my_sensibility_analyser
        my_state_space_converter
        % 		index_port_losses = 1;
        %>the handle of the add block, which sum all losses up
        % 		block_add_total_loss
        %  		name_total_losses = 'total_losses';
        
    end
    methods
        %% set function
        function SetAllowNegativeLosses(obj,allow)
            if nargin < 2
                allow = 1;
            end
            cell_loss_source_tunable = find_system(obj.GetModelName,'ComponentVariantNames','loss_source_tunable');
            
            for index = 1:numel(cell_loss_source_tunable)
                set_param(cell_loss_source_tunable{index},'debug',num2str(allow));
            end
            
            cell_loss_source = find_system(obj.GetModelName,'ComponentVariantNames','loss_source');
            for index = 1:numel(cell_loss_source)
                set_param(cell_loss_source{index},'debug',num2str(allow));
            end
        end
        function SetMeasuredTemperature(obj,name,stct_reference_output)
            for index = 1:numel(obj.cell_obj_measuring_point)
                if strcmp(obj.cell_obj_measuring_point{index}.GetNameMeasuringPoint,name)
                    obj.cell_obj_measuring_point{index}.SetMeasurementValue(stct_reference_output);
                    return;
                end
            end
            for index = 1:numel(obj.cell_obj_measured_output)
                if strcmp(obj.cell_obj_measured_output{index}.GetNameMeasuringPoint,name)
                    obj.cell_obj_measured_output{index}.SetMeasurementValue(stct_reference_output);
                    return;
                end
            end
            temp_measuring_point = LPNUtilities.clMeasuredSignal;
            temp_measuring_point.SetMeasuredSignal(name,stct_reference_output);
            obj.cell_obj_measured_output{end+1} = temp_measuring_point;
            return;
            
            %for index = 1:numel(obj.cell_obj_lptn_component)
            %	if strcmp(obj.cell_obj_lptn_component{index}.GetGlobalAverageTemperatureName,name)
            %		obj.cell_obj_lptn_component{index}.SetReferenceAverageTemperature(stct_reference_output);
            %        return;
            %	end
            %end
            %             output_block = obj.GetGlobalBlock([name '_add']);
            disp(['SetMeasuredTemperature:' name ' is not defined. Ignored!']);
        end
        %>@brief set the global initial temperature
        %>@param temp the gloabl inital temperature
        function SetGlobalInitialTemperature(obj,temp)
            if ~isa(temp,'LPNUtilities.clNumSym')
                obj.global_initial_temperature = LPNUtilities.clNumSym('global_initial_temperature',temp);
            else
                obj.global_initial_temperature = temp;
            end
            obj.RegistSymbolicVariable(obj.global_initial_temperature);
        end
        %>@brief Debug function, show all thermal connection type.
        % 		function ShowAllThermalConnectionType(obj)
        % 			vec_shown_enum = LPNEnum.enumThermalContact.empty(0);
        % 			%index_shown = 1;
        % 			for index_contact = 1:length(obj.cell_obj_contacts)
        % 				obj.cell_obj_contacts{index_contact}.CheckThermalContact;
        % 				enum_type = obj.cell_obj_contacts{index_contact}.GetEnumerationThermalContact;
        % 				shown = 0;
        % 				for index_enum = 1:numel(vec_shown_enum)
        % 					if vec_shown_enum(index_enum) == enum_type
        % 						shown = 1;
        % 						break;
        % 					elseif isempty(enum_type)
        %  						shown = 1;
        %  						break;
        % 					end
        % 				end
        % 				if shown%this type have been already shown
        % 					continue;
        % 				else
        % 					disp('-----------------------------');
        % 					disp(char(enum_type{1}));
        % 					vec_shown_enum(end+1) = enum_type{1};
        % 					for index_contact2 = 1:length(obj.cell_obj_contacts)
        % 						if obj.cell_obj_contacts{index_contact2}.GetEnumerationThermalContact == enum_type{1}
        % 							disp(obj.cell_obj_contacts{index_contact2}.GetContactName);
        % 						end
        % 					end
        % 				end
        % 			end
        % 			disp('-----------------------------');
        % 			disp('direct connection');
        % 			for index_contact2 = 1:length(obj.cell_obj_contacts)
        % 				if isempty(obj.cell_obj_contacts{index_contact2}.GetEnumerationThermalContact)
        % 					disp(obj.cell_obj_contacts{index_contact2}.GetContactName);
        % 				end
        % 			end
        %         end
        %% analysis function
        function analyser = SensibilityTest(obj)
            analyser = LPNTool.clSensibilityAnalyser;
            analyser.SetThermalNetwork(obj);
            % 			analyser.SensibilityAnalysis;
        end
        %>@brief GUI contains diverse LPNBuillder GUI
        function StartMasterGUI(obj)
            obj.my_state_space_converter = obj.GetToolStateSpaceConverter();
            mygui = LPNGui.clMasterGUI(obj.GetCurrentVisualizer(),obj.my_state_space_converter,obj);
        end
        %>@brief start visulaizer GUI for the 3D plot of the thermal
        %>component
        function StartVisualizerGUI(obj)
            LPNGui.clVisualizerGUI(obj.GetCurrentVisualizer());
        end
        %>@brief start show graph gui
        function StartGraphGUI(obj)
            LPNGui.clGraphToolGUI(obj);
        end
        %>@brief GUI to convert LPTN in state space model.
        function StartStateSpaceConverterGUI(obj)
            obj.my_state_space_converter = obj.GetToolStateSpaceConverter();
            LPNGui.clStateSpaceConverterGUI(obj.my_state_space_converter);
        end
        
        %>@brief function for sensibility analyser
        function cell_component = GetThermalComponentWithOutput(obj)
            cell_component = {};
            for index = 1:numel(obj.cell_obj_lptn_component)
                if obj.cell_obj_lptn_component{index}.IfOutputHotspotTemperature...
                        ||obj.cell_obj_lptn_component{index}.IfOutputAverageTemperature
                    cell_component{end+1} = obj.cell_obj_lptn_component{index};
                end
            end
        end
        %>@brief get simulated temperature
        function [obj_timeseries_or_vec_result,empty_or_vec_time] = GetSimulatedTemperature(obj,signal_id)
            % 			if ischar(obj_component)
            % 				obj_component = obj.GetObjComponent(obj_component);
            %             end
            %             signal_id = obj_component.GetNameTemperatureOutput(enum_signal_or_string);
            vec_result = [];
            vec_time = [];
            if obj.GetEnumOutput == LPNEnum.enumLPNBuilderOption.output_as_scope...
                    || obj.GetEnumOutput == LPNEnum.enumLPNBuilderOption.output_as_to_workspace
                simulation_output = obj.GetSimulationOutput;
                vec_time = simulation_output.get(signal_id).time;
                vec_result = simulation_output.get(signal_id).signals.values;
                
            elseif obj.GetEnumOutput == LPNEnum.enumLPNBuilderOption.output_as_port
                % this read method is only valid for the save to workspace
                % option format: array.
                outport_id = find_system(obj.GetModelName,'SearchDepth',1,'BlockType','Outport');
                for index = 1:numel(outport_id)
                    if strcmp(outport_id{index}((1+strfind(outport_id{index},'/')):end),signal_id)%strcmp
                        vec_time = obj.GetSimulationOutput.get('tout');
                        vec_result = obj.GetSimulationOutput.get('yout');
                        if verLessThan('matlab', '8.6.0')
                            vec_result = squeeze(vec_result);
                            vec_result = vec_result(:,index);
                        else
                            vec_result = vec_result.get(index).Values.Data;
                        end
                        break;
                    end
                end
            else
                error('output option doesn''t allows get simulated temperature');
            end
            if isempty(vec_result)
                ME = MException('clThermalNetwork:OutputNotExist',[signal_id ' not found']);
                throw(ME);
            end
            if nargout == 1
                obj_timeseries_or_vec_result = timeseries(vec_result,vec_time);
            elseif nargout == 2
                obj_timeseries_or_vec_result = vec_result;
                empty_or_vec_time = vec_time;
            end
        end
        %         function AddLossesOutput(obj,varargin)
        %
        %         end
        %>@brief add losses for a group of component. the loss is
        %>distributed depending on the volumn of the components
        function vec_losses = AddGroupLosses(obj,name,varargin)
            assert(ischar(name));
            total_volume = 0;
            nr_loss_parameter = 0;%number of none-component parameters
            for index_parameter = 1:numel(varargin)
                if isa(varargin{index_parameter},'LPNElement.clGeometricElement')
                    total_volume = total_volume+varargin{index_parameter}.GetScaledVolume;
                else
                    nr_loss_parameter = index_parameter;
                end
            end
            for index_parameter = nr_loss_parameter+1:numel(varargin)
                vec_losses(index_parameter-nr_loss_parameter) = varargin{index_parameter}.SetInputHeatFlux(varargin{1},varargin{index_parameter}.GetScaledVolume/total_volume,varargin{2:nr_loss_parameter});
                vec_losses(index_parameter-nr_loss_parameter).global_heat_flux_name = name;
            end
        end
        %>@brief add output of average temperature of a group of component
        function AddGroupAverageTemperatureOutput(obj,name,varargin)
            total_volume = 0;
            for index = 1:numel(varargin)
                total_volume = total_volume+varargin{index}.GetScaledVolume;
            end
            for index = 1:numel(varargin)
                varargin{index}.OutputGlobalAverageTemperature(name,varargin{index}.GetScaledVolume/total_volume);
            end
        end
        %>@brief return component with reference temperature in a cell
        % 		function [cell_component,nr_plots] = GetCellComponentWithReferenceTemperature(obj,varargin)
        % 			nr_plots = 0;
        % 			if nargin == 1
        % 				cell_all_components = obj.cell_obj_lptn_component;
        % 			elseif ischar(varargin{1})
        % 				cell_all_components = {obj.GetObjComponent(varargin{:})};
        % 			else
        % 				cell_all_components = varargin;
        % 			end
        % 			cell_component = {};
        % 			for index = 1:numel(cell_all_components)
        % 				current_component = cell_all_components{index};
        % 				if ~isempty(current_component.GetReferenceTemperatureName)
        % 					cell_component{end+1} = current_component;
        % 					nr_plots = nr_plots + numel(current_component.GetReferenceTemperatureName);
        % 				end
        % 			end
        % 		end
        %>@brief return component with reference temperature in a cell
        function [cell_component,nr_plots] = GetCellComponentWithOutputTemperature(obj,varargin)
            nr_plots = 0;
            if nargin == 1
                cell_all_components = obj.cell_obj_lptn_component;
            elseif ischar(varargin{1})
                cell_all_components = {obj.GetObjComponent(varargin{:})};
            else
                cell_all_components = varargin;
            end
            cell_component = {};
            for index = 1:numel(cell_all_components)
                current_component = cell_all_components{index};
                if current_component.IfOutputHotspotTemperature
                    cell_component{end+1} = current_component;
                    nr_plots = nr_plots + 1;
                end
                if current_component.IfOutputAverageTemperature
                    if ~isempty(cell_component) && cell_component{end} ~= current_component
                        cell_component{end+1} = current_component;
                    end
                    nr_plots = nr_plots + 1;
                end
            end
        end
        function have_negative_loss = HaveNegativeLosses(obj,simscape_log,tolerance)
            have_negative_loss = 0;
            if nargin < 3
                tolerance = -10;
            end
            for index = 2:length(obj.cell_obj_lptn_component)
                [vec_losses,vec_time] = obj.cell_obj_lptn_component{index}.GetTotalLosses(simscape_log);
                if any(vec_losses < tolerance)
                    [minimal_loss,index_minimal] = min(vec_losses);
                    disp([obj.cell_obj_lptn_component{index}.GetComponentName ' has negative losses: ' num2str(minimal_loss) ' at time ' num2str(vec_time(index_minimal))]);
                    have_negative_loss = 1;
                    return;
                end
            end
        end
        function PlotTemperature(obj,str_component)
            if ischar(str_component)
                obj_component = obj.GetCellObjComponent(str_component);
                obj_component = obj_component{1};
            else
                obj_component = str_component;
            end
            [vec_hotspot,vec_time] = obj_component.GetHotspotTemperatureFromSimscape(obj.GetSimscapeLogData);
            [vec_average,vec_time] = obj_component.GetAverageTemperatureFromSimscape(obj.GetSimscapeLogData);
            warning('average temperature may change if geometry parameter is changed');
            hold on;
            plot(vec_time,vec_hotspot,'DisplayName',['hotspot ' obj_component.GetComponentName]);
            plot(vec_time,vec_average,'DisplayName',['average ' obj_component.GetComponentName]);
        end
        %plot simulated losses
        function PlotLosses(obj,varargin)
            hold on;
            vec_time =  [];
            vec_losses = [];
            str_components = '';
            if nargin > 1
                cell_obj_component = obj.GetCellObjComponent(varargin{:});
            else
                cell_obj_component = obj.cell_obj_lptn_component;
            end
            simscape_log = obj.GetSimscapeLogData;
            for index = 1:length(cell_obj_component)
                %                 [vec_hotspot,vec_time] = cell_obj_component{index}.GetHotspotTemperatureFromSimscape(obj.GetSimscapeLogData);
                %                 [vec_average,vec_time] = cell_obj_component{index}.GetAverageTemperatureFromSimscape(obj.GetSimscapeLogData);
                warning('average temperature may change if geometry parameter is changed');
                hold on;
                %                 plot(vec_time,vec_hotspot,'DisplayName',['hotspot ' cell_obj_component{index}.GetComponentName]);
                %                 plot(vec_time,vec_average,'DisplayName',['average ' cell_obj_component{index}.GetComponentName]);
                [temp_losses,temp_time] = cell_obj_component{index}.GetTotalLosses(simscape_log);
                if ~isempty(temp_losses)
                    vec_time = temp_time;
                    str_components = [str_components '&' mytools.ReplaceUnderline(cell_obj_component{index}.GetComponentName)];
                    if isempty(vec_losses)
                        vec_losses = temp_losses;
                    else
                        vec_losses = vec_losses + temp_losses;
                    end
                end
            end
            %             figure;
            plot(vec_time,vec_losses,'DisplayName',['losses ']);
            title(['losses of ' str_components]);
        end
        %>@brief CompareSimulatedTemperatureWithReference, varargin can be
        %>empty for all, or several object
        function CompareSimulatedTemperatureWithReference(obj,varargin)
            warning('on','all');
            obj.SetSimscapeLogging;
            %             warning('off','all');
            try
                obj.StartSimulation;
            catch ME
                warning(ME.message);
            end
            %             warning('on','all');
            figure;
            hold on;
            plot_seperate = 0;
            % 			number_figure = numel(cell_component);
            %sub plot figure
            cell_obj_all_measuring_point = obj.GetCellMeasuringPoint;
            if nargin > 1
                cell_measuring_point_to_show = {};
                for index = 1:numel(varargin)
                    name = varargin(index);
                    for index_measuring_point = 1:numel(cell_obj_all_measuring_point)
                        if strcmp(cell_obj_all_measuring_point{index_measuring_point}.GetNameMeasuringPoint,name)
                            cell_measuring_point_to_show{end+1} = cell_obj_all_measuring_point{index_measuring_point};
                        end
                    end
                end
            else
                cell_measuring_point_to_show = cell_obj_all_measuring_point;
            end
            %             str_legend = {};
            num_points = numel(cell_measuring_point_to_show);
            sumsqr_error = 0;
            for index_measuring_point = 1:num_points
                current_measuring_point = cell_measuring_point_to_show{index_measuring_point};
                %                 current_component = current_measuring_point.GetMeasuredComponent;
                if plot_seperate
                    subplot(1,num_points,index_measuring_point);
                    %                     str_legend = {};
                end
                hold on;
                cc = lines(num_points);%hsv,hot,bone,copper,pink,gray,cool
                name_or_enum = current_measuring_point.GetNameTemperatureOutput;
                obj_reference_signal = current_measuring_point.GetMeasurementTimeSeries();
                if isempty(obj_reference_signal)
                    continue;
                end
                try
                    obj_timeseries = obj.GetSimulatedTemperature(name_or_enum);
                catch ME
                    if strcmp(ME.identifier,'clThermalNetwork:OutputNotExist')
                        disp(ME.message);
                        continue;
                    else
                        rethrow(ME);
                    end
                end
                
                plot(obj_reference_signal.Time,obj_reference_signal.Data,'-','color',cc(index_measuring_point,:),'DisplayName',['measurement ' strrep(name_or_enum,'_',' ')]);
                plot(obj_timeseries.Time,squeeze(obj_timeseries.Data),'--','color',cc(index_measuring_point,:),'DisplayName',['simulation ' strrep(name_or_enum,'_',' ')]);
                % 					plot(obj_timeseries.Time,obj_timeseries.Data,'.','color',cc(index_figure,:));
                % 				str_legend{end+1} =  ['measurement ' strrep(name_or_enum,'_',' ')];
                % 				str_legend{end+1} =  ['simulation ' strrep(name_or_enum,'_',' ')];
                
                %% calculate sumsqr of error
                r = sdo.requirements.SignalTracking;
                r.Type      = '==';
                r.Method    = 'Residuals';
                r.Normalize = 'off';%r.
                current_error = evalRequirement(r,obj_timeseries,obj_reference_signal);
                disp(['error ' name_or_enum ' maximum:' num2str(max(abs(current_error))) ' |sumsqr:'  num2str(sumsqr(current_error)) ' |average:'  num2str(mean(abs(current_error)))]);
                sumsqr_error = sumsqr_error + sumsqr(current_error);
                plot(obj_reference_signal.Time,current_error,':','color',cc(index_measuring_point,:),'DisplayName',['error ' strrep(name_or_enum,'_',' ')]);
                if plot_seperate
                    grid on;
                    %                     legend(str_legend{:});
                    hold off;
                    axis([-inf,obj_timeseries.Time(end),-inf,inf]);
                end
                
            end
            disp(['sumsqr of the error:' num2str(sumsqr_error)]);
            if ~plot_seperate&&num_points>0
                grid on;
                %                 legend(str_legend{:});
                axis([-inf,obj_timeseries.Time(end),-inf,inf]);
            end
            %% check simulation result
            simscape_log = obj.GetSimscapeLogData;
            for index = 2:length(obj.cell_obj_lptn_component)
                [vec_losses,vec_time] = obj.cell_obj_lptn_component{index}.GetTotalLosses(simscape_log);
                if any(vec_losses < -10)
                    [minimal_loss,index_minimal] = min(vec_losses);
                    warning([obj.cell_obj_lptn_component{index}.GetComponentName ' has negative losses: ' num2str(minimal_loss) ' at time ' num2str(vec_time(index_minimal))]);
                    obj.PlotLosses(obj.cell_obj_lptn_component{index}.GetComponentName);
                end
            end
        end
        %  		function PlotAllSimulatedTemperature(obj,str_component)
        %             obj.PlotTemperature(str_component);
        %         end
        % 			[cell_component,number_figure] = obj.GetCellComponentWithOutputTemperature(varargin{:});
        % %  			figure;
        % 			hold on;
        % 			index_figure = 1;
        % % 			number_figure = numel(cell_component);
        % 			%sub plot figure
        % 			cc = hsv(numel(cell_component));
        % 			str_legned = {};
        % 			for index = 1:numel(cell_component)
        % 				current_component = cell_component{index};
        % 				for index_signal = 1:numel(current_component)
        % % 					enum = LPNEnum.enumSignalType.average;
        % 					if current_component.IfOutputHotspotTemperature
        % 						obj_timeseries = obj.GetSimulatedTemperature(current_component,LPNEnum.enumSignalType.maximum);
        % 						name_or_enum = 'hotspot';
        % 						plot(obj_timeseries.Time,obj_timeseries.Data,'*','color',cc(index,:));
        % 						str_legned{index_figure} =  [current_component.GetComponentName(1) ' ' name_or_enum];
        % 						index_figure = index_figure+1;
        % 						grid on;
        % 					end
        % 					if current_component.IfOutputAverageTemperature
        % 						obj_timeseries = obj.GetSimulatedTemperature(current_component,LPNEnum.enumSignalType.average);
        % 						name_or_enum = 'average';
        % 						plot(obj_timeseries.Time,obj_timeseries.Data,'-','color',cc(index,:));
        % 						str_legned{index_figure} =  [current_component.GetComponentName(1) ' ' name_or_enum];
        % 						index_figure = index_figure+1;
        % 						grid on;
        % 					end
        % 				end
        % 			end
        % 			hold off;
        % 			legend(str_legned{:});
        % % 			legend('measurement','simulation');
        % 		end
        %>@brief call matlab parameter estimation tool box
        %>@param parameter_uncertainty
        function estimator = ParameterEstimation(obj)
            %             obj.CompareSimulatedTemperatureWithReference;
            estimator = LPNTool.clParameterEstimator;
            estimator.SetLPTN(obj);
        end
        %>@brief build high resoultion model in balanced mode and get
        %>@ simulated temperature
        %>@ obj (in balanced mode)
        function RebuildModelInHighResolution(obj)
            % high resoluted model needs to be in balanced resolution mode
            obj.SetOptions(LPNEnum.enumLPNBuilderOption.balanced_resolution)
            lptn_name = obj.GetModelName;
            % determine reference model resolution
            cell_measuringpoints = obj.GetCellMeasuringPoint;
            % go through every component, check whether it has a
            % measuring point or is referred to an output block
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    component_name = obj.cell_obj_lptn_component{index_component}.GetComponentName;
                    has_measuringpoint = 0;
                    for n = 1:length(cell_measuringpoints)
                        if strcmp(cell_measuringpoints{n},component_name)
                            has_measuringpoint = 1;
                        end
                    end
                    has_avg_output = obj.cell_obj_lptn_component{index_component}.IfOutputAverageTemperature;
                    has_hotspot_output = obj.cell_obj_lptn_component{index_component}.IfOutputHotspotTemperature;
                    has_output = has_measuringpoint || has_avg_output || has_hotspot_output;
                    if has_output
                        obj.cell_obj_lptn_component{index_component}.SetResolution(3,3,2);
                    elseif ~isempty(obj.cell_obj_lptn_component{index_component}.GetHeatFluxInput)
                        obj.cell_obj_lptn_component{index_component}.SetResolution(2,2,2);
                    else
                        obj.cell_obj_lptn_component{index_component}.SetResolution(1,1,1);
                    end
                end
            end
            % build reference model
            obj.Reset;
            obj.BuildEnvironment(lptn_name);
        end
        function cell_ref_output_temperature = GetReferenceSimulatedTemperature(obj)
            obj.StartSimulation;
            cell_output_blocks = obj.GetNameOutputBlocks;
            % saving reference output simulation results into timeseries cells
            % assign timeseries in base workspace
            cell_ref_output_temperature = cell(length(cell_output_blocks),1);
            for index_output = 1:length(cell_output_blocks)
                ts_auxilliary = obj.GetSimulatedTemperature(cell_output_blocks{index_output});
                cell_ref_output_temperature{index_output} = timeseries(ts_auxilliary.data(:),ts_auxilliary.time,'name',cell_output_blocks{index_output});
                assignin('base',cell_ref_output_temperature{index_output}.name,cell_ref_output_temperature{index_output});
            end
        end
        %>@brief find reduced discretization for ltpn model,
        %>@ first building a reference model, then building an initial model
        %>@ with lowest resolution, then increase resolution
        %>@ main criteria: difference to reference output
        %>@ input arguments: reference LPTN model, cell with reference
        %>@ output results, tolerance bound and tolerance bound for maximum
        %>@ gradient
        %>@ param: ref_lptn, cell_ref_output_temperature, tol_bound,
        %>@ max_gradient_bound
        function ModelReductionFqi(obj,tol_bound)%,max_gradient_bound)
            lptn_name = obj.GetModelName;
            %             obj.RebuildModelInHighResolution;
            mat_max_res = obj.GetAllComponentsUnitResolution;
            cell_ref_output_temperature = obj.GetReferenceSimulatedTemperature;
            % get names of all output blocks
            cell_output_blocks = obj.GetNameOutputBlocks;
            % initialize boolean variables whether to increase resolution or not
            %             bool_output_error = zeros(length(cell_output_blocks),1);
            bool_increase  = zeros(length(obj.cell_obj_lptn_component),3);
            bool_build_new_model = 0;
            %build inital model
            disp('Build inital model ...');
            obj.SetOptions(LPNEnum.enumLPNBuilderOption.unbalanced_resolution);
            desired_res = obj.RebuildAsInitialModel;
            while 1
                obj.StartSimulation;
                simlog_variable = obj.GetSimscapeLogData;
                [cell_output_temperature,cell_temperature_error,bool_output_error] = obj.GetOutputStatistics(cell_ref_output_temperature,cell_output_blocks,tol_bound);
                mat_max_gradients = obj.GetMaxGradientMatrix(simlog_variable);
                %                bool_increase = mat_max_gradients > max_gradient_bound;
                % find matching components to every ouptut block which shows
                % large error, then set the relative bool
                bool_increase = obj.FindMatchingComponentToOutput(cell_output_blocks,bool_increase,bool_output_error,mat_max_gradients);
                % increasing desired resolution setting if necessary
                for index_component = 1:length(obj.cell_obj_lptn_component)
                    if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                        for index_dim = 1:3
                            if bool_increase(index_component,index_dim) && desired_res(index_component,index_dim) < mat_max_res(index_component,index_dim)
                                desired_res(index_component,index_dim) = desired_res(index_component,index_dim) + 1;
                                bool_build_new_model = 1;
                            end
                            obj.cell_obj_lptn_component{index_component}.SetResolution(desired_res(index_component,1),desired_res(index_component,2),desired_res(index_component,3));
                        end
                    end
                end
                if ~bool_build_new_model
                    disp('Reducing finished.');
                    break
                end
                obj.Reset;
                obj.BuildEnvironment(lptn_name);
                %                 bool_output_error = zeros(length(cell_output_blocks),1);
                bool_increase  = zeros(length(obj.cell_obj_lptn_component),3);
                bool_build_new_model = 0;
            end
            %             while 1
            %                 for index_component = 1:length(obj.cell_obj_lptn_component)
            %                     if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
            %                         if all(desired_res(index_component,:)==1)
            %                             obj.cell_obj_lptn_component{index_component}.SetSingleUnit;
            %                         end
            %                     end
            %                 end
            %                 obj.StartSimulation;
            %                 simlog_variable = obj.GetSimscapeLogData;
            %                 [cell_output_temperature,cell_temperature_error,bool_output_error] = obj.GetOutputStatistics(cell_ref_output_temperature,cell_output_blocks,tol_bound);
            %                 mat_max_gradients = obj.GetMaxGradientMatrix(simlog_variable);
            %                 %                bool_increase = mat_max_gradients > max_gradient_bound;
            %                 % find matching components to every ouptut block which shows
            %                 % large error, then set the relative bool
            %                 bool_increase = obj.FindMatchingComponentToOutput(cell_output_blocks,bool_increase,bool_output_error,mat_max_gradients);
            %                 % increasing desired resolution setting if necessary
            %                 for index_component = 1:length(obj.cell_obj_lptn_component)
            %                     if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
            %                         for index_dim = 1:3
            %                             if bool_increase(index_component,index_dim) && desired_res(index_component,index_dim) < mat_max_res(index_component,index_dim)
            %                                 desired_res(index_component,index_dim) = desired_res(index_component,index_dim) + 1;
            %                                 bool_build_new_model = 1;
            %                             end
            %                         end
            %                     end
            %                 end
            %                 if ~bool_build_new_model
            %                     disp('Reducing finished.');
            %                     break
            %                 end
            %                 obj.Reset;
            %                 obj.BuildEnvironment(lptn_name);
            %                 %                 bool_output_error = zeros(length(cell_output_blocks),1);
            %                 bool_increase  = zeros(length(obj.cell_obj_lptn_component),3);
            %                 bool_build_new_model = 0;
            %             end
        end
        %>@brief find reduced discretization for ltpn model,
        %>@ first building a reference model, then building an initial model
        %>@ with lowest resolution, then increase resolution
        %>@ main criteria: difference to reference output
        %>@ input arguments: reference LPTN model, cell with reference
        %>@ output results, tolerance bound and tolerance bound for maximum
        %>@ gradient
        %>@ param: ref_lptn, cell_ref_output_temperature, tol_bound,
        %>@ max_gradient_bound
        function ModelReduction(obj,ref_lptn,cell_ref_output_temperature,tol_bound)%,max_gradient_bound)
            lptn_name = obj.GetModelName;
            mat_max_res = ref_lptn.GetAllComponentsUnitResolution;
            % get names of all output blocks
            cell_output_blocks = obj.GetNameOutputBlocks;
            % initialize boolean variables whether to increase resolution or not
            %             bool_output_error = zeros(length(cell_output_blocks),1);
            bool_increase  = zeros(length(obj.cell_obj_lptn_component),3);
            bool_build_new_model = 0;
            %build inital model
            disp('Build inital model ...');
            desired_res = obj.RebuildAsInitialModel;
            while 1
                obj.StartSimulation;
                simlog_variable = obj.GetSimscapeLogData;
                [cell_output_temperature,cell_temperature_error,bool_output_error] = obj.GetOutputStatistics(cell_ref_output_temperature,cell_output_blocks,tol_bound);
                mat_max_gradients = obj.GetMaxGradientMatrix(simlog_variable);
                bool_increase = mat_max_gradients > max_gradient_bound;
                % find matching components to every ouptut block which shows
                % large error, then set the relative bool
                bool_increase = obj.FindMatchingComponentToOutput(cell_output_blocks,bool_increase,bool_output_error,mat_max_gradients);
                % increasing desired resolution setting if necessary
                for index_component = 1:length(obj.cell_obj_lptn_component)
                    if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                        for index_dim = 1:3
                            if bool_increase(index_component,index_dim) && desired_res(index_component,index_dim) < mat_max_res(index_component,index_dim)
                                desired_res(index_component,index_dim) = desired_res(index_component,index_dim) + 1;
                                bool_build_new_model = 1;
                            end
                            obj.cell_obj_lptn_component{index_component}.SetResolution(desired_res(index_component,1),desired_res(index_component,2),desired_res(index_component,3));
                        end
                    end
                end
                if ~bool_build_new_model
                    disp('Reducing finished.');
                    break
                end
                obj.Reset;
                obj.BuildEnvironment(lptn_name);
                %                 bool_output_error = zeros(length(cell_output_blocks),1);
                bool_increase  = zeros(length(obj.cell_obj_lptn_component),3);
                bool_build_new_model = 0;
            end
        end
    end
    methods(Hidden)
        %>
        % function LinkLossToTotalLoss(obj,outport_loss)
        % obj.AddLine(outport_loss,obj.block_add_total_loss.GetInport(obj.index_port_losses));
        % obj.index_port_losses = obj.index_port_losses + 1;
        % end
        %>@brief converts the initial temperature to a clNumSym
        % 		function ConvertInitialTemperatureToSymbolic(obj)
        % 			if ~isa(obj.global_initial_temperature,'LPNUtilities.clNumSym')
        % 				obj.global_initial_temperature = LPNUtilities.clNumSym('global_initial_temperature', obj.global_initial_temperature);
        %             end
        % 			obj.RegistSymbolicVariable(obj.global_initial_temperature);
        %         end
    end
    methods(Access = protected)
        %>@brief set every component temperature using global initial temperature
        function SetComponentInitialTemperature(obj)
            % 			if obj.UseSymbolicThermalParameter()
            % 				obj.ConvertInitialTemperatureToSymbolic();
            % 			end
            if ~isempty(obj.global_initial_temperature)
                for index_component = 1:length(obj.cell_obj_lptn_component)
                    if isempty(obj.cell_obj_lptn_component{index_component}.GetInitialTemperature)
                        obj.cell_obj_lptn_component{index_component}.SetInitialTemperature(obj.global_initial_temperature);
                    end
                end
            end
        end
        function FinishConstructModel(obj)
            obj.SetOutputHeatFlux;
            % 			obj.StatisticPlotTotalLosses;
        end
        %>@brief assign options to the components, similar to
        %>clLumpedParameterNetwork but adds the inital temperature
        function AssignGlobalOptions(obj)
            obj.AssignGlobalOptions@LPNSystem.clLumpedParameterNetwork;
            % 			if obj.UseSymbolicThermalParameter()
            % 				obj.ConvertInitialTemperatureToSymbolic();
            % 			end
            obj.SetComponentInitialTemperature;
        end
        %>@brief get output statistics for model reduction, get output
        %>@ temperatures of reduced model
        %>@ get error between reference model and reduced model,
        %>@ get boolean vector whether error is bigger than tolerance bound
        %>@param obj,cell_ref_output_temperature,cell_output_blocks,tol_bound
        function [cell_output_temperature,cell_temperature_error,bool_output_error] = GetOutputStatistics(obj,cell_ref_output_temperature,cell_output_blocks,tol_bound)
            bool_output_error = zeros(length(cell_output_blocks),1);
            cell_temperature_error = cell(length(cell_output_blocks),1);
            cell_output_temperature = cell(length(cell_output_blocks),1);
            cell_output_temperature_sync = cell(length(cell_output_blocks),1);
            cell_ref_output_temperature_sync = cell(length(cell_ref_output_temperature),1);
            % determine output error between model and reference model
            for index_output = 1:length(cell_output_blocks)
                % get output temperatures of reduced model
                ts_auxilliary = obj.GetSimulatedTemperature(cell_output_blocks{index_output});
                cell_output_temperature{index_output} = timeseries(ts_auxilliary.data(:),ts_auxilliary.time,'name',cell_output_blocks{index_output});
                % calculate error
                for index_ref_output = 1:length(cell_output_blocks)
                    if strcmp(cell_output_temperature{index_output}.name,cell_ref_output_temperature{index_ref_output}.name)
                        [cell_output_temperature_sync{index_output},cell_ref_output_temperature_sync{index_output}] = ...
                            synchronize(cell_output_temperature{index_output},cell_ref_output_temperature{index_ref_output},'Union');
                        cell_temperature_error{index_output} = cell_output_temperature_sync{index_output}.data-cell_ref_output_temperature_sync{index_output}.data;
                    end
                end
                % boolean variable if output difference is too large
                if max(abs(cell_temperature_error{index_output})) > tol_bound
                    bool_output_error(index_output) = 1;
                end
            end
        end
        %>@brief get a matrix with maximum temperature gradients, rows:
        %>@ components, columns: dimension
        function mat_max_gradients = GetMaxGradientMatrix(obj,simlog_variable)
            mat_max_gradients = zeros(length(obj.cell_obj_lptn_component),3);
            % go through every component and check for large gradients
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                    mat_max_gradients(index_component,:) = obj.cell_obj_lptn_component{index_component}.GetComponentMaxGradients(simlog_variable);
                end
            end
        end
        %>@brief go through every output block and find components which
        %>@ belong to output, set boolean variable for increasing
        %>@ discetrization
        %>@param obj,cell_output_blocks,bool_increase,bool_output_error,mat_max_gradients
        function bool_increase = FindMatchingComponentToOutput(obj,cell_output_blocks,bool_increase,bool_output_error,mat_max_gradients)
            for index_output = 1:length(cell_output_blocks)
                bool_component_output_difference  = zeros(length(obj.cell_obj_lptn_component),1);
                if bool_output_error(index_output)
                    for index_component = 1:length(obj.cell_obj_lptn_component)
                        if ~obj.cell_obj_lptn_component{index_component}.IsShapeless
                            if strcmp(cell_output_blocks(index_output),obj.cell_obj_lptn_component{index_component}.GetGlobalAverageTemperatureName) ...
                                    || strcmp(cell_output_blocks(index_output),obj.cell_obj_lptn_component{index_component}.GetNameHotspotTemperature)
                                bool_component_output_difference(index_component) = 1;
                            end
                        end
                    end
                    vec_index = find(bool_component_output_difference);
                    [~,comp] = max(max(mat_max_gradients(vec_index,:),[],2));
                    num_output_components = numel(vec_index);
                    if num_output_components == 1
                        [~,dim] = max(mat_max_gradients(vec_index,:));
                    else
                        [~,dim] = max(max(mat_max_gradients(vec_index,:)));
                    end
                    bool_increase(vec_index(comp),dim) = 1;
                end
            end
        end
    end
    methods(Access = private)
        %>@brief calculate total losses of all component
        % 		function StatisticPlotTotalLosses(obj)
        % 			str_inputs = '';
        % 			for index = 1:numel(obj.cell_obj_lptn_component)
        % 				if ~isempty(obj.cell_obj_lptn_component{index}.GetHeatFluxInput)
        % 					str_inputs = [str_inputs '+'];
        % 				end
        % 			end
        % % 			if obj.PlotTotalLosses
        % 				signal_sink = obj.AddOutputBlock(['total_losses_' obj.name_total_losses]);
        % 				%scope = obj.AddBlock(LPNEnum.enumSimulinkElement.scope,0);
        % 				%scope.SetBlockName(['scope_' obj.name_total_losses]);
        % 				obj.block_add_total_loss = obj.AddBlock(LPNEnum.enumSimulinkElement.add);
        % 				obj.block_add_total_loss.SetBlockName(['add_' obj.name_total_losses]);
        % 				obj.block_add_total_loss.SetParameter('Inputs',str_inputs);
        % 				obj.block_add_total_loss.SetPosition([600,600]);
        % 				obj.AddLine(obj.block_add_total_loss.GetOutport,signal_sink);
        % % 			end
        % 		end
        %>@brief read output_all_my_heat_flux option and set the relative
        %>connections to output the flux.
        function SetOutputHeatFlux(obj)
            for index_component = 1:length(obj.cell_obj_lptn_component)
                if obj.cell_obj_lptn_component{index_component}.IfOutputAllHeatFlux
                    for index = 1:length(obj.cell_obj_contacts)
                        obj.cell_obj_contacts{index}.SetOutputHeatFluxIfRelatedTo(obj.cell_obj_lptn_component{index_component});
                    end
                end
            end
        end
        %>@brief get output statistics for model reduction, get output
        %>@ temperatures of reduced model
        %>@ get error between reference model and reduced model,
        %>@ get boolean vector whether error is bigger than tolerance bound
        %>@param obj,cell_ref_output_temperature,cell_output_blocks,tol_bound
        %         function [cell_output_temperature,cell_temperature_error,bool_output_error] = GetOutputStatistics(obj,cell_ref_output_temperature,cell_output_blocks,tol_bound)
        %                bool_output_error = zeros(length(cell_output_blocks),1);
        %                cell_temperature_error = cell(length(cell_output_blocks),1);
        %                cell_output_temperature = cell(length(cell_output_blocks),1);
        %                cell_output_temperature_sync = cell(length(cell_output_blocks),1);
        %                cell_ref_output_temperature_sync = cell(length(cell_ref_output_temperature),1);
        %                % determine output error between model and reference model
        %                for index_output = 1:length(cell_output_blocks)
        %                    % get output temperatures of reduced model
        %                    ts_auxilliary = obj.GetSimulatedTemperature(cell_output_blocks{index_output});
        %                    cell_output_temperature{index_output} = timeseries(ts_auxilliary.data(:),ts_auxilliary.time,'name',cell_output_blocks{index_output});
        %                    % calculate error
        %                    for index_ref_output = 1:length(cell_output_blocks)
        %                        if strcmp(cell_output_temperature{index_output}.name,cell_ref_output_temperature{index_ref_output}.name)
        %                             [cell_output_temperature_sync{index_output},cell_ref_output_temperature_sync{index_output}] = ...
        %                                 synchronize(cell_output_temperature{index_output},cell_ref_output_temperature{index_ref_output},'Union');
        %                             cell_temperature_error{index_output} = cell_output_temperature_sync{index_output}.data-cell_ref_output_temperature_sync{index_output}.data;
        %                        end
        %                    end
        %                    % boolean variable if output difference is too large
        %                    if max(abs(cell_temperature_error{index_output})) > tol_bound
        %                        bool_output_error(index_output) = 1;
        %                    end
        %                end
        %         end
    end
    methods%methods visualizer
        %>@brief give all information to visualizer
        function my_visualizer = NewVisualizer(obj)
            obj.my_visualizer = LPNVisualizer.clNetworkVisualizer();
            obj.my_visualizer.SetName(obj.GetHostName())
            obj.my_visualizer.SetObjLPTN(obj);
            %% todo:put these function in SetObjLPTN
            obj.my_visualizer.SetAllComponents(obj.cell_obj_lptn_component);
            obj.my_visualizer.SetMeasuringPoints(obj.cell_obj_measuring_point);
            obj.my_visualizer.SetContacts(obj.cell_obj_contacts);
            obj.my_visualizer.SetSimscapeLogName(obj.GetSimscapeLogName);
            %% todo:put these function in SetObjLPTN
            my_visualizer = obj.my_visualizer;
        end
        %>@brief get current visualizer
        function my_visualizer = GetCurrentVisualizer(obj)
            if isempty(obj.my_visualizer)
                my_visualizer = obj.NewVisualizer;
            else
                my_visualizer = obj.my_visualizer;
            end
        end
        %>@brief draws components, each in a separate window
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        function VisualizeComponentsSingle(obj, cell_str_component_name, varargin)
            obj.VisualizeComponents('single', cell_str_component_name, varargin{:})
        end
        %>@brief draws components in one common window
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        function VisualizeComponentsMerged(obj, cell_str_component_name, varargin)
            obj.VisualizeComponents('merged', cell_str_component_name, varargin{:})
        end
        %>@brief draws components in one common or a seperated window in 3D
        %>@param option 'single' or 'merged' are valid
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        %>@todo:because of the bad input parameter list, this function
        %>should not be used any more. A parameter pair list may be good.
        function VisualizeComponents(obj, option, cell_str_component_name, varargin)
            % 			p = inputParser;
            % 			p.addParamValue('Time',1);
            % 			p.addParamValue('ColorRange','auto');
            % 			p.addParamValue('Resolution',1);
            % 			p.parse(varargin{:});
            % 			res = p.Results;
            visualizer = GetCurrentVisualizer(obj);
            visualizer.SetComponentsForVisualizing(cell_str_component_name);
            
            % 			if nargin > 3
            visualizer.SetGraphResolution(0.01);
            % 			end
            % 			if nargin > 4
            visualizer.SetTime(4500);
            % 			end
            % 			if nargin > 5
            %			visualizer.SetColorRange([20,77]);
            % 			end
            if strcmp(option,'single')
                visualizer.VisualizeSingleComponents(1,0);
            else
                visualizer.VisualizeMergedComponents(1,0);
            end
            set(gcf,'Renderer','painters')
        end
        %>@brief draws the component shapes in one common window
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        function VisualizeComponentShapes(obj, cell_str_component_name)
            visualizer = GetCurrentVisualizer(obj);
            visualizer.SetComponentsForVisualizing(cell_str_component_name);
            visualizer.VisualizeMergedComponents(3);
        end
        %>@brief plots components, each in a separate window
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        function PlotComponentsSingle(obj, cell_str_component_name, varargin)
            obj.PlotComponents('single', cell_str_component_name, varargin{:})
        end
        %>@brief plots components in one common window
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        function PlotComponentsMerged(obj, cell_str_component_name, varargin)
            obj.PlotComponents('merged', cell_str_component_name, varargin{:})
        end
        %>@brief plots components in one common or a seperated window in 2D
        %>@param option 'single' or 'merged' are valid
        %>@param cell_str_component_name a string or a cell array of
        %>strings containing the component names
        %>@todo:because of the bad input parameter list, this function
        %>should not be used any more. A parameter pair list may be good.
        function PlotComponents(obj, option, cell_str_component_name, varargin)
            visualizer = GetCurrentVisualizer(obj);
            visualizer.SetComponentsForVisualizing(cell_str_component_name);
            if nargin > 3
                visualizer.SetGraphResolution(varargin{1});
            end
            if nargin > 4
                visualizer.SetTime(varargin{2});
            end
            if nargin > 7
                visualizer.SetSlices(varargin{3},varargin{4},varargin{5})
            end
            if nargin > 8
                visualizer.SetColorRange(varargin{6});
            end
            if strcmp(option,'single')
                visualizer.VisualizeSingleComponents(2);
            else
                visualizer.VisualizeMergedComponents(2);
            end
            set(gcf,'Renderer','painters')
        end
    end
end