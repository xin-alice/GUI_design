
#define S_FUNCTION_NAME  StateSpaceWithModelPredictiveControl
#define S_FUNCTION_LEVEL 2
#define MDL_UPDATE
#define MDL_START



#include <math.h>
#include "simstruc.h"
#include "TemperatureEstimator.hpp"

TemperatureEstimator TE;
#define NPARAMS 1
int mpc_outputs = 1;
//int mpc_inputs = 0;

int timer = 30;
float calculate_overload_if_changed = 0;
float mpc_out;

static void mdlInitializeSizes(SimStruct *S)
{
    //ssSetNumSFcnParams(S, 0);
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
            if (ssGetErrorStatus(S) != NULL) {
                return;
            }
        } else {
            return; /* Parameter mismatch reported by the Simulink engine*/
        }
    #endif
    
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }
	// input is a signal vector including losses and temperature
	if (!ssSetNumInputPorts(S, 3)) return;
	ssSetInputPortWidth(S, 0, N_INPUTS+1);//+mpc_inputs
	ssSetInputPortWidth(S, 1, 1);//max temperature
    ssSetInputPortWidth(S, 2, 1);//update mpc output if this port changes
	ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
	// output has a temperature output vector and mpc output vector
	if (!ssSetNumOutputPorts(S, 3)) return;
	ssSetOutputPortWidth(S, 0, N_OUTPUTS);
	ssSetOutputPortWidth(S, 1, mpc_outputs);// maximum current
	ssSetOutputPortWidth(S, 2, 2);// winding hotspot & rotor hotspot
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, F_TIMESTEP);
    ssSetOffsetTime(S, 0, 0);
}

static void mdlStart(SimStruct *S)
{
    const real_T *pr_initial_state   = mxGetPr(ssGetSFcnParam(S,0));
    TE.SetInitialStateVector(*pr_initial_state);
    
	//TE.SetInitialStateVector(INIT_STATES_FOR_SFUNCTION);
}

static void mdlUpdate(SimStruct *S, int_T tid)
{
    //float test_mat[2][N_CONTROLLED_OUTPUTS];
    //test_mat[1][N_CONTROLLED_OUTPUTS] = 1;
    //test_mat[2][N_CONTROLLED_OUTPUTS] = 1;
	//Get Reference Input
	InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
	float ref[N_CONTROLLED_OUTPUTS] = {0.f};
	ref[0] = static_cast<float>(*u1[0]);
    
    InputRealPtrsType u2 = ssGetInputPortRealSignalPtrs(S,2);
    float update_overload_current = {0.f};
    update_overload_current = static_cast<float>(*u2[0]);
    
	TE.SetReferenceInput(ref);
    
	//StateSpace input
	InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    float temp_input[N_INPUTS];
    for(int i = 0;i<N_INPUTS;i++)
    {
        temp_input[i] = static_cast<float>(*u0[i]);
//         ssPrintf("SetInputVector %.16g\n",temp_input[i]);
    }
    TE.SetInputVector(temp_input);
//     #ifdef I_ROTOR_COPPER_LOSS
// 	TE.SetRotorCopperLosses(static_cast<float>(*u0[I_ROTOR_COPPER_LOSS]));
//     #endif
//     #ifdef I_ROTOR_IRON_LOSS
// 	TE.SetRotorIronLosses(static_cast<float>(*u0[I_ROTOR_IRON_LOSS]));
//     #endif
//     #ifdef I_STATOR_IRON_LOSS
// 	TE.SetStatorIronLosses(static_cast<float>(*u0[I_STATOR_IRON_LOSS]));
//     #endif
// 	TE.SetStatorCopperLosses(static_cast<float>(*u0[I_STATOR_COPPER_LOSS]));
//     #ifdef I_STATOR_COPPER_LOSS2
//         TE.SetStatorCopperLosses2(static_cast<float>(*u0[I_STATOR_COPPER_LOSS2]));
//     #endif
// 	TE.SetCoolantTemperature(static_cast<float>(*u0[I_COOLANT]));
// 	TE.SetAmbientTemperature(static_cast<float>(*u0[I_AMBIENT]));
//     #ifdef I_BEARING_LOSS
// 	TE.SetBearingLoss(static_cast<float>(*u0[I_BEARING_LOSS]));
//     #endif
//     #ifdef I_WINDAGE_LOSS
// 	TE.SetWindageLoss(static_cast<float>(*u0[I_WINDAGE_LOSS]));
//     #endif
//    if(N_SCHEDULING_PARAMETER > 1)
//    {
        TE.UpdateStateSpace(static_cast<float>(*u0[N_INPUTS]));
//    }
//	else
//	{
//		TE.UpdateStateSpace();
//	}
	TE.ScaleBMatrixDueToTemperatureVariation();
	TE.IterateStateSpace();
	//MPC
	float Uopt[N_VAR_CONTROL_INPUTS] = {0.f};
	float resistance = 0.f;
    if (update_overload_current != calculate_overload_if_changed)
    {     
        timer = N_HORIZON;
        calculate_overload_if_changed = update_overload_current;
    }
    
	if (timer >= N_HORIZON)
	{
		timer = 0;
		TE.PredictiveControlCalculation();
		//calculate the average resistance over time assuming that the temperature rise is linear
		//resistance = WINDING_RESISTANCE * ( 1 + COPPER_LOSS_TEMPERATURE_FACTOR * ((TE.GetStatorAverage()+ref[0])/2 - COPPER_LOSS_REFERENCE_TEMPERATURE));
		TE.GetOptimalInputs(Uopt);
		if (Uopt[0] < 0)
		{
			Uopt[0] = 0.f;
		}
		//mpc_out = sqrt(Uopt[0]/resistance);
		mpc_out = Uopt[0];
	}
	//update timer for MPC
	timer++;
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
	//StateSpace output
	float output_vector[N_OUTPUTS];
	TE.GetOutputVector(output_vector);
	real_T *y0 = ssGetOutputPortRealSignal(S,0);
	for (int i = 0;i<N_OUTPUTS;i++)
	{
		y0[i] = output_vector[i];
	}
	//Hotspot Output
	real_T *y2 = ssGetOutputPortRealSignal(S,2);
	y2[0] = TE.GetStatorWindingHotspotTemperature();
    #ifdef N_ROTOR_STATES
	y2[1] = TE.GetRotorSquirrelCageHotspotTemperature();
    #else
    y2[1] = 0;
	#endif
	// MPC output
	real_T *y1 = ssGetOutputPortRealSignal(S,1);
	y1[0] = mpc_out;//current_stator;

}

static void mdlTerminate(SimStruct *S)
{
	
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
