%%
duration = Inf;
typeflag = 1;
exploratory = false;
al = 0.05/6;

%%
datainfoid = 'datainfo_Hilton-pyin';
outputdir = './output/Hilton-pyin/';
analysis_featureES_1(datainfoid, duration, typeflag, exploratory, outputdir);

esinfofile = strcat(outputdir, 'results_effectsize_acoustic_song-desc_Infsec.csv');
T = readtable(esinfofile);
writetable(T(strcmp(T.feature, 'f0'), :), esinfofile);

outputfile = strcat(outputdir, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);

%%
datainfoid = 'datainfo_Hilton-sa';
outputdir = './output/Hilton-sa/';
analysis_featureES_1(datainfoid, duration, typeflag, exploratory, outputdir);

esinfofile = strcat(outputdir, 'results_effectsize_acoustic_song-desc_Infsec.csv');
T = readtable(esinfofile);
writetable(T(strcmp(T.feature, 'f0'), :), esinfofile);

outputfile = strcat(outputdir, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);