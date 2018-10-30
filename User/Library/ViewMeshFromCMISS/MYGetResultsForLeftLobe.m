function left_results = MYGetResultsForLeftLobe(lung_mask, fissure_plane, reporting)

lung_mask.ChangeRawImage(uint8(lung_mask.RawImage == 2));

% lung_mask.ResizeToMatch(lung_template);


% fissure_plane.ResizeToMatch(lung_template);
fissure_plane = find(fissure_plane.RawImage(:) == 4);

left_results = PTKDivideVolumeUsingScatteredPoints(lung_mask, fissure_plane, 5, reporting);
left_results.ChangeColourIndex(1, 5);
left_results.ChangeColourIndex(2, 6);