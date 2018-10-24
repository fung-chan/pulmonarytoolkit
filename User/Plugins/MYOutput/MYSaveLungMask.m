classdef MYSaveLungMask < PTKPlugin
    % MYSaveLeftAndRightLungMask. Plugin for saving left and right lung segmentation result as a mask
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
        ButtonText = 'Save lung <br>mask'
        ToolTip = 'Saves lung segmentation result as mask image'
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
            reporting.ShowProgress('Save lung mask');
            lung_results = dataset.GetResult('PTKLeftAndRightLungs');
            lung_raw = lung_results.RawImage;
            full_lung_image = zeros(lung_results.OriginalImageSize);
            image_size = lung_results.ImageSize;
            start_crop = lung_results.Origin;
            full_lung_image(start_crop(1):(start_crop(1)+image_size(1)-1),start_crop(2):(start_crop(2)+image_size(2)-1),...
                start_crop(3):(start_crop(3)+image_size(3)-1)) = lung_raw;

            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Lung Mask');
            save_full_path=fullfile(save_root_path,'PTKLungMask');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            for i = 1:size(full_lung_image,3)
                current_image = full_lung_image(:,:,i);
                current_image1 = zeros(size(current_image));
                x_size = size(current_image,1);
                for k = 1:x_size
                    current_image1(k,:) = current_image(x_size-k+1,:);
                end
                save_mask_path = fullfile(save_full_path,'LungMask');
                if i-1<=9
                    save_image_name = strcat(save_mask_path,'000',num2str(i-1),'.jpg');
                elseif i-1>9&&i-1<=99
                    save_image_name = strcat(save_mask_path,'00',num2str(i-1),'.jpg');
                elseif i-1>99&&i-1<=999
                    save_image_name = strcat(save_mask_path,'0',num2str(i-1),'.jpg');
                end
                current_image1 = uint8(current_image1);
                imwrite(current_image1,save_image_name, 'Mode', 'lossless');
            end
            results = lung_results.Copy;
        end
               
    end
end
