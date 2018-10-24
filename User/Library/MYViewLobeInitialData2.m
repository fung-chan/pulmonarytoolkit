%% This function is used for view each lobe data in PTK viewer

%% Generate lobe data matrix
LobeNameGroup={'LeftUpper','LeftLower','RightUpper','RightMiddle','RightLower'};
row_num=512;col_num=512;sli_num=667;
row_res=0.71875;col_res=0.71875;sli_res=0.5;
LobeDataMatrix=zeros(row_num,col_num,sli_num,5);LobeDataMatrix1=zeros(row_num,col_num,sli_num);
LobeDataMatrixLO=zeros(row_num,col_num,sli_num);LobeDataMatrixRHO=zeros(row_num,col_num,sli_num);
for i=1:5
    LobeName=LobeNameGroup{i};
    LobeDataFileName=strcat('h11303FRC',LobeName,'LobeData');
    FilePath='/hpc/yzha947/PulmonaryToolkit/User/MyFiles/LobeInitialIpdata/';
    FullLobeDataFileName=strcat(FilePath,LobeDataFileName,'.txt');
    [a1,a2,a3,a4,a5,a6,a7]=textread(FullLobeDataFileName,'%s%s%s%s%s%s%s');
    x=a2;y=a3;z=a4;
    x1=zeros(length(x),1);y1=zeros(length(y),1);z1=zeros(length(z),1);
    for k=1:length(x)
        x1(k)=str2num(x{k});
        y1(k)=str2num(y{k});
        z1(k)=str2num(z{k});
    end
    %     eval(['x=',LobeDataFileName,'(:,2);']);
    %     eval(['y=',LobeDataFileName,'(:,3);']);
    %     eval(['z=',LobeDataFileName,'(:,4);']);
    x2=round(x1/row_res);y2=col_num-(round((col_num*col_res-y1)/0.71875));z2=round((-z1)/sli_res);
    for j=1:length(x2)
        LobeDataMatrix(y2(j),x2(j),z2(j),i)=1;
    end
    SE=ones(3,3,3);
    LobeDataMatrix(:,:,:,i)=imdilate(LobeDataMatrix(:,:,:,i),SE);
    %     LobeDataMatrix(:,:,:,i)=imerode(LobeDataMatrix(:,:,:,i),SE);
    LobeDataMatrix(:,:,:,i)=imfill(LobeDataMatrix(:,:,:,i),'holes');
    LobeDataMatrix(:,:,:,i)=LobeDataMatrix(:,:,:,i)*i;
end

%% Calculate left oblique fissure
for k=1:2
    LobeDataMatrixLO=LobeDataMatrixLO+LobeDataMatrix(:,:,:,k);
end
for i1=1:sli_num
    single_image=LobeDataMatrixLO(:,:,i1);
    [row2,col2]=find(single_image==3);
    if length(row2)~=0
        col_sort=unique(sort(col2));
        for i2=1:length(col_sort)
            list=single_image(:,col_sort(i2));
            [row3,col3]=find(list==3);
            if length(row3)~=0
                row_average=round((max(row3)+min(row3))./2);
                LobeDataMatrixLO(min(row3):row_average,col_sort(i2),i1)=1;
                LobeDataMatrixLO((row_average+1):max(row3),col_sort(i2),i1)=2;
            end
        end
    end
end

%% Calculate right oblique fissure
for k=3:4
    LobeDataMatrixRO=LobeDataMatrixRO+LobeDataMatrix(:,:,:,k);
end
for i1=1:sli_num
    single_image=LobeDataMatrixRO(:,:,i1);
    [row2,col2]=find(single_image==7);
    if length(row2)~=0
        col_sort=unique(sort(col2));
        for i2=1:length(col_sort)
            list=single_image(:,col_sort(i2));
            [row3,col3]=find(list==7);
            if length(row3)~=0
                row_average=round((max(row3)+min(row3))./2);
                LobeDataMatrixRO(min(row3):row_average,col_sort(i2),i1)=3;
                LobeDataMatrixRO((row_average+1):max(row3),col_sort(i2),i1)=4;
            end
        end
    end
end
%% Calculate right oblique and horizontal fissure
for k=3:5
    LobeDataMatrixROH=LobeDataMatrixROH+LobeDataMatrix(:,:,:,k);
end
for i1=1:sli_num
    single_image=LobeDataMatrixROH(:,:,i1);
    [row2,col2]=find(single_image==7);
    if length(row2)~=0
        col_sort=unique(sort(col2));
        for i2=1:length(col_sort)
            list=single_image(:,col_sort(i2));
            [row3,col3]=find(list==7);
            if length(row3)~=0
                row_average=round((max(row3)+min(row3))./2);
                LobeDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=3;
                LobeDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=4;
            end
        end
    end
end
for i1=1:sli_num
    single_image=LobeDataMatrixROH(:,:,i1);
    [row2,col2]=find(single_image==8);
    if length(row2)~=0
        col_sort=unique(sort(col2));
        for i2=1:length(col_sort)
            list=single_image(:,col_sort(i2));
            [row3,col3]=find(list==8);
            if length(row3)~=0
                row_average=round((max(row3)+min(row3))./2);
                LobeDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=3;
                LobeDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=5;
            end
        end
    end
end
for i1=1:sli_num
    single_image=LobeDataMatrixROH(:,:,i1);
    [row2,col2]=find(single_image==9);
    if length(row2)~=0
        col_sort=unique(sort(col2));
        for i2=1:length(col_sort)
            list=single_image(:,col_sort(i2));
            [row3,col3]=find(list==9);
            if length(row3)~=0
                row_average=round((max(row3)+min(row3))./2);
                LobeDataMatrixROH(min(row3):row_average,col_sort(i2),i1)=4;
                LobeDataMatrixROH((row_average+1):max(row3),col_sort(i2),i1)=5;
            end
        end
    end
end
LobeDataMatrix1=LobeDataMatrixLO+LobeDataMatrixROH;
%% Read in dicom raw image in PTK
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP242-H11303/FRC/Raw/P2BRP-242_P2BRP-FRC-0.75--B30f_9175113';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
DicomDataset=dataset.GetResult('PTKOriginalImage'); %% Get the raw PTKDicom data
lungs=dataset.GetResult('PTKLeftAndRightLungs');
lungs.ChangeRawImage(LobeDataMatrix1);
