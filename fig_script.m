function fig_script(outputdir)
    %%
    addpath('./lib/two-sample/');

    %%
    f0_song = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc_f0.csv';
    h_plotf0(f0_song, f0_speech);
    
    %%
    f0_song = './data/Stage 1 RR Full/Shafagh/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Shafagh/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc_f0.csv';
    h_plotf0(f0_song, f0_speech);

    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.wav';
    h_plotsoundwave(audio_song, audio_speech);

    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc.wav';
    h_plotsoundwave(audio_song, audio_speech);
    
    %%
    audio_song = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Song.wav';
    f0_song = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Song_f0.csv';
    onset_song = './data/Pilot data/onset_Patrick Savage_Twinkle Twinkle_Song.csv';
    break_song = './data/Pilot data/break_Patrick Savage_Twinkle Twinkle_Song.csv';
    
    h_figure4(audio_song, f0_song, onset_song, break_song, outputdir);

    %%
    audio_desc = './data/Pilot data/PES_English_Twinkle_Desc.wav';
    audio_song = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Song.wav';
    audio_recit = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Speech.wav';
    audio_inst = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Piano.wav';
    f0_desc = './data/Pilot data/PES_English_Twinkle_Desc_f0.csv';
    f0_song = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Song_f0.csv';
    f0_recit = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Speech_f0.csv';
    f0_inst = './data/Pilot data/Patrick Savage_Twinkle Twinkle_Piano_f0.csv';
    
    h_figure1(audio_desc, audio_song, audio_recit, audio_inst, f0_desc, f0_song, f0_recit, f0_inst, outputdir);

    %%
    f0_song = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song_f0.csv';
    onset_song = './data/Stage 1 RR Full/Florence/onset_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';
    break_song = './data/Stage 1 RR Full/Florence/break_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';

    h_plotinterval(f0_song, onset_song, break_song);
end

function h_figure1(audio_desc, audio_song, audio_recit, audio_inst, f0_desc, f0_song, f0_recit, f0_inst, outputdir)
    fobj = figure(1);
    clf; cla;
    fobj.Position = [1150, 630, 750, 350];
    
    audiofiles = {audio_desc, audio_song, audio_recit, audio_inst};
    f0files = {f0_desc, f0_song, f0_recit, f0_inst};

    xl = {[0.5, 1.7], [0.7, 4.5], [0.8, 2.4], [0.6, 4.55]};
    yl = {[0.03, 1], [0.03, 1], [0.03, 1], [0.1, 1.6]};
    outputfilename = {'fig1_desc.png', 'fig1_song.png', 'fig1_recit.png', 'fig1_inst.png'};

    for i=1:numel(audiofiles)
        [s, fs] = audioread(audiofiles{i});
        if size(s, 2) == 2
            s = mean(s, 2);
        end
        
        T = readtable(f0files{i});
        f0 = T.voice_1;
        t_f0 = T.time;

        [S, F, T] = spectrogram(s, hann(4096), 4096 - 128, 4096, fs);

        surf(T, F, 10.*log10(abs(S).^2) - 1000, 'EdgeColor', 'none');
        view(0, 90);
        hold on
        scatter(t_f0, f0, 'Marker', '.', 'MarkerEdgeColor', '#FF2222');
        hold off
        set(gca, 'YScale', 'log');
        xlim(xl{i});
        ylim(yl{i}.*1000);
        colorbar off
        xlabel('');
        ylabel('');
        ax = gca(fobj);
        ax.FontSize = 18;
        yticks([0.05, 0.1, 0.2, 0.4, 0.8].*1000);
        yticklabels({'50', '100', '200', '400', '800'});
        saveas(fobj, strcat(outputdir, outputfilename{i}));
    end
end

function h_plotinterval(f0_song, onset_song, break_song)
    %%
    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;
    
    %%
    T = readtable(onset_song);
    t_onset_song = table2array(T(:, 1));

    T = readtable(break_song);
    t_break_song = table2array(T(:, 1));

    %%
    fobj1 = figure(1);
    clf; cla;
    fobj1.Position = [30, 560, 340, 400];

    % f0 contour
    f0_cent = 1200.*log2(f0_song./440);
    scatter(t_f0_song, f0_cent, 'Marker', '.');
    hold on
    
    % Onset and break annotations
    yl = ylim();
    for i=1:numel(t_onset_song)
        plot(t_onset_song(i).*[1, 1], yl, 'Color', '#FF00FF', 'LineWidth', 1.2);
    end
    for i=1:numel(t_break_song)
        plot(t_break_song(i).*[1, 1], yl, 'Color', '#0000CD', 'LineWidth', 1.2, 'LineStyle', '-.');
    end
    
    % Example
    [~, idx_st] = min(abs(t_f0_song - t_onset_song(19)));
    [~, idx_ed] = min(abs(t_f0_song - t_onset_song(20)));
    scatter(t_f0_song(idx_st:idx_ed), f0_cent(idx_st:idx_ed), 'Marker', '.', 'MarkerEdgeColor', '#D95319');
    f0vec_i = f0_cent(idx_st:idx_ed);

    idx_st = idx_ed;
    [~, idx_ed] = min(abs(t_f0_song - t_onset_song(21)));
    scatter(t_f0_song(idx_st:idx_ed), f0_cent(idx_st:idx_ed), 'Marker', '.', 'MarkerEdgeColor', '#7E2F8E');
    f0vec_j = f0_cent(idx_st:idx_ed);
    
    hold off

    xlim([9.4, 10.31]);
    ylim([-1200, -200]);
    xlabel('Time (sec.)', 'FontSize', 12);
    ylabel('Frequency (cent; 440 Hz = 0)', 'FontSize', 12);
    ax = gca(fobj1);
    ax.FontSize = 10;

    intvl = f0vec_j' - f0vec_i;
    intvl = intvl(:);

    fobj2 = figure(2);
    clf; cla;
    fobj2.Position = [750, 560, 380, 400];
    histogram(intvl);
    ax = gca(fobj2);
    ax.FontSize = 10;
    xlabel('F0 ratio (cent)', 'FontSize', 12);
    ylabel('Count', 'FontSize', 12);

    fobj3 = figure(3);
    clf; cla;
    fobj3.Position = [380, 560, 220, 400];
    scatter(1:numel(f0vec_i), f0vec_i, 'Marker', '.', 'MarkerEdgeColor', '#D95319');
    ylim([-1200, -200]);
    ax = gca(fobj3);
    ax.FontSize = 10;
    xlabel('Sample', 'FontSize', 12);
    ylabel('Frequency (cent; 440 Hz = 0)', 'FontSize', 12);

    fobj4 = figure(4);
    clf; cla;
    fobj4.Position = [610, 560, 220*(t_onset_song(21) - t_onset_song(20))/(t_onset_song(20) - t_onset_song(19)), 400];
    scatter(1:numel(f0vec_j), f0vec_j, 'Marker', '.', 'MarkerEdgeColor', '#7E2F8E');
    ylim([-1200, -200]);
    ax = gca(fobj4);
    ax.FontSize = 10;
    xlabel('Sample', 'FontSize', 12);
    ylabel('Frequency (cent; 440 Hz = 0)', 'FontSize', 12);
end

function h_figure4(audio_song, f0_song, onset_song, break_song, outputdir_fig)
    %%
    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;
    
    %%
    T = readtable(onset_song);
    t_onset_song = table2array(T(:, 1));

    T = readtable(break_song);
    t_break_song = table2array(T(:, 1));

    %%
    [s_song, fs_song] = audioread(audio_song);
    s_song = mean(s_song, 2);

    [S, F_song, T_song] = spectrogram(s_song, hann(2048), 2048*3/4, 2048, fs_song);
    P_song = 10.*log10(abs(S).^2) - 100;
    
    %%
    N = round(fs_song*0.032);
    M = round(fs_song*0.010);
    w = hann(N, 'periodic');

    SC_song = spectralCentroid(s_song, fs_song, 'Window', w, 'OverlapLength', N - M + 1, 'SpectrumType', 'power');
    t_SC_song = ((1:(M - 1):(numel(s_song) - N)) + N/2)./fs_song;

    %%
    fobj = figure;
    clf; cla;
    fobj.Position = [50, 540, 770, 450];

    %% First window
    subplot(5, 1, 1:4);

    xl = [0.2, 8.6];
    yl = 1200.*log2([60, 1000]./440);
    axFontSize = 12;

    % Spectrogram
    C = 1200.*log2(F_song./440);

    surf(T_song, C, P_song, 'EdgeColor', 'none');
    view(0, 90);
    axis tight;
    hold on

    % F0 contour
    f0_C_song = 1200.*log2(f0_song./440);
    scatter(t_f0_song, f0_C_song, 'MarkerEdgeColor', 'r', 'Marker', '.');

    % Spectral centroid
    SC_C_song = 1200.*log2(SC_song./440);
    plot(t_SC_song, SC_C_song, 'Color', 'g', 'LineWidth', 1.3, 'LineStyle', '--');
    
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
    %plot(t_f0_i, 440.*(2.^((R(1) + R(2).*t_f0_i)./1200)), '-k', 'LineWidth', 1.2);
    plot(t_f0_i, R(1) + R(2).*t_f0_i, '-k', 'LineWidth', 1.2);
    
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
        plot(t_f0_i, R(1) + R(2).*t_f0_i, '-k', 'LineWidth', 1.2);
    end
    
    %%{
    h = zeros(5, 1);
    h(1) = plot(NaN, NaN, 'Color', '#FF0000', 'LineWidth', 1.2);
    h(2) = plot(NaN, NaN, 'Color', '#FF00FF', 'LineWidth', 1.2);
    h(3) = plot(NaN, NaN, 'Color', '#0000CD', 'LineStyle', '-.', 'LineWidth', 1.2);
    h(4) = plot(NaN, NaN, 'Color', '#00FF00', 'LineStyle', '--', 'LineWidth', 1.2);
    h(5) = plot(NaN, NaN, 'Color', '#000000', 'LineWidth', 1.2);
    legend(h, {'f_0', 'Onset', 'Breath', 'Spectral centroid', 'f_0 slope'}, 'FontName', 'Times New Roman', 'FontSize', 12,...
        'Position', [0.652, 0.642, 0.208, 0.258]);
    %}

    hold off
    xlim(xl);
    ylim(yl);

    ax = gca(fobj);
    ax.FontSize = axFontSize;

    %{
    ylabel('Frequency (Hz)', 'FontSize', 13);
    set(gca, 'YScale', 'log');
    %}

    ylabel('Cent [440 Hz = 0]', 'FontSize', 13);

    %% Second window
    subplot(5, 1, 5);

    % Delta f0
    addpath('./lib/CWT/');
    df0 = ft_deltaf0(f0_song, 0.005, 440);
    plot(t_f0_song, df0);
    xlim(xl);
    yticks([-4000, 0, 4000, 8000]);
    ylim([-4000, 9000]);

    ax = gca(fobj);
    ax.FontSize = axFontSize;

    xlabel('Time (sec.)', 'FontSize', 13);

    legend({'\Delta f_0'}, 'FontName', 'Times New Roman', 'FontSize', 12,...
        'Position', [0.66, 0.16, 0.11, 0.067]);

    %%
    saveas(fobj, strcat(outputdir_fig, '/figure4.png'))
end

function h_plotsoundwave(audio_song, audio_speech)
    [s_song, fs_song] = audioread(audio_song);
    [s_speech, fs_speech] = audioread(audio_speech);

    t_s_song = (0:(numel(s_song) - 1))./fs_song;
    t_s_speech = (0:(numel(s_speech) - 1))./fs_speech;
    
    fobj = figure;
    clf; cla;

    subplot(2, 1, 1);
    plot(t_s_song, s_song, 'Color', '#0072BD');
    %ax = gca(fobj);
    %ax.FontSize = 14;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);

    subplot(2, 1, 2);
    plot(t_s_speech, s_speech, 'Color', '#D95319');
    %ax = gca(fobj);
    %ax.FontSize = 14;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
end

function h_plotf0(f0_song, f0_speech)
    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;

    T = readtable(f0_speech);
    t_f0_speech = T.time;
    f0_speech = T.voice_1;
    
    fobj = figure;
    clf; cla;

    subplot(2, 1, 1);
    scatter(t_f0_song, f0_song, 'Marker', '.', 'MarkerEdgeColor', '#0072BD');
    ylim([80, 450]);
    %ax = gca(fobj);
    %ax.FontSize = 14;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);

    subplot(2, 1, 2);
    scatter(t_f0_speech, f0_speech, 'Marker', '.', 'MarkerEdgeColor', '#D95319');
    ylim([80, 450]);
    %ax = gca(fobj);
    %ax.FontSize = 14;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);

    h_histogram(f0_song(f0_song ~= 0), f0_speech(f0_speech ~= 0));
end

function h_histogram(X, Y)
    [d, tau] = pb_effectsize(X, Y);
    d_Cohen = sqrt(2)*norminv(d, 0, 1);

    fobj = figure;
    clf; cla;

    histogram(X, 40, 'EdgeColor', 'none', 'FaceColor', '#0072BD', 'Normalization', 'pdf');
    hold on
    histogram(Y, 40, 'EdgeColor', 'none', 'FaceColor', '#D95319', 'Normalization', 'pdf');
    hold off

    %ax = gca(fobj);
    %ax.FontSize = 14;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
    fprintf('%3.3f (%3.6f) (%3.3f)\n', d, tau, d_Cohen);
end