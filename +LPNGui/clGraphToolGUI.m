classdef clGraphToolGUI < handle
	%clGraphToolGUI Provides a GUI for the GraphTool
	
	properties(Access = private)
		%specifies whether this GUI is a subwindow or standalone
		standalone = 1;
		hdl_lptn
		%handles to the UI items
		hdl_figure;
		
		hdl_contacts;
		hdl_contacts_group;
		hdl_contacts_text;
		hdl_contacts_help;
		hdl_contacts_edit;
		
		hdl_information;
		hdl_information_group;
		hdl_information_text;
		hdl_information_help;
		hdl_information_edit;
		
		hdl_openbutton;
		hdl_showbutton;
		%options of GraphTool
        cell_contacts;
        cell_information;
	end
	
	methods
		function obj = clGraphToolGUI(hdl_lptn,varargin)
			if numel(varargin) == 1
				if ishandle(varargin{1})
					obj.hdl_figure = varargin{1};
					obj.standalone = 0;
				end
			end
			obj.hdl_lptn = hdl_lptn;
            [members, obj.cell_information] = enumeration('LPNEnum.enumGraphOption');
            [members, obj.cell_contacts] = enumeration('LPNEnum.enumGraphContacts');
			obj.BuildGUI();
		end
	end
	methods(Access = private)
		function BuildGUI(obj)
			if obj.standalone
				obj.hdl_figure = figure('Visible','off','Toolbar','none','MenuBar','None','Name','LPN GraphTool','Units','normalized','Position',[.33,.33,.33,.33],'Color',[0.94 0.94 0.94]);
			end
			obj.hdl_contacts_group = uibuttongroup('Parent', obj.hdl_figure, 'Title', 'Select Contacts:','Units','normalized', 'Position', [.05,.2,.425,.75])';
			obj.hdl_contacts = uicontrol('Parent',obj.hdl_contacts_group,'Style','listbox',...
				'String',obj.cell_contacts,'Units','normalized','Position',[.1,.3,.8,.65],'Callback',@obj.Callback_contacts);
			obj.hdl_contacts_help = uicontrol('Parent',obj.hdl_contacts_group,'Visible','on','Style','pushbutton',...
				'String','Help','Units','normalized','Position',[.1,.025,.8,.1],'Callback',@obj.Callback_contacts_help);
			obj.hdl_contacts_text = uicontrol('Parent',obj.hdl_contacts_group,'Visible','off','BackgroundColor',[0.85,0.85,0.85],'Style','text',...
				'Units','normalized','Position',[.125,.325,.75,.6]);
			obj.hdl_contacts_edit = uicontrol('Parent',obj.hdl_contacts_group,'Visible','off','Style','edit',...
				'String','Please type in.','Units','normalized','Position',[.1,.15,.8,.1]);
			
			obj.hdl_information_group = uibuttongroup('Parent', obj.hdl_figure, 'Title', 'Select Information:','Units','normalized', 'Position', [.525,.2,.425,.75]);
			obj.hdl_information = uicontrol('Parent',obj.hdl_information_group,'Style','listbox',...
				'String',obj.cell_information,'Units','normalized','Position',[.1,.3,.8,.65],'Callback',@obj.Callback_information);
			obj.hdl_information_text = uicontrol('Parent',obj.hdl_information_group,'Visible','off','Style','text',...
				'Units','normalized','Position',[.125,.325,.75,.6]);
			obj.hdl_information_help = uicontrol('Parent',obj.hdl_information_group,'Visible','on','Style','pushbutton',...
				'String','Help','Units','normalized','Position',[.1,.025,.8,.1],'Callback',@obj.Callback_information_help);
			obj.hdl_information_edit = uicontrol('Parent',obj.hdl_information_group,'Visible','off','Style','edit',...
				'String','Please type in.','Units','normalized','Position',[.1,.15,.8,.1]);
			
			obj.hdl_openbutton = uicontrol('Parent',obj.hdl_figure,'Style','pushbutton',...
				'String','OPEN graph in editor','Units','normalized','Position',[.05,.05,.425,.1],'Callback',@obj.Callback_openbutton);
			obj.hdl_showbutton = uicontrol('Parent',obj.hdl_figure,'Style','pushbutton',...
				'String','SHOW graph in windows figure','Units','normalized','Position',[.525,.05,.425,.1],'Callback',@obj.Callback_showbutton);
			
			if obj.standalone
				set(obj.hdl_figure,'Visible','on');
			end
		end
		
		function Callback_openbutton(obj,hdl_uicontrol,hdl_actiondata)
			stct = obj.Readout();
			obj.hdl_lptn.OpenGraph(stct.contact, stct.information1, stct.information2);
            disp('size="8.3,11.7!";ratio="compress";fontsize=18');
		end
		function Callback_showbutton(obj,hdl_uicontrol,hdl_actiondata)
			stct = obj.Readout();
			obj.hdl_lptn.ShowGraph(stct.contact, stct.information1, stct.information2);
		end
		
		function Callback_contacts(obj,hdl_uicontrol,hdl_actiondata)
			set(obj.hdl_contacts_edit, 'Visible', 'off');
			switch get(obj.hdl_contacts,'Value')
				case {LPNEnum.enumGraphContacts.component, LPNEnum.enumGraphContacts.by_function_handle} %{5,6}
					set(obj.hdl_contacts_edit, 'Visible', 'on');
			end
		end
		function Callback_contacts_help(obj,hdl_uicontrol,hdl_actiondata)
			if strcmp(obj.hdl_contacts_text.Visible, 'off')
				switch get(obj.hdl_contacts,'Value');
					case {LPNEnum.enumGraphContacts.no_filter, LPNEnum.enumGraphContacts.noneshapeless, LPNEnum.enumGraphContacts.convection, LPNEnum.enumGraphContacts.radiation} %{1,2,3,4}
						set(obj.hdl_contacts_text,'String','Please select which contacts/components of your model should be displayed. Choose one to get more help if available.')
					case LPNEnum.enumGraphContacts.component %{5}
						set(obj.hdl_contacts_text,'String','Please enter the name of a component. The component and its contacts will be shown.')
					case LPNEnum.enumGraphContacts.by_function_handle %{6}
						set(obj.hdl_contacts_text,'String',['Please enter the name of a function. The function has to be applicable to components or contacts.' ...
							' The Output has to be boolean. If output is true component/contact will be shown. i.e.: ''@(x)x.GetEnumDirection.dimension == 1'' displays all radial contacts.']);
				end
				obj.hdl_contacts_text.Visible = 'on';
			else
				obj.hdl_contacts_text.Visible = 'off';
			end
		end
		function Callback_information(obj,hdl_uicontrol,hdl_actiondata)
			set(obj.hdl_information_edit, 'Visible', 'off');
			switch get(obj.hdl_information,'Value');
				case {LPNEnum.enumGraphOption.thermal_energy, LPNEnum.enumGraphOption.resistance,LPNEnum.enumGraphOption.heat, LPNEnum.enumGraphOption.hotspot, LPNEnum.enumGraphOption.by_function_handle} %{6,7,12}
					set(obj.hdl_information_edit, 'Visible', 'on');
			end
		end
		function Callback_information_help(obj,hdl_uicontrol,hdl_actiondata)
			if strcmp(obj.hdl_information_text.Visible, 'off')
				switch get(obj.hdl_information,'Value');
					case {LPNEnum.enumGraphOption.thermal_energy, LPNEnum.enumGraphOption.resistance,LPNEnum.enumGraphOption.heat, LPNEnum.enumGraphOption.hotspot} %{6,7}
						set(obj.hdl_information_text,'String','Please enter the point in time for which you want to have the results of the simulation.')
					case LPNEnum.enumGraphOption.by_function_handle %12
						set(obj.hdl_information_text,'String',['Please enter the name of a function. The function has to be applicable to components or contacts.'...
							' The output will be displayed in the graph. i.e.: ''GetEnumDirection''']);
					otherwise
						set(obj.hdl_information_text,'String','Please select an type of information which should be shown in the graph. Choose one to get more help if available.');
				end
				obj.hdl_information_text.Visible = 'on';
			else
				obj.hdl_information_text.Visible = 'off';
			end
		end
		function stct = Readout(obj)
			stct = struct('contact',[],'information1',[],'information2',[]);
			
			contact_content = get(obj.hdl_contacts,'Value');
			switch contact_content
                %Moritz, bitte mit enumeration arbeiten. nicht mit index.
				case {LPNEnum.enumGraphContacts.no_filter, LPNEnum.enumGraphContacts.noneshapeless, ...
                        LPNEnum.enumGraphContacts.convection, LPNEnum.enumGraphContacts.radiation} %{1,2,3,4}
					stct.contact = obj.cell_contacts{contact_content};
				case LPNEnum.enumGraphContacts.component %{5}
					stct.contact = get(obj.hdl_contacts_edit,'String');
				case LPNEnum.enumGraphContacts.by_function_handle %{6}
					str_functor_contact = get(obj.hdl_contacts_edit,'String');
					if str_functor_contact(1) ~= '@'
						str_functor_contact = [ '@' str_functor_contact];
					end
					stct.contact = str2func(str_functor_contact);
			end
			
			info_content = get(obj.hdl_information,'Value');
			stct.information1 = obj.cell_information{info_content};
			switch info_content
				case {LPNEnum.enumGraphOption.thermal_energy, LPNEnum.enumGraphOption.resistance,LPNEnum.enumGraphOption.heat, LPNEnum.enumGraphOption.hotspot} %{6,7}
					stct.information2 = str2double(get(obj.hdl_information_edit,'String'));
				case LPNEnum.enumGraphOption.by_function_handle %{12}
					str_functor_info = get(obj.hdl_information_edit,'String');
					if str_functor_info(1) ~= '@'
						str_functor_info = [ '@(x)x.' str_functor_info];
					end
					stct.information1 = str2func(str_functor_info);
			end
		end
	end
end

