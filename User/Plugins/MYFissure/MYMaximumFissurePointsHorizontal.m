classdef MYMaximumFissurePointsHorizontal < PTKPlugin
    % PTKMaximumFissurePointsHorizontal. Plugin which is part of the lobar segmentation.
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     PTKMaximumFissurePointsHorizontal is an intermediate stage in segmenting the
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
        ButtonText = 'My Fissureness <br>Maxima Horizontal'
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
            fissure_approximation = application.GetResult('MYPCAFissureApproximation');
            fissureness_roi = application.GetResult('MYFissurenessROIHorizontal');
            lung_mask = application.GetResult('MYLobesFromFissurePlaneOblique');
            
            fissureness_pack_results = application.GetResult('PTKFissureness');
            Vx = fissureness_pack_results.Vx;
            Vy = fissureness_pack_results.Vy;
            Vz = fissureness_pack_results.Vz;
                        
            results = MYMaximumFissurePointsHorizontal.GetResultsForLung(Vx,Vy,Vz,fissure_approximation, fissureness_roi.PTKRightMidFissure,...
                fissureness_roi.MYRightMidFissure, application.GetResult('PTKGetRightLungROI'), lung_mask, 1, 3, reporting);
            results.ResizeToMatch(fissure_approximation);
            results.ImageType = PTKImageType.Colormap;
        end
        
        function results = GenerateImageFromResults(results, ~, ~)
        end
    end    
    
    methods (Static, Access = private)
        
        function results = GetResultsForLung(Vx,Vy,Vz,fissure_approximation, PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_mask, lung_colour, fissure_colour, reporting)
            lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == lung_colour));
            
            fissure_approximation.ResizeToMatch(lung_roi);
            PTKfissureness_roi.ResizeToMatch(lung_roi);
            MYfissureness_roi.ResizeToMatch(lung_roi);
            lung_mask.ResizeToMatch(lung_roi);
            Vx = Vx.Copy;
            Vx.ResizeToMatch(lung_roi);
            Vy = Vy.Copy;
            Vy.ResizeToMatch(lung_roi);
            Vz = Vz.Copy;
            Vz.ResizeToMatch(lung_roi);
            
            % Get the developer value for horizontal fissure
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','..','..','User', 'Library', 'MYIfConnectedAnalysisRun.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            fclose(FidOpen);
            RH_developer_value = str2num(tline3(36));
            if ~RH_developer_value
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
                Eig_min_connected_size = str2num(tline3(45:end));
                [max_fissure_indices, ref_image] = MYGetMaxFissurePoints(Vx.RawImage,Vy.RawImage,Vz.RawImage,fissure_approximation.RawImage == fissure_colour, lung_mask,...
                    PTKfissureness_roi, MYfissureness_roi, lung_roi, lung_roi.ImageSize, Eig_min_connected_size);
            end
            if isempty(max_fissure_indices)
                reporting.ShowWarning('PTKMaximumFissurePointsHorizontal:FissurePointsNotFound', ['The horizontal fissure could not be found.']);
            end
            
            ref_image(ref_image == 1) = 8;
            
            results = lung_roi.BlankCopy;
            results.ChangeRawImage(ref_image);
        end
        
    end
end