function results =  MYGetResultsForMaximumObliqueFissure(fissure_approximation, fissureness_roi, lung_roi, left_and_right_lungs, lung_colour, fissure_colour, lung_name, reporting)

lung_mask = left_and_right_lungs.Copy;
lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == lung_colour));

fissure_approximation = fissure_approximation.Copy;
fissure_approximation.ResizeToMatch(lung_roi);
lung_mask.ResizeToMatch(lung_roi);

[max_fissure_indices, ref_image] = PTKGetMaxFissurePoints(fissure_approximation.RawImage == fissure_colour, lung_mask, fissureness_roi, lung_roi, lung_roi.ImageSize);

if isempty(max_fissure_indices)
    reporting.ShowWarning('PTKMaximumFissurePointsOblique:FissurePointsNotFound', ['The oblique fissure could not be found in the ' lung_name ' lung']);
end

results = lung_roi.BlankCopy;
results.ChangeRawImage(ref_image);
