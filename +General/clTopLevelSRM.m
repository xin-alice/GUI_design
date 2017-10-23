%>the top level object of srm. It contains its lumped parameter thermal model, 
%>its PCSRD Model, later also its control strategie and so on.
classdef clTopLevelSRM < handle
	properties(Access = private)
		%> the name of 
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