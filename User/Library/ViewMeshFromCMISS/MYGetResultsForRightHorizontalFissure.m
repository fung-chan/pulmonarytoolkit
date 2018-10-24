function right_results = MYGetResultsForRightHorizontalFissure(max_fissure_points, lung_mask, right_lung_roi, reporting)
max_fissure_points.ResizeToMatch(right_lung_roi);
lung_mask.ResizeToMatch(right_lung_roi);

max_fissure_points_m = find(max_fissure_points.RawImage(:) == 8);

if isempty(max_fissure_points_m)
    reporting.ShowWarning('PTKFissurePlane:NoRightHoritontalFissure', 'Unable to find the right horizontal fissure', []);
end

if ~isempty(max_fissure_points_m)
    [~, fissure_plane] = PTKSeparateIntoLobesWithVariableExtrapolation(max_fissure_points_m, lung_mask, right_lung_roi.ImageSize, 20, reporting);
    fissure_plane(lung_mask.RawImage == 0) = 0;
    fissures_right = 2*uint8(fissure_plane == 3);
else
    right_results = [];
    return;
end

right_results = right_lung_roi.BlankCopy;
right_results.ChangeRawImage(fissures_right);