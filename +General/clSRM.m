classdef clSRM < handle
	properties(Access = private)
		str_SRM_ID
		obj_PCSRD_Model
		obj_LPTN
		cell_op_performance		
		obj_reference_control_data
	end
	methods
		function SetReferencControlData(obj,obj_control_data)
			obj.obj_reference_control_data = obj_control_data;
		end
		function SetPCSRDModel(obj,obj_PCSRD_Model)
			obj.obj_PCSRD_Model = obj_PCSRD_Model;
		end
	end
end