clear;close;clc;
PTKAddPaths;
ptk_main=PTKMain;
% source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP-076_BRP2-FRC22%-0.75--B31f_1768717';
source_path='/hpc/yzha947/2';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
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

LungDicomImage = PTKLoadImages(dataset.GetImageInfo);
[start_crop,end_crop]=MYGetLungROIForCT(LungDicomImage); 

VoxelSize=lungs.VoxelSize;
OriginalImageSize=lungs.OriginalImageSize;
LeftLungCoor_x1=(LeftLungCoor_y+start_crop(2)-1).*VoxelSize(2);
LeftLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(LeftLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
LeftLungCoor_z1=-(LeftLungCoor_z+start_crop(3)-1).*VoxelSize(3);
RightLungCoor_x1=(RightLungCoor_y+start_crop(2)-1).*VoxelSize(2);
RightLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(RightLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
RightLungCoor_z1=-(RightLungCoor_z+start_crop(3)-1).*VoxelSize(3);

LeftLungCoor=[LeftLungCoor_x1',LeftLungCoor_y1',LeftLungCoor_z1'];
RightLungCoor=[RightLungCoor_x1',RightLungCoor_y1',RightLungCoor_z1'];
writeExdata('2.exdata',LeftLungCoor,'LeftLung',0);
writeExdata('2.exdata',RightLungCoor,'RightLung',200000);
                
                
