%>operating point 
classdef clOperatingPoint < handle
	properties(Access = private)
		speed
		torque
	end
	methods
		function obj = clOperatingPoint(speed, torque)
			obj.speed = speed;
			obj.torque = torque;
		end
		
		function torque = GetTorque(obj)
			torque = obj.torque;
		end
		
		function speed = GetRevolutionsPerMinute(obj)
			speed = obj.speed;
		end
		
		function angular_velocity = GetAngularVelocity(obj)
			angular_velocity = obj.speed/60*2*pi;
		end
		
		function power = GetPower(obj)
			power = obj.GetAngularVelocity*obj.torque; 
		end
	end
end