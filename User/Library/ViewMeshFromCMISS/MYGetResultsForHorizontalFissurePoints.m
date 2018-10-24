function results_right_mid = MYGetResultsForHorizontalFissurePoints(oblique_fissures, fissure_approximation, fissureness, right_lung_roi)
fissureness.ResizeToMatch(right_lung_roi);
oblique_fissures.ResizeToMatch(right_lung_roi);
fissure_approximation.ResizeToMatch(right_lung_roi);

R_fissure = oblique_fissures.RawImage == 3;
R_fissure_dt = bwdist(R_fissure).*max(right_lung_roi.VoxelSize);

supressor_distance_thresholded = max(0, R_fissure_dt)/10;
supressor = min(1, supressor_distance_thresholded.^2);

RM_fissure = fissure_approximation.RawImage == 3;

RM_fissure_dt = bwdist(RM_fissure).*max(right_lung_roi.VoxelSize);
distance_thresholded_M = max(0, RM_fissure_dt - 15)/30;
multiplier_M = max(0, 1 - distance_thresholded_M.^2);
multiplier_M = multiplier_M.*single(~R_fissure);

% The suppressor is a term that dampens fissureness near the *other*
% fissure, while the multiplier dampens fissureness far away from
% the fissure we are looking for

fissureness_M = fissureness.RawImage.*multiplier_M.*supressor;

results_right_mid = right_lung_roi.BlankCopy;
results_right_mid.ChangeRawImage(fissureness_M);