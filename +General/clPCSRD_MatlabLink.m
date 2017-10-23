classdef clPCSRD_MatlabLink < handle
	properties(Access = private)
		obj_wsrd_server
		obj_control_design
		obj_PC_SRD_Model
	end
	properties
		rotor_yoke_loss_high_speed
		rotor_teeth_loss_high_speed
		stator_yoke_loss_high_speed
		stator_teeth_loss_high_speed
		copper_loss_high_speed
		rotor_yoke_loss_high_torque
		rotor_teeth_loss_high_torque
		stator_yoke_loss_high_torque
		stator_teeth_loss_high_torque
		copper_loss_high_torque
	end
	methods
% 		function delete(obj)
% % 			delete wsrd32params.m;
% % 			invoke(obj.obj_wsrd_server,'Quit');
% % 			obj.obj_wsrd_server.quit;
% % 			obj.obj_wsrd_server.delete;
% 		end
		function obj = clPCSRD_MatlabLink
			obj.Initialize;
		end
% 		function Restart(obj)
% 			obj.obj_wsrd_server.quit;
% 			obj.obj_wsrd_server.delete;
% 			obj.Initialize;
% 		end
		function Initialize(obj)
			%% Create M-file for input/output parameter file of PC-SRD
			if (exist('wsrd32params.m','file')== 2);
				delete wsrd32params.m; 
			end
			obj.obj_wsrd_server = actxserver ('wsrd32.appautomation');
% 			invoke(obj.obj_wsrd_server);       % List of all defined functions
			%% Get path of this M-file to create parameter file in the same directory
			param_pname = strcat(pwd,'\');  
			res = invoke(obj.obj_wsrd_server,'WriteParameterInformation',strcat(param_pname,'wsrd32params.m'),'*.m');
			%% Call generated parameter file
% 			run(strcat(param_pname,'wsrd32params.m'));
			%run([pwd '\wsrd32params.m']);
% 			obj.SaveParameterIDInWorkspace;
			%% Create new problem
			obj.obj_control_design = obj.obj_wsrd_server.invoke('createnewdesign');
% 			invoke(obj.obj_control_design);
		end
		
% 		function SaveParameterIDInWorkspace(obj)
% 			run([pwd '\wsrd32params.m']);
% 			save('wsrd32params.mat');
% 		end
		function LoadModel(obj,obj_Model)
			%% Loading an existing PCSRD design from a saved file. File end has to be ".srd"
			proc1 = invoke(obj.obj_control_design,'LoadFromFile',obj_Model.GetPath);
			obj.obj_PC_SRD_Model = obj_Model;
			if proc1 ~= 0
				invoke( obj.obj_wsrd_server,'ShowMessage','Error opening file');
			end
		end
		function SetControlParameter(obj, Theta_on, Theta_off, iHi, HBAmps, n_ref)
			%% Transmit in the above defined values to PC-SRD
			% invoke(obj.obj_control_design,'SetVariable',piVS,U_DC); 
			% invoke(obj.obj_control_design,'SetVariable',piHB,Current_tolerance_band_width);
			run([pwd '\wsrd32params.m']);
			try
				invoke(obj.obj_control_design,'SetVariable',piIHI,iHi);
			catch ME
				a = 1;
			end
			invoke(obj.obj_control_design,'SetVariable',piTH0,Theta_on); 
			invoke(obj.obj_control_design,'SetVariable',piTHC,Theta_off);
			invoke(obj.obj_control_design,'SetVariable',piHB,HBAmps);
% 			invoke(obj.obj_control_design,'SetVariable',piTHZ,Theta_freewheel); 
			invoke(obj.obj_control_design,'SetVariable',piRPM,n_ref);
			invoke(obj.obj_control_design,'SetVariable',piTFRIC,0); 
			invoke(obj.obj_control_design,'SetVariable',piWF0,0); 
		end
		function [Efficiency,Average_torque,Current_density_RMS] = Simulate(obj)
			%% Simulate in PC-SRD
			run([pwd '\wsrd32params.m']);
			Res = invoke(obj.obj_control_design,'DoDynamicDesign');
			%% Get parameters from PC-SRD
 			Average_torque = invoke(obj.obj_control_design,'GetVariable',piTORQSH);            % Average machine torque
% 			obj.Torque_ripple = invoke(obj.obj_control_design,'GetVariable',piTRPP);               % Torque ripple
% 			obj.Current_max = invoke(obj.obj_control_design,'GetVariable',piIWPK);                 % Maximum phase current
% 			Current_RMS = invoke(obj.obj_control_design,'GetVariable',piIWRMS);                % RMS (root mean square) phase current
 			Current_density_RMS = invoke(obj.obj_control_design,'GetVariable',piJRMS);         % RMS current density
			Efficiency = invoke(obj.obj_control_design,'GetVariable',piEFF)/100;               % Total efficiency NOT in % but \in [0;1] (neglecting eddy current losses in the windings)
%			Efficiency = 1-(invoke(obj.obj_control_design,'GetVariable',piWCU)+invoke(obj.obj_control_design,'GetVariable',piWIRON))/invoke(obj.obj_control_design,'GetVariable',piPELEC); 
			% 			obj.DC_link_current_ripple = invoke(obj.obj_control_design,'GetVariable',piDCRIPPLE);  % Current ripple at the DC-link-capacitor
% 			obj.Mean_switching_freq = invoke(obj.obj_control_design,'GetVariable',piFCHOPAVG);     % Mean switching frequency of one phase
% 			obj.N_switchings_per_phase = invoke(obj.obj_control_design,'GetVariable',piNCHOPS);    % Number of switching actions
% 			obj.N_switchings_per_phase = double(obj.N_switchings_per_phase);        % Integers are given back not as doubles but as integers. Matlab the converts the other doubles in an equation to integers (by rounding) also; thus, this integers have to be converted to doubles
% 			obj.Energy_conversion_factor = invoke(obj.obj_control_design,'GetVariable',piERATIO);  % Energy conversion factor = W_mech / (W_mech + W_mag)
% 			obj.Mode = invoke(obj.obj_control_design,'GetVariable',piDOING);        
		end
		
% 		function SimulateHighSpeed(obj)
% 			n_ref = 22500;
% % 			[best_Th0,best_ThC,best_iHi,HBAmps,eff,Jrms,torque] = obj.FindBestEff(Th0,ThC,iHi,35,torque_ref,n_ref)
% 			obj.SetControlParameter(-90,90,300,50,n_ref);
% 			[eff,torque,Jrms] = obj.Simulate
% 			obj.rotor_yoke_loss_high_speed = obj.GetRotorYokeLoss;
% 			obj.rotor_teeth_loss_high_speed = obj.GetRotorPoleLoss;
% 			obj.stator_yoke_loss_high_speed = obj.GetStatorYokeLoss;
% 			obj.stator_teeth_loss_high_speed = obj.GetStatorPoleLoss;
% 			obj.copper_loss_high_speed = obj.GetCopperLoss;
% 		end
% 		function SimulateHighTorque(obj,speed_of_machine)
% 			if speed_of_machine == 1
% 				torque_ref = 110;
% 			elseif speed_of_machine == 2
% 				torque_ref = 80;
% 			end
% 			[best_Th0,best_ThC,best_iHi,HBAmps,eff,Jrms,torque,n_ref] = obj.FindBestEff(Th0,ThC,iHi,35,torque_ref,n_ref)
% 			obj.SetControlParameter(best_Th0,best_ThC,best_iHi,HBAmps,n_ref);
% 			[eff,torque,Jrms] = obj.Simulate
% 			obj.rotor_yoke_loss_high_torque = obj.GetRotorYokeLoss;
% 			obj.rotor_teeth_loss_high_torque = obj.GetRotorPoleLoss;
% 			obj.stator_yoke_loss_high_torque = obj.GetStatorYokeLoss;
% 			obj.stator_teeth_loss_high_torque = obj.GetStatorPoleLoss;
% 			obj.copper_loss_high_torque = obj.GetCopperLoss;
% 		end
		
		function rotor_yoke_loss = GetRotorYokeLoss(obj)
			run([pwd '\wsrd32params.m']);
			rotor_yoke_hysteresis_loss= invoke(obj.obj_control_design,'GetVariable',piPRYH);
			rotor_yoke_eddy_loss= invoke(obj.obj_control_design,'GetVariable',piPRYE);
			rotor_yoke_loss = rotor_yoke_hysteresis_loss + rotor_yoke_eddy_loss;
		end
			
		function rotor_pole_loss = GetRotorPoleLoss(obj)
			run([pwd '\wsrd32params.m']);
			rotor_pole_hysteresis_loss= invoke(obj.obj_control_design,'GetVariable',piPRPH);
			rotor_pole_eddy_loss= invoke(obj.obj_control_design,'GetVariable',piPRPE);
			rotor_pole_loss = rotor_pole_hysteresis_loss + rotor_pole_eddy_loss;
		end
		
		function stator_yoke_loss = GetStatorYokeLoss(obj)
			run([pwd '\wsrd32params.m']);
			stator_yoke_hysteresis_loss= invoke(obj.obj_control_design,'GetVariable',piPSYH);
			stator_yoke_eddy_loss= invoke(obj.obj_control_design,'GetVariable',piPSYE);
			stator_yoke_loss = stator_yoke_hysteresis_loss + stator_yoke_eddy_loss;
		end
		
		function stator_pole_loss = GetStatorPoleLoss(obj)
			run([pwd '\wsrd32params.m']);
			stator_pole_hysteresis_loss= invoke(obj.obj_control_design,'GetVariable',piPSPH);
			stator_pole_eddy_loss= invoke(obj.obj_control_design,'GetVariable',piPSPE);
			stator_pole_loss = stator_pole_hysteresis_loss + stator_pole_eddy_loss;
		end
		
		function copper_loss = GetCopperLoss(obj)
			run([pwd '\wsrd32params.m']);
			copper_loss = invoke(obj.obj_control_design,'GetVariable',piWCU);
		end
				%>find best eff point for ODIN machines
		function cell_ans = FindBestEffForOperatingPoint(obj,speed,torque)
			test_Th0 = obj.obj_PC_SRD_Model.GetBasicTh0;%35;
			test_ThC = obj.obj_PC_SRD_Model.GetBasicThC;%160;
			test_iHi = obj.obj_PC_SRD_Model.GetBasiciHi;%85;
			[Th02,ThC2,iHi2,HBAmps2] = obj.ConvertParameter(test_Th0,test_ThC,test_iHi,torque,speed);
			cell_ans = obj.FindBestEff(Th02,ThC2,iHi2,HBAmps2,torque,speed);
		end
		%>find best eff point for ODIN machines
		function cell_ans = FindBestEffForSpeed(obj,speed_of_machine,begin_index_speed,begin_index_torque)
			if nargin < 3
				begin_index_speed = 1;
				begin_index_torque = 1;
			end
			test_Th0 = obj.obj_PC_SRD_Model.GetBasicTh0;%35;
			test_ThC = obj.obj_PC_SRD_Model.GetBasicThC;%160;
			test_iHi = obj.obj_PC_SRD_Model.GetBasiciHi;%85;
			if speed_of_machine == 1
				cell_speed = {1365,4095,6825,9555};
				nr_speeds = numel(cell_speed);
				cell_torque = {[-20.6 , 6.9 , 34.3],[-20.6 , 6.9 , 20.6 , 34.3],[6.9 , 20.6],[6.9]};
				cell_ans = cell(1,nr_speeds);
			elseif speed_of_machine == 2
				cell_speed = {1172,1875,3516,5625,5859,8203,9375,13125};
				nr_speeds = numel(cell_speed);
				cell_torque = {[8,-24,40],[5,-15,25],[24,40,-24,8],[15,25,-15,5],[24,8],[8],[15,5],[5]};
				cell_ans = cell(nr_speeds,1);
			end
			for index_speed = begin_index_speed:nr_speeds
				cell_ans{index_speed} = cell(length(cell_torque{index_speed}),1);
				for index_torque = begin_index_torque:length(cell_torque{index_speed})
					[Th02,ThC2,iHi2,HBAmps2] = obj.ConvertParameter(test_Th0,test_ThC,test_iHi,cell_torque{index_speed}(index_torque),cell_speed{index_speed});

					cell_ans{index_speed}{index_torque} = obj.FindBestEff(Th02,ThC2,iHi2,HBAmps2,cell_torque{index_speed}(index_torque),cell_speed{index_speed});

				end	
			end
		end
		%> adapt control parameter
		function [Th02,ThC2,iHi2,HBAmps2] = ConvertParameter(obj,Th0,ThC,iHi,torque_ref,n_ref)
			
			iHi2 = iHi + 50 * floor(abs(torque_ref)/15);
			if iHi2 < 0
				warning;
			end
			if torque_ref > 0
				Th02 = Th0 - floor(n_ref/2000)*5;
				ThC2 = ThC - floor(n_ref/2000)*5;
			else
				Th02 = 140 + Th0 - floor(n_ref/2000)*5;
				ThC2 = 150 + ThC - floor(n_ref/2000)*5;
			end
			HBAmps2 = 10 + floor(iHi2/50)*5;
				
		end
		%>finde the control data with the best effencency		
		function cell_ans = FindBestEff(obj,Th0,ThC,iHi,HBAmps,torque_ref,n_ref)
			torque_ref = abs(torque_ref);
			best1_Th0 = obj.FindBestParameter(1,@(x)x==max(x),1,18,6,Th0,ThC,iHi,HBAmps,n_ref);
			best1_ThC = obj.FindBestParameter(1,@(x)x==max(x),2,18,6,best1_Th0,ThC,iHi,HBAmps,n_ref);
			best1_iHi = obj.FindBestParameter(2,@(x)abs(x-torque_ref)==min(abs(x-torque_ref)),3,20,10,best1_Th0,best1_ThC,iHi,HBAmps,n_ref);
			best_Th0 = obj.FindBestParameter(1,@(x)x==max(x),1,9,3,best1_Th0,best1_ThC,best1_iHi,HBAmps,n_ref);
			best_ThC = obj.FindBestParameter(1,@(x)x==max(x),2,9,3,best_Th0,best1_ThC,best1_iHi,HBAmps,n_ref);
			best_iHi = obj.FindBestParameter(2,@(x)abs(x-torque_ref)==min(abs(x-torque_ref)),3,10,5,best_Th0,best_ThC,best1_iHi,HBAmps,n_ref);
			second_correction = abs([best_Th0-best1_Th0,best_ThC-best1_ThC,best_iHi-best1_iHi])
% 			best_Th0 = Th0;
% 			best_ThC = ThC;
% 			best_iHi = iHi;
 			obj.SetControlParameter(best_Th0,best_ThC,best_iHi,HBAmps,n_ref);
 			[eff,torque,Jrms] = obj.Simulate;
			if abs(torque-torque_ref)>1
				warning(['target torque: ' num2str(torque_ref) ' real torque: ' num2str(torque)]);
				%cell_ans = {};
				%return;
			end
			format long;
			run([pwd '\wsrd32params.m']);
			cell_ans = cell(575,1);
			cell_ans{1} = obj.obj_PC_SRD_Model.str_mdl_name;
			for id_variable_name = 2:575
				cell_ans{id_variable_name} = invoke(obj.obj_control_design,'GetVariable',id_variable_name);
			end
		end
		%>simulate recursive to find the best parameter. 
		%>@param Nr_to_evaluate which parameter in the output parameter of simulate should be
		%>used to rate the parameter
		%>@param evaluate_function function_handle is the evaluation
		%>function. The best effiency is @(x)x==max(x). The nearest current
		%>to produced torque is @(x)abs(x-torque_ref)
		%>@param Nr_para which parameter in varargin should be evaluate
		%>@param search_interval the plus minus search interval. if varargin{3}
		%>is the paramter to be found. Search interval is
		%>varargin{3}-search_interval------varargin{3}+search_interval
		%>@param stepsize stepsize in total search interval
		%>@param varargin the parameter 
		function best_para = FindBestParameter(obj,Nr_to_evaluate,evaluate_function,Nr_para,search_interval,stepsize,varargin)
			while 1
				start_para = varargin{Nr_para}-search_interval;
				end_para = varargin{Nr_para}+search_interval;
				vec_para = start_para:stepsize:end_para;
				eff_para = zeros(1,length(vec_para));
				cell_paras = varargin;
				answer = zeros(1,3);
				for index = 1:length(vec_para)
					cell_paras{Nr_para} = vec_para(index);
					obj.SetControlParameter(cell_paras{:});
					[answer(1),answer(2),answer(3)] = obj.Simulate;
					eff_para(index) = answer(Nr_to_evaluate);
% 					eff_para(index) = obj.Simulate;
				end
% 				best_para = vec_para(eff_para == max(eff_para));
				best_para = vec_para(evaluate_function(eff_para));
				best_para = best_para(1);
				if length(vec_para) > 4 && (best_para == start_para||best_para == end_para)
					cell_paras = varargin;
					cell_paras{Nr_para} = best_para;
					best_para = obj.FindBestParameter(Nr_to_evaluate,evaluate_function,Nr_para,search_interval,stepsize,cell_paras{:});
					break;
				else
					break;
				end
			end
		end
		
% 		function LoadVariableInWorkspace(obj)
% 			run([pwd '\wsrd32params.m']);
% 		end
		
		function value = GetMachineVariable(obj,id_variable_name)
			value = double(invoke(obj.obj_control_design,'GetVariable',id_variable_name));
		end

	end
end