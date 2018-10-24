function MYWriteTxt(filename,data,save_full_path)
if ~exist(save_full_path)
    mkdir(save_full_path);
end
full_filename=strcat(save_full_path,'/',filename);
ipnode_FID=fopen(full_filename, 'wt');
for j=1:size(data,1)%-1
    fprintf(ipnode_FID,'%d %d %d %d\n',data(j,1),data(j,2),data(j,3),data(j,4));
end
fclose(ipnode_FID);


