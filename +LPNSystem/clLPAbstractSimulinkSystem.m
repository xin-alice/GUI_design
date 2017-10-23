%>@class clLPAbstractSimulinkSystem
%>@brief this is a clAbstractSimulinkSystem with input,output interface.
classdef clLPAbstractSimulinkSystem < LPNSystem.clAbstractSimulinkSystem & LPNUtilities.clLumpedParameterNetworkOption
    methods
        %add input before <port_after_input>, if block <str_name> doesn't
        %exist. Otherwise just link the input to <port_after_input>
        function [outport,block_source] = AddGlobalInputBlocksBefore(obj,port_after_input,str_name,input_value,varargin)%varargin is put_into_subsystem
            block_source = obj.GetCurrentLPTN().GetGlobalBlock(str_name);
			if isempty(block_source)
                [outport,block_source] = obj.AddInputBlocksBefore(port_after_input,str_name,input_value,varargin{:});
                obj.GetCurrentLPTN().RegistGlobalBlock(block_source);
            else
                try 
                    obj.AddLine(block_source.GetOutport(),port_after_input);
                    outport = block_source.GetOutport;
                catch 
                    obj.AddLine(block_source.GetPortRight,port_after_input);
                    outport = block_source.GetPortRight;
                end
            end
        end
    end
    methods(Access = protected)
        %>@brief depending on matlab version and whether the parameter should be
        %>tunable, set parameter of the simscape element, or add a input
        %>block before the inport
        %>before matlab 2016a, simscape parameter are not run-time tunable.
        %>workaround has been used to put the parameter in a constant and
        %>connect it as a input.
        function AddTunableSimscapeParameter(obj,obj_simulink_element,name,num_or_sym,expand_number_squared,str_struct,use_symbolic,port_left_id,global_input_name)
            try
                obj_simulink_element.SetParameterNumSymDependent(name,num_or_sym,expand_number_squared,str_struct,use_symbolic)
            catch%if verLessThan('matlab', 'R2017a')%connect to a constant to add a tunable parameter as workaround for old version
                if nargin == 9%create a global input 
                    obj.AddGlobalInputBlocksBefore(obj_simulink_element.GetPortLeft(port_left_id),global_input_name,num_or_sym);
                else
                    obj.AddInputBlocksBefore(obj_simulink_element.GetPortLeft(port_left_id),[],num_or_sym,1);
                end
                % fqi:201606:it is not efficient to use run time parameter of simscape
           % else%set the parameter to be tunable
            %    obj_simulink_element.SetParameterNumSymDependent(name,num_or_sym,expand_number_squared,str_struct,use_symbolic)
           %     obj_simulink_element.SetParameter([name '_conf'],'runtime');
            end
        end
        function [inport,output_block]= AddGlobalAverageOutput(obj)
            %fqi:adjust output block type using function AddOutputBlock
            [block_add,add_exists] = obj.GetCurrentLPTN().AddGlobalBlock([obj.GetGlobalAverageTemperatureName() '_add'],LPNEnum.enumSimulinkElement.add,1);
			%block_add = obj.GetEnvironment().GetGlobalBlock([obj.GetGlobalAverageTemperatureName() '_add']);
            %if ~output_exists && ~add_exists
            if ~add_exists
                [signal_sink,output_block] = obj.AddOutputBlock(obj.GetGlobalAverageTemperatureName());
                obj.AddLine(block_add.GetOutport(),signal_sink);
                block_add.SetParameter('Inputs','+');
                num = 1;
            else
                % the global block should already exist
                output_block = obj.GetCurrentLPTN().GetGlobalBlock(obj.GetGlobalAverageTemperatureName());
                str = block_add.GetParameter('Inputs');
                num = length(str)+1;
                block_add.SetParameter('Inputs',[str '+']);
            end
            %>@todo GetComponentAverageOutputGain is a function of
            %>clLPThermalComponent. This function should not be called in
            %>its super class. 
            [inport_gain,outport_gain,block_gain] = obj.AddGainBlockBefore(block_add.GetInport(num),obj.GetComponentAverageOutputGain,1);
            
            inport = inport_gain;
        end
        
        function [port_inport_converter,obj_converter] = AddSimulinkPSConverter(obj,port_after_converter)
            obj_converter = obj.AddBlock(LPNEnum.enumSimulinkElement.simulink_PS_converter,1);
            if iscell(port_after_converter)
                for index = 1:numel(port_after_converter)
                    obj.AddLine(obj_converter.GetPortRight,port_after_converter{index});
                end
            else
                obj.AddLine(obj_converter.GetPortRight,port_after_converter);
            end
            port_inport_converter = obj_converter.GetInport;
        end
        
        function handle_demux_inport = AddDemuxBefore(obj,cell_str_outport)
            if numel(cell_str_outport) == 1
                handle_demux_inport = cell_str_outport{1};
            else
                demux = obj.AddBlock(LPNEnum.enumSimulinkElement.demux);
                demux.SetParameter('Outputs',num2str(numel(cell_str_outport)));
                for index = 1:numel(cell_str_outport)
                    obj.AddLine(demux.GetOutport(index),cell_str_outport{index});
                end
                handle_demux_inport = demux.GetInport;
            end
        end
        
        function obj_product = AddProductBlockBefore(obj,port_after_product,in_subsystem)
            if nargin == 2
                in_subsystem = 0;
            end
            obj_product = obj.AddBlock(LPNEnum.enumSimulinkElement.product,in_subsystem);
            obj.AddLine(obj_product.GetOutport,port_after_product);
        end
        
        function obj_divide = AddDivideBlockBefore(obj,port_after_divide,in_subsystem)
            if nargin == 2
                in_subsystem = 0;
            end
            obj_divide = obj.AddProductBlockBefore(port_after_divide,in_subsystem);
            obj_divide.SetParameter('Inputs','*/');
        end
        
        %>@brief add rate transition before port_after_transition
        function port_before_transition = AddRateTransitionBlockBefore(obj,port_after_transition)
            %add rate transition between input and subsystem
            rate_transition = obj.AddBlock(LPNEnum.enumSimulinkElement.rate_transition,0);
            obj.AddLine(rate_transition.GetOutport,port_after_transition);
            port_before_transition = rate_transition.GetInport;
        end
        %>@brief add gain block before port_after_gain with the specified gain
        %>value
        function [inport_gain,outport_gain,block_gain] = AddGainBlockBefore(obj,port_after_gain,gain,in_subsystem)
            if nargin == 3
                in_subsystem = 0;
            end
            block_gain = obj.AddBlock(LPNEnum.enumSimulinkElement.gain,in_subsystem);
            obj.AddLine(block_gain.GetOutport,port_after_gain);
            block_gain.SetParameterNumSymDependent('Gain',gain,obj.ExpandNumberSquared,obj.GetNameDataStruct,obj.UseSymbolicThermalParameter);
            inport_gain = block_gain.GetInport;
            outport_gain = block_gain.GetOutport;
        end
        %>@brief add step function before
        function [inport_step,outport_step] = AddStepBlockBefore(obj,port_after_step)
            block_step = obj.GetCurrentLPTN.AddGlobalBlock('global_step',LPNEnum.enumSimulinkElement.step,0);
            block_product = obj.AddBlock(LPNEnum.enumSimulinkElement.product,0);
            obj.AddLine(block_step.GetOutport,block_product.GetInport(2));
            obj.AddLine(block_product.GetOutport,port_after_step);
            inport_step = block_product.GetInport(1);
            outport_step = block_product.GetOutport;
        end
        %>@brief add Fcn block before
        function block_fcn = AddFcnBlockBefore(obj,port_after_fcn,put_into_subsystem)
            if nargin == 2
                put_into_subsystem = 0;
            end
            block_fcn = obj.AddBlock(LPNEnum.enumSimulinkElement.fcn,put_into_subsystem);
            obj.AddLine(block_fcn.GetOutport,port_after_fcn);
%             inport_fcn = block_fcn.GetInport;
        end
        %>@brief add step function before
        %>@todo merge with similar AddStepBlockBefore function
        function [inport_pulse,outport_pulse] = AddPulseBlockBefore(obj,port_after_pulse)
            block_step = obj.GetCurrentLPTN.AddGlobalBlock('global_pulse',LPNEnum.enumSimulinkElement.pulse,0);
            block_product = obj.AddBlock(LPNEnum.enumSimulinkElement.product,0);
            obj.AddLine(block_step.GetOutport,block_product.GetInport(2));
            obj.AddLine(block_product.GetOutport,port_after_pulse);
            inport_pulse = block_product.GetInport(1);
            outport_pulse = block_product.GetOutport;
        end
        %>@brief add a output block and return the handle of the input
        %>port.
        function [str_port_id,obj_output] = AddOutputBlock(obj,str_output_name)
            switch obj.GetEnumOutput
                case LPNEnum.enumLPNBuilderOption.output_as_display
                    obj_output = obj.AddBlock(LPNEnum.enumSimulinkElement.to_display,0);
                    obj_output.SetSimulinkElementSize(100,20);
                case LPNEnum.enumLPNBuilderOption.output_as_port
                    obj_output(1) = obj.AddBlock(LPNEnum.enumSimulinkElement.outport,0);
                    %                     str_index_port = obj_output(1).GetParameter('Port');
                    %                     obj
                    %                     disp(str_index_port);
                case LPNEnum.enumLPNBuilderOption.output_as_scope
                    obj_output = obj.AddBlock(LPNEnum.enumSimulinkElement.scope,0);
                    obj_output.SetParameter('SaveToWorkspace','on');
                    obj_output.SetParameter('SaveName',str_output_name);
                    obj_output.SetParameter('DataFormat','StructureWithTime');
                    obj_output.SetParameter('LimitDataPoints','off');
                case LPNEnum.enumLPNBuilderOption.output_as_to_file
                    obj_output = obj.AddBlock(LPNEnum.enumSimulinkElement.to_file,0);
                case LPNEnum.enumLPNBuilderOption.output_as_to_workspace
                    obj_output = obj.AddBlock(LPNEnum.enumSimulinkElement.to_workspace,0);
                    %the name can not be too long
                    obj_output.SetParameter('VariableName',str_output_name);
                    obj_output.SetParameter('SaveFormat','Timeseries');
                otherwise
                    obj_output = obj.AddBlock(LPNEnum.enumSimulinkElement.outport,0);
            end
            %                    str_index_port = obj_output(1).GetParameter('Port');
            %                     obj
            %                     disp(str_index_port);
%             if length(obj_output) > 1
%                 warning('obj_output have more object. why is this happend?');
%             end
            obj_output(1).SetBlockName(str_output_name);
            str_port_id = obj_output.GetInport();
%             for index = 1:length(obj_output)
%                 str_port_id{index} = obj_output(index).GetInport();
%             end
        end
        function port_simscape_sum = AddSimscapeAddBlock(obj,cell_str_outport)
            if numel(cell_str_outport) == 0
                port_simscape_sum = [];
                return;
            end
            if numel(cell_str_outport) == 1
                port_simscape_sum = cell_str_outport{1};
                return;
            end
            assert(numel(cell_str_outport)<6,'simscape_add with more ports must be implemented');
            obj_add = obj.AddBlock(eval(['LPNEnum.enumSimulinkElement.simscape_add' num2str(numel(cell_str_outport))]));
			for index = 1:numel(cell_str_outport)
                obj.AddLine(cell_str_outport{index},obj_add.GetPortLeft(index));
            end
            port_simscape_sum = obj_add.GetPortRight;
        end
        %>@brief create a average outport of all the outport in
        %>vec_str_outport and return the obj_simulink_outport
        function CreateSumOutput(obj,cell_str_outport,str_output_name)
            cell_str_output_port = obj.AddOutputBlock(str_output_name);
            if numel(cell_str_outport)> 1
                obj_add = obj.AddBlock(LPNEnum.enumSimulinkElement.sum);
                obj_add.SetParameter('Inputs',num2str(numel(cell_str_outport)));
                obj.AddLine(obj_add.GetOutport(), cell_str_output_port);
                for index = 1:length(cell_str_outport)
                    obj.AddLine(cell_str_outport{index},obj_add.GetInport(index));
                end
            else
                obj.AddLine(cell_str_outport,cell_str_output_port);
            end
        end
        %>@brief create a mux outport of all the outport in
        %>vec_str_outport and return the obj_simulink_outport
        function CreateMuxOutput(obj,cell_str_outport,str_output_name)
            str_port = obj.AddOutputBlock(str_output_name);
            obj.AddMuxBlockBetween(cell_str_outport,str_port);
        end
        
        function AddMuxBlockBetween(obj,cell_str_inport,str_outport,mux_in_root_system)
            if nargin < 4
                mux_in_root_system = 1;
            end
            obj_mux = obj.AddBlock(LPNEnum.enumSimulinkElement.mux,mux_in_root_system);
            obj_mux.SetParameter('Inputs',num2str(numel(cell_str_inport)));
            obj_mux.SetPosition([700,200]);
            obj.AddLine(obj_mux.GetOutport(), str_outport);
            for index = 1:length(cell_str_inport)
                obj.AddLine(cell_str_inport{index},obj_mux.GetInport(index));
            end
        end
        %add mux after several signal in cell_str_outport and mutiply with
        %gain
        function [str_port,output_block] = CreateMuxGainOutput(obj,cell_str_outport,vec_gain,str_output_name)
            if isempty(obj.GetGlobalAverageTemperatureName())
                [str_port,output_block] = obj.AddOutputBlock(str_output_name);
            else
                [str_port,output_block] = obj.AddGlobalAverageOutput();
            end
            [inport_gain,outport_gain,block_gain] = obj.AddGainBlockBefore(str_port,vec_gain',1);
            block_gain.SetParameter('Multiplication','Matrix(u*K)');
            block_gain.SetPosition([800,200]);
            obj.AddMuxBlockBetween(cell_str_outport,inport_gain);
        end
        %>@brief create a maximum outport of all the outport in
        %>cell_str_outport and return the obj_simulink_outport
        function obj_output_block = CreateMaximumOutput(obj,cell_str_outport,str_output_name)
            [str_port,obj_output_block] = obj.AddOutputBlock(str_output_name);
            obj_minmax = obj.AddBlock(LPNEnum.enumSimulinkElement.minmax);
            obj_minmax.SetParameter('Function','max');
            obj_minmax.SetParameter('Inputs',num2str(numel(cell_str_outport)));
            obj_minmax.SetPosition([800,500]);
            obj_output_block.SetPosition([850,500]);
            obj.AddLine(obj_minmax.GetOutport(), str_port);
            
            for index = 1:length(cell_str_outport)
                obj.AddLine(cell_str_outport{index},obj_minmax.GetInport(index));
            end
        end
                
		%>@brief add a voltage sensor
		%>@param simscape_node the node, whose voltage will be messured.
		%>@retval handle_simulink_voltage_output the port handle of the
		%>voltage output.
		%>@retval handle_simscape_voltage_output the port handle of the
		%>voltage output.
		%>@retval obj_converter return obj converter for signal tracking in
		%>clMeasuringPoint
		function [handle_simulink_voltage_output,handle_simscape_voltage_output,obj_sensor,obj_converter] = AddVoltageSensor(obj,simscape_node,add_converter_voltage_sensor)
			if nargin == 2
				add_converter_voltage_sensor = 1;
			end
			obj_sensor = LPNElement.clSimulinkElement(LPNEnum.enumSimulinkElement.voltage_sensor);
			obj.AddBlock(obj_sensor);
			obj_sensor.SetPosition([550,250]);
			obj.AddLine(simscape_node,obj_sensor.GetPortLeft);
			%to add eletrical reference and set its position
			reference = obj.AddBlock(LPNEnum.enumSimulinkElement.electrical_reference);
			reference.SetPosition([560,300]);
			obj.AddLine(obj_sensor.GetPortRight(2),reference.GetPortLeft);
			%to add PS converter in Simulink and set its position
			handle_simscape_voltage_output = obj_sensor.GetPortRight(1);
			%@todo:converter added in AddLine
			if add_converter_voltage_sensor == 1
				[handle_simulink_voltage_output,obj_converter] = obj.AddSimscapeSimulinkConverter(obj_sensor.GetPortRight(1));
				obj_converter.SetPosition([600,350]);
			else
				handle_simulink_voltage_output = [];
			end
		end
		%>@brief add current sensor before handle_current_sensor_minus_port
		%>return the sensor output and the plus port of current sensor
		function [handle_simulink_current_sensor_output,handle_current_sensor_plus_port,handle_simscape_current_sensor_output] = AddCurrentSensor(obj,handle_current_sensor_minus_port,add_converter_current_sensor)
			if nargin == 2
				add_converter_current_sensor = 1;
			end
			sensor = obj.AddBlock(LPNEnum.enumSimulinkElement.current_sensor);
			obj.AddLine(handle_current_sensor_minus_port,sensor.GetPortLeft);
			handle_current_sensor_plus_port = sensor.GetPortRight(2);
			handle_simscape_current_sensor_output = sensor.GetPortRight(1);
			%to add PS converter in Simulink and set its position
			%@todo:converter added in AddLine
			if add_converter_current_sensor == 1
				handle_simulink_current_sensor_output = obj.AddSimscapeSimulinkConverter(sensor.GetPortRight(1));
			else
				handle_simulink_current_sensor_output = [];
			end
        end
        %>@brief init the several block as input
        %>@retval block_before_transition the block before transition
        %>@retval block_after_transition the block after transition
        function [outport,block_source] = AddInputBlocksBefore(obj,port_after_input,str_name_input,input_value,put_into_subsystem)
            if nargin < 5
                put_into_subsystem = 0;
            end
            block_source = obj.CreateInputSource(input_value,str_name_input,put_into_subsystem);
            %%decide the block source type
            obj.AddLine(block_source.GetOutport,port_after_input);
            outport = block_source.GetOutport;
        end
	end
    methods(Access = private)
        %>add 2d lookup table or constant or inport or 1d lookup table of time  
        function block_source = CreateInputSource(obj,input_value,str_name_input,put_into_subsystem)
            block_source = obj.GetCurrentLPTN.GetGlobalBlock(str_name_input);
            if ~isempty(block_source)
                return;
            elseif isa(input_value,'MotorInputs.cl2DLookupTable')
                block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.lookup_table_2D,put_into_subsystem);
                block_source.SetParameter('BreakpointsForDimension1',input_value.str_breakpoints1);
                block_source.SetParameter('BreakpointsForDimension2',input_value.str_breakpoints2);
                block_source.SetParameter('Table',input_value.str_table_data);
                cell_name_inputs = input_value.GetNameInputs;
                obj.AddGlobalInputBlocksBefore(block_source.GetInport,cell_name_inputs{1},input_value.GetFunctionProperty(cell_name_inputs{1}));
                obj.AddGlobalInputBlocksBefore(block_source.GetInport(2),cell_name_inputs{2},input_value.GetFunctionProperty(cell_name_inputs{2}));
            elseif isa(input_value,'LPNUtilities.clInputFunction')
%                 cell_inputs = input_value.GetInputsForSimulink;
                cell_name_inputs = input_value.GetNameInputs;
                %cell_lookup_table_outport = cell(size(cell_name_inputs));
                %% add input needed in function block or custom block 
                for index = 1:numel(cell_name_inputs)
                    input_block = obj.GetCurrentLPTN.GetGlobalBlock(cell_name_inputs{index});
                    [current_input_value,is_parameter] = input_value.GetFunctionProperty(cell_name_inputs{index});
                    %
                    if isa(input_value,'LPNUtilities.clVariableContactFilmCoefficient')&&obj.PutVariableParameterInSubsystem
                        put_into_subsystem = 1;
                    else
                        put_into_subsystem = is_parameter;
                    end
                    if isempty(input_block)&&~isempty(current_input_value)
                        input_block = obj.CreateInputSource(current_input_value,cell_name_inputs{index},put_into_subsystem);
                        obj.GetCurrentLPTN.RegistGlobalBlock(input_block);
                    end 
                    if ~isempty(input_block)%not defined input will leave a open simscape port
                        cell_lookup_table_outport{index} = input_block.GetOutport;
                    end
                end
                %% 
                if isempty(cell_name_inputs)
                    block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.constant);
                    block_source.SetParameterNumSymDependent('Value',input_value.GetInputFunctionForSimulink,obj.ExpandNumberSquared,obj.GetNameDataStruct);
%                     obj.AddLine(block_source.GetOutport,port_after_input);
%                     outport = block_source.GetOutport;
                else%if isempty(input_value.GetSSCBlockID)
                    %% using function block from simulink
                    block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.fcn,put_into_subsystem);
%                     obj.AddLine(block_source.GetOutport,port_after_input);
%                     block_source = obj.AddFcnBlockBefore(port_after_input,put_into_subsystem);
                    block_source.SetParameterNumSymDependent('Expr', input_value.GetInputFunctionForSimulink ,obj.ExpandNumberSquared,obj.GetNameDataStruct,obj.UseSymbolicThermalParameter);
                    %% link input with the function block or custom block
                    if numel(cell_name_inputs) > 1
                        obj.AddMuxBlockBetween(cell_lookup_table_outport,block_source.GetInport,put_into_subsystem);
                    else
                        obj.AddLine(cell_lookup_table_outport{1},block_source.GetInport);
                    end
%                     outport = block_source.GetOutport;
                end
                block_source.SetBlockName(str_name_input);
            elseif ~iscell(input_value)&&...
                    length(input_value) == 1
                if isnan(input_value)
                    block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.inport,put_into_subsystem);
                else
                    block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.constant,put_into_subsystem);
                    block_source.SetParameterNumSymDependent('Value',input_value,obj.ExpandNumberSquared,obj.GetNameDataStruct);
                end
            else%lookup table of time
                block_clock = obj.GetCurrentLPTN.AddGlobalBlock('global_clock',LPNEnum.enumSimulinkElement.clock,put_into_subsystem);
                block_source = obj.AddBlock(LPNEnum.enumSimulinkElement.lookup_table_1D,put_into_subsystem);
%                 try
                    obj.AddLine(block_clock.GetOutport,block_source.GetInport);
                    %existing table should been already connected to the
                    %clock
%                 end
                if iscell(input_value)%{'time','temperature'}
                    str_time = input_value{1};
                    str_value = input_value{2};
                    assert(ischar(str_time));
                    assert(ischar(str_value));
                    block_source.SetParameter('BreakpointsForDimension1',str_time);
                    block_source.SetParameter('Table',str_value);
                else
                    if isnumeric(input_value)
                        input_value = mytools.ReshapeSignal(input_value);
                        vec_time = input_value(:,1)';
                        vec_value = input_value(:,2)';
                    elseif isa(input_value,'timeseries')
                        vec_time = input_value.Time';
                        vec_value = squeeze(input_value.Data)';
                    else
                        warning('unknown input for table');
                    end
                    %leave out nan and inf in the signal
                    block_source.SetParameterNumSymDependent('BreakpointsForDimension1',vec_time(isfinite(vec_value)),obj.ExpandNumberSquared,obj.GetNameDataStruct);
                    block_source.SetParameterNumSymDependent('Table',vec_value(isfinite(vec_value)),obj.ExpandNumberSquared,obj.GetNameDataStruct);
                end
                
                block_source.SetParameter('ExtrapMethod','clip');
                block_source.SetParameter('UseLastTableValue','on');
            end
            if ~isempty(str_name_input)
                block_source.SetBlockName(str_name_input);
            end
        end

        %>add a simscape -> simulink converter
        function [handle_simulink_port,obj_converter] = AddSimscapeSimulinkConverter(obj,handle_simscape_port)
            obj_converter = obj.AddBlock(LPNEnum.enumSimulinkElement.PS_simulink_converter);
            obj.AddLine(handle_simscape_port,obj_converter.GetPortLeft);
            handle_simulink_port = obj_converter.GetOutport();
        end
    end
end