classdef controller< handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        model
        View
        index
        state
        cbh
    end
    
    methods
        function obj = controller(model)
            obj.model = model;
            obj.View = View(obj);
        end
        
        function setMode(obj,mode)
            obj.model.setMode(mode)
        end
        
        function ApplyParameter(obj)
            obj.model.ApplyParameter()
        end
        
        function AddOptions(obj)  %open a new window
            options=LPNGui.clDesignerGUI.ListEnumerationMembers('LPNEnum.enumLPNBuilderOption');
            obj.index = length(options);
            h = figure;
            set(h, 'Position', [600 150 400 650])
            for i=1:obj.index
                obj.cbh(i) = uicontrol('Parent',h,'Style','checkbox','String',options{i}, 'Value',0,'Position',[50 25*i 150 20],'Callback',{@checkBox_Callback});
            end
            uicontrol('Parent',h,'Style','pushbutton','String','OK', 'Value',0,'Position',[300 20 40 30],'Callback',{@buttonCallback});
            
             for i=1:obj.index
                if obj.cbh(i).Value 
                    obj.state(i) = 1;
                else
                    obj.state(i) = 0;
                end
             end
  
        end
        
        
        function checkBox_Callback(obj,str)
            for i=1:obj.index
                if str == obj.cbh(i).String
                    obj.state(i) = 1;
                else
                    obj.state(i) = 0;
                end
            end
            
%             if ~isfield(handles,'chosen_options')
%                 handles.chosen_options={};
%             end
%             handles.chosen_options{end+1} = hObject.String;
           
        function buttonCallback(obj)
                h = findobj('Tag','figure1');
                h1 = guidata(h);
%                 handles = guidata(hObject);
%                 test_string = '';
                  chosen_options = {};
                for i = 1:obj.index
%                     test_string = [test_string handles.chosen_options{index}];
                      if obj.state(i) == 1
                          chosen_options{end+1} = obj.cbh(i).String;
                      end
                end
                set(h1.show_options,'String',chosen_options)
            end
        end
    end
end


