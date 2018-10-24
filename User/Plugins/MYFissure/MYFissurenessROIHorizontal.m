classdef MYFissurenessROIHorizontal < PTKPlugin
    % PTKFissurenessROIHorizontal. Plugin to determine fissureness with regions of interest
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     PTKFissurenessROIHorizontal is an intermediate stage towards lobar segmentation.
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
        ButtonText = 'My Fissureness <br>ROI Horizontal'
        ToolTip = ''
        Category = 'Fissures'
        
        AllowResultsToBeCached = true
        AlwaysRunPlugin = false
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = true
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = true
        Visibility = 'Developer'
    end
    
    methods (Static)
        function results = RunPlugin(application, reporting)
            
            oblique_fissures = application.GetResult('MYFissurePlaneOblique');
            fissure_approximation = application.GetResult('MYPCAFissureApproximation');
            fissureness_package = application.GetResult('PTKFissureness');
            PTKfissureness = fissureness_package.PTKfissureness;
            MYfissureness = fissureness_package.MYfissureness;
            
            PTKresults_right_mid = MYFissurenessROIHorizontal.GetRightLungResults(oblique_fissures, fissure_approximation, PTKfissureness, application.GetResult('PTKGetRightLungROI'));
            MYresults_right_mid = MYFissurenessROIHorizontal.GetRightLungResults(oblique_fissures, fissure_approximation, MYfissureness, application.GetResult('PTKGetRightLungROI'));
            results = [];
            results.PTKRightMidFissure = PTKresults_right_mid;
            results.MYRightMidFissure = MYresults_right_mid;
        end
        
        function results_image = GenerateImageFromResults(results, image_templates, ~)
            template_image = image_templates.GetTemplateImage(PTKContext.LungROI);
            
            results_image = results.MYRightMidFissure;
            results_image.ResizeToMatch(template_image);
            results_image.ImageType = PTKImageType.Scaled;
        end
    end
    
    methods (Static, Access = private)
        
        function results_right_mid = GetRightLungResults(oblique_fissures, fissure_approximation, fissureness, right_lung_roi)
            fissureness.ResizeToMatch(right_lung_roi);
            oblique_fissures.ResizeToMatch(right_lung_roi);
            fissure_approximation.ResizeToMatch(right_lung_roi);
            
            R_fissure = oblique_fissures.RawImage == 3;
            R_fissure_dt = bwdist(R_fissure).*max(right_lung_roi.VoxelSize);
            
            supressor_distance_thresholded = max(0, R_fissure_dt)/10;
            supressor = min(1, supressor_distance_thresholded.^2);
            
            RM_fissure = fissure_approximation.RawImage == 3;
            
            RM_fissure_dt = bwdist(RM_fissure).*max(right_lung_roi.VoxelSize);
            %             searching_region_value=input('Input the horizontal fissure searching distance from the initial guessing: ')
            %% Get the searching region
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'PTKSearchingRegionThreshold.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            fclose(FidOpen);
            left_oblique_threshold = str2num(tline1(28:end));
            right_oblique_threshold = str2num(tline2(29:end));
            right_horizontal_threshold = str2num(tline3(32:end));
            
            distance_thresholded_M = max(0, RM_fissure_dt - right_horizontal_threshold)/(right_horizontal_threshold.*2);
            multiplier_M = max(0, 1 - distance_thresholded_M.^2);
            multiplier_M = multiplier_M.*single(~R_fissure);
            
            % The suppressor is a term that dampens fissureness near the *other*
            % fissure, while the multiplier dampens fissureness far away from
            % the fissure we are looking for
            
            fissureness_M = fissureness.RawImage.*multiplier_M.*supressor;
            
            results_right_mid = right_lung_roi.BlankCopy;
            results_right_mid.ChangeRawImage(fissureness_M);
        end
        
    end
end