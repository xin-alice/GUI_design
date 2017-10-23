joch = LPNComponent.clLPThermalComponent.CreateThermalComponent('joch',LPNEnum.enumThermalComponent.cylindrical);
joch.SetGeometry([3,4],pi/3,2);
joch.SetResolution(2,2,2);
joch.SetEnumMaterial(LPNEnum.enumThermalMaterial.iron);
joch.SetInputTemperature(25,LPNEnum.enumCylindricalDirection.on_positive_direction_on_radial_axis);
joch.OutputAverageTemperature();
joch.OutputHotspotTemperature();

teeth = LPNComponent.clLPThermalComponent.CreateThermalComponent('teeth',LPNEnum.enumThermalComponent.cylindrical);
teeth.SetGeometry([2,3],pi/6,2);
teeth.SetResolution(1,1,1);
teeth.SetEnumMaterial(LPNEnum.enumThermalMaterial.iron);
teeth.SetInputHeatFlux(500);
teeth.OutputAverageTemperature();
teeth.OutputHotspotTemperature();

teeth_joch = LPNContact.clComponentThermalContact;
teeth_joch.InitContact(teeth,LPNEnum.enumCylindricalDirection.on_negative_direction_on_radial_axis,joch);%'y+'
% c1.SetPartialContactPoint(LPNEnum.enumRectangularAxis.x,1,LPNEnum.enumRectangularAxis.z,1);
teeth_joch.SetEnumerationThermalContact(LPNEnum.enumThermalContact.sample_contact);
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
builder.SetOptions(LPNEnum.enumLPNBuilderOption.output_as_display,LPNEnum.enumLPNBuilderOption.simulation_steady_state,LPNEnum.enumLPNBuilderOption.use_symbolic_representation)%,LPNEnum.enumLPNBuilderOption.expand_number_squared);

builder.BuildEnvironment('stator');
%builder.DrawComponents({'joch','teeth'}, 5, 'merged')