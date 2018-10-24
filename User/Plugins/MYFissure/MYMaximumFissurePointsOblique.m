classdef MYMaximumFissurePointsOblique < PTKPlugin
    % PTKMaximumFissurePointsOblique. Plugin which is part of the lobar segmentation.
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     PTKMaximumFissurePointsOblique is an intermediate stage in segmenting the
    %     lobes.
    %
    %     For more information, see 
    %     [Doel et al., Pulmonary lobe segmentation from CT images using
    %     fissureness, airways, vessels and multilevel B-splines, 2012]
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    properties
        ButtonText = 'My Fissureness <br>Maxima Oblique'
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
            fissureness_roi = application.GetResult('MYFissurenessROIOblique');
            fissure_approximation = application.GetResult('MYPCAFissureApproximation');
            left_and_right_lungs = application.GetResult('PTKLeftAndRightLungs');
            
            fissureness_pack_results = application.GetResult('PTKFissureness');
            Vx = fissureness_pack_results.Vx;
            Vy = fissureness_pack_results.Vy;
            Vz = fissureness_pack_results.Vz;
            
            results_left = MYMaximumFissurePointsOblique.GetResultsForLeftLung(Vx,Vy,Vz,fissure_approximation, fissureness_roi.PTKLeftMainFissure,...
                fissureness_roi.MYLeftMainFissure, application.GetResult('PTKGetLeftLungROI'), left_and_right_lungs, 2, 6, 'left', reporting);
            results_right = MYMaximumFissurePointsOblique.GetResultsForRightLung(Vx,Vy,Vz,fissure_approximation, fissureness_roi.PTKRightMainFissure,...
                fissureness_roi.MYRightMainFissure, application.GetResult('PTKGetRightLungROI'), left_and_right_lungs, 1, 2, 'right', reporting);
            
            results = PTKCombineLeftAndRightImages(application.GetTemplateImage(PTKContext.LungROI), results_left, results_right, left_and_right_lungs);
            results.ImageType = PTKImageType.Colormap;
        end
        
        function results = GenerateImageFromResults(results, ~, ~)
        end
    end    
    
    methods (Static, Access = private)
        function results = GetResultsForLeftLung(Vx,Vy,Vz,fissure_approximation, PTKfissureness_roi, MYfissureness_roi, lung_roi, left_and_right_lungs, lung_colour, fissure_colour, lung_name, reporting)
            lung_mask = left_and_right_lungs.Copy;
            lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == lung_colour));
            
            fissure_approximation = fissure_approximation.Copy;
            fissure_approximation.ResizeToMatch(lung_roi);
            lung_mask.ResizeToMatch(lung_roi);
            Vx = Vx.Copy;
            Vx.ResizeToMatch(lung_roi);
            Vy = Vy.Copy;
            Vy.ResizeToMatch(lung_roi);
            Vz = Vz.Copy;
            Vz.ResizeToMatch(lung_roi);
            
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'MYIfConnectedAnalysisRun.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            fclose(FidOpen);
            LO_developer_value = str2num(tline1(36));
            if ~LO_developer_value
                [max_fissure_indices, ref_image] = PTKGetMaxFissurePoints(Vx.RawImage,Vy.RawImage,Vz.RawImage,fissure_approximation.RawImage == fissure_colour, lung_mask,...
                    PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_roi.ImageSize);
            else
                current_path = mfilename('fullpath');
                [path_root, ~, ~] = fileparts(current_path);
                full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'MYEigenvectorConnectedSize.txt');
                FidOpen = fopen(full_filename,'r');
                tline1 = fgetl(FidOpen);
                tline2 = fgetl(FidOpen);
                tline3 = fgetl(FidOpen);
                fclose(FidOpen);
                Eig_min_connected_size = str2num(tline1(45:end));
                [max_fissure_indices, ref_image] = MYGetMaxFissurePoints(Vx.RawImage,Vy.RawImage,Vz.RawImage,fissure_approximation.RawImage == fissure_colour, lung_mask,...
                    PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_roi.ImageSize, Eig_min_connected_size);
            end
            
            if isempty(max_fissure_indices)
                reporting.ShowWarning('PTKMaximumFissurePointsOblique:FissurePointsNotFound', ['The oblique fissure could not be found in the ' lung_name ' lung']);
            end
            
            results = lung_roi.BlankCopy;
            results.ChangeRawImage(ref_image);
        end 
        
        function results = GetResultsForRightLung(Vx,Vy,Vz,fissure_approximation, PTKfissureness_roi, MYfissureness_roi, lung_roi, left_and_right_lungs, lung_colour, fissure_colour, lung_name, reporting)
            lung_mask = left_and_right_lungs.Copy;
            lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == lung_colour));
            
            fissure_approximation = fissure_approximation.Copy;
            fissure_approximation.ResizeToMatch(lung_roi);
            lung_mask.ResizeToMatch(lung_roi);
            Vx = Vx.Copy;
            Vx.ResizeToMatch(lung_roi);
            Vy = Vy.Copy;
            Vy.ResizeToMatch(lung_roi);
            Vz = Vz.Copy;
            Vz.ResizeToMatch(lung_roi);
            
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'MYIfConnectedAnalysisRun.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            fclose(FidOpen);
            RO_developer_value = str2num(tline2(36));
            if ~RO_developer_value
                [max_fissure_indices, ref_image] = PTKGetMaxFissurePoints(Vx.RawImage,Vy.RawImage,Vz.RawImage,fissure_approximation.RawImage == fissure_colour, lung_mask,...
                    PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_roi.ImageSize);
            else
                current_path = mfilename('fullpath');
                [path_root, ~, ~] = fileparts(current_path);
                full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'MYEigenvectorConnectedSize.txt');
                FidOpen = fopen(full_filename,'r');
                tline1 = fgetl(FidOpen);
                tline2 = fgetl(FidOpen);
                tline3 = fgetl(FidOpen);
                fclose(FidOpen);
                Eig_min_connected_size = str2num(tline2(45:end));
                [max_fissure_indices, ref_image] = MYGetMaxFissurePoints(Vx.RawImage,Vy.RawImage,Vz.RawImage,fissure_approximation.RawImage == fissure_colour, lung_mask,...
                    PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_roi.ImageSize, Eig_min_connected_size);
            end
            
            if isempty(max_fissure_indices)
                reporting.ShowWarning('PTKMaximumFissurePointsOblique:FissurePointsNotFound', ['The oblique fissure could not be found in the ' lung_name ' lung']);
            end
            
            results = lung_roi.BlankCopy;
            results.ChangeRawImage(ref_image);
        end
    end
end