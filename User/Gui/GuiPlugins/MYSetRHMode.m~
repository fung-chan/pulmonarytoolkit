classdef MYSetRHMode < PTKGuiPlugin
    % PTKSetDeveloperMode. Gui Plugin for enabling or disabling developer mode
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
        ButtonText = 'RH fissure detection'
        SelectedText = 'RH fissure tools off'
        ToolTip = 'Enables or disabled right horizontal fissure detection mode'
        Category = 'Eigenvalue based connected component filter tools'
        Visibility = 'Always'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 4
        ButtonHeight = 1
        
        Icon = 'RH_fissure_developer_tools.png'
        Location = 33
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            % Toggles developer mode
            ptk_gui_app.RHFissureMode = ~ptk_gui_app.RHFissureMode;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = true;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = ptk_gui_app.RHFissureMode;
        end
    end
end
