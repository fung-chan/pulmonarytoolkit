classdef MYPCAbasedFissurePlane < PTKPlugin
    % MYFissurePlane. Plugin to obtain an approximation of the fissures
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'PCA-based Fissure plane'
        ToolTip = 'show the pca-based fissure plane for manual editing'
        Category = 'Fissures'
        
        AllowResultsToBeCached = true
        AlwaysRunPlugin = false
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = true
        
        EnableModes = MimModes.EditMode
        SubMode = MimSubModes.FixedBoundariesEditing
    end
    
    methods (Static)
        function results = RunPlugin(application, reporting)
            results = application.GetResult('MYFissurePlaneOblique');
            horiztonal_results = application.GetResult('MYFissurePlaneHorizontal');
            horiztonal_results.ResizeToMatch(results);
            oblique_results_raw = results.RawImage;
            oblique_results_raw(horiztonal_results.RawImage == 2) = 2;
            results.ChangeRawImage(oblique_results_raw);
        end
        
        function results = GenerateImageFromResults(results, ~, ~)
        end
    end
end