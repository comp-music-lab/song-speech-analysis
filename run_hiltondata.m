%%
duration = Inf;
typeflag_songdesc = 1;
exploratory = false;
al = 0.05/6;
blindedonly = false;

%%
outputdir_analysis = './output/analysis/Stage1/Hilton-pyin/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfofile = './datainfo_pilot-Hilton-pyin.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);

%%
outputdir_analysis = './output/analysis/Stage1/Hilton-sa/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfofile = 'datainfo_pilot-Hilton-sa.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);

%%
outputdir_analysis = './output/analysis/Stage1/pilot-pyin-praat/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfoid = 'datainfo_pilot-data-auto';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);