%%
%%{
%dataname = 'Latyr_Sy_Wolof_Traditional_Mbeuguel_20221021_song';
%dataname = 'Tutushamum_Teyxokawa_Puri_Traditional_Petara_20221020_desc';
dataname = 'Polina_Proutskova_Russian_Traditional_Dusha moia pregreshnaia_20220301_song';
inputdir = {'../data/Stage 2 Annotation/', '../data/Stage 2 Annotation (pYIN)/'};

figure;

for i=1:numel(inputdir)
    f0filepath = strcat(inputdir{i}, dataname, '_f0.csv');
    T = readtable(f0filepath);
    t_f0 = T.time;
    f0 = T.voice_1;

    plot(t_f0, 1200.*log2(f0./440));
    title(dataname, 'Interpreter', 'none');
    hold on
end
hold off
%}

%%
inputdir = '../data/Stage 2 Annotation (Hilton)/';
dirinfo = dir(inputdir);

%%{
i = randi(length(dirinfo));
filename = dirinfo(i).name;
while ~contains(filename, 'D_f0.csv')
    i = randi(length(dirinfo));
    filename = dirinfo(i).name;
end
s = strsplit(filename, '_');
dataname = s{1};
%}

%{
dataname = 'MEN12D';
filename = strcat(dataname, '_f0.csv');
%}

T = readtable(strcat(inputdir, filename));
t_f0 = T.time;
f0 = T.voice_1;

[s, fs] = audioread(strcat('G:\Datasets\Hilton\IDS-corpus-raw\IDS-corpus-raw', filesep, dataname, '.wav'));
[S, F, T] = spectrogram(mean(s, 2), hann(4096), 4096*7/8, 4096, fs);
P = abs(S);

figure(1);
clf; cla;
surf(T, F, log(P) -  max(log(P(:))) - 1, 'EdgeColor', 'none');
view(0, 90);
hold on
scatter(t_f0, f0, 'Marker', '.');
hold off
title(filename, 'Interpreter', 'none');
axis tight;
ylim([50, max(max(f0)*1.1, 500)]);