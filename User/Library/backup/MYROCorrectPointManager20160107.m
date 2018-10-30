classdef MYROCorrectPointManager < PTKTool
    % MYCorrectPointManager. Part of the internal gui for the Pulmonary Toolkit.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the gui of the Pulmonary Toolkit.
    %
    %     Manager provides functionality for creating, editing and
    %     deleting marker points associated with an image using the
    %     PTKViewerPanel.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'ROMYMark'
        Cursor = 'cross'
        RestoreKeyPressCallbackWhenSelected = false
        ToolTip = 'Add or modify correct points and do a multipoint correction.'
        Tag = 'MYROMark'
        ShortcutKey = 'm'
    end
    
    properties
        % When a marker is placed in close proximity to an existing marker of
        % the same colour, we assume that the user is actually trying to replace
        % the marker.
        ClosestDistanceForReplaceMarker = 10
    end
    
    properties (SetAccess = private)
        
        % Keep a record of when we have unsaved changes to markers
        MarkerImageHasChanged = false
        
    end
    
    properties (SetAccess = private, SetObservable)
        
        % The colour that new markers will be set to
        CurrentColour
        
        % Whether marker positions are displayed
        ShowTextLabels = true
        
        FixedOuterBoundary = true % When this is set to true, the outer boundary cannot be changed
        
        BrushSize = 15 % Minimum size of the gaussian used to adjust the distance tranform
        
        LockToBorderDistance = 10 % When the mouse is closer to the border then this, the brush will actually be applied on the border
        
        MinimumEditVolume = [20, 20, 20] % Post-edit processing (such as removing orphaned regions) is applied to this grid
    end
    
    properties (Access = private)
        MarkerPointImage
        MarkerPoints
        ViewerPanel
        Callback
        CurrentlyHighlightedMarker
        SliceNumber
        Orientation
        CoordinateLimits
        LockCallback = false
        Enabled = false
        DefaultColour = 2;
        IsDragging = false
        EditModeInitialised = false
        Colours
        ClosestColour
        SecondClosestColour
        FissureColour = 3;
        OverlayChangeLock
        UndoStack
        RO_lobe = [];
    end
    
    methods
        function obj = MYROCorrectPointManager(viewer_panel, callback)
            obj.ViewerPanel = viewer_panel;
            obj.Callback = callback;
            obj.UndoStack = PTKUndoStack([], 5);
            obj.MarkerPointImage = MYROCorrectPointImage;
        end
        
        function ChangeMarkerImage(obj, new_image)
            obj.MarkerPointImage.ChangeMarkerSubImage(new_image);
            obj.MarkerImageChanged;
            obj.MarkerImageHasChanged = false;
        end
        
        function Correct(obj,enable,slice_markers)
            if enable
                obj.InitialiseEditMode;
                obj.ViewerPanel.ShowWaitCursor;
                
                preview_fissure = obj.ViewerPanel.OverlayImage.RawImage;
                
                % Get the lung surface mask
                cache_directory=obj.ViewerPanel.Parent.GetCacheDirectory;
                reporting=PTKReportingDefault;
                if isempty(obj.RO_lobe)
                    lung_results = PTKDiskUtilities.LoadStructure(cache_directory, 'PTKLeftAndRightLungs', reporting);
                    lung_mask = lung_results.value;
                    lung_mask_image = lung_mask.RawImage;
                    lung_mask_image(lung_mask_image~=1) = 0;
                    lung_mask.ChangeRawImage(lung_mask_image);
                    
                    fissure_plane = obj.ViewerPanel.OverlayImage;
                    results = MYGetResultsForRightObliqueLobe(lung_mask.Copy, fissure_plane.Copy, reporting);
                    obj.RO_lobe = results;
                end
                
                obj.ViewerPanel.OverlayImage = obj.RO_lobe;
                if ~isempty(slice_markers)
                    for i=1:length(slice_markers)
                        coords=[slice_markers{i}.x , slice_markers{i}.y];
                        obj.StartBrush(coords);
                        obj.ApplyBrush(coords);
                        
                    end
                end
                
                obj.RO_lobe = obj.ViewerPanel.OverlayImage.Copy;
                
                if ~isempty(slice_markers)
                    for i=1:length(slice_markers)
                        coords=[slice_markers{i}.x , slice_markers{i}.y];
                        obj.StartBrush(coords);
                        obj.ApplyBrush(coords);
                        %                         obj.CorrectFissurePlane(coords);
                    end
                end
                
                new_lobe_overlay_image = obj.ViewerPanel.OverlayImage.RawImage;
                SE=[0 1 0;1 1 1;0 1 0];
                lobe1_overlay_image = zeros(size(new_lobe_overlay_image));
                lobe2_overlay_image = zeros(size(new_lobe_overlay_image));
                
                lobe1_overlay_image(new_lobe_overlay_image == obj.ClosestColour)=1;
                lobe2_overlay_image(new_lobe_overlay_image == obj.SecondClosestColour)=1;
                
                lobe1_overlay_image = double(obj.ClosestColour).*imdilate(lobe1_overlay_image,SE);
                lobe2_overlay_image = double(obj.SecondClosestColour).*imdilate(lobe2_overlay_image,SE);
                dt_lobe_overlay_image = lobe1_overlay_image+lobe2_overlay_image;
                
                preview_fissure_index=find(preview_fissure == obj.FissureColour);
                dt_fissure_index=find(dt_lobe_overlay_image == (obj.ClosestColour + obj.SecondClosestColour));
                preview_fissure(preview_fissure_index)=0;
                preview_fissure(dt_fissure_index)=obj.FissureColour;
                
                obj.ApplyEditToImage(preview_fissure);
                obj.Enabled = enable;
                obj.RemoveAllPoints;
                obj.RemoveAllPointsFromImage;
                obj.ViewerPanel.HideWaitCursor;
            end
        end
        
        function Enable(obj, enable)
            if enable && ~obj.EditModeInitialised
                notify(obj.ViewerPanel, 'MarkerPanelSelected');
            end
            %             if (enable && ~obj.Enabled)
            obj.ConvertMarkerImageToPoints(obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation), obj.ViewerPanel.Orientation);
            %             end
            
            %             if (~enable && obj.Enabled)
            %                 obj.RemoveAllPoints;
            %             end
            
            obj.Enabled = enable;
        end
        
        function DeleteEditLobe(obj)
            obj.RO_lobe = [];
        end
        
        function InitialiseEditMode(obj)
            obj.EditModeInitialised = true;
            obj.UndoStack.Clear;
            
            obj.FixedOuterBoundary = strcmp(obj.ViewerPanel.SubMode, PTKSubModes.FixedBoundariesEditing);
        end
        
        function StartFissureBrush(obj, coords)
            global_image_coords = round(obj.GetGlobalImageCoordinates(coords));
            local_image_coords = obj.ViewerPanel.OverlayImage.GlobalToLocalCoordinates(global_image_coords);
            [fissure_colour] = obj.GetClosestIndices2D(local_image_coords);
            
            obj.FissureColour = fissure_colour;
        end
        
        function NewSlice(obj)
            obj.NewSliceOrOrientation;
        end
        
        function NewOrientation(obj)
            obj.NewSliceOrOrientation;
        end
        
        function NewSliceOrOrientation(obj)
            if obj.Enabled
                if ~obj.LockCallback
%                     obj.RemoveAllPoints;
                    obj.ConvertMarkerImageToPoints(obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation), obj.ViewerPanel.Orientation);
                end
            end
        end
        
        function ImageChanged(obj)
            obj.MarkerPointImage.BackgroundImageChanged(obj.ViewerPanel.BackgroundImage.BlankCopy);
            obj.MarkerImageChanged;
            obj.MarkerImageHasChanged = false;
        end
        
        function OverlayImageChanged(obj)
        end
        
        
        function MarkerImageChanged(obj)
            if obj.Enabled
                if ~obj.LockCallback
                    obj.RemoveAllPoints;
                    obj.ConvertMarkerImageToPoints(obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation), obj.ViewerPanel.Orientation);
                end
            end
        end
        
        function processed = Keypressed(obj, key_name)
            processed = true;
            if strcmpi(key_name, 'l') % L
                obj.ChangeShowTextLabels(~obj.ShowTextLabels);
            elseif strcmpi(key_name, '1') % one
                obj.ChangeCurrentColour(1);
            elseif strcmpi(key_name, '2')
                obj.ChangeCurrentColour(2);
            elseif strcmpi(key_name, '3')
                obj.ChangeCurrentColour(3);
            elseif strcmpi(key_name, '4')
                obj.ChangeCurrentColour(4);
            elseif strcmpi(key_name, '5')
                obj.ChangeCurrentColour(5);
            elseif strcmpi(key_name, '6')
                obj.ChangeCurrentColour(6);
            elseif strcmpi(key_name, '7')
                obj.ChangeCurrentColour(7);
            elseif strcmpi(key_name, 'space')
                obj.GotoNearestMarker;
            elseif strcmpi(key_name, 'backspace')
                obj.DeleteHighlightedMarker;
            elseif strcmpi(key_name, 'leftarrow')
                obj.GotoPreviousMarker;
            elseif strcmpi(key_name, 'rightarrow')
                obj.GotoNextMarker;
            elseif strcmpi(key_name, 'pageup')
                obj.GotoFirstMarker;
            elseif strcmpi(key_name, 'pagedown')
                obj.GotoLastMarker;
            else
                processed = false;
            end
        end
        
        function ChangeShowTextLabels(obj, show)
            obj.ShowTextLabels = show;
            if obj.Enabled
                if obj.ShowTextLabels
                    obj.ShowAllTextLabels;
                else
                    obj.HideAllTextLabels;
                end
            end
        end
        
        function MouseDown(obj, ~)
            obj.IsDragging = false;
        end
        
        function AlertDragging(obj)
            obj.IsDragging = true;
        end
        
        function MouseHasMoved(obj, coords, last_coords)
            if obj.Enabled
                closest_marker = obj.GetMarkerForThisPoint(coords, []);
                if isempty(closest_marker)
                    obj.HighlightNone;
                else
                    obj.HighlightMarker(closest_marker);
                end
            end
        end
        
        function MouseDragged(obj, screen_coords, last_coords)
        end
        
        
        function MouseUp(obj, coords)
            if obj.Enabled
                if ~obj.IsDragging
                    closest_marker = obj.GetMarkerForThisPoint(coords, obj.CurrentColour);
                    if isempty(closest_marker)
                        current_colour = obj.CurrentColour;
                        if isempty(current_colour)
                            current_colour = obj.DefaultColour;
                        end;
                        
                        new_marker = obj.NewMarker(coords, current_colour);
                        obj.HighlightMarker(new_marker);
                    else
                        closest_marker.ChangePosition(coords);
                    end
                end
            end
        end
        function StartBrush(obj, coords)
            global_image_coords = round(obj.GetGlobalImageCoordinates(coords));
            local_image_coords = obj.ViewerPanel.OverlayImage.GlobalToLocalCoordinates(global_image_coords);
            [closest_colour, second_closest_colour] = obj.GetClosestIndices2D(local_image_coords);
            
            obj.ClosestColour = closest_colour;
            obj.SecondClosestColour = second_closest_colour;
            
        end
        
        function ApplyBrush(obj, coords)
            if (~isempty(obj.ClosestColour)) && (~isempty(obj.SecondClosestColour))
                image_size = obj.ViewerPanel.OverlayImage.ImageSize;
                voxel_size = obj.ViewerPanel.OverlayImage.VoxelSize;
                
                global_image_coords = round(obj.GetGlobalImageCoordinates(coords));
                local_image_coords = obj.ViewerPanel.OverlayImage.GlobalToLocalCoordinates(global_image_coords);
                
                closest_colour = obj.ClosestColour;
                second_closest_colour = obj.SecondClosestColour;
                [distance_2d, border_distance_2d, border_point] = obj.GetClosestIndices2DForColours(local_image_coords, closest_colour, second_closest_colour);
                
                % When the mouse is close to the region border, we apply the
                % correction at the nearest border point, as this gives a connection
                % between the selected point and the image boundary
                if obj.FixedOuterBoundary
                    if border_distance_2d < distance_2d || border_distance_2d < obj.LockToBorderDistance
                        local_image_coords = border_point;
                    end
                end
                
                gaussian_size = max(obj.BrushSize, distance_2d/2);
                gaussian_image = PTKNormalisedGaussianKernel(voxel_size, gaussian_size, obj.MinimumEditVolume);
                
                local_size = size(gaussian_image);
                
                
                halfsize = floor(local_size/2);
                min_coords = local_image_coords - halfsize;
                max_coords = local_image_coords + halfsize;
                
                min_clipping = max(0, 1 - min_coords);
                max_clipping = max(0, max_coords - image_size);
                
                midpoint = 1 + halfsize - min_clipping;
                
                min_coords = max(1, min_coords);
                max_coords = min(max_coords, image_size);
                
                raw_image = obj.ViewerPanel.OverlayImage.RawImage;
                
                cropped_image = obj.ViewerPanel.OverlayImage.Copy;
                cropped_image.Crop(min_coords, max_coords);
                subimage = cropped_image.RawImage;
                
                dt_subimage_second = cropped_image.BlankCopy;
                dt_subimage_second.ChangeRawImage(cropped_image.RawImage == second_closest_colour);
                dt_subimage_second = PTKImageUtilities.GetNonisotropicDistanceTransform(dt_subimage_second);
                
                filtered_dt = PTKGaussianFilter(dt_subimage_second, 2);
                dt_subimage_second = filtered_dt.RawImage;
                
                
                dt_value = dt_subimage_second(midpoint(1), midpoint(2), midpoint(3));
                
                brush_min_coords = 1 + min_clipping;
                brush_max_coords = size(gaussian_image) - max_clipping;
                
                
                add_mask = -dt_value*gaussian_image;
                add_mask = add_mask(brush_min_coords(1) : brush_max_coords(1), brush_min_coords(2) : brush_max_coords(2), brush_min_coords(3) : brush_max_coords(3));
                
                dt_subimage_second = dt_subimage_second + add_mask;
                
                old_subimage = cropped_image.RawImage;
                
                % Get new segmentation based on the modified distance transform
                subimage(old_subimage == closest_colour & dt_subimage_second <= 0) = second_closest_colour;
                
                % Perform a morphological opening to force disconnection of neighbouring
                % segments, which will be removed in the hole filling step
                cropped_image_copy = cropped_image.BlankCopy;
                cropped_image_copy.ChangeRawImage(subimage == closest_colour);
                cropped_image_copy.BinaryMorph(@imopen, 2);
                subimage((subimage == closest_colour) & (~cropped_image_copy.RawImage)) = second_closest_colour;
                
                % Fill holes for all colours
                subimage = PTKFillHolesForMultiColourImage(subimage, ~obj.FixedOuterBoundary);
                
                raw_image(min_coords(1):max_coords(1), min_coords(2):max_coords(2), min_coords(3):max_coords(3)) = subimage;
                
                obj.ApplyEditToImage(raw_image);
                
                
                
            end
        end
        
        function [closest, second_closest] = GetClosestIndices(obj, local_image_coords)
            distances = obj.DT(local_image_coords(1), local_image_coords(2), local_image_coords(3), :);
            [~, sorted_indices] = sort(distances, 'ascend');
            closest = sorted_indices(1);
            second_closest = sorted_indices(2);
        end
        
        function [closest_colour, second_closest_colour] = GetClosestIndices2D(obj, local_image_coords)
            orientation = obj.ViewerPanel.Orientation;
            switch orientation
                case PTKImageOrientation.Coronal
                    x_coord = local_image_coords(2);
                    y_coord = local_image_coords(3);
                case PTKImageOrientation.Sagittal
                    x_coord = local_image_coords(1);
                    y_coord = local_image_coords(3);
                case PTKImageOrientation.Axial
                    x_coord = local_image_coords(1);
                    y_coord = local_image_coords(2);
                otherwise
                    error('Unsupported dimension');
            end
            
            slice_number = obj.ViewerPanel.SliceNumber(orientation);
            image_slice = obj.ViewerPanel.OverlayImage.GetSlice(slice_number, obj.ViewerPanel.Orientation);
            
            colours = unique(image_slice);
            
            if obj.FixedOuterBoundary
                colours = setdiff(colours, 0);
            end
            
            dts = zeros([size(image_slice), numel(colours)]);
            
            for colour_index = 1 : numel(colours);
                colour = colours(colour_index);
                dts(:, :, colour_index) = bwdist(image_slice == colour);
            end
            distances = dts(x_coord, y_coord, :);
            
            [~, sorted_indices] = sort(distances, 'ascend');
            closest = sorted_indices(1);
            if length(sorted_indices)>1
                second_closest = sorted_indices(2);
            else
                second_closest = [];
            end
            
            closest_colour = colours(closest);
            second_closest_colour = colours(second_closest);
        end
        
        function [distance, border_distance, border_point] = GetClosestIndices2DForColours(obj, local_image_coords, closest_colour, second_closest_colour)
            orientation = obj.ViewerPanel.Orientation;
            switch orientation
                case PTKImageOrientation.Coronal
                    x_coord = local_image_coords(2);
                    y_coord = local_image_coords(3);
                case PTKImageOrientation.Sagittal
                    x_coord = local_image_coords(1);
                    y_coord = local_image_coords(3);
                case PTKImageOrientation.Axial
                    x_coord = local_image_coords(1);
                    y_coord = local_image_coords(2);
                otherwise
                    error('Unsupported dimension');
            end
            
            slice_number = obj.ViewerPanel.SliceNumber(orientation);
            image_slice = obj.ViewerPanel.OverlayImage.GetSlice(slice_number, obj.ViewerPanel.Orientation);
            
            dt_second_closest =  bwdist(image_slice == second_closest_colour);
            
            distance = dt_second_closest(x_coord, y_coord);
            
            [dt_border, indices] = bwdist(image_slice == 0);
            border_distance = dt_border(x_coord, y_coord);
            border_index = indices(x_coord, y_coord);
            [border_index_x, border_index_y]  = ind2sub(size(indices), double(border_index));
            
            switch orientation
                case PTKImageOrientation.Coronal
                    border_point = [slice_number, border_index_x, border_index_y];
                case PTKImageOrientation.Sagittal
                    border_point = [border_index_x, slice_number, border_index_y];
                case PTKImageOrientation.Axial
                    border_point = [border_index_x, border_index_y, slice_number];
                otherwise
                    error('Unsupported dimension');
            end
            
        end
        
        function ApplyEditToImage(obj, new_image)
            obj.OverlayChangeLock = true;
            current_image = obj.ViewerPanel.OverlayImage.RawImage;
            obj.UndoStack.Push({current_image});
            obj.ViewerPanel.OverlayImage.ChangeRawImage(new_image);
            obj.OverlayChangeLock = false;
        end
        
        function RevertEdit(obj)
            old_image = obj.UndoStack.Pop;
            if ~isempty(old_image)
                obj.OverlayChangeLock = true;
                obj.ViewerPanel.OverlayImage.ChangeRawImage(old_image);
                obj.OverlayChangeLock = false;
            end
        end
        
        function image_coords = GetImageCoordinates(obj, coords)
            image_coords = zeros(1, 3);
            i_screen = coords(2);
            j_screen = coords(1);
            k_screen = obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation);
            
            switch obj.ViewerPanel.Orientation
                case PTKImageOrientation.Coronal
                    image_coords(1) = k_screen;
                    image_coords(2) = j_screen;
                    image_coords(3) = i_screen;
                case PTKImageOrientation.Sagittal
                    image_coords(1) = j_screen;
                    image_coords(2) = k_screen;
                    image_coords(3) = i_screen;
                case PTKImageOrientation.Axial
                    image_coords(1) = i_screen;
                    image_coords(2) = j_screen;
                    image_coords(3) = k_screen;
            end
        end
        
        function global_image_coords = GetGlobalImageCoordinates(obj, coords)
            local_image_coords = obj.GetImageCoordinates(coords);
            global_image_coords = obj.MarkerPointImage.LocalToGlobalCoordinates(local_image_coords);
        end
        
        function RemoveAllPointsFromImage(obj)
            obj.MarkerPointImage.RemoveAllCorrectPoints;
        end
        
        function RemoveThisMarker(obj, marker)
            for index = 1: length(obj.MarkerPoints)
                indexed_marker = obj.MarkerPoints(index);
                if indexed_marker == marker
                    if (marker == obj.CurrentlyHighlightedMarker)
                        obj.CurrentlyHighlightedMarker = [];
                    end
                    obj.MarkerPoints(index) = [];
                    return;
                end
            end
        end
        
        function ChangeCurrentColour(obj, new_colour)
            obj.CurrentColour = new_colour;
        end
        
        function AddPointToMarkerImage(obj, marker_position, colour)
            obj.LockCallback = true;
            coords = obj.GetImageCoordinates(marker_position);
            
            if obj.MarkerPointImage.ChangeMarkerPoint(coords, colour)
                obj.MarkerImageHasChanged = true;
            end
            
            obj.LockCallback = false;
        end
        
        function MarkerPointsHaveBeenSaved(obj)
            obj.MarkerImageHasChanged = false;
        end
        
        function marker_image = GetMarkerImage(obj)
            marker_image = obj.MarkerPointImage.GetMarkerImage;
        end
        
        function [slice_markers] = GetCorrectPoints(obj)
            if obj.MarkerPointImage.MarkerImageExists
                obj.Orientation = obj.ViewerPanel.Orientation;
                obj.SliceNumber = obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation);
                
                [slice_markers, slice_size] = obj.MarkerPointImage.GetMarkersFromImage(obj.SliceNumber, obj.Orientation);
            else slice_markers = [];
            end
        end
        
    end
    
    methods (Access = private)
        function ConvertMarkerImageToPoints(obj, slice_number, dimension)
            if obj.MarkerPointImage.MarkerImageExists
                obj.Orientation = dimension;
                obj.SliceNumber = slice_number;
                
                [slice_markers, slice_size] = obj.MarkerPointImage.GetMarkersFromImage(slice_number, dimension);
                
                obj.CoordinateLimits = slice_size;
                
                for marker_s = slice_markers
                    marker = marker_s{1};
                    obj.NewMarker([marker.x, marker.y], marker.colour);
                end
            end
        end
        
        function [new_marker,coords] = NewMarker(obj, coords, colour)
            axes = obj.Callback.GetAxesHandle;
            new_marker = MYCorrectPoint(coords, axes, colour, obj, obj.CoordinateLimits);
            
            if isempty(obj.MarkerPoints)
                obj.MarkerPoints = new_marker;
            else
                obj.MarkerPoints(end+1) = new_marker;
            end
            
            %             if (obj.ShowTextLabels)
            %                 new_marker.AddTextLabel;
            %             end
        end
        
        function ShowAllTextLabels(obj)
            for marker = obj.MarkerPoints
                marker.AddTextLabel;
            end
        end
        
        function HideAllTextLabels(obj)
            for marker = obj.MarkerPoints
                marker.RemoveTextLabel;
            end
        end
        
        function HighlightNone(obj)
            if ~isempty(obj.CurrentlyHighlightedMarker)
                obj.CurrentlyHighlightedMarker.HighlightOff;
                obj.CurrentlyHighlightedMarker = [];
            end
        end
        
        function HighlightMarker(obj, marker)
            if isempty(obj.CurrentlyHighlightedMarker) || (obj.CurrentlyHighlightedMarker ~= marker)
                obj.HighlightNone;
                marker.Highlight;
                obj.CurrentlyHighlightedMarker = marker;
            end
        end
        
        function closest_marker = GetMarkerForThisPoint(obj, coords, desired_colour)
            [closest_marker, closest_distance] = obj.GetNearestMarker(coords, desired_colour);
            if closest_distance > obj.ClosestDistanceForReplaceMarker
                closest_marker = [];
            end
        end
        
        function [closest_point, closest_distance] = GetNearestMarker(obj, coords, desired_colour)
            closest_point = [];
            closest_distance = [];
            for marker = obj.MarkerPoints
                if isempty(desired_colour) || (desired_colour == marker.Colour)
                    point_position = marker.GetPosition;
                    distance = sum(abs(coords - point_position)); % Cityblock distance
                    if isempty(closest_distance) || (distance < closest_distance)
                        closest_distance = distance;
                        closest_point = marker;
                    end
                end
            end
        end
        
        function RemoveAllPoints(obj)
            obj.CurrentlyHighlightedMarker = [];
            for marker = obj.MarkerPoints
                marker.RemoveGraphic;
            end
            obj.MarkerPoints = [];
        end
        
        % Find the image slice containing the last marker
        function GotoPreviousMarker(obj)
            maximum_skip = obj.ViewerPanel.SliceSkip;
            orientation = obj.ViewerPanel.Orientation;
            current_coordinate = obj.ViewerPanel.SliceNumber(orientation);
            index_of_nearest_marker = obj.MarkerPointImage.GetIndexOfPreviousMarker(current_coordinate, maximum_skip, orientation);
            obj.ViewerPanel.SliceNumber(orientation) = index_of_nearest_marker;
        end
        
        function GotoNextMarker(obj)
            maximum_skip = obj.ViewerPanel.SliceSkip;
            orientation = obj.ViewerPanel.Orientation;
            current_coordinate = obj.ViewerPanel.SliceNumber(orientation);
            index_of_nearest_marker =  obj.MarkerPointImage.GetIndexOfNextMarker(current_coordinate, maximum_skip, orientation);
            obj.ViewerPanel.SliceNumber(orientation) = index_of_nearest_marker;
        end
        
        function GotoNearestMarker(obj)
            orientation = obj.ViewerPanel.Orientation;
            current_coordinate = obj.ViewerPanel.SliceNumber(orientation);
            index_of_nearest_marker = obj.MarkerPointImage.GetIndexOfNearestMarker(current_coordinate, orientation);
            obj.ViewerPanel.SliceNumber(orientation) = index_of_nearest_marker;
        end
        
        function GotoFirstMarker(obj)
            orientation = obj.ViewerPanel.Orientation;
            index_of_nearest_marker = obj.MarkerPointImage.GetIndexOfFirstMarker(orientation);
            obj.ViewerPanel.SliceNumber(orientation) = index_of_nearest_marker;
        end
        
        function GotoLastMarker(obj)
            orientation = obj.ViewerPanel.Orientation;
            index_of_nearest_marker = obj.MarkerPointImage.GetIndexOfLastMarker(orientation);
            obj.ViewerPanel.SliceNumber(orientation) = index_of_nearest_marker;
        end
        
        function DeleteHighlightedMarker(obj)
            if ~isempty(obj.CurrentlyHighlightedMarker)
                obj.CurrentlyHighlightedMarker.DeleteMarker;
            end
        end
        
    end
end

