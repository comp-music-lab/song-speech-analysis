function SC_vad = ft_spectralcentroid(audiofilepath)
    [s, fs] = audioread(audiofilepath);
    
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    N = round(fs*0.032);
    M = round(fs*0.010);
    w = hann(N, 'periodic');
    
    SC = spectralCentroid(s, fs, 'Window', w, 'OverlapLength', N - M + 1);
    
    VAD = voiceActivityDetector('FFTLength', N);
    idx_st = 1;
    idx_ed = idx_st + N - 1;
    L = numel(s);
    p = [];
    
    while idx_ed <= L
        p(end + 1) = VAD(s(idx_st:idx_ed));
        idx_st = idx_st + M - 1;
        idx_ed = idx_st + N - 1;
    end
    
    idx = p > 0.9;
    SC_vad = SC(idx);
end