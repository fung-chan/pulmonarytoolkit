classdef MYTracheaManualMode < MimGuiPlugin
    % MYTracheaManualMode. Gui Plugin for enabling or disabling mode to
    % manually find the trachea location
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        ButtonText = 'Auto Trachea'
        SelectedText = 'Manual Trachea'
        ToolTip = 'Enables or disables mode to manually find the trachea location'
        Category = 'Trachea location manual control tools'
        Visibility = 'Always'
%         Mode = 'View'
        Mode = 'Toolbar'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 1
        
        Icon = 'developer_tools.png'
        Location = 31
    end
    
    methods (Static)
        function RunGuiPlugin(gui_app)
            % Toggles developer mode
            gui_app.TracheaManualMode = ~gui_app.TracheaManualMode;
        end
        
        function enabled = IsEnabled(gui_app)
            enabled = true;
        end
        
        function is_selected = IsSelected(gui_app)
            is_selected = gui_app.TracheaManualMode;
        end
    end
end
