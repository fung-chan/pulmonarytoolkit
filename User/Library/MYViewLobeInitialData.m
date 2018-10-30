%% This function is used for view each lobe data in PTK viewer

%% Generate lobe data matrix
LobeNameGroup={'LeftUpper','LeftLower','RightUpper','RightMiddle','RightLower'};
LobeDataMatrix=zeros(512,512,667);
for i=1:5
    LobeName=LobeNameGroup{i};
    LobeDataFileName=strcat('h11303',LobeName,'LobeData');
    FilePath='/hpc/yzha947/PulmonaryToolkit/MyFiles/LobeInitialIpdata/';
    FullLobeDataFileName=strcat(FilePath,LobeDataFileName,'.txt');
    load(FullLobeDataFileName);
    eval(['x=',LobeDataFileName,'(:,2);']);
    eval(['y=',LobeDataFileName,'(:,3);']);
    eval(['z=',LobeDataFileName,'(:,4);']);
    x1=round(x/0.71875);y1=512-(round((0.71875*512-y)/0.71875));z1=round((-z)/0.5); 
    for j=1:length(x1)
        LobeDataMatrix(y1(j),x1(j),z1(j))=i;
    end
end

%% Read in dicom raw image in PTK

