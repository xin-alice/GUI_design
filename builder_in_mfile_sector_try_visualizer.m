joch = LPNComponent.clLPThermalComponent.CreateThermalComponent('joch',LPNEnum.enumThermalComponent.cylindrical);
joch.SetGeometry([3,5],pi/3,1);
joch.SetResolution(2,2,1);
joch.SetEnumMaterial(LPNEnum.enumThermalMaterial.iron);
joch.SetInputTemperature(25,LPNEnum.enumCylindricalDirection.on_positive_direction_on_radial_axis);
joch.OutputAverageTemperature;
joch.OutputHotspotTemperature;
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

teeth = LPNComponent.clLPThermalComponent.CreateThermalComponent('teeth',LPNEnum.enumThermalComponent.cylindrical);
teeth.SetGeometry([2,3],pi/6,1);
teeth.SetResolution(2,2,1);
teeth.SetEnumMaterial(LPNEnum.enumThermalMaterial.iron);
teeth.SetInputHeatFlux(1000);
teeth.OutputAverageTemperature;
teeth.OutputHotspotTemperature;
% C = clLPThermalCoolant('C');
% C.SetInputTemperature(25);
% C.SetComponentType(LPNEnum.enumThermalComponent.rectangular);
% C.SetGeometry(3,1,3);
% 
% 
% L = clLPThermalAir('L');

teeth_joch = LPNContact.clComponentThermalContact;
teeth_joch.InitContact(teeth,LPNEnum.enumCylindricalDirection.on_negative_direction_on_radial_axis,joch);%'y+'
% c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,1,LPNEnum.enumRectangularAxis.z,1);
% c1.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
% c1.OutputHeatFlux;
% 			c1.SetThermalContactResistance(0.1);
% c2 = LPNContact.clComponentThermalContact(A,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,C);
% c3 = LPNContact.clComponentThermalContact(L,LPNEnum.enumRectangularDirection.on_positive_direction_on_y_axis,A);


builder = LPNSystem.clThermalNetwork;
builder.RegisterComponent(joch);
builder.RegisterComponent(teeth);
% builder.RegisterComponent(D);
% builder.RegisterComponent(C);
builder.RegisterContact(teeth_joch);
% builder.RegisterContact(c2);
% builder.RegisterContact(c3);
builder.BuildEnvironment('stator');
builder.SetSimscapeLogging;
builder.StartSimulation();
%builder.PlotComponents({'teeth'}, 5, 0.01, 1, 1, 1);
builder.DrawComponentsSingle({'teeth'}, 5);