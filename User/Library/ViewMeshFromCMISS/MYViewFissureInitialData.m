%% This function is used for view each Fissure data in PTK viewer

%% Generate Fissure data matrix
FissureNameGroup={'LeftOblique','RightOblique','RightHorizontal'};
row_num=512;col_num=512;sli_num=667;
row_res=0.71875;col_res=0.71875;sli_res=0.5;
FissureDataMatrix=zeros(row_num,col_num,sli_num,3);FissureDataMatrix1=zeros(row_num,col_num,sli_num);
new_folder='/hpc/yzha947/CMISSmesh/GenerateDataPoint/GenerateFissureData/output/FissureTXTData';
mkdir(new_folder);
for i=1:3
    FissureName=FissureNameGroup{i};
    FissureDataFileName=strcat('h11303FRC',FissureName,'FissureData');
    FilePath='/hpc/yzha947/CMISSmesh/GenerateDataPoint/GenerateFissureData/output/';
    OriginalFullFissureDataFileName=strcat(FilePath,FissureDataFileName,'.ipdata');
    copyfile(OriginalFullFissureDataFileName,new_folder);
    MovedIpdataFullFissureDataFileName=strcat(new_folder,'/',FissureDataFileName,'.ipdata');
    TXTFullFissureDataFileName=strcat(new_folder,'/',FissureDataFileName,'.txt');
    movefile(MovedIpdataFullFissureDataFileName,TXTFullFissureDataFileName);
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

for k=1:3
    FissureDataMatrix1=FissureDataMatrix1+FissureDataMatrix(:,:,:,k);
end

%% Read in dicom raw image in PTK
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP242-H11303/FRC/Raw/P2BRP-242_P2BRP-FRC-0.75--B30f_9175113';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
DicomDataset=dataset.GetResult('PTKOriginalImage'); %% Get the raw PTKDicom data
lungs=dataset.GetResult('PTKLeftAndRightLungs');
MYfissure_approximation=lungs.Copy;
MYfissure_approximation.ChangeRawImage(FissureDataMatrix1);

%%% Calculate the PTK fissure approximation
PTKfissure_approximation=dataset.GetResult('PTKFissureApproximation');
[start_crop,end_crop]=MYGetLungROIForCT(DicomDataset); 
PTKFissureApproximationRawImage=PTKfissure_approximation.RawImage;
PTKFissureApproximationRecropRawImage=zeros(row_num,col_num,sli_num);
PTKFissureApproximationRecropRawImage(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3))=PTKFissureApproximationRawImage;
PTKfissure_approximationRecrop=PTKfissure_approximation.Copy;
PTKfissure_approximationRecrop.ChangeRawImage(PTKFissureApproximationRecropRawImage);
results_lobe=MYGetLobesFromInitialFissure(dataset,DicomDataset,MYfissure_approximation);%% Get the lobe segmentation result
%% Recrop the lobe segementation result
MYlobes=zeros(row_num,col_num,sli_num);
MYlobes(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3))=results_lobe.RawImage;
results_lobe.ChangeRawImage(MYlobes);
lobes=dataset.GetResult('PTKLobes');
lobes1=zeros(row_num,col_num,sli_num);
lobes1(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3))=lobes.RawImage;
lobes.ChangeRawImage(lobes1);
a=DicomDataset.Copy;
b=results_lobe.Copy;
c=lobes.Copy;
PTKViewer(a,b);
PTKViewer(a,c);