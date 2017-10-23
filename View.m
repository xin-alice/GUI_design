classdef View < handle
    properties
        gui
        model
        controller
    end
    
    methods
        function obj = View(controller)
            obj.controller = controller;
            obj.model = controller.model;
            obj.gui = ViewGuide('controller',obj.controller);
 
            addlistener(obj.model,'mode','PostSet', ...
                @(src,evnt)view.handlePropEvents(obj,src,evnt));
%             addlistener(obj.model,'options','PostSet', ...
%                 @(src,evnt)view.handlePropEvents(obj,src,evnt));       
        end
    end
    
    methods (Static)
        function handlePropEvents(obj,src,evnt)
            evntobj = evnt.AffectedObject;
            handles = guidata(obj.gui);
            set(handles.mode_choose,'String',LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderMode'))
        end
    end
end