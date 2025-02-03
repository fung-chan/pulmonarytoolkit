classdef MYSaveRawMask < PTKPlugin
    % MYSaveLungMesh. Plugin for creating an STL surface mesh file
    %     for each lung
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
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    %     Note: this plugin needs the add-on MetaImageIO - can be
    %     installed from Add-Ons manager
    
    properties
        ButtonText = 'Save mha Raw and Masks'
        ToolTip = 'Saves raw image, lung and lobe masks as mha files'
        Category = 'Export'

        AllowResultsToBeCached = true
        AlwaysRunPlugin = true
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = true
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = false
    end
    
    methods (Static)
        function results = RunPlugin(dataset, reporting)
            reporting.ShowProgress('Saving raw image and masks');
            
            % Get raw image, lung and lobe segmentations
            raw = dataset.GetResult('PTKOriginalImage');
            lungs = dataset.GetResult('PTKLeftAndRightLungs');
            lobes = dataset.GetResult('PTKLobes');
            
            % Save raw image as mha file
            raw_image = int16(raw.RawImage); % Make sure raw image is always int16
            raw_image_rotate = permute(raw_image, [2,1,3]); % Rotate images
            [filename, pathname] = uiputfile('*.mha', 'Save the raw metaimage file as');
            raw_filename = extractBefore(filename, ".");

            if isfield(raw.MetaHeader,'RescaleIntercept')==1
                raw_image_rotate = raw_image_rotate * raw.RescaleSlope + raw.RescaleIntercept;
            end

            meta_struct = struct;
            meta_struct.ObjectType = 'Image';
            meta_struct.NDims = 3;
            meta_struct.Offset = raw.GlobalOrigin;
            meta_struct.Offset = [meta_struct.Offset(2),meta_struct.Offset(1),meta_struct.Offset(3)]; % Rotate origin to match
            transform_2D = raw.MetaHeader.ImageOrientationPatient;

            % Assumes should be RAS
            meta_struct.TransformMatrix = [transform_2D(1),transform_2D(2),transform_2D(3);...
                transform_2D(4),transform_2D(5),transform_2D(6); 0,0,-1];
            meta_struct.CenterOfRotation = [0,0,0];
%             meta_struct.AnatomicalOrientation = 'RAS';
            meta_struct.ElementSpacing = raw.VoxelSize;
            meta_struct.DimSize = raw.OriginalImageSize;
            meta_struct.Offset(3) = meta_struct.Offset(3)+(meta_struct.DimSize(3)*meta_struct.ElementSpacing(3));
            
            metaimageio.write(fullfile(pathname,strcat(raw_filename,'.mha')),raw_image_rotate,meta_struct);
            
            % Save lung mask
            lung_raw = lungs.RawImage;            
            full_lung = zeros(lungs.OriginalImageSize);
            image_size = lungs.ImageSize;
            start_crop = lungs.Origin;
            full_lung(start_crop(1):(start_crop(1)+image_size(1)-1),start_crop(2):(start_crop(2)+image_size(2)-1),...
                start_crop(3):(start_crop(3)+image_size(3)-1)) = lung_raw;
            
            full_lung_rotate = permute(full_lung, [2,1,3]);
            full_lung_combined = full_lung_rotate;
            full_lung_combined(full_lung_rotate==2) = 1;

            meta_struct.CompressedData = 1;
            meta_struct.BinaryData = 1;
            
            metaimageio.write(fullfile(pathname,strcat(raw_filename,'_lungmask.mha')),full_lung_combined,meta_struct);
            metaimageio.write(fullfile(pathname,strcat(raw_filename,'_rightleftmask.mha')),full_lung_rotate,meta_struct);

            % Save lobe mask
            lobe_raw = lobes.RawImage;            
            full_lobe = zeros(lobes.OriginalImageSize);
            image_size = lobes.ImageSize;
            start_crop = lobes.Origin;
            full_lobe(start_crop(1):(start_crop(1)+image_size(1)-1),start_crop(2):(start_crop(2)+image_size(2)-1),...
                start_crop(3):(start_crop(3)+image_size(3)-1)) = lobe_raw;
            
            full_lobe_rotate = permute(full_lobe, [2,1,3]);

            metaimageio.write(fullfile(pathname,strcat(raw_filename,'_lobemask.mha')),full_lobe_rotate,meta_struct);

            results = raw;
            reporting.UpdateProgressValue(100);
            reporting.CompleteProgress;
            
        end
        
%         function results = GenerateImageFromResults(results, image_templates, reporting)
%         end        
    end
end
