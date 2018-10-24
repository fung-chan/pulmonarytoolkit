function MYFieldIpdata(filename,data,field,header,offset,save_full_path)
if ~exist(save_full_path)
    mkdir(save_full_path);
end
full_filename=strcat(save_full_path,'/',filename);
ipnode_FID=fopen(full_filename, 'wt');
fprintf(ipnode_FID,[header '\n']);
for j=1:size(data,1)%-1
    fprintf(ipnode_FID,'%2i %11.7f %11.7f %6.2f %5.3f 1.0 1.0 1.0 1.0\n',j+offset,data(j,1),data(j,2),data(j,3),field(j));
end
fclose(ipnode_FID);


