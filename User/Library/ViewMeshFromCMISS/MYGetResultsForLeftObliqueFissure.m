function results = MYGetResultsForLeftObliqueFissure(max_fissure_points, lung_roi, left_and_right_lungs, reporting)
max_fissure_points = max_fissure_points.Copy;

lung_mask = left_and_right_lungs.Copy;
lung_mask.ResizeToMatch(lung_roi);
lung_mask.ChangeRawImage(lung_mask.RawImage == 2);

max_fissure_points.ResizeToMatch(lung_roi);
max_fissure_points = find(max_fissure_points.RawImage(:) == 1);

if isempty(max_fissure_points)
    reporting.Error('PTKFissurePlane:NoLeftObliqueFissure', 'Unable to find the left oblique fissure');
end

[~, fissure_plane] = PTKSeparateIntoLobesWithVariableExtrapolation(max_fissure_points, lung_mask, lung_roi.ImageSize, 5, reporting);

results = lung_roi.BlankCopy;
results.ChangeRawImage(4*uint8(fissure_plane == 3));