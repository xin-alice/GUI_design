classdef clStateSpaceConverterGUI < handle
	%clVisualizerGUI Provides a GUI for the Visualizer
	%   Detailed explanation goes here
	
	properties(Access = private)
		%specifies whether this GUI is a subwindow or standalone
		standalone = 1;
		%handle to the visualizer which does the actual component drawing
		hdl_state_space_converter;
		%handles to the UI items
		hdl_figure;
		hdl_axes;
		hdl_disclaimer;
		hdl_convert_button;
		hdl_timestep;
		hdl_timestep_label;
		hdl_horizon;
		hdl_horizon_label;			
	end
	methods
		%>@brief ctor
		function obj = clStateSpaceConverterGUI(hdl_state_space_converter,varargin)
			%if a optional figure handle is provided in the ctor, use this
			%set flag standalone to indicate whether this GUI is used alone
			%or in a tab
			if numel(varargin) == 1
				if ishandle(varargin{1})
					obj.hdl_figure = varargin{1};
					obj.standalone = 0;
				end
			end
			obj.hdl_state_space_converter = hdl_state_space_converter;
			obj.BuildGUI();
		end
		%>@brief function that contatins all gui elements
		function BuildGUI(obj)
			if obj.standalone
				obj.hdl_figure = figure('Visible','off','Toolbar','none','MenuBar','None','Name','LPN State Space Converter','Position',[150,100,1000,800],'Color',[0.94 0.94 0.94]);
			end
			obj.hdl_axes = axes('Parent', obj.hdl_figure, 'Units','pixels','Position',[250,400,600,400]);
			print(['-s',obj.hdl_state_space_converter.GetModelName()],'-dpng',obj.hdl_state_space_converter.GetModelName());
			h = imread([obj.hdl_state_space_converter.GetModelName() '.png']);
			imshow(h, 'Parent', obj.hdl_axes);
			str_disclaimer = sprintf(['The Simulink Model must be of certain structure to be able to be converted:\n'...
				'There must only be seven inputs (iron, stator, copper, bearing and windage losses and ambient and coolant temperatures).\n'...
				'Only average output temperatures are allowed.']);
			obj.hdl_disclaimer = uicontrol('Parent',obj.hdl_figure,'Style','text',...
				'String',str_disclaimer,...
				'Position',[150 350 700 50]);
			obj.hdl_timestep_label = uicontrol('Parent',obj.hdl_figure,'Style','text',...
				'String','Discretization Time [s]:',...
				'Position',[80 300 120 20]);
			obj.hdl_timestep = uicontrol('Parent',obj.hdl_figure,'Style','edit',...
				'String','1',...
				'Position',[200 300 120 20]);
			obj.hdl_horizon_label = uicontrol('Parent',obj.hdl_figure,'Style','text',...
				'String','Prediction Horizon [n * timestep]:',...
				'Position',[340 300 160 20]);
			obj.hdl_horizon = uicontrol('Parent',obj.hdl_figure,'Style','edit',...
				'String','1',...
				'Position',[500 300 120 20]);
			obj.hdl_convert_button = uicontrol('Parent',obj.hdl_figure,'Style','pushbutton','String','Start Conversion',...
                'Position',[700 290 100 40],...
				'Callback',@obj.Convert);
			if obj.standalone
				set(obj.hdl_figure,'Visible','on');
			end
		end
		%>@brief callback function for the convert button
		function Convert(obj,~,~)
			%get data
			timestep = str2double(get(obj.hdl_timestep,'String'));
			n_horizon = round(str2double(get(obj.hdl_horizon,'String')));
			%setup converter
			obj.hdl_state_space_converter.SetDiscretizationTimeStep(timestep);
			obj.hdl_state_space_converter.SetPredictionHorizon(n_horizon);
			%perform conversion
			obj.hdl_state_space_converter.GenerateCFilesForMPC();
		end
	end
end

