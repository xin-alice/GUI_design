A = LPNComponent.clLPThermalComponent.CreateThermalComponent('A',LPNEnum.enumThermalComponent.rectangular);
A.SetGeometry(2,1,1);
A.SetInputHeatFlux(1000);
A.SetResolution(3,3,1);
A.SetInputTemperature(25,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis);
A.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
% A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_positive_direction_on_x_axis);
A.OutputHotspotTemperature;
% A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_positive_direction_on_x_axis);
 A.AddMeasuringPoint('M1',[0.3,0.5,0.5]);
% A.AddMeasuringPoint('M12',[1,0.5,0.5]);
% A.AddMeasuringPoint('M13',[2,0.5,0.5]);
% A.AddMeasuringPoint('M14',[0.2,0.5,0.5]);

B = LPNComponent.clLPThermalComponent.CreateThermalComponent('B',LPNEnum.enumThermalComponent.rectangular);
B.SetGeometry(1,1,1);
B.SetResolution(3,3,1);
B.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
B.OutputAverageTemperature;
B.SetInputTemperature(25,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
% B.AddMeasuringPoint('M2',[0.7,0.5,0.5]);
% B.AddMeasuringPoint('M3',[0.3,0.5,0.5]);
%B.OutputHotspotTemperature;
%B.OutputAllTemperature
c1 = LPNContact.clComponentThermalContact;
c1.InitContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.iron_frame);

builder = LPNSystem.clThermalNetwork;
builder.RegisterComponent(A);
builder.RegisterComponent(B);
builder.RegisterContact(c1);
builder.SetOptions(LPNEnum.enumLPNBuilderOption.simulation_steady_state,	LPNEnum.enumLPNBuilderOption.output_as_scope,LPNEnum.enumLPNBuilderOption.detailed_mode);



builder.BuildEnvironment('test');

[value,time] = builder.GetSimulatedTemperature(A,'M1');
plot(time,value);
builder.SetSimscapeLogging;
builder.StartSimulation;
builder.DrawComponentsMerged({'A','B'});
% builder.CreateProtectedSubsystem;