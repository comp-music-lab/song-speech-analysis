function SC_vad = ft_spectralcentroid(audiofilepath, f0, t_f0)
    %%
    [s, fs] = audioread(audiofilepath);
    
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    %%
    N = round(fs*0.032);
    M = round(fs*0.010);
    w = hann(N, 'periodic');
    
    SC = spectralCentroid(s, fs, 'Window', w, 'OverlapLength', N - M + 1, 'SpectrumType', 'power');
    
    %%
    voice_active = zeros(numel(SC), 1);
    idx_st = 1;
    for i=1:numel(SC)
        idx_ed = idx_st + N - 1;

        [~, idx_st_f0] = min(abs(t_f0 - idx_st/fs));
        [~, idx_ed_f0] = min(abs(t_f0 - idx_ed/fs));
        if all(f0(idx_st_f0:idx_ed_f0) ~= 0)
            voice_active(i) = 1;
        end

        idx_st = idx_st + M - 1;
    end

    SC_vad = SC(voice_active == 1);
end