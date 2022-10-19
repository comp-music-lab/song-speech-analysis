function SF = ft_spectralflatness(audiofilepath, t_onset, t_break, duration)
    %%
    [s, fs] = audioread(audiofilepath);
    
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    t = (0:(numel(s) - 1))./fs;
    idx = find(t <= duration, 1, 'last');
    s = s(1:idx);

    %%
    [~, ~, t_st, t_ed] = helper.h_ioi(t_onset, t_break);
    SF = zeros(numel(t_st), 1);

    for i=1:numel(t_st)
        [~, idx_st] = min(abs(t - t_st(i)));
        [~, idx_ed] = min(abs(t - t_ed(i)));
        
        P = abs(fft(s(idx_st:idx_ed))).^2;

        Gm = exp(mean(log(P)));
        Am = mean(P);
        SF(i) = Gm/Am;
    end
end