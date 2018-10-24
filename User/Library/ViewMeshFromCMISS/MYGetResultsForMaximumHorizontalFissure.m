function results = MYGetResultsForMaximumHorizontalFissure(fissure_approximation, fissureness_roi, lung_roi, lung_mask, lung_colour, fissure_colour, reporting)
lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == lung_colour));

fissure_approximation.ResizeToMatch(lung_roi);
fissureness_roi.ResizeToMatch(lung_roi);
lung_mask.ResizeToMatch(lung_roi);
lung_mask.ResizeToMatch(lung_roi);

[max_fissure_indices, ref_image] = PTKGetMaxFissurePoints(fissure_approximation.RawImage == fissure_colour, lung_mask, fissureness_roi, lung_roi, lung_roi.ImageSize);

if isempty(max_fissure_indices)
    reporting.ShowWarning('PTKMaximumFissurePointsHorizontal:FissurePointsNotFound', ['The horizontal fissure could not be found.']);
end

ref_image(ref_image == 1) = 8;

results = lung_roi.BlankCopy;
results.ChangeRawImage(ref_image);