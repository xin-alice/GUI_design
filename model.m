classdef model < handle    
    properties (SetObservable)
       mode
    end
        
    methods
        function obj = model()
        end
                
       
        function ApplyParameter(obj,mode)    
        end
        
        function setMode(obj,mode)
            obj.mode = mode;
        end
%         
%         function setUnits(obj,units)
%             obj.units = units;
%         end
%         
%         function calculate(obj)
%             obj.mass = obj.density * obj.volume;
%         end
    end
end