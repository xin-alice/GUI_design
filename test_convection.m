A = LPNComponent.clLPThermalComponent('A');
A.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
A.SetGeometry(1,1,1);
A.SetResolution(2,2,1);
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

B = LPNComponent.clLPThermalComponent('B');
B.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
B.SetGeometry(1,1,1);
B.SetResolution(1,1,1);
B.SetEnumMaterial(LPNEnum.enumThermalMaterial.sample_material);
B.SetInputTemperature(0,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis);

% Air = LPNComponent.clLPThermalComponent('Air');
% Air.SetComponentType(LPNEnum.enumThermalComponent.Air);
Air = LPNComponent.clLPThermalComponent.CreateThermalComponent('Air',LPNEnum.enumThermalComponent.shapeless);
% C = clLPThermalCoolant('C');
% C.SetInputTemperature(25);
% C.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
% C.SetGeometry(3,1,3);
% 
% 
% L = clLPThermalAir('L');

c1 = LPNContact.clComponentThermalContact(B,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);%'y+'
c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,0.5,LPNEnum.enumRectangularAxis.z,0.5);
c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
c1.OutputHeatFlux;
% 			c1.SetThermalContactResistance(0.1);
% c2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,C);
% c3 = LPNContact.clComponentThermalContact(L,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);
c_air1 = LPNContact.clComponentThermalContact(Air,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,B);%'y+'
c_air1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
c_air2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,Air);%'y+'
c_air2.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
builder = clLumpedParameterNetwork;
builder.RegisterComponent(A);
builder.RegisterComponent(B);
builder.RegisterComponent(Air);
% builder.RegisterComponent(C);
builder.RegisterContact(c1);
builder.RegisterContact(c_air1);
builder.RegisterContact(c_air2);
builder.BuildEnvironment('test');