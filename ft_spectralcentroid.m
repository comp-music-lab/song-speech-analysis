function SC_vad = ft_spectralcentroid(audiofilepath, f0, t_f0, duration, vad)
    %%
    [s, fs] = audioread(audiofilepath);
    
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    t = (0:(numel(s) - 1))./fs;
    idx = find(t <= duration, 1, 'last');
    s = s(1:idx);

    %%
    N = round(fs*0.032);
    M = round(fs*0.010);
    w = hann(N, 'periodic');
    
    SC = spectralCentroid(s, fs, 'Window', w, 'OverlapLength', N - M + 1, 'SpectrumType', 'power');
    
    %%
    if vad
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
    else
        SC_vad = SC;
    end

    SC_vad = SC_vad(~isnan(SC_vad));
end

%{
t = linspace(0, numel(s)/fs, size(centroid, 1));

figure(1);
plot(t, SC);
hold on
plot(t, voice_active);
hold off
%}