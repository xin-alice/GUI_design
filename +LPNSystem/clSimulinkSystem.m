%>@brief clSimulinkSystem is a simulink subsystem containing other simulinkelement
classdef clSimulinkSystem < LPNElement.clSimulinkElement
	properties
		cell_global_block = {};
	end
	methods(Hidden = true)
        function Reset(obj)
            obj.cell_global_block = {};
        end
		%>@brief to create a subsystem
        %>@param LPNEnum.enumSimulinkElement.subsystem
		function obj = clSimulinkSystem
 			obj@LPNElement.clSimulinkElement(LPNEnum.enumSimulinkElement.subsystem);
		end
		%>@brief create a global block or find a global block, which is
		%>already defined.
		%>@param enum_block_type type of the block, see
		%>enumSimulinkBuildInElement or LPNEnum.enumSimulinkElement
		%>@param str_ID the unique name of the block.
		%>@param in_subsystem boolean variable indicating if the block will
		%>be put in the subsystem (true) or not (false)
		%>@retval block handle to the block
		%>@retval exists boolean variable indicating if the block existed
		%>before (true) or if it was created during this function call
		%>(false)
		function RegistGlobalBlock(obj,obj_block)
            if ~isempty(obj.GetGlobalBlock(obj_block.GetLocalName))
                error(['global block' obj_block.GetLocalName 'already exist']);
            end
            obj.cell_global_block{end+1} = obj_block;
        end
        %add a block in global block
        function [obj_block,exist] = AddGlobalBlock(obj,str_ID,enum_block_type,in_subsystem)
            obj_block = obj.GetGlobalBlock(str_ID);
            if isempty(obj_block)
                obj_block = obj.AddBlock(enum_block_type, in_subsystem);
                obj_block.SetBlockName(str_ID);
                obj.RegistGlobalBlock(obj_block);
                exist = 0;
            else
                assert(strcmp(char(enum_block_type),char(obj_block.GetBlockEnumType)));
                exist = 1;
            end
        end
        %check if a global block with name <str_block_name> exists.
        function obj_block = GetGlobalBlock(obj,str_block_name)
            obj_block = [];
            for index = 1:length(obj.cell_global_block)
                if strcmp(obj.cell_global_block{index}.GetLocalName,str_block_name)
                    obj_block = obj.cell_global_block{index};
                    break;
                end
            end
        end
        %>delete line between two port
		function DeleteLine(obj,obj_port_handle1,obj_port_handle2)
			delete_line(obj.GetBlockID,obj_port_handle1,obj_port_handle2);
        end
        
        %>@brief to add block in this subsystem
        %>@param enum_or_obj
        %>@param str_new_name
        %>@param obj
        %>@retval obj_element
		function obj_element = AddBlock(obj,enum_or_obj)
			if isa(enum_or_obj,'LPNEnum.enumSimulinkElement')%||isa(enum_or_obj,'LPNEnum.enumSimulinkElement')
				obj_element = LPNElement.clSimulinkElement(enum_or_obj);
			else
				obj_element = enum_or_obj;
			end
			obj_element.Build(obj);
			%obj_element.TakeOverOptions(obj);
% 			persistent 
% 			set_param(obj_element,'Position',[50,100,400,250]);
% 			if nargin == 3
% 				obj_element.SetBlockName(str_new_name);
% 			end
		end
		%>@brief to add line in the simulink system. 
        %>@param obj_port_handle1
        %>@param cell_obj_port_handle2
        %            obj_converter = obj.AddBlock(LPNEnum.enumSimulinkElement.simulink_PS_converter,1);
%             if iscell(port_after_converter)
%                 for index = 1:numel(port_after_converter)
%                     obj.AddLine(obj_converter.GetPortRight,port_after_converter{index});
%                 end
%             else
%                 obj.AddLine(obj_converter.GetPortRight,port_after_converter);
%             end
%             port_inport_converter = obj_converter.GetInport;
		function nr_lines = AddLine(obj,obj_port_handle1,cell_obj_port_handle2)
            
            
			assert(~isempty(obj_port_handle1));
			assert(~isempty(cell_obj_port_handle2));
			nr_lines = 0;
			if ~iscell(cell_obj_port_handle2)
				cell_obj_port_handle2 = {cell_obj_port_handle2};
            end
            str_type1 = get_param(obj_port_handle1,'PortType');
            str_type2 = get_param(cell_obj_port_handle2{1},'PortType');
            pos_handle1 = get_param(obj_port_handle1,'Position');
            if strcmp(str_type1,'outport') && strcmp(str_type2,'connection')
                obj_converter = obj.AddBlock(LPNEnum.enumSimulinkElement.simulink_PS_converter,1);
                obj_converter.SetPosition([pos_handle1(1)+20,pos_handle1(1)]);
                obj.AddLine(obj_port_handle1,obj_converter.GetInport);
                obj_port_handle1 = obj_converter.GetPortRight;
            elseif strcmp(str_type1,'connection') && strcmp(str_type2,'inport')
                obj_converter = obj.AddBlock(LPNEnum.enumSimulinkElement.PS_simulink_converter,1);
                obj_converter.SetPosition([pos_handle1(1)+20,pos_handle1(1)]);
                obj.AddLine(obj_port_handle1,obj_converter.GetPortLeft);
                obj_port_handle1 = obj_converter.GetOutport;
            end
            
			for index = 1:numel(cell_obj_port_handle2)
				obj_port_handle2 = cell_obj_port_handle2{index};
                
				try
					add_line(obj.GetBlockID,obj_port_handle1,obj_port_handle2,'autorouting','off');%,'AUTOROUTING','ON');
                    nr_lines = nr_lines + 1;
				catch ME
					% two point may already connected. This happens in
					% selectric. 6 stator yoke head to head conncted. endcap 1
					% and endcap 6 don't need to be connected because if 1-2
					% 2-3 3-4 4-5 5-6 already connected, 1 and 6 is also
					% connceted.
					%warning('AddLineSecondAlreadyConnected');
					if strcmp(ME.identifier,'Simulink:Commands:AddLineSecondAlreadyConnected')
						warning(ME.identifier,'AddLineSecondAlreadyConnected');
					else
						error(['Lines not connected.' ME.identifier ':'  ME.message]);
					end
				end
			end
		end
	end
	methods
		function OpenSystemInSimulink(obj,str_system_name)
			obj.ResetSystemAndBlockNames('',str_system_name);
			display('Starting Simulink...');
            try
                obj.SetSimulationParameter('FastRestart','off');
            end
			close_system(str_system_name,0);
			load_system('simscape');
			load_system('fl_lib');
			load_system('nesl_utility');
			load_system('SimscapeCustomBlocks_lib');
			handle = new_system(str_system_name);
			obj.SetBlockHandle(handle);
 			open_system(str_system_name);
		end

    end
end