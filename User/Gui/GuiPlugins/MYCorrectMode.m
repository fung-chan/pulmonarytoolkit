classdef MYCorrectMode < PTKGuiPlugin
    % PTKSaveEdited.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'Start Correct'
        SelectedText = 'Start Correct'
        ToolTip = 'Start Correct the segmentation result based on the landmark points'
        Category = 'Correct'
        Visibility = 'Dataset'
        Mode = 'Edit'
        
        HidePluginInDisplay = false
        PTKVersion = '2'
        ButtonWidth = 6
        ButtonHeight = 2
        %         Location = 23
        %         Icon = 'markers.png'
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            ptk_gui_app.MultiCorrectMode;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.IsDatasetLoaded;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = ptk_gui_app.ImagePanel.IsInMarkerMode;
        end
    end
end
