function MYExportField(filename,coordinates,field, group_name, offset,save_full_path)
if ~exist(save_full_path)
    mkdir(save_full_path);
end
full_filename=fullfile(save_full_path, filename);
ipnode_FID=fopen(full_filename, 'wt');
fprintf(ipnode_FID,['Group name: ', group_name, '\n']);
fprintf(ipnode_FID,'#Fields=2\n');
fprintf(ipnode_FID,' 1) coordinates, coordinate, rectangular cartesian, #Components=3\n');
fprintf(ipnode_FID,' x.  Value index=1, #Derivatives=0\n');
fprintf(ipnode_FID,' y.  Value index=2, #Derivatives=0\n');
fprintf(ipnode_FID,' z.  Value index=3, #Derivatives=0\n');
fprintf(ipnode_FID,' 2) density, field, rectangular cartesian, #Components=1\n');
fprintf(ipnode_FID,' 1.  Value index= 4, #Derivatives=0\n');

for j=1:size(coordinates,1)
    fprintf(ipnode_FID,'Node: %d\n',j+offset);
    fprintf(ipnode_FID,'%15.8f  %15.8f  %15.8f\n',coordinates(j,1),coordinates(j,2),coordinates(j,3));
    fprintf(ipnode_FID,'%15.8f\n',field(j));
end
fclose(ipnode_FID);
end
