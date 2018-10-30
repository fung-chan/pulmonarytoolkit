clear;close;clc;
PTKAddPaths;
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP-076_BRP2-FRC22%-0.75--B31f_1768717';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
lungs=dataset.GetResult('PTKLeftAndRightLungs');
leftlungs=dataset.GetResult('PTKGetLeftLungROI');

Lung=lungs.RawImage;
[a1,b1,c1]=size(Lung);
for i=1:c1
    AxLung=Lung(:,:,i);
    level=graythresh(AxLung);
    AxLung=im2bw(AxLung,level);

    Lung(:,:,i)=imfill(AxLung,'holes');
end
LeftLungRaw=leftlungs.RawImage;
[a2,b2,c2]=size(LeftLungRaw);
LeftLung=Lung(:,1:b2,:);
RightLung=Lung(:,(b2+1):b1,:);

PTKImage
function RescaleToMaxSize(obj, max_size)
            scale = [1 1 1];
            image_size = obj.ImageSize;
            original_image_size = image_size;
            for dim_index = 1 : 3
                while image_size(dim_index) > max_size
                    scale(dim_index) = scale(dim_index) + 1;
                    image_size = floor(original_image_size./scale);
                end
            end
            
            obj.DownsampleImage(scale);
end
        
PTKImage
 function DownsampleImage(obj, scale)
            if length(scale) == 1
                scale = repmat(scale, 1, length(obj.Origin));
            end
            obj.VoxelSize = scale.*obj.VoxelSize;
            obj.Scale = scale.*obj.Scale;
            obj.RawImage = obj.RawImage(round(1:scale(1):end), round(1:scale(2):end), round(1:scale(3):end));
            obj.NotifyImageChanged;
            obj.Origin = floor(obj.Origin./scale);
 end
 
 PTKImage
 function CropToFit(obj)
            if obj.ImageExists
                
                bounds = obj.GetBounds;
                
                if isempty(bounds)
                    obj.RawImage = [];
                    obj.CheckForZeroImageSize;

                    obj.NotifyImageChanged;
                    
                else
                    
                    % Create new image
                    obj.RawImage = obj.RawImage(bounds(1):bounds(2), bounds(3):bounds(4), bounds(5):bounds(6));
                    
                    obj.Origin = obj.Origin + [bounds(1) - 1, bounds(3) - 1, bounds(5) - 1];
                    obj.NotifyImageChanged;
                end
            end
 end
        
 function lung_image = PTKGetLungROIForCT(lung_image, reporting)
    % PTKGetLungROIForCT. Finds a region of interest from a chest CT image which
    %     contains the lungs and airways
    %
    %     Inputs
    %     ------
    %
    %     lung_image - the full original lung volume stored as a PTKImage.
    %
    %     reporting (optional) - an object implementing the PTKReporting
    %         interface for reporting progress and warnings
    %
    %
    %     Outputs
    %     -------
    %
    %     lung_image - a PTKImage cropped to the lung region of interest.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    
    if ~isa(lung_image, 'PTKImage')
        reporting.Error('PTKGetLungROIForCT:InputImageNotPTKImage', 'Requires a PTKImage as input');
    end

    if nargin < 2
        reporting = PTKReportingDefault;
    end
    
    reporting.ShowProgress('Rescaling image');
    
    reduced_image = lung_image.Copy;
    
    reduced_image.RescaleToMaxSize(128);

    reporting.ShowProgress('Filtering image');
    reduced_image = PTKGaussianFilter(reduced_image, 1.0);
    
    scale_factor = reduced_image.Scale;
    reporting.ShowProgress('Finding region of interest');
    reduced_image = PTKSegmentLungsWithoutClosing(reduced_image, false, true, reporting);
    
    % Use the crop function to find the offset and image size
    original_origin = reduced_image.Origin;
    reduced_image.CropToFit;
    offset = reduced_image.Origin - original_origin;
    
    % Scale back to normal size, allowing a border
    new_size = scale_factor.*(reduced_image.ImageSize + [4 4 4]);
    start_crop = scale_factor.*(offset  - [2 2 2]);
    end_crop = start_crop + new_size;
    start_crop = max(start_crop, [1 1 1]);
    end_crop = min(end_crop, lung_image.ImageSize);
    
    reporting.ShowProgress('Cropping image');    
    lung_image = lung_image.Copy;
    lung_image.Crop(start_crop, end_crop);
    
    reporting.CompleteProgress;
end
