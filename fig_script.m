function fig_script
    %%
    audio_song = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.wav';
    audio_speech = './data/Stage 1 RR Audio/full-length/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit.wav';
    f0_song = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song_f0.csv';
    f0_speech = './data/Stage 1 RR Full/Florence/Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit_f0.csv';
    onset_song = './data/Stage 1 RR Full/Florence/onset_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';
    onset_speech = './data/Stage 1 RR Full/Florence/onset_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit.csv';
    break_song = './data/Stage 1 RR Full/Florence/break_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song.csv';
    break_speech = './data/Stage 1 RR Full/Florence/break_Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_recit.csv';

    %%
    T = readtable(onset_song);
    t_onset_song = T.Var1;

    T = readtable(onset_speech);
    t_onset_speech = T.Var1;

    T = readtable(break_song);
    t_break_song = T.Var1;

    T = readtable(break_speech);
    t_break_speech = T.Var1;

    T = readtable(f0_song);
    t_f0_song = T.time;
    f0_song = T.voice_1;

    T = readtable(f0_speech);
    t_f0_speech = T.time;
    f0_speech = T.voice_1;

    [s_song, fs_song] = audioread(audio_song);
    [S, F_song, T_song] = spectrogram(s_song, hann(2048), 2048*3/4, 2048, fs_song);
    P_song = 10.*log10(abs(S).^2) - 100;

    [s_speech, fs_speech] = audioread(audio_speech);
    [S, F_speech, T_speech] = spectrogram(s_speech, hann(2048), 2048*3/4, 2048, fs_speech);
    P_speech = 10.*log10(abs(S).^2) - 100;

    fobj = figure(1);
    fobj.Position = [20, 531, 723, 448];

    subplot(2, 1, 1);
    surf(T_song, F_song, P_song, 'EdgeColor', 'none');
    view(0, 90);
    axis tight;
    hold on
    plot(t_f0_song, f0_song, 'r', 'LineWidth', 1.3);
    ylim([80, 4000]);
    yl = ylim();
    for i=1:numel(t_onset_song)
        plot(t_onset_song(i).*[1, 1], yl, 'Color', '#FF00FF', 'LineWidth', 1.2);
    end
    for i=1:numel(t_break_song)
        plot(t_break_song(i).*[1, 1], yl, 'Color', '#FFFF00', 'LineWidth', 1.2, 'LineStyle', '-.');
    end
    hold off
    xlim([0.2, 5.5]);
    set(gca, 'YScale', 'log');
    ylabel('Singing', 'FontSize', 14);
    ax = gca(fobj);
    ax.FontSize = 9;
    
    subplot(2, 1, 2);
    surf(T_speech, F_speech, P_speech, 'EdgeColor', 'none');
    view(0, 90);
    axis tight;
    hold on
    plot(t_f0_speech, f0_speech, 'r', 'LineWidth', 1.3);
    ylim([80, 4000]);
    yl = ylim();
    for i=1:numel(t_onset_speech)
        plot(t_onset_speech(i).*[1, 1], yl, 'Color', '#FF00FF', 'LineWidth', 1.2);
    end
    for i=1:numel(t_break_speech)
        plot(t_break_speech(i).*[1, 1], yl, 'Color', '#FFFF00', 'LineWidth', 1.2, 'LineStyle', '-.');
    end
    hold off
    xlim([0.2, 5.5]);
    set(gca, 'YScale', 'log');
    ylabel('Lyrics recitation', 'FontSize', 14);
    ax = gca(fobj);
    ax.FontSize = 9;
end