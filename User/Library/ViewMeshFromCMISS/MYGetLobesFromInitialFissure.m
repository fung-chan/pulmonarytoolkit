function results_lobes=MYGetLobesFromInitialFissure(dataset,DicomDataset,MYfissure_approximation)

%% Input:
%% dataset: initial PTKDataset formate raw data
%% MYfissure_approximation: my initial fissure approximation convert from CMISS
reporting=PTKReportingDefault;
fissureness = dataset.GetResult('PTKFissureness'); %% Get fissureness probability for each voxel
[start_crop,end_crop]=MYGetLungROIForCT(DicomDataset); %% Get the crop size
MYfissure_approximationRawImage=MYfissure_approximation.RawImage;
MYfissure_approximationRawImage=MYfissure_approximationRawImage(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3));
MYfissure_approximation.ChangeRawImage(MYfissure_approximationRawImage);

%% Get some oblique fissure points from the initial guessing
%% Use the codes from PTKFissurenessROIOblique
%% Saved in results_oblique_fissure_points
left_and_right_lungs = dataset.GetResult('PTKLeftAndRightLungs');

results_left_fissure= MYGetResultsForObliqueFissurePoints(MYfissure_approximation.Copy, dataset.GetResult('PTKGetLeftLungROI'), fissureness.Copy, 1, []);
results_right_fissure= MYGetResultsForObliqueFissurePoints(MYfissure_approximation.Copy, dataset.GetResult('PTKGetRightLungROI'), fissureness.Copy, 2, 3);
results_oblique_fissure_points = [];
results_oblique_fissure_points.LeftMainFissure = results_left_fissure;
results_oblique_fissure_points.RightMainFissure = results_right_fissure;
results_oblique_fissure_points.LeftAndRightLungs = left_and_right_lungs;

%% Get the maxmum oblique fissureness points
%% Use the codes from PTKMaximumFissurePointsOblique
%% Saved in results_oblique_fissure_maximum
results_left_oblique_maximum = MYGetResultsForMaximumObliqueFissure(MYfissure_approximation.Copy, results_oblique_fissure_points.LeftMainFissure.Copy, dataset.GetResult('PTKGetLeftLungROI'), left_and_right_lungs.Copy, 2, 1, 'left', reporting);
results_right_oblique_maximum = MYGetResultsForMaximumObliqueFissure(MYfissure_approximation.Copy, results_oblique_fissure_points.RightMainFissure.Copy, dataset.GetResult('PTKGetRightLungROI'), left_and_right_lungs.Copy, 1, 2, 'right', reporting);
results_oblique_fissure_maximum = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), results_left_oblique_maximum, results_right_oblique_maximum, left_and_right_lungs);
results_oblique_fissure_maximum.ImageType = PTKImageType.Colormap;

%% Get left and right oblique fissure lines
%% Use the codes from PTKFissurePlaneOblique
%% Saved in results_oblique_fissure
results_left_oblique_fissure = MYGetResultsForLeftObliqueFissure(results_oblique_fissure_maximum.Copy, dataset.GetResult('PTKGetLeftLungROI'), left_and_right_lungs.Copy, reporting);
results_right_oblique_fissure = MYGetResultsForRightObliqueFissure(results_oblique_fissure_maximum.Copy, dataset.GetResult('PTKGetRightLungROI'), left_and_right_lungs.Copy, reporting);
results_oblique_fissure = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), results_left_oblique_fissure, results_right_oblique_fissure, left_and_right_lungs);
results_oblique_fissure.ImageType = PTKImageType.Colormap;

%% Get some horizontal fissure points from the initial guessing
%% Use the codes from PTKFissurenessROIHorizontal
%% Saved in results_horizontal_fissure_points
results_horizontal_fissure_points1 = MYGetResultsForHorizontalFissurePoints(results_oblique_fissure.Copy, MYfissure_approximation.Copy, fissureness.Copy, dataset.GetResult('PTKGetRightLungROI'));
results_horizontal_fissure_points = [];
results_horizontal_fissure_points.RightMidFissure = results_horizontal_fissure_points1;

%% Get the horizontal fissureness points
%% Use the codes from PTKMaximumFissurePointsHorizontal
%% Saved in results_horizontal_fissure_maximum
lung_mask = dataset.GetResult('PTKLobesFromFissurePlaneOblique');

results_horizontal_fissure_maximum = MYGetResultsForMaximumHorizontalFissure(MYfissure_approximation.Copy, results_horizontal_fissure_points.RightMidFissure.Copy, dataset.GetResult('PTKGetRightLungROI'), lung_mask, 1, 3, reporting);
results_horizontal_fissure_maximum.ResizeToMatch(MYfissure_approximation.Copy);
results_horizontal_fissure_maximum.ImageType = PTKImageType.Colormap;

%% Get horizontal fissure lines
%% Use the codes from PTKFissurePlaneHorizontal
%% Saved in results_horizontal_fissure
lung_mask.ChangeRawImage(lung_mask.RawImage == 1);

results_horizontal_fissure = MYGetResultsForRightHorizontalFissure(results_horizontal_fissure_maximum.Copy, lung_mask.Copy, dataset.GetResult('PTKGetRightLungROI'), reporting);
if ~isempty(results_horizontal_fissure)
    results_horizontal_fissure.ResizeToMatch(left_and_right_lungs.Copy);
else
    results_horizontal_fissure = dataset.GetResult('PTKFissurePlaneOblique');
end
results_horizontal_fissure.ImageType = PTKImageType.Colormap;

%% Combine the oblique fissure and horizontal fissure
%% Use the codes from PTKFissurePlane
%% Saved in results_fissure
results_horizontal_fissure.ResizeToMatch(results_oblique_fissure.Copy);
oblique_results_raw = results_oblique_fissure.RawImage;
oblique_results_raw(results_horizontal_fissure.RawImage == 2) = 2;
results_fissure=results_oblique_fissure.Copy;
results_fissure.ChangeRawImage(oblique_results_raw);

%% Get the lobe segmentation result from fissure detection result
%% Use the codes from PTKLobesFromFissurePlane
%% Saved in results_lobes
left_lung_template = dataset.GetTemplateImage(PTKContext.LeftLung).BlankCopy;
right_lung_template = dataset.GetTemplateImage(PTKContext.RightLung).BlankCopy;
lung_mask = dataset.GetResult('PTKLeftAndRightLungs');
results_left_lobe = MYGetResultsForLeftLobe(left_lung_template, lung_mask.Copy, results_fissure.Copy, reporting);
results_right_lobe = MYGetResultsForRightLobe(right_lung_template, lung_mask.Copy, results_fissure, reporting);
results_lobes = PTKCombineLeftAndRightImages(dataset.GetTemplateImage(PTKContext.LungROI), results_left_lobe.Copy, results_right_lobe.Copy, left_and_right_lungs);
results_lobes.ImageType = PTKImageType.Colormap;