classdef MYOutputFissure < PTKGuiPlugin
    % MYOutputFissure. Gui Plugin
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     MYOutputFissure is a Gui Plugin for the TD Pulmonary Toolkit.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'Export Edit Fissure'
        SelectedText = 'Export Edit Fissure'
        ToolTip = 'Exports the current edit fissure to an external CMISS file'
        Category = 'Import / Export'
        Visibility = 'Overlay'
        Mode = 'Edit'
        
        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            fissure_image = ptk_gui_app.ImagePanel.OverlayImage;
            fissure_image_raw = ptk_gui_app.ImagePanel.OverlayImage.RawImage;
            image_size = fissure_image.ImageSize;
            original_image_size = fissure_image.OriginalImageSize;
            image_voxel = fissure_image.VoxelSize;
            image_origin = fissure_image.Origin;
            
            % Get fissure plane coordinateds
            LO_fissure_index = find(fissure_image_raw == 4);
            RO_fissure_index = find(fissure_image_raw == 3);
            RH_fissure_index = find(fissure_image_raw == 2);
            [LO_PTK_fissure_coords_x,LO_PTK_fissure_coords_y,LO_PTK_fissure_coords_z] = ...
                ind2sub(image_size,LO_fissure_index);
            [RO_PTK_fissure_coords_x,RO_PTK_fissure_coords_y,RO_PTK_fissure_coords_z] = ...
                ind2sub(image_size,RO_fissure_index);
            [RH_PTK_fissure_coords_x,RH_PTK_fissure_coords_y,RH_PTK_fissure_coords_z] = ...
                ind2sub(image_size,RH_fissure_index);
            
            LO_coords_x = (LO_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
            LO_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(LO_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            LO_coords_z = -(LO_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            RO_coords_x = (RO_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
            RO_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(RO_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            RO_coords_z = -(RO_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            RH_coords_x = (RH_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
            RH_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(RH_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            RH_coords_z = -(RH_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            
            LO_coords = [LO_coords_x(1:5:end),LO_coords_y(1:5:end),LO_coords_z(1:5:end)];
            RO_coords = [RO_coords_x(1:5:end),RO_coords_y(1:5:end),RO_coords_z(1:5:end)];
            RH_coords = [RH_coords_x(1:5:end),RH_coords_y(1:5:end),RH_coords_z(1:5:end)];
            
            % Get the saving path
            background_image = ptk_gui_app.ImagePanel.BackgroundImage;
            full_data_path = background_image.MetaHeader.Filename;
            [current_data_path, ~, ~] = fileparts(full_data_path);
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Fissure Points');
            save_full_path=fullfile(save_root_path,'PTKFissure');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            MYWriteExdata('fissure_LObliquetrimmed.exdata',LO_coords,'fissure_LOblique',100000,save_full_path);
            MYWriteExdata('fissure_RHorizontaltrimmed.exdata',RH_coords,'fissure_RHorizontal',250000,save_full_path);
            MYWriteExdata('fissure_RObliquetrimmed.exdata',RO_coords,'fissure_ROblique',280000,save_full_path);
            MYWriteIpdata('fissure_LObliquetrimmed.ipdata',LO_coords,'fissure_LOblique',100000,save_full_path);
            MYWriteIpdata('fissure_RHorizontaltrimmed.ipdata',RH_coords,'fissure_RHorizontal',250000,save_full_path);
            MYWriteIpdata('fissure_RObliquetrimmed.ipdata',RO_coords,'fissure_ROblique',280000,save_full_path);
        end
    end
end
