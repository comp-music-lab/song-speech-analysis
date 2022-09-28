function pr = ft_pitchrange(t_onset, t_break, f0, t_f0)
    if isempty(t_onset)
        pr = NaN;
        return
    end
    
    reffreq = 440;
    f0 = 1200.*log2(f0./reffreq);

    if isempty(t_break)
        [~, idx_st] = min(abs(t_f0 - t_onset(1)));
        idx_ed = numel(f0);
        f0_i = f0(idx_st:idx_ed);
        f0_i = f0_i(~isinf(f0_i));

        pr = quantile(f0_i, 0.95) - quantile(f0_i, 0.05);
    else
        [~, idx_st] = min(abs(t_f0 - t_onset(1)));
        [~, idx_ed] = min(abs(t_f0 - t_break(1)));
        f0_i = f0(idx_st:idx_ed);
        f0_i = f0_i(~isinf(f0_i));

        pr = quantile(f0_i, 0.95) - quantile(f0_i, 0.05);
        
        for i=2:numel(t_break)
            idx = find(t_onset > t_break(i - 1), 1, 'first');

            [~, idx_st] = min(abs(t_f0 - t_onset(idx)));
            [~, idx_ed] = min(abs(t_f0 - t_break(i)));
            f0_i = f0(idx_st:idx_ed);
            f0_i = f0_i(~isinf(f0_i));

            pr(end + 1) = quantile(f0_i, 0.95) - quantile(f0_i, 0.05);
        end
    end
end