function results_right = MYGetResultsForRightLobe(lung_template, lung_mask, fissure_plane, reporting)

lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == 1));

lung_mask.ResizeToMatch(lung_template);
fissure_plane.ResizeToMatch(lung_template);
fissure_plane_o = find(fissure_plane.RawImage(:) == 3);

results_right = PTKDivideVolumeUsingScatteredPoints(lung_mask, fissure_plane_o, 5, reporting);
results_right.ChangeColourIndex(2, 4);

% Mid lobe
fissure_plane_m = find(fissure_plane.RawImage(:) == 2);

if ~isempty(fissure_plane_m)
    lung_mask_excluding_lower = lung_mask.Copy;
    lung_mask_excluding_lower.ChangeRawImage(results_right.RawImage == 1);
    
    results_mid_right = PTKDivideVolumeUsingScatteredPoints(lung_mask_excluding_lower, fissure_plane_m, 20, reporting);
    results_right.ChangeSubImageWithMask(results_mid_right, results_mid_right);
else
    reporting.ShowWarning('PTKLobesFromFissurePlane:NoRightObliqueFissure', 'Unable to find the right horizontal fissure. No middle right lobe segmentation will be shown.', []);
end