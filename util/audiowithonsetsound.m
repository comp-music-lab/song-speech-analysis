function audiowithonsetsound
    %%
    %{
    outputfilepath_img = 'C:\Users\yuto\Downloads\Florence_(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.png';
    outputfilepath = 'C:\Users\yuto\Downloads\Florence_(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.wav';
    audiofilepath = '..\data\Stage 1 RR Audio\(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.wav';
    onsetfilepath = 'C:\Users\yuto\Downloads\onset_(excerpt) Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc.csv';
    %}
    
    dataname = '(excerpt) Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc';

    outputfilepath_img = strcat('..\output\20220526\', 'G-Dhwani_', dataname, '.png');
    outputfilepath = strcat('..\output\20220526\', 'G-Dhwani__', dataname, '.wav');
    audiofilepath = strcat('..\data\Stage 1 RR Audio\', dataname, '.wav');
    onsetfilepath = strcat('..\data\Stage 1 RR Round 1\Dhwani\', 'onset_', dataname, '.csv');

    %%
    [s, fs] = audioread(audiofilepath);
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    t = (0:(numel(s) - 1))./fs;

    %%
    clicksound = audioread('clicksound.wav');
    clicksound = mean(clicksound, 2);

    %%
    T = readtable(onsetfilepath);
    t_onset = unique(T.Var1);
    
    %%
    f = figure(1);
    clf; cla;
    plot(t, s);
    hold on;
    yl = ylim();
    for i=1:numel(t_onset)
        plot(t_onset(i).*[1, 1], yl, '-.m');
    end
    saveas(f, outputfilepath_img);
    hold off;

    %%
    xsynth = h_clicksynth(s, t, clicksound, t_onset, true);
    audiowrite(outputfilepath, xsynth, fs);
end