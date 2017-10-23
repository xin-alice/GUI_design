classdef clSRMControlData <handle
	properties(Access = private)
		Th0
		ThC
		iHi
		HBAmps
	end
	methods
		function obj = clSRMControlData(Th0,ThC,iHi,HBAmps)
			obj.Th0 = Th0;
			obj.ThC = ThC;
			obj.iHi = iHi;
			obj.HBAmps = HBAmps;
		end
	end
end