classdef MYAccuracyEvaluationAbnormal < PTKGuiPlugin
    % PTKExportEditedImage. Gui Plugin
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKExportEditedImage is a Gui Plugin for the TD Pulmonary Toolkit.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'Accuracy Evaluation Abnormal'
        SelectedText = 'Accuracy Evaluation'
        ToolTip = 'Show the quantification of the accuracy of automatic segmentation'
        Category = 'Accuracy Analysis'
        Visibility = 'Overlay'
        Mode = 'Edit'
        
        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            % Get the previous data path
            background_image = ptk_gui_app.ImagePanel.BackgroundImage;
            full_data_path = background_image.MetaHeader.Filename;
            [current_data_path, ~, ~] = fileparts(full_data_path);
            
            % Get manual data path
            manual_root_path = uigetdir(current_data_path, 'Select Directory to Read in Manual Fissure Points');
            if manual_root_path == 0
                reporting.Error('MYAccuracyEvaluation:ProgramErro', 'Can not read in manual mesh');
            end
            
            % Generate fissure txt folder
            Fissure_txt_path = fullfile(manual_root_path , 'TxtData');
            if ~exist(Fissure_txt_path)
                mkdir(Fissure_txt_path);
            end
            
            % Generate accuacy analysis result folder
            Fissure_accuracy_path = fullfile(manual_root_path , 'AccuracyResult');
            if ~exist(Fissure_accuracy_path)
                mkdir(Fissure_accuracy_path);
            end
            
            % Get the previous image
            fissure_image = ptk_gui_app.ImagePanel.OverlayImage;
            fissure_image_raw = ptk_gui_app.ImagePanel.OverlayImage.RawImage;
            image_size = fissure_image.ImageSize;
            original_image_size = fissure_image.OriginalImageSize;
            image_voxel = fissure_image.VoxelSize;
            image_origin = fissure_image.Origin;
            
            % Get fissure plane coordinateds
            LO_fissure_index = find(fissure_image_raw == 4);
            RO_fissure_index = find(fissure_image_raw == 3);
            RH_fissure_index = find(fissure_image_raw == 2);
            [LO_PTK_fissure_coords_x,LO_PTK_fissure_coords_y,LO_PTK_fissure_coords_z] = ...
                ind2sub(image_size,LO_fissure_index);
            [RO_PTK_fissure_coords_x,RO_PTK_fissure_coords_y,RO_PTK_fissure_coords_z] = ...
                ind2sub(image_size,RO_fissure_index);
            [RH_PTK_fissure_coords_x,RH_PTK_fissure_coords_y,RH_PTK_fissure_coords_z] = ...
                ind2sub(image_size,RH_fissure_index);
            
            automatic_LO_coords_x = (LO_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
%             automatic_LO_coords_x = original_image_size(2).*image_voxel(2)-automatic_LO_coords_x;
            automatic_LO_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(LO_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            automatic_LO_coords_y = original_image_size(2).*image_voxel(2)-automatic_LO_coords_y;
            automatic_LO_coords_z = -(LO_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            automatic_LO_coords_z = -(original_image_size(3).*image_voxel(3) + automatic_LO_coords_z);
            automatic_RO_coords_x = (RO_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
%             automatic_RO_coords_x = original_image_size(2).*image_voxel(2)-automatic_RO_coords_x;
            automatic_RO_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(RO_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            automatic_RO_coords_y = original_image_size(2).*image_voxel(2)-automatic_RO_coords_y;
            automatic_RO_coords_z = -(RO_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            automatic_RO_coords_z = -(original_image_size(3).*image_voxel(3) + automatic_RO_coords_z);
            automatic_RH_coords_x = (RH_PTK_fissure_coords_y+image_origin(2)-1).*image_voxel(2);
%             automatic_RH_coords_x = original_image_size(2).*image_voxel(2)-automatic_RH_coords_x;
            automatic_RH_coords_y = original_image_size(2).*image_voxel(2)-(original_image_size(1)-(RH_PTK_fissure_coords_x+image_origin(1)-1)).*image_voxel(1);
            automatic_RH_coords_y = original_image_size(2).*image_voxel(2)-automatic_RH_coords_y;
            automatic_RH_coords_z = -(RH_PTK_fissure_coords_z+image_origin(3)-1).*image_voxel(3);
            automatic_RH_coords_z = -(original_image_size(3).*image_voxel(3) + automatic_RH_coords_z);
            automatic_LOblique = [automatic_LO_coords_x automatic_LO_coords_y automatic_LO_coords_z];
            automatic_RHorizontal = [automatic_RH_coords_x automatic_RH_coords_y automatic_RH_coords_z];
            automatic_ROblique = [automatic_RO_coords_x automatic_RO_coords_y automatic_RO_coords_z];
            
            Groups = {'LOblique', 'RHorizontal', 'ROblique'};
            for i = 1:3
                % Get the manual data
                current_filename = strcat('fissure_', Groups{i}, 'trimmed.ipdata');
                full_manual_filename = fullfile(manual_root_path, current_filename);
                moved_full_manual_filename = fullfile(Fissure_txt_path, current_filename);
                txt_filename = strcat('fissure_', Groups{i}, 'trimmed.txt');
                txt_full_manual_filename = fullfile(Fissure_txt_path, txt_filename);
                copyfile(full_manual_filename,Fissure_txt_path);
                movefile(moved_full_manual_filename, txt_full_manual_filename);
                
                % Generate the manual data matixes
                [a1,a2,a3,a4,a5,a6,a7] = textread(txt_full_manual_filename,'%s%s%s%s%s%s%s');
                x=a2(2:end); y=a3(2:end); z=a4(2:end);
                manual_x = cellfun(@str2num,x);
                manual_y = cellfun(@str2num,y);
%                 manual_y = original_image_size(2).*image_voxel(2)-manual_y;
                manual_z = cellfun(@str2num,z);
                if i == 1
                    manual_LOblique = [manual_x manual_y manual_z];
                elseif i == 2
                    manual_RHorizontal = [manual_x manual_y manual_z];
                elseif i == 3
                    manual_ROblique = [manual_x manual_y manual_z];
                end
            end
            
            % Find the nearest point in automatic points for each manual one
            for i = 1:3
                manual_file_name = strcat('manual_', Groups{i});
                automatic_file_name = strcat('automatic_', Groups{i});
                manual_Cartesian_coords_filename = strcat('manual_Cartesian_coords_', Groups{i});
                automatic_Cartesian_coords_filename = strcat('automatic_Cartesian_coords_', Groups{i});
                AA=[];BB=[];CC=[];DD=[];EE=[];
                eval(['M=',manual_file_name,';'])
                if isempty(M)
                    eval([manual_file_name,'=[1,1,1];'])
                end
                eval(['length_number=length(', manual_file_name, '(:,1));'])
                for j = 1:length_number
                    %                 for j = 1:length(manual_file_name)
                    eval(['A=[', manual_file_name,'(j,1) ', manual_file_name, '(j,2) ', manual_file_name, '(j,3)];'])
                    eval(['B=[', automatic_file_name,'(:,1) ', automatic_file_name, '(:,2) ', automatic_file_name, '(:,3)];'])
                    if isempty(B)
                        B = [1,1,1];
                    end
                    
                    %compute Euclidean distances:
                    distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
                    
                    %find the smallest distance and use that as an index into B:
                    closest = B(find(distances==min(distances)),:);
                    AA=[AA;closest(1,1)]; BB=[BB;closest(1,2)]; CC=[CC;closest(1,3)];
                    
                    % Calculate the Cartesian coordinates of manual and automatic points
                    manual = sqrt(A(1).^2+A(2).^2+A(3).^2);
                    automatic = sqrt(closest(1,1).^2+closest(1,2).^2+closest(1,3).^2);
                    DD = [DD;manual]; EE = [EE;automatic];
                end
                
                eval([manual_Cartesian_coords_filename, '=DD;'])
                eval([automatic_Cartesian_coords_filename, '=EE;'])
                
                % Do analysis of varaince with two groups of data points
                % (manual and automatic) into excel
                %                 eval(['p = anova1([', manual_Cartesian_coords_filename, ',', automatic_Cartesian_coords_filename, '];'])
                %                 p_value_filename = strcat('P_value_', Groups{i});
                %                 eval([p_value_filename, '=p;'])
                
                % Output two groups of data points (manual and automatic) into excel
                current_filename = strcat(Groups{i}, 'SignificanceAnalysis.xlsx');
                excel_file_name = fullfile(Fissure_accuracy_path, current_filename);
                eval(['Output_Cartesian_Coords=[', manual_Cartesian_coords_filename, ' '...
                    automatic_Cartesian_coords_filename, '];'])
                xlswrite(excel_file_name, Output_Cartesian_Coords);
                
                % Calculate error distance of each couple points
                distance_file_name = strcat(Groups{i}, '_Distance');
                eval([distance_file_name, '=sqrt((AA-', manual_file_name, '(:,1)', ').^2+(BB-', ...
                    manual_file_name, '(:,2)', ').^2+(CC-', manual_file_name, '(:,3)', ').^2);'])
                
                % Output distance data in exdata format
                output_file_name = strcat(distance_file_name, 'Difference.exdata');
                group_name = strcat(Groups{i}, '_fissure');
                eval(['MYExportField(output_file_name,' manual_file_name, ',', distance_file_name,...
                    ',group_name,(i-1)*1000,Fissure_accuracy_path);'])
                
                % Calculate mean difference, RMS error, maximum error
                Distance_mean_filename = strcat('Distance_mean_',Groups{i});
                Distance_RMSE_filename = strcat('Distance_RMSE_', Groups{i});
                Distance_max_filename = strcat('Distance_max_', Groups{i});
                
                eval([Distance_mean_filename, '=sum(', distance_file_name, ')/length_number;'])
                eval([Distance_RMSE_filename, '=sqrt(sum(', distance_file_name, '.^2)/length_number);'])
                eval([Distance_max_filename, '=max(', distance_file_name, ');'])
                
                % Calculate the percentile accuracy
                percentile_accuracy_filename = strcat('Percentile_accuracy_', Groups{i});
                eval(['accuracy_number=length(find(', distance_file_name, '<=3));'])
                eval([percentile_accuracy_filename, '=accuracy_number/length_number*100;'])
            end
            
            % Show the result in display box
            % first line content
            Distance_mean_filename = strcat('Distance_mean_',Groups{1});
            Distance_RMSE_filename = strcat('Distance_RMSE_', Groups{1});
            Distance_max_filename = strcat('Distance_max_', Groups{1});
            Percentile_accuracy_filename = strcat('Percentile_accuracy_', Groups{1});
            show_content_firstline = strcat('LOblique mean difference is:  ', eval(['num2str(',Distance_mean_filename,')']),...
                '  LOblique RMS error is:  ', eval(['num2str(',Distance_RMSE_filename,')']), '  LOblique maximum difference is:  ',...
                eval(['num2str(',Distance_max_filename,')']), '  LOblique percentile accuracy is:  ',...
                eval(['num2str(',Percentile_accuracy_filename,')']), '%')
            % second line content
            Distance_mean_filename = strcat('Distance_mean_',Groups{2});
            Distance_RMSE_filename = strcat('Distance_RMSE_', Groups{2});
            Distance_max_filename = strcat('Distance_max_', Groups{2});
            Percentile_accuracy_filename = strcat('Percentile_accuracy_', Groups{2});
            show_content_secondline = strcat('RHorizontal mean difference is:  ', eval(['num2str(',Distance_mean_filename,')']),...
                '  RHorizontal RMS error is:  ', eval(['num2str(',Distance_RMSE_filename,')']), '  RHorizontal maximum difference is:  ',...
                eval(['num2str(',Distance_max_filename,')']), '  RHorizontal percentile accuracy is:  ',...
                eval(['num2str(',Percentile_accuracy_filename,')']), '%')
            % third line content
            Distance_mean_filename = strcat('Distance_mean_',Groups{3});
            Distance_RMSE_filename = strcat('Distance_RMSE_', Groups{3});
            Distance_max_filename = strcat('Distance_max_', Groups{3});
            Percentile_accuracy_filename = strcat('Percentile_accuracy_', Groups{3});
            show_content_thirdline = strcat('ROorizontal mean difference is:  ', eval(['num2str(',Distance_mean_filename,')']),...
                '  ROorizontal RMS error is:  ', eval(['num2str(',Distance_RMSE_filename,')']), '  ROorizontal maximum difference is:  ',...
                eval(['num2str(',Distance_max_filename,')']), '  ROblique percentile accuracy is:  ',...
                eval(['num2str(',Percentile_accuracy_filename,')']), '%')
            h = msgbox({show_content_firstline;show_content_secondline;show_content_thirdline},...
                'Quantification accuracy result');
            
            % Open distance shown in different colour in Cmgui
%             cmgui_file_name = strcat('/hpc/yzha947/PulmonaryToolkit (another copy)', '/ViewDistanceErrorData.com');
            current_filename = mfilename('fullpath');
            [current_filepath,~,~] = fileparts(current_filename);
            cmgui_filename = fullfile(current_filepath, '..', '..', '..','ViewDistanceErrorData.com');
            linux_command = ['cmgui',' ', cmgui_filename];
            cd(Fissure_accuracy_path);
            unix(linux_command);
        end
    end
end
