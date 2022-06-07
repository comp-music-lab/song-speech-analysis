function checkPraat
    %%
    dataname = '(excerpt) Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc';
    audiodir = '../Stage 1 RR Audio/';
    mono= true;

    %%
    audiofilepath = strcat(audiodir, dataname, '.wav');
    [s, fs] = audioread(audiofilepath);
    
    if size(s, 2) == 2
        s = mean(s, 2);
    end
    
    t = (0:(numel(s) - 1))./fs;

    %%
    clicksound = audioread('clicksound.wav');
    clicksound = mean(clicksound, 2);

    %%
    praatfilepath = strcat(dataname, '_data.txt');
    T = readtable(praatfilepath);
    t_onset = T.nucl_t1;

    %%
    xsynth = h_clicksynth(s, t, clicksound, t_onset, mono);

    %%
    figure(1);
    plot(t, s);
    hold on;
    yl = ylim();
    for i=1:numel(t_onset)
        plot(t_onset(i).*[1, 1], yl, '-.m');
    end
    hold off;
end