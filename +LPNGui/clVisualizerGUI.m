classdef clVisualizerGUI < handle
	%clVisualizerGUI Provides a GUI for the Visualizer
	%   Detailed explanation goes here
	
	properties(Access = private)
		%specifies whether this GUI is a subwindow or standalone
		standalone = 1;
		%figure and parent are not the same when created in a tab
		hdl_figure;
		hdl_parent;
		%handle to the visualizer which does the actual component drawing
		hdl_network_visualizer;
		%ui stuff
		hdl_list;
		hdl_list_label;
		hdl_drawbutton;
		hdl_savebutton;
		hdl_save_label;
		hdl_save_name;
		hdl_options;
		hdl_options_slice;
		hdl_options_3d;
		hdl_options_shapes;
		hdl_options_3d_video;
		hdl_options_slice_video;
		hdl_slices_label;
		hdl_slices1;
		hdl_slices1_label;
		hdl_slices2;
		hdl_slices2_label;
		hdl_slices3;
		hdl_slices3_label;
		hdl_time;
		hdl_time_label;
		hdl_resolution;
		hdl_resolution_label;
		hdl_axes;
		hdl_overlay;
		hdl_discretization;
		hdl_measuring_points;
		hdl_color_start;
		hdl_color_end;
		hdl_color_auto;
		hdl_color_label;
		hdl_color_label2;
		hdl_transparency_label;
		hdl_transparency;
		hdl_rotate;
		hdl_datacursor;
		hdl_resetaxes;
		%store the component name
		cell_str_component_names = {};
	end
	methods
		%>@brief ctor
		function obj = clVisualizerGUI(hdl_network_visualizer, varargin)
			%if a optional figure handle is provided in the ctor, use this
			%set flag standalone to indicate whether this GUI is used alone
			%or in a tab
			if numel(varargin) > 1
				if ishandle(varargin{1})
					obj.hdl_parent = varargin{1};
					obj.hdl_figure = varargin{2};
					obj.standalone = 0;
				end
			end
			obj.hdl_network_visualizer = hdl_network_visualizer;
			obj.cell_str_component_names = obj.hdl_network_visualizer.GetAllDrawableComponentNames();
			obj.BuildGUI();
			obj.SetVisualizerAxisHandle();
		end
		%>@brief function that contatins all gui elements
		function BuildGUI(obj)
			if obj.standalone
				obj.hdl_parent = figure('Visible','off','Toolbar','figure','MenuBar','none','Name','LPN Visualizer','Position',[150,100,1000,800],'Color',[0.94 0.94 0.94]);
				%when standalone the figure is the parent
				obj.hdl_figure = obj.hdl_parent;
			end
			obj.hdl_list_label = uicontrol(obj.hdl_parent,'Style','text',...
				'String','Select Components:',...
				'Position',[20 760 100 20]);
			num = numel(obj.cell_str_component_names);
			%display available components
			obj.hdl_list = uitable('Parent', obj.hdl_parent, 'Data', false(num,1),...
				'ColumnName', {'Draw'},...
				'ColumnFormat', {'logical'},...
				'ColumnEditable', [true],...
				'RowName',obj.cell_str_component_names,...
				'Position',[20 500 250 260]);
			%draw buttons
			obj.hdl_drawbutton = uicontrol('Parent',obj.hdl_parent,'Style','pushbutton','String','Draw',...
				'Position',[550 20 60 40],...
				'Callback',@obj.Draw);
			obj.hdl_overlay = uicontrol('Parent',obj.hdl_parent,'Style','checkbox',...
				'String','Overlay with previous',...
				'Value',0,'Position',[615 30 130 20]);
			%save options
			obj.hdl_savebutton = uicontrol('Parent',obj.hdl_parent,'Style','pushbutton','String','Save Figure',...
				'Position',[750 20 100 40],...
				'Callback',@obj.SaveFigure);
			obj.hdl_save_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Specify file name (without extension)','Position',[870 40 100 40]);
			obj.hdl_save_name = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','myFigure', 'Position',[870 20 100 20]);
			%draw options panel
			obj.hdl_options = uibuttongroup('Parent',obj.hdl_parent,'Title','Draw Options',...
				'Units','pixels',...
				'Position',[20 300 150 180]);
			obj.hdl_options_3d = uicontrol('Parent',obj.hdl_options,'Style','radiobutton','String','3D',...
				'Units','normalized','Tag','3d','Callback',@obj.Draw3DOptionCallback,...
				'Position',[.1 .825 .8 .2]);
			obj.hdl_options_slice = uicontrol('Parent',obj.hdl_options,'Style','radiobutton','String','Slices',...
				'Units','normalized','Tag','slice','Callback',@obj.SliceOptionCallback,...
				'Position',[.1 .625 .8 .2]);
			obj.hdl_options_3d_video = uicontrol('Parent',obj.hdl_options,'Style','radiobutton','String','3D Video',...
				'Units','normalized','Tag','3d video','Callback',@obj.Video3DOptionsCallback,...
				'Position',[.1 .425 .8 .2]);
			obj.hdl_options_slice_video = uicontrol('Parent',obj.hdl_options,'Style','radiobutton','String','Slice Video',...
				'Units','normalized','Tag','slice video','Callback',@obj.SliceVideoOptionsCallback,...
				'Position',[.1 .225 .8 .2]);
			obj.hdl_options_shapes = uicontrol('Parent',obj.hdl_options,'Style','radiobutton','String','Shapes only',...
				'Units','normalized','Tag','shapes','Callback',@obj.ShapeOptionsCallback,...
				'Position',[.1 .025 .8 .2]);
			%specify label position for each dimension
			obj.hdl_slices_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Enter slice coordinates for each dimension:',...
				'Position',[20 210 120 30]);
			obj.hdl_slices1_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Dim 1:',...
				'Position',[20 190 60 20]);
			obj.hdl_slices1 = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','1','enable','off',...
				'Position',[80 190 60 20]);
			obj.hdl_slices2_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Dim 2:',...
				'Position',[20 170 60 20]);
			obj.hdl_slices2 = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','1','enable','off',...
				'Position',[80 170 60 20]);
			obj.hdl_slices3_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Dim 3:',...
				'Position',[20 150 60 20]);
			obj.hdl_slices3 = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','1','enable','off',...
				'Position',[80 150 60 20]);
			%specify simulation time
			obj.hdl_time_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Enter Simulation Time [s]:',...
				'Position',[20 120 130 20]);
			obj.hdl_time = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String',num2str(obj.hdl_network_visualizer.GetLastTimeInstant()),...
				'Position',[20 100 120 20]);
			%specify interpolation resolution
			obj.hdl_resolution_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Interpolation Resolution:',...
				'Position',[20 70 120 20]);
			obj.hdl_resolution = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','1',...
				'Position',[20 50 120 20]);
			%specify color range
			obj.hdl_color_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Temperature Range [°C]:',...
				'Position',[150 210 120 30]);
			obj.hdl_color_start = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','0','enable','off',...
				'Position',[160 190 30 20]);
			obj.hdl_color_label2 = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','-',...
				'Position',[190 190 10 20]);
			obj.hdl_color_end = uicontrol('Parent',obj.hdl_parent,'Style','edit',...
				'String','100','enable','off',...
				'Position',[200 190 30 20]);
			obj.hdl_color_auto = uicontrol('Parent',obj.hdl_parent,'Style','checkbox',...
				'String','auto','Callback',@obj.AutoRangeCallback,...
				'Value',1,'Position',[160 160 60 20]);
			obj.hdl_transparency_label = uicontrol('Parent',obj.hdl_parent,'Style','text',...
				'String','Transparency',...
				'Position',[160 120 100 20]);
			obj.hdl_transparency = uicontrol('Parent',obj.hdl_parent,'Style','slider',...
				'Min',0,'Max',1,'SliderStep',[0.05 0.1],'Value',1,...
				'Position',[160 100 100 20]);
			%show component discretization or not
			obj.hdl_discretization = uicontrol('Parent',obj.hdl_parent,'Style','checkbox',...
				'String','Show Component Discretization',...
				'Value',0,'Position',[20 275 180 20]);
			%show measuring points or not
			obj.hdl_measuring_points = uicontrol('Parent',obj.hdl_parent,'Style','checkbox',...
				'String','Show Measuring Points',...
				'Value',0,'Position',[20 245 180 20]);
			%provide some options for axes
			obj.hdl_rotate = uicontrol('Parent',obj.hdl_parent,'Style','pushbutton','String','Toggle Rotation',...
				'Position',[200 20 100 40],...
				'Callback',@obj.ToggleRotationCallback);
			obj.hdl_datacursor = uicontrol('Parent',obj.hdl_parent,'Style','pushbutton','String','Toggle DataCursor',...
				'Position',[300 20 100 40],...
				'Callback',@obj.ToggleDataCursorCallback);
			dcm_obj = datacursormode(obj.hdl_figure);
			set(dcm_obj,'UpdateFcn',@obj.DataCursorCallback)
			obj.hdl_resetaxes = uicontrol('Parent',obj.hdl_parent,'Style','pushbutton','String','Reset Axes',...
				'Position',[400 20 100 40],...
				'Callback',@obj.ResetAxesCallback);
			%main axes
			obj.hdl_axes = axes('Parent',obj.hdl_parent,'Units','pixels','Position',[320,140,680,640]);
	
			if obj.standalone
				set(obj.hdl_parent,'Visible','on');
			end
		end
		%>@brief set the parent handle for the visualizer
		function SetVisualizerAxisHandle(obj)
			obj.hdl_network_visualizer.SetAxisHandle(obj.hdl_axes);
		end
		%>@brief callback function for the draw button
		function Draw(obj,~,~)
			%clear the error message
			%get the selected components from the list
			get_data = get(obj.hdl_list,'Data');
			selected_components = {};
			for i=1:numel(get_data)
				if get_data(i)
					selected_components{end+1} = obj.cell_str_component_names{i};
				end
			end
			%get the draw option and select for visualizer accordingly
			selected_option = get(get(obj.hdl_options,'SelectedObject'), 'Tag');
			draw_option = 1;
			bool_video = 0;
			switch selected_option
				case '3d'
					draw_option = 1;
				case 'shapes'
					draw_option = 3;
				case 'slice';
					draw_option = 2;
				case '3d video'
					bool_video = 1;
					draw_option = 1;
				case 'slice video'
					bool_video = 1;
					draw_option = 2;
			end
			%get specified slices
			slices1 = str2double(strsplit(get(obj.hdl_slices1,'String'),{',',';',' '}));
			slices2 = str2double(strsplit(get(obj.hdl_slices2,'String'),{',',';',' '}));
			slices3 = str2double(strsplit(get(obj.hdl_slices3,'String'),{',',';',' '}));
			transparency = get(obj.hdl_transparency,'Value');
			%get the graph resolution
			resolution = str2double(get(obj.hdl_resolution,'String'));
			%get whether the old drawing will be kept and clear axes if not
			overlay = get(obj.hdl_overlay,'value');
			autorange = get(obj.hdl_color_auto,'value');
			show_discretization = get(obj.hdl_discretization,'value');
			show_measuring_points =  get(obj.hdl_measuring_points,'value');
			if ~overlay
				cla(obj.hdl_axes);%,'reset')
			end
			%get the simulation time that will be visualized
			time = str2double(get(obj.hdl_time,'String'));
			if ~isempty(selected_components)
				obj.hdl_network_visualizer.SetComponentsForVisualizing(selected_components);
				obj.hdl_network_visualizer.SetGraphResolution(resolution);
				obj.hdl_network_visualizer.SetTransparency(transparency);
				if draw_option == 2
					obj.hdl_network_visualizer.SetSlices(slices1,slices2,slices3);
				end
				if autorange
					obj.hdl_network_visualizer.SetColorRange('auto');
				else
					obj.hdl_network_visualizer.SetColorRange([str2double(get(obj.hdl_color_start,'String')) str2double(get(obj.hdl_color_end,'String'))]);
				end
				if bool_video
					obj.hdl_network_visualizer.VisualizeMergedComponentsOverTime(draw_option, show_discretization, show_measuring_points);
				else
					obj.hdl_network_visualizer.SetTime(time);
					obj.hdl_network_visualizer.VisualizeMergedComponents(draw_option, show_discretization, show_measuring_points);
				end
			end
		end
		function SaveFigure(obj,~,~)
			obj.hdl_network_visualizer.SaveFigure(get(obj.hdl_save_name,'String'));
		end
		function AutoRangeCallback(obj,~,~)
			if strcmp(get(obj.hdl_color_end,'enable'),'on')
				set(obj.hdl_color_end,'enable', 'off')
				set(obj.hdl_color_start,'enable', 'off')
			else
				set(obj.hdl_color_end,'enable', 'on')
				set(obj.hdl_color_start,'enable', 'on')
			end
		end
		function Video3DOptionsCallback(obj,~,~)
			set(obj.hdl_time,'enable','off')
			set(obj.hdl_slices1,'enable','off')
			set(obj.hdl_slices2,'enable','off')
			set(obj.hdl_slices3,'enable','off')
			set(obj.hdl_resolution,'enable','on');
		end
		function ShapeOptionsCallback(obj,~,~)
			set(obj.hdl_time,'enable','off')
			set(obj.hdl_slices1,'enable','off')
			set(obj.hdl_slices2,'enable','off')
			set(obj.hdl_slices3,'enable','off')
			set(obj.hdl_resolution,'enable','off');
		end
		function Draw3DOptionCallback(obj,~,~)
			set(obj.hdl_time,'enable','on')
			set(obj.hdl_slices1,'enable','off')
			set(obj.hdl_slices2,'enable','off')
			set(obj.hdl_slices3,'enable','off')
			set(obj.hdl_resolution,'enable','on');
		end
		function SliceOptionCallback(obj,~,~)
			set(obj.hdl_time,'enable','on')
			set(obj.hdl_slices1,'enable','on')
			set(obj.hdl_slices2,'enable','on')
			set(obj.hdl_slices3,'enable','on')
			set(obj.hdl_resolution,'enable','on');
		end
		function SliceVideoOptionsCallback(obj,~,~)
			set(obj.hdl_time,'enable','off')
			set(obj.hdl_slices1,'enable','on')
			set(obj.hdl_slices2,'enable','on')
			set(obj.hdl_slices3,'enable','on')
			set(obj.hdl_resolution,'enable','on');
		end
		function output_txt = DataCursorCallback(~,~,event_obj)
			pos = event_obj.Position;
			if isempty(event_obj.Target.Vertices)
				output_txt = {['X: ',num2str(pos(1),4)],...
						['Y: ',num2str(pos(2),4)],...
						['Z: ',num2str(pos(3),4)]};
			else
				[~,indx]=ismember(pos,event_obj.Target.Vertices,'rows');
				temperature = event_obj.Target.FaceVertexCData(indx);
				output_txt = {['X: ',num2str(pos(1),4)],...
					['Y: ',num2str(pos(2),4)],...
					['Z: ',num2str(pos(3),4)],...
					['Temperature [°C]: ', num2str(temperature,4)]};
			end
		end
		function ToggleDataCursorCallback(obj,~,~)
			datacursormode(obj.hdl_figure)
		end
		function ToggleRotationCallback(obj,~,~)
			rotate3d(obj.hdl_axes);
		end
		function ResetAxesCallback(obj,~,~)
			cla(obj.hdl_axes,'reset');
		end
	end
end

