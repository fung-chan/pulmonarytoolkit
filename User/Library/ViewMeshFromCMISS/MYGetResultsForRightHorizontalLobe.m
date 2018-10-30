function results_right = MYGetResultsForRightHorizontalLobe(lung_mask, fissure_plane, reporting)

lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == 1));

fissure_plane_o = find(fissure_plane.RawImage(:) == 3);

results_right = PTKDivideVolumeUsingScatteredPoints(lung_mask, fissure_plane_o, 5, reporting);
results_right.ChangeColourIndex(2, 4);

% Mid lobe
fissure_plane_m = find(fissure_plane.RawImage(:) == 2);

if ~isempty(fissure_plane_m)
    lung_mask_excluding_lower = lung_mask.Copy;
    lung_mask_excluding_lower.ChangeRawImage(results_right.RawImage == 1);
    
%     [~, fissure_plane] = PTKSeparateIntoLobesWithVariableExtrapolation(fissure_plane_m, results_right, lung_mask.ImageSize, 20, reporting);
%     fissure_plane_m = find(fissure_plane == 3);
    
    results_right = MYRHCorrectDivideVolumeUsingScatteredPoints(lung_mask_excluding_lower, fissure_plane_m, 20, reporting);
else
    reporting.ShowWarning('PTKLobesFromFissurePlane:NoRightObliqueFissure', 'Unable to find the right horizontal fissure. No middle right lobe segmentation will be shown.', []);
end
