function I = h_interval(f0_cent, t_f0, t_st, t_ed)
    %%
    I = cell(0, 0);

    %%
    for j=2:numel(t_st)
        if t_st(j) == t_ed(j - 1)
            [~, idx_st] = min(abs(t_f0 - t_st(j - 1)));
            [~, idx_ed] = min(abs(t_f0 - t_ed(j - 1)));
            f0_cent_p = f0_cent(idx_st:idx_ed);
            f0_cent_p = f0_cent_p(~isinf(f0_cent_p));

            [~, idx_st] = min(abs(t_f0 - t_st(j)));
            [~, idx_ed] = min(abs(t_f0 - t_ed(j)));
            f0_cent_f = f0_cent(idx_st:idx_ed);
            f0_cent_f = f0_cent_f(~isinf(f0_cent_f));

            I_j = f0_cent_f - f0_cent_p';

            if ~isempty(I_j)
                I{end + 1} = I_j(:);
            end
        end
    end
end