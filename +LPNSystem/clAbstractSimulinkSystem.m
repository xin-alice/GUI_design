%>@class clAbstractSimulinkSystem
%>@brief an abstract group of elements that can be put together in a
%>subsystem.
classdef clAbstractSimulinkSystem < LPNSystem.clSimulinkSystem
	properties(Access = private)
		%>all its element would save here
		cell_obj_element = {};
        %>the element that should stay outside this subsystem, not in this
        %>system
		cell_obj_root_element = {};
		%>save the subsystem, who give there child element to this
		%subsystem
		cell_obj_virtuall_child_subsystem = {};
		%>option, if the cell_obj_element{index should put into subsystem}
		obj_environment
    end
	methods(Hidden)
        function Reset(obj)
            obj.Reset@LPNSystem.clSimulinkSystem;
            obj.cell_obj_element = {};
            obj.cell_obj_root_element = {};
            obj.cell_obj_virtuall_child_subsystem = {};
        end
		%> set the simulink system, in which the simulink system will be
		%> built.
		function SetEnvironment(obj,obj_simulink_system)
			obj.obj_environment = obj_simulink_system;
			obj.ResetSystemAndBlockNames(obj_simulink_system.GetHostName,obj_simulink_system.GetLocalName);
		end
		function obj_environment = GetEnvironment(obj)
			obj_environment = obj.obj_environment;
		end
		%> register element in simulink system, so that all the component
		%>can be put into a subsystem
		function simulink_element = AddBlock(obj,obj_element,put_into_subsystem)
			if nargin == 2
				put_into_subsystem = 1;
			end
			simulink_element = obj.AddBlock@LPNSystem.clSimulinkSystem(obj_element);
			if ~put_into_subsystem
				simulink_element.SetToRootSystemElement;
				obj.cell_obj_root_element{end+1} = simulink_element;
			end
 			obj.cell_obj_element{end+1} = simulink_element;
% 			obj.vec_block_handles = [obj.vec_block_handles obj_element.GetHandle];
		end
		
		function bool_valid = PutElementIntoSubsystem(obj,index)
			bool_valid = (obj.cell_obj_element{index}.IsRootSystemElement == 0)...
				&&(obj.cell_obj_element{index}.IsAValidSimulinkBlock == 1);
		end
		%> build a subsystem with the name str_subsystem_name
		function BuildSubsystem(obj,str_subsystem_name)
 			%obj.DeleteUnconnectedLines;
			%%decide the total number of elements that will be put into the subsystem
% 			element_size = 0;
% 			for index = 1:length(obj.cell_obj_element);
% 				if obj.PutElementIntoSubsystem(index)
% 					element_size = element_size+1;
% %                     if element_size == 101
% %                         1;
% %                     end
% 				end
% 			end
% 			if element_size == 0
% % 				warning('unit is not valid, there might be a unit that does not connect to any other unit, check model definition');
% 				return
% 			end
% 			vec_block_handles = zeros(1,element_size);
% 			%%get all the handles of the elements that will be put into the
% 			%%subsystem
% 			element_nr = 0;
            vec_block_handles = [];
			for index = 1:length(obj.cell_obj_element);
				if obj.PutElementIntoSubsystem(index)
                    %make sure the elements, which should be put in the subsystem, 
                    %are in the first level of the
                    %abstract simulink system.
%                     str_host_name = obj.cell_obj_element{index}.GetHostName;
%                     vec_slash = strfind(str_host_name,'/');
%                     str_host_name = str_host_name(vec_slash(end)+1:end);
                    if strcmp(obj.GetBlockID,obj.cell_obj_element{index}.GetHostName)
%                         element_nr = element_nr+1;
                        vec_block_handles(end+1) = obj.cell_obj_element{index}.GetHandle;
                    else
                        warning(['BuildSubsystem error:' obj.cell_obj_element{index}.GetBlockID ' must locat in system ' obj.GetBlockID]);
                    end
				end
            end
            if isempty(vec_block_handles)
                return;
            end
  			try
				Simulink.BlockDiagram.createSubSystem(vec_block_handles);
  			catch ME
 				error(ME.message);
  			end
			%%update the underlying simulink ID and set with new name.
			obj.ResetSystemAndBlockNames(obj.GetBlockID,'Subsystem');
			obj.SetBlockName(str_subsystem_name);
			obj.UpdateHandleWithBlockID;
			obj.UpdateElementBlockID;
			obj.SetIsAValidSimulinkBlock(1);
		end
		
		function UpdateElementBlockID(obj)
			for index = 1:length(obj.cell_obj_element);
 				if obj.PutElementIntoSubsystem(index)
					obj.cell_obj_element{index}.UpdateBlockNameWithHandle;
					if isa(obj.cell_obj_element{index},'LPNSystem.clAbstractSimulinkSystem')
						obj.cell_obj_element{index}.UpdateElementBlockID;
					end
				end
			end
			for index = 1:length(obj.cell_obj_virtuall_child_subsystem)
				obj.cell_obj_virtuall_child_subsystem{index}.ResetSystemAndBlockNames(obj.GetHostName,obj.GetLocalName);
			end
		end

		%>@brief function that postprocesses the simulink for position
		%>adjustment of the blocks for better visibility
		%>currently only processes the first layer
		%>@todo actually finish the function and make it postprocessing each
		%>subsystem layer, may be good to move to clLumpedParamterNetwork
		function PostProcessSimulinkModel(obj, varargin)
			obj.SetPosition([400,100]);
			obj.SetSimulinkElementSize(100,800);
			if nargin == 2
				handle_or_id = varargin{1};
			else 
				handle_or_id = obj.GetHostName();
			end
			%determine the number of ports
			port_handles = obj.GetParameter('PortHandles');
			inport_handles = port_handles.Inport;
			lconn_handles = port_handles.LConn;
			rconn_handles = port_handles.RConn;
			outport_handles = port_handles.Outport;
			number_ports_left = numel(inport_handles) + numel(lconn_handles);
			number_ports_right = numel(outport_handles) + numel(rconn_handles);
			max_number_of_ports = max(number_ports_left,number_ports_right);
			%find the subsystem
			handle_subsystems = find_system(handle_or_id, 'FindAll', 'On', 'SearchDepth',1,'BlockType','SubSystem');
			%number_subsystems = numel(handle_subsystems);
			master_subsystem = handle_subsystems(1);
            if verLessThan('matlab','8.4.0')
                multiplier = 40;
            else
                multiplier = 70;
            end
			obj.SetSimulinkElementSize(100,max_number_of_ports*multiplier);
			port_connectivity = get_param(master_subsystem,'PortConnectivity');
			obj.PositionConnectedObjects(port_connectivity);
			
			%this might be not necessary in newer versions of matlab
			%(>=2012b) due to the smart signal routing
			number_of_inport_handles = numel(inport_handles);
			number_of_outport_handles = numel(outport_handles);
			number_of_lconn_handles = numel(lconn_handles);
			number_of_rconn_handles = numel(rconn_handles);
			for i=1:number_of_inport_handles
				temp = get_param(inport_handles(i), 'Line');
				dst = get_param(temp, 'DstPortHandle');
				src = get_param(temp, 'SrcPortHandle');
				delete_line(temp)
				add_line(obj.GetHostName(),src,dst)
			end
			for i=1:number_of_outport_handles
				temp = get_param(outport_handles(i), 'Line');
				dst = get_param(temp, 'DstPortHandle');
				src = get_param(temp, 'SrcPortHandle');
				delete_line(temp)
				add_line(obj.GetHostName(),src,dst)
			end
			for i=1:number_of_lconn_handles
				temp = get_param(lconn_handles(i), 'Line');
				dst = get_param(temp, 'DstPortHandle');
				src = get_param(temp, 'SrcPortHandle');
				delete_line(temp)
				add_line(obj.GetHostName(),src,dst)
			end
			for i=1:number_of_rconn_handles
				temp = get_param(rconn_handles(i), 'Line');
				dst = get_param(temp, 'DstPortHandle');
				src = get_param(temp, 'SrcPortHandle');
				delete_line(temp)
				add_line(obj.GetHostName(),src,dst)
			end
		end
		%>@brief adjusts the position of objects connected to a subsystem
		%to be in line with the port of the subsystem
		function PositionConnectedObjects(obj,port_connectivity,varargin)
			bool_right = 1;
			bool_left = 1;
			if nargin == 3
				if varargin{1} == 1
					bool_right = 0;
				elseif varargin{1} == 0
					bool_left = 0;
				else
					warning('Unknown option in PositionConnectedObjects().');
				end
			end
			%if SrcBlock is set the port is an input port, DstBlock means
			%Outport, special treatment for Simscape Connection
			number_of_ports = numel(port_connectivity);
			for i=1:number_of_ports
				offset = 100;%+ 100 * mod(i,2);
				if (strncmp(port_connectivity(i).Type, 'LConn',5) || isempty(port_connectivity(i).SrcBlock) == 0) && bool_left
					handle_to_connected_object = port_connectivity(i).SrcBlock;
					if handle_to_connected_object == obj.GetParameter('handle')
						break;
					end
					position_of_connected = get_param(handle_to_connected_object,'Position');
					width = position_of_connected(3) - position_of_connected(1);
					height = position_of_connected(4) - position_of_connected(2);
					port_position = port_connectivity(i).Position;
					new_position = [port_position(1) - width/2 - offset, port_position(2) - height/2, port_position(1) + width/2 - offset, port_position(2) + height/2];
					set_param(handle_to_connected_object,'Position', new_position);
					obj.PositionConnectedObjects(get_param(handle_to_connected_object,'PortConnectivity'),1);
				elseif strncmp(port_connectivity(i).Type, 'RConn',5) || isempty(port_connectivity(i).DstBlock) == 0 && bool_right
					handle_to_connected_object = port_connectivity(i).DstBlock;
					if handle_to_connected_object == obj.GetParameter('handle')
						break;
					end
					position_of_connected = get_param(handle_to_connected_object,'Position');
					width = position_of_connected(3) - position_of_connected(1);
					height = position_of_connected(4) - position_of_connected(2);
					port_position = port_connectivity(i).Position;
					new_position = [port_position(1) - width/2 + offset, port_position(2) - height/2, port_position(1) + width/2 + offset, port_position(2) + height/2];
					set_param(handle_to_connected_object,'Position', new_position);
					obj.PositionConnectedObjects(get_param(handle_to_connected_object,'PortConnectivity'),0);
				end
			end
		end

		%>return all element in a cell
		function cell_obj_element = GetCellObjElements(obj)
			cell_obj_element = obj.cell_obj_element;
		end
		%>take over all elements from a child system
		function TakeOverElements(obj,obj_child_system)
			obj.cell_obj_virtuall_child_subsystem{end+1} = obj_child_system;
			obj.cell_obj_element = [obj.cell_obj_element obj_child_system.GetCellObjElements];
% 			obj.vec_bool_put_in_subsystem = [obj.vec_bool_put_in_subsystem,obj_child_system.vec_bool_put_in_subsystem];
		end
		%>find element in system with the name str_name
		function obj_element = GetRootElementByName(obj,str_name)
			for index = 1:numel(obj.cell_obj_root_element)
				if strcmp(obj.cell_obj_root_element{index}.GetLocalName,str_name)
					obj_element = obj.cell_obj_root_element{index};
					return;
				end
			end
			error([str_name ' not found!']);
		end
    end
end