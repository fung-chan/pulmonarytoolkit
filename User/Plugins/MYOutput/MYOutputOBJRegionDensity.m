classdef MYOutputOBJRegionDensity < PTKPlugin
    % MYOutputOBJRegionDensity. Plugin for outputing the obj region tissue density
    %
    %     This is a plugin for a self-built function of the Pulmonary Toolkit. Plugins can be run using
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     The output image generated by GenerateImageFromResults creates a
    %     colour-coded segmentation image with true airway points shown as blue
    %     and explosion points shown in red.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'Output OBJ Region Density'
        ToolTip = 'Output Lung segmentation data cloud with density information and convert it into exdata and ipdata'
        Category = 'Export'
        
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
        function results=RunPlugin(dataset,reporting)
            if nargin < 2
                reporting = PTKReportingDefault;
            end
            
            LungDicomImage = PTKLoadImages(dataset.GetImageInfo);
            Raw = LungDicomImage.RawImage;
            
            lungs=dataset.GetResult('PTKLeftAndRightLungs');
            
            % Get OBJ region classified data
            data_info = dataset.GetImageInfo;
            current_data_path = data_info.ImagePath;
            OBJ_path = uigetdir(current_data_path, 'Select Directory to Read in OBJ Region Classified Data and Lung Data');
            if OBJ_path == 0
                reporting.Error('MYOutputOBJRegionDensity:MYOutputOBJRegionDensity', 'Can not read in obj region classified data');
            end
            
            OBJ_region_mask = fullfile(OBJ_path,'Region.hdr');
            region_mask_info = analyze75info(OBJ_region_mask);
            Region_Img = analyze75read(region_mask_info);
            
            OBJ_lung_mask = fullfile(OBJ_path,'Lung.hdr');
            lung_mask_info = analyze75info(OBJ_lung_mask);
            Lung_Img = analyze75read(lung_mask_info);
            
            Original_Region_Img = Region_Img;
            Classified_Region_Img = zeros(size(Region_Img));
            
            % Sample the data
            Region_Img = Region_Img(1:2:end,1:2:end,:);
            Lung_Img = Lung_Img(1:2:end,1:2:end,:);
            Raw = Raw(1:2:end,1:2:end,:);
            
            % Upside down the Img
            Region_Img1 = Region_Img;
            for i = 1:size(Region_Img,3)
                Region_Img(:,:,i) = Region_Img1(:,:,(size(Region_Img,3)-i+1));
            end
            Region_Img = Region_Img(end:-1:1,:,:);
            
            Lung_Img1 = Lung_Img;
            for i = 1:size(Lung_Img,3)
                Lung_Img(:,:,i) = Lung_Img1(:,:,(size(Lung_Img,3)-i+1));
            end
            Lung_Img = Lung_Img(end:-1:1,:,:);
            
            Original_Region_Img1 = Original_Region_Img;
            for i = 1:size(Original_Region_Img1,3)
                Original_Region_Img(:,:,i) = Original_Region_Img1(:,:,(size(Original_Region_Img,3)-i+1));
            end
            Original_Region_Img = Original_Region_Img(end:-1:1,:,:);
            
            % Separate left and right lung
            OBJ_separate_Lung = zeros(size(Lung_Img));
            left_lung_index = 1:6; right_lung_index = 7:12;
            for m = left_lung_index
                OBJ_separate_Lung(Lung_Img==m) = 2;
            end
            for m = right_lung_index
                OBJ_separate_Lung(Lung_Img==m) = 1;
            end
            
            left_index = find(OBJ_separate_Lung==2);
            right_index = find(OBJ_separate_Lung==1);
            
            % Divide img data into different regions
            GroupName = {'Honeycomb','Normal','Reticular','SevereLAA','ModerateLAA','MideLAA','GroundGlass'};
            index_matrix = {[1:6,40:59],[7:15],[16:19,20:24],[25,27,28],[26,39],[29,35:38,60:69],[30:34]};
            offset_value = 0;
            VoxelSize=LungDicomImage.VoxelSize;
            OriginalImageSize=LungDicomImage.OriginalImageSize;
            
            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save OBJ Region density data');
            save_full_path=fullfile(save_root_path,'PTKOBJRegionDensity');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            
            mean_density_value_left = zeros(length(GroupName),1);
            mean_density_value_right = zeros(length(GroupName),1);
            SD_density_value_left = zeros(length(GroupName),1);
            SD_density_value_right = zeros(length(GroupName),1);
            region_volume_left = zeros(length(GroupName),1);
            region_volume_right = zeros(length(GroupName),1);
            region_volume_percent_left = zeros(length(GroupName),1);
            region_volume_percent_right = zeros(length(GroupName),1);
            
            unit_voxel_volume = VoxelSize(1).*VoxelSize(2).*VoxelSize(3);
            
            for i = 1:length(GroupName)
                x_coords_left = []; y_coords_left = []; z_coords_left = [];
                x_coords_right = []; y_coords_right = []; z_coords_right = [];
                density_value_left = [];density_value_right = [];
                current_index = index_matrix{i};
                for j = current_index
%                     if strcmp(GroupName{i}, 'SevereLAA')
                    Classified_Region_Img(Original_Region_Img==j) = i;
%                     end
                    region_index = find(Region_Img==j);
                    [tf_left, ~] = ismember(region_index,left_index);
                    region_index_left = region_index(tf_left);
                    HU_value_left = LungDicomImage.GrayscaleToRescaled(Raw(region_index_left));
                    density_left = double(HU_value_left)/1024+1;
                    [tf_right, ~] = ismember(region_index,right_index);
                    region_index_right = region_index(tf_right);
                    HU_value_right = LungDicomImage.GrayscaleToRescaled(Raw(region_index_right));
                    density_right = double(HU_value_right)/1024+1;
                    [x_left,y_left,z_left] = ind2sub(size(Region_Img),region_index_left);
                    [x_right,y_right,z_right] = ind2sub(size(Region_Img),region_index_right);
                    x_coords_left = [x_coords_left;x_left]; y_coords_left = [y_coords_left;y_left]; z_coords_left = [z_coords_left;z_left];
                    x_coords_right = [x_coords_right;x_right]; y_coords_right = [y_coords_right;y_right]; z_coords_right = [z_coords_right;z_right];
                    density_value_left = [density_value_left;density_left]; density_value_right = [density_value_right;density_right];
                end
                x_coords_left1 = y_coords_left.*VoxelSize(2).*2;
                y_coords_left1 = OriginalImageSize(2).*VoxelSize(2)-x_coords_left.*VoxelSize(1).*2;
                y_coords_left1 = OriginalImageSize(2)*VoxelSize(2)-y_coords_left1;
                z_coords_left1 = -z_coords_left.*VoxelSize(3);
                x_coords_right1 = y_coords_right.*VoxelSize(2).*2;
                y_coords_right1 = OriginalImageSize(2).*VoxelSize(2)-x_coords_right.*VoxelSize(1).*2;
                y_coords_right1 = OriginalImageSize(2)*VoxelSize(2)-y_coords_right1;
                z_coords_right1 = -z_coords_right.*VoxelSize(3);
                
                save_data_left = [x_coords_left1,y_coords_left1,z_coords_left1];
                save_data_right = [x_coords_right1,y_coords_right1,z_coords_right1];
                
                save_file_name_ipdata_left = strcat(GroupName{i},'_density_left.ipdata');
                save_file_name_exdata_left = strcat(GroupName{i},'_density_left.exdata');
                save_file_name_ipdata_right = strcat(GroupName{i},'_density_right.ipdata');
                save_file_name_exdata_right = strcat(GroupName{i},'_density_right.exdata');
                
                group_name_left = strcat(GroupName{i},'_density_left');
                group_name_right = strcat(GroupName{i},'_density_right');
                
                mean_density_value_left(i) = mean(density_value_left);
                mean_density_value_right(i) = mean(density_value_right);
                SD_density_value_left(i) = sqrt(sum((density_value_left-mean_density_value_left(i)).^2)./length(density_value_left));
                SD_density_value_right(i) = sqrt(sum((density_value_right-mean_density_value_right(i)).^2)./length(density_value_right));
                region_volume_left(i) = unit_voxel_volume.*length(density_value_left);
                region_volume_right(i) = unit_voxel_volume.*length(density_value_left);
                
                MYFieldIpdata(save_file_name_ipdata_left,save_data_left,density_value_left,group_name_left,0,save_full_path);
                MYExportField(save_file_name_exdata_left,save_data_left,density_value_left,group_name_left,offset_value,save_full_path);
                offset_value = offset_value + length(x_coords_left) + 100;
                MYFieldIpdata(save_file_name_ipdata_right,save_data_right,density_value_right,group_name_right,0,save_full_path);
                MYExportField(save_file_name_exdata_right,save_data_right,density_value_right,group_name_right,offset_value,save_full_path);
                offset_value = offset_value + length(x_coords_right) + 100;
            end
            
            [start_crop,end_crop]=MYGetLungROIForCT(LungDicomImage);
            Crop_Region_Img = Classified_Region_Img(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3));
            Crop_Region_Img = uint8(Crop_Region_Img);
            
            mean_density_value_left
            mean_density_value_right
            SD_density_value_left
            SD_density_value_right
            region_volume_left
            region_volume_right
            region_volume_percent_left = region_volume_left./sum(region_volume_left).*100
            region_volume_percent_right = region_volume_right./sum(region_volume_right).*100
            left = sum(region_volume_percent_left)
            right = sum(region_volume_percent_right)
            
            lungs.ChangeRawImage(Crop_Region_Img);
            results = lungs.Copy;
        end
    end
end
