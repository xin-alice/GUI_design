A = LPNComponent.clLPThermalComponent.CreateThermalComponent('A',LPNEnum.enumThermalComponent.rectangular);
A.SetGeometry(2,1,2);
A.SetResolution(2,1,2);
A.SetInputHeatFlux(100);
A.SetEnumMaterial(LPNEnum.enumThermalMaterial.sample_material);
% A.SetTemperatureInput(0,LPNEnum.enumRectangularDirection.on_negative_direction_on_y_axis);
% D = LPNComponent.clLPThermalComponent('D');
% D.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
% D.SetGeometry(1,1,1);
% D.SetResolution(1,1,1);
% %			A.SetUnitSize(0.5);
% % A.SetHeatFluxInput;
% D.SetEnumMaterial(LPNEnum.enumThermalMaterial.sample_material);
% A.OutputHotspotTemperature;
% A.OutputAverageTemperature;

B = LPNComponent.clLPThermalComponent.CreateThermalComponent('B',LPNEnum.enumThermalComponent.rectangular);
B.SetGeometry(1,1,1);
B.SetResolution(1,1,1);
B.SetEnumMaterial(LPNEnum.enumThermalMaterial.sample_material);
B.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis);

% Air = LPNComponent.clLPThermalComponent('Air');
% Air.SetComponentType(LPNEnum.enumThermalComponent.Air);

% C = clLPThermalCoolant('C');
% C.SetInputTemperature(25);
% C.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
% C.SetGeometry(3,1,3);
% 
% 
% L = clLPThermalAir('L');

c1 = LPNContact.clComponentThermalContact;
c1.InitContact(B,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);%'y+'
% c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
% c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
% c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,1,LPNEnum.enumRectangularAxis.z,1);
% c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
% c1.OutputHeatFlux;
% 			c1.SetThermalContactResistance(0.1);
% c2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,C);
% c3 = LPNContact.clComponentThermalContact(L,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);


builder = clThermalNetwork;
builder.RegisterComponent(A);
builder.RegisterComponent(B);
% builder.RegisterComponent(D);
% builder.RegisterComponent(C);
builder.RegisterContact(c1);
% builder.RegisterContact(c2);
% builder.RegisterContact(c3);
builder.BuildEnvironment('test');
builder.StartSimulation();
