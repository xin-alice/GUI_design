classdef clLPTNDesignerView < handle
    properties
        
        main_figure
        data
        
        global_settings
        motor_settings
        detail_settings
        panel_global_settings
        panel_motor_settings
        panel_detail_settings
    end
    
    methods
        
        function obj = clLPTNDesignerView()
            obj.BuildGUI();
            obj.data = LPNGui.clLPTNDesignerinput;
            obj.global_settings = LPNGui.clLPTNDesignerGlobalSettingPanal(obj.panel_global_settings,obj.data);
            obj.motor_settings = LPNGui.clLPTNDesignerMotorSettingPanal(obj.panel_motor_settings,obj.data);
            obj.detail_settings = LPNGui.clLPTNDesignerDetailSettingPanal(obj.panel_detail_settings,obj.data);
            obj.data.lptn_MotorSettingPanal = obj.motor_settings;
            obj.data.lptn_DetailSettingPanal = obj.detail_settings;
        end
        
        function BuildGUI(obj)
            obj.main_figure = figure('Visible','off','Toolbar','figure','MenuBar','none',...
                'Name','LPN Builder Graphical Interface','Position',[100,50,1100,600]);
            obj.panel_global_settings = uipanel('parent',obj.main_figure,'Title','Global Settings',...
                'FontSize',12,'Position',[.01 .45 .4 .53]);
            obj.panel_motor_settings = uipanel('parent',obj.main_figure,'Title','Motor Settings',...
                'FontSize',12,'Position',[.01 .05 .4 .4]);
            obj.panel_detail_settings = uipanel('parent',obj.main_figure,'Title','Detail Settings',...
                'FontSize',12, 'Position',[.42 .05 .52 .93]);
            set(obj.main_figure,'Visible','on');
        end
    end
end
