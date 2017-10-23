lptn = MotorInstance.clIM_DickeBertha_C_Code;
converter = lptn.GetToolStateSpaceConverter;
state_space = converter.GetContinuousStateSpaceModel;
initial_temp = 30;
reduced_order = 20;
[state_space_reduced,x0_reduced,trans_matrix] = converter.GetReducedContinuousStateSpaceModel(reduced_order,initial_temp);
state_space_reduced.c * x0_reduced
%% state space array
lptn_name = lptn.GetModelName;
vector_parameter = 0:2000:20000;
state_space_array = converter.GetStateSpaceArray(lptn_name,'speed_rotor',vector_parameter);
[ss_array_reduced,x0,trans_matrix] = converter.GetReducedStateSpaceArray(state_space_array,reduced_order,initial_temp);
% LPV System Simulink block in Control System Toolbox (at least MATLAB
% 2014b)
% needs State Space Array and initial state vector
% MATLAB documentation: http://de.mathworks.com/help/control/ref/lpvsystem.html
%% physical
% lptn_hires_reference: reference model
% cell_ref_temp_steadystate: cell containing timeseries of simulation
% results of reference model
tol_bound = 3;
gradient_bound = 15;
% tol_bound: simulation error bound
% gradient_bound: temperature gradient bound
lptn.ModelReduction(lptn_hires_reference,cell_ref_temp_steadystate,tol_bound,gradient_bound)
