function idx_modes = persistencemode_thresh(f, thresh)
    %% Persistence diagram
    [birth, locs, ~, p] = findpeaks(f);
	death = birth - p;

    %% Bottleneck distance
	dist = 0.5.*(birth - death);

    %% Thresholding
	re = (max(dist) - dist)./max(dist);
	idx = re < thresh;
	idx_modes = locs(idx);
end