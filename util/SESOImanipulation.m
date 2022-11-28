function SESOImanipulation
    %%
    datadir = '../data/Stage 1 RR Full/';
    subdir = {'Dhwani', 'Florence', 'Patrick', 'Shafagh', 'Yuto'};
    performer = {'Parimal', 'Florence', 'John', 'Shafagh', 'Yuto'};
    stimulipair = {...
        {'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220320_song',...
        'Parimal_Sadaphal_Marathi_Spiritual_Maajhe Maahera Pandhari_20220430_desc'},...
        {'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_song',...
        'Florence_Nweke_Yoruba_Yoruba_Traditional_Ise-Agbe_20220504_desc'},...
        {'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc'},...
        {'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220430_song',...
        'Shafagh_Hadavi_Farsi_Iran_Traditional_YekHamoomi_20220502_desc'},...
        {'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_song',...
        'Yuto_Ozaki_Japanese_Japanese_Traditional_Asatoya-Yunta_20220209_desc'}
        };
    
    fs_target = 16000;
    clicksound = audioread('clicksound.wav');
    clicksound = mean(clicksound, 2);
    audiodir = '../data/Stage 1 RR Audio/full-length/';
    outputdir = '../output/SESOI-manipulation/';
    
    %%
    addpath('../');
    addpath('../lib/two-sample/');
    q = normcdf(0.4/sqrt(2));
    
    for j=2:2
        for i=1:numel(subdir)
            if j == 1
                %%
                f0filepath = strcat(datadir, subdir{i}, '/', stimulipair{i}{1}, '_f0.csv');
                T = readtable(f0filepath);
                t_song = T.time;
                f0_song = T.voice_1;
                X = 1200.*log2(f0_song(f0_song ~= 0)./440);
                
                f0filepath = strcat(datadir, subdir{i}, '/', stimulipair{i}{2}, '_f0.csv');
                T = readtable(f0filepath);
                t_desc = T.time;
                f0_desc = T.voice_1;
                Y = 1200.*log2(f0_desc(f0_desc ~= 0)./440);
            
                %%
                p = pb_effectsize(X, Y);
                f = @(C) pb_effectsize(X + C, Y) - q;
                C_q = fzero(f, 0);
                f = @(C) pb_effectsize(X + C, Y) - 0.5;
                C_0 = fzero(f, 0);
                
                fprintf(['f0: ', subdir{i}, ' (', num2str(p, '%3.3f'), '): ', num2str(C_q, '%3.3f'), ', ', num2str(C_0, '%3.3f'), '\n']);
                
                %%
                f0vec = f0_song;
                f0vec(f0vec ~= 0) = f0vec(f0vec ~= 0).*2^(C_q/1200);
                fmsignal = f0synth(f0vec, fs_target, fs_target*(t_song(2) - t_song(1)));
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_f0_sesoi.wav'), fmsignal, fs_target);
            
                f0vec = f0_song;
                f0vec(f0vec ~= 0) = f0vec(f0vec ~= 0).*2^(C_0/1200);
                fmsignal = f0synth(f0vec, fs_target, fs_target*(t_song(2) - t_song(1)));
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_f0_equiv.wav'), fmsignal, fs_target);
            
                fmsignal = f0synth(f0_song, fs_target, fs_target*(t_song(2) - t_song(1)));
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_f0.wav'), fmsignal, fs_target);
            
                fmsignal = f0synth(f0_desc, fs_target, fs_target*(t_desc(2) - t_desc(1)));
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_desc_f0.wav'), fmsignal, fs_target);
            elseif j == 2
                %%
                onsetfilepath = strcat(datadir, subdir{i}, '/onset_', stimulipair{i}{1}, '.csv');
                T = readtable(onsetfilepath);
                t_onset_song = table2array(T(:, 1));
                breakfilepath = strcat(datadir, subdir{i}, '/break_', stimulipair{i}{1}, '.csv');
                T = readtable(breakfilepath);
                t_break = table2array(T(:, 1));
                X = helper.h_ioi(t_onset_song, t_break);

                onsetfilepath = strcat(datadir, subdir{i}, '/onset_', stimulipair{i}{2}, '.csv');
                T = readtable(onsetfilepath);
                t_onset_desc = table2array(T(:, 1));
                breakfilepath = strcat(datadir, subdir{i}, '/break_', stimulipair{i}{2}, '.csv');
                T = readtable(breakfilepath);
                t_break = table2array(T(:, 1));
                Y = helper.h_ioi(t_onset_desc, t_break);

                %%
                p = pb_effectsize(X, Y);
                f = @(C) pb_effectsize(log(X) + C, log(Y)) - q;
                C_q = fzero(f, 0);
                f = @(C) pb_effectsize(log(X) + C, log(Y)) - 0.5;
                C_0 = fzero(f, 0);
                
                fprintf(['IOI: ', subdir{i}, ' (', num2str(p, '%3.3f'), '): ', num2str(exp(C_q), '%3.3f'), ', ', num2str(exp(C_0), '%3.3f'), '\n']);
                
                %%
                [s, fs] = audioread(strcat(audiodir, stimulipair{i}{1}, '.wav'));
                s = mean(s, 2);

                s_ts = stretchAudio(s, 1/exp(C_q));
                t = (0:(size(s_ts, 1) - 1))./fs;
                s_ts = 0.025/quantile(abs(s_ts), 0.98) .* s_ts;
                xsynth = h_clicksynth(s_ts, t, clicksound, t_onset_song.*exp(C_q), true);
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_ioi_sesoi.wav'), xsynth, fs);

                s_ts = stretchAudio(s, 1/exp(C_0));
                t = (0:(size(s_ts, 1) - 1))./fs;
                s_ts = 0.025/quantile(abs(s_ts), 0.98) .* s_ts;
                xsynth = h_clicksynth(s_ts, t, clicksound, t_onset_song.*exp(C_0), true);
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_ioi_equiv.wav'), xsynth, fs);

                t = (0:(size(s, 1) - 1))./fs;
                s = 0.025/quantile(abs(s), 0.98) .* s;
                xsynth = h_clicksynth(s, t, clicksound, t_onset_song, true);
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_song_ioi.wav'), xsynth, fs);

                [s, fs] = audioread(strcat(audiodir, stimulipair{i}{2}, '.wav'));
                s = mean(s, 2);
                t = (0:(size(s, 1) - 1))./fs;
                s = 0.025/quantile(abs(s), 0.98) .* s;
                xsynth = h_clicksynth(s, t, clicksound, t_onset_desc, true);
                audiowrite(strcat(outputdir, performer{i}, '-', subdir{i}, '_desc_ioi.wav'), xsynth, fs);
            end
        end
    end
end