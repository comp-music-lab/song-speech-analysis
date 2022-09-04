function E_voiced = ft_energy(audiofilepath, t_onset, t_break)
    %%
    [x, fs] = audioread(audiofilepath);

    if size(x, 2) == 2
        x = mean(x, 2);
    end

    %%
    N_t = 0.025;
    M_t = N_t/2;
    N = round(N_t*fs);
    M = round(M_t*fs);

    t_E = (1:M:(numel(x) - N))./fs;
    E = zeros(numel(t_E), 1);
    idx_st = 1;
    for i=1:numel(t_E)
        idx_ed = idx_st + N - 1;
        E(i) = mean(x(idx_st:idx_ed).^2);
        idx_st = idx_st + M;
    end

    %%
    if isempty(t_break)
        [~, idx_st] = min(abs(t_E - t_onset(1)));
        [~, idx_ed] = numel(x);
        E_i = E(idx_st:idx_ed);
        E_voiced = E_i(E_i ~= 0);
    else
        [~, idx_st] = min(abs(t_E - t_onset(1)));
        [~, idx_ed] = min(abs(t_E - t_break(1)));
        E_i = E(idx_st:idx_ed);
        E_voiced = E_i(E_i ~= 0);
        
        for i=2:numel(t_break)
            idx = find(t_onset > t_break(i - 1), 1, 'first');

            [~, idx_st] = min(abs(t_E - t_onset(idx)));
            [~, idx_ed] = min(abs(t_E - t_break(i)));
            E_i = E(idx_st:idx_ed);
            E_i = E_i(E_i ~= 0);

            E_voiced = [E_voiced; E_i];
        end
    end
end