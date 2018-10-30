classdef MYOutputLungData < PTKPlugin
    % MYOutputLungData. Plugin for outputing the lung segmentation result and
    % saved as exdata format
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
        ButtonText = 'Output Lung'
        ToolTip = 'Output Lung segmentation result and convert it into exdata'
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
            
            % using bwboundaries to separate lungs
            lungs=dataset.GetResult('PTKLeftAndRightLungs');
            Lung=lungs.RawImage;
            [a1,b1,c1]=size(Lung);
            lung_surface = zeros(size(Lung));
            Right = zeros(size(Lung));
            Left = zeros(size(Lung));
            LeftLungCoor_x=[];RightLungCoor_x=[];
            LeftLungCoor_y=[];RightLungCoor_y=[];
            LeftLungCoor_z=[];RightLungCoor_z=[];
            
            for i=1:c1
                AxLung=Lung(:,:,i);
                if ~any(AxLung)
                    continue
                else
                    AxLung=imfill(AxLung,'holes'); %% fill the holes
                    
                    Right(:,:,i) = zeros(size(AxLung));
                    Left(:,:,i) = zeros(size(AxLung));
                    B_left = bwboundaries(AxLung==2,'noholes');
                    B_right = bwboundaries(AxLung==1,'noholes');
                    
                    for n = 1:length(B_right)
                        poly = B_right{n};
                        for m=1:length(poly)
                            Right(poly(m,1),poly(m,2), i) = 1;
                        end
                    end
                    
                    for n = 1:length(B_left)
                        poly = B_left{n};
                        for m=1:length(poly)
                            Left(poly(m,1),poly(m,2), i) = 1;
                        end
                    end
                    
                    lung_surface (:,:,i) = Left(:,:,i) + Right(:,:,i).*2;
                    
                    for j=1:2:a1
                        for k=1:3:b1
                            if lung_surface(j,k,i)==1
                                LeftLungCoor_x=[LeftLungCoor_x,j];
                                LeftLungCoor_y=[LeftLungCoor_y,k];
                                LeftLungCoor_z=[LeftLungCoor_z,i];
                            end
                            
                            if lung_surface(j,k,i)==2
                                RightLungCoor_x=[RightLungCoor_x,j];
                                RightLungCoor_y=[RightLungCoor_y,k];
                                RightLungCoor_z=[RightLungCoor_z,i];
                            end
                        end
                    end
                    
                    
                end
            end
            
            VoxelSize=lungs.VoxelSize;
            OriginalImageSize=lungs.OriginalImageSize;
            start_crop=lungs.Origin;
            LeftLungCoor_x1=(LeftLungCoor_y+start_crop(2)-1).*VoxelSize(2);
            LeftLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(LeftLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
            LeftLungCoor_z1=-(LeftLungCoor_z+start_crop(3)-1).*VoxelSize(3);
            RightLungCoor_x1=(RightLungCoor_y+start_crop(2)-1).*VoxelSize(2);
            RightLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(RightLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
            RightLungCoor_z1=-(RightLungCoor_z+start_crop(3)-1).*VoxelSize(3);
            
            LeftLungCoor=[LeftLungCoor_x1',LeftLungCoor_y1',LeftLungCoor_z1'];
            RightLungCoor=[RightLungCoor_x1',RightLungCoor_y1',RightLungCoor_z1'];
            
            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Lung Surface Points');
            save_full_path=fullfile(save_root_path,'PTKLung');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            MYWriteExdata('surface_Lefttrimmed.exdata',LeftLungCoor,'surface_Left',10000,save_full_path);
            MYWriteExdata('surface_Righttrimmed.exdata',RightLungCoor,'surface_Right',200000,save_full_path);
            MYWriteIpdata('surface_Lefttrimmed.ipdata',LeftLungCoor,'surface_Left',10000,save_full_path);
            MYWriteIpdata('surface_Righttrimmed.ipdata',RightLungCoor,'surface_Right',200000,save_full_path);
            lungs.ChangeRawImage(lung_surface);
            results = lungs.Copy;
        end
    end
end
