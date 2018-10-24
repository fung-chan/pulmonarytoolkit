function results_right = MYGetResultsForRightObliqueLobe(lung_mask, fissure_plane, reporting)

lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == 1));

fissure_plane_o = find(fissure_plane.RawImage(:) == 3);

results_right = PTKDivideVolumeUsingScatteredPoints(lung_mask, fissure_plane_o, 5, reporting);
results_right.ChangeColourIndex(2, 4);

end
