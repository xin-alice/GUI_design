A = LPNComponent.clLPThermalComponent.CreateThermalComponent('A',LPNEnum.enumThermalComponent.rectangular);
A.SetGeometry(1,1,1);
% A.SetInputHeatFlux([0,1,3,5,10;100,200,400,500,30]');
A.SetInputHeatFlux(100000);
% A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
A.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
A.OutputAverageTemperature;

%A.SetResolution(2,2,2);
% table_input = [1:10;1:10]';
% A.SetInputHeatFlux(table_input);

% B = LPNComponent.clLPThermalComponent.CreateThermalComponent('B',LPNEnum.enumThermalComponent.rectangular);
% B.SetGeometry(1,1,1);
% %B.SetResolution(1,1,1);
% B.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
% B.SetInputTemperature(10,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis);
% B.OutputAverageTemperature;
% %B.OutputHotspotTemperature;

C = LPNComponent.clLPThermalComponent.CreateThermalComponent('C',LPNEnum.enumThermalComponent.rectangular);
C.SetGeometry(1,1,1);
%A.SetInputHeatFlux(100);
% A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
C.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
C.OutputAverageTemperature;
% C.AddMeasuringPoint('test',[0.5,0.5,1]);
% C.SetResolution(2,2,2);

% Air1 = LPNComponent.clLPThermalComponent.CreateThermalComponent('Air',LPNEnum.enumThermalComponent.shapeless);
% % Air2 = LPNComponent.clLPThermalComponent.CreateThermalComponent('Air2',LPNEnum.enumThermalComponent.shapeless);
% 
% Air1.OutputHotspotTemperature;
% Air2.OutputHotspotTemperature;

% c1 = LPNContact.clComponentThermalContact;
% c1.InitContact(Air1,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);%'y+'
% c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.air_gap_component);
% c1.SetContactRange(LPNEnum.enumRectangularAxis.x,[0.5,1],LPNEnum.enumRectangularAxis.x,[0,0.2]);
% c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
%c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,0.5,LPNEnum.enumRectangularAxis.z,0.5);
%c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
% c1.OutputHeatFlux;

% c2 = LPNContact.clComponentThermalContact;
% c2.InitContact(B,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air1);%'y+'
% % c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% % c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
% %c2.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,0.5,LPNEnum.enumRectangularAxis.z,0.5);
% c2.SetEnumerationThermalContact(LPNEnum.enumThermalVariableContact.example,5000);

c3 = LPNContact.clComponentThermalContact;
c3.InitContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,C)

% c3 = LPNContact.clComponentThermalContact;
% c3.InitContact(Air2, LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis, B);

% c4 = LPNContact.clComponentThermalContact;
% c4.InitContact(Air2, LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis, Air1);
% 			c1.SetThermalContactResistance(0.1);
% c2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air1);
% c3 = LPNContact.clComponentThermalContact(L,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);


builder = LPNSystem.clThermalNetwork;
builder.RegisterComponent(A);
% builder.RegisterComponent(B);
builder.RegisterComponent(C);
% builder.RegisterComponent(Air1);
% builder.RegisterComponent(Air2);
builder.SetOptions(LPNEnum.enumLPNBuilderOption.simulation_dynamic,LPNEnum.enumLPNBuilderOption.output_as_scope,LPNEnum.enumLPNBuilderOption.detailed_mode);
% builder.RegisterComponent(Air);
% builder.RegisterComponent(Air1);
% builder.RegisterContact(c1);
% builder.RegisterContact(c2);
builder.RegisterContact(c3);
% builder.RegisterContact(c4);
% builder.RegisterContact(c_air1);
% builder.RegisterContact(c_air2);

% test_measuring_point = builder.AddMeasuringPoint('test_measuring_point',A,[0.5,1,0.5]);
% test_measuring_point.SetAttachedSensor(Air1,LPNEnum.enumThermalContact.air_gap_component,1e-3,1e-4,LPNEnum.enumThermalMaterial.filled_epoxy_resin_X238);
builder.SetGlobalInitialTemperature(25);
builder.BuildEnvironment('test');
builder.SetSimscapeLogging;
builder.StartSimulation;
% builder.PlotComponentsSingle({'A'},5, 0.1, 1,1,1);
% builder.DrawComponentsSingle({'A'},5);
% builder.CreateProtectedSubsystem;