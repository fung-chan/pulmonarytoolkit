classdef PTKRightHorizontalSearchingRegionSlider < PTKGuiPluginSlider
    % PTKWindowSlider. Gui Plugin for changing the searching region of left
    % oblique fissure.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKWindowSlider is a Gui Plugin for changing the searching region of 
    %     left oblique fissure used to help with the fissure points
    %     detection.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Yuwen Zhang, 2015. 
    %    
    
    properties
        ButtonText = 'RH Searching Region'
        SelectedText = 'Right Horizontal Searching Region'
        ToolTip = 'change the searching region of right horizontal fissure'
        Category = 'SearchingRegion'
        Visibility = 'Dataset'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '2'
        ButtonWidth = 6
        ButtonHeight = 3
        Location = 21

        MinValue = 0
        MaxValue = 50
        SmallStep = 0.01
        LargeStep = 0.1
        DefaultValue = 50
        
        EditBoxPosition = 140
        EditBoxWidth = 80
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.IsDatasetLoaded;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = true;
        end
        
        function [instance_handle, value_property_name, limits_property_name] = GetHandleAndProperty(ptk_gui_app)
            instance_handle = ptk_gui_app.ImagePanel;
            value_property_name = 'RHRegion';
            limits_property_name = 'RHRegionLimits';
        end
        
    end
end
