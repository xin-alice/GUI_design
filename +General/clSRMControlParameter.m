%>this class contain the srm control parameter for the operating point.
classdef clSRMControlParameter <handle
	properties(Access = private)
		%>turn on angle
		Th0
		%>turn off angle
		ThC
		%>target current of hysteresis current control
		iHi
		%>tolerence of the current band
		HBAmps
	end
	methods
		%>set parameter 
		function SetParameter(obj,Th0,ThC,iHi,HBAmps)
			obj.Th0 = Th0;
			obj.ThC = ThC;
			obj.iHi = iHi;
			obj.HBAmps = HBAmps;
		end
		%>@todo
		[Th0,ThC] = GetAngleParameter(obj)
		%>@todo
		[iHi,HBAmps] = GetCurrentParameter(obj)
		
	end
end