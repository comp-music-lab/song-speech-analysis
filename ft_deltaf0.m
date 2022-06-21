function df0 = ft_deltaf0(f0, dt, reffreq)
    %%
    f0 = f0(:);
    f0_cent = 1200.*log2(f0./reffreq);
    
    %%
    df0 = [];
    idx_ed = 0;
    idx_st = find(~isinf(f0_cent(idx_ed + 1:end)), 1, 'first') + idx_ed;

    while ~isempty(idx_st)
        idx_ed = find(isinf(f0_cent(idx_st:end)), 1, 'first') + idx_st - 2;
        f0_cent_i = f0_cent(idx_st:idx_ed);
        df0_j = cwtdiff(f0_cent_i, 0.02, 1/dt, 1);
        df0 = [df0; df0_j];

        idx_st = find(~isinf(f0_cent(idx_ed + 1:end)), 1, 'first') + idx_ed;
    end
end