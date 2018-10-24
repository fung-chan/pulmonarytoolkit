% input:
%       filename: filename with directory
%       data: data output
%       groupName: exdata group title
%       offset: cmiss numbering offset
function MYWriteExdata(filename,data,groupName,offset,save_full_path)
if ~exist(save_full_path)
    mkdir(save_full_path);
end
full_filename=strcat(save_full_path,'/',filename);
ipnode_FID=fopen(full_filename, 'wt');
fprintf(ipnode_FID,['Group name: ' groupName '\n']);
fprintf(ipnode_FID,'#Fields=1\n');
fprintf(ipnode_FID,'1) coordinates, coordinate, rectangular cartesian, #Components=3\n');
fprintf(ipnode_FID,' x.  Value index=1, #Derivatives=0\n');
fprintf(ipnode_FID,' y.  Value index=2, #Derivatives=0\n');
fprintf(ipnode_FID,' z.  Value index=3, #Derivatives=0\n');

for j=1:size(data,1)%-1
    fprintf(ipnode_FID,'Node: %d\n',j+offset);
    fprintf(ipnode_FID,'%15.8f  %15.8f  %15.8f\n',data(j,1),data(j,2),data(j,3));
end
fclose(ipnode_FID);

