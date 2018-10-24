classdef MYOBJLung < PTKPlugin
    % MYOBJLung. Plugin to show obj segmentation results.
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
    
    properties
        ButtonText = 'OBJ Segmentation'
        ToolTip = 'Show obj segmentation results'
        Category = 'Lungs'
        
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
         SubMode = MimSubModes.EditBoundariesEditing
    end
    
    methods (Static)
        function results = RunPlugin(dataset, reporting)
            
            lungs = dataset.GetResult('PTKLeftAndRightLungs');
            results = lungs.Copy;
            % Get OBJ Lung segmentation result
            data_info = dataset.GetImageInfo;
            current_data_path = data_info.ImagePath;
            OBJ_lung_path = uigetdir(current_data_path, 'Select Directory to Read in OBJ Lung Segmentation Result');
            if OBJ_lung_path == 0
                reporting.Error('MYOBJLung:ProgramErro', 'Can not read in obj lung segmentation result');
            end
            
            OBJ_lung_mask = fullfile(OBJ_lung_path,'Lung.hdr');
            lung_mask_info = analyze75info(OBJ_lung_mask);
            Lung_Img = analyze75read(lung_mask_info);
            
            % Separate left and right lung
            OBJ_separate_Lung = zeros(size(Lung_Img));
            left_lung_index = 1:6; right_lung_index = 7:12;
            for m = left_lung_index
                OBJ_separate_Lung(Lung_Img==m) = 2;
            end
            for m = right_lung_index
                OBJ_separate_Lung(Lung_Img==m) = 1;
            end
            
            raw_obj_image = uint8(OBJ_separate_Lung);
            raw_obj_image1 = raw_obj_image;  
            % Crop raw_obj_image
            for i = 1:size(raw_obj_image,3)
                raw_obj_image(:,:,i) = raw_obj_image1(:,:,(size(raw_obj_image,3)-i+1));
            end
            raw_obj_image = raw_obj_image(end:-1:1,:,:);
            LungDicomImage = PTKLoadImages(dataset.GetImageInfo);
            [start_crop,end_crop]=MYGetLungROIForCT(LungDicomImage);
            crop_obj_image = raw_obj_image(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3));
            results.ChangeRawImage(crop_obj_image);
            end
        end
end