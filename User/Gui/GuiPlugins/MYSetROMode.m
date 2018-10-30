classdef MYSetROMode < PTKGuiPlugin
    % PTKSetDeveROperMode. Gui Plugin for enabling or disabling deveROper mode
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
        ButtonText = 'RO fissure detection'
        SelectedText = 'RO fissure tools off'
        ToolTip = 'Enables or disabled right oblique fissure detection mode'
        Category = 'Eigenvalue based connected component filter tools'
        Visibility = 'Always'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 4
        ButtonHeight = 1
        
        Icon = 'RO_fissure_developer_tools.png'
        ROcation = 29
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            % Toggles deveROper mode
            ptk_gui_app.ROFissureMode = ~ptk_gui_app.ROFissureMode;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = true;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = ptk_gui_app.ROFissureMode;
        end
    end
end
