classdef MYFissureness < PTKPlugin
    % PTKFissureness. Plugin to detect fissures 
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     This is an intermediate stage towards lobar segmentation.
    %
    %     PTKFissureness computes the fissureness by combining two components
    %     generated from the two plugins PTKFissurenessHessianFactor and
    %     PTKFissurenessVesselsFactor.
    %
    %     For more information, see 
    %     [Doel et al., Pulmonary lobe segmentation from CT images using
    %     fissureness, airways, vessels and multilevel B-splines, 2012]
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'MYFissureness'
        ToolTip = 'Fissureness filter for detecting plane-like points with suppression of points close to vessels'
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
        Visibility = 'Developer'
    end
    
    methods (Static)
        
        function results = RunPlugin(dataset, reporting)
            fissureness_pack_result = dataset.GetResult('PTKFissurenessHessianFactor');
            PTKfissureness_from_hessian = single(fissureness_pack_result.PTKfissureness.RawImage)/100;
            MYfissureness_from_hessian = single(fissureness_pack_result.MYfissureness.RawImage)/100;
            fissureness_from_vessels = single(dataset.GetResult('PTKFissurenessVesselsFactor').RawImage)/100;
            PTKfissureness = dataset.GetTemplateImage(PTKContext.LungROI);
            MYfissureness = dataset.GetTemplateImage(PTKContext.LungROI);
            PTKfissureness.ChangeRawImage(100*fissureness_from_vessels.*PTKfissureness_from_hessian);
            MYfissureness.ChangeRawImage(100*fissureness_from_vessels.*MYfissureness_from_hessian);
            PTKfissureness.ImageType = PTKImageType.Scaled;
            MYfissureness.ImageType = PTKImageType.Scaled;
            results = [];
            results.PTKfissureness = PTKfissureness;
            results.MYfissureness = MYfissureness;
            results.Vx = fissureness_pack_result.Vx;
            results.Vy = fissureness_pack_result.Vy;
            results.Vz = fissureness_pack_result.Vz;
        end        
        
    
        
        function combined_image = GenerateImageFromResults(results, image_templates, ~)
            combined_image = results.MYfissureness;
            results.ImageType = PTKImageType.Colormap;
        end
    end
        
end
