function [Vx,Vy,Vz] = MYFissurenessHessianFactor(dataset,left_lung,right_lung, left_and_right_lungs, reporting)
    % PTKFissureApproximation. Plugin to detect fissures using analysis of the
    %     Hessian matrix
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     This is an intermediate stage towards lobar segmentation.
    %
    %     PTKFissurenessHessianFactor computes the components of the fissureness
    %     generated using analysis of eigenvalues of the Hessian matrix.
    %
    %     For more information, see 
    %     [Doel et al., Pulmonary lobe segmentation from CT images using
    %     fissureness, airways, vessels and multilevel B-splines, 2012]
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

%     properties
%         ButtonText = 'Fissureness <BR>(Hessian part)'
%         ToolTip = 'The part of the fissureness filter which uses Hessian-based analysis'
%         Category = 'Fissures'
% 
%         AllowResultsToBeCached = true
%         AlwaysRunPlugin = false
%         PluginType = 'ReplaceOverlay'
%         HidePluginInDisplay = True
%         FlattenPreviewImage = false
%         PTKVersion = '1'
%         ButtonWidth = 6
%         ButtonHeight = 2
%         GeneratePreview = true
%         Visibility = 'Developer'
%     end
    
%     methods (Static)
%         function [results,Vx,Vy,Vz] = RunPlugin(dataset, reporting)
            reporting.UpdateProgressValue(0);
%             left_and_right_lungs = dataset.GetResult('PTKLeftAndRightLungs');
%             
%             right_lung = dataset.GetResult('PTKGetRightLungROI');
            
            [Vx_right,Vy_right,Vz_right] = ComputeFissureness(right_lung, left_and_right_lungs, reporting, false);
            
            reporting.UpdateProgressValue(50);
%             left_lung = dataset.GetResult('PTKGetLeftLungROI');
            [Vx_left,Vy_left,Vz_left] = ComputeFissureness(left_lung, left_and_right_lungs, reporting, true);
            
            reporting.UpdateProgressValue(100);
%             results = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), fissureness_left, fissureness_right, left_and_right_lungs);
            Vx = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), Vx_left, Vx_right, left_and_right_lungs);
            Vy = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), Vy_left, Vy_right, left_and_right_lungs);
            Vz = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), Vz_left, Vz_right, left_and_right_lungs);
            
%             results.ImageType = PTKImageType.Scaled;
%         end        
    end
    
%     methods (Static, Access = private)
        
        function lung = DuplicateImageInMask(lung, mask_raw)
            mask_raw = mask_raw > 0;
            [~, labelmatrix] = bwdist(mask_raw);
            lung(~mask_raw(:)) = lung(labelmatrix(~mask_raw(:)));
        end
        
        function [Vx,Vy,Vz] = ComputeFissureness(image_data, left_and_right_lungs, reporting, is_left_lung)
            
            left_and_right_lungs = left_and_right_lungs.Copy;
            left_and_right_lungs.ResizeToMatch(image_data);
            image_data.ChangeRawImage(DuplicateImageInMask(image_data.RawImage, left_and_right_lungs.RawImage));
            
            mask = [];
            [Vx_image,Vy_image,Vz_image] = MYImageDividerHessian(image_data, @ComputeFissurenessPartImage, mask, 1.0, [], false, false, is_left_lung, reporting);
            Vx=image_data.Copy;
            Vx.ChangeRawImage(Vx_image);
            Vy=image_data.Copy;
            Vy.ChangeRawImage(Vy_image);
            Vz=image_data.Copy;
            Vz.ChangeRawImage(Vz_image);
        end
        
        function fissureness_wrapper = ComputeFissurenessPartImage(hessian_eigs_wrapper, voxel_size)
            fissureness_wrapper = PTKComputeFissurenessFromHessianeigenvalues(hessian_eigs_wrapper, voxel_size);
        end
