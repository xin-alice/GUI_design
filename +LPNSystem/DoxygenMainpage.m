%>@author Fang Qi fqi@isea.rwth-aachen.de
%>@mainpage 
%>
%>
%>@section Introduction
%>
%>
%>This tool is used to create a lumped parameter network in simulink using simscape toolbox depending on the geometry and material information. The user can define the geometry, material and 
%>boundary conditions of the domain. 
%>You can describe the model in script, instantiate a builder of
%>clLumpedParameterNetwork and register all the component in builder.
%>or you can write your own class inherited from clThermalNetwork
%>@n use clLumpedParameterNetwork::RegisterComponent and clLumpedParameterNetwork::RegisterContact
%>to register components.
%>@n use clLumpedParameterNetwork::BuildEnvironment to build the network.
%>@n use clLumpedParameterNetwork::SetOption to set a simulation options.
%>for example steady state, output block 
%>All available options are in enumLPNBuilderOption
%>
%>
%>@section Verification of the Thermal Network
%>
%>
%>@n clThermalNetwork::StartVisualizerGUI
%>@n clThermalNetwork::StartGraphGUI 
%>@n clThermalNetwork::StartMasterGUI
%>@n clThermalNetwork::ShowAllThermalConnectionType
%>@n clLumpedParameterNetwork::ShowAllDivision to show how all component are
%>devided.
%>@n clLumpedParameterNetwork::ShowAllConnection to show all the connection.
%>a parameter of component name will show only the connection of this
%>component.
%>@n clLumpedParameterNetwork::ShowBuildingStatistic
%>@n clLumpedParameterNetwork::ShowSimulationStatistic
%>@n clLumpedParameterNetwork::ShowAllDivision
%>@n clLumpedParameterNetwork::ShowAllMeasuringPointsPosition
%>@n clLumpedParameterNetwork::ShowConnectionInOneDirectionOfComponent
%>@n clLumpedParameterNetwork::ShowAllConnectionOf
%>@n clLumpedParameterNetwork::ShowAllConnection
%>@n clLumpedParameterNetwork::ShowGraph
%>@n clLumpedParameterNetwork::ShowOpenComponents
%>
%>
%>@section Validation of the Thermal Network
%>
%>@par Comparison of Simulation and Measurement
%>@n clThermalNetwork::SetMeasuredTemperature Set measured temperature of a
%>sensor or any output of the LPTN
%>@n clThermalNetwork::PlotLosses Plot simulated losses of component. This
%>may be different as the input of the LPTN since the copper losses dependents on the real time temperature 
%>@n clThermalNetwork::CompareSimulatedTemperatureWithReference
%>@n clThermalNetwork::ParameterEstimation
%>@n clThermalNetwork::PlotAllSimulatedTemperature
%>@n clThermalNetwork::GetSimulatedTemperature
%>@n clThermalNetwork::ParameterEstimation
%>
%>
%>@section Export the Thermal Network
%>
%>
%>@n clThermalNetwork::GetToolStateSpaceConverter
%>@n clThermalNetwork::ConvertToStateSpace
%>@n clThermalNetwork::StartStateSpaceConverterGUI
%>@section Buildup of the Thermal Network
%>
%>
%>@par Stucture of LPTN
%>
%>
%>@n use clComponentThermalContact::InitContact to define the contact 
%>@code
%>contact_frame_yoke.InitContact(obj.frame,LPNEnum.enumCylindricalDirection.on_positive_direction_on_radial_axis,obj.yoke);
%>@endcode
%>@n use clComponentThermalContact::SetEnumerationThermalContact to choose a type of the thermal contact from LPNEnum.enumThermalContact
%>@code
%>contact_frame_yoke.SetEnumerationThermalContact(LPNEnum.enumThermalContact.iron_frame);
%>@endcode
%>@n use clComponentThermalContact::SetPartialContactPoint to set two
%>component to have a partial contact.
%>this point is defined as an offset between the origin nearest point of
%>the two component.
%>@code
%>contact_yoke_winding.SetPartialContactPoint(LPNEnum.enumCylindricalAxis.tangential,geo.MinimalStatorToothAngle);
%>@endcode
%>@n use clLPThermalComponent::CreateThermalComponent to create a new thermal component
%>@code  
%>frame = LPNComponent.clLPThermalComponent.CreateThermalComponent('frame',LPNEnum.enumThermalComponent.cylindrical);
%>@endcode
%>@n use clLPComponent::SetGeometry to set the size of the component
%>@code 
%>frame.SetGeometry([geo.r_frame_out geo.r_stator_yoke_out],geo.MinimalStatorAngle,geo.l_stator/2);
%>@endcode
%>or 
%>@code 
%>frame.SetGeometry(LPNEnum.enumCylindricalAxis.radial,[geo.r_frame_out geo.r_stator_yoke_out],LPNEnum.enumCylindricalAxis.tangential,geo.MinimalStatorAngle);
%>@endcode
%>@n use clThermalElement::SetEnumMaterial to choose a material from
%>enumThermalMaterial
%>@code 
%>frame.SetEnumMaterial(LPNEnum.enumThermalMaterial.structural_steel);
%>@endcode
%>@n use clLPComponent::SetResolution to set in which resolution the component should
%>be diveded. 
%>@code 
%>frame.SetResolution(3,3,3);
%>@endcode
%>or
%>@code 
%>frame.SetResolution(LPNEnum.enumCylindricalAxis.radial,3);
%>@endcode
%>
%>
%>@par Input of LPTN
%>
%>
%>@n clThermalNetwork::AddGroupLosses
%>@n clThermalNetwork::SetGlobalInitialTemperature
%>
%>
%>@par Output of LPTN
%>
%>
%>@n clThermalNetwork::AddGroupAverageTemperatureOutput
%>@n use clLPThermalComponent::OutputHotspotTemperature to create a output
%>of hotspot temperature, the optional parameter 1 create a scope block
%>@n use clLPThermalComponent::OutputAverageTemperature to create a output
%>of average temperature, the optional parameter 1 create a scope block
%>@n use clLPThermalComponent::OutputAllHeatFlux to set all relative
%>connections active to output heat flux.
%>@n use clLPThermalComponent::SetInputTemperature to set the component to have a input of temperature
%>@code
%>frame.SetInputTemperature(25,LPNEnum.enumCylindricalDirection.on_positive_direction_on_radial_axis);
%>@endcode
%>@n use clLPThermalComponent::SetInputHeatFlux to set the component to have a input of the losses
%>@n use constructor clComponentThermalContact to create a new contact
%>
%>@par Set Measurement
%>@par Magnetic Network
%>to be implemented
%>@page development
%>@brief development information
%>@par workflow of the program(for developing of the tool)
%>1. define the components(size, material,accuracy)
%>2. define the contact of the components
%>3. According to the contacts, the components are seperated to several domains, so that every domain have
%> full contact with other domain
%>4. Every domain will be initilized with the user defined resolution
%>5. go through all the connections, the connected domains must
%>have the same resolution on the interface. therefore the domain with
%>the smaller resolution take over the bigger resolution
%>6. the domain will be seperated to many units.
%>7. according to the old contacts and the inside contacts between the
%>domains, the ports needed will be calculated, the units-resistants will be calculated.