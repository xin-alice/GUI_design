classdef clSRMOperatingPointAnalyser < handle
	properties
		%> vector of the operating point object
		vec_obj_operating_point
		%> vector of the machine
		vec_obj_srm
	end
	methods
		LoadSRMModel
		LoadOperatingPoint
		CalculateOperatingPoint
		OutputToExcell
	end
end