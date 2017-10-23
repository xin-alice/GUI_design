%>@clPC_SRD_Model is a PC-SRD Model
%>
classdef clPC_SRD_Model < handle
	properties%(Access = private)
		str_mdl_name
		str_mdl_path
		%>@todo replace this parameter with object of clSRMControlParameter
		%>basic control parameter is the control parameter for the
		%>operating point of 1000rpm, 10nm.(reasonable point? or may be 
		%>smaller rpm and smaller torque) This point should be determined
		%>at first and then as a reference point of other operating point.
		obj_basic_control_parameter
		%%%%%%to be delete%%%%%%%%
		basic_Th0 = 30;
		basic_ThC = 160;
		basic_iHi = 90;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%
	end
	methods
		%>initialize the object with name and path.
		function obj = clPC_SRD_Model(str_mdl_path,str_mdl_name)
			obj.str_mdl_path = str_mdl_path;
			obj.str_mdl_name = str_mdl_name;
		end
		%>@todo a function to determine the basic operating point. 
		function str_path = GetPath(obj)
			str_path = [obj.str_mdl_path '\' obj.str_mdl_name '.srd'];
		end
		%>input the th0,thC,iHi for the operation point 1000rpm 10nm
		function SetBasicControlParameter(obj,basic_Th0,basic_ThC,basic_iHi)
			obj.basic_Th0 = basic_Th0;
			obj.basic_ThC = basic_ThC;
			obj.basic_iHi = basic_iHi;
		end
		%>@todo: return only an object of clSRMControlParameter
		GetBasicControlParameter
		%%%%%%to be delete%%%%%%%%
		function Th0 = GetBasicTh0(obj)
			Th0 = obj.basic_Th0;
		end
		
		function ThC = GetBasicThC(obj)
			ThC = obj.basic_ThC;
		end
		
		function iHi = GetBasiciHi(obj)
			iHi = obj.basic_iHi;
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%
	end
end