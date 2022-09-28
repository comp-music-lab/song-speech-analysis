function fig_script
    %%
    addpath('./lib/two-sample/');
    
    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.wav';
    f0_song = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc_f0.csv';
    onset_song = './data/Stage 1 RR Full/Florence/onset_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';
    onset_speech = './data/Stage 1 RR Full/Florence/onset_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.csv';
    break_song = './data/Stage 1 RR Full/Florence/break_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';
    break_speech = './data/Stage 1 RR Full/Florence/break_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.csv';
    h_spectrogramplot(audio_song, audio_speech, f0_song, f0_speech, onset_song, onset_speech, break_song, break_speech);

    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.wav';
    h_plotsoundwave(audio_song, audio_speech);

    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc.wav';
    h_plotsoundwave(audio_song, audio_speech);
    
    %%
    f0_song = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc_f0.csv';
    h_plotf0(f0_song, f0_speech);
    
    %%
    f0_song = './data/Stage 1 RR Full/Shafagh/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Shafagh/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc_f0.csv';
    h_plotf0(f0_song, f0_speech);
end

function h_spectrogramplot(audio_song, audio_speech, f0_song, f0_speech, onset_song, onset_speech, break_song, break_speech)
    %%
    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;

    T = readtable(f0_speech);
    t_f0_speech = T.time;
    f0_speech = T.voice_1;
    
    %%
    T = readtable(onset_song);
    t_onset_song = T.Var1;

    T = readtable(onset_speech);
    t_onset_speech = T.Var1;

    T = readtable(break_song);
    t_break_song = T.Var1;

    T = readtable(break_speech);
    t_break_speech = T.Var1;

    %%
    [s_song, fs_song] = audioread(audio_song);
    [s_speech, fs_speech] = audioread(audio_speech);

    [S, F_song, T_song] = spectrogram(s_song, hann(2048), 2048*3/4, 2048, fs_song);
    P_song = 10.*log10(abs(S).^2) - 100;    
    [S, F_speech, T_speech] = spectrogram(s_speech, hann(2048), 2048*3/4, 2048, fs_speech);
    P_speech = 10.*log10(abs(S).^2) - 100;
    
    %%
    N = round(fs_song*0.032);
    M = round(fs_song*0.010);
    w = hann(N, 'periodic');

    SC_song = spectralCentroid(s_song, fs_song, 'Window', w, 'OverlapLength', N - M + 1, 'SpectrumType', 'power');
    t_SC_song = ((1:(M - 1):(numel(s_song) - N)) + N/2)./fs_song;
    SC_speech = spectralCentroid(s_speech, fs_speech, 'Window', w, 'OverlapLength', N - M + 1, 'SpectrumType', 'power');
    t_SC_speech = ((1:(M - 1):(numel(s_speech) - N)) + N/2)./fs_speech;

    %%
    fobj = figure;
    fobj.Position = [50, 420, 920, 570];
    xl = [0.2, 9.35];
    yl = [60, 8000];
    axFontSize = 12;

    subplot(2, 1, 1);
    % Spectrogram
    surf(T_song, F_song, P_song, 'EdgeColor', 'none');
    view(0, 90);
    axis tight;
    hold on

    % F0 contour
    scatter(t_f0_song, f0_song, 'MarkerEdgeColor', 'r', 'Marker', '.');

    % Spectral centroid
    plot(t_SC_song, SC_song, 'Color', 'g', 'LineWidth', 1.3, 'LineStyle', '--');
    
    % Onset and break annotations
    for i=1:numel(t_onset_song)
        plot(t_onset_song(i).*[1, 1], yl, 'Color', '#FF00FF', 'LineWidth', 1.2);
    end
    for i=1:numel(t_break_song)
        plot(t_break_song(i).*[1, 1], yl, 'Color', '#0000CD', 'LineWidth', 1.2, 'LineStyle', '-.');
    end

    % F0 slope
    [~, idx_st] = min(abs(t_f0_song - t_onset_song(1)));
    [~, idx_ed] = min(abs(t_f0_song - t_break_song(1)));
    f0_i = 1200.*log2(f0_song(idx_st:idx_ed)./440);
    t_f0_i = t_f0_song(idx_st:idx_ed);

    idx = ~isinf(f0_i);
    f0_idx = f0_i(idx);
    t_f0_idx = t_f0_i(idx);

    mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
    R = mdl.Coefficients.Estimate;
    plot(t_f0_i, 440.*(2.^((R(1) + R(2).*t_f0_i)./1200)), '-k', 'LineWidth', 1.2);
    
    for i=2:numel(t_break_song)
        idx = find(t_onset_song > t_break_song(i - 1), 1, 'first');

        [~, idx_st] = min(abs(t_f0_song - t_onset_song(idx)));
        [~, idx_ed] = min(abs(t_f0_song - t_break_song(i)));
        f0_i = 1200.*log2(f0_song(idx_st:idx_ed)./440);
        t_f0_i = t_f0_song(idx_st:idx_ed);

        idx = ~isinf(f0_i);
        f0_idx = f0_i(idx);
        t_f0_idx = t_f0_i(idx);

        mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
        R = mdl.Coefficients.Estimate;
        plot(t_f0_i, 440.*(2.^((R(1) + R(2).*t_f0_i)./1200)), '-k', 'LineWidth', 1.2);
    end
    
    %%{
    h = zeros(5, 1);
    h(1) = plot(NaN, NaN, 'Color', '#FF0000', 'LineWidth', 1.2);
    h(2) = plot(NaN, NaN, 'Color', '#FF00FF', 'LineWidth', 1.2);
    h(3) = plot(NaN, NaN, 'Color', '#0000CD', 'LineStyle', '-.', 'LineWidth', 1.2);
    h(4) = plot(NaN, NaN, 'Color', '#00FF00', 'LineStyle', '--', 'LineWidth', 1.2);
    h(5) = plot(NaN, NaN, 'Color', '#000000', 'LineWidth', 1.2);
    legend(h, {'f_0', 'Onset', 'Break', 'Spectral centroid', 'f_0 slope'}, 'FontName', 'Times New Roman', 'FontSize', 12);
    %}

    hold off
    xlim(xl);
    ylim(yl);
    set(gca, 'YScale', 'log');
    ax = gca(fobj);
    ax.FontSize = axFontSize;
    ylabel('Frequency (Hz)', 'FontSize', 13);
    
    subplot(2, 1, 2);
    %Spectrogram
    surf(T_speech, F_speech, P_speech, 'EdgeColor', 'none');
    view(0, 90);
    axis tight;
    hold on

    % F0 contour
    scatter(t_f0_speech, f0_speech, 'MarkerEdgeColor', 'r', 'Marker', '.');

    % Spectral centroid
    plot(t_SC_speech, SC_speech, 'Color', 'g', 'LineWidth', 1.3, 'LineStyle', '--');
    
    % Onset and break annotations
    for i=1:numel(t_onset_speech)
        plot(t_onset_speech(i).*[1, 1], yl, 'Color', '#FF00FF', 'LineWidth', 1.2);
    end
    for i=1:numel(t_break_speech)
        plot(t_break_speech(i).*[1, 1], yl, 'Color', '#0000CD', 'LineWidth', 1.2, 'LineStyle', '-.');
    end

    % F0 slope
    [~, idx_st] = min(abs(t_f0_speech - t_onset_speech(1)));
    [~, idx_ed] = min(abs(t_f0_speech - t_break_speech(1)));
    f0_i = 1200.*log2(f0_speech(idx_st:idx_ed)./440);
    t_f0_i = t_f0_speech(idx_st:idx_ed);

    idx = ~isinf(f0_i);
    f0_idx = f0_i(idx);
    t_f0_idx = t_f0_i(idx);

    mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
    R = mdl.Coefficients.Estimate;
    plot(t_f0_i, 440.*(2.^((R(1) + R(2).*t_f0_i)./1200)), '-k', 'LineWidth', 1.2);
    
    for i=2:numel(t_break_speech)
        idx = find(t_onset_speech > t_break_speech(i - 1), 1, 'first');

        [~, idx_st] = min(abs(t_f0_speech - t_onset_speech(idx)));
        [~, idx_ed] = min(abs(t_f0_speech - t_break_speech(i)));
        f0_i = 1200.*log2(f0_speech(idx_st:idx_ed)./440);
        t_f0_i = t_f0_speech(idx_st:idx_ed);

        idx = ~isinf(f0_i);
        f0_idx = f0_i(idx);
        t_f0_idx = t_f0_i(idx);

        mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
        R = mdl.Coefficients.Estimate;
        plot(t_f0_i, 440.*(2.^((R(1) + R(2).*t_f0_i)./1200)), '-k', 'LineWidth', 1.2);
    end

    hold off
    xlim(xl);
    ylim(yl);
    set(gca, 'YScale', 'log');
    ax = gca(fobj);
    ax.FontSize = axFontSize;

    ylabel('Frequency (Hz)', 'FontSize', 13);
    xlabel('Time (sec.)', 'FontSize', 13);
end

function h_plotsoundwave(audio_song, audio_speech)
    [s_song, fs_song] = audioread(audio_song);
    [s_speech, fs_speech] = audioread(audio_speech);

    t_s_song = (0:(numel(s_song) - 1))./fs_song;
    t_s_speech = (0:(numel(s_speech) - 1))./fs_speech;
    
    fobj = figure;

    subplot(2, 1, 1);
    plot(t_s_song, s_song, 'Color', '#0072BD');
    ax = gca(fobj);
    ax.FontSize = 14;

    subplot(2, 1, 2);
    plot(t_s_speech, s_speech, 'Color', '#D95319');
    ax = gca(fobj);
    ax.FontSize = 14;
end

function h_plotf0(f0_song, f0_speech)
    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;

    T = readtable(f0_speech);
    t_f0_speech = T.time;
    f0_speech = T.voice_1;
    
    fobj = figure;

    subplot(2, 1, 1);
    scatter(t_f0_song, f0_song, 'Marker', '.', 'MarkerEdgeColor', '#0072BD');
    ylim([80, 450]);
    ax = gca(fobj);
    ax.FontSize = 14;
    %title('Fundamental frequency (f0)', 'FontSize', 16);

    subplot(2, 1, 2);
    scatter(t_f0_speech, f0_speech, 'Marker', '.', 'MarkerEdgeColor', '#D95319');
    ylim([80, 450]);
    ax = gca(fobj);
    ax.FontSize = 14;

    h_histogram(f0_song(f0_song ~= 0), f0_speech(f0_speech ~= 0));
end

function h_histogram(X, Y)
    [d, tau] = pb_effectsize(X, Y);
    d_Cohen = sqrt(2)*norminv(d, 0, 1);

    fobj = figure;

    histogram(X, 40, 'EdgeColor', 'none', 'FaceColor', '#0072BD', 'Normalization', 'pdf');
    hold on
    histogram(Y, 40, 'EdgeColor', 'none', 'FaceColor', '#D95319', 'Normalization', 'pdf');
    hold off

    ax = gca(fobj);
    ax.FontSize = 14;

    fprintf('%3.3f (%3.6f) (%3.3f)\n', d, tau, d_Cohen);
end