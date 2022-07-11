function audiowithonsetsound
    %%
    dataname = {...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_recit',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_inst',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220507_inst',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_recit',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_inst',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_song',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_recit',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_desc',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_recit',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220224_inst'...
    };
    
    i = randi(numel(dataname), 1);

    onsetfilepath = strcat('../data/Stage 1 RR Full/', 'onset_', dataname{i}, '.csv');
    
    %%
    T = readtable(onsetfilepath);
    t_onset = unique(T.Var1);
    
    %%
    r = max(0.3, rand * 2);
    t_onset_r = t_onset .* r;

    %%
    clicksound = audioread('clicksound.wav');
    clicksound = mean(clicksound, 2);

    %%
    fs = 44100;
    L = max(t_onset_r) + 1;
    s = zeros(round(fs*L), 1);
    t = (0:(numel(s) - 1))./fs;

    xsynth = h_clicksynth(s, t, clicksound, t_onset_r, true);
    sound(xsynth, fs);

    %%
    %{
    breakfilepath = strcat('../data/Stage 1 RR Full/', 'break_', dataname, '.csv');
    T = readtable(breakfilepath);
    t_break = unique(T.Var1);

    currentpath = pwd();
    cd('../');
    [ioi, ioiratio] = helper.h_ioi(t_onset, t_break);
    cd(currentpath);
    
    figure;
    subplot(2, 1, 1);
    plot(ioi);
    hold on;
    scatter(1:numel(ioi), ioi, 'Marker', 'o');
    hold off;
    subplot(2, 1, 2);
    plot(ioiratio);
    hold on;
    scatter(1:numel(ioiratio), ioiratio, 'Marker', 'o');
    plot([1, numel(ioiratio)], [0.5, 0.5], '-.m');
    hold off;
    %}

    %%
    %{
    [s, fs] = audioread(audiofilepath);
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    t = (0:(numel(s) - 1))./fs;

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
    audiowrite(outputfilepath, xsynth, fs);
    %}
end