function MYWriteIpdata(filename,data,header,offset,save_full_path)
if ~exist(save_full_path)
    mkdir(save_full_path);
end
full_filename=strcat(save_full_path,'/',filename);
ipnode_FID=fopen(full_filename, 'wt');
fprintf(ipnode_FID,[header '\n']);
for j=1:size(data,1)%-1
    fprintf(ipnode_FID,'%11i  %15.8f  %15.8f  %15.8f  1.0 1.0 1.0\n',j+offset,data(j,1),data(j,2),data(j,3));
end
fclose(ipnode_FID);


