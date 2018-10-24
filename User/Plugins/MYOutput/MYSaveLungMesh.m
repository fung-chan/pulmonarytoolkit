classdef MYSaveLungMesh < PTKPlugin
    % MYSaveLungMesh. Plugin for creating an STL surface mesh file
    %     for each lung
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    
    properties
        ButtonText = 'Save lung <br>mesh'
        ToolTip = 'Saves STL meshes for each lung in the Output folder'
        Category = 'Export'

        AllowResultsToBeCached = true
        AlwaysRunPlugin = true
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = true
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = false
    end
    
    methods (Static)
        function results = RunPlugin(dataset, reporting)
            reporting.ShowProgress('Creating mesh for lungs');

            lungs = dataset.GetResult('PTKLeftAndRightLungs');
            
%             lungs_image = lungs.RawImage;
%             dilated_image = zeros(lungs.ImageSize);
%             for i=1:lungs.ImageSize(3);
%             SE = [1,1,1;1,1,1;1,1,1];
%             dilated_image(:,:,i)=imdilate(lungs_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             dilated_image(:,:,i)=imdilate(dilated_image(:,:,i),SE);
%             end
%             
%             lungs.ChangeRawImage(dilated_image);
            lung_names = {'Right', 'Left'};
            lung_index_colours = [1, 2];

            coordinate_system = PTKCoordinateSystem.DicomUntranslated;
            template_image = lungs;

            for lung_index = 1 : 2
                reporting.UpdateProgressStage((lung_index-1), 2);
                
                current_lung = lungs.Copy;
                current_lung.ChangeRawImage(lungs.RawImage == lung_index_colours(lung_index));
                current_lung = PTKFillHolesInImage(current_lung);
                
                smoothing_size = 3;
                filename = ['lungSurfaceMesh_' lung_names{lung_index} '.stl'];
                current_lung.AddBorder(6);
                reporting.PushProgress;
                
                small_structures = false;
                dataset.SaveSurfaceMesh('PTKSavelungMesh', 'lung mesh', filename, 'Surface mesh of the segmented lungs' , current_lung, smoothing_size, small_structures, coordinate_system, template_image);
                
                reporting.PopProgress;
            end
            results = lungs;
            reporting.UpdateProgressValue(100);
            reporting.CompleteProgress;
            
        end
        
        function results = GenerateImageFromResults(results, image_templates, reporting)
        end        
    end
end