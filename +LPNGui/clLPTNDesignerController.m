classdef clLPTNDesignerController < handle
    properties
    end
    methods
1        %set tempelate:LPTN or LPTNDuplicate(popup)
1        %for LPTNDuplicate: duplicate of stator kland rotor.(add + popup + entry)
1        %set mode and options(popup)(buttongroup)
%instantiate lptn1
1       %set stator yoke,rotor, shapeless, stator teeth(for each, extra parameters) 
1        %set optimized model parameter
1        %set measurement data
1        %set geometry
0        %change something in geometry
1        %set boundary
0        %change something in boundary, it could be a MotorInputs 
        %in MotorInputs, set the input of the MotorInputs, it could also be
        %further MotorInputs(Lookup Table)
%ConstructMachine
        %set resolution of components, set single unit of components,
            %delete components
        %set temperature of compoennts(uniform temperature, side temperature)
        %set global initial temperature
        %set initial temperature of various vomponent
        
        %set losses, it could be a MotorInputs, Also Group losses. Losses
        %could have a loss setup, for example temperature dependence.
        %set output of component, average temperature, hotspot temperature
        %set sensors positions, sensor thermal properties, measured sensor temperature
%Build LPTN, type name, set stop time
        
    end
end