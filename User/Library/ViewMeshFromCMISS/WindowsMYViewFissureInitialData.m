%% This function is used for view each Fissure data in PTK viewer

%% Generate Fissure data matrix
FissureNameGroup={'LeftOblique','RightOblique','RightHorizontal'};
row_num=512;col_num=512;sli_num=667;
row_res=0.71875;col_res=0.71875;sli_res=0.5;
FissureDataMatrix=zeros(row_num,col_num,sli_num,3);FissureDataMatrix1=zeros(row_num,col_num,sli_num);
% new_folder='/hpc/yzha947/CMISSmesh/GenerateDataPoint/GenerateFissureData/output/FissureTXTData';
% mkdir(new_folder);
for i=1:3
    FissureName=FissureNameGroup{i};
    FissureDataFileName=strcat('h11303FRC',FissureName,'FissureData');
    FilePath='D:\PhD\data\h11303\FissureData\FissureTXTData\';
%     OriginalFullFissureDataFileName=strcat(FilePath,FissureDataFileName,'.ipdata');
%     copyfile(OriginalFullFissureDataFileName,new_folder);
%     MovedIpdataFullFissureDataFileName=strcat(new_folder,'/',FissureDataFileName,'.ipdata');
    TXTFullFissureDataFileName=strcat(FilePath,FissureDataFileName,'.txt');
%     movefile(MovedIpdataFullFissureDataFileName,TXTFullFissureDataFileName);
    [a1,a2,a3,a4,a5,a6,a7]=textread(TXTFullFissureDataFileName,'%s%s%s%s%s%s%s');
    x=a2(2:end);y=a3(2:end);z=a4(2:end);
    x1=zeros(length(x),1);y1=zeros(length(y),1);z1=zeros(length(z),1);
    for k=1:length(x)
        x1(k)=str2num(x{k});
        y1(k)=str2num(y{k});
        z1(k)=str2num(z{k});
    end
    x2=round(x1/row_res);y2=col_num-(round((col_num*col_res-y1)/0.71875));z2=round((-z1)/sli_res);
    for j=1:length(x2)
%         FissureDataMatrix(y2(j),x2(j),z2(j),i)=1;
                FissureDataMatrix(y2(j),x2(j),z2(j),i)=i;
    end
%     SE=ones(3,3,3);
%     FissureDataMatrix(:,:,:,i)=imdilate(FissureDataMatrix(:,:,:,i),SE);
%     FissureDataMatrix(:,:,:,i)=imerode(FissureDataMatrix(:,:,:,i),SE);
%     FissureDataMatrix(:,:,:,i)=imfill(FissureDataMatrix(:,:,:,i),'holes');
%     FissureDataMatrix(:,:,:,i)=FissureDataMatrix(:,:,:,i)*i;
end
% Calculate left oblique fissure
for k=1:3
    FissureDataMatrix1=FissureDataMatrix1+FissureDataMatrix(:,:,:,k);
end
% for i1=1:sli_num
%     single_image=FissureDataMatrixLO(:,:,i1);
%     [row2,col2]=find(single_image==3);
%     if length(row2)~=0
%         col_sort=unique(sort(col2));
%         for i2=1:length(col_sort)
%             list=single_image(:,col_sort(i2));
%             [row3,col3]=find(list==3);
%             if length(row3)~=0
%                 row_average=round((max(row3)+min(row3))./2);
%                 FissureDataMatrixLO(min(row3):row_average,col_sort(i2),i1)=1;
%                 FissureDataMatrixLO((row_average+1):max(row3),col_sort(i2),i1)=2;
%             end
%         end
%     end
% end
% %% Calculate right oblique and horizontal fissure
% for k=3:5
%     FissureDataMatrixROH=FissureDataMatrixROH+FissureDataMatrix(:,:,:,k);
% end
% for i1=1:sli_num
%     single_image=FissureDataMatrixROH(:,:,i1);
%     [row2,col2]=find(single_image==7);
%     if length(row2)~=0
%         col_sort=unique(sort(col2));
%         for i2=1:length(col_sort)
%             list=single_image(:,col_sort(i2));
%             [row3,col3]=find(list==7);
%             if length(row3)~=0
%                 row_average=round((max(row3)+min(row3))./2);
%                 FissureDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=3;
%                 FissureDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=4;
%             end
%         end
%     end
% end
% for i1=1:sli_num
%     single_image=FissureDataMatrixROH(:,:,i1);
%     [row2,col2]=find(single_image==8);
%     if length(row2)~=0
%         col_sort=unique(sort(col2));
%         for i2=1:length(col_sort)
%             list=single_image(:,col_sort(i2));
%             [row3,col3]=find(list==8);
%             if length(row3)~=0
%                 row_average=round((max(row3)+min(row3))./2);
%                 FissureDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=3;
%                 FissureDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=5;
%             end
%         end
%     end
% end
% for i1=1:sli_num
%     single_image=FissureDataMatrixROH(:,:,i1);
%     [row2,col2]=find(single_image==9);
%     if length(row2)~=0
%         col_sort=unique(sort(col2));
%         for i2=1:length(col_sort)
%             list=single_image(:,col_sort(i2));
%             [row3,col3]=find(list==9);
%             if length(row3)~=0
%                 row_average=round((max(row3)+min(row3))./2);
%                 FissureDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=4;
%                 FissureDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=5;
%             end
%         end
%     end
% end
% FissureDataMatrix1=FissureDataMatrixLO+FissureDataMatrixROH;
%% Read in dicom raw image in PTK
ptk_main=PTKMain;
source_path='D:\PhD\data\h11303\frc\Raw\P2BRP-242_P2BRP-FRC-0.75--B30f_9175113';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
DicomDataset=dataset.GetResult('PTKOriginalImage'); %% Get the raw PTKDicom data
lungs=dataset.GetResult('PTKLeftAndRightLungs');
MYfissure_approximation=lungs.Copy;
MYfissure_approximation.ChangeRawImage(FissureDataMatrix1);
%%% Calculate the PTK fissure approximation
PTKfissure_approximation=dataset.GetResult('PTKFissureApproximation');
[start_crop,end_crop]=MYGetLungROIForCT(DicomDataset); 
PTKFissureApproximationRawImage1=PTKfissure_approximation.RawImage;
PTKFissureApproximationRawImage=zeros(row_num,col_num,sli_num);
PTKFissureApproximationRawImage(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3))=PTKFissureApproximationRawImage1;
PTKfissure_approximation.ChangeRawImage(PTKFissureApproximationRawImage);
fissureness = dataset.GetResult('PTKFissureness');%% Get the fissureness probablity for each voxel using Hessian matrix
MYfissure_approximationRawImage=MYfissure_approximation.RawImage;
MYfissure_approximationRawImage=MYfissure_approximationRawImage(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3));
MYfissure_approximation.ChangeRawImage(MYfissure_approximationRawImage);
results_left_fissure= MYGetResultsForLobe(MYfissure_approximation, dataset.GetResult('PTKGetLeftLungROI'), fissureness, 6, []);
results_right_fissure= MYGetResultsForLobe(MYfissure_approximation, dataset.GetResult('PTKGetRightLungROI'), fissureness, 2, 3);