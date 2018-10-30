function results = MYGetResultsForObliqueFissurePoints(fissure_approximation, lung_roi, fissureness, main_fissure_colour, mid_fissure_colour)

%% This function is used to calculate the lobe segmentation result 

fissureness = fissureness.Copy;
fissureness.ResizeToMatch(lung_roi);

fissure_approximation = fissure_approximation.Copy;
fissure_approximation.ResizeToMatch(lung_roi);

fissure = fissure_approximation.RawImage == main_fissure_colour;
fissure_dt = bwdist(fissure).*max(lung_roi.VoxelSize);

distance_thresholded = max(0, fissure_dt - 20)/20;
multiplier = max(0, 1 - distance_thresholded.^2);

if isempty(mid_fissure_colour)
    fissureness = fissureness.RawImage.*multiplier;
else
    % The suppressor is a term that dampens fissureness near the *other*
    % fissure, while the multiplier dampens fissureness far away from
    % the fissure we are looking for
    RM_fissure = fissure_approximation.RawImage == mid_fissure_colour;
    RM_fissure_dt = bwdist(RM_fissure).*max(lung_roi.VoxelSize);
    supressor_distance_thresholded_M = max(0, RM_fissure_dt)/10;
    supressor_M = min(1, supressor_distance_thresholded_M.^2);
    
    fissureness = fissureness.RawImage.*multiplier.*supressor_M;
end

results = lung_roi.BlankCopy;
results.ChangeRawImage(fissureness);
end