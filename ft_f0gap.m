function f0gap = ft_f0gap(f0, dt, t_onset, t_break)
    %%
    f0gap = [];
    
    if ~isempty(t_break)
        t = (0:numel(f0)).*dt;
        
        [~, idx_ed] = min(abs(t - t_break(1)));
        [~, idx_st] = min(abs(t - t_onset(1)));
        
        f0_i = f0(idx_st:idx_ed);
        idx_f0_i_st = find(f0_i ~= 0, 1, 'first');
        idx_f0_i_ed = find(f0_i ~= 0, 1, 'last');
        
        f0gap(1) = f0_i(idx_f0_i_st) - f0_i(idx_f0_i_ed);
        
        for i=2:numel(t_break)
            [~, idx_ed] = min(abs(t - t_break(i)));
            idx = find(t_onset > t_break(i - 1), 1, 'first');
            [~, idx_st] = min(abs(t - t_onset(idx)));
            
            f0_i = f0(idx_st:idx_ed);
            idx_f0_i_st = find(f0_i ~= 0, 1, 'first');
            idx_f0_i_ed = find(f0_i ~= 0, 1, 'last');

            f0gap(end + 1) = f0_i(idx_f0_i_st) - f0_i(idx_f0_i_ed);
        end
    end
end