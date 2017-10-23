Winding = LPNComponent.clLPThermalComponent.CreateThermalComponent('Winding',LPNEnum.enumThermalComponent.rectangular);
Winding.SetGeometry(0.1,0.1,0.1);
Winding.SetInputHeatFlux(1000);
% A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
Winding.SetEnumMaterial(LPNEnum.enumThermalMaterial.winding);
Winding.OutputAverageTemperature;
%A.AddMeasuringPoint('test',[0.5,0.5,1]);
% Winding.SetResolution(2,2,2);
% table_input = [1:10;1:10]';
% A.SetInputHeatFlux(table_input);

Housing = LPNComponent.clLPThermalComponent.CreateThermalComponent('Housing',LPNEnum.enumThermalComponent.rectangular);
Housing.SetGeometry(0.1,0.01,0.1);
%B.SetResolution(1,1,1);
Housing.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
Housing.SetInputTemperature(25,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis);
Housing.OutputAverageTemperature;
%B.OutputHotspotTemperature;

% C = LPNComponent.clLPThermalComponent.CreateThermalComponent('C',LPNEnum.enumThermalComponent.rectangular);
% C.SetGeometry(1,1,1);
% %A.SetInputHeatFlux(100);
% % A.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
% C.SetEnumMaterial(LPNEnum.enumThermalMaterial.MotorCAD_Aluminium_Cast);
% C.OutputAverageTemperature;
% % C.AddMeasuringPoint('test',[0.5,0.5,1]);
% C.SetResolution(2,2,2);

% Air1 = LPNComponent.clLPThermalComponent.CreateThermalComponent('Air',LPNEnum.enumThermalComponent.shapeless);
% % Air2 = LPNComponent.clLPThermalComponent.CreateThermalComponent('Air2',LPNEnum.enumThermalComponent.shapeless);
% 
% Air1.OutputHotspotTemperature;
% Air2.OutputHotspotTemperature;

c1 = LPNContact.clComponentThermalContact;
c1.InitContact(Housing,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Winding);%'y+'
c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.lamination_winding);
% c1.SetContactRange(LPNEnum.enumRectangularAxis.x,[0.5,1],LPNEnum.enumRectangularAxis.x,[0,0.2]);
% c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
%c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,0.5,LPNEnum.enumRectangularAxis.z,0.5);
%c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
% c1.OutputHeatFlux;

% c2 = LPNContact.clComponentThermalContact;
% c2.InitContact(Housing,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air1);%'y+'
% % c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% % c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
% %c2.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,0.5,LPNEnum.enumRectangularAxis.z,0.5);
% c2.SetEnumerationThermalContact(LPNEnum.enumThermalVariableContact.example,5000);
% 
% c3 = LPNContact.clComponentThermalContact;
% c3.InitContact(Winding,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,C);%'y+'
% % c3 = LPNContact.clComponentThermalContact;
% % c3.InitContact(Air2, LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis, B);
% 
% % c4 = LPNContact.clComponentThermalContact;
% % c4.InitContact(Air2, LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis, Air1);
% % 			c1.SetThermalContactResistance(0.1);
% % c2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air1);
% % c3 = LPNContact.clComponentThermalContact(L,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);


builder = LPNSystem.clThermalNetwork;
builder.RegisterComponent(Winding);
builder.RegisterComponent(Housing);
% builder.RegisterComponent(C);
% builder.RegisterComponent(Air1);
% builder.RegisterComponent(Air2);
builder.SetOptions(LPNEnum.enumLPNBuilderOption.output_as_scope);
% builder.RegisterComponent(Air);
% builder.RegisterComponent(Air1);
builder.RegisterContact(c1);
% builder.RegisterContact(c2);
% builder.RegisterContact(c3);
% builder.RegisterContact(c4);
% builder.RegisterContact(c_air1);
% builder.RegisterContact(c_air2);
builder.BuildEnvironment('test');
builder.SetSimscapeLogging;
builder.StartSimulation(1000);
% builder.PlotComponentsSingle({'A'},5, 0.1, 1,1,1);
% builder.DrawComponentsSingle({'A'},5);
% builder.CreateProtectedSubsystem;