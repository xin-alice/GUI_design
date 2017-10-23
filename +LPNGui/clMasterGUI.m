classdef clMasterGUI < handle
	%clMasterGUI Summary of this class goes here
	%   Detailed explanation goes here
	
	properties(Access = private)
		hdl_figure;
		hdl_lptn;
        hdl_gui_builder
		hdl_gui_converter;
		hdl_gui_visualizer;
		hdl_gui_graphtool;
		hdl_tab_group;
		hdl_tab_converter;
		hdl_tab_visualizer;
		hdl_tab_graphtool;
	end
	
	methods
		function obj = clMasterGUI(visualizer,converter,lptn)
			obj.BuildGUI();
			obj.hdl_lptn = lptn;
			obj.hdl_gui_converter = LPNGui.clStateSpaceConverterGUI(converter,obj.hdl_tab_converter);
			obj.hdl_gui_visualizer = LPNGui.clVisualizerGUI(visualizer,obj.hdl_tab_visualizer,obj.hdl_figure);
			obj.hdl_gui_graphtool = LPNGui.clGraphToolGUI(lptn,obj.hdl_tab_graphtool);
		end
		function BuildGUI(obj)
			obj.hdl_figure = figure('Visible','off','Toolbar','figure','MenuBar','none','Name','LPN Builder Graphical Interface','Position',[100,75,1100,850],'Color',[0.94 0.94 0.94]);
			obj.hdl_tab_group = uitabgroup(obj.hdl_figure,'Units','normalized');
			obj.hdl_tab_visualizer = uitab(obj.hdl_tab_group,'Title','Visualizer');
			obj.hdl_tab_converter = uitab(obj.hdl_tab_group,'Title','State Space Converter');
			obj.hdl_tab_graphtool = uitab(obj.hdl_tab_group,'Title','Graph Tool');
			set(obj.hdl_figure,'Visible','on');
		end
		function SetVisualizerGUIHandle(obj, hdl_gui_visualizer)
			obj.hdl_gui_visualizer = hdl_gui_visualizer;
		end
		function SetConverterGUIHandle(obj, hdl_gui_converter)
			obj.hdl_gui_converter = hdl_gui_converter;
		end
	end
	
end

