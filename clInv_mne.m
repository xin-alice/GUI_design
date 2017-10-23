classdef clInv_mne < Inverter.clInv_LPTN
	properties
		x_igbt = 0.040; %Measurements=2*0.10; approximated in order to keep the simulation time small
		y_igbt = 0.010; %Measurements; approximated in order to keep the simulation time small
		z_igbt = 80e-6; %datasheet IGC100T65T8RM
		
		x_diode = 0.040; %Measurements=2*10; approximated in order to keep the simulation time small
		y_diode = 0.005; %Measurements; approximated in order to keep the simulation time small
		z_diode = 65e-6; %datasheet SIDC50D65C8
		
		z_solder = 80e-6; %value is from Semikron "Applikationshandbuch", p. 83
		
		x_diode_relative_offset = 0.0;
		y_diode_relative_offset = -0.0015; %Measurements; approximated in order to keep the simulation time small
		
		IGBT1_offset = [0.01, 0.04, 0.0]; %Measurements; approximated in order to keep the simulation time small
		IGBT2_offset = [0.01, 0.012, 0.0]; %Measurements; approximated in order to keep the simulation time small
		%IGBT3_offset = [0.033, 0.04, 0.0]; %Measurements; approximated in order to keep the simulation time small
		%IGBT4_offset = [0.033, 0.012, 0.0]; %Measurements; approximated in order to keep the simulation time small		
		resolution_igbt = [1,1,1];
		resolution_diode = [1,1,1];
% 		resolution_igbt = [3,2,1];
% 		resolution_diode = [3,2,1];
		x_DCB = 0.06; %Measurements; approximated in order to keep the simulation time small
		y_DCB = 0.062; %Measurements; approximated in order to keep the simulation time small
		z_copperHigh  = 300e-6; %Semikron "Applikationshandbuch", p. 83 
		z_substrate = 380e-6; %Semikron "Applikationshandbuch", p. 83
		z_copperLow  = 300e-6; %Semikron "Applikationshandbuch", p. 83
% 		resolution_DCB = [2, 2, 2];
		resolution_DCB = [1, 1, 1];
		DCB_offset = [0.009, 0.0175, 0]; %Measurements; approximated in order to keep the simulation time small
        
		x_baseplate = 0.071; % 71=213/3 Datasheet; only 1/3 is simulated
		y_baseplate = 0.097; %97mm Datasheet
		z_baseplate = 4e-3; %Datasheet 4mm
		baseplate_offset = [0.00, 0.00];
% 		resolution_baseplate = [1,1,2];		
        resolution_baseplate = [1,1,1];	
		x_heatsink = 0.0;%0.062;
		y_heatsink = 0.0;%0.055;
		z_heatsink = 0.0;%0.01;
		resolution_heatsink = [1, 1, 1];
        z_thermalGrease = 0.0;%75e-6;
		
		x_fin = 0.062; %0.071-0.009 preliminary Datasheet (including the additional distance (o-ring)) 
		y_fin = 0.055; %0.055 preliminary Datasheet (including the additional distance (o-ring))
		z_fin = 1e-6;% 1e-6 to have a thin contact for the comsol values... 0.008; %Datasheet
		resolution_fin = [1, 1, 1];
		fin_offset = [0.009, 0.021]; %Datasheet 0.009 0.021	
		
		inv_name = 'FS800R07A2E3_one_half_bridge'
        
	end
	methods
		function obj = clInv_mne
			%close all
			
			%% Set the components and the thermal properties	
			
			%Initialize and set the Geometry;
			obj.obj_Inv_Geometry = Geometry.clInvGeometry;
			obj.obj_Inv_Geometry.SetValues(obj);
			
			obj.IGBT_Chip.No11 = InverterComponent.Semiconductor.clIGBTandDiode('IGBT1', 'SolderIGBT1', 'Diode1', 'SolderDiode1');
			obj.IGBT_Chip.No11.SetGeometry(obj.obj_Inv_Geometry.IGBT, obj.IGBT1_offset);
			
			%Set the position of the IGBT2 chips and Diodes
			obj.IGBT_Chip.No12 = InverterComponent.Semiconductor.clIGBTandDiode('IGBT2', 'SolderIGBT2', 'Diode2', 'SolderDiode2');
			obj.IGBT_Chip.No12.SetGeometry(obj.obj_Inv_Geometry.IGBT_mirrored, obj.IGBT2_offset);
		
% 			obj.IGBT_Chip.No13 = InverterComponent.Semiconductor.clIGBTandDiode('IGBT3', 'SolderIGBT3', 'Diode3', 'SolderDiode3');
% 			obj.IGBT_Chip.No13.SetGeometry(obj.obj_Inv_Geometry.IGBT, obj.IGBT3_offset);
% 			
% 			obj.IGBT_Chip.No14 = InverterComponent.Semiconductor.clIGBTandDiode('IGBT4', 'SolderIGBT4', 'Diode4', 'SolderDiode4');
% 			obj.IGBT_Chip.No14.SetGeometry(obj.obj_Inv_Geometry.IGBT_mirrored, obj.IGBT4_offset);			
			
			%Set the position of the DCB-Substrate
			obj.DCB.No1 = InverterComponent.Substrate.clDCB('CopperHigh', 'Substrate', 'CopperLow', 'SolderDCB' );
			obj.DCB.No1.SetGeometry(obj.obj_Inv_Geometry.DCB, obj.DCB_offset);
			
			%Set the Baseplate
			obj.baseplate = InverterComponent.Baseplate.clBaseplate('Baseplate', 0);
			obj.baseplate.SetGeometry(obj.obj_Inv_Geometry.baseplate, obj.baseplate_offset);
			
            %Define a thin layer, because the shapeless component
            %doesn't allow a partial contact
			obj.fin = InverterComponent.Cooling.clFin('ContactFin');
			obj.fin.SetGeometry(obj.obj_Inv_Geometry.fin, obj.fin_offset);
            
            %shortCircuitFinContactArea is used to short circuit the bottom part
            %of the fin-connection
            obj.shortCircuitFinContactArea = LPNComponent.clLPThermalComponent.CreateThermalComponent('ShortCircuitFinContactArea', LPNEnum.enumThermalComponent.shapeless);
			%Don't define the LPNEnum.enumThermalContact in order to achieve a
            %direct conection of all the units of the bottom side of the
            %baseplate (short circuit). This connection can be used to add
            %the resistance simulated with comsol.
            obj.contact_baseplate_shortCircuitFinContactArea = LPNContact.clComponentThermalContact;
            obj.contact_baseplate_shortCircuitFinContactArea.InitContact(obj.shortCircuitFinContactArea, LPNEnum.enumRectangularDirection.on_negative_direction_on_z_axis, obj.fin.GetContactObject(LPNEnum.enumRectangularDirection.on_negative_direction_on_z_axis));
            
            %This is a dummy element to adjust the water temperature
            %resistanc from the comsol simulation
            obj.finComsol = LPNComponent.clLPThermalComponent.CreateThermalComponent('FinComsol', LPNEnum.enumThermalComponent.shapeless);
            obj.contact_shortCircuitFinContactArea_finComsol = LPNContact.clComponentThermalContact;
			obj.contact_shortCircuitFinContactArea_finComsol.InitContact(obj.shortCircuitFinContactArea, LPNEnum.enumRectangularDirection.on_positive_direction_on_z_axis, obj.finComsol);
 			obj.contact_shortCircuitFinContactArea_finComsol.SetEnumerationThermalContact(LPNEnum.enumThermalContact.slot_paper_contact); %The contact should be replaced afterwards

			%% Settings for the simulation
            
			%Set the Input for the WaterTemperature
			obj.finComsol.SetInputTemperature(25, LPNEnum.enumRectangularDirection.on_negative_direction_on_z_axis);
			
			%set the igbt_losses
			obj.SetLosses({obj.IGBT_Chip.No11, obj.IGBT_Chip.No12}, 1000, 0);
			
			obj.IGBT_Chip.No11.OutputHotspotTemperature;
			obj.IGBT_Chip.No12.OutputHotspotTemperature;
% 			obj.IGBT_Chip.No13.OutputHotspotTemperature;
% 			obj.IGBT_Chip.No14.OutputHotspotTemperature;
			obj.IGBT_Chip.No11.OutputAverageTemperatureIGBT;
			obj.IGBT_Chip.No12.OutputAverageTemperatureIGBT;
% 			obj.IGBT_Chip.No13.OutputAverageTemperatureIGBT;
% 			obj.IGBT_Chip.No14.OutputAverageTemperatureIGBT;
            obj.DCB.No1.OutputAverageTemperature;
            obj.DCB.No1.OutputHotspotTemperature;
			obj.baseplate.OutputAverageTemperature;
            obj.baseplate.OutputHotspotTemperature;
            obj.shortCircuitFinContactArea.OutputAverageTemperature; %This output returns the average temperature of the bottom of the baseplate = T_Frame/maximal_temperature of cooling circuit
            obj.finComsol.OutputAllHeatFlux; %Output the heatflux to Water
			
			%set the initial temperature
			obj.SetGlobalInitialTemperature(25);
			
			%Set the options
			obj.SetOptions(LPNEnum.enumLPNBuilderMode.unprotected_complete_variable_parameter); %enumLPNBuilderOption.simulation_steady_state
			
			%% Start building the model and the simulation
			%Construct the inverter
			obj.ConstructInv;
			
			%Build the model
			obj.Build_Inv_LPTN;
			%Create Protected Subsystem in order to keep the simulation
			%time short
% 			obj.CreateProtectedSubsystem;
			
            %enable data-logging
            obj.SetSimscapeLogging;
%             obj.StartSimulation(100);
% 			
% 			
% 			%% Visualize the components
% 			%Plot overview
% 			obj.DrawComponentsMerged({'ContactFin', 'Baseplate', 'SolderDCB', 'CopperLow', 'Substrate', 'CopperHigh', 'SolderDiode1', 'SolderIGBT1', 'Diode1', 'IGBT1', 'SolderDiode2', 'SolderIGBT2', 'Diode2', 'IGBT2'}, 0.002, 100);
% 			%xy-slice 
% 			obj.PlotComponentsMerged({'ContactFin', 'Baseplate', 'SolderDCB', 'CopperLow', 'Substrate', 'CopperHigh', 'SolderDiode1', 'SolderIGBT1', 'Diode1', 'IGBT1', 'SolderDiode2', 'SolderIGBT2', 'Diode2', 'IGBT2'}, 0.0001, 100, 0.003, [], []);
% 			%yz-slice 
% 			obj.PlotComponentsMerged({'ContactFin', 'Baseplate', 'SolderDCB', 'CopperLow', 'Substrate', 'CopperHigh', 'SolderDiode1', 'SolderIGBT1', 'Diode1', 'IGBT1', 'SolderDiode2', 'SolderIGBT2', 'Diode2', 'IGBT2'}, 0.0001, 100, [], [], 0.03);
		end
	end
end
